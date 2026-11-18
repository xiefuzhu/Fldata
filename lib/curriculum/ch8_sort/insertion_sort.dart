import '../../engine/layout/linear_memory_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'sort_records.dart';
import 'insertion_source.dart';

part 'insertion_scene.dart';

enum InsertionMethod {
  direct('直接插入'),
  binary('折半插入'),
  shell('希尔排序');

  const InsertionMethod(this.label);
  final String label;
}

class InsertionInput {
  const InsertionInput({
    this.keys = sortExample81,
    this.method = InsertionMethod.direct,
    this.gaps = const [5, 3, 1],
  });
  final List<int> keys, gaps;
  final InsertionMethod method;
  InsertionInput change({
    List<int>? keys,
    InsertionMethod? method,
    List<int>? gaps,
  }) => InsertionInput(
    keys: keys ?? this.keys,
    method: method ?? this.method,
    gaps: gaps ?? this.gaps,
  );
  void validate() {
    if (method != InsertionMethod.shell) return;
    if (gaps.isEmpty || gaps.last != 1) {
      throw const FormatException('希尔增量的最后一项须为 1。');
    }
    for (var i = 0; i < gaps.length; i++) {
      if (gaps[i] <= 0 || i > 0 && gaps[i] >= gaps[i - 1]) {
        throw const FormatException('希尔增量须为严格递减的正整数。');
      }
    }
  }

  static List<int> parse(String raw, {bool tagged = false}) =>
      parseSortIntegers(raw, tagged: tagged);
}

