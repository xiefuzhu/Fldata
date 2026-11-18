import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch2_linear_list/merge_compare.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class MergeCompareStage extends StatelessWidget {
  const MergeCompareStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final MergeInput input;
  @override
  Widget build(BuildContext context) {
    final linked = input.operation == MergeOperation.linked,
        union = input.operation == MergeOperation.union;
    final row = frame.scene.auxTables.first.rows.first;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final width =
        (input.a.length + input.b.length + 1) * (linked ? 96.0 : 72.0) + 120;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.phaseTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(
                        MergeCompareModule.names[input.operation.index],
                      ),
                    ),
                    Chip(
                      key: const ValueKey('merge-status'),
                      label: Text(row[0]),
                    ),
                    Chip(label: Text('值比较 ${frame.metrics.comparisons} 次')),
                    Chip(
                      label: Text(
                        linked
                            ? '新数据节点 0 · 固定游标 O(1)'
                            : union
                            ? 'A 预留容量 · 无新数组'
                            : '新 LC 数据槽 ${frame.metrics.auxiliarySpace}',
                      ),
                    ),
                  ],
                ),
                Text(
                  linked
                      ? '上：原 A / B；下：已接入 LC。pa、pb 为候选，pc 为结果边界。'
                      : union
                      ? '上：A（含预留空槽）；中：B。并集追加到 A。[0] 是普通数据槽。'
                      : '上：A；中：B；下：独立 LC（顺序归并）。[0] 是普通数据槽。',
                ),
                SizedBox(
                  height: math.max(linked ? 600 : 480, 440 * scale),
                  child: DsStageCanvas(
                    key: ValueKey(
                      'merge-${input.operation}-${input.a}-${input.b}',
                    ),
                    scene: scene,
                    sceneSize: Size(width, linked ? 600 : 480),
                  ),
                ),
                Text(
                  '${row[0] == '完成' ? '结果' : '已确定前缀'}：${row[1].isEmpty ? '空' : row[1]}',
                  key: const ValueKey('merge-result'),
                ),
                if (linked)
                  Text(
                    'HA 当前可达：${row[2].isEmpty ? '空' : row[2]}${row[0] == '完成' ? '' : '（pc 后方可能仍是原后缀）'}',
                  ),
                const SizedBox(height: 8),
                Text(frame.explanation),
                Text(
                  '字段/数据写入 ${frame.metrics.writes} · 读取 ${frame.metrics.reads} · 值复制 ${frame.metrics.moves} · 新分配 ${frame.metrics.allocations}',
                ),
                const SizedBox(height: 12),
                const MergeComparisonCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MergeComparisonCards extends StatelessWidget {
  const MergeComparisonCards({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '表 2.2 / 2.3 · 时空性能对照',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const Text('以下为按教材主题重建的比较卡；n 为表长，指针字段与容量开销需同时考虑。'),
      for (final row in const [
        ['按位序读取', '顺序表 O(1)', '单链表 O(n)'],
        ['按值查找（无序）', '顺序表 O(n)', '单链表 O(n)'],
        ['按位序插入 / 删除', '顺序表 O(n)，移动元素', '单链表 O(n) 定位 + O(1) 接链'],
        ['已知前驱后插入 / 删除后继', '顺序表仍可能移动 O(n)', '单链表 O(1)，无需搬移其余节点'],
        ['存储开销', '连续容量，可能有未用槽', '数据 + 每节点 next + 可选头结点'],
        ['有序归并（2.16 / 2.17）', 'O(m+n)，新 LC 占 m+n 槽', 'O(m+n)，复用节点，辅助 O(1)'],
      ])
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(row[1]),
                Text(row[2]),
              ],
            ),
          ),
        ),
      const Text(
        '算法 2.15：无序并集不等于有序归并。集合输入只查原 A 前缀，值比较至多 mn；含 B 遍历为 O(mn+n)。本课程 A 预留 m+n 容量；Dart List.add 的容量增长由运行时管理，实际分配不按快照模拟。',
      ),
      const SizedBox(height: 8),
      const Text(
        '有序归并允许重复值，使用 <= 保证 A 中相等值先出。链式归并消耗 LA/LB，返回 LC；最后整串挂接只写一次 next，释放的仅是 LB 头结点。顺序 LC 空间计入结果数组；若排除输出，两种归并的游标工作空间均为 O(1)。',
      ),
    ],
  );
}
