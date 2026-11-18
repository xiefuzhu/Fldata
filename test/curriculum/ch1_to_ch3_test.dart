import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/quiz_question.dart';
import 'package:fldata/curriculum/ch2_linear_list/sqlist_ops.dart';
import 'package:fldata/curriculum/ch2_linear_list/linklist_ops.dart';
import 'package:fldata/curriculum/ch2_linear_list/cases_polyn_book.dart'
    as polynomial;
import 'package:fldata/curriculum/ch3_stack_queue/recursion_hanoi.dart';
import 'package:fldata/curriculum/ch3_stack_queue/queue_sq_link.dart';
import 'package:fldata/curriculum/ch3_stack_queue/cases_expr_dance.dart'
    as applications;
import 'package:fldata/models/trace_model.dart';

// Acceptance examples from .doc/04, kept together as the Stage 2 contract.
List<SceneNode> chain(SceneSnapshot scene, String root) {
  final nodes = {for (final n in scene.nodes) n.id: n};
  final next = {for (final e in scene.edges) e.fromNodeId: e.toNodeId};
  final result = <SceneNode>[], seen = <String>{};
  var p = root;
  while (p != nullNodeId) {
    expect(seen.add(p), isTrue, reason: 'unexpected cycle at $p');
    final n = nodes[p]!;
    expect(n.isDeleted, isFalse);
    result.add(n);
    p = next[p] ?? nullNodeId;
  }
  return result;
}

