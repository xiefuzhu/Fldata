part of 'merge_radix.dart';

class _Radix {
  _Radix(this.b, this.records)
    : next = List.filled(records.length + 1, 0),
      digits = records.fold(
        1,
        (w, r) => r.key.toString().length > w ? r.key.toString().length : w,
      );
  final TraceBuilder b;
  final List<SortRecord> records;
  final int digits;
  final List<int> next;
  final f = List.filled(10, 0), e = List.filled(10, 0);
  int pass = 0, remaining = 0;
  int get n => records.length;
  String label(int p) {
    final r = records[p - 1];
    return r.key.toString().padLeft(digits, '0') +
        r.label.substring(r.key.toString().length);
  }

  Iterable<int> chain(int p, {int? end}) sync* {
    while (p != 0) {
      yield p;
      if (p == end) break;
      p = next[p];
    }
  }

  void run() {
    for (var p = 0; p < n; p++) {
      next[p] = p + 1;
    }
    remaining = next[0];
    emit(
      1,
      '初始',
      '建立静态链表',
      'r[0].next 指向首记录，游标 0 表示链尾。记录始终保存在原始槽。',
      writes: n + 1,
    );
    for (pass = 1; pass <= digits && n > 0; pass++) {
      f.fillRange(0, 10, 0);
      e.fillRange(0, 10, 0);
      remaining = next[0];
      emit(2, '清桶', '第 $pass 趟 · 清空十个桶', '从最低位算起，按第 $pass 位分配。', writes: 20);
      while (remaining != 0) {
        final p = remaining;
        final key = records[p - 1].key.toString().padLeft(digits, '0');
        final d = key.codeUnitAt(digits - pass) - 48;
        emit(
          3,
          '取位',
          '读取 ${label(p)} 的第 $pass 位',
          '数字 $d 决定要进入的桶。',
          p: p,
          bucket: d,
        );
        remaining = next[p];
        if (f[d] == 0) {
          f[d] = p;
        } else {
          next[e[d]] = p;
        }
        e[d] = p;
        emit(
          4,
          '分配',
          '${label(p)} 进入 $d 号桶',
          '队头 f[$d] = ${f[d]}，队尾 e[$d] = $p。桶中记录到队尾为止。',
          p: p,
          bucket: d,
          writes: 2,
        );
      }
      var tail = 0;
      for (var d = 0; d < 10; d++) {
        if (f[d] == 0) continue;
        next[tail] = f[d];
        emit(
          tail == 0 ? 5 : 6,
          '收集',
          '接入 $d 号桶',
          '将 r[$tail].next 改为 ${f[d]}，新的总链尾为 ${e[d]}。',
          p: tail,
          bucket: d,
          writes: 1,
        );
        tail = e[d];
      }
      next[tail] = 0;
      emit(
        7,
        '整趟',
        '第 $pass 趟收集完成',
        'r[$tail].next = 0。沿头结点的 next 可读取本趟完整序列。',
        p: tail,
        writes: 1,
      );
    }
    if (pass > 0) pass--;
    emit(8, '完成', '基数排序完成', chain(next[0]).map(label).join('　'));
  }

  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    int? p,
    int? bucket,
    int writes = 0,
  }) {
    final groups = [
      for (var d = 0; d < 10; d++) chain(f[d], end: e[d]).toList(),
    ];
    final order = phase == '初始' || phase == '整趟' || phase == '完成'
        ? chain(next[0]).toList()
        : [...groups.expand((g) => g), ...chain(remaining)];
    final nodes = <SceneNode>[
      for (var s = 0; s <= n; s++)
        SceneNode(
          id: 'rad$s',
          label: s == 0 ? '头' : label(s),
          x: 32 + 88.0 * s,
          y: 110,
          width: 72,
          height: 48,
          shape: NodeShape.linkedCell,
          indexBadge: 'r[$s]',
          logicBadge: 'next=${next[s]}',
          memoryAddress: 'r[$s]',
          isZeroSentinelSlot: s == 0,
          visualState: s == p ? NodeVisualState.active : NodeVisualState.normal,
        ),
    ];
    final edges = <SceneEdge>[
      for (var s = 0; s <= n; s++)
        if (next[s] != 0)
          SceneEdge(
            id: 'next$s',
            fromNodeId: 'rad$s',
            toNodeId: 'rad${next[s]}',
            curvature: s.isEven ? -40 : -58,
            visualState: s == p
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
    ];
    for (var d = 0; d < 10; d++) {
      final x = 32 + 100.0 * d;
      nodes.add(
        SceneNode(
          id: 'bucket$d',
          label: '桶 $d',
          x: x,
          y: 234,
          width: 84,
          height: 48,
          shape: NodeShape.bucket,
          logicBadge: 'f=${f[d]}  e=${e[d]}',
          visualState: bucket == d
              ? NodeVisualState.active
              : NodeVisualState.normal,
        ),
      );
      for (var j = 0; j < groups[d].length; j++) {
        final slot = groups[d][j];
        nodes.add(
          SceneNode(
            id: 'member$slot',
            label: label(slot),
            x: x + 6,
            y: 334 + 77.0 * j,
            width: 72,
            height: 44,
            indexBadge: 'r[$slot]',
            visualState: slot == p
                ? NodeVisualState.moving
                : NodeVisualState.normal,
          ),
        );
        edges.add(
          SceneEdge(
            id: 'queue$slot',
            fromNodeId: j == 0 ? 'bucket$d' : 'member${groups[d][j - 1]}',
            toNodeId: 'member$slot',
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
        '位次': '$pass',
        'p': ?p?.toString(),
        '桶': ?bucket?.toString(),
        '链序': order.join(','),
      },
      deltaWrite: writes,
      deltaSpace: phase == '初始' ? n + 20 : 0,
      milestone: ['清桶', '整趟', '完成'].contains(phase),
      scene: SceneSnapshot(
        nodes: nodes,
        edges: edges,
        zones: [
          const SceneZoneOverlay(
            id: 'zero',
            label: 'r[0]',
            x: 29,
            y: 107,
            width: 78,
            height: 54,
            pattern: ZonePattern.dashed,
            visualState: NodeVisualState.sentinel,
          ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'chain',
            title: '静态记录与后继',
            columns: ['槽', '关键字', 'next'],
            rows: [
              for (var s = 0; s <= n; s++)
                ['$s', s == 0 ? '头' : label(s), '${next[s]}'],
            ],
          ),
          AuxTableSnapshot(
            id: 'queues',
            title: '十个队列的首尾游标',
            columns: ['桶', 'f', 'e', '队列（从头到尾）'],
            rows: [
              for (var d = 0; d < 10; d++)
                ['$d', '${f[d]}', '${e[d]}', groups[d].map(label).join(' ')],
            ],
          ),
        ],
      ),
    );
  }
}
