import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch6_graph/six_degrees.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';

const _layerColors = [
  Color(0xff534170),
  Color(0xff006d77),
  Color(0xff12639b),
  Color(0xff584fa8),
  Color(0xff89488d),
  Color(0xffa45232),
  Color(0xff397239),
  Color(0xff815523),
];

class SixDegreeStage extends StatefulWidget {
  const SixDegreeStage({
    super.key,
    required this.state,
    required this.rule,
    required this.onSource,
    this.editor,
    this.editorHint,
  });
  final PlaybackState state;
  final SixDegreeRule rule;
  final ValueChanged<String> onSource;
  final Widget? editor;
  final String? editorHint;
  @override
  State<SixDegreeStage> createState() => _SixDegreeStageState();
}

class _SixDegreeStageState extends State<SixDegreeStage> {
  TraceTimeline? previous;
  final positions = <String, Offset>{};
  double gap = 48, extent = 100;
  int lastLayer = 0;

  void layout(TraceTimeline timeline) {
    if (identical(previous, timeline)) return;
    previous = timeline;
    final scene = timeline.frames.last.scene, groups = <int, List<String>>{};
    final reached = scene.auxTables.single.rows;
    lastLayer = reached.isEmpty ? 0 : int.parse(reached.last[1]);
    for (final row in reached) {
      (groups[int.parse(row[1])] ??= []).add(row[0]);
    }
    for (final n in scene.nodes) {
      if (n.groupTag == null) (groups[lastLayer + 1] ??= []).add(n.id);
    }
    gap = 60;
    for (final group in groups.entries) {
      if (group.key > 0 && group.value.length > 1) {
        gap = math.max(
          gap,
          32 / (group.key * math.sin(math.pi / group.value.length)),
        );
      }
    }
    final radius = groups.keys.fold<int>(0, math.max) * gap;
    extent = 2 * (radius + 48);
    positions.clear();
    final center = Offset(extent / 2, extent / 2);
    for (final group in groups.entries) {
      for (final (i, id) in group.value.indexed) {
        final angle = 2 * math.pi * (i + .5) / group.value.length - math.pi / 2;
        positions[id] =
            center +
            Offset(math.cos(angle), math.sin(angle)) *
                group.key.toDouble() *
                gap;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state,
        timeline = state.timeline!,
        frame = state.currentFrame!,
        vars = frame.inlineVars;
    layout(timeline);
    final source = vars['源点']!,
        layer = int.parse(vars['最远层']!),
        total = int.parse(vars['总人数']!),
        count = int.parse(vars['已达其他人']!);
    final printed = widget.rule == SixDegreeRule.printed;
    final next = timeline
        .frames[math.min(timeline.frames.length - 1, state.frameIndex + 1)];
    final t = MediaQuery.disableAnimationsOf(context) ? 0.0 : state.subProgress;
    final wave = layer + (int.parse(next.inlineVars['最远层']!) - layer) * t;
    final histogram = <int, int>{};
    for (final n in frame.scene.nodes) {
      if (n.groupTag != null) {
        final d = int.parse(n.groupTag!);
        histogram.update(d, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final scene = frame.scene.copyWith(
      nodes: [
        for (final n in frame.scene.nodes)
          n.copyWith(
            x: positions[n.id]!.dx - n.width / 2,
            y: positions[n.id]!.dy - n.height / 2,
          ),
      ],
    );
    final canvas = DsStageCanvas(
      key: const ValueKey('six-network'),
      scene: scene,
      sceneSize: Size.square(extent),
      selectedNodeId: source,
      onSelect: widget.onSource,
      traversalEdges: true,
      backdropPainter: _WavePainter(gap, layer, wave),
      nodeContentBuilder: (context, n) {
        final d = int.tryParse(n.groupTag ?? '');
        final colors = Theme.of(context).colorScheme;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: d == null ? colors.surfaceContainerHighest : _layerColors[d],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                n.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  color: d == null ? colors.onSurface : Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              frame.phaseTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '触达其他人　$count / $total = ${vars['占比']}',
              key: const ValueKey('six-count'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            LinearProgressIndicator(
              value: total == 0 ? 0 : count / total,
              semanticsLabel: '当前触达比例',
            ),
            const SizedBox(height: 6),
            Text(
              widget.editor == null
                  ? '点击人物切换源点并播放。每个彩色圈表示一层最短距离。'
                  : widget.editorHint!,
            ),
            SizedBox(
              height: (c.maxHeight * .67).clamp(245.0, 660.0),
              child: widget.editor ?? canvas,
            ),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (int d = 1; d <= math.max(6, lastLayer); d++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 10, color: _layerColors[d]),
                      Text(' $d 度　${histogram[d] ?? 0} 人'),
                    ],
                  ),
              ],
            ),
            Text('队列（队首在左）　${vars['队列']!.isEmpty ? '∅' : vars['队列']}'),
            Text(frame.explanation),
            if (printed) Text('已出队 ${vars['出队次数']} 次 · 教材整型输出 ${vars['整型输出']}'),
            Text(
              printed
                  ? '教材第 185 页每次循环出队一人，至多七次。出队次数与最短路径层数分别统计。'
                  : '按最短路径计 1～6 条边。源点只计入分母，灰点尚未计入触达人数。',
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.gap, this.layer, this.wave);
  final double gap, wave;
  final int layer;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.stroke;
    for (var d = 1; d <= layer; d++) {
      paint.color = _layerColors[d].withValues(alpha: .43);
      paint.strokeWidth = 2;
      canvas.drawCircle(center, d * gap, paint);
    }
    if (wave > 0) {
      final color = _layerColors[wave.ceil()];
      paint.color = color.withValues(alpha: .17);
      paint.strokeWidth = 10;
      canvas.drawCircle(center, wave * gap, paint);
      paint.color = color.withValues(alpha: .7);
      paint.strokeWidth = 2;
      canvas.drawCircle(center, wave * gap, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.gap != gap || old.layer != layer || old.wave != wave;
}
