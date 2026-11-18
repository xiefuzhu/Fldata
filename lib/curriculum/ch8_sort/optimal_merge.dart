part of 'external_sort.dart';

class _Segment {
  const _Segment(
    this.index,
    this.weight, {
    this.dummy = false,
    this.children = const [],
  });
  final int index;
  final BigInt weight;
  final bool dummy;
  final List<_Segment> children;
  String get id => 'seg$index';
}

class _Optimal {
  _Optimal(this.input, this.b);
  final ExternalInput input;
  final TraceBuilder b;
  final segments = <_Segment>[];
  final queue = HeapPriorityQueue<_Segment>((a, b) {
    final weight = a.weight.compareTo(b.weight);
    return weight == 0 ? a.index.compareTo(b.index) : weight;
  });
  var wpl = BigInt.zero;
  void add(
    BigInt weight, {
    bool dummy = false,
    List<_Segment> children = const [],
  }) {
    final s = _Segment(
      segments.length,
      weight,
      dummy: dummy,
      children: children,
    );
    segments.add(s);
    queue.add(s);
  }

  void run() {
    final m = input.keys.length, k = input.width, u = input.padding;
    for (final weight in input.keys) {
      add(BigInt.from(weight));
    }
    emit(1, '初始', '$m 个归并段，$k 路归并', '各叶的权值为该段占用的物理块数。');
    if (u > 0) {
      for (var i = 0; i < u; i++) {
        add(BigInt.zero, dummy: true);
      }
      emit(
        2,
        '补虚段',
        '补入 $u 个零权虚段',
        '叶数由 $m 变为 ${m + u}，满足 (叶数 − 1) 能被 ${k - 1} 整除。',
      );
    }
    while (queue.length > 1) {
      final children = [for (var i = 0; i < k; i++) queue.removeFirst()];
      final total = children.fold(BigInt.zero, (sum, v) => sum + v.weight);
      emit(
        3,
        '选段',
        '选择 $k 个最短段',
        '本趟归并 ${children.map((s) => s.weight).join(" + ")}。',
        chosen: children,
      );
      add(total, children: children);
      wpl += total;
      emit(
        4,
        '归并',
        '形成长度为 $total 的新段',
        '本趟读取 $total 块并写回 $total 块。累积的归并权值为 $wpl。',
        chosen: [segments.last],
      );
    }
    emit(5, '完成', '最佳归并树完成', 'WPL = $wpl，按物理块计算的读写总次数为 ${wpl * BigInt.two}。');
  }

  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    List<_Segment> chosen = const [],
  }) {
    final forest = TreeReingoldLayout.arrange(
      SceneSnapshot(
        nodes: [
          for (final s in segments)
            SceneNode(
              id: s.id,
              label: s.weight.toString(),
              x: 0,
              y: 0,
              width: 68,
              height: 68,
              shape: NodeShape.circle,
              logicBadge: s.dummy
                  ? '虚段'
                  : s.children.isEmpty
                  ? 'R${s.index + 1}'
                  : '归并段',
              groupTag: s.dummy ? 'virtual' : null,
              visualState: chosen.contains(s)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final s in segments)
            for (final child in s.children)
              SceneEdge(
                id: 'edge-${child.id}',
                fromNodeId: s.id,
                toNodeId: child.id,
              ),
        ],
      ),
      levelGap: 46,
    );
    b.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {
        '阶段': phase,
        'm': '${input.keys.length}',
        'k': '${input.width}',
        'u': '${input.padding}',
        'WPL': '$wpl',
        '读写次数': '${wpl * BigInt.two}',
      },
      milestone: true,
      scene: forest.copyWith(
        auxTables: [
          AuxTableSnapshot(
            id: 'merges',
            title: '归并记录（物理块）',
            columns: ['输入段长度', '新段长度', '本趟读写'],
            rows: [
              for (final s in segments)
                if (s.children.isNotEmpty)
                  [
                    s.children.map((c) => c.weight).join(' + '),
                    '${s.weight}',
                    '${s.weight * BigInt.two}',
                  ],
            ],
          ),
        ],
      ),
    );
  }
}
