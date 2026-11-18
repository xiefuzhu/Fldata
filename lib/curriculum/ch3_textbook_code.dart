import 'dart:math';
import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

part 'ch3_textbook_stack_exercises.dart';
part 'ch3_textbook_queue_exercises.dart';
part 'ch3_textbook_recursion_exercises.dart';

final ch3TextbookCode = List<CodeQuestion>.unmodifiable([
  _doubleStack(),
  _palindrome(),
  _sentinelStack(),
  _postfix(),
  _ioSequence(),
  _tailQueue(),
  _tagQueue(),
  _deque(),
  _ackermann(),
  _listStatistics(),
]);

CodeQuestion _design(
  int number, {
  required String title,
  required String topic,
  required String prompt,
  required String explanation,
  required String template,
  required List<String> answers,
  required String dart,
  required List<AlgorithmTestCase> cases,
}) => textbookDesign(
  ChapterId.ch3,
  2,
  number,
  page: number <= 8 ? 85 : 86,
  title: title,
  topic: topic,
  prompt: prompt,
  explanation: explanation,
  template: template,
  answers: answers,
  dart: dart,
  cases: cases,
);

AlgorithmTestCase _example(
  String name,
  Map<String, dynamic> input,
  Object? expected,
) => AlgorithmTestCase(name: name, input: input, expected: expected);

List<int> _randomValues(int seed, int count) {
  final random = Random(seed);
  return List.generate(count, (_) => random.nextInt(101) - 50);
}
