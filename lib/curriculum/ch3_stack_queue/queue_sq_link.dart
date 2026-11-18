import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'queue_trace.dart';

enum QueueKind { circular, linear, linked }

enum QueueOperation { init, length, enqueue, dequeue, peek, demo }

class QueueInput {
  const QueueInput({
    this.kind = QueueKind.circular,
    this.operation = QueueOperation.enqueue,
    this.capacity = 5,
    this.front = 0,
    this.values = const [10, 20, 30],
    this.value = 99,
  });
  final QueueKind kind;
  final QueueOperation operation;
  final int capacity, front, value;
  final List<int> values;
  QueueInput copyWith({QueueKind? kind, QueueOperation? operation}) =>
      QueueInput(
        kind: kind ?? this.kind,
        operation: operation ?? this.operation,
        capacity: capacity,
        front: front,
        values: values,
        value: value,
      );
  String get raw =>
      '${kind.name}|${operation.name}|$capacity|$front|$value|${values.join(',')}';
}

class QueueSqLinkModule implements AlgorithmModule<QueueInput> {
  const QueueSqLinkModule();
  @override
  String get id => 'ch3_queue_sq_link';
  static const kindNames = ['循环队列', '线性队列', '带头链队'];
  static const operationNames = [
    'Init 初始化',
    'Length 长度',
    'EnQueue 入队',
    'DeQueue 出队',
    'GetHead 读队首',
    '假溢出对照',
  ];
  @override
  List<AlgorithmPreset<QueueInput>> get presets => const [
    AlgorithmPreset(
      id: 'wrap',
      name: '循环 · rear 跨零点',
      input: QueueInput(front: 2, values: [10, 20]),
    ),
    AlgorithmPreset(
      id: 'full',
      name: '循环 · 5 槽仅容 4 元素',
      input: QueueInput(values: [1, 2, 3, 4]),
    ),
    AlgorithmPreset(
      id: 'front-wrap',
      name: '循环 · front 跨零点出队',
      input: QueueInput(
        front: 4,
        values: [8, 9],
        operation: QueueOperation.dequeue,
      ),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '循环 · 空队拒绝出队',
      input: QueueInput(values: [], operation: QueueOperation.dequeue),
    ),
    AlgorithmPreset(
      id: 'length',
      name: '循环 · 模运算求长度',
      input: QueueInput(
        front: 4,
        values: [8, 9, 10],
        operation: QueueOperation.length,
      ),
    ),
    AlgorithmPreset(
      id: 'linear-demo',
      name: '对照 · 线性假溢出',
      input: QueueInput(kind: QueueKind.linear, operation: QueueOperation.demo),
    ),
    AlgorithmPreset(
      id: 'ring-demo',
      name: '对照 · 循环复用前端空槽',
      input: QueueInput(operation: QueueOperation.demo),
    ),
    AlgorithmPreset(
      id: 'linked-last',
      name: '链队 · 删除唯一节点',
      input: QueueInput(
        kind: QueueKind.linked,
        operation: QueueOperation.dequeue,
        values: [42],
      ),
    ),
    AlgorithmPreset(
      id: 'linked-push',
      name: '链队 · 空队入队',
      input: QueueInput(kind: QueueKind.linked, values: []),
    ),
    AlgorithmPreset(
      id: 'linked-init',
      name: '链队 · 初始化头结点',
      input: QueueInput(kind: QueueKind.linked, operation: QueueOperation.init),
    ),
    AlgorithmPreset(
      id: 'linked-peek',
      name: '链队 · 读取首元而非头结点',
      input: QueueInput(kind: QueueKind.linked, operation: QueueOperation.peek),
    ),
  ];
  @override
  ValidationResult<QueueInput> validateInput(String raw) {
    final p = raw.split('|');
    if (p.length != 6) return const ValidationResult.failure('队列输入字段不完整。');
    final kind = QueueKind.values.where((k) => k.name == p[0]).firstOrNull,
        op = QueueOperation.values.where((o) => o.name == p[1]).firstOrNull;
    final cap = int.tryParse(p[2]),
        front = int.tryParse(p[3]),
        value = int.tryParse(p[4]);
    final list = p[5].trim().isEmpty
        ? <int?>[]
        : p[5].trim().split(RegExp(r'[,，\s]+')).map(int.tryParse).toList();
    if (kind == null ||
        op == null ||
        cap == null ||
        cap < 2 ||
        cap > 10 ||
        front == null ||
        front < 0 ||
        front > cap ||
        value == null ||
        value.abs() > 999 ||
        list.length > 10 ||
        list.any((v) => v == null || v.abs() > 999)) {
      return const ValidationResult.failure(
        '容量 2～10；最多 10 个 −999～999 整数，front 在容量范围内。',
      );
    }
    if (op == QueueOperation.demo && kind == QueueKind.linked) {
      return const ValidationResult.failure('假溢出对照用于线性与循环队列。');
    }
    if (op != QueueOperation.init &&
        op != QueueOperation.demo &&
        ((kind == QueueKind.circular && (front >= cap || list.length >= cap)) ||
            (kind == QueueKind.linear && front + list.length > cap))) {
      return const ValidationResult.failure(
        '循环队列留一空槽且 front < M；线性队列 front + 长度不能超过 M。',
      );
    }
    return ValidationResult.success(
      QueueInput(
        kind: kind,
        operation: op,
        capacity: cap,
        front: front,
        value: value,
        values: list.cast<int>(),
      ),
    );
  }

  @override
  TraceTimeline generateTrace(QueueInput input) {
    if (!validateInput(input.raw).isValid) {
      throw ArgumentError('Invalid queue input');
    }
    return generateQueueTrace(input);
  }
}
