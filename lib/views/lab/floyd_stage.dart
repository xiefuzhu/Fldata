import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch6_graph/floyd.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../engine/canvas/edge_geometry.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';

class FloydStage extends StatefulWidget {
  const FloydStage({
    super.key,
    required this.state,
    required this.input,
    required this.editorHint,
    required this.canvasBuilder,
  });
  final PlaybackState state;
  final GraphInputModel input;
  final String editorHint;
  final Widget Function(SceneSnapshot, CustomPainter Function(SceneSnapshot)?)
  canvasBuilder;
  @override
  State<FloydStage> createState() => _FloydStageState();
}

class _FloydStageState extends State<FloydStage>
    with SingleTickerProviderStateMixin {
  (int, int)? selected;
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  bool reduced = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) pulse.stop();
  }

  @override
  void didUpdateWidget(FloydStage old) {
    super.didUpdateWidget(old);
    if (!identical(old.state.timeline, widget.state.timeline)) selected = null;
    if (!identical(old.state.currentFrame, widget.state.currentFrame)) {
      final phase = widget.state.currentFrame!.inlineVars['阶段'];
      if (!reduced && (phase == '写回' || phase == '比较')) {
        pulse.forward(from: 0);
      } else {
        pulse.reset();
      }
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.state.currentFrame!, vars = frame.inlineVars;
    final dist = frame.scene.auxTables.first, pred = frame.scene.auxTables.last;
    final k = int.parse(vars['k']!),
        i = int.tryParse(vars['i'] ?? ''),
        j = int.tryParse(vars['j'] ?? '');
    final phase = vars['阶段'], done = phase == '完成', updating = phase == '写回';
    final pair = done ? selected : null, colors = Theme.of(context).colorScheme;
    var scene = frame.scene;
    String? pathText;
    if (pair != null) {
      final (a, b) = pair;
      final ids = widget.input.vertices.map((v) => v.id).toList();
      final indices = floydRoute(
        a,
        b,
        pred.rows[a].skip(1).map(int.parse).toList(),
      );
      final labels = indices.map((v) => ids[v]).toList();
      pathText = labels.isEmpty
          ? '${ids[a]} → ${ids[b]}：不可达'
          : '${labels.join(' → ')}　长度 ${dist.rows[a][b + 1]}';
      final routeEdges = {
        for (var z = 1; z < labels.length; z++)
          widget.input.edge(labels[z - 1], labels[z])!.id,
      };
      scene = scene.copyWith(
        nodes: [
          for (final n in scene.nodes)
            n.copyWith(
              visualState: labels.contains(n.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final e in scene.edges)
            e.copyWith(
              visualState: routeEdges.contains(e.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
      );
    }
    final operands = <(int, int)>{
      if (i != null && j != null && k >= 0) ...[(i, k), (k, j)],
    };
    final target = pair ?? (i != null && j != null ? (i, j) : null);
    final canvas = widget.canvasBuilder(
      scene,
      vars.containsKey('拼接') ? (s) => _PathGlow(s, pulse, reduced) : null,
    );
    Widget matrix(AuxTableSnapshot data) => _HeatMatrix(
      data: data,
      k: k,
      operands: operands,
      target: target,
      pulse: updating && !reduced ? pulse : null,
      error: frame.isErrorState,
      onSelect: done ? (p) => setState(() => selected = p) : null,
    );
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 600;
        final height = (c.maxHeight * .62).clamp(215.0, 510.0);
        final matrices = c.maxWidth < 440
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  matrix(dist),
                  const SizedBox(height: 8),
                  matrix(pred),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: matrix(dist)),
                  const SizedBox(width: 8),
                  Expanded(child: matrix(pred)),
                ],
              );
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: frame.isErrorState ? colors.error : null,
                ),
              ),
              Text(frame.explanation),
              if (vars['算式'] case final String formula)
                Text(
                  formula,
                  key: const ValueKey('floyd-formula'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              if (vars['拼接'] case final String route) Text('拼接路径　$route'),
              if (pathText != null)
                Text(pathText, key: const ValueKey('floyd-path')),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(height: height, child: canvas),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: matrices),
                  ],
                )
              else ...[
                SizedBox(height: height, child: canvas),
                matrices,
              ],
              Text(widget.editorHint),
            ],
          ),
        );
      },
    );
  }
}

