import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch2_linear_list/merge_compare.dart';
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
import 'merge_compare_stage.dart';

class MergeCompareView extends ConsumerStatefulWidget {
  const MergeCompareView({super.key});
  @override
  ConsumerState<MergeCompareView> createState() => _MergeCompareViewState();
}

class _MergeCompareViewState extends ConsumerState<MergeCompareView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<MergeInput> {
  static const module = MergeCompareModule();
  MergeInput input = const MergeInput();
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
      chapterId: ChapterId.ch2,
    );
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((elapsed) {
      final delta = elapsed - previous;
      previous = elapsed;
      vm.advance(delta);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      input = initialDataset(context, input);
      vm.load(module.generateTrace(input));
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
  void changeInput(MergeInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<MergeInput>(
      context: context,
      builder: (_) => _MergeInputDialog(input: input),
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
              const Text('线性表合并'),
              const SizedBox(width: 12),
              DropdownButton<MergeOperation>(
                key: const ValueKey('merge-operation'),
                value: input.operation,
                items: [
                  for (final op in MergeOperation.values)
                    DropdownMenuItem(
                      value: op,
                      child: Text(MergeCompareModule.names[op.index]),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    final candidate = input.copyWith(operation: v);
                    final check = module.validateInput(
                      '${v.name}|${candidate.a.join(",")}|${candidate.b.join(",")}',
                    );
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
                key: const ValueKey('merge-input'),
                tooltip: '编辑合并参数',
                onPressed: editInput,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('merge-preset'),
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
          stage: MergeCompareStage(
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
              const MergeComparisonCards(),
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

class _MergeInputDialog extends StatefulWidget {
  const _MergeInputDialog({required this.input});
  final MergeInput input;
  @override
  State<_MergeInputDialog> createState() => _MergeInputDialogState();
}

class _MergeInputDialogState extends State<_MergeInputDialog> {
  late final fields = [
    TextEditingController(text: widget.input.a.join(', ')),
    TextEditingController(text: widget.input.b.join(', ')),
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
    title: const Text('编辑合并输入'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('每表最多 6 个 −99～99 整数；留空为空表。归并输入必须各自非递减；并集输入各自无重复。'),
          for (var k = 0; k < fields.length; k++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                key: ValueKey('merge-input-$k'),
                controller: fields[k],
                decoration: InputDecoration(labelText: ['A 元素', 'B 元素'][k]),
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
        key: const ValueKey('merge-apply-input'),
        onPressed: () {
          final result = const MergeCompareModule().validateInput(
            '${widget.input.operation.name}|${fields[0].text}|${fields[1].text}',
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
