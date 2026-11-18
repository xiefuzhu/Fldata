part of 'insertion_sort.dart';

extension on _Run {
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    List<int> active = const [],
    int? from,
    int? to,
    bool compare = false,
    bool milestone = false,
    List<List<String>>? comparison,
  }) {
    final builder = b;
    if (builder == null) return;
    final shell = input.method == InsertionMethod.shell;
    final layout = LinearMemoryLayout.arrange([
      for (var s = 0; s <= n; s++)
        SceneNode(
          id: 'slot$s',
          label: r[s]?.label ?? '∅',
          x: 0,
          y: 0,
          memoryAddress: 'r[$s]',
          groupTag: shell && s > 0 ? '${(s - 1) % dk}' : null,
          visualState: s == to
              ? NodeVisualState.moving
              : active.contains(s)
              ? NodeVisualState.comparing
              : NodeVisualState.normal,
        ),
    ], hasSentinelZero: true);
    final nodes = layout.nodes;
    final pointerLabels = <int, List<String>>{};
    void pointer(String label, int? slot) {
      if (slot == null || slot < 0 || slot > n) return;
      (pointerLabels[slot] ??= []).add(label);
    }

    if (i > 0 && i <= n) pointer('i', i);
    pointer('j', j);
    pointer('low', low);
    pointer('mid', mid);
    pointer('high', high);
    builder.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      deltaCompare: compare ? 1 : 0,
      deltaMove: to == null ? 0 : 1,
      deltaWrite: to == null ? 0 : 1,
      deltaSpace: frames == 0 ? 1 : 0,
      milestone: milestone || crossing.isNotEmpty,
      vars: {
        '阶段': phase,
        'i': '$i',
        'dk': '$dk',
        'j': ?j?.toString(),
        'low': ?low?.toString(),
        'mid': ?mid?.toString(),
        'high': ?high?.toString(),
        '来源': ?from?.toString(),
        '目标': ?to?.toString(),
        '后移': '$shifts',
        '有序区': '$prefix',
        if (crossing.isNotEmpty) '跨位': crossing,
        if (comparison != null) ...crossings.result(input.keys),
      },
      scene: layout.copyWith(
        nodes: [
          for (var s = 0; s <= n; s++)
            nodes[s].copyWith(
              logicBadge: s == 0
                  ? (shell || input.method == InsertionMethod.binary
                        ? '暂存'
                        : '监视哨')
                  : pointerLabels[s]?.join('/'),
            ),
        ],
        edges: [
          if (shell && phase != '初始' && phase != '完成' && dk < n)
            for (var s = 1; s <= n - dk; s++)
              SceneEdge(
                id: 'gap$dk-$s',
                fromNodeId: 'slot$s',
                toNodeId: 'slot${s + dk}',
                style: EdgeStyle.shellArc,
                curvature: -58 - 12.0 * ((s - 1) % dk % 6),
                visualState: i > 0 && (s - i) % dk == 0
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
        ],
        zones: [
          SceneZoneOverlay(
            id: 'zero',
            label: 'r[0]',
            x: nodes[0].x - 3,
            y: nodes[0].y - 3,
            width: nodes[0].width + 6,
            height: nodes[0].height + 6,
            pattern: ZonePattern.dashed,
            visualState: NodeVisualState.sentinel,
          ),
          if (prefix > 0)
            SceneZoneOverlay(
              id: 'ordered',
              label: '有序区 1..$prefix',
              x: nodes[1].x - 3,
              y: nodes[1].y - 4,
              width: nodes[prefix].x + nodes[prefix].width - nodes[1].x + 6,
              height: nodes[1].height + 8,
              visualState: NodeVisualState.sorted,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'records',
            title: '顺序表与原始位序',
            columns: ['槽', '关键字', '原始位序'],
            rows: [
              for (var s = 0; s <= n; s++)
                ['$s', r[s]?.label ?? '∅', r[s]?.origin.toString() ?? '—'],
            ],
          ),
          if (comparison != null)
            AuxTableSnapshot(
              id: 'insert-counts',
              title: '相同输入的操作次数',
              columns: ['算法', 'KCN', '后移', '暂存与回填', 'RMN'],
              rows: comparison,
            ),
        ],
      ),
    );
    frames++;
  }
}
