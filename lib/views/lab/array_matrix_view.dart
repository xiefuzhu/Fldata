import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch4_string_array_glist/array_matrix.dart';
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
import 'array_matrix_stage.dart';

class ArrayMatrixView extends ConsumerStatefulWidget {
  const ArrayMatrixView({super.key});
  @override
  ConsumerState<ArrayMatrixView> createState() => _ArrayMatrixViewState();
}

class _ArrayMatrixViewState extends ConsumerState<ArrayMatrixView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<MatrixInput> {
  static const module = ArrayMatrixModule();
  MatrixInput input = const MatrixInput();
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
      chapterId: ChapterId.ch4,
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
  void changeInput(MatrixInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<MatrixInput>(
      context: context,
      builder: (_) => _MatrixInputDialog(input: input),
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
              DropdownButton<MatrixMode>(
                key: const ValueKey('matrix-mode'),
                value: input.mode,
                items: [
                  for (final m in MatrixMode.values)
                    DropdownMenuItem(
                      value: m,
                      child: Text(ArrayMatrixModule.names[m.index]),
                    ),
                ],
                onChanged: (m) {
                  if (m != null) {
                    changeInput(ArrayMatrixModule.example(m));
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('参数'),
                onPressed: editInput,
              ),
              if (input.mode == MatrixMode.address)
                TextButton(
                  onPressed: () => changeInput(
                    input.select(
                      input.z,
                      input.i,
                      input.j,
                      columns: !input.columnMajor,
                    ),
                  ),
                  child: Text(input.columnMajor ? '列主序' : '行主序'),
                ),
              PopupMenuButton<int>(
                key: const ValueKey('matrix-preset'),
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
          stage: ArrayMatrixStage(
            frame: frame,
            next:
                timeline.frames[(state.frameIndex + 1).clamp(
                  0,
                  timeline.frames.length - 1,
                )],
            progress: state.subProgress,
            input: input,
            onCell: (z, i, j) {
              runCustomInput(input.select(z, i, j));
              vm.toggle();
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
              Text(
                input.mode == MatrixMode.transpose
                    ? '普通转置逐列扫描三元组。快速转置先统计列频数，再计算起点，最后按输入顺序写出。时间 O(列数 + 非零项数)。'
                    : input.compressed
                    ? '矩阵坐标从 1 编号，压缩槽从 0 编号。用当前行以前的存储项数加本行偏移定位。'
                    : '数组坐标从 0 编号。行主序让最后一维连续，列主序让第一维连续。地址公式可直接计算，扫描用于展示存储顺序。',
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

class _MatrixInputDialog extends StatefulWidget {
  const _MatrixInputDialog({required this.input});
  final MatrixInput input;
  @override
  State<_MatrixInputDialog> createState() => _MatrixInputDialogState();
}

class _MatrixInputDialogState extends State<_MatrixInputDialog> {
  late final fields = widget.input.parameters
      .split(' ')
      .map((v) => TextEditingController(text: v))
      .toList();
  late final entries = TextEditingController(text: widget.input.entries);
  String? error;
  @override
  void dispose() {
    for (final f in fields) {
      f.dispose();
    }
    entries.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.input;
    return AlertDialog(
      title: Text(ArrayMatrixModule.names[a.mode.index]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final k in [
              0,
              if (!a.compressed) 1,
              if (a.mode == MatrixMode.address) 2,
              if (a.mode != MatrixMode.transpose) ...[3, 4],
              if (a.mode == MatrixMode.lower) 5,
            ])
              TextField(
                key: ValueKey('matrix-param-$k'),
                controller: fields[k],
                decoration: InputDecoration(
                  labelText: [
                    a.compressed ? '阶数' : '行数',
                    '列数',
                    '层数（二维取 1）',
                    '基址（十进制或 0x）',
                    '元素字节数',
                    '公共常数 c',
                  ][k],
                ),
              ),
            if (a.mode == MatrixMode.transpose)
              TextField(
                key: const ValueKey('matrix-triples'),
                controller: entries,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '三元组（行,列,值；英文分号分隔）',
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
          onPressed: () {
            final dims = fields.map((f) => f.text.trim()).toList();
            if (a.compressed) {
              dims[1] = dims[0];
            }
            final result = const ArrayMatrixModule().validateInput(
              '${a.mode.name}|${dims.join(" ")}|${entries.text}',
            );
            if (!result.isValid) {
              setState(() => error = result.error);
              return;
            }
            final next = result.value!;
            Navigator.pop(
              context,
              next.select(
                a.z.clamp(0, next.layers - 1),
                a.i.clamp(0, next.rows - 1),
                a.j.clamp(0, next.cols - 1),
                columns: a.columnMajor,
              ),
            );
          },
          child: const Text('应用'),
        ),
      ],
    );
  }
}
