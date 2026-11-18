part of 'selection_sort.dart';

SceneSnapshot treeTemplate(int count) => TreeReingoldLayout.arrange(
  SceneSnapshot(
    nodes: [
      for (var i = 1; i <= count; i++)
        SceneNode(
          id: 'tree$i',
          label: '',
          x: 0,
          y: 0,
          width: 56,
          height: 52,
          shape: NodeShape.circle,
        ),
    ],
    edges: [
      for (var i = 2; i <= count; i++)
        SceneEdge(
          id: 'branch$i',
          fromNodeId: 'tree${i ~/ 2}',
          toNodeId: 'tree$i',
          fromPort: i.isEven ? EdgePort.lchild : EdgePort.rchild,
        ),
    ],
  ),
  levelGap: 42,
  slantSingleChild: true,
);

extension on _Selection {
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    int compares = 0,
    int moves = 0,
    int? from,
    int? to,
    int? focus,
    bool swap = false,
    bool milestone = false,
    String crossing = '',
  }) {
    final heap = input.method == SelectionMethod.heap,
        tournament = input.method == SelectionMethod.tournament;
    final visibleCount = heap ? size : geometry.nodes.length;
    final arrayY = geometry.nodes.isEmpty ? 105.0 : geometry.nodes.last.y + 142;
    bool settled(int i) =>
        i > 0 && (phase == '完成' || (heap ? i > size : i <= sorted));
    NodeVisualState slotState(int i) {
      if (i == to) return NodeVisualState.moving;
      if (i == chosen || i == minIndex) return NodeVisualState.comparing;
      if (i == parent || i == pass) return NodeVisualState.active;
      return settled(i) ? NodeVisualState.sorted : NodeVisualState.normal;
    }

    String arrayLabel(int i) => i == hole ? '空位' : r[i]?.label ?? '∅';
    final array = LinearMemoryLayout.arrange(
      [
        for (var i = 0; i <= n; i++)
          SceneNode(
            id: 'slot$i',
            label: arrayLabel(i),
            x: 0,
            y: 0,
            memoryAddress: 'r[$i]',
            visualState: slotState(i),
          ),
      ],
      hasSentinelZero: true,
      origin: Vec2(x: 32, y: arrayY),
    );
    final slots = [
      for (var i = 0; i <= n; i++)
        array.nodes[i].copyWith(
          logicBadge: i == 0
              ? '保留槽'
              : i == hole
              ? '空位'
              : i == minIndex
              ? 'k'
              : i == chosen
              ? 'j'
              : i == parent
              ? 's'
              : i == pass
              ? 'i'
              : settled(i)
              ? '已排序'
              : '',
        ),
    ];
    String treeLabel(int i) {
      if (heap) return arrayLabel(i);
      if (winners[i] != null) return winners[i]!.label;
      if (i >= leaves || played.contains(i)) return '∞';
      return '·';
    }

    bool lit(int child) => heap ? parent == child ~/ 2 : focus == child ~/ 2;
    final tree = [
      for (var i = 1; i <= visibleCount; i++)
        geometry.nodes[i - 1].copyWith(
          label: treeLabel(i),
          indexBadge: '[$i]',
          logicBadge: heap
              ? (i == parent
                    ? 's'
                    : i == chosen
                    ? 'j'
                    : '')
              : i >= leaves
              ? (retired.contains(i)
                    ? '已输出'
                    : i - leaves < n
                    ? '叶 ${i - leaves + 1}'
                    : '轮空')
              : '',
          visualState: heap
              ? slotState(i)
              : focus == i
              ? NodeVisualState.active
              : lit(i)
              ? NodeVisualState.comparing
              : NodeVisualState.normal,
        ),
    ];
    final vars = {
      '阶段': phase,
      if (section.isNotEmpty) '过程': section,
      if (heap) '堆规模': '$size',
      's': ?parent?.toString(),
      'j': ?chosen?.toString(),
      'k': ?minIndex?.toString(),
      'i': ?pass?.toString(),
      'rc': ?saved?.label,
      '来源': ?from?.toString(),
      '目标': ?to?.toString(),
      if (swap) '双向': '1',
      if (heap && swap) '跨视图': '1',
      if (focus != null) '比赛结点': '$focus',
      if (crossing.isNotEmpty) '跨位': crossing,
      if (phase == '完成') ...crossings.result(input.keys),
    };
    final zero = slots.first;
    builder.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: vars,
      deltaCompare: compares,
      deltaMove: moves,
      deltaWrite: moves,
      deltaSpace: frame == 0 ? (tournament ? visibleCount : 1) : 0,
      milestone: milestone || crossing.isNotEmpty,
      scene: SceneSnapshot(
        nodes: [...slots, ...tree],
        edges: [
          for (var i = 2; i <= visibleCount; i++)
            geometry.edges[i - 2].copyWith(
              visualState: lit(i)
                  ? NodeVisualState.comparing
                  : NodeVisualState.normal,
            ),
        ],
        zones: [
          SceneZoneOverlay(
            id: 'zero',
            label: 'r[0]',
            x: zero.x - 4,
            y: zero.y - 4,
            width: zero.width + 8,
            height: zero.height + 8,
            pattern: ZonePattern.dashed,
            visualState: NodeVisualState.sentinel,
          ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'records',
            title: tournament ? '输出序列' : '顺序存储',
            columns: ['位序', '存储值', '原始位序'],
            rows: [
              for (var i = 0; i <= n; i++)
                ['$i', r[i]?.label ?? '∅', r[i]?.origin.toString() ?? '—'],
            ],
          ),
        ],
      ),
    );
    frame++;
  }
}
