import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch2_linear_list/circular_dulink.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class CircularDulinkStage extends StatelessWidget {
  const CircularDulinkStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final CircularInput input;
  @override
  Widget build(BuildContext context) {
    final merge = input.operation == CircularOperation.merge;
    final row = frame.scene.auxTables.first.rows.first,
        order = frame.scene.auxTables[1].rows.first;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final width = merge
        ? math.max(input.a.length, input.b.length) + 1
        : input.a.length + 2;
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
                    Chip(label: Text(merge ? '仅尾指针 · O(1) 合并' : '双向循环链 · 四指针')),
                    Chip(
                      key: const ValueKey('circular-status'),
                      label: Text('返回：${row[0]}'),
                      backgroundColor: frame.isErrorState
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                    Chip(label: Text('输出 e：${row[1]}')),
                    if (!merge)
                      Chip(
                        key: const ValueKey('circular-invariant'),
                        label: Text(
                          row[2] == '0'
                              ? '双向一致'
                              : '${frame.isErrorState ? '错误' : '中间态'} · 不一致 ${row[2]} 项',
                        ),
                      ),
                    if (row[3] != '0')
                      Chip(
                        key: const ValueKey('circular-dangling'),
                        label: Text('暂存悬空 next：${row[3]} 条'),
                      ),
                  ],
                ),
                SizedBox(
                  height: math.max(500, 420 * scale),
                  child: DsStageCanvas(
                    key: ValueKey(
                      'circular-${input.operation}-${input.a}-${input.b}',
                    ),
                    scene: scene,
                    sceneSize: Size(112.0 * width + 120, 500),
                  ),
                ),
                Text(
                  '从 HA 沿 next：${order[0].isEmpty ? '空' : order[0]}',
                  key: const ValueKey('circular-order'),
                ),
                if (!merge)
                  Text('沿 prior：${order[1].isEmpty ? '空' : order[1]}'),
                const SizedBox(height: 8),
                Text(
                  frame.explanation,
                  style: frame.isErrorState
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
                Text(
                  '累计结构字段写入 ${frame.metrics.writes} · 寻址/读取 ${frame.metrics.reads} · 本操作新分配 ${frame.metrics.allocations}',
                ),
                const Text('蓝色为当前修改字段；红色边为悬空引用或错误自环。回退可观察每个字段赋值前后的状态。'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
