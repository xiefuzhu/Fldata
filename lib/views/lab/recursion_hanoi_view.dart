import 'dart:async';
import 'package:flutter/material.dart';
import 'badge_event.dart';
import '../../models/study_badge.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch3_stack_queue/recursion_hanoi.dart';
import '../../engine/debugger/code_debugger_pane.dart';
import '../../engine/debugger/memory_table_inspector.dart';
import '../../engine/debugger/playback_transport_bar.dart';
import '../../enum/ds_enums.dart';
import '../../providers/app_providers.dart';
import '../../providers/playback_provider.dart';
import '../../ui/layout/lab_workspace_layout.dart';
import '../../ui/managers/playback_actions.dart';
import 'lesson_visit.dart';
import 'recursion_hanoi_stage.dart';

class RecursionHanoiView extends ConsumerStatefulWidget {
  const RecursionHanoiView({super.key});
  @override
  ConsumerState<RecursionHanoiView> createState() => _RecursionHanoiViewState();
}

class _RecursionHanoiViewState extends ConsumerState<RecursionHanoiView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<RecursionInput> {
  static const module = RecursionHanoiModule();
  RecursionInput input = const RecursionInput();
  RecursionInput? fiveDisks;
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
  void changeInput(RecursionInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<RecursionInput>(
      context: context,
      builder: (_) => _RecursionInputDialog(input: input),
    );
    if (mounted && result != null) {
      fiveDisks = result.kind == RecursionKind.hanoi && result.n == 5
          ? result
          : null;
      runCustomInput(result);
    }
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
      if (identical(input, fiveDisks) &&
          next.frameIndex == next.timeline!.frames.length - 1 &&
          next.currentFrame!.callStack.isEmpty &&
          foreground &&
          visible) {
        fiveDisks = null;
        saveBadgeEvent(
          context,
          ref
              .read(achievementRepositoryProvider)
              .unlock(StudyBadge.hanoiMaster),
        );
      }
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
              const Text('递归实验室'),
              const SizedBox(width: 12),
              DropdownButton<RecursionKind>(
                key: const ValueKey('recursion-kind'),
                value: input.kind,
                items: [
                  for (final kind in RecursionKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(RecursionHanoiModule.names[kind.index]),
                    ),
                ],
                onChanged: (kind) {
                  if (kind == null) return;
                  final n = kind == RecursionKind.hanoi
                      ? input.n.clamp(1, 6)
                      : kind == RecursionKind.fibonacci
                      ? input.n.clamp(1, 10)
                      : input.n;
                  changeInput(input.copyWith(kind: kind, n: n));
                },
              ),
              IconButton(
                key: const ValueKey('recursion-input'),
                tooltip: '编辑递归参数',
                onPressed: editInput,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('recursion-preset'),
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
          stage: RecursionHanoiStage(
            timeline: timeline,
            frameIndex: state.frameIndex,
            progress: state.subProgress,
            input: input,
          ),
          code: CodeDebuggerPane(
            state: state,
            onLanguageChanged: vm.setLanguage,
            onToggleBreakpoint: vm.toggleBreakpoint,
          ),
          callStack: RecursionStackPanel(frame: frame),
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
              const RecursionTheory(),
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

class _RecursionInputDialog extends StatefulWidget {
  const _RecursionInputDialog({required this.input});
  final RecursionInput input;
  @override
  State<_RecursionInputDialog> createState() => _RecursionInputDialogState();
}

class _RecursionInputDialogState extends State<_RecursionInputDialog> {
  late final field = TextEditingController(
    text: widget.input.kind == RecursionKind.traverse
        ? widget.input.values.join(', ')
        : '${widget.input.n}',
  );
  String? error;
  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('编辑递归参数'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.input.kind == RecursionKind.traverse
                ? '最多 8 个 −999～999 整数；留空为 NULL 链。'
                : widget.input.kind == RecursionKind.hanoi
                ? '圆盘数 n：1～6。'
                : 'Fact：0～10；Fib：1～10，F(1)=F(2)=1。',
          ),
          if (widget.input.kind == RecursionKind.hanoi)
            Slider(
              key: const ValueKey('hanoi-disks'),
              min: 1,
              max: 6,
              divisions: 5,
              value: (int.tryParse(field.text) ?? widget.input.n)
                  .clamp(1, 6)
                  .toDouble(),
              label: field.text,
              onChanged: (v) => setState(() {
                field.text = v.round().toString();
                error = null;
              }),
            ),
          TextField(
            key: const ValueKey('recursion-input-value'),
            onChanged: widget.input.kind == RecursionKind.hanoi
                ? (_) => setState(() {})
                : null,
            controller: field,
            decoration: InputDecoration(
              labelText: widget.input.kind == RecursionKind.traverse
                  ? '链表从首元到末尾'
                  : 'n',
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
        key: const ValueKey('recursion-apply-input'),
        onPressed: () {
          final result = const RecursionHanoiModule().validateInput(
            '${widget.input.kind.name}|${widget.input.kind == RecursionKind.traverse ? widget.input.n : field.text}|${widget.input.kind == RecursionKind.traverse ? field.text : widget.input.values.join(',')}',
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
