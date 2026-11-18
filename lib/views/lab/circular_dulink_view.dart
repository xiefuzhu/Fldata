import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch2_linear_list/circular_dulink.dart';
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
import 'circular_dulink_stage.dart';

class CircularDulinkView extends ConsumerStatefulWidget {
  const CircularDulinkView({super.key});
  @override
  ConsumerState<CircularDulinkView> createState() => _CircularDulinkViewState();
}

class _CircularDulinkViewState extends ConsumerState<CircularDulinkView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<CircularInput> {
  static const module = CircularDulinkModule();
  CircularInput input = const CircularInput();
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
  void changeInput(CircularInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<CircularInput>(
      context: context,
      builder: (_) => _CircularInputDialog(input: input),
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
              const Text('循环 / 双向表'),
              const SizedBox(width: 12),
              DropdownButton<CircularOperation>(
                key: const ValueKey('circular-operation'),
                value: input.operation,
                items: [
                  for (final op in CircularOperation.values)
                    DropdownMenuItem(
                      value: op,
                      child: Text(CircularDulinkModule.names[op.index]),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) changeInput(input.copyWith(operation: v));
                },
              ),
              IconButton(
                key: const ValueKey('circular-input'),
                tooltip: '编辑链表参数',
                onPressed: editInput,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('circular-preset'),
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
          stage: CircularDulinkStage(
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
              const Text(
                '教材锚点：2.5.3 单循环链表合并、算法 2.13～2.14 双向链表。输入均为带头结点的循环链；地址为教学模拟。合并消耗两条输入链，返回唯一结果尾指针 T，不再把 Ta/Tb 当独立链使用。',
              ),
              const SizedBox(height: 12),
              const Text(
                '仅有尾指针即可在 O(1) 时间访问头结点和首元并合并；B 为空单独处理。双向表按位序定位 O(n)，已知 p 后接链 O(1)。② 必须早于 ④，否则 p.prior 已变成 s，② 写错对象。正常四步中间可能不一致；最终应恢复互为前后继。快照按 C99 生命周期显示释放；Dart GC 不承诺立即回收。',
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

class _CircularInputDialog extends StatefulWidget {
  const _CircularInputDialog({required this.input});
  final CircularInput input;
  @override
  State<_CircularInputDialog> createState() => _CircularInputDialogState();
}

class _CircularInputDialogState extends State<_CircularInputDialog> {
  late final fields = [
    TextEditingController(text: widget.input.a.join(', ')),
    TextEditingController(text: widget.input.b.join(', ')),
    TextEditingController(text: '${widget.input.position}'),
    TextEditingController(text: widget.input.value),
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
    title: const Text('编辑循环 / 双向链表'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('每表最多 5 个单字符（英文字母/数字）；留空表示空表。B 仅用于合并。位序从 1 开始，允许越界演示。'),
          for (var k = 0; k < fields.length; k++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                key: ValueKey('circular-input-$k'),
                controller: fields[k],
                decoration: InputDecoration(
                  labelText: ['A 元素', 'B 元素（合并）', '位序 i', '插入值 e'][k],
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
        key: const ValueKey('circular-apply-input'),
        onPressed: () {
          final result = const CircularDulinkModule().validateInput(
            '${widget.input.operation.name}|${fields[2].text}|${fields[3].text}|${fields[0].text}|${fields[1].text}',
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
