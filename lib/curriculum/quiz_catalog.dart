import '../models/quiz_question.dart';
import 'pointer_practice.dart';
import 'achievement_practice.dart';
import 'ch1_quiz_seed.dart';
import 'ch1_textbook_questions.dart';
import 'ch2_quiz_seed.dart';
import 'ch2_textbook_questions.dart';
import 'ch2_textbook_code.dart';
import 'ch2_code_quiz_seed.dart';
import 'ch3_quiz_seed.dart';
import 'ch3_textbook_questions.dart';
import 'ch3_textbook_code.dart';
import 'ch4_textbook_questions.dart';
import 'ch4_textbook_code.dart';
import 'ch5_textbook_code.dart';
import 'ch5_textbook_questions.dart';
import 'ch6_textbook_questions.dart';
import 'ch6_textbook_code.dart';
import 'ch7_textbook_questions.dart';
import 'ch7_textbook_code.dart';
import 'ch8_textbook_questions.dart';
import 'ch8_textbook_code.dart';

/// Exercises checked against the numbered questions in the textbook.
final quizQuestions = List<QuizQuestion>.unmodifiable([
  ...ch1TextbookShortAnswers,
  ...ch1TextbookChoices,
  ...ch1TextbookTraces,
  ...ch2TextbookChoices,
  ...ch2TextbookCode,
  ...ch3TextbookChoices,
  ...ch3TextbookCode,
  ...ch4TextbookChoices,
  ...ch4TextbookApplications,
  ...ch4TextbookCode,
  ...ch5TextbookChoices,
  ...ch5TextbookApplications,
  ...ch5TextbookCode,
  ...ch6TextbookChoices,
  ...ch6TextbookApplications,
  ...ch6TextbookCode,
  ...ch7TextbookChoices,
  ...ch7TextbookApplications,
  ...ch7TextbookCode,
  ...ch8TextbookChoices,
  ...ch8TextbookApplications,
  ...ch8TextbookCode,
]);

/// Earlier topic-based drafts retain their IDs for saved references.
const draftQuizQuestions = <QuizQuestion>[
  ...ch1QuizSeed,
  ...ch2QuizSeed,
  ...ch2CodeQuizSeed,
  ...ch3QuizSeed,
];

QuizQuestion? questionById(String id) =>
    quizQuestions.where((q) => q.id == id).firstOrNull ??
    achievementPractice.where((q) => q.id == id).firstOrNull ??
    pointerPractice.values.where((q) => q.id == id).firstOrNull ??
    draftQuizQuestions.where((q) => q.id == id).firstOrNull;
