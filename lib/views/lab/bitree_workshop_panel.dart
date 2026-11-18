part of 'bitree_stage.dart';

class _WorkshopStatePanel extends StatelessWidget {
  const _WorkshopStatePanel({
    required this.mode,
    required this.frame,
    required this.sequence,
  });
  final TreeLesson mode;
  final TraceFrame frame;
  final String sequence;
  @override
  Widget build(BuildContext context) {
    final vars = frame.inlineVars, colors = Theme.of(context).colorScheme;
    final rows = frame.scene.auxTables.single.rows;
    if (mode == TreeLesson.levelOrder) {
      return Text(
        '队头 → ${rows.isEmpty ? "∅" : rows.map((r) => r.last).join("　")} ← 队尾',
        key: const ValueKey('tree-queue'),
      );
    }
    if (mode.isReconstruction && vars.containsKey('中序区间')) {
      final label = mode == TreeLesson.preIn ? '先序区间' : '后序区间';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label　${vars[label]!.isEmpty ? "∅" : vars[label]}'),
          Text(
            '中序区间 [${vars["中序起点"]}]　${vars["中序区间"]!.isEmpty ? "∅" : vars["中序区间"]}',
          ),
          if (vars.containsKey('分割根'))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                key: const ValueKey('tree-partition'),
                children: [
                  Text('左　${vars["左区间"]!.isEmpty ? "∅" : vars["左区间"]}　'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      border: Border.symmetric(
                        vertical: BorderSide(color: colors.primary, width: 2),
                      ),
                    ),
                    child: Text(
                      '根 ${vars["分割根"]}',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ),
                  Text('　右　${vars["右区间"]!.isEmpty ? "∅" : vars["右区间"]}'),
                ],
              ),
            ),
        ],
      );
    }
    if (mode == TreeLesson.create && vars.containsKey('游标')) {
      final symbols = sequence
          .replaceAll(RegExp(r'\s+'), '')
          .runes
          .map(String.fromCharCode)
          .toList();
      final i = int.parse(vars['游标']!) - 1;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: symbols.take(i).join()),
            TextSpan(
              text: symbols[i],
              style: TextStyle(
                backgroundColor: colors.primaryContainer,
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: symbols.skip(i + 1).join()),
          ],
        ),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [for (final r in rows) Text('${r[0]}　${r[1]}')],
    );
  }
}

class _StorageMapping extends StatelessWidget {
  const _StorageMapping(this.scene);
  final SceneSnapshot scene;

  @override
  Widget build(BuildContext context) {
    final nodes = {
      for (final n in scene.nodes) BigInt.parse(n.id.substring(1)): n,
    };
    final indices = nodes.keys.toList()..sort();
    final slots = <String>[];
    var next = BigInt.one;
    for (final i in indices) {
      if (next < i) {
        final last = i - BigInt.one;
        slots.add(next == last ? '[$next] #' : '[$next…$last] #');
      }
      slots.add('[$i] ${nodes[i]!.label}');
      next = i + BigInt.one;
    }
    final links = {
      for (final e in scene.edges) (e.fromNodeId, e.fromPort): e.toNodeId,
    };
    return ExpansionTile(
      title: const Text('顺序存储与二叉链表'),
      children: [
        if (nodes.isEmpty)
          const Text('空树')
        else
          ListTile(
            title: const Text('顺序存储（# 为空槽）'),
            subtitle: Text(slots.join('　')),
          ),
        for (final i in indices)
          ListTile(
            dense: true,
            title: Text('b$i · ${nodes[i]!.label}'),
            subtitle: Text(
              '左　${links[(nodes[i]!.id, EdgePort.lchild)] ?? "NULL"}　　右　${links[(nodes[i]!.id, EdgePort.rchild)] ?? "NULL"}',
            ),
          ),
      ],
    );
  }
}
