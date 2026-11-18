import '../../models/quiz_question.dart';
import '../../models/trace_model.dart';
import 'sort_records.dart';

const exerciseSortKeys = [12, 2, 16, 30, 28, 10, 16, 20, 6, 18];
final exerciseSortLabels = List<String>.unmodifiable(
  SortRecord.tag(exerciseSortKeys).map((r) => r.label),
);

class TextbookSortPass {
  const TextbookSortPass(this.method, this.module, this.phase, this.index);
  final String method, module, phase;
  final int index;
  factory TextbookSortPass.forRow(TraceTableQuestion q, int row) {
    final label = q.rowLabels[row], method = label.split(' ').first;
    final (module, phase) = switch (method) {
      '直接插入' || '折半插入' || '希尔' => ('ch8_insert_shell', '整趟'),
      '冒泡' => ('ch8_swap_bubble_quick', '整趟'),
      '快排' => ('ch8_swap_bubble_quick', '枢轴归位'),
      '简选' => ('ch8_select_heap', '整趟'),
      '初堆' => ('ch8_select_heap', '建堆完成'),
      '堆排序' => ('ch8_select_heap', '恢复堆'),
      '归并' => ('ch8_merge_radix_race', '整趟'),
      _ => throw ArgumentError.value(label),
    };
    final index = q.rowLabels
        .take(row)
        .where((name) => name.split(' ').first == method)
        .length;
    return TextbookSortPass(method, module, phase, index);
  }
  int target(TraceTimeline timeline) => timeline.frames
      .where((f) => f.inlineVars['阶段'] == phase)
      .elementAt(index)
      .stepIndex;
}
