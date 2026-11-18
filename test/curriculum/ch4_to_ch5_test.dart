import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/bf_kmp.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/glist_explorer.dart';
import 'package:fldata/curriculum/ch5_tree/bitree_traverse.dart';
import 'package:fldata/curriculum/ch5_tree/threaded_tree.dart';
import 'package:fldata/curriculum/ch5_tree/huffman_tree.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  test('05.1 one-based links, match offset and circular virus detection', () {
    const module = BfKmpModule();
    expect(failureLinks(SString('abaabcac'), optimized: false).skip(1), [
      0,
      1,
      1,
      2,
      2,
      3,
      1,
      2,
    ]);
    expect(failureLinks(SString('abaabcac'), optimized: true).skip(1), [
      0,
      1,
      0,
      2,
      1,
      3,
      0,
      2,
    ]);
    expect(failureLinks(SString('aaaab'), optimized: true).skip(1), [
      0,
      0,
      0,
      0,
      4,
    ]);
    final match = module
        .generateTrace(
          const MatchInput(text: 'ababcabcacbab', pattern: 'abcac'),
        )
        .frames
        .last;
    expect(match.inlineVars['KMP.result'], '6');
    final absent = module
        .generateTrace(
          const MatchInput(text: 'ababcabcacbab', pattern: 'abaabcac'),
        )
        .frames
        .last;
    expect(absent.inlineVars['KMP.result'], '0');
    for (final (host, expected) in [('abbbaabbb', 'YES'), ('cccc', 'NO')]) {
      final virus = module
          .generateTrace(
            MatchInput(text: host, pattern: 'baa', mode: MatchMode.rotations),
          )
          .frames
          .last;
      expect(virus.inlineVars['感染'], expected);
    }
  });
  test('05.2 length, nesting and Head(Tail(D))', () {
    const d = '((), (e), (a, (b, c, d)))';
    const m = GListModule();
    final base = m.generateTrace(const GListInput(expression: d)).frames.last;
    expect(base.inlineVars['长度'], '3');
    expect(base.inlineVars['深度'], '3');
    final peeled = m
        .generateTrace(
          const GListInput(expression: d, path: [Peel.tail, Peel.head]),
        )
        .frames
        .last;
    expect(peeled.inlineVars['当前值'], '(e)');
  });
  const sequence = 'ABC##DE#G##F###';
  test('05.3 three traversals of the printed preorder tree', () {
    for (final (lesson, output) in [
      (TreeLesson.preorder, 'ABCDEGF'),
      (TreeLesson.inorder, 'CBEGDFA'),
      (TreeLesson.postorder, 'CGEFDBA'),
    ]) {
      final end = const BiTreeModule()
          .generateTrace(TreeInput(sequence: sequence, lesson: lesson))
          .frames
          .last;
      expect(end.inlineVars['输出'], output);
    }
  });
  test('05.4 threaded walk returns to sentinel without a stack', () {
    final trace = const ThreadedTreeModule(
      traversalOnly: true,
    ).generateTrace(const TreeInput(sequence: sequence));
    expect(trace.frames.last.inlineVars['输出'], 'CBEGDFA');
    expect(trace.frames.last.inlineVars['p'], 'Thrt');
    expect(
      trace.frames.every(
        (f) => f.callStack.isEmpty && f.metrics.maxCallDepth == 0,
      ),
      isTrue,
    );
  });
  test(
    '05.5 textbook Huffman depth, weighted path length and prefix property',
    () {
      final t = HuffmanTree.build(textbookWeights);
      expect(t.height, 5);
      expect(t.wpl, BigInt.from(271));
      for (final code in t.codes.values) {
        expect(t.codes.values.where((c) => c.startsWith(code)), [code]);
      }
    },
  );
  test(
    'all 52 textbook exercises have stable IDs, source pages and answers',
    () {
      for (final chapter in [4, 5]) {
        final questions = quizQuestions
            .where((q) => q.chapterId.name == 'ch$chapter')
            .toList();
        expect(questions.length, chapter == 4 ? 25 : 27);
        expect(questions.map((q) => q.id).toSet().length, questions.length);
        for (final (section, count) in [
          (1, 15),
          (2, 4),
          (3, chapter == 4 ? 6 : 8),
        ]) {
          for (var i = 1; i <= count; i++) {
            final q = questionById(
              'textbook_ch${chapter}_${section}_${i.toString().padLeft(2, '0')}',
            )!;
            expect(q.sourceLabel, contains('PDF第'));
            expect(q.sourceLabel, endsWith('第$section题（$i）'));
            if (section == 3) {
              final design = q as CodeQuestion;
              expect(design.testCases.length, 6);
              expect(design.blanks.length, inInclusiveRange(2, 4));
            }
            if (section == 1) {
              expect((q as ChoiceQuestion).options.length, 4);
            }
          }
        }
      }
      final order = questionById('textbook_ch4_1_14')! as ChoiceQuestion;
      expect(order.orderedAnswers.map((i) => order.options[i]), [
        '(a,b,c,d)',
        '()',
      ]);
      final kmp = questionById('textbook_ch4_2_01')! as TraceTableQuestion;
      for (final (i, opt) in [false, true].indexed) {
        expect(
          kmp.answerRows.map((r) => int.parse(r[i])),
          failureLinks(SString('abcaabbabcab'), optimized: opt).skip(1),
        );
      }
      final ht = questionById('textbook_ch5_2_04')! as TraceTableQuestion;
      final t = HuffmanTree.build({
        'A': 3,
        'B': 12,
        'C': 7,
        'D': 4,
        'E': 2,
        'F': 8,
        'G': 11,
      });
      expect(
        ht.answerRows.map((r) => r.sublist(2)),
        t.table
            .skip(1)
            .map(
              (n) => ['${n.weight}', '${n.parent}', '${n.left}', '${n.right}'],
            ),
      );
    },
  );
}
