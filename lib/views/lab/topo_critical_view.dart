import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/topo_critical.dart';
import '../../engine/canvas/edge_geometry.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'graph_lesson_player.dart';

class TopoCriticalView extends ConsumerStatefulWidget {
  const TopoCriticalView({super.key});
  @override
  ConsumerState<TopoCriticalView> createState() => _TopoState();
}

class _TopoState extends GraphLessonPlayer<TopoCriticalView> {
  var method = TopoMethod.topological;
  @override
  GraphInputModel input = topoPresets.first.input;
  @override
  TopoCriticalModule get module => TopoCriticalModule(method);
  @override
  String get presetKey => 'topo-preset';
  @override
  String get replayLabel => '回放拓扑与关键路径';
  @override
  String get theoryHint => method == TopoMethod.topological
      ? '算法 6.12 使用栈保存零入度顶点，可在图 6.27 上对照输出顺序。'
      : '算法 6.13 先取得拓扑序，再正推 ve、逆推 vl。选择图 6.28 可对照表 6.7 的事件和活动时间。无权弧按一个时间单位计算。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<TopoMethod>(
      key: const ValueKey('topo-method'),
      value: method,
      items: [
        for (final m in TopoMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (next) {
        if (next != null) {
          method = next;
          changeInput(input);
        }
      },
    ),
    const SizedBox(width: 12),
    if (method == TopoMethod.critical)
      TextButton(
        onPressed: () => context.push('/assessment/practice_ch6_parallel_aoe'),
        child: const Text('标定图 6.28'),
      ),
    ...super.controls(state),
  ];
  @override
  Widget stage(PlaybackState state) {
    final f = state.currentFrame!, vars = f.inlineVars, phase = vars['阶段'];
    final events = f.scene.auxTables.first,
        indegree = {
          if (events.columns.contains('indegree'))
            for (final r in events.rows) r.first: r[1],
        };
    Widget node(BuildContext ctx, SceneNode n) {
      final colors = Theme.of(ctx).colorScheme;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: FittedBox(child: Text(n.label))),
          if (indegree[n.id] case final count?)
            Positioned(
              right: -14,
              top: -11,
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(ctx)
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: DecoratedBox(
                  key: ValueKey((n.id, count)),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      'in: $count',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final canvas = _AnimatedGraph(
      frame: f,
      builder: (scene, painter) =>
          editorCanvas(scene, nodeContentBuilder: node, backdrop: painter),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final height = (c.maxHeight * .67).clamp(225.0, 520.0);
        final graph = SizedBox(height: height, child: canvas);
        final tables = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (indegree.isNotEmpty || phase == '建栈')
              Text(
                '零入度栈 S（底 → 顶）　${vars['S']!.isEmpty ? '∅' : vars['S']}',
                key: const ValueKey('topo-stack'),
              ),
            Text(
              '拓扑序（${vars['m']} / ${input.vertices.length}）　${vars['topo']}',
              key: const ValueKey('topo-order'),
            ),
            for (final table in f.scene.auxTables)
              _Timetable(table: table, critical: phase == '关键活动'),
          ],
        );
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.phaseTitle,
                key: const ValueKey('topo-title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: f.isErrorState
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
              Text(f.explanation),
              if (c.maxWidth >= 580)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: graph),
                    const SizedBox(width: 8),
                    Expanded(child: tables),
                  ],
                )
              else ...[
                graph,
                tables,
              ],
              Text(editorHint),
            ],
          ),
        );
      },
    );
  }
}

class _Timetable extends StatelessWidget {
  const _Timetable({required this.table, required this.critical});
  final AuxTableSnapshot table;
  final bool critical;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(table.title, style: Theme.of(context).textTheme.titleSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              for (final (index, row) in [table.columns, ...table.rows].indexed)
                TableRow(
                  decoration: BoxDecoration(
                    color: index == 0
                        ? colors.surfaceContainerHighest
                        : table.highlightedRows.contains(index - 1)
                        ? (critical
                              ? colors.errorContainer
                              : colors.secondaryContainer)
                        : null,
                  ),
                  children: [
                    for (final value in row)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        child: Text(value, softWrap: false),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedGraph extends StatefulWidget {
  const _AnimatedGraph({required this.frame, required this.builder});
  final TraceFrame frame;
  final Widget Function(SceneSnapshot, CustomPainter Function(SceneSnapshot)?)
  builder;
  @override
  State<_AnimatedGraph> createState() => _AnimatedGraphState();
}

class _AnimatedGraphState extends State<_AnimatedGraph>
    with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    value: 1,
  );
  @override
  void didUpdateWidget(_AnimatedGraph old) {
    super.didUpdateWidget(old);
    if (!identical(widget.frame, old.frame)) {
      final phase = widget.frame.inlineVars['阶段'];
      if (!MediaQuery.disableAnimationsOf(context) &&
          (phase == '减入度' || phase == '关键活动')) {
        pulse.forward(from: 0);
      } else {
        pulse.value = 1;
      }
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (context, _) {
      final f = widget.frame, phase = f.inlineVars['阶段'];
      var scene = f.scene;
      final t = MediaQuery.disableAnimationsOf(context) ? 1.0 : pulse.value;
      if (phase == '减入度' && t < 1) {
        scene = scene.copyWith(
          edges: [
            for (final e in scene.edges)
              e.id == f.inlineVars['弧'] ? e.copyWith(opacity: 1 - t) : e,
          ],
        );
      }
      return widget.builder(
        scene,
        phase == '关键活动'
            ? (s) => _CriticalPathsPainter(s, math.sin(t * math.pi))
            : null,
      );
    },
  );
}

class _CriticalPathsPainter extends CustomPainter {
  const _CriticalPathsPainter(this.scene, this.pulse);
  final SceneSnapshot scene;
  final double pulse;
  @override
  void paint(Canvas canvas, Size size) {
    final nodes = {for (final n in scene.nodes) n.id: n};
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 + 4 * pulse
      ..color = const Color(0xffdb392c);
    for (final e in scene.edges.where(
      (e) => e.visualState == NodeVisualState.sorted,
    )) {
      final geometry = edgeGeometry(scene, e, nodes);
      if (geometry == null) continue;
      final (a, c, b) = geometry;
      final angle = math.atan2(b.dy - c.dy, b.dx - c.dx);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
      for (final sign in [-1, 1]) {
        path.moveTo(b.dx, b.dy);
        path.lineTo(
          b.dx - 10 * math.cos(angle + sign * .5),
          b.dy - 10 * math.sin(angle + sign * .5),
        );
      }
      canvas.drawPath(path, pen);
    }
  }

  @override
  bool shouldRepaint(_CriticalPathsPainter old) =>
      old.scene != scene || old.pulse != pulse;
}
