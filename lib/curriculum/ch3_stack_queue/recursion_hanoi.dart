import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'recursion_trace.dart';

enum RecursionKind { hanoi, factorial, fibonacci, traverse }

class RecursionInput {
  const RecursionInput({
    this.kind = RecursionKind.hanoi,
    this.n = 3,
    this.values = const [12, 24, 36, 48],
  });
  final RecursionKind kind;
  final int n;
  final List<int> values;
  RecursionInput copyWith({RecursionKind? kind, int? n}) =>
      RecursionInput(kind: kind ?? this.kind, n: n ?? this.n, values: values);
  String get raw => '${kind.name}|$n|${values.join(',')}';
}

class RecursionHanoiModule implements AlgorithmModule<RecursionInput> {
  const RecursionHanoiModule();
  @override
  String get id => 'ch3_recursion_hanoi';
  static const names = ['汉诺塔', '阶乘 Fact', '斐波 Fib', '递归遍历链表'];
  @override
  List<AlgorithmPreset<RecursionInput>> get presets => const [
    AlgorithmPreset(id: 'h3', name: '汉诺塔 · 三盘七步', input: RecursionInput()),
    AlgorithmPreset(id: 'h1', name: '汉诺塔 · 单盘基例', input: RecursionInput(n: 1)),
    AlgorithmPreset(id: 'h6', name: '汉诺塔 · 六盘递归树', input: RecursionInput(n: 6)),
    AlgorithmPreset(
      id: 'fact',
      name: '阶乘 · 5!',
      input: RecursionInput(kind: RecursionKind.factorial, n: 5),
    ),
    AlgorithmPreset(
      id: 'fact0',
      name: '阶乘 · 0! = 1',
      input: RecursionInput(kind: RecursionKind.factorial, n: 0),
    ),
    AlgorithmPreset(
      id: 'fib',
      name: '斐波 · Fib(5) 重复子问题',
      input: RecursionInput(kind: RecursionKind.fibonacci, n: 5),
    ),
    AlgorithmPreset(
      id: 'list',
      name: '链表 · 先输出再递归',
      input: RecursionInput(kind: RecursionKind.traverse),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '链表 · NULL 基例',
      input: RecursionInput(kind: RecursionKind.traverse, values: []),
    ),
  ];
  @override
  ValidationResult<RecursionInput> validateInput(String raw) {
    final p = raw.split('|');
    if (p.length != 3) return const ValidationResult.failure('输入字段不完整。');
    final kind = RecursionKind.values.where((k) => k.name == p[0]).firstOrNull,
        n = int.tryParse(p[1]);
    final values = p[2].trim().isEmpty
        ? <int?>[]
        : p[2].trim().split(RegExp(r'[,，\s]+')).map(int.tryParse).toList();
    if (kind == null ||
        n == null ||
        n < 0 ||
        n > 10 ||
        values.length > 8 ||
        values.any((v) => v == null || v.abs() > 999)) {
      return const ValidationResult.failure('n 为 0～10；链表最多 8 个 −999～999 整数。');
    }
    if (kind == RecursionKind.hanoi && (n < 1 || n > 6)) {
      return const ValidationResult.failure('汉诺塔圆盘数为 1～6。');
    }
    if (kind == RecursionKind.fibonacci && n < 1) {
      return const ValidationResult.failure('Fib 采用 F(1)=F(2)=1，n 为 1～10。');
    }
    return ValidationResult.success(
      RecursionInput(kind: kind, n: n, values: values.cast<int>()),
    );
  }

  @override
  TraceTimeline generateTrace(RecursionInput input) {
    if (!validateInput(input.raw).isValid) {
      throw ArgumentError('Invalid recursion input');
    }
    return generateRecursionTrace(input);
  }
}
