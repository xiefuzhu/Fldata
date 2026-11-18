import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch8_sort/merge_radix.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/layout/swap_trajectory.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';
import 'sort_keys_editor.dart';
import 'sort_playback.dart';
import 'sort_race_arena.dart';
import 'badge_event.dart';
import '../../providers/app_providers.dart';

class MergeRadixView extends ConsumerStatefulWidget {
  const MergeRadixView({super.key, this.launch});
  final LessonLaunch<MergeRadixInput>? launch;
  @override
  ConsumerState<MergeRadixView> createState() => _MergeRadixState();
}

class _MergeRadixState extends LessonPlayer<MergeRadixView, MergeRadixInput> {
  @override
  LessonLaunch<MergeRadixInput>? get launch => widget.launch;
  @override
  final module = const MergeRadixModule();
  @override
  MergeRadixInput input = const MergeRadixInput();
  @override
  String get presetKey => 'merge-radix-presets';
  bool get radix => input.method == MergeRadixMethod.radix;
  @override
  String get theoryHint => input.bottomUp
      ? '图 8.13 按段长 1、2、4……自底向上合并，相等时先取左段。每趟交换源表与目标表。'
      : radix
      ? '算法 8.12 按十进制低位优先分配与收集。f、e 分别保存十个队列的首尾游标；同桶内维持到达顺序。KCN 与 RMN 都为零，面板单独统计游标赋值。'
      : '算法 8.10 在相等时先选左段。算法 8.11 递归拆分闭区间，两个缓冲区逐层交换读写角色，根调用把最后一段写回原表。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<MergeRadixMethod>(
      key: const ValueKey('merge-radix-method'),
      value: input.method,
      items: [
        for (final m in MergeRadixMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) {
          changeInput(
            module.presets.firstWhere((p) => p.input.method == m).input,
          );
        }
      },
    ),
    TextButton.icon(
      key: const ValueKey('merge-radix-edit'),
      onPressed: () async {
        final v = await showDialog<List<int>>(
          context: context,
          builder: (_) => SortKeysEditor(
            input.keys,
            title: '设置${input.method.label}序列',
            fieldKey: 'merge-radix-keys',
            validate: radix
                ? (keys) => keys.any((k) => k < 0) ? '链式基数排序使用非负十进制整数。' : null
                : null,
          ),
        );
        if (v != null && mounted) {
          runCustomInput(
            MergeRadixInput(
              method: input.method,
              keys: v,
              bottomUp: input.bottomUp,
            ),
          );
        }
      },
      icon: const Icon(Icons.edit_outlined),
      label: const Text('设置序列'),
    ),
    TextButton.icon(
      key: const ValueKey('open-race'),
      onPressed: () {
        vm.pause();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SortRaceArena(
              onFinished: (mixed) => saveBadgeEvent(
                context,
                ref
                    .read(achievementRepositoryProvider)
                    .finishRace(mixed: mixed),
              ),
            ),
          ),
        );
      },
      icon: const Icon(Icons.flag_outlined),
      label: const Text('排序竞速'),
    ),
  ];
  @override
  Widget stage(PlaybackState state) {
    final f = state.currentFrame!,
        frames = state.timeline!.frames,
        next = frames[math.min(state.frameIndex + 1, frames.length - 1)],
        vars = f.inlineVars;
    final t = MediaQuery.disableAnimationsOf(context) ? 0.0 : state.subProgress;
    var scene = SceneInterpolator.lerp(f.scene, next.scene, t);
    final bucketEntry = next.inlineVars['阶段'] == '分配';
    final slot = next.inlineVars['p'];
    final read = bucketEntry ? 'rad$slot' : next.inlineVars['读槽'],
        write = bucketEntry ? 'member$slot' : next.inlineVars['写槽'];
    if (t > 0 && t < 1 && read != null && write != null && read != write) {
      final a = f.scene.nodes.firstWhere((n) => n.id == read),
          z = next.scene.nodes.firstWhere((n) => n.id == write);
      final pos = SwapTrajectory.position(
        Vec2(x: a.x, y: a.y),
        Vec2(x: z.x, y: z.y),
        t,
      );
      scene = scene.copyWith(
        nodes: [
          for (final node in scene.nodes)
            if (!bucketEntry || node.id != write) node,
          a.copyWith(
            id: bucketEntry ? write : 'merge-copy',
            x: pos.x,
            y: pos.y,
            indexBadge: null,
            logicBadge: null,
            visualState: NodeVisualState.moving,
          ),
        ],
      );
    }
    final bounds = radix ? scene.nodes : frames.last.scene.nodes;
    final width = bounds.fold(200.0, (a, n) => math.max(a, n.x + n.width + 42)),
        height = bounds.fold(160.0, (a, n) => math.max(a, n.y + n.height + 55));
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
                for (final name in ['源', '目标表', 'i', 'j', 'k', '位次', 'p', '桶'])
                  if (vars[name] != null) Text('$name = ${vars[name]}'),
              ],
            ),
            SizedBox(
              height: math.min(height, math.max(275.0, c.maxHeight * .7)),
              child: DsStageCanvas(
                key: ObjectKey(state.timeline),
                scene: scene,
                sceneSize: Size(width, height),
                nodeContentBuilder: (ctx, n) => Center(
                  child: FittedBox(
                    child: Text(
                      n.label,
                      style: TextStyle(
                        color: n.isZeroSentinelSlot ? Colors.white : null,
                        fontWeight: n.label.contains('*')
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text('KCN　${f.metrics.comparisons}　　RMN　${f.metrics.moves}'),
            if (radix) ...[
              Text('游标写入　${f.metrics.writes}'),
              if (vars['阶段'] == '整趟' || vars['阶段'] == '完成')
                Text(
                  '链序　${vars['链序']!.split(',').where((s) => s.isNotEmpty).map((s) => f.scene.nodes[int.parse(s)].label).join(" → ")}',
                ),
            ],
            if (!radix && !input.bottomUp)
              Text(
                '递归栈　当前 ${f.metrics.callDepth}　峰值 ${f.metrics.maxCallDepth}',
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
