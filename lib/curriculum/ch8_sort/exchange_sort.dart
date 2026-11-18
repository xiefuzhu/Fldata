import '../../engine/layout/linear_memory_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'exchange_source.dart';
import 'sort_records.dart';

part 'exchange_scene.dart';

enum ExchangeMethod {
  bubble('冒泡排序'),
  quick('快速排序');

  const ExchangeMethod(this.label);
  final String label;
}

class ExchangeInput {
  const ExchangeInput({
    this.keys = sortExample81,
    this.method = ExchangeMethod.quick,
    this.earlyStop = true,
  });
  final List<int> keys;
  final ExchangeMethod method;
  final bool earlyStop;
  ExchangeInput change({
    List<int>? keys,
    ExchangeMethod? method,
    bool? earlyStop,
  }) => ExchangeInput(
    keys: keys ?? this.keys,
    method: method ?? this.method,
    earlyStop: earlyStop ?? this.earlyStop,
  );
}

class ExchangeModule implements AlgorithmModule<ExchangeInput> {
  const ExchangeModule();
  @override
  String get id => 'ch8_swap_bubble_quick';
  @override
  List<AlgorithmPreset<ExchangeInput>> get presets => const [
    AlgorithmPreset(
      id: 'bubble',
      name: '图 8.3 · 冒泡六趟',
      input: ExchangeInput(method: ExchangeMethod.bubble),
    ),
    AlgorithmPreset(
      id: 'quick',
      name: '图 8.4、8.5 · 首元划分与递归',
      input: ExchangeInput(),
    ),
    AlgorithmPreset(
      id: 'balanced',
      name: '七键 · 均分区间',
      input: ExchangeInput(keys: [4, 1, 3, 2, 6, 5, 7]),
    ),
    AlgorithmPreset(
      id: 'chain',
      name: '七键 · 正序退化',
      input: ExchangeInput(keys: [1, 2, 3, 4, 5, 6, 7]),
    ),
    AlgorithmPreset(
      id: 'unstable',
      name: '同键跨位 · 2 与 2*',
      input: ExchangeInput(keys: [2, 2, 1]),
    ),
  ];
  @override
  ValidationResult<ExchangeInput> validateInput(String raw) {
    final p = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择交换排序预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(ExchangeInput input) => _Run(input, id).record();
}

class _Run {
  _Run(this.input, String id)
    : r = [null, ...SortRecord.tag(input.keys)],
      b = TraceBuilder(
        moduleId: id,
        inputSummary: '${input.method.label} · ${input.keys.join(" ")}',
        codeLines: exchangeSource(input.method == ExchangeMethod.bubble),
      );
  final ExchangeInput input;
  final List<SortRecord?> r;
  final TraceBuilder b;
  final stack = <StackActivationRecord>[], settled = <int>{};
  final crossings = SortCrossings();
  int frames = 0, pass = 0, swaps = 0;
  int? low, high, hole, j, m;
  bool flag = false;
  int get n => r.length - 1;
  TraceTimeline record() {
    emit(1, '初始', '建立待排序表', '每条记录保留原始位序，比较仅使用关键字。', milestone: true);
    if (input.method == ExchangeMethod.bubble) {
      bubble();
    } else {
      qsort(1, n, null);
    }
    settled.addAll([for (var s = 1; s <= n; s++) s]);
    emit(
      input.method == ExchangeMethod.bubble ? 7 : 12,
      '完成',
      '排序完成',
      r.skip(1).map((e) => e!.label).join('　'),
      milestone: true,
    );
    return b.build();
  }

  void bubble() {
    for (var bound = n - 1; bound > 0; bound--) {
      m = bound;
      pass++;
      flag = false;
      j = null;
      emit(2, '开始一趟', '第 $pass 趟 · m = $m', '比较 r[1] 到 r[${bound + 1}] 的相邻记录。');
      for (var k = 1; k <= bound; k++) {
        j = k;
        final left = r[k]!, right = r[k + 1]!;
        emit(
          3,
          '比较',
          '比较 ${left.label} 与 ${right.label}',
          '左键严格大于右键时交换；相等时保持原顺序。',
          compares: 1,
          active: [k, k + 1],
        );
        if (left.key > right.key) {
          r[k] = right;
          r[k + 1] = left;
          flag = true;
          swaps++;
          emit(
            4,
            '交换',
            '相邻交换 ${left.label} 与 ${right.label}',
            '经临时记录 t 交换，三次记录赋值。',
            moves: 3,
            from: k,
            to: k + 1,
            swap: true,
          );
        }
      }
      j = null;
      settled.add(bound + 1);
      emit(
        5,
        '整趟',
        '第 $pass 趟结束',
        '本趟最大键 ${r[bound + 1]!.label} 已到位。flag = ${flag ? 1 : 0}。',
        milestone: true,
      );
      if (input.earlyStop && !flag) {
        emit(6, '提前结束', '整趟无交换', 'flag = 0，剩余区间已按关键字有序。', milestone: true);
        break;
      }
    }
    m = null;
  }

