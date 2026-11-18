import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/assessment/pointer_sandbox_judge.dart';
import '../../models/quiz_question.dart';
import '../../providers/app_providers.dart';
import 'pointer_board.dart';

enum _Mode { wire, cards }

class _Step {
  const _Step(this.heap, this.label, {this.card, this.error});
  final PointerHeap heap;
  final String label;
  final int? card;
  final String? error;
}

class PointerSandboxAttempt extends ConsumerStatefulWidget {
  const PointerSandboxAttempt({super.key, required this.question});
  final PointerSandboxQuestion question;
  @override
  ConsumerState<PointerSandboxAttempt> createState() => _AttemptState();
}

class _AttemptState extends ConsumerState<PointerSandboxAttempt> {
  PointerSandboxQuestion get q => widget.question;
  final history = {for (final mode in _Mode.values) mode: <_Step>[]};
  late final start = PointerHeap.initial(q);
  final clock = Stopwatch()..start();
  bool encounteredLeak = false;
  var mode = _Mode.wire;
  List<_Step> get steps => history[mode]!;
  PointerHeap get heap => steps.lastOrNull?.heap ?? start;
  PointerPort? selected;
  bool saving = false, submitted = false;
  String? saveError;
  static const judge = PointerSandboxJudge();
  PointerJudgeResult get grade {
    final error = steps.lastOrNull?.error;
    if (error != null) {
      return PointerJudgeResult(PointerIssue.instruction, error);
    }
    final result = judge.evaluate(q, heap);
    if (result.correct &&
        mode == _Mode.cards &&
        steps.length != q.instructions.length) {
      return const PointerJudgeResult(PointerIssue.instruction, '继续执行剩余指令卡。');
    }
    return result;
  }

  bool get locked => saving || submitted;
  void apply(String label, PointerHeap Function() action, {int? card}) {
    if (locked) return;
    final previous = heap;
    setState(() {
      selected = null;
      try {
        final next = action();
        steps.add(_Step(next, label, card: card));
        if (judge.evaluate(q, next).issue == PointerIssue.leak) {
          encounteredLeak = true;
        }
      } on StateError catch (e) {
        steps.add(_Step(previous, label, card: card, error: e.message));
      }
    });
  }

  void connect(PointerPort port, String? target) => apply(
    '${portName(port)} → ${target ?? "NULL"}',
    () => heap.connect(port.owner, port.field, target),
  );
  void reset() => setState(() {
    for (final run in history.values) {
      run.clear();
    }
    encounteredLeak = false;
    selected = null;
    submitted = false;
    saveError = null;
    clock
      ..reset()
      ..start();
  });
  Future<void> submit() async {
    if (locked || steps.isEmpty) return;
    final result = grade;
    setState(() {
      saving = true;
      saveError = null;
    });
    try {
      await ref
          .read(quizRepositoryProvider)
          .recordAttempt(
            questionId: q.id,
            chapterId: q.chapterId,
            type: q.type,
            isCorrect: result.correct,
            score: result.correct ? 100 : 0,
            answer: {
              'mode': mode.name,
              ...heap.toJson(),
              'steps': [for (final s in steps) s.label],
              if (mode == _Mode.cards) 'order': [for (final s in steps) s.card],
              'issue': result.issue?.name,
              'zeroLeak': !encounteredLeak,
            },
            durationMs: clock.elapsedMilliseconds,
            quality: result.correct ? 4 : 1,
          );
      if (mounted) {
        setState(() {
          submitted = true;
          clock.stop();
        });
      }
    } catch (e) {
      if (mounted) setState(() => saveError = '作答保存失败，可重试。$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = grade,
        started = steps.isNotEmpty,
        colors = Theme.of(context).colorScheme;
    final interrupted =
        started &&
        (steps.last.error != null ||
            result.issue == PointerIssue.leak ||
            result.issue == PointerIssue.dangling);
    final editable = !locked && !interrupted;
    final good = started && result.correct;
    final fault = interrupted || result.issue == PointerIssue.cycle;
    final text = !started ? '初始指针状态' : result.message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<_Mode>(
            segments: const [
              ButtonSegment(value: _Mode.wire, label: Text('端口连线')),
              ButtonSegment(value: _Mode.cards, label: Text('指令排序')),
            ],
            selected: {mode},
            onSelectionChanged: locked
                ? null
                : (s) => setState(() {
                    mode = s.single;
                    selected = null;
                  }),
          ),
        ),
        Text(
          mode == _Mode.wire
              ? '拖动指针端口到目标结点，或先点端口再点结点名称。'
              : '按执行顺序点选指令，每次赋值都会更新下方连接。',
        ),
        PointerBoard(
          question: q,
          heap: heap,
          marked: started ? result.nodes : {},
          selected: selected,
          onSelect: mode == _Mode.wire && editable
              ? (p) => setState(() => selected = selected == p ? null : p)
              : null,
          onConnect: mode == _Mode.wire && editable ? connect : null,
        ),
        if (mode == _Mode.wire && q.deletedNodes.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: PopupMenuButton<String>(
              tooltip: '释放结点',
              enabled: editable,
              itemBuilder: (_) => [
                for (final e in heap.roots.entries)
                  if (e.value != null && heap.live(e.value!))
                    PopupMenuItem(
                      value: e.key,
                      child: Text('free(${e.key}) · ${e.value}'),
                    ),
              ],
              onSelected: (root) => apply(
                'free($root);',
                () => heap.release(heap.roots[root]!, local: root),
              ),
              child: const Chip(
                avatar: Icon(Icons.link_off),
                label: Text('释放结点'),
              ),
            ),
          ),
        if (mode == _Mode.cards)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final (i, card) in q.instructions.indexed.toList().reversed)
                OutlinedButton(
                  key: ValueKey('card-$i'),
                  onPressed: editable && !steps.any((step) => step.card == i)
                      ? () => apply(card, () => heap.execute(card), card: i)
                      : null,
                  child: Text(card),
                ),
            ],
          ),
        if (started)
          Text(
            [
              for (final (i, step) in steps.indexed) '${i + 1}. ${step.label}',
            ].join('　'),
          ),
        Semantics(
          liveRegion: true,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: good
                  ? Colors.green.shade800
                  : fault
                  ? colors.errorContainer
                  : colors.surfaceContainerHigh,
            ),
            child: Row(
              children: [
                Icon(
                  good
                      ? Icons.check_circle
                      : fault
                      ? Icons.warning_amber
                      : Icons.account_tree_outlined,
                  color: good ? Colors.white : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    submitted ? '${good ? 100 : 0} 分 · $text' : text,
                    style: TextStyle(color: good ? Colors.white : null),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (interrupted && !submitted) const Text('撤销上一步可回到操作前的指针状态。'),
        if (submitted) Text(q.explanationMarkdown),
        if (saveError != null) Text(saveError!),
        Wrap(
          spacing: 8,
          children: [
            if (!submitted)
              OutlinedButton.icon(
                onPressed: locked || !started
                    ? null
                    : () => setState(() {
                        steps.removeLast();
                        selected = null;
                      }),
                icon: const Icon(Icons.undo),
                label: const Text('撤销上一步'),
              ),
            if (!submitted)
              FilledButton(
                onPressed: locked || !started ? null : submit,
                child: Text(saving ? '正在保存' : '提交指针图'),
              ),
            if (submitted)
              OutlinedButton(onPressed: reset, child: const Text('重新演练')),
          ],
        ),
      ],
    );
  }
}
