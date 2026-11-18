import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/curriculum/ch8_sort/textbook_sort_pass.dart';
import 'package:fldata/curriculum/ch8_sort/insertion_sort.dart';
import 'package:fldata/curriculum/ch8_sort/exchange_sort.dart';
import 'package:fldata/curriculum/ch8_sort/selection_sort.dart';
import 'package:fldata/curriculum/ch8_sort/merge_radix.dart';
import 'package:fldata/models/quiz_question.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/features/assessment/trace_table_grader.dart';

void main() {
  const grader = TraceTableGrader();
  TraceTableQuestion table(String id) =>
      questionById(id)! as TraceTableQuestion;
  test('正式推演题的参考矩阵满分，漏格、错位和错弧单独计分', () {
    final tables = quizQuestions.whereType<TraceTableQuestion>().toList();
    expect(tables, hasLength(26));
    const critical = {'1→3', '3→2', '2→5', '5→6'};
    for (final q in tables) {
      final rows = [
        for (final row in q.answerRows) [...row],
      ];
      final full = grader.grade(
        q,
        rows,
        edges: q.id == aoeTableId ? critical : {},
      );
      expect(full.score, 100, reason: q.id);
      rows[0][0] = '';
      final partial = grader.grade(
        q,
        rows,
        edges: q.id == aoeTableId ? critical : {},
      );
      expect(partial.hits, full.total - 1, reason: q.id);
      expect(partial.score, lessThan(100));
    }
    final aoe = table(aoeTableId);
    final marked = grader.grade(
      aoe,
      aoe.answerRows,
      edges: {...critical, '1→2'},
    );
    expect((marked.hits, marked.total, marked.edgeSetCorrect), (29, 30, false));
    expect(marked.cells[0][2], isNull);
    expect(marked.cells[7][2], isFalse);
    expect(grader.equivalent('14/8', '1.75'), isTrue);
    expect(grader.equivalent('14/8', '7/0'), isFalse);
    expect(grader.equivalent('∞', 'INF'), isTrue);
    expect(grader.equivalent('a→c→f', 'a -> c -> f'), isTrue);
    expect(grader.equivalent('1 12', '11 2'), isFalse);
    expect(grader.equivalent('16*', '16'), isFalse);
    expect(grader.feedback(table(kmpTableId), 5, 1), contains('T[2]=b'));
  });
  test('八种算法的每一趟都与实验室目标帧一致，保留重复键身份', () {
    final q = table(sortTableId);
    const keys = exerciseSortKeys;
    final timelines = <String, TraceTimeline>{};
    for (final (row, expected) in q.answerRows.indexed) {
      final pass = TextbookSortPass.forRow(q, row);
      final trace = timelines.putIfAbsent(
        pass.method,
        () => switch (pass.method) {
          '直接插入' || '折半插入' || '希尔' => const InsertionModule().generateTrace(
            InsertionInput(
              keys: keys,
              method: switch (pass.method) {
                '希尔' => InsertionMethod.shell,
                '折半插入' => InsertionMethod.binary,
                _ => InsertionMethod.direct,
              },
            ),
          ),
          '快排' || '冒泡' => const ExchangeModule().generateTrace(
            ExchangeInput(
              keys: keys,
              method: pass.method == '快排'
                  ? ExchangeMethod.quick
                  : ExchangeMethod.bubble,
            ),
          ),
          '归并' => const MergeRadixModule().generateTrace(
            const MergeRadixInput(keys: keys, bottomUp: true),
          ),
          _ => const SelectionModule().generateTrace(
            SelectionInput(
              keys: keys,
              method: pass.method == '简选'
                  ? SelectionMethod.simple
                  : SelectionMethod.heap,
            ),
          ),
        },
      );
      final frame = trace.frames[pass.target(trace)];
      final slots = pass.method == '归并'
          ? [
              for (var i = 1; i <= keys.length; i++)
                frame.scene.nodes
                    .singleWhere((n) => n.id == '${frame.inlineVars["目标表"]}$i')
                    .label,
            ]
          : frame.scene.nodes
                .skip(1)
                .take(keys.length)
                .map((n) => n.label)
                .toList();
      expect(slots, expected, reason: q.rowLabels[row]);
    }
  });
}
