import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';

CodeQuestion textbookDesign(
  ChapterId chapter,
  int section,
  int number, {
  required int page,
  int? endPage,
  required String title,
  required String topic,
  required String prompt,
  required String explanation,
  required String template,
  required List<String> answers,
  required String dart,
  required List<AlgorithmTestCase> cases,
}) {
  final chapterNumber = chapter.name.substring(2);
  final bookPages = endPage == null ? '$page' : '$page～$endPage';
  final pdfPages = endPage == null
      ? '${page + 8}'
      : '${page + 8}～${endPage + 8}';
  var reference = template;
  final blanks = <CodeBlank>[];
  for (final (i, answer) in answers.indexed) {
    final marker = '/*BLANK_${i + 1}*/';
    blanks.add(CodeBlank(marker: marker, acceptedAnswers: [answer]));
    reference = reference.replaceFirst(marker, answer);
  }
  return CodeQuestion(
    id: 'textbook_${chapter.name}_${section}_${number.toString().padLeft(2, '0')}',
    chapterId: chapter,
    title: '第$section题（$number）· $title',
    topic: topic,
    sourceLabel:
        '《数据结构（C语言版）》第2版，ISBN 978-7-115-37950-4，第$chapterNumber章习题，书页$bookPages（PDF第$pdfPages页），第$section题（$number）',
    promptMarkdown: prompt,
    explanationMarkdown: explanation,
    template: template,
    referenceCode: reference,
    dartReferenceCode: dart,
    blanks: blanks,
    testCases: cases,
  );
}
