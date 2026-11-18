part of 'btree.dart';

extension on _Run {
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    _Page? focus,
    int? key,
    bool split = false,
    _Page? link,
    String? from,
    String? to,
    int reads = 0,
    int compares = 0,
    int writes = 0,
    bool milestone = false,
  }) {
    if (!recording) return;
    final pages = <_Page>[?root],
        boxes = <SceneNode>[],
        branches = <SceneEdge>[];
    final rows = <List<String>>[];
    for (var i = 0; i < pages.length; i++) {
      final n = pages[i], count = n.keys.length;
      pages.addAll(n.children);
      final role = input.plus ? (n.leaf ? '记录' : '索引') : (n.leaf ? '末层' : '分支');
      final ptrs = n.children.map((c) => c.id).join(' ');
      rows.add([
        n.id,
        n.parent?.id ?? 'NULL',
        role,
        n.keys.join(' '),
        ptrs,
        n.next?.id ?? 'NULL',
        input.plus && n.leaf ? n.keys.map((k) => 'R($k)').join(' ') : '',
      ]);
      boxes.add(
        TreeReingoldLayout.bTreeNode(
          id: n.id,
          keys: n.keys.map((v) => '$v').toList(),
        ).copyWith(
          width: 40 + (input.plus ? 0 : 30) + count * 80.0,
          height: 52,
          groupTag: 'page',
          logicBadge: '${n.id} · $role',
          label: 'n=$count',
          visualState: n == focus
              ? NodeVisualState.active
              : NodeVisualState.normal,
        ),
      );
      for (final c in n.children) {
        branches.add(
          SceneEdge(id: '${n.id}/${c.id}', fromNodeId: n.id, toNodeId: c.id),
        );
      }
    }
    final arranged = TreeReingoldLayout.arrange(
      SceneSnapshot(nodes: boxes, edges: branches),
    );
    final nodes = [...arranged.nodes],
        edges = <SceneEdge>[],
        zones = <SceneZoneOverlay>[];
    for (var i = 0; i < pages.length; i++) {
      final n = pages[i], box = arranged.nodes[i];
      double x = box.x + 38;
      void pointer(int j, {bool record = false}) {
        final id = '${n.id}:ptr$j',
            c = j < n.children.length ? n.children[j] : null;
        final label = record ? 'R(${n.keys[j]})' : 'P$j';
        nodes.add(
          SceneNode(
            id: id,
            label: label,
            x: x,
            y: box.y + 10,
            width: record ? 43 : 28,
            height: 32,
            groupTag: 'slot',
          ),
        );
        if (c != null) {
          edges.add(
            SceneEdge(id: '$id>${c.id}', fromNodeId: id, toNodeId: c.id),
          );
        }
        x += record ? 45 : 30;
      }

      if (!input.plus) pointer(0);
      for (var j = 0; j < n.keys.length; j++) {
        final k = n.keys[j], real = input.plus && n.leaf;
        final active = n == focus && k == key, w = real ? 33.0 : 48.0;
        nodes.add(
          SceneNode(
            id: input.plus && !n.leaf ? '${n.id}:index$k' : 'key$k',
            label: '$k',
            x: x,
            y: box.y + 9,
            width: w,
            height: 34,
            groupTag: 'key',
            visualState: active
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
        );
        if (split && active) {
          zones.add(
            SceneZoneOverlay(
              id: 'split',
              label: 's = ${j + 1} · 上推 $k',
              x: x + w / 2 - 1,
              y: box.y - 13,
              width: 2,
              height: box.height + 26,
              pattern: ZonePattern.dashed,
              visualState: NodeVisualState.error,
            ),
          );
        }
        x += w + 2;
        pointer(input.plus ? j : j + 1, record: real);
      }
      if (n.next != null) {
        edges.add(
          SceneEdge(
            id: 'leaf:${n.id}',
            fromNodeId: n.id,
            toNodeId: n.next!.id,
            fromPort: EdgePort.next,
            visualState: n == focus && link != null
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
        );
      }
    }
    b.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {
        '阶段': phase,
        '操作': operation,
        '结果': result,
        '根': root?.id ?? 'NULL',
        '页': focus?.id ?? '',
        '键': key?.toString() ?? '',
        if (input.plus) '记录': hits.join(' '),
        '分裂页': ?from,
        '新右页': ?to,
      },
      scene: arranged.copyWith(
        nodes: nodes,
        edges: edges,
        zones: zones,
        auxTables: [
          AuxTableSnapshot(
            id: 'pages',
            title: '多路树页表',
            columns: ['页', '双亲', '角色', '关键字', '孩子', '后继叶页', '记录指针'],
            rows: rows,
            highlightedRows: {
              if (focus != null && pages.contains(focus)) pages.indexOf(focus),
            },
          ),
        ],
      ),
      deltaCompare: compares,
      deltaRead: reads,
      deltaWrite: writes,
      milestone: milestone,
    );
  }
}
