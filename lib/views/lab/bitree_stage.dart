import 'dart:math' as math;
import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import '../../curriculum/ch5_tree/bitree_traverse.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/trace_model.dart';

part 'bitree_workshop_panel.dart';

class EulerContour {
  EulerContour(SceneSnapshot scene) {
    final nodes = {for (final n in scene.nodes) n.id: n};
    final children = {
      for (final e in scene.edges) (e.fromNodeId, e.fromPort): e.toNodeId,
    };
    const radius = 35.0;
    void walk(String? id) {
      if (id == null) return;
      final n = nodes[id]!,
          center = Offset(n.x + n.width / 2, n.y + n.height / 2);
      points.add(center - const Offset(radius, 0));
      sides.add(0);
      walk(children[(id, EdgePort.lchild)]);
      points.add(center + const Offset(0, radius));
      sides.add(1);
      walk(children[(id, EdgePort.rchild)]);
      points.add(center + const Offset(radius, 0));
      sides.add(2);
    }

    if (nodes.isEmpty) return;
    walk('b1');
    final tangents = [
      const Offset(0, 1),
      const Offset(1, 0),
      const Offset(0, -1),
    ];
    for (var i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length,
          a = points[i],
          b = points[j],
          part = Path()..moveTo(a.dx, a.dy);
      if (j == 0) {
        final center = (a + b) / 2;
        part.arcTo(
          Rect.fromCircle(center: center, radius: radius),
          0,
          -math.pi,
          false,
        );
      } else {
        final distance = (b - a).distance;
        final handle = distance < radius * 1.5
            ? radius * .55228475
            : math.min(60.0, distance / 2.5);
        final c1 = a + tangents[sides[i]] * handle,
            c2 = b - tangents[sides[j]] * handle;
        part.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
      }
      outline.addPath(part, Offset.zero);
      segments.add(part.computeMetrics().single);
    }
  }
  final points = <Offset>[], sides = <int>[], segments = <PathMetric>[];
  final outline = Path();
  Offset sample(int index, double progress) {
    if (index < 0 || index >= points.length) return points.first;
    if (progress <= 0) return points[index];
    if (progress >= 1) return points[(index + 1) % points.length];
    final curve = segments[index];
    return curve.getTangentForOffset(curve.length * progress)!.position;
  }
}

class _TourPainter extends CustomPainter {
  const _TourPainter(
    this.contour,
    this.index,
    this.progress,
    this.emit,
    this.color,
  );
  final EulerContour contour;
  final int index;
  final double progress;
  final bool emit;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (contour.points.isEmpty) return;
    canvas.drawPath(
      contour.outline,
      Paint()
        ..color = color.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final ball = contour.sample(index, progress);
    if (emit && index >= 0 && index < contour.points.length) {
      canvas.drawCircle(
        contour.points[index],
        8 + 15 * progress,
        Paint()
          ..color = color.withValues(alpha: .85 * (1 - progress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    canvas.drawCircle(
      ball,
      9,
      Paint()
        ..color = color.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(ball, 5.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TourPainter old) =>
      old.contour != contour ||
      old.index != index ||
      old.progress != progress ||
      old.emit != emit ||
      old.color != color;
}

class BiTreeStage extends StatefulWidget {
  const BiTreeStage({
    super.key,
    required this.input,
    required this.frame,
    required this.progress,
  });
  final TreeInput input;
  final TraceFrame frame;
  final double progress;
  @override
  State<BiTreeStage> createState() => _BiTreeStageState();
}

class _BiTreeStageState extends State<BiTreeStage> {
  EulerContour? contour;
  @override
  void initState() {
    super.initState();
    if (widget.input.lesson.isTour) contour = EulerContour(widget.frame.scene);
  }

  @override
  void didUpdateWidget(BiTreeStage old) {
    super.didUpdateWidget(old);
    if (widget.input.lesson.isTour &&
        (!old.input.lesson.isTour ||
            old.input.sequence != widget.input.sequence)) {
      contour = EulerContour(widget.frame.scene);
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame,
        scene = frame.scene,
        vars = frame.inlineVars,
        mode = widget.input.lesson;
    final size = mode.isWorkshop
        ? Size(double.parse(vars["画布宽"]!), double.parse(vars["画布高"]!))
        : Size(
            scene.nodes.fold<double>(
              190,
              (v, n) => math.max(v, n.x + n.width + 65),
            ),
            scene.nodes.fold<double>(
              160,
              (v, n) => math.max(v, n.y + n.height + 65),
            ),
          );
    final stack = mode == TreeLesson.stack,
        properties = mode == TreeLesson.properties;
    final rows = scene.auxTables.single.rows;
    Widget stackPanel() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SqStack<BiTree>', style: Theme.of(context).textTheme.titleSmall),
        Text('p = ${vars["p"]}　q = ${vars["q"]}'),
        if (rows.isEmpty) const Text('空栈'),
        for (final r in rows.reversed)
          Text('${r == rows.last ? "栈顶" : "　　"}  [${r[0]}] ${r[1]} → ${r[2]}'),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) {
        final board = SizedBox(
          height: (c.maxHeight - 110).clamp(190.0, 560.0),
          child: DsStageCanvas(
            key: ValueKey(widget.input.sequence),
            scene: scene,
            sceneSize: size,
            backdropPainter: !mode.isTour
                ? null
                : _TourPainter(
                    contour!,
                    int.parse(vars['轨迹序号']!),
                    widget.progress,
                    vars['采集'] == '是',
                    Theme.of(context).colorScheme.primary,
                  ),
          ),
        );
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.phaseTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (mode.isWorkshop)
                  _WorkshopStatePanel(
                    mode: mode,
                    frame: frame,
                    sequence: widget.input.sequence,
                  ),
                if (mode.isTour || stack || mode == TreeLesson.levelOrder)
                  Text(
                    '输出　${vars["输出"]!.isEmpty ? "∅" : vars["输出"]}',
                    key: const ValueKey('tree-output'),
                  ),
                if (properties)
                  for (final r in rows) Text('${r[0]}　${r[1]}'),
                if (stack && c.maxWidth >= 580)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: board),
                      SizedBox(width: 178, child: stackPanel()),
                    ],
                  )
                else ...[
                  if (stack) stackPanel(),
                  board,
                ],
                if (properties) _StorageMapping(scene),
                Text(frame.explanation),
              ],
            ),
          ),
        );
      },
    );
  }
}
