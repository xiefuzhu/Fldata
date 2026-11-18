import '../../engine/layout/linear_memory_layout.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'sort_records.dart';
part 'merge_run.dart';
part 'radix_run.dart';
part 'merge_radix_source.dart';

enum MergeRadixMethod {
  merge('二路归并'),
  radix('链式基数');

  const MergeRadixMethod(this.label);
  final String label;
}

const mergeExample88 = [49, 38, 65, 97, 76, 13, 27];
const radixFigure815 = [278, 109, 63, 930, 589, 184, 505, 269, 8, 83];

class MergeRadixInput {
  const MergeRadixInput({
    this.method = MergeRadixMethod.merge,
    this.keys = mergeExample88,
    this.bottomUp = false,
  });
  final bool bottomUp;
  final MergeRadixMethod method;
  final List<int> keys;
}

class MergeRadixModule implements AlgorithmModule<MergeRadixInput> {
  const MergeRadixModule();
  @override
  String get id => 'ch8_merge_radix_race';
  @override
  List<AlgorithmPreset<MergeRadixInput>> get presets => const [
    AlgorithmPreset(
      id: 'merge',
      name: '例 8.8 · 七键归并',
      input: MergeRadixInput(),
    ),
    AlgorithmPreset(
      id: 'radix',
      name: '图 8.15 · 三趟分配与收集',
      input: MergeRadixInput(
        method: MergeRadixMethod.radix,
        keys: radixFigure815,
      ),
    ),
  ];
  @override
  ValidationResult<MergeRadixInput> validateInput(String raw) {
    final p = presets.where((v) => v.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择教学预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(MergeRadixInput input) {
    final radix = input.method == MergeRadixMethod.radix;
    if (radix && input.keys.any((key) => key < 0)) {
      throw const FormatException('链式基数排序使用非负十进制整数。');
    }
    final b = TraceBuilder(
      moduleId: id,
      inputSummary: '${input.method.label} · ${input.keys.join(" ")}',
      codeLines: !radix && input.bottomUp ? _passSource : _source(radix),
    );
    final records = SortRecord.tag(input.keys);
    if (radix) {
      _Radix(b, records).run();
    } else if (input.bottomUp) {
      _Merge(b, records, recursive: false).passes();
    } else {
      _Merge(b, records).run();
    }
    return b.build();
  }
}
