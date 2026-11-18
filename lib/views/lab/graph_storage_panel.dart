import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch6_graph/graph_input.dart';

enum StorageTab {
  matrix('AMGraph'),
  adjacency('ALGraph'),
  cross('OLGraph'),
  multi('AMLGraph');

  const StorageTab(this.label);
  final String label;
}

class GraphStoragePanel extends StatefulWidget {
  const GraphStoragePanel({
    super.key,
    required this.input,
    required this.storage,
    required this.onMark,
  });
  final GraphInputModel input;
  final GraphStorage storage;
  final ValueChanged<String?> onMark;
  @override
  State<GraphStoragePanel> createState() => _GraphStoragePanelState();
}

class _GraphStoragePanelState extends State<GraphStoragePanel> {
  StorageTab tab = StorageTab.matrix;
  bool reverse = false;
  GraphStorage get s => widget.storage;
  GraphInputModel get graph => widget.input;
  Widget field(String text, {bool heading = false}) => Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      color: heading
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
    ),
    child: Text(text, softWrap: false),
  );

  Widget matrix() {
    Widget cell(String a, String b) {
      final e = s.cells[(a, b)];
      return MouseRegion(
        onEnter: (_) => widget.onMark(e?.id),
        onExit: (_) => widget.onMark(null),
        child: InkWell(
          key: ValueKey('matrix-$a-$b'),
          onTap: () => widget.onMark(e?.id),
          child: field(
            e == null ? (graph.kind.weighted ? '∞' : '0') : '${e.weight}',
          ),
        ),
      );
    }

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: [
            field('i / j', heading: true),
            for (final v in s.vertices) field(v.id, heading: true),
          ],
        ),
        for (final a in s.vertices)
          TableRow(
            children: [
              field(a.id, heading: true),
              for (final b in s.vertices) cell(a.id, b.id),
            ],
          ),
      ],
    );
  }

  Widget adjacency() {
    final index = {for (final (i, v) in s.vertices.indexed) v.id: i};
    final rev = s.directed && reverse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.directed)
          FilterChip(
            label: const Text('逆邻接表'),
            selected: reverse,
            onSelected: (v) => setState(() => reverse = v),
          ),
        const Text('头插法 · 同一条链按输入边的逆序排列'),
        for (final v in s.vertices)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                field('${index[v.id]}  ${v.id}  firstarc', heading: true),
                for (final entry in s.chain(v.id, reverse: rev)) ...[
                  const Text(' → '),
                  field(
                    '${index[entry.vertex]}  ${entry.vertex}${graph.kind.weighted ? ' | ${entry.arc.weight}' : ''}',
                  ),
                ],
                Text(' → ∅${rev ? '   入度 ${s.incoming[v.id]!.length}' : ''}'),
              ],
            ),
          ),
      ],
    );
  }

  Widget linked() {
    final cross = tab == StorageTab.cross;
    if (cross != s.directed) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(cross ? '十字链表适用于有向图和有向网。' : '邻接多重表适用于无向图和无向网。'),
      );
    }
    final index = {for (final (i, v) in s.vertices.indexed) v.id: i};
    final headers = cross
        ? ['弧', 'tailvex', 'headvex', 'hlink', 'tlink']
        : ['边', 'mark', 'ivex', 'ilink', 'jvex', 'jlink'];
    final c = Theme.of(context).colorScheme;
    final cellWidth =
        68.0 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 3);
    final rowHeight = 44.0 * MediaQuery.textScalerOf(context).scale(1);
    final margin = 30.0 + 4 * s.arcs.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cross
              ? 'tlink 同弧尾（紫） · hlink 同弧头（青）'
              : '${s.arcs.length} 个共享边结点 · 邻接表需 ${2 * s.arcs.length} 个边结点',
        ),
        Wrap(
          children: [
            for (final v in s.vertices)
              field(
                cross
                    ? '${v.id}  firstin ${s.firstIn[v.id] ?? '∅'}  firstout ${s.first[v.id] ?? '∅'}'
                    : '${v.id}  firstedge ${s.first[v.id] ?? '∅'}',
              ),
          ],
        ),
        SizedBox(
          width: headers.length * cellWidth + 2 * margin,
          height: (s.arcs.length + 1) * rowHeight,
          child: CustomPaint(
            painter: _LinkPainter(
              s,
              cross,
              margin,
              headers.length * cellWidth,
              rowHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: Column(
                children: [
                  for (final row in [
                    headers,
                    for (final e in s.arcs)
                      cross
                          ? [
                              e.id,
                              '${index[e.tail]}',
                              '${index[e.head]}',
                              s.links[e.id]!.right ?? '∅',
                              s.links[e.id]!.left ?? '∅',
                            ]
                          : [
                              e.id,
                              '0',
                              '${index[e.tail]}',
                              s.links[e.id]!.left ?? '∅',
                              '${index[e.head]}',
                              s.links[e.id]!.right ?? '∅',
                            ],
                  ])
                    SizedBox(
                      height: rowHeight,
                      child: Row(
                        children: [
                          for (final (i, value) in row.indexed)
                            SizedBox(
                              width: cellWidth,
                              height: rowHeight * .68,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  border: Border.all(color: c.outlineVariant),
                                ),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: i == (cross ? 4 : 3)
                                        ? Colors.deepPurpleAccent
                                        : i == (cross ? 3 : 5)
                                        ? Colors.teal
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in StorageTab.values)
              TextButton(
                key: ValueKey(t.label),
                onPressed: () {
                  widget.onMark(null);
                  setState(() => tab = t);
                },
                style: t == tab
                    ? TextButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                      )
                    : null,
                child: Text(t.label),
              ),
          ],
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: switch (tab) {
              StorageTab.matrix => matrix(),
              StorageTab.adjacency => adjacency(),
              _ => linked(),
            },
          ),
        ),
      ),
    ],
  );
}