  void qsort(int first, int last, String? parent) {
    final id = 'q$first:$last';
    stack.add(
      StackActivationRecord(
        id: id,
        functionName: 'QSort',
        arguments: {'low': '$first', 'high': '$last'},
        parentCallId: parent,
        returnLocation: parent ?? 'QuickSort',
      ),
    );
    low = first;
    high = last;
    emit(
      9,
      '进入',
      'QSort($first, $last)',
      first > last
          ? '空区间直接返回。'
          : first == last
          ? '单记录区间已到位。'
          : '以区间首记录为枢轴。',
      milestone: true,
    );
    if (first < last) {
      final p = partition(first, last);
      low = null;
      high = null;
      emit(10, '左递归', '进入左区间 [$first, ${p - 1}]', '枢轴位置 $p 已固定。');
      qsort(first, p - 1, id);
      emit(11, '右递归', '进入右区间 [${p + 1}, $last]', '左区间已返回。');
      qsort(p + 1, last, id);
    } else if (first == last) {
      settled.add(first);
      stack.last = stack.last.copyWith(locals: {'record': r[first]!.label});
    }
    emit(12, '返回', '返回区间 [$first, $last]', '当前 QSort 调用结束。');
    stack.removeLast();
    low = null;
    high = null;
  }

  int partition(int first, int last) {
    var l = first, h = last;
    final pivot = r[first]!;
    pass++;
    r[0] = pivot;
    hole = l;
    emit(
      2,
      '暂存',
      '枢轴 ${pivot.label} 进入 r[0]',
      'r[$l] 成为空坑。',
      from: l,
      to: 0,
      moves: 1,
      milestone: true,
    );
    while (l < h) {
      while (l < h) {
        final skip = r[h]!.key >= pivot.key;
        emit(
          3,
          '右扫',
          '从 high = $h 向左扫描',
          '${r[h]!.label} ≥ ${pivot.label} 为${skip ? "真，high 左移" : "假，找到较小记录"}。',
          compares: 1,
          active: [h],
        );
        if (!skip) break;
        high = --h;
      }
      fill(h, l, 4, pivot);
      while (l < h) {
        final skip = r[l]!.key <= pivot.key;
        emit(
          5,
          '左扫',
          '从 low = $l 向右扫描',
          '${r[l]!.label} ≤ ${pivot.label} 为${skip ? "真，low 右移" : "假，找到较大记录"}。',
          compares: 1,
          active: [l],
        );
        if (!skip) break;
        low = ++l;
      }
      fill(l, h, 6, pivot);
    }
    r[l] = pivot;
    hole = null;
    settled.add(l);
    stack.last = stack.last.copyWith(
      locals: {'pivotloc': '$l', 'pivot': pivot.label},
    );
    emit(
      7,
      '枢轴归位',
      '枢轴 ${pivot.label} 落在 r[$l]',
      '左右指针相遇。从 r[0] 回填，完成区间 [$first, $last] 的划分。',
      moves: 1,
      from: 0,
      to: l,
      milestone: true,
    );
    return l;
  }

  void fill(int from, int to, int line, SortRecord pivot) {
    final item = r[from]!;
    String change = '';
    if (from != to) {
      change =
          crossings.observe(r, item, from, to, frames) +
          crossings.observe(r, pivot, to, from, frames);
    }
    r[to] = item;
    hole = from;
    emit(
      line,
      from == to ? '同槽赋值' : '填坑',
      from == to ? '指针相遇 · r[$to] 自赋值' : '${item.label} 从 r[$from] 飞填 r[$to]',
      from == to
          ? '执行教材赋值语句，空坑位置保持在 $from。'
          : '空坑移到 r[$from]，枢轴仍保存在 r[0]。$change',
      moves: 1,
      from: from,
      to: to,
      crossing: change,
    );
  }
}
