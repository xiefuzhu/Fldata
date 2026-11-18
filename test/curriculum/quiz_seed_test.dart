import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/curriculum/ch3_stack_queue/cases_expr_dance.dart';
import 'package:fldata/curriculum/ch3_stack_queue/cases_trace.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  test('chapter three stack choices agree with a LIFO simulation', () {
    final choices = quizQuestions
        .whereType<ChoiceQuestion>()
        .where((q) => q.chapterId == ChapterId.ch3)
        .toList();
    expect(choices.map((q) => q.correctIndices.single), [
      2,
      2,
      3,
      0,
      0,
      3,
      0,
      1,
      2,
      3,
      3,
      3,
      1,
      2,
      1,
    ]);
    expect(choices[4].sourceLabel, contains('书页83～84（PDF第91～92页）'));
    expect(choices[14].sourceLabel, contains('书页84～85（PDF第92～93页）'));
    int? requiredCapacity(List<int> output) {
      var next = 1, peak = 0;
      final stack = <int>[];
      for (final value in output) {
        while (next <= value) {
          stack.add(next++);
          if (stack.length > peak) peak = stack.length;
        }
        if (stack.isEmpty || stack.removeLast() != value) return null;
      }
      return peak;
    }

    final first = choices.first;
    for (final (i, option) in first.options.indexed) {
      expect(
        requiredCapacity(option.split('，').map(int.parse).toList()) == null,
        first.correctIndices.contains(i),
      );
    }
    final capacity = choices[7];
    final order = RegExp(r'e([1-6])')
        .allMatches(capacity.promptMarkdown.split('出队的序列是').last)
        .map((m) => int.parse(m[1]!))
        .toList();
    expect(
      requiredCapacity(order),
      int.parse(capacity.options[capacity.correctIndices.single]),
    );
  });

  test('chapter two design fixtures satisfy the printed input domains', () {
    final code = quizQuestions
        .whereType<CodeQuestion>()
        .where((q) => q.chapterId == ChapterId.ch2)
        .toList();
    expect(code.length, 10);
    for (final (i, q) in code.indexed) {
      final number = i + 1;
      expect(q.id, 'textbook_ch2_2_${number.toString().padLeft(2, '0')}');
      expect(q.sourceLabel, endsWith('书页53（PDF第61页），第2题（$number）'));
      for (final c in q.testCases) {
        if ([1, 3, 4, 8].contains(number)) {
          for (final key in number == 8 ? ['a'] : ['a', 'b']) {
            final values = (c.input[key] as List).cast<int>();
            for (var j = 1; j < values.length; j++) {
              expect(
                values[j],
                greaterThan(values[j - 1]),
                reason: '${q.id} ${c.name}',
              );
            }
          }
        }
        if (number == 5) expect(c.input['a'], isNot(contains(0)));
      }
    }
  });

  test(
    'chapter two choices preserve original numbers, including the page break',
    () {
      final choices = quizQuestions
          .whereType<ChoiceQuestion>()
          .where((q) => q.chapterId == ChapterId.ch2)
          .toList();
      expect(choices.map((q) => q.correctIndices.single), [
        1,
        0,
        1,
        0,
        3,
        1,
        2,
        0,
        1,
        3,
        2,
        3,
        3,
        0,
        2,
      ]);
      for (var i = 0; i < choices.length; i++) {
        final number = i + 1;
        final q = choices[i];
        expect(q.id, 'textbook_ch2_1_${number.toString().padLeft(2, '0')}');
        expect(q.sourceLabel, endsWith('第1题（$number）'));
        expect(q.options.length, 4);
      }
      expect(choices[4].sourceLabel, contains('书页51～52（PDF第59～60页）'));
    },
  );

  test('chapter one follows the printed numbering across all three pages', () {
    final chapter = quizQuestions
        .where((q) => q.chapterId == ChapterId.ch1)
        .toList();
    expect(chapter.map((q) => q.id), [
      for (var i = 1; i <= 4; i++) 'textbook_ch1_$i',
      for (var i = 1; i <= 6; i++) 'textbook_ch1_5_0$i',
      for (var i = 1; i <= 6; i++) 'textbook_ch1_6_0$i',
    ]);
    final short = chapter.whereType<ShortAnswerQuestion>().toList();
    expect(short.length, 4);
    expect(short[2].promptMarkdown, contains('画出'));
    final rows = chapter.whereType<TraceTableQuestion>().toList();
    expect(rows.map((q) => q.answerRows.single.last), [
      'O(1)',
      'O(nm)',
      'O(n²)',
      'O(log n)',
      'O(n²)',
      'O(√n)',
    ]);
    for (var i = 0; i < chapter.length; i++) {
      final page = i < 2
          ? 16
          : i < 14
          ? 17
          : 18;
      expect(chapter[i].sourceLabel, contains('书页$page（PDF第${page + 8}页）'));
    }
  });

  test(
    'textbook choices retain the six original numbers, pages and option keys',
    () {
      final choices = quizQuestions
          .whereType<ChoiceQuestion>()
          .where((q) => q.chapterId == ChapterId.ch1)
          .toList();
      expect(choices.length, 6);
      expect(choices.map((q) => q.correctIndices.single), [2, 2, 1, 3, 3, 0]);
      for (var i = 0; i < choices.length; i++) {
        final q = choices[i];
        expect(q.id, 'textbook_ch1_5_0${i + 1}');
        expect(q.sourceLabel, contains('书页17（PDF第25页），第5题（${i + 1}）'));
        expect(q.options.length, 4);
        expect(questionById(q.id), same(q));
        expect(draftQuizQuestions.any((draft) => draft.id == q.id), isFalse);
      }
    },
  );

  test(
    'installed seed inventory has unique stable IDs and explicit provenance',
    () {
      expect(draftQuizQuestions.length, 58);
      expect(draftQuizQuestions.map((q) => q.id).toSet().length, 58);
      expect(
        [
          for (final c in [ChapterId.ch1, ChapterId.ch2, ChapterId.ch3])
            draftQuizQuestions.where((q) => q.chapterId == c).length,
        ],
        [12, 29, 17],
      );
      expect(draftQuizQuestions.whereType<ChoiceQuestion>().length, 36);
      expect(draftQuizQuestions.whereType<TraceTableQuestion>().length, 10);
      expect(draftQuizQuestions.whereType<PointerSandboxQuestion>().length, 2);
      expect(draftQuizQuestions.whereType<CodeQuestion>().length, 10);
      for (final q in draftQuizQuestions) {
        expect(q.promptMarkdown, isNotEmpty);
        expect(q.explanationMarkdown, isNotEmpty);
        expect(q.topic, isNotEmpty);
        expect(q.sourceLabel, contains('重建'));
        expect(q.sourceLabel, contains('非教材原题'));
        expect(questionById(q.id), same(q));
      }
      expect(questionById('missing'), isNull);
    },
  );
  test('choice answers and table dimensions are internally consistent', () {
    for (final q in draftQuizQuestions) {
      if (q is ChoiceQuestion) {
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndices, isNotEmpty);
        expect(
          q.correctIndices.every((i) => i >= 0 && i < q.options.length),
          isTrue,
        );
      }
      if (q is TraceTableQuestion) {
        expect(q.answerRows.length, q.rowLabels.length, reason: q.id);
        expect(
          q.answerRows.every(
            (r) => r.length == q.columns.length && r.every((v) => v.isNotEmpty),
          ),
          isTrue,
          reason: q.id,
        );
      }
    }
  });
  test('six complexity worksheet counts match concrete loop execution', () {
    const n = 8;
    final counts = <int>[];
    var count = 0;
    for (var i = 0; i < 100; i++) {
      for (var j = 0; j < 10; j++) {
        count++;
      }
    }
    counts.add(count);
    count = 0;
    for (var i = 0; i < n; i++) {
      count++;
    }
    counts.add(count);
    count = 0;
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        count++;
      }
    }
    counts.add(count);
    count = 0;
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= i; j++) {
        count++;
      }
    }
    counts.add(count);
    count = 0;
    for (var i = 1; i <= n; i *= 2) {
      count++;
    }
    counts.add(count);
    count = 0;
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= i; j *= 2) {
        count++;
      }
    }
    counts.add(count);
    for (var i = 0; i < 6; i++) {
      final q =
          questionById('ch1_trace_${(i + 1).toString().padLeft(2, '0')}')!
              as TraceTableQuestion;
      expect(int.parse(q.answerRows.single.first), counts[i], reason: q.id);
    }
  });
  test('all 24 stack permutations are covered, with exactly 14 realizable', () {
    final q = questionById('ch3_trace_02')! as TraceTableQuestion;
    expect(q.rowLabels.length, 24);
    expect(q.rowLabels.toSet().length, 24);
    var legal = 0;
    for (var i = 0; i < q.rowLabels.length; i++) {
      final desired = q.rowLabels[i].split(' ').map(int.parse).toList();
      expect(desired.toSet(), {1, 2, 3, 4});
      final stack = <int>[];
      var next = 1, valid = true;
      for (final value in desired) {
        while ((stack.isEmpty || stack.last != value) && next <= 4) {
          stack.add(next++);
        }
        if (stack.isEmpty || stack.last != value) {
          valid = false;
          break;
        }
        stack.removeLast();
      }
      if (valid) legal++;
      expect(q.answerRows[i].single, valid ? '是' : '否', reason: q.rowLabels[i]);
    }
    expect(legal, 14);
  });
  test(
    'expression worksheet stack states agree with executable lesson trace',
    () {
      final q = questionById('ch3_trace_01')! as TraceTableQuestion;
      final trace = const CasesExprDanceModule().generateTrace(
        const CasesInput(),
      );
      final titles = [
        '操作数 3 入 OPND',
        '算符 * 入 OPTR',
        '算符 ( 入 OPTR',
        '操作数 7 入 OPND',
        '算符 - 入 OPTR',
        '操作数 2 入 OPND',
        '⑤ 结果压回 OPND',
        '脱去一对圆括号',
        '⑤ 结果压回 OPND',
        '求值完成：15',
      ];
      var cursor = 0;
      for (var i = 0; i < titles.length; i++) {
        while (trace.frames[cursor].phaseTitle != titles[i]) {
          cursor++;
        }
        final frame = trace.frames[cursor++];
        final optr = frame.scene.auxTables[2].rows.map((r) => r[1]).join(' ');
        final opnd = frame.scene.auxTables[3].rows
            .map((r) => caseNumber(double.parse(r[1])))
            .join(' ');
        expect(q.answerRows[i].take(2), [optr, opnd], reason: titles[i]);
      }
      final numbers = <int>[];
      for (final token in q.answerRows.last.last.split(' ')) {
        final n = int.tryParse(token);
        if (n != null) {
          numbers.add(n);
          continue;
        }
        final b = numbers.removeLast(), a = numbers.removeLast();
        numbers.add(token == '-' ? a - b : a * b);
      }
      expect(numbers, [15]);
    },
  );
  test(
    'pointer exercise target graphs preserve bidirectional cycles and deletion ownership',
    () {
      for (final q in draftQuizQuestions.whereType<PointerSandboxQuestion>()) {
        expect(q.solutionOrder.toSet(), {
          for (var i = 0; i < q.instructions.length; i++) i,
        });
        expect(
          q.expectedRoots.values.every(q.expectedNext.containsKey),
          isTrue,
        );
        expect(
          q.deletedNodes.intersection(q.expectedNext.keys.toSet()),
          isEmpty,
        );
        for (final edge in q.expectedNext.entries) {
          expect(q.expectedPrior[edge.value], edge.key, reason: q.id);
        }
        final seen = <String>{};
        var current = q.expectedRoots['L']!;
        while (seen.add(current)) {
          current = q.expectedNext[current]!;
        }
        expect(current, 'H');
        expect(seen, q.expectedNext.keys.toSet());
      }
    },
  );
}
