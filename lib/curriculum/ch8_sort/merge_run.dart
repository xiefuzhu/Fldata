part of 'merge_radix.dart';

class _Merge {
  _Merge(this.b, List<SortRecord> input, {bool recursive = true})
    : r = [null, ...input],
      tr = List.filled(input.length + 1, null) {
    final nodes = <SceneNode>[], edges = <SceneEdge>[];
    void branch(int lo, int hi, String? parent, bool left) {
      final id = 'm$lo:$hi';
      nodes.add(
        SceneNode(
          id: id,
          label: '[$lo, $hi]',
          x: 0,
          y: 0,
          width: 82,
          height: 42,
        ),
      );
      if (parent != null) {
        edges.add(
          SceneEdge(
            id: 'edge-$id',
            fromNodeId: parent,
            toNodeId: id,
            fromPort: left ? EdgePort.lchild : EdgePort.rchild,
          ),
        );
      }
      if (lo < hi) {
        final mid = (lo + hi) ~/ 2;
        branch(lo, mid, id, true);
        branch(mid + 1, hi, id, false);
      }
    }

    if (recursive && input.isNotEmpty) branch(1, input.length, null, true);
    tree = TreeReingoldLayout.arrange(
      SceneSnapshot(nodes: nodes, edges: edges),
      levelGap: 36,
    );
    arrayY =
        tree.nodes.fold(
          30.0,
          (y, n) => n.y + n.height > y ? n.y + n.height : y,
        ) +
        84;
  }
  final TraceBuilder b;
  final List<SortRecord?> r, tr;
  late final SceneSnapshot tree;
  late final double arrayY;
  final visited = <String>{}, stack = <StackActivationRecord>[];
  int get n => r.length - 1;
  void passes() {
    emit(1, '初始', '二路归并 · 按段长逐趟合并', '从长度 1 的有序段开始，r 和 TR 交替作输出表。');
    var source = r, dest = tr, from = 'r', to = 'TR';
    for (var width = 1; width < n; width *= 2) {
      for (var lo = 1; lo <= n; lo += 2 * width) {
        final mid = (lo + width - 1).clamp(lo, n),
            hi = (lo + 2 * width - 1).clamp(mid, n);
        var i = lo, j = mid + 1;
        for (var k = lo; k <= hi; k++) {
          final both = i <= mid && j <= hi;
          final left = j > hi || (i <= mid && source[i]!.key <= source[j]!.key);
          final pos = left ? i++ : j++;
          dest[k] = source[pos];
          emit(
            3,
            '写入',
            '归并 [$lo,$hi] · 写入 $to[$k]',
            '按键取较小的段首，相等时保留左段优先。',
            source: from,
            dest: to,
            read: pos,
            write: k,
            moves: 1,
            compares: both ? 1 : 0,
          );
        }
      }
      emit(4, '整趟', '归并 h=$width', '$to 中相邻的两段已合并，下一趟段长翻倍。', dest: to);
      (source, dest) = (dest, source);
      (from, to) = (to, from);
    }
    if (!identical(source, r)) {
      for (var k = 1; k <= n; k++) {
        r[k] = source[k];
        emit(
          5,
          '回写',
          '回写 r[$k]',
          '将最后一趟结果复制到原表。',
          source: from,
          dest: 'r',
          read: k,
          write: k,
          moves: 1,
        );
      }
    }
    emit(5, '完成', '归并排序完成', r.skip(1).map((v) => v!.label).join('　'));
  }

  void run() {
    emit(1, '初始', '建立顺序表和辅助数组', 'MSort 的根调用将结果写回原表 r。子调用交替使用 r 和 TR 作为目标。');
    if (n > 0) sort(1, n, true);
    emit(10, '完成', '归并排序完成', r.skip(1).map((v) => v!.label).join('　'));
  }

