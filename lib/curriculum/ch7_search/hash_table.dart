import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import '../../enum/ds_enums.dart';
import 'key_operations.dart';

part 'hash_trace.dart';
part 'hash_source.dart';

enum HashFunction {
  remainder('除留余数'),
  direct('直接定址'),
  digits('数字分析'),
  square('平方取中'),
  fold('折叠');

  const HashFunction(this.label);
  final String label;
}

enum HashCollision {
  linear('线性探测'),
  quadratic('二次探测'),
  random('伪随机探测'),
  chain('链地址');

  const HashCollision(this.label);
  final String label;
}

const _example73 = [19, 14, 23, 1, 68, 20, 84, 27, 55, 11, 10, 79];

class HashInput {
  const HashInput({
    this.function = HashFunction.remainder,
    this.collision = HashCollision.linear,
    this.m = 16,
    this.p = 13,
    this.base = 0,
    this.digits = const [3, 2],
    this.boundaryFold = false,
    this.seed = 8,
    this.initial = _example73,
    this.operations = '?79 ?13',
  });
  final HashFunction function;
  final HashCollision collision;
  final int m, p, base, seed;
  final List<int> digits, initial;
  final bool boundaryFold;
  final String operations;
  HashInput change({
    HashFunction? function,
    HashCollision? collision,
    int? m,
    int? p,
    int? base,
    List<int>? digits,
    bool? boundaryFold,
    int? seed,
    List<int>? initial,
    String? operations,
  }) => HashInput(
    function: function ?? this.function,
    collision: collision ?? this.collision,
    m: m ?? this.m,
    p: p ?? this.p,
    base: base ?? this.base,
    digits: digits ?? this.digits,
    boundaryFold: boundaryFold ?? this.boundaryFold,
    seed: seed ?? this.seed,
    initial: initial ?? this.initial,
    operations: operations ?? this.operations,
  );
  void validate() {
    if (p < 1 || m < p) throw const FormatException('表长与入口数须满足 1 ≤ p ≤ m。');
    if (function == HashFunction.digits &&
        (digits.isEmpty ||
            digits.any((n) => n < 1) ||
            digits.toSet().length != digits.length)) {
      throw const FormatException('选位须为互不重复的正整数，个位是第 1 位。');
    }
    parseKeyOperations(operations);
  }

  ({int? home, String formula}) hash(int key) {
    final k = BigInt.from(key), mod = BigInt.from(p);
    final dec = k.abs().toString(), width = (p - 1).toString().length;
    switch (function) {
      case HashFunction.remainder:
        return (home: key % p, formula: '$key mod $p = ${key % p}');
      case HashFunction.direct:
        final a = k - BigInt.from(base);
        return (
          home: a.isNegative || a >= mod ? null : a.toInt(),
          formula: '$key − ($base) = $a',
        );
      case HashFunction.digits:
        final selected = [
          for (final i in digits) i > dec.length ? '0' : dec[dec.length - i],
        ].join();
        final h = (BigInt.parse(selected) % mod).toInt();
        return (
          home: h,
          formula: '|$key| 从右取第 ${digits.join("、")} 位 → $selected mod $p = $h',
        );
      case HashFunction.square:
        final squared = (k * k).toString().padLeft(width, '0'),
            start = (squared.length - width) ~/ 2;
        final mid = squared.substring(start, start + width),
            h = (BigInt.parse(mid) % mod).toInt();
        return (
          home: h,
          formula: '$key² = $squared，取中间 $width 位 $mid，mod $p = $h',
        );
      case HashFunction.fold:
        final groups = <String>[];
        for (var i = 0; i < dec.length; i += width) {
          final end = i + width > dec.length ? dec.length : i + width;
          final group = dec.substring(i, end);
          groups.add(
            boundaryFold && groups.length.isOdd
                ? group.split('').reversed.join()
                : group,
          );
        }
        final total = groups.fold(BigInt.zero, (n, s) => n + BigInt.parse(s)),
            truncated = total % BigInt.from(10).pow(width),
            h = (truncated % mod).toInt();
        return (
          home: h,
          formula: '${groups.join(" + ")} = $total，舍进位得 $truncated，mod $p = $h',
        );
    }
  }
}

typedef HashProbe = ({
  int address,
  int depth,
  int? value,
  bool deleted,
  int offset,
});

class HashStorage {
  HashStorage(this.input);
  final HashInput input;
  // An empty list in an existing open-address slot is a tombstone.
  final cells = <int, List<int>>{};
  bool get chained => input.collision == HashCollision.chain;
  late int _randomState = input.seed % 2147483647 == 0
      ? 1
      : input.seed % 2147483647;
  final _randomOffsets = <int>[0], _shuffle = <int, int>{};
  int randomOffset(int i) {
    // Incremental Fisher–Yates retains the same sequence for every home address.
    while (_randomOffsets.length <= i) {
      final first = _randomOffsets.length;
      _randomState = (_randomState * 48271) % 2147483647;
      final j = first + _randomState % (input.m - first);
      final chosen = _shuffle[j] ?? j,
          replacement = _shuffle.remove(first) ?? first;
      if (j != first) _shuffle[j] = replacement;
      _randomOffsets.add(chosen);
    }
    return _randomOffsets[i];
  }

