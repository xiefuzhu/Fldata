import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch2_linear_list/linklist_ops.dart';
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
import 'linklist_stage.dart';

class LinkListView extends ConsumerStatefulWidget {
  const LinkListView({super.key});
  @override
  ConsumerState<LinkListView> createState() => _LinkListViewState();
}

class _LinkListViewState extends ConsumerState<LinkListView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<LinkListInput> {
  static const module = LinkListModule();
  LinkListInput input = const LinkListInput();
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
  void changeInput(LinkListInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<LinkListInput>(
      context: context,
      builder: (_) => _LinkListInputDialog(input: input),
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
              const Text('单链表'),
              const SizedBox(width: 12),
              DropdownButton<LinkListOperation>(
                key: const ValueKey('linklist-operation'),
                value: input.operation,
                items: [
                  for (final op in LinkListOperation.values)
                    DropdownMenuItem(
                      value: op,
                      child: Text(LinkListModule.names[op.index]),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) changeInput(input.copyWith(operation: v));
                },
              ),
              Tooltip(
                message: '带头结点 / 无头结点；保留输入并重建追踪',
                child: Row(
                  children: [
                    const Text('头结点'),
                    Switch(
                      key: const ValueKey('linklist-head'),
                      value: input.hasHead,
                      onChanged: (v) => changeInput(input.copyWith(hasHead: v)),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                key: const ValueKey('linklist-wrong'),
                onPressed: () => changeInput(
                  input.copyWith(
                    operation: LinkListOperation.insert,
                    wrongOrder: !input.wrongOrder,
                  ),
                ),
                icon: Icon(input.wrongOrder ? Icons.undo : Icons.warning_amber),
                label: Text(input.wrongOrder ? '恢复正常顺序' : '演示误序断链'),
              ),
              IconButton(
                key: const ValueKey('linklist-input'),
                tooltip: '编辑链表参数',
                onPressed: editInput,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('linklist-preset'),
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
          stage: LinkListStage(
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
                '教材锚点：算法 2.6～2.12。代码为教学重建；C99 使用二级指针写回 L，Dart 使用 Link.first。地址是堆对象模拟标识，不是真实地址。Init/Create 演示新建表，分配成功；真实分配失败仅在 C99 代码列出。',
              ),
              const SizedBox(height: 12),
              const Text(
                '按位序定位/按值查找最坏 O(n)，已有前驱时接链只需 O(1)。前插与后插建表均 O(n)，分配 n 个数据结点；其他操作辅助空间 O(1)。头结点不存数据，统一首元插删。反例中的“泄漏”按 C/C99 指针可达性解释；Dart 的失联对象可由 GC 回收，但断链和自环仍是逻辑错误。',
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

class _LinkListInputDialog extends StatefulWidget {
  const _LinkListInputDialog({required this.input});
  final LinkListInput input;
  @override
  State<_LinkListInputDialog> createState() => _LinkListInputDialogState();
}

class _LinkListInputDialogState extends State<_LinkListInputDialog> {
  late final fields = [
    TextEditingController(text: widget.input.values.join(', ')),
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
    title: const Text('编辑单链表'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('最多 8 个单字符元素（英文字母/数字），逗号或空格分隔；空白表示空表。位序可越界。每次操作从输入重建。'),
          for (var k = 0; k < fields.length; k++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                key: ValueKey('linklist-input-$k'),
                controller: fields[k],
                decoration: InputDecoration(
                  labelText: ['元素 / 建表输入', '位序 i', '插入 / 查找值 e'][k],
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
        key: const ValueKey('linklist-apply-input'),
        onPressed: () {
          final result = const LinkListModule().validateInput(
            '${widget.input.operation.name}|${widget.input.hasHead ? 1 : 0}|${widget.input.wrongOrder ? 1 : 0}|${fields[1].text}|${fields[2].text}|${fields[0].text}',
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
