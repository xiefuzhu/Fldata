part of 'external_sort.dart';

SceneSnapshot _loserTemplate(int k) {
  final nodes = [
    for (var i = 0; i < 2 * k; i++)
      SceneNode(
        id: 'pos$i',
        label: '',
        x: 0,
        y: 0,
        width: i == 0 ? 98 : 70,
        height: i == 0 ? 46 : 54,
        shape: i > 0 && i < k ? NodeShape.circle : NodeShape.roundedRect,
      ),
  ];
  return TreeReingoldLayout.arrange(
    SceneSnapshot(
      nodes: nodes,
      edges: [
        for (var i = 1; i < 2 * k; i++)
          SceneEdge(
            id: 'edge$i',
            fromNodeId: 'pos${i ~/ 2}',
            toNodeId: 'pos$i',
            fromPort: i == 1
                ? EdgePort.auto
                : i.isEven
                ? EdgePort.lchild
                : EdgePort.rchild,
          ),
      ],
    ),
    levelGap: 40,
  );
}

extension on _ExternalRuns {
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    int? leaf,
    int? child,
    int? t,
    int? candidate,
    int? winner,
    int compare = 0,
    int reads = 0,
    int writes = 0,
  }) {
    final recorder = builder;
    if (recorder == null) return;
    final y =
        template.nodes.fold<double>(0, (acc, n) => max(acc, n.y + n.height)) +
        84;
    String value(int s) =>
        keys[s]?.toString() ??
        (replacement
            ? '空'
            : positions[s] < input.runs[s].length
            ? '待读'
            : 'MAXKEY');
    String job(int s) => keys[s] == null
        ? '空槽'
        : bands[s] > activeRun
        ? '冻结 · RUN ${bands[s]}'
        : 'RUN ${bands[s]}';
    final nodes = <SceneNode>[];
    for (var i = 0; i < 2 * k; i++) {
      final internal = i < k, slot = internal ? ls[i] : i - k;
      nodes.add(
        template.nodes[i].copyWith(
          label: internal ? (i == 0 ? '冠军 $slot' : '$slot') : value(slot),
          indexBadge: internal ? 'ls[$i]' : '$buffer[$slot]',
          logicBadge: internal
              ? (slot == k ? 'MINKEY' : value(slot))
              : replacement
              ? job(slot)
              : '第 $slot 路',
          visualState: i == t
              ? NodeVisualState.comparing
              : i == 0 && winner != null
              ? NodeVisualState.active
              : !internal && slot == leaf
              ? NodeVisualState.moving
              : NodeVisualState.normal,
        ),
      );
    }
    for (var s = 0; s < k + (replacement ? 0 : 1); s++) {
      nodes.add(
        SceneNode(
          id: 'buf$s',
          label: s == k ? 'MINKEY' : value(s),
          x: 32 + s * 94.0,
          y: y,
          width: 80,
          height: 46,
          shape: NodeShape.arraySlot,
          indexBadge: '$buffer[$s]',
          logicBadge: s == k
              ? '建树哨兵'
              : replacement
              ? job(s)
              : '已读 ${positions[s]}',
          visualState: s == k
              ? NodeVisualState.sentinel
              : s == leaf
              ? NodeVisualState.active
              : NodeVisualState.normal,
        ),
      );
    }
    final spans = [
      for (var i = 0; i < output.length; i++)
        ['RUN ${i + 1}', '${output[i].length}', output[i].join(' ')],
    ];
    recorder.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {
        '阶段': phase,
        'ls[0]': '${ls[0]}',
        's': ?leaf?.toString(),
        't': ?t?.toString(),
        '子位': ?child?.toString(),
        '胜者': ?winner?.toString(),
        '挑战者': ?candidate?.toString(),
        if (replacement) ...{
          '段号': '$activeRun',
          'MINIMAX': ?minimax?.toString(),
          '已读': '$cursor',
          '段长': output.map((r) => r.length).join(' '),
        },
        '输出': output.isEmpty ? '' : output.last.join(' '),
      },
      deltaCompare: compare,
      deltaRead: reads,
      deltaWrite: writes,
      deltaSpace: phase == '初始化' ? 2 * k + (replacement ? 0 : 1) : 0,
      milestone: ['建树完成', '封段', '换段', '完成'].contains(phase),
      scene: SceneSnapshot(
        nodes: nodes,
        edges: [
          for (var i = 1; i < 2 * k; i++)
            template.edges[i - 1].copyWith(
              visualState: i == child
                  ? NodeVisualState.comparing
                  : NodeVisualState.normal,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'losers',
            title: '败者树与冠军',
            columns: ['位置', '选手', '键'],
            rows: [
              for (var i = 0; i < k; i++)
                ['ls[$i]', '${ls[i]}', ls[i] == k ? 'MINKEY' : value(ls[i])],
            ],
          ),
          if (replacement)
            AuxTableSnapshot(
              id: 'work',
              title: '内存工作区',
              columns: ['WA', '键', '段号与状态'],
              rows: [
                for (var s = 0; s < k; s++) ['$s', value(s), job(s)],
              ],
            )
          else
            AuxTableSnapshot(
              id: 'sources',
              title: '输入归并段',
              columns: ['路', '缓存', '尚未读入'],
              rows: [
                for (var s = 0; s < k; s++)
                  ['$s', value(s), input.runs[s].skip(positions[s]).join(' ')],
              ],
            ),
          if (replacement)
            AuxTableSnapshot(
              id: 'input',
              title: '外存输入 FI',
              columns: ['下一位置', '剩余记录'],
              rows: [
                ['$cursor', input.keys.skip(cursor).join(' ')],
              ],
            ),
          AuxTableSnapshot(
            id: 'output',
            title: '外存输出 FO',
            columns: ['段', '长度', '记录'],
            rows: spans,
          ),
        ],
      ),
    );
  }
}
