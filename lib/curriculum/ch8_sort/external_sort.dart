import 'dart:math';
import 'package:collection/collection.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'sort_records.dart';
part 'external_runs.dart';
part 'external_run_scene.dart';
part 'optimal_merge.dart';
part 'external_source.dart';

enum ExternalMethod {
  merge('多路归并'),
  replacement('置换选择'),
  optimal('最佳归并树');

  const ExternalMethod(this.label);
  final String label;
}

const figure818 = [
  [10, 15, 16],
  [9, 18, 20],
  [20, 22, 40],
  [6, 15, 25],
  [12, 37, 48],
];
const table81 = [
  51,
  49,
  39,
  46,
  38,
  29,
  14,
  61,
  15,
  30,
  1,
  48,
  52,
  3,
  63,
  27,
  4,
  13,
  89,
  24,
  46,
  58,
  33,
  76,
];
const figure822 = [9, 30, 12, 18, 3, 17, 2, 6, 24];

class ExternalInput {
  const ExternalInput.merge([this.runs = figure818])
    : method = ExternalMethod.merge,
      keys = const [],
      parameter = 0;
  const ExternalInput.replacement([this.keys = table81, this.parameter = 6])
    : method = ExternalMethod.replacement,
      runs = const [];
  const ExternalInput.optimal([this.keys = figure822, this.parameter = 3])
    : method = ExternalMethod.optimal,
      runs = const [];
  final ExternalMethod method;
  final List<List<int>> runs;
  final List<int> keys;
  final int parameter;
  int get width => method == ExternalMethod.merge ? runs.length : parameter;
  int get padding => method != ExternalMethod.optimal || keys.length < 2
      ? 0
      : (width - 1 - (keys.length - 1) % (width - 1)) % (width - 1);
  void validate() {
    if (method == ExternalMethod.replacement && width < 1) {
      throw const FormatException('工作区容量须至少为 1。');
    }
    if (method != ExternalMethod.replacement && width < 2) {
      throw const FormatException('归并路数须至少为 2。');
    }
    if (method == ExternalMethod.optimal && keys.any((w) => w <= 0)) {
      throw const FormatException('实际归并段长度须为正整数。');
    }
    for (var s = 0; s < runs.length; s++) {
      for (var j = 1; j < runs[s].length; j++) {
        if (runs[s][j] < runs[s][j - 1]) {
          throw FormatException('第 ${s + 1} 路须按非降序输入。');
        }
      }
    }
  }

  static ExternalInput parse(
    ExternalMethod method,
    String data,
    String parameter,
  ) {
    final ExternalInput input;
    if (method == ExternalMethod.merge) {
      input = ExternalInput.merge([
        for (final line in data.trim().split(RegExp(r'[;；\n]')))
          parseSortIntegers(line),
      ]);
    } else {
      final value = int.tryParse(parameter.trim());
      if (value == null) throw const FormatException('请输入整数参数。');
      final keys = parseSortIntegers(data);
      input = method == ExternalMethod.replacement
          ? ExternalInput.replacement(keys, value)
          : ExternalInput.optimal(keys, value);
    }
    input.validate();
    return input;
  }
}

class ExternalModule implements AlgorithmModule<ExternalInput> {
  const ExternalModule();
  @override
  String get id => 'ch8_external_sort';
  @override
  List<AlgorithmPreset<ExternalInput>> get presets => const [
    AlgorithmPreset(
      id: 'five',
      name: '图 8.18 · 五路败者树',
      input: ExternalInput.merge(),
    ),
    AlgorithmPreset(
      id: 'wa',
      name: '表 8.1 · 六槽置换选择',
      input: ExternalInput.replacement(),
    ),
    AlgorithmPreset(
      id: 'nine',
      name: '图 8.22 · 九段三路归并',
      input: ExternalInput.optimal(),
    ),
    AlgorithmPreset(
      id: 'eight',
      name: '图 8.23 · 八段补虚段',
      input: ExternalInput.optimal([9, 12, 18, 3, 17, 2, 6, 24], 3),
    ),
    AlgorithmPreset(
      id: 'six',
      name: '六段四路 · 补一个虚段',
      input: ExternalInput.optimal([2, 3, 6, 9, 12, 17], 4),
    ),
  ];
  @override
  ValidationResult<ExternalInput> validateInput(String raw) {
    final p = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择外部排序预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(ExternalInput input) {
    input.validate();
    final b = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${input.method.label} · ${input.width} ${input.method == ExternalMethod.replacement ? "槽" : "路"}',
      codeLines: _source(input.method),
    );
    if (input.method == ExternalMethod.optimal) {
      _Optimal(input, b).run();
    } else {
      final run = _ExternalRuns(input, b);
      if (input.method == ExternalMethod.merge) {
        run.merge();
      } else {
        run.replace();
      }
    }
    return b.build();
  }
}

/// Use the same replacement selector without allocating playback snapshots.
double sampledRunLength(int capacity, {int seed = 81, int count = 4096}) {
  final random = Random(seed);
  final input = ExternalInput.replacement(
    List.generate(count, (_) => random.nextInt(1 << 30)),
    capacity,
  );
  input.validate();
  final run = _ExternalRuns(input, null)..replace();
  return run.output.isEmpty ? 0 : count / run.output.length;
}
