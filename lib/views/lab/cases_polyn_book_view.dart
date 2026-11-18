import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch2_linear_list/cases_polyn_book.dart';
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
import 'cases_polyn_book_stage.dart';

class CasesPolynBookView extends ConsumerStatefulWidget {
  const CasesPolynBookView({super.key});
  @override
  ConsumerState<CasesPolynBookView> createState() => _CasesPolynBookViewState();
}

class _CasesPolynBookViewState extends ConsumerState<CasesPolynBookView>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        CustomLessonInput<CasesInput> {
  static const module = CasesPolynBookModule();
  CasesInput input = const CasesInput();
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
  void changeInput(CasesInput next) {
    setState(() => input = next);
    seenFrames.clear();
    vm.load(module.generateTrace(next));
  }

  Future<void> editInput() async {
    final result = await showDialog<CasesInput>(
      context: context,
      builder: (_) => _CasesInputDialog(input: input),
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
              const Text('多项式 / 图书'),
              const SizedBox(width: 12),
              DropdownButton<CaseOperation>(
                key: const ValueKey('cases-operation'),
                value: input.operation,
                items: [
                  for (final op in CaseOperation.values)
                    DropdownMenuItem(
                      value: op,
                      child: Text(CasesPolynBookModule.names[op.index]),
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
              if (input.isBook) ...[
                const Text('链式'),
                Switch(
                  key: const ValueKey('book-storage'),
                  value: input.linked,
                  onChanged: (v) => changeInput(input.copyWith(linked: v)),
                ),
              ],
              IconButton(
                key: const ValueKey('cases-input'),
                tooltip: '编辑案例数据',
                onPressed: editInput,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<int>(
                key: const ValueKey('cases-preset'),
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
          stage: CasesPolynBookStage(
            frame: frame,
            next:
                timeline.frames[(state.frameIndex + 1).clamp(
                  0,
                  timeline.frames.length - 1,
                )],
            progress: state.subProgress,
            input: input,
            onUseBooks:
                input.isBook &&
                    frame.scene.auxTables.first.rows.first[0] == 'OK'
                ? () {
                    final rows = frame.scene.auxTables
                        .singleWhere((t) => t.id == 'books')
                        .rows;
                    final books = rows
                        .map((r) => BookRecord(r[0], r[1], double.parse(r[2])))
                        .toList();
                    runCustomInput(
                      input.copyWith(
                        books: books,
                        operation: CaseOperation.bookFind,
                        query: books.firstOrNull?.isbn ?? input.query,
                      ),
                    );
                  }
                : null,
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
              CasesTheory(input: input),
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

class _CasesInputDialog extends StatefulWidget {
  const _CasesInputDialog({required this.input});
  final CasesInput input;
  @override
  State<_CasesInputDialog> createState() => _CasesInputDialogState();
}

class _CasesInputDialogState extends State<_CasesInputDialog> {
  late final fields = [
    TextEditingController(text: widget.input.a.map((t) => t.raw).join(', ')),
    TextEditingController(text: widget.input.b.map((t) => t.raw).join(', ')),
    TextEditingController(
      text: widget.input.books.map((b) => b.raw).join('\n'),
    ),
    TextEditingController(text: widget.input.book.raw),
    TextEditingController(text: '${widget.input.position}'),
    TextEditingController(text: widget.input.query),
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
  Widget build(BuildContext context) {
    final op = widget.input.operation;
    final indices = widget.input.isBook
        ? [
            2,
            if (op == CaseOperation.bookInsert) 3,
            if (op != CaseOperation.bookFind) 4,
            if (op == CaseOperation.bookFind) 5,
          ]
        : [0, if (op == CaseOperation.add) 1];
    return AlertDialog(
      title: const Text('编辑案例数据'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.input.isBook
                  ? '每行一本：编号,书名,价格。最多 8 本；编号唯一。留空表示空书库。'
                  : '每项 系数:指数，用逗号分隔；最多 6 项，指数 0～99 不重复，系数非零且绝对值≤99。相加输入须升序，建表允许乱序。',
            ),
            for (final k in indices)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  key: ValueKey('cases-input-$k'),
                  controller: fields[k],
                  minLines: k == 2 ? 3 : 1,
                  maxLines: k == 2 ? 5 : 2,
                  decoration: InputDecoration(
                    labelText: [
                      'A 各项',
                      'B 各项',
                      '当前书库',
                      '新图书',
                      '位序 i',
                      '查找编号',
                    ][k],
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
          key: const ValueKey('cases-apply-input'),
          onPressed: () {
            final result = const CasesPolynBookModule().validateInput(
              '${op.name}|${widget.input.linked ? 1 : 0}|${fields[4].text}|${fields[5].text}|${fields[3].text}|${fields[2].text.replaceAll('\n', ';')}|${fields[0].text}|${fields[1].text}',
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
}
