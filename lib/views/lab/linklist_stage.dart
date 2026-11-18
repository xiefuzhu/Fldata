import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch2_linear_list/linklist_ops.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class LinkListStage extends StatelessWidget {
  const LinkListStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final LinkListInput input;
  @override
  Widget build(BuildContext context) {
    final row = frame.scene.auxTables.first.rows.first;
    final leaks = frame.scene.nodes.where((n) => n.isOrphanLeak).length;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
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
                    Chip(label: Text(input.hasHead ? '带头结点' : '无头结点')),
                    Chip(
                      key: const ValueKey('linklist-result'),
                      label: Text('返回：${row[2]}'),
                      backgroundColor: frame.isErrorState
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                    Chip(label: Text('输出 e：${row[3]}')),
                    Chip(
                      key: const ValueKey('linklist-leaks'),
                      label: Text('失联 $leaks 个'),
                      backgroundColor: leaks > 0
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                  ],
                ),
                SizedBox(
                  height: math.max(400, 340 * scale),
                  child: DsStageCanvas(
                    key: ValueKey(
                      'linked-${input.hasHead}-${input.operation}-${input.values}',
                    ),
                    scene: scene,
                    sceneSize: Size(
                      112.0 * (input.values.length + (input.hasHead ? 2 : 1)) +
                          120,
                      410,
                    ),
                  ),
                ),
                Text(
                  'L 可达数据链：${row[1].isEmpty ? '空' : row[1]}',
                  key: const ValueKey('linklist-chain'),
                ),
                if (frame.isErrorState)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      frame.explanation,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(frame.explanation),
                const SizedBox(height: 8),
                const Text(
                  '逻辑顺序由 next 决定。紫色结点是表头；红色失联结点在 C/C99 中泄漏。反例错误帧会暂停：继续单步可观察自环，倒放可恢复。',
                ),
                Text(
                  '累计：读取 ${frame.metrics.reads} · 比较 ${frame.metrics.comparisons} · 指针写入 ${frame.metrics.writes} · 新分配 ${frame.metrics.allocations}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
