import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/pointer_practice.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/features/assessment/pointer_sandbox_judge.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  const judge = PointerSandboxJudge();
  test('教材配套演练与历史双链题的每一步都执行真实指针赋值', () {
    expect(quizQuestions, hasLength(195));
    for (final e in pointerPractice.entries) {
      expect(questionById(e.key), isNotNull);
      expect(questionById(e.value.id), same(e.value));
    }
    for (final q in [
      ...pointerPractice.values,
      ...draftQuizQuestions.whereType<PointerSandboxQuestion>(),
    ]) {
      var heap = PointerHeap.initial(q);
      expect(judge.evaluate(q, heap).correct, isFalse);
      for (final i in q.solutionOrder) {
        heap = heap.execute(q.instructions[i]);
        expect(
          judge.evaluate(q, heap).issue,
          isNot(
            isIn([
              PointerIssue.leak,
              PointerIssue.dangling,
              PointerIssue.cycle,
            ]),
          ),
          reason: q.id,
        );
      }
      expect(judge.evaluate(q, heap).correct, isTrue, reason: q.id);
      expect(heap.deleted, q.deletedNodes);
    }
  });
  test('两条旁路改写可互换，提前释放保留悬空证据，其他别名不能隐式清空', () {
    final q = pointerPractice['textbook_ch2_1_14']!;
    var h = PointerHeap.initial(q);
    for (final i in [1, 0, 2]) {
      h = h.execute(q.instructions[i]);
    }
    expect(judge.evaluate(q, h).correct, isTrue);
    final initial = PointerHeap.initial(q);
    final early = initial.execute('free(p);');
    expect(early.roots['p'], isNull);
    expect(early.next['A'], 'B');
    expect(initial.live('B'), isTrue);
    expect(judge.evaluate(q, early).correct, isFalse);
    expect(() => early.execute('p->next->prior=p->prior;'), throwsStateError);
    final alias = PointerHeap(
      {'B': null},
      {},
      {'p': 'B', 'r': 'B'},
    ).execute('free(p);');
    expect(alias.roots['r'], 'B');
    expect(
      evaluatePointerGraph(
        expectedNextMap: {},
        actualNextMap: alias.next,
        rootPointers: {'B'},
        deletedNodes: {'B'},
      ).issue,
      PointerIssue.dangling,
    );
  });
  test('多根前向 BFS 优先报告孤岛，prior 不持有结点，Floyd 精确定位非头部环', () {
    const next = {'A': 'B', 'B': 'C', 'C': 'B', 'S': null};
    PointerJudgeResult detect(Set<String> roots) => evaluatePointerGraph(
      expectedNextMap: {'A': 'B', 'B': 'C', 'C': null, 'S': null},
      actualNextMap: next,
      actualPriorMap: {'C': 'S'},
      rootPointers: roots,
      deletedNodes: {},
    );
    final leak = detect({'A'});
    expect(leak.issue, PointerIssue.leak);
    expect(leak.nodes, {'S'});
    final cycle = detect({'A', 'S'});
    expect(cycle.issue, PointerIssue.cycle);
    expect(cycle.nodes, {'B', 'C'});
    expect(
      evaluatePointerGraph(
        expectedNextMap: {'A': null},
        actualNextMap: {'A': 'A'},
        rootPointers: {'A'},
        deletedNodes: {},
      ).issue,
      PointerIssue.cycle,
    );
    final q = pointerPractice['textbook_ch2_1_15']!;
    var heap = PointerHeap.initial(q);
    for (final i in [1, 0, 2, 3]) {
      heap = heap.execute(q.instructions[i]);
    }
    expect(judge.evaluate(q, heap).correct, isTrue);
    expect(
      judge.evaluate(q, heap.connect('B', 'prior', 'A')).issue,
      PointerIssue.reciprocal,
    );
    expect(
      judge.evaluate(q, heap.connect(null, 'q', 'A')).issue,
      PointerIssue.roots,
    );
    final tree = pointerPractice['textbook_ch5_3_03']!;
    expect(
      judge
          .evaluate(tree, PointerHeap.initial(tree).connect('C', 'rchild', 'A'))
          .issue,
      PointerIssue.cycle,
    );
  });
}
