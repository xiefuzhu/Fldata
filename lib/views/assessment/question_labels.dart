import '../../enum/ds_enums.dart';
import '../../models/quiz_question.dart';

const questionTypeLabels = {
  QuestionType.choice: '选择题',
  QuestionType.shortAnswer: '简答题',
  QuestionType.traceTable: '手算推演',
  QuestionType.pointerSandbox: '指针操作',
  QuestionType.code: '算法设计',
};

enum PracticeLevel {
  basic('基础'),
  applied('进阶'),
  comprehensive('综合');

  const PracticeLevel(this.label);
  final String label;
}

// Project practice levels, independent of the textbook's numbering.
PracticeLevel practiceLevel(QuizQuestion q) {
  const appliedChoices = {
    'textbook_ch3_1_01',
    'textbook_ch3_1_10',
    'textbook_ch4_1_13',
    'textbook_ch4_1_14',
    'textbook_ch6_1_05',
    'textbook_ch6_1_13',
    'textbook_ch6_1_14',
    'textbook_ch7_1_04',
    'textbook_ch7_1_07',
    'textbook_ch7_1_14',
    'textbook_ch8_1_07',
    'textbook_ch8_1_11',
  };
  if (appliedChoices.contains(q.id)) return PracticeLevel.applied;
  if (q is ChoiceQuestion || q is ShortAnswerQuestion) {
    return PracticeLevel.basic;
  }
  if (q is CodeQuestion ||
      q.id == 'textbook_ch6_2_04' ||
      q.id == 'textbook_ch6_2_05' ||
      q.id == 'textbook_ch7_2_03' ||
      q.id == 'textbook_ch8_2_01' ||
      q.id == 'textbook_ch8_2_03') {
    return PracticeLevel.comprehensive;
  }
  return PracticeLevel.applied;
}

String questionHeading(QuizQuestion q) =>
    q.title.contains(q.topic) ? q.title : '${q.title} · ${q.topic}';