class _HeatMatrix extends StatefulWidget {
  const _HeatMatrix({
    required this.data,
    required this.k,
    required this.operands,
    required this.target,
    required this.pulse,
    required this.error,
    required this.onSelect,
  });
  final AuxTableSnapshot data;
  final int k;
  final Set<(int, int)> operands;
  final (int, int)? target;
  final Animation<double>? pulse;
  final bool error;
  final ValueChanged<(int, int)>? onSelect;
  @override
  State<_HeatMatrix> createState() => _HeatMatrixState();
}

class _HeatMatrixState extends State<_HeatMatrix> {
  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme, data = widget.data;
    final values = data.rows
        .expand((row) => row.skip(1))
        .map(int.tryParse)
        .whereType<int>();
    final maxAbs = values.fold<int>(1, (v, x) => math.max(v, x.abs()));
    Widget box(String label, Color bg, {Color? ink, bool bold = false}) =>
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: colors.outlineVariant, width: .5),
          ),
          child: Text(
            label,
            softWrap: false,
            style: TextStyle(
              color: ink ?? colors.onSurface,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        );
    Widget cell(int i, int j) {
      final p = (i, j),
          value = data.rows[i][j + 1],
          number = int.tryParse(value);
      final chosen = p == widget.target, operand = widget.operands.contains(p);
      final base = number == null || (data.id == 'pred' && number == -1)
          ? colors.surfaceContainerLow
          : Color.lerp(
              colors.surfaceContainerLow,
              colors.primaryContainer,
              .28 + .64 * number.abs() / maxAbs,
            )!;
      final bg = chosen
          ? (widget.error ? colors.errorContainer : colors.tertiaryContainer)
          : operand
          ? Colors.orange.shade200
          : base;
      final tile = box(
        value,
        bg,
        ink: operand && !chosen ? Colors.black87 : null,
        bold: chosen || operand,
      );
      return InkWell(
        key: ValueKey('floyd-${data.id}-$i-$j'),
        onTap: widget.onSelect == null ? null : () => widget.onSelect!(p),
        child: chosen && widget.pulse != null
            ? AnimatedBuilder(
                animation: widget.pulse!,
                child: tile,
                builder: (_, child) => Transform.scale(
                  scale: 1 + .14 * math.sin(math.pi * widget.pulse!.value),
                  child: child,
                ),
              )
            : tile,
      );
    }

    final extent = math.max(
      45.0,
      42 * MediaQuery.textScalerOf(context).scale(1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.title}（k = ${widget.k}）',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Scrollbar(
          controller: scroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8),
            child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              children: [
                TableRow(
                  children: [
                    for (final h in data.columns)
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: extent),
                        child: box(
                          h,
                          colors.surfaceContainerHighest,
                          bold: true,
                        ),
                      ),
                  ],
                ),
                for (final (i, row) in data.rows.indexed)
                  TableRow(
                    children: [
                      box(
                        row.first,
                        colors.surfaceContainerHighest,
                        bold: true,
                      ),
                      for (var j = 0; j < row.length - 1; j++) cell(i, j),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PathGlow extends CustomPainter {
  _PathGlow(this.scene, this.pulse, this.reduced) : super(repaint: pulse);
  final SceneSnapshot scene;
  final Animation<double> pulse;
  final bool reduced;
  @override
  void paint(Canvas canvas, Size size) {
    final nodes = {for (final n in scene.nodes) n.id: n};
    final strength = reduced ? .5 : math.sin(math.pi * pulse.value);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 + 4 * strength;
    for (final e in scene.edges) {
      if (e.visualState == NodeVisualState.normal) continue;
      final g = edgeGeometry(scene, e, nodes);
      if (g == null) continue;
      final (a, c, b) = g;
      pen.color =
          (e.visualState == NodeVisualState.error
                  ? Colors.red
                  : e.visualState == NodeVisualState.comparing
                  ? Colors.orange
                  : Colors.blue)
              .withValues(alpha: .22 + .36 * strength);
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_PathGlow old) =>
      old.scene != scene || old.pulse != pulse || old.reduced != reduced;
}
