import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/features/assessment/function_judge.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  test('每份正式与历史参考函数在学生入口实际执行六组用例', () async {
    final questions = [
      ...quizQuestions,
      ...draftQuizQuestions,
    ].whereType<CodeQuestion>();
    expect(questions.length, 61);
    for (final q in questions) {
      final result = await FunctionJudge.run(q.dartReferenceCode, q.testCases);
      expect(result.length, 6);
      for (final (i, c) in result.indexed) {
        expect(
          c.passed,
          isTrue,
          reason: '${q.id}/${q.testCases[i].name} ${c.error ?? c.actual}',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('用户函数改变输出，隔离输入，逐例报告异常与语法错误', () async {
    final q = questionById('textbook_ch8_3_01')! as CodeQuestion;
    const changed = """Object solve(Map<String,dynamic> d) {
      final items = d['keys'] as List;
      if(items.length == 1) throw '单元素';
      items.clear();
      return items;
    }""";
    final results = await FunctionJudge.run(changed, q.testCases);
    expect(results.where((c) => c.passed).length, 1);
    expect(results.first.actual, isEmpty);
    expect(results[1].error, contains('单元素'));
    expect(q.testCases[2].input['keys'], [1, 2, 3]);
    for (final source in [
      'Object solve( {',
      "import 'dart:math'; int solve(d) => 0;",
    ]) {
      final bad = await FunctionJudge.run(source, q.testCases);
      expect(bad.map((x) => x.error), everyElement(isNotNull));
    }
  });
}
