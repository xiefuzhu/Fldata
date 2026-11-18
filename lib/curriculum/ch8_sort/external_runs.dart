part of 'external_sort.dart';

/// ls contains leaf indices. The extra index k is strictly smaller than any
/// record. An exhausted real leaf is greater than every remaining record.
class _ExternalRuns {
  _ExternalRuns(this.input, this.builder)
    : k = input.width,
      ls = List.filled(input.width, input.width),
      keys = List.filled(input.width, null),
      bands = List.filled(input.width, 1),
      positions = List.filled(input.width, 0);
  final ExternalInput input;
  final TraceBuilder? builder;
  final int k;
  final List<int> ls, bands, positions;
  final List<int?> keys;
  final List<List<int>> output = [];
  int cursor = 0, activeRun = 1;
  int? minimax;
  late final SceneSnapshot template = _loserTemplate(k);
  bool get replacement => input.method == ExternalMethod.replacement;
  String get buffer => replacement ? 'WA' : 'b';

  int compare(int a, int b) {
    if (a == b) return 0;
    if (a == k) return -1;
    if (b == k) return 1;
    final x = keys[a], y = keys[b];
    if (x == null || y == null) {
      return x == null ? (y == null ? a.compareTo(b) : 1) : -1;
    }
    final segment = bands[a].compareTo(bands[b]);
    if (segment != 0) return segment;
    final cmp = x.compareTo(y);
    return cmp == 0 ? a.compareTo(b) : cmp;
  }

  String entry(int s) => s == k
      ? 'MINKEY'
      : keys[s] == null
      ? 'MAXKEY'
      : '$buffer[$s]=${keys[s]}';
  void adjust(int leaf) {
    var child = k + leaf, challenger = leaf;
    while (child > 1) {
      final t = child ~/ 2, old = ls[t], candidate = challenger;
      if (compare(challenger, old) > 0) {
        ls[t] = challenger;
        challenger = old;
      }
      emit(
        3,
        '比赛',
        '在 ls[$t] 比赛',
        '${entry(candidate)} 与 ${entry(old)} 比较，败者 ${ls[t]} 留在结点，胜者 $challenger 向上。',
        leaf: leaf,
        child: child,
        t: t,
        candidate: candidate,
        winner: challenger,
        compare: 1,
      );
      child = t;
    }
    ls[0] = challenger;
    emit(
      4,
      '冠军',
      '更新 ls[0]',
      '当前胜者为 ${entry(challenger)}。',
      leaf: leaf,
      winner: challenger,
    );
  }

  bool refillRun(int s) {
    final run = input.runs[s];
    if (positions[s] >= run.length) {
      keys[s] = null;
      return false;
    }
    keys[s] = run[positions[s]++];
    return true;
  }

  void merge() {
    emit(1, '初始化', '初始化败者树', 'ls 全部指向额外的 MINKEY。每路结束后以 MAXKEY 继续参赛。');
    for (var s = 0; s < k; s++) {
      final loaded = refillRun(s);
      emit(
        2,
        '首记录',
        '装入 b[$s]',
        '${entry(s)}，读入后仅缓存这一条记录。',
        leaf: s,
        reads: loaded ? 1 : 0,
      );
    }
    for (var s = k - 1; s >= 0; s--) {
      adjust(s);
    }
    emit(4, '建树完成', '初始败者树已建立', 'ls[0] 给出当前首记录最小的路号。');
    while (keys[ls[0]] != null) {
      final s = ls[0], value = keys[s]!;
      if (output.isEmpty) output.add([]);
      output.first.add(value);
      emit(5, '输出', '把 $value 写入归并段', '冠军来自第 $s 路。', leaf: s, writes: 1);
      final loaded = refillRun(s);
      emit(
        6,
        '补读',
        loaded ? '读取第 $s 路的下一条记录' : '第 $s 路已耗尽',
        'b[$s] 更新为 ${entry(s)}，只重赛该叶到根的路径。',
        leaf: s,
        reads: loaded ? 1 : 0,
      );
      adjust(s);
    }
    emit(
      7,
      '完成',
      '多路归并完成',
      '所有输入段均已耗尽，共输出 ${output.firstOrNull?.length ?? 0} 条记录。',
    );
  }

  void replace() {
    emit(1, '初始化', '准备工作区 WA', '工作区有 $k 槽，每个记录保存键值和段号。比赛先比较段号，再比较键值。');
    for (var s = k - 1; s >= 0; s--) {
      final loaded = cursor < input.keys.length;
      if (loaded) keys[s] = input.keys[cursor++];
      emit(
        2,
        '初装',
        '装入 WA[$s]',
        loaded ? '读入 ${keys[s]}，初始段号为 1。' : '输入已空，本槽不参与选取。',
        leaf: s,
        reads: loaded ? 1 : 0,
      );
      adjust(s);
    }
    emit(4, '建树完成', '工作区败者树已就绪', '从当前段号最小的记录中取最小键。');
    while (keys[ls[0]] != null) {
      final s = ls[0], value = keys[s]!;
      if (bands[s] != activeRun) {
        emit(7, '封段', '封闭 RUN $activeRun', '当前段不再有合格记录，将开始 RUN ${bands[s]}。');
        activeRun = bands[s];
        minimax = null;
        emit(
          7,
          '换段',
          '开始 RUN $activeRun',
          '上一段冻结的记录已可参赛，重新选取 MINIMAX。',
          leaf: s,
        );
      }
      if (output.length < activeRun) output.add([]);
      output.last.add(value);
      minimax = value;
      keys[s] = null;
      emit(
        5,
        '输出',
        '把 $value 写入 RUN $activeRun',
        '腾出 WA[$s]，更新 MINIMAX = $value。',
        leaf: s,
        writes: 1,
      );
      if (cursor < input.keys.length) {
        final incoming = input.keys[cursor++];
        keys[s] = incoming;
        bands[s] = incoming < value ? activeRun + 1 : activeRun;
        emit(
          6,
          bands[s] == activeRun ? '补读' : '冻结',
          '读入 $incoming 到 WA[$s]',
          bands[s] == activeRun ? '新键不小于 MINIMAX，留在本段。' : '新键小于 MINIMAX，归入下一段。',
          leaf: s,
          reads: 1,
        );
      } else {
        emit(6, '耗尽', 'WA[$s] 退出', '外存输入已耗尽。', leaf: s);
      }
      adjust(s);
    }
    emit(8, '完成', '所有初始归并段已生成', '共读入 $cursor 条记录，输出 ${output.length} 个非降序段。');
  }
}
