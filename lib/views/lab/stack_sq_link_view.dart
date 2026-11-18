import 'dart:async';
import '../../curriculum/ch3_stack_queue/stack_sequence.dart';
import '../../models/quiz_question.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch3_stack_queue/stack_sq_link.dart';
import '../../engine/debugger/call_stack_inspector.dart';
import '../../engine/debugger/code_debugger_pane.dart';
import '../../engine/debugger/memory_table_inspector.dart';
import '../../engine/debugger/playback_transport_bar.dart';
import '../../enum/ds_enums.dart';
import '../../providers/app_providers.dart';
import '../../providers/playback_provider.dart';
import '../../ui/layout/lab_workspace_layout.dart';
import '../../ui/managers/playback_actions.dart';
import 'lesson_visit.dart';
import 'stack_sq_link_stage.dart';

class StackSqLinkView extends ConsumerStatefulWidget {
  const StackSqLinkView({super.key, this.repro});
  final LabDeepLinkPayload? repro;
  @override
  ConsumerState<StackSqLinkView> createState() => _StackSqLinkViewState();
}

class _StackSqLinkViewState extends ConsumerState<StackSqLinkView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<StackInput> {
  static const module = StackSqLinkModule();
  StackInput input = const StackInput();
  bool replaying = false;
  bool foreground = true, visible = true;
  bool desiredComplete = false, desiredWatched = false, completing = false;
  String? saveError;
  final seenFrames = <int>{};
  @override
  late final LessonVisit visit;
  late final Ticker ticker;
  Duration previous = Duration.zero;
  PlaybackController get vm => ref.read(playbackProvider.notifier);
  @override
  void initState() {
    super.initState();
    visit = LessonVisit(
      ref.read(progressRepositoryProvider),
      moduleId: module.id,
      chapterId: ChapterId.ch3,
    );
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((elapsed) {
      final delta = elapsed - previous;
      previous = elapsed;
      vm.advance(delta);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repro = widget.repro;
      if (repro == null) {
        input = initialDataset(context, input);
        vm.load(module.generateTrace(input));
      } else {
        final sequence = StackSequence.fromPreset(repro.presetPayloadJson);
        input = sequence.initial;
        replaying = true;
        vm.load(sequence.trace());
        vm.seek(repro.targetStepIndex.toDouble());
      }
      syncActivity();
      unawaited(saveProgress());
    });
  }

