import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/quiz_catalog.dart';
import '../../models/quiz_question.dart';
import '../../providers/app_providers.dart';
import 'question_labels.dart';
import 'code_attempt.dart';
import 'trace_table_attempt.dart';
import 'pointer_sandbox_attempt.dart';
import '../../curriculum/pointer_practice.dart';

class QuestionDetail extends StatelessWidget {
  const QuestionDetail({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final q = questionById(id);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/assessment'),
        ),
        title: Text(
          q == null
              ? '习题'
              : '第 ${q.chapterId.index + 1} 章 · ${questionTypeLabels[q.type]}',
        ),
      ),
      body: q == null
          ? const Center(child: Text('未找到这道习题'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          questionHeading(q),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.sourceLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        QuizText(q.promptMarkdown),
                        const SizedBox(height: 16),
                        if (pointerPractice[q.id] case final practice?)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/assessment/${practice.id}'),
                              icon: const Icon(Icons.account_tree_outlined),
                              label: const Text('打开配套指针演练'),
                            ),
                          ),
                        if (q.id == 'textbook_ch1_6_03')
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/assessment/practice_ch1_matrix_sum',
                              ),
                              icon: const Icon(Icons.code),
                              label: const Text('运行配套矩阵求和程序'),
                            ),
                          ),
                        if (q is PointerSandboxQuestion)
                          PointerSandboxAttempt(
                            key: ValueKey(q.id),
                            question: q,
                          )
                        else if (q is CodeQuestion)
                          CodeAttempt(key: ValueKey(q.id), question: q)
                        else if (q is ChoiceQuestion)
                          _ChoiceAttempt(key: ValueKey(q.id), question: q)
                        else if (q is TraceTableQuestion)
                          TraceTableAttempt(key: ValueKey(q.id), question: q)
                        else
                          ExpansionTile(
                            title: const Text('查看参考作答'),
                            childrenPadding: const EdgeInsets.all(12),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [QuizText(q.explanationMarkdown)],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChoiceAttempt extends ConsumerStatefulWidget {
  const _ChoiceAttempt({super.key, required this.question});
  final ChoiceQuestion question;
  @override
  ConsumerState<_ChoiceAttempt> createState() => _ChoiceAttemptState();
}

class _ChoiceAttemptState extends ConsumerState<_ChoiceAttempt> {
  ChoiceQuestion get q => widget.question;
  late final slots = List<int?>.filled(
    q.orderedAnswers.isEmpty ? 1 : q.orderedAnswers.length,
    null,
  );
  final checked = <int>{};
  final clock = Stopwatch()..start();
  bool? correct;
  bool saving = false;
  String? failure;
  bool get multiple => q.orderedAnswers.isEmpty && q.correctIndices.length > 1;
  bool get ready => multiple ? checked.isNotEmpty : !slots.contains(null);
  String letter(int i) => String.fromCharCode(65 + i);
  Future<void> submit() async {
    if (saving || correct != null || !ready) return;
    final answers = multiple
        ? (checked.toList()..sort())
        : slots.cast<int>().toList();
    final passed = q.orderedAnswers.isNotEmpty
        ? listEquals(answers, q.orderedAnswers)
        : setEquals(answers.toSet(), q.correctIndices);
    final duration = clock.elapsedMilliseconds;
    setState(() {
      saving = true;
      failure = null;
    });
    try {
      await ref
          .read(quizRepositoryProvider)
          .recordAttempt(
            questionId: q.id,
            chapterId: q.chapterId,
            type: q.type,
            isCorrect: passed,
            score: passed ? 100 : 0,
            answer: {'indices': answers},
            durationMs: duration,
            quality: passed ? (duration < 5000 ? 5 : 4) : 1,
          );
      clock.stop();
      if (mounted) setState(() => correct = passed);
    } catch (e) {
      if (mounted) setState(() => failure = '作答保存失败，可重新提交。$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void retry() => setState(() {
    slots.fillRange(0, slots.length, null);
    checked.clear();
    correct = null;
    failure = null;
    clock
      ..reset()
      ..start();
  });
  @override
  Widget build(BuildContext context) {
    final locked = saving || correct != null;
    final answer =
        (q.orderedAnswers.isEmpty ? q.correctIndices : q.orderedAnswers)
            .map(letter)
            .join('、');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var s = 0; s < slots.length; s++) ...[
          if (slots.length > 1)
            Text(
              '第 ${s + 1} 空',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          for (final (i, option) in q.options.indexed)
            ListTile(
              key: ValueKey('option-$s-$i'),
              selected: multiple ? checked.contains(i) : slots[s] == i,
              leading: Icon(
                multiple
                    ? (checked.contains(i)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                    : slots[s] == i
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text('${letter(i)}. $option'),
              onTap: locked
                  ? null
                  : () => setState(() {
                      if (multiple) {
                        if (!checked.remove(i)) checked.add(i);
                      } else {
                        slots[s] = i;
                      }
                    }),
            ),
        ],
        if (failure != null) Text(failure!),
        const SizedBox(height: 12),
        if (correct == null)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: locked || !ready ? null : submit,
              child: Text(saving ? '正在保存' : '提交答案'),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correct! ? '回答正确' : '回答有误 · 正确答案 $answer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  QuizText(q.explanationMarkdown),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!correct! && q.reproLab != null)
                        FilledButton.icon(
                          onPressed: () => context.push(
                            Uri(
                              path: '/lab/${q.reproLab!.moduleId}',
                              queryParameters: {'exercise': q.id},
                            ).toString(),
                          ),
                          icon: const Icon(Icons.science_outlined),
                          label: const Text('在顺序栈实验室中运行验证'),
                        ),
                      OutlinedButton(
                        onPressed: retry,
                        child: const Text('重新作答'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The textbook seeds use fenced code, preformatted diagrams and bundled PNGs.
class QuizText extends StatelessWidget {
  const QuizText(this.text, {super.key});
  final String text;
  static final blocks = RegExp(
    r'```[^\n]*\n([\s\S]*?)```|!\[([^\]]*)\]\((assets/quiz/[^)]+)\)',
  );
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    void prose(String s) {
      if (s.trim().isNotEmpty) children.add(SelectableText(s.trim()));
    }

    var start = 0;
    for (final match in blocks.allMatches(text)) {
      prose(text.substring(start, match.start));
      final code = match.group(1);
      if (code != null) {
        children.add(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code.trimRight(),
              style: const TextStyle(fontFamily: 'JetBrainsMono'),
            ),
          ),
        );
      } else {
        children.add(
          Image.asset(
            match.group(3)!,
            semanticLabel: match.group(2),
            fit: BoxFit.scaleDown,
          ),
        );
      }
      start = match.end;
    }
    prose(text.substring(start));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: children,
    );
  }
}
