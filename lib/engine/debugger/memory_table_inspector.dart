import 'package:flutter/material.dart';
import '../../models/trace_model.dart';

class MemoryTableInspector extends StatefulWidget {
  const MemoryTableInspector({super.key, required this.scene});
  final SceneSnapshot scene;
  @override
  State<MemoryTableInspector> createState() => _MemoryTableInspectorState();
}

class _MemoryTableInspectorState extends State<MemoryTableInspector> {
  bool auxiliary = false;
  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final colors = Theme.of(context).colorScheme;
    Widget table(
      String id,
      String title,
      List<String> columns,
      List<List<String>> rows,
      Set<int> highlighted,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (columns.isEmpty || rows.isEmpty)
          const Padding(padding: EdgeInsets.all(12), child: Text('暂无记录'))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              key: ValueKey('memory-table-$id'),
              columnSpacing: 24,
              horizontalMargin: 12,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 80,
              columns: [for (final c in columns) DataColumn(label: Text(c))],
              rows: [
                for (var i = 0; i < rows.length; i++)
                  DataRow(
                    key: ValueKey('$id-row-$i'),
                    color: highlighted.contains(i)
                        ? WidgetStatePropertyAll(colors.secondaryContainer)
                        : null,
                    cells: [
                      for (final value in rows[i])
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Text(value, softWrap: true),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
    final active = {
      NodeVisualState.active,
      NodeVisualState.comparing,
      NodeVisualState.moving,
      NodeVisualState.error,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          key: const ValueKey('memory-view'),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: false, label: Text('内存与指针')),
            ButtonSegment(value: true, label: Text('辅助表')),
          ],
          selected: {auxiliary},
          onSelectionChanged: (v) => setState(() => auxiliary = v.single),
        ),
        Expanded(
          child: ListView(
            children: auxiliary
                ? [
                    if (scene.auxTables.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('暂无辅助表'),
                      ),
                    for (final t in scene.auxTables)
                      table(
                        t.id,
                        t.title,
                        t.columns,
                        t.rows,
                        t.highlightedRows,
                      ),
                  ]
                : [
                    table(
                      'nodes',
                      '结点内存',
                      const ['地址 / ID', '值', '下标 / 位序', '状态'],
                      [
                        for (final n in scene.nodes)
                          [
                            n.memoryAddress ?? n.id,
                            n.label,
                            [
                              n.indexBadge,
                              n.logicBadge,
                            ].whereType<String>().join(' / '),
                            n.isDeleted
                                ? '已释放'
                                : n.isOrphanLeak
                                ? '不可达 / 泄漏'
                                : n.isZeroSentinelSlot
                                ? '哨兵 / 暂存'
                                : _stateName(n.visualState),
                          ],
                      ],
                      {
                        for (var i = 0; i < scene.nodes.length; i++)
                          if (active.contains(scene.nodes[i].visualState) ||
                              scene.nodes[i].isOrphanLeak)
                            i,
                      },
                    ),
                    table(
                      'pointers',
                      '外部指针',
                      const ['名称', '目标'],
                      [
                        for (final p in scene.pointers)
                          [
                            p.label,
                            p.targetNodeId == nullNodeId
                                ? 'NULL'
                                : p.targetNodeId,
                          ],
                      ],
                      const {},
                    ),
                    table(
                      'edges',
                      '结点链接',
                      const ['端口 / 边', '来源', '目标'],
                      [
                        for (final e in scene.edges)
                          [
                            e.id,
                            e.fromNodeId,
                            e.toNodeId == nullNodeId ? 'NULL' : e.toNodeId,
                          ],
                      ],
                      const {},
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  String _stateName(NodeVisualState state) => switch (state) {
    NodeVisualState.normal => '正常',
    NodeVisualState.active => '当前',
    NodeVisualState.comparing => '比较中',
    NodeVisualState.moving => '移动中',
    NodeVisualState.sorted => '已完成',
    NodeVisualState.sentinel => '哨兵',
    NodeVisualState.error => '错误',
  };
}