  void syncActivity() {
    final active = foreground && visible;
    if (active) {
      visit.clock.start();
    } else {
      visit.clock.stop();
    }
    if (active && ref.read(playbackProvider).isPlaying) {
      if (!ticker.isActive) {
        previous = Duration.zero;
        ticker.start();
      }
    } else if (ticker.isActive) {
      ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wasVisible = visible;
    visible = TickerMode.valuesOf(context).enabled;
    syncActivity();
    if (wasVisible && !visible) unawaited(saveProgress());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    syncActivity();
    if (!foreground) unawaited(saveProgress());
  }

  @override
  Future<void> saveProgress({
    bool completed = false,
    bool watched = false,
  }) async {
    desiredComplete = desiredComplete || completed;
    desiredWatched = desiredWatched || watched;
    try {
      await visit.save(
        completed: desiredComplete,
        watchedFullTrace: desiredWatched,
      );
      if (mounted) setState(() => saveError = null);
    } catch (error) {
      if (mounted) setState(() => saveError = '学习记录保存失败：$error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    visit.clock.stop();
    unawaited(
      visit
          .save(completed: desiredComplete, watchedFullTrace: desiredWatched)
          .catchError((Object error) {
            debugPrint('学习记录保存失败：$error');
          }),
    );
    super.dispose();
  }

  @override
  void changeInput(StackInput next) {
    setState(() {
      input = next;
      replaying = false;
    });
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<StackInput>(
      context: context,
      builder: (_) => _StackInputDialog(input: input),
    );
    if (mounted && result != null) runCustomInput(result);
  }

  void command(PlaybackCommand command) {
    switch (command) {
      case PlaybackCommand.toggle:
        vm.toggle();
      case PlaybackCommand.stepBack:
        vm.stepBack();
      case PlaybackCommand.stepInto:
        vm.stepInto();
      case PlaybackCommand.nextMilestone:
        vm.nextMilestone();
      case PlaybackCommand.first:
        vm.first();
      case PlaybackCommand.last:
        vm.last();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackProvider);
    ref.listen(studyClockProvider, (old, next) {
      if (old?.hasValue == true && next.hasValue && foreground && visible) {
        unawaited(saveProgress());
      }
    });
    ref.listen(playbackProvider, (old, next) {
      syncActivity();
      if (next.timeline?.moduleId != module.id) return;
      if (!identical(old?.timeline, next.timeline)) seenFrames.clear();
      seenFrames.add(next.frameIndex);
      if (!desiredWatched &&
          seenFrames.length == next.timeline!.frames.length) {
        unawaited(saveProgress(watched: true));
      }
    });
    final timeline = state.timeline;
    final frame = state.currentFrame;
    final completed =
        ref
            .watch(lessonProgressProvider)
            .value
            ?.any((p) => p.moduleId == module.id && p.status == 2) ??
        false;
    if (timeline == null || frame == null || timeline.moduleId != module.id) {
      return const Center(child: CircularProgressIndicator());
    }
    final source = timeline.codeLines[state.language]!;
    final firstLine = frame.activeLines[state.language]!.first;
    final mini = [
      for (var i = firstLine; i <= firstLine + 1 && i <= source.length; i++)
        '$i  ${source[i - 1]}',
    ].join('\n');
    return PlaybackActions(
      onCommand: command,
      child: Focus(
        autofocus: true,
        child: LabWorkspaceLayout(
          toolbar: Row(
            children: [
              if (widget.repro != null)
                IconButton(
                  tooltip: '返回习题',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      final exercise = GoRouterState.of(
                        context,
                      ).uri.queryParameters['exercise'];
                      context.go(
                        exercise == null
                            ? '/assessment'
                            : '/assessment/$exercise',
                      );
                    }
                  },
                ),
              const Text('栈实验室'),
              const SizedBox(width: 12),
              if (replaying)
                TextButton.icon(
                  icon: const Icon(Icons.undo),
                  label: const Text('切换到栈操作'),
                  onPressed: () => changeInput(const StackInput()),
                )
              else ...[
                DropdownButton<StackKind>(
                  key: const ValueKey('stack-kind'),
                  value: input.kind,
                  items: [
                    for (final kind in StackKind.values)
                      DropdownMenuItem(
                        value: kind,
                        child: Text(StackSqLinkModule.kindNames[kind.index]),
                      ),
                  ],
                  onChanged: (kind) {
                    if (kind == null) return;
                    final candidate = input.copyWith(kind: kind);
                    final check = module.validateInput(candidate.raw);
                    if (check.isValid) {
                      runCustomInput(candidate);
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(check.error!)));
                    }
                  },
                ),
                if (input.kind == StackKind.shared)
                  DropdownButton<int>(
                    key: const ValueKey('stack-side'),
                    value: input.stack,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('左栈 0')),
                      DropdownMenuItem(value: 1, child: Text('右栈 1')),
                    ],
                    onChanged: (v) {
                      if (v != null) changeInput(input.copyWith(stack: v));
                    },
                  ),
                DropdownButton<StackOperation>(
                  key: const ValueKey('stack-operation'),
                  value: input.operation,
                  items: [
                    for (final op in StackOperation.values)
                      DropdownMenuItem(
                        value: op,
                        child: Text(StackSqLinkModule.operationNames[op.index]),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      final candidate = input.copyWith(operation: v);
                      final check = module.validateInput(candidate.raw);
                      if (check.isValid) {
                        runCustomInput(candidate);
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(check.error!)));
                      }
                    }
                  },
                ),
                IconButton(
                  key: const ValueKey('stack-input'),
                  tooltip: '编辑栈参数',
                  onPressed: editInput,
                  icon: const Icon(Icons.edit_outlined),
                ),
                PopupMenuButton<int>(
                  key: const ValueKey('stack-preset'),
                  tooltip: '教学预设',
                  icon: const Icon(Icons.dataset_outlined),
                  itemBuilder: (_) => [
                    for (var i = 0; i < module.presets.length; i++)
                      PopupMenuItem(
                        value: i,
                        child: Text(module.presets[i].name),
                      ),
                  ],
                  onSelected: (i) => changeInput(module.presets[i].input),
                ),
              ],
              IconButton(
                key: const ValueKey('lesson-complete'),
                tooltip: completed ? '已标记学完' : '标记已学',
                onPressed: completing
                    ? null
                    : () async {
                        setState(() => completing = true);
                        await saveProgress(completed: true);
                        if (mounted) setState(() => completing = false);
                      },
                icon: Icon(
                  completed ? Icons.check_circle : Icons.check_circle_outline,
                ),
              ),
              if (saveError != null)
                TextButton.icon(
                  onPressed: () => saveProgress(),
                  icon: const Icon(Icons.sync_problem),
                  label: const Text('保存失败，重试'),
                ),
            ],
          ),
          stage: StackSqLinkStage(
            replaySummary: replaying ? timeline.inputSummary : null,
            highlight:
                replaying && state.frameIndex == widget.repro!.targetStepIndex
                ? widget.repro!.highlightReason
                : null,
            frame: frame,
            next:
                timeline.frames[(state.frameIndex + 1).clamp(
                  0,
                  timeline.frames.length - 1,
                )],
            progress: state.subProgress,
            input: input,
          ),
          code: CodeDebuggerPane(
            state: state,
            onLanguageChanged: vm.setLanguage,
            onToggleBreakpoint: vm.toggleBreakpoint,
          ),
          callStack: CallStackInspector(
            timeline: timeline,
            frameIndex: state.frameIndex,
          ),
          memory: MemoryTableInspector(scene: frame.scene),
          theory: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(frame.explanation),
              const SizedBox(height: 16),
              StackTheory(input: input),
              if (saveError != null)
                Text(
                  saveError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          miniCode: SizedBox(
            height: 40 * MediaQuery.textScalerOf(context).scale(1),
            child: Text(
              mini,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          transport: PlaybackTransportBar(
            compact: true,
            state: state,
            onCommand: command,
            onSeek: vm.seek,
            onSpeed: vm.setSpeed,
            onDirection: vm.setDirection,
          ),
        ),
      ),
    );
  }
}