  int offsetAt(int i) {
    final k = (i + 1) ~/ 2;
    return switch (input.collision) {
      HashCollision.quadratic => i.isOdd ? k * k : -k * k,
      HashCollision.random => randomOffset(i),
      _ => i,
    };
  }

  Iterable<HashProbe> probe(int home, int? target) sync* {
    if (chained) {
      final chain = cells[home] ?? const <int>[];
      for (var i = 0; i < chain.length; i++) {
        yield (
          address: home,
          depth: i,
          value: chain[i],
          deleted: false,
          offset: 0,
        );
        if (chain[i] == target) return;
      }
      yield (
        address: home,
        depth: chain.length,
        value: null,
        deleted: false,
        offset: 0,
      );
      return;
    }
    for (var i = 0; i < input.m; i++) {
      final d = offsetAt(i);
      final addr = (home + d) % input.m,
          cell = cells[addr],
          value = cell?.firstOrNull;
      yield (
        address: addr,
        depth: 0,
        value: value,
        deleted: cell != null && cell.isEmpty,
        offset: d,
      );
      if (cell == null || (value != null && value == target)) return;
    }
  }

  factory HashStorage.fromScene(HashInput input, SceneSnapshot scene) {
    final table = HashStorage(input);
    for (final row in scene.auxTables.first.rows) {
      table.cells[int.parse(row[0])] = row[2].isEmpty
          ? []
          : row[2].split(' ').map(int.parse).toList();
    }
    return table;
  }
  HashAsl analyze() {
    final success = <(int, int, int)>[];
    for (final values in cells.values) {
      for (final key in values) {
        final h = input.hash(key).home!;
        success.add((key, h, probe(h, key).length));
      }
    }
    // An unused home stops at the first check. Only occupied homes and tombstones need a walk.
    final costs = {
      for (final h in cells.keys)
        if (h < input.p) h: probe(h, null).length,
    };
    return HashAsl(success, input.p, costs);
  }
}

class HashAsl {
  const HashAsl(this.success, this.entries, this.costs);
  final List<(int, int, int)> success;
  final int entries;
  final Map<int, int> costs;
  int failureAt(int home) => costs[home] ?? 1;
  int get successSum => success.fold(0, (s, r) => s + r.$3);
  int get failureSum => entries + costs.values.fold(0, (s, c) => s + c - 1);
}

class HashModule implements AlgorithmModule<HashInput> {
  const HashModule();
  @override
  String get id => 'ch7_hash_table';
  @override
  List<AlgorithmPreset<HashInput>> get presets => const [
    AlgorithmPreset(
      id: 'linear73',
      name: '例 7.3 · 表 7.4 与 ASL',
      input: HashInput(),
    ),
    AlgorithmPreset(
      id: 'chain72',
      name: '例 7.2 · 图 7.30 同义词链',
      input: HashInput(collision: HashCollision.chain, m: 13),
    ),
    AlgorithmPreset(
      id: 'linear38',
      name: '图 7.29 · 线性插入 38',
      input: HashInput(m: 11, p: 11, initial: [17, 60, 29], operations: '+38'),
    ),
    AlgorithmPreset(
      id: 'quadratic38',
      name: '图 7.29 · 二次插入 38',
      input: HashInput(
        m: 11,
        p: 11,
        initial: [17, 60, 29],
        operations: '+38',
        collision: HashCollision.quadratic,
      ),
    ),
    AlgorithmPreset(
      id: 'random38',
      name: '图 7.29 · 伪随机插入 38',
      input: HashInput(
        m: 11,
        p: 11,
        initial: [17, 60, 29],
        operations: '+38',
        collision: HashCollision.random,
      ),
    ),
    AlgorithmPreset(
      id: 'tombstone',
      name: '删除标记 · 跨槽查找与复用',
      input: HashInput(
        m: 7,
        p: 5,
        initial: [1, 6, 11],
        operations: '-6 ?11 +11 +16',
      ),
    ),
    AlgorithmPreset(
      id: 'direct',
      name: '直接定址 · 连续编号',
      input: HashInput(
        function: HashFunction.direct,
        base: 100,
        initial: [103, 106, 101],
        operations: '?106 ?104',
      ),
    ),
    AlgorithmPreset(
      id: 'digits',
      name: '数字分析 · 八位关键字选位',
      input: HashInput(
        function: HashFunction.digits,
        m: 100,
        p: 100,
        digits: [5, 4],
        initial: [81346532, 81372242],
        operations: '?81346532',
      ),
    ),
    AlgorithmPreset(
      id: 'square',
      name: '表 7.2 · 平方取中',
      input: HashInput(
        function: HashFunction.square,
        m: 1000,
        p: 1000,
        initial: [9040101, 9040202, 24090403, 25090404],
        operations: '?9040101',
      ),
    ),
    AlgorithmPreset(
      id: 'fold',
      name: '图 7.28 · 折叠 45387765213',
      input: HashInput(
        function: HashFunction.fold,
        m: 1000,
        p: 1000,
        initial: [],
        operations: '+45387765213',
      ),
    ),
  ];
  @override
  ValidationResult<HashInput> validateInput(String raw) {
    final v = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return v == null
        ? const ValidationResult.failure('请选择散列表预设。')
        : ValidationResult.success(v.input);
  }

  @override
  TraceTimeline generateTrace(HashInput input) {
    input.validate();
    return _HashRun(input, id).record();
  }
}