void main() {
  test('chapters one to three index all 66 numbered textbook exercises', () {
    final chapterIds = [ChapterId.ch1, ChapterId.ch2, ChapterId.ch3];
    final questions = quizQuestions
        .where((q) => chapterIds.contains(q.chapterId))
        .toList();
    final expected = <String>{
      for (var i = 1; i <= 4; i++) 'textbook_ch1_$i',
      for (final group in [5, 6])
        for (var i = 1; i <= 6; i++) 'textbook_ch1_${group}_0$i',
      for (final chapter in [2, 3])
        for (final (group, count) in [(1, 15), (2, 10)])
          for (var i = 1; i <= count; i++)
            'textbook_ch${chapter}_${group}_${i.toString().padLeft(2, '0')}',
    };
    expect(questions.length, 66);
    expect(questions.map((q) => q.id).toSet(), expected);
    for (final q in questions) {
      expect(questionById(q.id), same(q));
      expect(q.sourceLabel, contains('978-7-115-37950-4'));
      expect(q.sourceLabel, contains('PDF第'));
    }
    expect(questions.whereType<CodeQuestion>().length, 20);
    expect(
      draftQuizQuestions.map((q) => q.id).toSet().intersection(expected),
      isEmpty,
    );
  });

  test('04.1 sequential list full insertion and illegal deletions', () {
    const module = SqListModule();
    final full = module
        .generateTrace(const SqListInput(capacity: 4))
        .frames
        .last;
    expect(full.inlineVars['result'], 'OVERFLOW');
    expect(full.isErrorState, isTrue);
    expect(full.metrics.writes, 0);
    for (final i in [0, 5]) {
      final deleted = module.generateTrace(
        SqListInput(operation: SqListOperation.delete, position: i),
      );
      expect(deleted.frames.last.inlineVars['result'], 'ERROR');
      expect(deleted.frames.last.metrics.writes, 0);
      expect(deleted.frames.last.scene.nodes, deleted.frames.first.scene.nodes);
    }
  });
  test(
    '04.2 linked insertion adds one reachable node; wrong ordering loses suffix',
    () {
      const module = LinkListModule();
      final normal = module.generateTrace(const LinkListInput(position: 2));
      expect(
        chain(normal.frames.last.scene, 'head').length,
        chain(normal.frames.first.scene, 'head').length + 1,
      );
      expect(
        chain(normal.frames.last.scene, 'head').skip(1).map((n) => n.label),
        ['A', 'X', 'B', 'C', 'D'],
      );
      expect(
        normal.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
        isFalse,
      );
      final wrong = module.generateTrace(
        const LinkListInput(position: 2, wrongOrder: true),
      );
      final lost = wrong.frames.firstWhere(
        (f) => f.scene.nodes.any((n) => n.isOrphanLeak),
      );
      expect(lost.isErrorState, isTrue);
      expect(
        lost.scene.nodes
            .where((n) => n.isOrphanLeak)
            .map((n) => n.label)
            .toSet(),
        {'B', 'C', 'D'},
      );
    },
  );
  test(
    '04.3 polynomial cancellation leaves exact four terms and frees both x8 nodes',
    () {
      final t = const polynomial.CasesPolynBookModule().generateTrace(
        const polynomial.CasesInput(),
      );
      final last = t.frames.last.scene,
          terms = chain(last, 'a-head').skip(1).toList();
      expect(last.auxTables.first.rows.first[1], '7 + 11x + 22x^7 + 5x^17');
      expect(terms.length, 4);
      final heap = last.auxTables.singleWhere((a) => a.id == 'heap').rows;
      expect(
        [
          for (final n in terms)
            heap.singleWhere((r) => r[0] == n.id).sublist(2, 4),
        ],
        [
          ['7', '0'],
          ['11', '1'],
          ['22', '7'],
          ['5', '17'],
        ],
      );
      for (final id in ['a-2', 'b-2']) {
        expect(last.nodes.singleWhere((n) => n.id == id).isDeleted, isTrue);
        expect(terms.any((n) => n.id == id), isFalse);
      }
    },
  );
  test('04.4 three-disk Hanoi has exactly seven legal moves', () {
    final t = const RecursionHanoiModule().generateTrace(
      const RecursionInput(n: 3),
    );
    final moved = t.frames.where((f) => f.isKeyMilestone).toList();
    expect(moved.length, 7);
    expect(t.frames.last.metrics.moves, 7);
    List<List<int>> pegs(TraceFrame f) => [
      for (final r in f.scene.auxTables.singleWhere((a) => a.id == 'pegs').rows)
        r[1].isEmpty ? [] : r[1].split(',').map(int.parse).toList(),
    ];
    var previous = pegs(t.frames.first);
    for (final frame in moved) {
      final current = pegs(frame);
      expect(current.expand((p) => p).toList()..sort(), [1, 2, 3]);
      for (final peg in current) {
        for (var i = 1; i < peg.length; i++) {
          expect(peg[i - 1], greaterThan(peg[i]));
        }
      }
      final from = [
        for (var i = 0; i < 3; i++)
          if (current[i].length < previous[i].length) i,
      ].single;
      final to = [
        for (var i = 0; i < 3; i++)
          if (current[i].length > previous[i].length) i,
      ].single;
      expect(current[to].last, previous[from].last);
      previous = current;
    }
    expect(previous, [
      [],
      [],
      [3, 2, 1],
    ]);
    expect(t.frames.last.callStack, isEmpty);
  });
  test(
    '04.5 five-slot ring reserves one slot; linked deletion resets rear before free',
    () {
      const module = QueueSqLinkModule();
      final fill = module
          .generateTrace(
            const QueueInput(capacity: 5, values: [1, 2, 3], value: 4),
          )
          .frames
          .last;
      expect(fill.scene.auxTables.first.rows.first[4], '4');
      expect(fill.isErrorState, isFalse);
      final full = module
          .generateTrace(
            const QueueInput(capacity: 5, values: [1, 2, 3, 4], value: 5),
          )
          .frames
          .last;
      expect(full.isErrorState, isTrue);
      expect(full.metrics.writes, 0);
      expect(full.scene.auxTables.first.rows.first[4], '4');
      final t = module.generateTrace(
        const QueueInput(
          kind: QueueKind.linked,
          operation: QueueOperation.dequeue,
          values: [42],
        ),
      );
      final reset = t.frames.firstWhere(
        (f) => f.phaseTitle.startsWith('rear = front'),
      );
      final free = t.frames.firstWhere((f) => f.phaseTitle == '释放 p');
      expect(reset.stepIndex, lessThan(free.stepIndex));
      final scene = t.frames.last.scene;
      expect(
        scene.pointers.singleWhere((p) => p.id == 'front').targetNodeId,
        'head',
      );
      expect(
        scene.pointers.singleWhere((p) => p.id == 'rear').targetNodeId,
        'head',
      );
      expect(chain(scene, 'head').length, 1);
    },
  );
  test('04.6 operator precedence textbook expressions yield 15 and 8', () {
    const module = applications.CasesExprDanceModule();
    for (final entry in {'3*(7-2)#': '15', '4+2*3-10/5#': '8'}.entries) {
      final t = module.generateTrace(applications.CasesInput(text: entry.key));
      expect(t.frames.any((f) => f.isErrorState), isFalse);
      expect(t.frames.last.scene.auxTables.first.rows.first[1], entry.value);
    }
  });
}
