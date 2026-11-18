import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'badge_event.dart';
import '../../models/study_badge.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch5_tree/bitree_traverse.dart';
import '../../providers/playback_provider.dart';
import 'bitree_stage.dart';
import 'threaded_tree_stage.dart';
import 'forest_stage.dart';
import 'lesson_player.dart';
import '../../curriculum/ch5_tree/forest_conversion.dart';
import '../../models/playback_model.dart';
import '../../curriculum/ch5_tree/threaded_tree.dart';
import '../../engine/vm/algorithm_module.dart';

enum TreeCourse { binary, threaded, forest }

class BiTreeView extends ConsumerStatefulWidget {
  const BiTreeView({super.key, this.course = TreeCourse.binary});
  final TreeCourse course;
  bool get threaded => course == TreeCourse.threaded;
  bool get forest => course == TreeCourse.forest;
  @override
  ConsumerState<BiTreeView> createState() => _BiTreeViewState();
}

class _BiTreeViewState extends LessonPlayer<BiTreeView, TreeInput> {
  bool traversalOnly = false;
  @override
  AlgorithmModule<TreeInput> get module => widget.forest
      ? const ForestModule()
      : widget.threaded
      ? ThreadedTreeModule(traversalOnly: traversalOnly)
      : const BiTreeModule();
  @override
  late TreeInput input = widget.forest
      ? const TreeInput(sequence: textbookForest)
      : const TreeInput();
  bool sound = true;
  int forestDirection = 0, forestSteps = 0;

  @override
  String get presetKey => 'bitree-preset';
  Future<void> editInput({bool binary = false}) async {
    final result = await showDialog<TreeInput>(
      context: context,
      builder: (_) => widget.forest
          ? ForestInputDialog(sequence: input.sequence, binary: binary)
          : _TreeInputDialog(input: input),
    );
    if (mounted && result != null) {
      runCustomInput(result);
      if (widget.forest && binary) vm.last();
    }
  }

  void switchLesson(TreeLesson mode) {
    final index = ref.read(playbackProvider).frameIndex;
    final sameTour = input.lesson.isTour && mode.isTour;
    changeInput(TreeInput(sequence: input.sequence, lesson: mode));
    if (sameTour) vm.seek(index.toDouble());
  }

  @override
  void onPlaybackChange(PlaybackState? old, PlaybackState next) {
    if (visible && foreground && old?.frameIndex != next.frameIndex) {
      final repo = ref.read(achievementRepositoryProvider);
      final end = next.timeline!.frames.length - 1;
      if (widget.course == TreeCourse.binary &&
          input.lesson.isTour &&
          seenFrames.length == end + 1 &&
          next.frameIndex == end) {
        saveBadgeEvent(
          context,
          repo.milestone(StudyBadge.eulerWalker, input.lesson.index),
        );
      }
      if (widget.forest &&
          old != null &&
          identical(old.timeline, next.timeline)) {
        final delta = next.frameIndex - old.frameIndex;
        if (delta.abs() == 1) {
          forestSteps = forestDirection == delta ? forestSteps + 1 : 1;
          forestDirection = delta;
          if (forestSteps == end &&
              (next.frameIndex == 0 || next.frameIndex == end)) {
            saveBadgeEvent(
              context,
              repo.milestone(StudyBadge.eulerWalker, delta > 0 ? 3 : 4),
            );
          }
        } else {
          forestSteps = 0;
        }
      } else {
        forestSteps = 0;
      }
    }
    if (widget.course == TreeCourse.binary &&
        sound &&
        foreground &&
        visible &&
        input.lesson.isTour &&
        identical(old?.timeline, next.timeline) &&
        old != null &&
        next.frameIndex == old.frameIndex + 1 &&
        next.currentFrame?.inlineVars['采集'] == '是') {
      final desktop = [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      ].contains(defaultTargetPlatform);
      unawaited(
        SystemSound.play(
          desktop ? SystemSoundType.alert : SystemSoundType.click,
        ),
      );
    }
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    if (widget.forest) ...[
      TextButton.icon(
        onPressed: state.position < state.timeline!.frames.length - 1
            ? () => vm.play(direction: PlaybackDirection.forward)
            : null,
        icon: const Icon(Icons.account_tree),
        label: const Text('转为二叉树'),
      ),
      TextButton.icon(
        onPressed: state.position > 0
            ? () => vm.play(direction: PlaybackDirection.reverse)
            : null,
        icon: const Icon(Icons.undo),
        label: const Text('还原为森林'),
      ),
    ] else if (widget.threaded)
      DropdownButton<bool>(
        key: const ValueKey('thread-mode'),
        value: traversalOnly,
        items: const [
          DropdownMenuItem(value: false, child: Text('带头结点线索化')),
          DropdownMenuItem(value: true, child: Text('无栈中序遍历')),
        ],
        onChanged: (value) {
          if (value != null) {
            traversalOnly = value;
            changeInput(input);
          }
        },
      )
    else
      DropdownButton<TreeLesson>(
        key: const ValueKey('tree-mode'),
        value: input.lesson,
        items: [
          for (final m in TreeLesson.values)
            DropdownMenuItem(
              value: m,
              child: Text(BiTreeModule.names[m.index]),
            ),
        ],
        onChanged: (m) {
          if (m != null) {
            switchLesson(m);
          }
        },
      ),
    TextButton.icon(
      onPressed: editInput,
      icon: const Icon(Icons.edit_outlined),
      label: Text(widget.forest ? '编辑森林' : '编辑树'),
    ),
    if (widget.forest)
      TextButton(
        onPressed: () => editInput(binary: true),
        child: const Text('编辑二叉树'),
      ),
    if (widget.course == TreeCourse.binary && input.lesson.isTour)
      IconButton(
        tooltip: sound ? '关闭采集音效' : '开启采集音效',
        onPressed: () => setState(() => sound = !sound),
        icon: Icon(sound ? Icons.volume_up : Icons.volume_off),
      ),
  ];
  @override
  Widget stage(PlaybackState state) {
    final frame = state.currentFrame!;
    return widget.forest
        ? ForestStage(key: ValueKey(input.sequence), state: state)
        : widget.threaded
        ? ThreadedTreeStage(
            key: ValueKey(input.sequence),
            frame: frame,
            traversal: traversalOnly,
          )
        : BiTreeStage(frame: frame, progress: state.subProgress, input: input);
  }

