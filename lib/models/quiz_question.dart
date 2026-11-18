import '../enum/ds_enums.dart';

/// IDs are stable application references. The source label identifies the
/// textbook exercise or records the origin of a reconstructed draft.
sealed class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.promptMarkdown,
    required this.explanationMarkdown,
    required this.topic,
    this.sourceLabel = '依据附件 08 主题重建；非教材原题逐字录入',
    this.reproLab,
  });
  final String id,
      title,
      promptMarkdown,
      explanationMarkdown,
      topic,
      sourceLabel;
  final ChapterId chapterId;
  final LabDeepLinkPayload? reproLab;
  QuestionType get type;
}

class LabDeepLinkPayload {
  const LabDeepLinkPayload({
    required this.moduleId,
    required this.presetPayloadJson,
    required this.targetStepIndex,
    required this.highlightReason,
  });
  final String moduleId, presetPayloadJson, highlightReason;
  final int targetStepIndex;
}

/// Learners compare their written or drawn response with the worked example.
class ShortAnswerQuestion extends QuizQuestion {
  const ShortAnswerQuestion({
    required super.id,
    required super.chapterId,
    required super.title,
    required super.promptMarkdown,
    required super.explanationMarkdown,
    required super.topic,
    required super.sourceLabel,
  });

  @override
  QuestionType get type => QuestionType.shortAnswer;
}

class ChoiceQuestion extends QuizQuestion {
  const ChoiceQuestion({
    required super.id,
    required super.chapterId,
    required super.title,
    required super.promptMarkdown,
    required super.explanationMarkdown,
    required super.topic,
    super.sourceLabel,
    super.reproLab,
    required this.options,
    required this.correctIndices,
    this.orderedAnswers = const [],
  });
  final List<String> options;
  final Set<int> correctIndices;

  /// Option indices in blank order when the printed question has multiple blanks.
  final List<int> orderedAnswers;
  @override
  QuestionType get type => QuestionType.choice;
}

class TraceTableQuestion extends QuizQuestion {
  const TraceTableQuestion({
    required super.id,
    required super.chapterId,
    required super.title,
    required super.promptMarkdown,
    required super.explanationMarkdown,
    required super.topic,
    super.sourceLabel,
    super.reproLab,
    required this.columns,
    required this.rowLabels,
    required this.answerRows,
  });
  final List<String> columns, rowLabels;
  final List<List<String>> answerRows;
  @override
  QuestionType get type => QuestionType.traceTable;
}

class PointerSandboxQuestion extends QuizQuestion {
  const PointerSandboxQuestion({
    required super.id,
    required super.chapterId,
    required super.title,
    required super.promptMarkdown,
    required super.explanationMarkdown,
    required super.topic,
    super.sourceLabel,
    super.reproLab,
    required this.initialNext,
    required this.expectedNext,
    this.initialPrior = const {},
    this.expectedPrior = const {},
    required this.roots,
    required this.expectedRoots,
    this.deletedNodes = const {},
    this.circular = false,
    this.binaryTree = false,
    this.locals = const {},
    required this.instructions,
    required this.solutionOrder,
  });
  final Map<String, String?> initialNext,
      expectedNext,
      initialPrior,
      expectedPrior;
  final Map<String, String> roots, expectedRoots;
  final Set<String> deletedNodes;
  final bool circular, binaryTree;
  final Set<String> locals;
  final List<String> instructions;
  final List<int> solutionOrder;
  @override
  QuestionType get type => QuestionType.pointerSandbox;
}

class CodeBlank {
  const CodeBlank({required this.marker, required this.acceptedAnswers});
  final String marker;
  final List<String> acceptedAnswers;
}

class AlgorithmTestCase {
  const AlgorithmTestCase({
    required this.name,
    required this.input,
    required this.expected,
  });
  final String name;
  final Map<String, dynamic> input;
  final Object? expected;
}

class CodeQuestion extends QuizQuestion {
  const CodeQuestion({
    required super.id,
    required super.chapterId,
    required super.title,
    required super.promptMarkdown,
    required super.explanationMarkdown,
    required super.topic,
    super.sourceLabel,
    super.reproLab,
    required this.template,
    required this.referenceCode,
    required this.dartReferenceCode,
    required this.blanks,
    required this.testCases,
  });
  final String template, referenceCode;

  /// Executable trusted translation, including a JSON-compatible solve adapter.
  /// This is not an interpreter for student-submitted code.
  final String dartReferenceCode;
  final List<CodeBlank> blanks;
  final List<AlgorithmTestCase> testCases;
  @override
  QuestionType get type => QuestionType.code;
}