class _StackInputDialog extends StatefulWidget {
  const _StackInputDialog({required this.input});
  final StackInput input;
  @override
  State<_StackInputDialog> createState() => _StackInputDialogState();
}

class _StackInputDialogState extends State<_StackInputDialog> {
  late final fields = [
    TextEditingController(text: widget.input.a.join(', ')),
    TextEditingController(text: widget.input.b.join(', ')),
    TextEditingController(text: '${widget.input.capacity}'),
    TextEditingController(text: '${widget.input.value}'),
  ];
  String? error;
  @override
  void dispose() {
    for (final f in fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('编辑栈参数'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '元素按栈底 → 栈顶输入，每栈最多 10 个 −999～999 整数。容量 1～10；留空表示空栈。Init 总是初始化新空栈，忽略预设元素。',
          ),
          for (final k in [
            0,
            if (widget.input.kind == StackKind.shared) 1,
            if (widget.input.kind != StackKind.linked) 2,
            if (widget.input.operation == StackOperation.push) 3,
          ])
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                key: ValueKey('stack-input-$k'),
                controller: fields[k],
                decoration: InputDecoration(
                  labelText: ['A / 左栈（底→顶）', '右栈（底→顶）', '容量', '入栈值 e'][k],
                ),
              ),
            ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        key: const ValueKey('stack-apply-input'),
        onPressed: () {
          final result = const StackSqLinkModule().validateInput(
            '${widget.input.kind.name}|${widget.input.operation.name}|${fields[2].text}|${widget.input.stack}|${fields[3].text}|${fields[0].text}|${fields[1].text}',
          );
          if (!result.isValid) {
            setState(() => error = result.error);
            return;
          }
          Navigator.pop(context, result.value);
        },
        child: const Text('应用'),
      ),
    ],
  );
}
