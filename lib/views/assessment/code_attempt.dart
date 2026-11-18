import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/assessment/algorithm_code_judge.dart';
import '../../models/quiz_question.dart';
import '../../providers/app_providers.dart';
import 'question_detail.dart';
import 'function_attempt.dart';

class CodeAttempt extends StatefulWidget {
  const CodeAttempt({super.key, required this.question});
  final CodeQuestion question;
  @override
  State<CodeAttempt> createState() => _CodeAttemptState();
}

class _CodeAttemptState extends State<CodeAttempt> {
  bool? fullFunction;
  @override
  Widget build(BuildContext context) {
    final full = fullFunction ?? MediaQuery.sizeOf(context).width >= 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('关键行填空')),
            ButtonSegment(value: true, label: Text('完整函数')),
          ],
          selected: {full},
          onSelectionChanged: (s) => setState(() => fullFunction = s.single),
        ),
        const SizedBox(height: 16),
        Visibility(
          visible: !full,
          maintainState: true,
          child: _BlankAttempt(question: widget.question),
        ),
        Visibility(
          visible: full,
          maintainState: true,
          child: FunctionAttempt(question: widget.question),
        ),
      ],
    );
  }
}

class _BlankAttempt extends ConsumerStatefulWidget {
  const _BlankAttempt({required this.question});
  final CodeQuestion question;
  @override
  ConsumerState<_BlankAttempt> createState() => _BlankAttemptState();
}

class _BlankAttemptState extends ConsumerState<_BlankAttempt> {
  CodeQuestion get q => widget.question;
  late final fields = [for (final _ in q.blanks) TextEditingController()];
  final clock = Stopwatch()..start();
  List<bool>? result;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  String get frame {
    var template = q.template;
    for (final (i, blank) in q.blanks.indexed) {
      template = template.replaceFirst(blank.marker, '【${i + 1}】');
    }
    return template;
  }

  Future<void> submit() async {
    if (saving || result != null) return;
    final answers = [for (final f in fields) f.text];
    if (answers.any((a) => a.trim().isEmpty)) return;
    final grades = AlgorithmCodeJudge.gradeBlanks(q, answers);
    final passed = grades.where((g) => g).length;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(quizRepositoryProvider)
          .recordAttempt(
            questionId: q.id,
            chapterId: q.chapterId,
            type: q.type,
            isCorrect: passed == grades.length,
            score: (passed * 100 / grades.length).round(),
            answer: {
              'mode': 'blanks',
              'answers': answers,
              'correctBlanks': grades,
            },
            durationMs: clock.elapsedMilliseconds,
            quality: passed == grades.length ? 4 : 1,
          );
      clock.stop();
      if (mounted) setState(() => result = grades);
    } catch (e) {
      if (mounted) setState(() => error = '保存失败，可重新提交。$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void retry() => setState(() {
    for (final field in fields) {
      field.clear();
    }
    result = null;
    error = null;
    clock
      ..reset()
      ..start();
  });

  @override
  Widget build(BuildContext context) {
    final grades = result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('类 C 关键行补全', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        QuizText('\x60\x60\x60c\n$frame\n\x60\x60\x60'),
        const SizedBox(height: 12),
        for (final (i, field) in fields.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              key: ValueKey('code-blank-$i'),
              controller: field,
              readOnly: saving || grades != null,
              minLines: 1,
              maxLines: 6,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(fontFamily: 'JetBrainsMono'),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '第 ${i + 1} 空',
                border: const OutlineInputBorder(),
                helperText: grades != null && grades[i] ? '正确' : null,
                errorText: grades != null && !grades[i]
                    ? '参考写法：${q.blanks[i].acceptedAnswers.first}'
                    : null,
                errorMaxLines: 8,
              ),
            ),
          ),
        if (error != null) Text(error!),
        if (grades == null)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: saving || fields.any((f) => f.text.trim().isEmpty)
                  ? null
                  : submit,
              child: Text(saving ? '正在保存' : '提交填空'),
            ),
          )
        else ...[
          Text('答对 ${grades.where((g) => g).length} / ${grades.length} 空'),
          ExpansionTile(
            title: const Text('查看参考作答'),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizText('\x60\x60\x60c\n${q.referenceCode}\n\x60\x60\x60'),
              QuizText(q.explanationMarkdown),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(onPressed: retry, child: const Text('重新作答')),
          ),
        ],
      ],
    );
  }
}
