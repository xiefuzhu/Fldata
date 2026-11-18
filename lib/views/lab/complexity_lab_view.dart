import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch1_intro/complexity_lab.dart';
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
import 'complexity_stage.dart';

class ComplexityLabView extends ConsumerStatefulWidget {
  const ComplexityLabView({super.key});
  @override
  ConsumerState<ComplexityLabView> createState() => _ComplexityLabViewState();
}

class _ComplexityLabViewState extends ConsumerState<ComplexityLabView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<ComplexityInput> {
  static const module = ComplexityLabModule();
  ComplexityInput input = const ComplexityInput();
  int? pendingN;
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
      chapterId: ChapterId.ch1,
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
  void changeInput(ComplexityInput next) {
    setState(() {
      input = next;
      pendingN = null;
    });
    seenFrames.clear();
    vm.load(module.generateTrace(next));
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
              const Text('复杂度实验室'),
              const SizedBox(width: 12),
              DropdownButton<ComplexityMode>(
                key: const ValueKey('complexity-mode'),
                value: input.mode,
                items: [
                  for (final mode in ComplexityMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(ComplexityLabModule.names[mode.index]),
                    ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    changeInput(
                      input.copyWith(
                        mode: mode,
                        n: input.n.clamp(1, ComplexityLabModule.maxN(mode)),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                'n=${pendingN ?? input.n}',
                key: const ValueKey('complexity-size'),
              ),
              SizedBox(
                width: 180,
                child: Slider(
                  key: const ValueKey('complexity-n'),
                  value: (pendingN ?? input.n).toDouble(),
                  min: 1,
                  max: ComplexityLabModule.maxN(input.mode).toDouble(),
                  divisions: ComplexityLabModule.maxN(input.mode) - 1,
                  label: '${pendingN ?? input.n}',
                  onChanged: (v) {
                    if (input.mode == ComplexityMode.growth) {
                      if (input.n != v.round()) {
                        runCustomInput(input.copyWith(n: v.round()));
                      }
                    } else {
                      setState(() => pendingN = v.round());
                    }
                  },
                  onChangeEnd: (v) {
                    if (input.mode != ComplexityMode.growth) {
                      runCustomInput(input.copyWith(n: v.round()));
                    }
                  },
                ),
              ),
              if (input.mode == ComplexityMode.search)
                DropdownButton<SearchScenario>(
                  key: const ValueKey('search-scenario'),
                  value: input.search,
                  items: [
                    for (final scenario in SearchScenario.values)
                      DropdownMenuItem(
                        value: scenario,
                        child: Text(['最好', '中间', '最坏', '失败'][scenario.index]),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) changeInput(input.copyWith(search: v));
                  },
                ),
              PopupMenuButton<int>(
                key: const ValueKey('complexity-preset'),
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
          stage: ComplexityStage(input: input, frame: frame),
          code: CodeDebuggerPane(
            state: state,
            onLanguageChanged: vm.setLanguage,
            onToggleBreakpoint: vm.toggleBreakpoint,
            lineCounts: {
              for (final e in frame.metrics.statementCounts.entries)
                int.parse(e.key.substring(5)): e.value,
            },
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
              const Text(
                '教材锚点：第 1.4 节例 1.4～1.11 与图 1.7。附件未附逐字源码，界面是按例题类别重建的教学实现。',
              ),
              const SizedBox(height: 12),
              const Text(
                '增长函数用于比较量级，不代表具体程序的测量次数。循环行计进入循环体次数；逆序空间按额外元素槽分别统计。矩阵规模 1～8，其余规模 1～32；逐步演示保留每次核心操作。',
              ),
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