/// Each colored route joins two physical edge rows. Pointer fields carry the target ID.
class _LinkPainter extends CustomPainter {
  _LinkPainter(this.storage, this.cross, this.margin, this.width, this.height);
  final GraphStorage storage;
  final bool cross;
  final double margin, width, height;
  @override
  void paint(Canvas canvas, Size size) {
    final indices = {for (final (i, e) in storage.arcs.indexed) e.id: i};
    void route(int i, String? target, bool left) {
      if (target == null) return;
      final j = indices[target]!;
      final x = left ? margin : margin + width;
      final direction = left ? -1 : 1;
      final lane = x + direction * (10 + 4.0 * i);
      final column = cross ? (left ? 4 : 3) : (left ? 3 : 5);
      final fieldX = margin + (column + .5) * width / (cross ? 5 : 6);
      final sourceY = height * (i + 1.84);
      final y = height * (i + (left ? 1.92 : 1.98));
      final dest = height * (j + 1.54);
      final pen = Paint()
        ..color = left ? Colors.deepPurpleAccent : Colors.teal
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(
        Path()
          ..moveTo(fieldX, sourceY)
          ..lineTo(fieldX, y)
          ..lineTo(lane, y)
          ..lineTo(lane, dest)
          ..lineTo(x, dest),
        pen,
      );
      canvas.drawLine(
        Offset(x, dest),
        Offset(x + direction * 5, dest - math.min(4, height / 8)),
        pen,
      );
      canvas.drawLine(
        Offset(x, dest),
        Offset(x + direction * 5, dest + math.min(4, height / 8)),
        pen,
      );
    }

    for (final (i, e) in storage.arcs.indexed) {
      final link = storage.links[e.id]!;
      route(i, link.left, true);
      route(i, link.right, false);
    }
  }

  @override
  bool shouldRepaint(_LinkPainter old) =>
      storage != old.storage ||
      cross != old.cross ||
      width != old.width ||
      height != old.height;
}
