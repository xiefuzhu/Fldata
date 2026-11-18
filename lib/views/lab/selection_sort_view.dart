import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch8_sort/selection_sort.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/layout/swap_trajectory.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';
import 'sort_keys_editor.dart';
import 'sort_playback.dart';

class SelectionSortView extends ConsumerStatefulWidget {
  const SelectionSortView({super.key, this.launch});
  final LessonLaunch<SelectionInput>? launch;
  @override
  ConsumerState<SelectionSortView> createState() => _SelectionSortViewState();
}

class _SelectionSortViewState
    extends LessonPlayer<SelectionSortView, SelectionInput> {
  @override
  LessonLaunch<SelectionInput>? get launch => widget.launch;
  @override
  final module = const SelectionModule();
  @override
  SelectionInput input = const SelectionInput();
  @override
  String get presetKey => 'selection-presets';
  @override
  String get theoryHint => switch (input.method) {
    SelectionMethod.simple => '每趟在未排序区间找出最小键，只在位置不同时交换。交换可能改变同键记录的原始次序。',
    SelectionMethod.tournament =>
      '树形选择保存上一轮比赛的胜者。输出根后，原叶填 ∞，只重算这片叶到根的路径。同键时左叶优先。',
    SelectionMethod.heap =>
      '完全二叉树和顺序表使用相同位序。父位 s 的孩子为 2s 和 2s+1。先从最后一个非叶结点倒序建大根堆，再将堆顶送入有序后缀。',
  };
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<SelectionMethod>(
      key: const ValueKey('selection-method'),
      value: input.method,
      items: [
        for (final m in SelectionMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) changeInput(input.change(method: m));
      },
    ),
    TextButton.icon(
      key: const ValueKey('selection-edit'),
      onPressed: () async {
        final keys = await showDialog<List<int>>(
          context: context,
          builder: (_) => SortKeysEditor(
            input.keys,
            fieldKey: 'selection-keys',
            title: '设置选择排序序列',
          ),
        );
        if (keys != null && mounted) runCustomInput(input.change(keys: keys));
      },
      icon: const Icon(Icons.edit_outlined),
      label: const Text('设置序列'),
    ),
  ];
  @override
  Widget stage(PlaybackState state) {
    final f = state.currentFrame!,
        timeline = state.timeline!,
        frames = timeline.frames;
    final next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final t = MediaQuery.disableAnimationsOf(context) ? 0.0 : state.subProgress;
    final scene = _selectionScene(f, next, t);
    final vars = f.inlineVars;
    final bounds = frames.first.scene.nodes;
    final w = bounds.fold(160.0, (w, n) => math.max(w, n.x + n.width + 52));
    final h = bounds.fold(150.0, (h, n) => math.max(h, n.y + n.height + 75));
    return LayoutBuilder(
      builder: (ctx, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.phaseTitle, style: Theme.of(ctx).textTheme.titleMedium),
            Text(f.explanation),
            Wrap(
              spacing: 12,
              children: [
                for (final key in ['过程', '堆规模', 's', 'j', 'rc', 'i', 'k'])
                  if (vars.containsKey(key)) Text('$key = ${vars[key]}'),
              ],
            ),
            SizedBox(
              height: math.min(h, math.max(250.0, c.maxHeight * .68)),
              child: DsStageCanvas(
                key: ObjectKey(timeline),
                scene: scene,
                sceneSize: Size(w, h),
                nodeContentBuilder: (ctx, node) => Center(
                  child: FittedBox(
                    child: Text(
                      node.label,
                      style: TextStyle(
                        fontWeight: node.label.contains('*')
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: node.isZeroSentinelSlot ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'KCN　${f.metrics.comparisons}　　RMN　${f.metrics.moves}',
              key: const ValueKey('selection-metrics'),
            ),
            Text(
              input.method == SelectionMethod.tournament
                  ? '锦标赛树使用 ${f.metrics.peakAuxiliarySpace} 个树槽，辅助空间 O(n)。晋级时只更新记录下标，输出才移动记录。'
                  : '辅助空间 O(1)，每次交换计三次记录移动。',
            ),
            if (vars['阶段'] == '完成')
              sortStabilityResult(
                ctx,
                input.keys,
                vars,
                (i) => vm.seek(i.toDouble()),
              ),
          ],
        ),
      ),
    );
  }
}

// Carry the outgoing root down to its final array slot, and its replacement
// from the array back to the root. Both views share the same exact end frame.
SceneSnapshot _selectionScene(TraceFrame current, TraceFrame next, double t) {
  final crossView = next.inlineVars.containsKey('跨视图');
  final scene = crossView
      ? SceneInterpolator.lerp(current.scene, next.scene, t)
      : interpolateSort(current, next, t);
  if (t <= 0 || t >= 1) return scene;
  if (!crossView && next.inlineVars['阶段'] != '孩子上移') return scene;
  SceneNode tree(String slot) =>
      current.scene.nodes.firstWhere((n) => n.id == 'tree$slot');
  SceneNode fly(SceneNode a, SceneNode b, String id) {
    final p = SwapTrajectory.position(
      Vec2(x: a.x, y: a.y),
      Vec2(x: b.x, y: b.y),
      t,
    );
    return a.copyWith(
      id: id,
      x: p.x,
      y: p.y,
      indexBadge: null,
      logicBadge: null,
      memoryAddress: null,
      visualState: NodeVisualState.moving,
    );
  }

  final dest = next.inlineVars['目标']!;
  if (!crossView) {
    return scene.copyWith(
      nodes: [
        ...scene.nodes,
        fly(tree(next.inlineVars['来源']!), tree(dest), 'heap-rise'),
      ],
    );
  }
  final root = tree('1'), end = current.scene.nodes[int.parse(dest)];
  return scene.copyWith(
    nodes: [
      ...scene.nodes,
      fly(root, end, 'heap-out'),
      fly(end, root, 'heap-in'),
    ],
  );
}
