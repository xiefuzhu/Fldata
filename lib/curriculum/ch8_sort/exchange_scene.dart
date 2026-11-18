part of 'exchange_sort.dart';

extension on _Run {
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    int compares = 0,
    int moves = 0,
    int? from,
    int? to,
    bool swap = false,
    List<int> active = const [],
    bool milestone = false,
    String crossing = '',
  }) {
    final bubble = input.method == ExchangeMethod.bubble;
    final layout = LinearMemoryLayout.arrange([
      for (var s = 0; s <= n; s++)
        SceneNode(
          id: 'slot$s',
          label: s == hole ? '空坑' : r[s]?.label ?? '∅',
          x: 0,
          y: 0,
          memoryAddress: 'r[$s]',
          visualState: s == to
              ? NodeVisualState.moving
              : active.contains(s)
              ? NodeVisualState.comparing
              : settled.contains(s)
              ? NodeVisualState.sorted
              : NodeVisualState.normal,
        ),
    ], hasSentinelZero: true);
    final slots = layout.nodes;
    SceneZoneOverlay box(
      String id,
      String label,
      int s,
      NodeVisualState state,
    ) => SceneZoneOverlay(
      id: id,
      label: label,
      x: slots[s].x - 4,
      y: slots[s].y - 4,
      width: slots[s].width + 8,
      height: slots[s].height + 8,
      pattern: ZonePattern.dashed,
      visualState: state,
    );
    final vars = {
      '阶段': phase,
      '趟': '$pass',
      '交换次数': '$swaps',
      if (bubble) 'flag': flag ? '1' : '0',
      'm': ?m?.toString(),
      'j': ?j?.toString(),
      'low': ?low?.toString(),
      'high': ?high?.toString(),
      '空坑': ?hole?.toString(),
      '来源': ?from?.toString(),
      '目标': ?to?.toString(),
      if (swap) '双向': '1',
      if (crossing.isNotEmpty) '跨位': crossing,
      if (phase == '完成') ...crossings.result(input.keys),
    };
    final calls = [...stack];
    if (hole != null) {
      calls.last = calls.last.copyWith(
        locals: {
          'low': '$low',
          'high': '$high',
          'hole': '$hole',
          'pivotkey': '${r[0]!.key}',
        },
      );
    }
    b.step(
      title: title,
      explain: detail,
      vars: vars,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      callStack: calls,
      deltaCompare: compares,
      deltaMove: moves,
      deltaWrite: moves,
      deltaSpace: frames == 0 ? 1 : 0,
      milestone: milestone || crossing.isNotEmpty,
      scene: layout.copyWith(
        nodes: [
          for (var s = 0; s <= n; s++)
            slots[s].copyWith(
              logicBadge: s == 0
                  ? (bubble ? '保留槽' : '枢轴暂存')
                  : [
                      if (s == low) 'low',
                      if (s == high) 'high',
                      if (s == j) 'j',
                      if (s == m) 'm',
                      if (settled.contains(s)) '已到位',
                    ].join('/'),
            ),
        ],
        zones: [
          box('zero', 'r[0]', 0, NodeVisualState.sentinel),
          if (hole != null)
            box('hole', '空坑 r[$hole]', hole!, NodeVisualState.comparing),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'records',
            title: '顺序表与原始位序',
            columns: ['槽', '存储值', '原始位序', '用途'],
            rows: [
              for (var s = 0; s <= n; s++)
                [
                  '$s',
                  r[s]?.label ?? '∅',
                  r[s]?.origin.toString() ?? '—',
                  s == hole
                      ? '逻辑空坑'
                      : s == 0
                      ? '保留槽'
                      : settled.contains(s)
                      ? '已到位'
                      : '记录',
                ],
            ],
          ),
        ],
      ),
    );
    frames++;
  }
}
