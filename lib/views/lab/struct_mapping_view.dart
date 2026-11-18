import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch1_intro/struct_mapping.dart';
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
import 'struct_mapping_stage.dart';

class StructMappingView extends ConsumerStatefulWidget {
  const StructMappingView({super.key});
  @override
  ConsumerState<StructMappingView> createState() => _StructMappingViewState();
}

class _StructMappingViewState extends ConsumerState<StructMappingView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<MappingInput> {
  static const module = StructMappingModule();
  MappingInput input = const MappingInput();
  bool follow = false, foreground = true, visible = true;
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
  void changeInput(MappingInput next) {
    setState(() => input = next);
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
              const Tooltip(
                message: '第 1 章 · 1.1～1.2 逻辑结构与存储结构',
                child: Text('结构与存储'),
              ),
              const SizedBox(width: 12),
              SegmentedButton<StorageStructure>(
                key: const ValueKey('mapping-storage-kind'),
                showSelectedIcon: false,
                segments: [
                  for (final storage in StorageStructure.values)
                    ButtonSegment(
                      value: storage,
                      label: Text(
                        StructMappingModule.storageNames[storage.index],
                      ),
                    ),
                ],
                selected: {input.storage},
                onSelectionChanged: (v) =>
                    runCustomInput(input.copyWith(storage: v.single)),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('mapping-preset'),
                tooltip: '选择教学数据',
                icon: const Icon(Icons.dataset_outlined),
                itemBuilder: (_) => [
                  for (var i = 0; i < module.presets.length; i++)
                    PopupMenuItem(
                      value: i,
                      child: Text(module.presets[i].name),
                    ),
                ],
                onSelected: (i) => changeInput(
                  input.copyWith(
                    count: module.presets[i].input.count,
                    seed: module.presets[i].input.seed,
                  ),
                ),
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
          stage: StructMappingStage(
            scene: frame.scene,
            frameIndex: state.frameIndex,
            logical: input.logical,
            onLogicalChanged: (v) => runCustomInput(input.copyWith(logical: v)),
            onSelect: (i) => vm.seek((i + 1).toDouble()),
            followCamera: follow,
            onCameraInteraction: () {
              if (follow) setState(() => follow = false);
            },
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
          memory: MemoryTableInspector(
            scene: mappingScene(frame.scene, 'physical'),
          ),
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
                '教材锚点：第 1.1 节例 1.1～1.3；第 1.2 节逻辑结构与存储结构。场景数据是教学重建，非原书完整原题。',
              ),
              const SizedBox(height: 12),
              const Text(
                '顺序定位：O(1)。链表按序号定位通常为 O(n)；本演示的地址表用于点选映射。树、图的访问成本取决于选用的表示方法。',
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
            followCamera: follow,
            onFollowCamera: (v) => setState(() => follow = v),
          ),
        ),
      ),
    );
  }
}
