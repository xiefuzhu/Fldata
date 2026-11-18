import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/features/assessment/algorithm_code_judge.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  test('正式题和历史题的关键行均可得分，每一空独立反馈', () {
    final official = quizQuestions.whereType<CodeQuestion>();
    expect(official.length, 51);
    for (final q in [
      ...official,
      ...draftQuizQuestions.whereType<CodeQuestion>(),
    ]) {
      final answers = [for (final b in q.blanks) b.acceptedAnswers.first];
      expect(
        AlgorithmCodeJudge.gradeBlanks(q, answers),
        everyElement(isTrue),
        reason: q.id,
      );
      answers[0] = '';
      expect(AlgorithmCodeJudge.gradeBlanks(q, answers), [
        false,
        ...List.filled(answers.length - 1, true),
      ]);
    }
  });

  test('指针真值规约只用于条件，保留逻辑优先级', () {
    final eq = CLikeTokenNormalizer.equivalent;
    expect(eq('((p != NULL))', 'p', condition: true), isTrue);
    expect(eq('p!=NULL', 'p'), isFalse);
    expect(
      eq('p && !(p->next)', 'p != NULL && p->next == NULL', condition: true),
      isTrue,
    );
    expect(eq('(a || b) && c', 'a || b && c', condition: true), isFalse);
    expect(eq('!p->next', 'p->next != NULL', condition: true), isFalse);
    expect(eq('a + b != NULL', 'a + b', condition: true), isFalse);
    final q = questionById('textbook_ch2_2_01')! as CodeQuestion;
    final actual = AlgorithmCodeJudge.gradeBlanks(q, [
      'b == NULL || (a != NULL && a -> data <= b -> data)',
      'tail == LA || tail->data == p->data',
      'tail->next=p; /* 接入 */ tail=p; tail->next=NULL;',
    ]);
    expect(actual, [true, false, true]);
  });

  test('独立自增语句可等价，表达式值和字面量保持区别', () {
    final eq = CLikeTokenNormalizer.equivalent;
    expect(eq('i = i + 1;', '++i;', statement: true), isTrue);
    expect(eq('i++', '++i', statement: true), isTrue);
    expect(eq('i++', '++i'), isFalse);
    expect(eq('a[++i]', 'a[i++]', statement: true), isFalse);
    expect(eq('p - > next', 'p->next'), isFalse);
    expect(eq('0 x10', '0x10'), isFalse);
    expect(eq('"a b"', '"ab"'), isFalse);
    expect(eq('"/*x*/"', '""'), isFalse);
    expect(eq('a * (b+c)', 'a*b+c'), isFalse);
    expect(eq('i++', 'i++;', statement: true), isFalse);
  });
}
