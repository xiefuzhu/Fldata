import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'stack_trace.dart';

enum StackKind { array, linked, shared }

enum StackOperation { init, push, pop, peek }

class StackInput {
  const StackInput({
    this.kind = StackKind.array,
    this.operation = StackOperation.push,
    this.capacity = 6,
    this.a = const [10, 20, 30],
    this.b = const [70, 80],
    this.value = 99,
    this.stack = 0,
  });
  final StackKind kind;
  final StackOperation operation;
  final int capacity, value, stack;
  final List<int> a, b;
  StackInput copyWith({
    StackKind? kind,
    StackOperation? operation,
    int? stack,
  }) => StackInput(
    kind: kind ?? this.kind,
    operation: operation ?? this.operation,
    capacity: capacity,
    a: a,
    b: b,
    value: value,
    stack: stack ?? this.stack,
  );
  String get raw =>
      '${kind.name}|${operation.name}|$capacity|$stack|$value|${a.join(',')}|${b.join(',')}';
}

class StackSqLinkModule implements AlgorithmModule<StackInput> {
  const StackSqLinkModule();
  @override
  String get id => 'ch3_stack_sq_link';
  static const kindNames = ['顺序栈', '无头链栈', '共享双栈'];
  static const operationNames = ['Init 初始化', 'Push 入栈', 'Pop 出栈', 'GetTop 读栈顶'];
  @override
  List<AlgorithmPreset<StackInput>> get presets => const [
    AlgorithmPreset(
      id: 'array-push',
      name: '顺序 · 写空槽后 top++',
      input: StackInput(),
    ),
    AlgorithmPreset(
      id: 'array-pop',
      name: '顺序 · --top 后读值',
      input: StackInput(operation: StackOperation.pop),
    ),
    AlgorithmPreset(
      id: 'array-full',
      name: '边界 · 顺序满栈',
      input: StackInput(a: [1, 2, 3, 4, 5, 6]),
    ),
    AlgorithmPreset(
      id: 'array-empty',
      name: '边界 · 顺序空栈出栈',
      input: StackInput(operation: StackOperation.pop, a: []),
    ),
    AlgorithmPreset(
      id: 'array-peek',
      name: '顺序 · 只读栈顶',
      input: StackInput(operation: StackOperation.peek),
    ),
    AlgorithmPreset(
      id: 'linked-push',
      name: '链栈 · 新节点接到 S 前',
      input: StackInput(kind: StackKind.linked),
    ),
    AlgorithmPreset(
      id: 'linked-pop',
      name: '链栈 · 删除唯一节点',
      input: StackInput(
        kind: StackKind.linked,
        operation: StackOperation.pop,
        a: [42],
      ),
    ),
    AlgorithmPreset(
      id: 'linked-init',
      name: '链栈 · 空栈无需头节点',
      input: StackInput(kind: StackKind.linked, operation: StackOperation.init),
    ),
    AlgorithmPreset(
      id: 'shared-last',
      name: '共享 · 填满最后空槽',
      input: StackInput(kind: StackKind.shared, a: [1, 2], b: [8, 9, 10]),
    ),
    AlgorithmPreset(
      id: 'shared-right',
      name: '共享 · 右栈向左增长',
      input: StackInput(kind: StackKind.shared, stack: 1, a: [1], b: [8, 9]),
    ),
    AlgorithmPreset(
      id: 'shared-full',
      name: '共享 · 两栈相邻已满',
      input: StackInput(
        kind: StackKind.shared,
        capacity: 5,
        a: [1, 2],
        b: [8, 9, 10],
      ),
    ),
    AlgorithmPreset(
      id: 'shared-empty',
      name: '共享 · 仅右栈为空',
      input: StackInput(
        kind: StackKind.shared,
        operation: StackOperation.pop,
        a: [1, 2],
        b: [],
        stack: 1,
      ),
    ),
  ];
  @override
  ValidationResult<StackInput> validateInput(String raw) {
    final p = raw.split('|');
    if (p.length != 7) return const ValidationResult.failure('栈输入字段不完整。');
    final kind = StackKind.values.where((v) => v.name == p[0]).firstOrNull,
        op = StackOperation.values.where((v) => v.name == p[1]).firstOrNull;
    final cap = int.tryParse(p[2]),
        side = int.tryParse(p[3]),
        value = int.tryParse(p[4]);
    List<int?> parse(String s) => s.trim().isEmpty
        ? []
        : s.trim().split(RegExp(r'[,，\s]+')).map(int.tryParse).toList();
    final a = parse(p[5]), b = parse(p[6]);
    if (kind == null ||
        op == null ||
        cap == null ||
        cap < 1 ||
        cap > 10 ||
        side == null ||
        side < 0 ||
        side > 1 ||
        value == null ||
        value.abs() > 999 ||
        a.length > 10 ||
        b.length > 10 ||
        [...a, ...b].any((v) => v == null || v.abs() > 999)) {
      return const ValidationResult.failure(
        '容量 1～10；每栈最多输入 10 个 −999～999 整数，顺序为栈底到栈顶。',
      );
    }
    if (op != StackOperation.init &&
        ((kind == StackKind.array && a.length > cap) ||
            (kind == StackKind.shared && a.length + b.length > cap))) {
      return const ValidationResult.failure('初始有效元素不能超过容量；要演示上溢请填满后选择 Push。');
    }
    return ValidationResult.success(
      StackInput(
        kind: kind,
        operation: op,
        capacity: cap,
        a: a.cast<int>(),
        b: b.cast<int>(),
        value: value,
        stack: side,
      ),
    );
  }

  @override
  TraceTimeline generateTrace(StackInput input) {
    if (!validateInput(input.raw).isValid) {
      throw ArgumentError('Invalid stack input');
    }
    return generateStackTrace(input);
  }
}