  void sort(int lo, int hi, bool intoR) {
    final id = 'm$lo:$hi', dest = intoR ? r : tr, source = intoR ? tr : r;
    final to = intoR ? 'r' : 'TR', from = intoR ? 'TR' : 'r';
    final mid = (lo + hi) ~/ 2;
    stack.add(
      StackActivationRecord(
        id: id,
        functionName: 'MSort',
        arguments: {'low': '$lo', 'high': '$hi', 'T': to},
        locals: {if (lo < hi) 'mid': '$mid'},
        parentCallId: stack.lastOrNull?.id,
        returnLocation: stack.lastOrNull?.id ?? 'MergeSort',
      ),
    );
    visited.add(id);
    emit(
      2,
      '进入',
      'MSort [$lo, $hi] → $to',
      lo == hi ? '单记录直接写入目标数组。' : '以 $mid 为界，先递归左段，再递归右段。',
    );
    if (lo == hi) {
      dest[lo] = r[lo];
      emit(
        3,
        '叶复制',
        '写入 $to[$lo]',
        '复制原始记录 ${r[lo]!.label}。',
        moves: 1,
        source: 'r',
        dest: to,
        read: lo,
        write: lo,
      );
    } else {
      emit(4, '拆分', '拆分为 [$lo, $mid] 和 [${mid + 1}, $hi]', '两个子调用将结果写入 $from。');
      sort(lo, mid, !intoR);
      sort(mid + 1, hi, !intoR);
      var i = lo, j = mid + 1, k = lo;
      emit(
        5,
        '开始归并',
        '合并 [$lo, $mid] 和 [${mid + 1}, $hi]',
        '从 $from 读取两段有序记录，写入 $to。',
        source: from,
        dest: to,
        i: i,
        j: j,
        k: k,
      );
      while (i <= mid || j <= hi) {
        final both = i <= mid && j <= hi;
        final left = j > hi || (i <= mid && source[i]!.key <= source[j]!.key);
        if (both) {
          emit(
            6,
            '比较',
            '比较 ${source[i]!.label} 与 ${source[j]!.label}',
            left ? '取左段记录，相等时保留原始次序。' : '取右段较小记录。',
            compares: 1,
            source: from,
            dest: to,
            i: i,
            j: j,
            k: k,
          );
        }
        final pos = left ? i : j;
        dest[k] = source[pos];
        emit(
          both
              ? 7
              : left
              ? 8
              : 9,
          '写入',
          '$from[$pos] → $to[$k]',
          both ? '拾取较小记录。' : '一段已耗尽，顺次复制余段。',
          moves: 1,
          source: from,
          dest: to,
          i: i,
          j: j,
          k: k,
          read: pos,
          write: k,
        );
        if (left) {
          i++;
        } else {
          j++;
        }
        k++;
      }
    }
    emit(10, '返回', '区间 [$lo, $hi] 已有序', '结果保存在 $to[$lo..$hi]。');
    stack.removeLast();
  }

  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    int compares = 0,
    int moves = 0,
    String? source,
    String? dest,
    int? i,
    int? j,
    int? k,
    int? read,
    int? write,
  }) {
    final call = stack.lastOrNull, top = call?.id;
    final left = i != null && i <= int.parse(call!.locals['mid']!) ? i : null;
    final right = j != null && j <= int.parse(call!.arguments['high']!)
        ? j
        : null;
    final nodes = <SceneNode>[], zones = <SceneZoneOverlay>[];
    void row(String name, List<SortRecord?> records, double y) {
      final layout = LinearMemoryLayout.arrange(
        [
          for (var s = 0; s <= n; s++)
            SceneNode(
              id: '$name$s',
              label: records[s]?.label ?? '∅',
              x: 0,
              y: 0,
              memoryAddress: '$name[$s]',
              visualState: s == write && name == dest
                  ? NodeVisualState.moving
                  : name == source && (s == left || s == right)
                  ? NodeVisualState.comparing
                  : phase == '完成' && name == 'r'
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
            ),
        ],
        origin: Vec2(x: 38, y: y),
        hasSentinelZero: true,
      );
      for (var s = 0; s <= n; s++) {
        nodes.add(
          layout.nodes[s].copyWith(
            logicBadge: s == 0
                ? name
                : [
                    if (name == source && left == s) 'i',
                    if (name == source && right == s) 'j',
                    if (name == dest && k == s) 'k',
                  ].join('/'),
          ),
        );
      }
      final zero = layout.nodes.first;
      zones.add(
        SceneZoneOverlay(
          id: 'zero-$name',
          label: '$name[0]',
          x: zero.x - 3,
          y: y - 3,
          width: zero.width + 6,
          height: zero.height + 6,
          pattern: ZonePattern.dashed,
          visualState: NodeVisualState.sentinel,
        ),
      );
    }

    row('r', r, arrayY);
    row('TR', tr, arrayY + 107);
    nodes.addAll(
      tree.nodes
          .where((n) => visited.contains(n.id))
          .map(
            (n) => n.copyWith(
              visualState: n.id == top
                  ? NodeVisualState.active
                  : stack.any((s) => s.id == n.id)
                  ? NodeVisualState.comparing
                  : NodeVisualState.sorted,
            ),
          ),
    );
    b.step(
      title: title,
      explain: detail,
      vars: {
        '阶段': phase,
        '源': ?source,
        '目标表': ?dest,
        'i': ?i?.toString(),
        'j': ?j?.toString(),
        'k': ?k?.toString(),
        if (read != null) '读槽': '$source$read',
        if (write != null) '写槽': '$dest$write',
      },
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      callStack: [...stack],
      deltaCompare: compares,
      deltaMove: moves,
      deltaWrite: moves,
      deltaSpace: phase == '初始' ? n : 0,
      milestone: ['进入', '返回', '整趟', '完成'].contains(phase),
      scene: SceneSnapshot(
        nodes: nodes,
        edges: tree.edges.where((e) => visited.contains(e.toNodeId)).toList(),
        zones: zones,
        auxTables: [
          AuxTableSnapshot(
            id: 'merge-records',
            title: '两张顺序表',
            columns: ['位序', 'r', 'r 原位序', 'TR', 'TR 原位序'],
            rows: [
              for (var s = 1; s <= n; s++)
                [
                  '$s',
                  r[s]?.label ?? '∅',
                  r[s]?.origin.toString() ?? '—',
                  tr[s]?.label ?? '∅',
                  tr[s]?.origin.toString() ?? '—',
                ],
            ],
          ),
        ],
      ),
    );
  }
}
