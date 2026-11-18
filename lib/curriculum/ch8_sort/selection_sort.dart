import '../../engine/layout/linear_memory_layout.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import '../../enum/ds_enums.dart';
import 'sort_records.dart';

part 'selection_scene.dart';
part 'selection_source.dart';

enum SelectionMethod {
  simple('简单选择'),
  tournament('树形选择'),
  heap('堆排序');

  const SelectionMethod(this.label);
  final String label;
}

const simpleExample85 = [49, 38, 65, 97, 49, 13, 27, 76];

class SelectionInput {
  const SelectionInput({
    this.keys = sortExample81,
    this.method = SelectionMethod.heap,
  });
  final List<int> keys;
  final SelectionMethod method;
  SelectionInput change({List<int>? keys, SelectionMethod? method}) =>
      SelectionInput(keys: keys ?? this.keys, method: method ?? this.method);
}

class SelectionModule implements AlgorithmModule<SelectionInput> {
  const SelectionModule();
  @override
  String get id => 'ch8_select_heap';
  @override
  List<AlgorithmPreset<SelectionInput>> get presets => const [
    AlgorithmPreset(
      id: 'heap',
      name: '例 8.6、8.7 · 建堆与排序',
      input: SelectionInput(),
    ),
    AlgorithmPreset(
      id: 'simple',
      name: '例 8.5 · 简单选择七趟',
      input: SelectionInput(
        method: SelectionMethod.simple,
        keys: simpleExample85,
      ),
    ),
    AlgorithmPreset(
      id: 'tournament',
      name: '图 8.8 · 锦标赛树',
      input: SelectionInput(method: SelectionMethod.tournament),
    ),
  ];
  @override
  ValidationResult<SelectionInput> validateInput(String raw) {
    final preset = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return preset == null
        ? const ValidationResult.failure('请选择选择排序预设。')
        : ValidationResult.success(preset.input);
  }

  @override
  TraceTimeline generateTrace(SelectionInput input) =>
      _Selection(input, id).record();
}

class _Selection {
  _Selection(this.input, String id)
    : original = SortRecord.tag(input.keys),
      builder = TraceBuilder(
        moduleId: id,
        inputSummary: '${input.method.label} · ${input.keys.join(" ")}',
        codeLines: selectionSource(input.method),
      ) {
    r = [null, ...original];
    size = n;
    if (input.method == SelectionMethod.tournament && n > 0) {
      leaves = 1 << (n - 1).bitLength;
      winners = List.filled(2 * leaves, null);
      for (var i = 0; i < n; i++) {
        winners[leaves + i] = original[i];
      }
      r = List.filled(n + 1, null);
    }
    geometry = treeTemplate(
      input.method == SelectionMethod.heap
          ? n
          : winners.isEmpty
          ? 0
          : winners.length - 1,
    );
  }
  final SelectionInput input;
  final TraceBuilder builder;
  final List<SortRecord> original;
  final crossings = SortCrossings();
  late List<SortRecord?> r;
  final retired = <int>{}, played = <int>{};
  List<SortRecord?> winners = [];
  late final SceneSnapshot geometry;
  late int size;
  int leaves = 0, frame = 0, sorted = 0;
  int? parent, chosen, pass, minIndex, hole;
  SortRecord? saved;
  String section = '';
  int get n => original.length;
  TraceTimeline record() {
    emit(
      1,
      '初始',
      '${input.method.label}的输入记录',
      input.method == SelectionMethod.tournament
          ? '下方输出槽按获胜次序写入。各叶保留原始位序，同键取左侧记录。'
          : '数组采用教材位序 1..n，星号区分相同关键字的记录。',
    );
    switch (input.method) {
      case SelectionMethod.simple:
        simple();
      case SelectionMethod.heap:
        heap();
      case SelectionMethod.tournament:
        tournament();
    }
    sorted = n;
    parent = null;
    chosen = null;
    pass = null;
    minIndex = null;
    emit(
      builder.codeLines.values.first.length,
      '完成',
      '排序完成',
      r.skip(1).map((v) => v!.label).join('　'),
      milestone: true,
    );
    return builder.build();
  }

  void simple() {
    for (var i = 1; i < n; i++) {
      pass = i;
      minIndex = i;
      emit(2, '开始一趟', '第 $i 趟，从 r[$i] 开始', '在尚未排序的区间内寻找最小键。');
      for (var j = i + 1; j <= n; j++) {
        chosen = j;
        final smaller = r[j]!.key < r[minIndex!]!.key;
        emit(
          3,
          '比较',
          '比较 ${r[j]!.label} 与 ${r[minIndex!]!.label}',
          smaller ? '发现更小的候选记录。' : '保留当前候选。',
          compares: 1,
        );
        if (smaller) {
          minIndex = j;
          emit(4, '更新最小', '最小记录位于 r[$j]', '后续记录将与 ${r[j]!.label} 比较。');
        }
      }
      chosen = null;
      if (i != minIndex) {
        swap(i, minIndex!, 5);
      }
      sorted = i;
      emit(6, '整趟', '第 $i 趟结束', 'r[1..$i] 已按关键字排好。', milestone: true);
    }
  }