class InsertionModule implements AlgorithmModule<InsertionInput> {
  const InsertionModule();
  @override
  String get id => 'ch8_insert_shell';
  @override
  List<AlgorithmPreset<InsertionInput>> get presets => const [
    AlgorithmPreset(id: 'fig81', name: '图 8.1 · 直接插入', input: InsertionInput()),
    AlgorithmPreset(
      id: 'binary',
      name: '相同八键 · 折半插入',
      input: InsertionInput(method: InsertionMethod.binary),
    ),
    AlgorithmPreset(
      id: 'fig82',
      name: '图 8.2 · 希尔三趟分组',
      input: InsertionInput(keys: sortExample82, method: InsertionMethod.shell),
    ),
    AlgorithmPreset(
      id: 'ascending',
      name: '正序 · 比较和移动',
      input: InsertionInput(keys: [1, 2, 3, 4, 5]),
    ),
    AlgorithmPreset(
      id: 'descending',
      name: '逆序 · 每趟插到表头',
      input: InsertionInput(keys: [5, 4, 3, 2, 1]),
    ),
  ];
  @override
  ValidationResult<InsertionInput> validateInput(String raw) {
    final p = presets.where((v) => v.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择插入排序预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(InsertionInput input) {
    input.validate();
    final b = TraceBuilder(
      moduleId: id,
      inputSummary: '${input.method.label} · ${input.keys.join(" ")}',
      codeLines: insertionSource(input.method.name),
    );
    final run = _Run(input, b)..sort();
    final comparison = <List<String>>[];
    for (final method in [InsertionMethod.direct, InsertionMethod.binary]) {
      final sample = method == input.method
          ? run
          : (_Run(input.change(method: method), null)..sort());
      comparison.add([
        method.label,
        '${sample.kcn}',
        '${sample.shifts}',
        '${sample.rmn - sample.shifts}',
        '${sample.rmn}',
      ]);
    }
    run.finish(comparison);
    return b.build();
  }
}

class _Run {
  _Run(this.input, this.b) : r = [null, ...SortRecord.tag(input.keys)];
  final InsertionInput input;
  final TraceBuilder? b;
  final List<SortRecord?> r;
  int kcn = 0, rmn = 0, shifts = 0, frames = 0, i = 0, dk = 1, prefix = 0;
  int? j, low, mid, high;
  int get n => r.length - 1;
  final crossings = SortCrossings();
  String crossing = '';

  void sort() {
    prefix = n == 0 ? 0 : 1;
    emit(1, '初始', '建立顺序表', '有效记录从 r[1] 开始，原始位序随记录一起移动。', milestone: true);
    if (input.method == InsertionMethod.shell) {
      for (final gap in input.gaps) {
        dk = gap;
        i = 0;
        j = null;
        prefix = dk == 1 && n > 0 ? 1 : 0;
        emit(2, '分组', '按增量 dk = $dk 分组', '位序相差 $dk 的记录属于同一组。', milestone: true);
        // A gap at least as large as the table has only singleton groups.
        if (dk < n) {
          for (i = dk + 1; i <= n; i++) {
            shellInsert();
          }
        }
        i = 0;
        j = null;
        emit(8, '整趟', '增量 $dk 的排序完成', '各组内部有序。', milestone: true);
      }
    } else {
      for (i = 2; i <= n; i++) {
        if (input.method == InsertionMethod.direct) {
          directInsert();
        } else {
          binaryInsert();
        }
        prefix = i;
        j = null;
        low = null;
        mid = null;
        high = null;
        emit(8, '整趟', '已排好 r[1..$i]', '本趟插入完成。', milestone: true);
      }
    }
  }

  bool less(int a, int c, int line) {
    final yes = r[a]!.key < r[c]!.key;
    kcn++;
    emit(
      line,
      '比较',
      '比较 r[$a] 与 r[$c]',
      '${r[a]!.label} < ${r[c]!.label} 为${yes ? "真" : "假"}；KCN 加 1。',
      compare: true,
      active: [a, c],
    );
    return yes;
  }

  void move(int from, int to, int line, String phase) {
    final item = r[from]!;
    crossing = '';
    if (b != null && from != to && phase != '暂存') {
      crossing = crossings.observe(r, item, from == 0 ? i : from, to, frames);
    }
    r[to] = item;
    rmn++;
    if (phase == '后移') shifts++;
    emit(
      line,
      phase,
      '$phase ${item.label}',
      'r[$to] ← r[$from]，RMN 加 1。$crossing',
      from: from,
      to: to,
    );
    crossing = '';
  }

  void directInsert() {
    j = i - 1;
    if (!less(i, i - 1, 2)) return;
    move(i, 0, 3, '暂存');
    move(i - 1, i, 4, '后移');
    j = i - 2;
    while (less(0, j!, 5)) {
      move(j!, j! + 1, 6, '后移');
      j = j! - 1;
    }
    move(0, j! + 1, 7, '回填');
  }

  void binaryInsert() {
    move(i, 0, 2, '暂存');
    low = 1;
    high = i - 1;
    emit(3, '定位', '定位插入位置', '在有序区 r[1..$high] 内查找。');
    while (low! <= high!) {
      mid = (low! + high!) ~/ 2;
      if (less(0, mid!, 4)) {
        high = mid! - 1;
      } else {
        low = mid! + 1;
      }
      emit(5, '边界', '收缩折半区间', 'low = $low，high = $high；相等时继续在右半区定位。');
    }
    mid = null;
    j = i - 1;
    while (j! >= low!) {
      move(j!, j! + 1, 6, '后移');
      j = j! - 1;
    }
    move(0, high! + 1, 7, '回填');
  }

  void shellInsert() {
    j = i - dk;
    if (less(i, j!, 3)) {
      move(i, 0, 4, '暂存');
      while (j! > 0 && less(0, j!, 5)) {
        move(j!, j! + dk, 6, '后移');
        j = j! - dk;
      }
      move(0, j! + dk, 7, '回填');
    }
    if (dk == 1) prefix = i;
  }

  void finish(List<List<String>> comparison) {
    i = 0;
    j = null;
    low = null;
    mid = null;
    high = null;
    prefix = n;
    emit(
      input.method == InsertionMethod.direct ? 8 : 9,
      '完成',
      '排序完成',
      r.skip(1).map((v) => v!.label).join('　'),
      milestone: true,
      comparison: comparison,
    );
  }
}