  @override
  String get theoryHint => widget.forest
      ? '在孩子兄弟表示中，左指针指向长子，右指针指向右兄弟。单棵树的根没有右兄弟，森林中第一棵树的根可以有右兄弟。'
      : widget.threaded
      ? (traversalOnly
            ? '沿每棵右子树的左孩子找到首结点，再按右线索依次访问后继。抵达 Thrt 即结束。'
            : '按中序访问结点，用 pre 记录前驱。空孩子域可写入线索；头结点连接根与末结点。')
      : input.lesson.isWorkshop
      ? _workshopHint(input.lesson)
      : input.lesson == TreeLesson.stack
      ? '栈保存尚待访问的祖先。左路走到底时才弹出；访问后转向右孩子。'
      : input.lesson == TreeLesson.properties
      ? '根为第 1 层，空树深度为 0。树上的数字是完全二叉树位置编号。'
      : '每个节点依次经过左、底、右三个切点。切换采集规则可以比较同一时刻的先、中、后序输出。';
}

String _workshopHint(TreeLesson mode) => switch (mode) {
  TreeLesson.levelOrder => '队头先出，左、右孩子依次追加到队尾。',
  TreeLesson.create => '每个 # 都占一个输入位置，表示当前位置的空孩子。',
  TreeLesson.preIn ||
  TreeLesson.postIn => '根在中序区间中的位置决定左右子树的范围。先序取首项，后序取末项。同名结点可能有多种重构结果。',
  TreeLesson.copy => '副本中的每个结点都有独立标识，孩子链接均指向副本。',
  TreeLesson.depth => '从空树的深度 0 开始，逐层返回左右深度的较大值加 1。',
  _ => '空树贡献 0；每个非空结点贡献 1，并加上两个子树的结点数。',
};

class _TreeInputDialog extends StatefulWidget {
  const _TreeInputDialog({required this.input});
  final TreeInput input;
  @override
  State<_TreeInputDialog> createState() => _TreeInputDialogState();
}

class _TreeInputDialogState extends State<_TreeInputDialog> {
  late final root = readPreorder(widget.input.sequence);
  bool get paired => widget.input.lesson.isReconstruction;
  bool get post => widget.input.lesson == TreeLesson.postIn;
  late final expression = TextEditingController(
    text: paired
        ? traversalSequence(
            root,
            post ? TreeLesson.postorder : TreeLesson.preorder,
          )
        : widget.input.sequence,
  );
  late final middle = TextEditingController(
    text: paired ? traversalSequence(root, TreeLesson.inorder) : '',
  );
  String? error;
  @override
  void dispose() {
    expression.dispose();
    middle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('编辑二叉树'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('tree-sequence'),
            controller: expression,
            decoration: InputDecoration(
              labelText: paired ? (post ? '后序序列' : '先序序列') : '先序串（# 为空孩子）',
              errorText: paired ? null : error,
            ),
          ),
          if (paired)
            TextField(
              key: const ValueKey('tree-inorder'),
              controller: middle,
              decoration: InputDecoration(labelText: '中序序列', errorText: error),
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
          try {
            final sequence = paired
                ? reconstructSequence(
                    expression.text,
                    middle.text,
                    postorder: post,
                  )
                : expression.text;
            if (!paired) readPreorder(sequence);
            Navigator.pop(
              context,
              TreeInput(sequence: sequence, lesson: widget.input.lesson),
            );
          } on FormatException catch (e) {
            setState(() => error = e.message);
          }
        },
        child: const Text('应用'),
      ),
    ],
  );
}