  void swap(int a, int b, int line) {
    final left = r[a]!, right = r[b]!;
    final change =
        crossings.observe(r, left, a, b, frame, includeDestination: true) +
        crossings.observe(r, right, b, a, frame);
    r[a] = right;
    r[b] = left;
    emit(
      line,
      '交换',
      '交换 r[$a] 与 r[$b]',
      '${left.label} 与 ${right.label} 借助临时记录互换。$change',
      moves: 3,
      from: a,
      to: b,
      swap: true,
      crossing: change,
    );
  }

  void heap() {
    section = '建堆';
    for (var s = n ~/ 2; s > 0; s--) {
      parent = s;
      emit(2, '建堆入口', '从结点 $s 开始筛选', '两个孩子的子树已经是大根堆。', milestone: true);
      adjust(s);
    }
    emit(8, '建堆完成', '初始大根堆已建立', '堆规模为 $size。', milestone: true);
    section = '排序';
    for (var end = n; end > 1; end--) {
      swap(1, end, 9);
      size = end - 1;
      sorted = n - size;
      emit(10, '缩堆', '将 r[$end] 移出堆', '堆规模缩至 $size，后缀有序。', milestone: true);
      adjust(1);
      emit(11, '恢复堆', 'r[1..$size] 恢复大根堆', '根是剩余记录中最大的键。', milestone: true);
    }
  }

  void adjust(int start) {
    var s = start;
    final rc = r[s]!;
    parent = s;
    hole = s;
    saved = rc;
    emit(3, '暂存', '暂存 rc = ${rc.label}', '沿较大的孩子向下筛选。', moves: 1);
    while (2 * s <= size) {
      var j = 2 * s;
      if (j < size) {
        final rightLarger = r[j]!.key < r[j + 1]!.key;
        if (rightLarger) j++;
        chosen = j;
        emit(4, '比较孩子', '比较两个孩子，选择 r[$j]', '左右键相等时取左孩子。', compares: 1);
      }
      chosen = j;
      final stop = rc.key >= r[j]!.key;
      emit(
        5,
        '比较暂存键',
        '比较 rc 与 r[$j]',
        stop ? 'rc 已可放在当前父位。' : '较大孩子上移一层。',
        compares: 1,
      );
      if (stop) break;
      final child = r[j]!;
      final change =
          crossings.observe(r, child, j, s, frame) +
          crossings.observe(r, rc, s, j, frame);
      r[s] = child;
      hole = j;
      emit(
        6,
        '孩子上移',
        '${child.label} 从 r[$j] 上移到 r[$s]',
        '暂存记录的位置随空位下移。$change',
        from: j,
        to: s,
        moves: 1,
        crossing: change,
      );
      s = j;
      parent = s;
      chosen = null;
    }
    r[s] = rc;
    hole = null;
    emit(7, '回填', '将 rc 写回 r[$s]', '本次 HeapAdjust 结束。', moves: 1);
    parent = null;
    chosen = null;
    saved = null;
  }

  void tournament() {
    if (n == 0) return;
    for (var p = leaves - 1; p >= 1; p--) {
      match(p);
    }
    for (var i = 1; i <= n; i++) {
      final winner = winners[1]!;
      r[i] = winner;
      sorted = i;
      emit(
        4,
        '输出',
        '第 $i 名为 ${winner.label}',
        '根保存原始叶 ${winner.origin} 的记录。',
        moves: 1,
        milestone: true,
      );
      if (i == n) break;
      var p = leaves + winner.origin - 1;
      retired.add(p);
      winners[p] = null;
      emit(5, '置无穷', '将叶 ${winner.origin} 改为 ∞', '只重赛这片叶到根路径上的比赛。', focus: p);
      while (p > 1) {
        p ~/= 2;
        match(p, replay: true);
      }
    }
  }

  void match(int p, {bool replay = false}) {
    final a = winners[2 * p], b = winners[2 * p + 1];
    winners[p] = a == null
        ? b
        : b == null || a.key <= b.key
        ? a
        : b;
    played.add(p);
    emit(
      replay ? 6 : 3,
      '晋级',
      '${winners[p]?.label ?? "∞"} 晋级到结点 $p',
      '${a?.label ?? "∞"} 与 ${b?.label ?? "∞"} 比赛。仅两条有效记录交锋时计一次关键字比较。',
      compares: a != null && b != null ? 1 : 0,
      focus: p,
    );
  }
}
