import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/minimum_spanning_tree.dart';
import '../../engine/canvas/edge_geometry.dart';
import '../../engine/canvas/pointer_edge_painter.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'graph_lesson_player.dart';

class MstView extends ConsumerStatefulWidget {
  const MstView({super.key});
  @override
  ConsumerState<MstView> createState() => _MstState();
}

Color _componentColor(int id, Brightness brightness) => HSVColor.fromAHSV(
  1,
  (id * 137.508 + 165) % 360,
  .74,
  brightness == Brightness.dark ? .94 : .68,
).toColor();

class _MstState extends GraphLessonPlayer<MstView> {
  var method = MstMethod.prim;
  String? source;
  @override
  GraphInputModel input = mstPresets.first.input;
  @override
  MinimumSpanningTreeModule get module =>
      MinimumSpanningTreeModule(method: method, source: source);
  @override
  String get presetKey => 'mst-preset';
  @override
  String get replayLabel => '回放选边';
  @override
  String get theoryHint => method == MstMethod.prim
      ? '算法 6.8 为集合外每个顶点保留一条来自 U 的最轻边。表 6.1 中已并入顶点的 lowcost 为 0。实验另记 U 的成员，因此零权边和负权边也能参与比较。'
      : '算法 6.9 按权值扫描所有边。Vexset 相同表示两端已有通路，再加入这条边就会成环。排序需 O(e log e)，教材数组每次合并至多扫描 n 项。';
  @override
  void loadInput(GraphInputModel next) {
    if (!next.vertices.any((v) => v.id == source)) {
      source = next.vertices.firstOrNull?.id;
    }
    super.loadInput(next);
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<MstMethod>(
      key: const ValueKey('mst-method'),
      value: method,
      items: [
        for (final m in MstMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) {
          method = m;
          changeInput(input);
        }
      },
    ),
    if (method == MstMethod.prim) ...[
      const SizedBox(width: 12),
      const Text('起点 '),
      DropdownButton<String>(
        key: const ValueKey('mst-source'),
        value: source,
        items: [
          for (final v in input.vertices)
            DropdownMenuItem(value: v.id, child: Text(v.id)),
        ],
        onChanged: (s) {
          if (s != null) {
            source = s;
            changeInput(input);
          }
        },
      ),
    ],
    const SizedBox(width: 12),
    ...super.controls(state),
  ];
  @override
  Widget stage(PlaybackState state) {
    final frame = state.currentFrame!,
        prim = method == MstMethod.prim,
        vars = frame.inlineVars;
    final colors = Theme.of(context).colorScheme,
        brightness = Theme.of(context).brightness;
    final pulse = MediaQuery.disableAnimationsOf(context)
        ? 0.5
        : math.pow(math.sin(math.pi * state.subProgress), 2).toDouble();
    final canvas = editorCanvas(
      frame.scene,
      traversal: true,
      backdrop: prim ? (scene) => _CutPainter(scene, pulse) : null,
      nodeContentBuilder: prim
          ? null
          : (context, n) => DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _componentColor(int.parse(n.groupTag!), brightness),
                  width: 4,
                ),
              ),
              child: Center(child: Text(n.label)),
            ),
    );
    final tables = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final table in frame.scene.auxTables) ...[
          Text(table.title, style: Theme.of(context).textTheme.titleSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: colors.outlineVariant),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                  ),
                  children: [
                    for (final h in table.columns)
                      Padding(padding: const EdgeInsets.all(5), child: Text(h)),
                  ],
                ),
                for (final (i, row) in table.rows.indexed)
                  TableRow(
                    decoration: BoxDecoration(
                      color: table.highlightedRows.contains(i)
                          ? colors.secondaryContainer
                          : null,
                    ),
                    children: [
                      for (final (column, value) in row.indexed)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (table.id == 'vexset' && column == 1)
                                Icon(
                                  Icons.circle_outlined,
                                  size: 14,
                                  color: _componentColor(
                                    int.parse(value),
                                    brightness,
                                  ),
                                ),
                              Text(
                                value,
                                style: table.id == 'edges' && row.last == '舍弃'
                                    ? TextStyle(
                                        color: colors.error,
                                        decoration: TextDecoration.lineThrough,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 560;
        final area = (c.maxHeight * .70).clamp(230.0, 550.0);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: frame.phaseTitle.contains('回路') ? colors.error : null,
                ),
              ),
              Text(
                '已选 ${vars['已选边']} 条边　权值和 ${vars['权值和']}　当前 ${vars['分量数']} 个分量',
                key: const ValueKey('mst-summary'),
              ),
              Text(frame.explanation),
              Text(prim ? 'U = {${vars['U']}}　橙色边跨越当前割集。' : '同色环与相同分量号表示连通。'),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(height: area, child: canvas),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: tables),
                  ],
                )
              else ...[
                SizedBox(height: area, child: canvas),
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

class _CutPainter extends CustomPainter {
  const _CutPainter(this.scene, this.pulse);
  final SceneSnapshot scene;
  final double pulse;
  @override
  void paint(Canvas canvas, Size size) {
    final nodes = {for (final n in scene.nodes) n.id: n};
    Offset center(SceneNode n) => Offset(n.x + n.width / 2, n.y + n.height / 2);
    Path disk(SceneNode n, double padding) => Path()
      ..addOval(
        Rect.fromCircle(center: center(n), radius: n.width / 2 + padding),
      );
    Path region = Path();
    for (final n in scene.nodes.where((n) => n.groupTag == 'U')) {
      region = Path.combine(PathOperation.union, region, disk(n, 9));
    }
    for (final e in scene.edges.where(
      (e) => e.visualState == NodeVisualState.sorted,
    )) {
      final a = center(nodes[e.fromNodeId]!), b = center(nodes[e.toNodeId]!);
      final delta = b - a;
      if (delta.distance == 0) continue;
      final side = Offset(-delta.dy, delta.dx) * (12 / delta.distance);
      final bridge = Path()
        ..addPolygon([a + side, b + side, b - side, a - side], true);
      region = Path.combine(PathOperation.union, region, bridge);
    }
    for (final n in scene.nodes.where((n) => n.groupTag != 'U')) {
      region = Path.combine(PathOperation.difference, region, disk(n, 3));
    }
    const emerald = Color(0xff159369);
    canvas.drawPath(region, Paint()..color = emerald.withValues(alpha: .13));
    drawDashedPath(
      canvas,
      region,
      Paint()
        ..color = emerald
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 + 3 * pulse
      ..color = Colors.orange.withValues(alpha: .24 + .42 * pulse);
    for (final e in scene.edges.where(
      (e) => e.visualState == NodeVisualState.comparing,
    )) {
      final geometry = edgeGeometry(scene, e, nodes);
      if (geometry == null) continue;
      final (a, c, b) = geometry;
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_CutPainter old) =>
      old.scene != scene || old.pulse != pulse;
}
