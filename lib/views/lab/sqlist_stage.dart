import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch2_linear_list/sqlist_ops.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class SqListStage extends StatelessWidget {
  const SqListStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final SqListInput input;
  @override
  Widget build(BuildContext context) {
    final n = input.operation == SqListOperation.init ? 0 : input.values.length;
    final state = frame.scene.auxTables.first.rows.first;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.phaseTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(label: Text('length = ${state[1]} / ${state[2]}')),
                    Chip(
                      key: const ValueKey('sqlist-result'),
                      label: Text('返回：${state[3]}'),
                      backgroundColor: frame.isErrorState
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                    Chip(label: Text('输出 e：${state[4]}')),
                  ],
                ),
                SizedBox(
                  height: math.max(300, 260 * scale),
                  child: DsStageCanvas(
                    key: ValueKey(
                      'sqlist-canvas-${input.capacity}-${input.operation.name}-${input.values}',
                    ),
                    scene: scene,
                    sceneSize: Size(64.0 * input.capacity + 64, 250),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      key: const ValueKey('sqlist-moves'),
                      label: Text('本次移动 ${frame.metrics.moves} 次'),
                    ),
                    Chip(
                      label: Text(
                        '读取 ${frame.metrics.reads} · 写入 ${frame.metrics.writes} · 比较 ${frame.metrics.comparisons}',
                      ),
                    ),
                  ],
                ),
                Text(
                  '初始 n=$n：E_ins=n/2=${n / 2}；E_del=${n == 0 ? '不适用（空表）' : '(n−1)/2=${(n - 1) / 2}'}。',
                  key: const ValueKey('sqlist-expectation'),
                ),
                const Text(
                  '上述期望假设各合法位序等概率，插入还需有空槽；移动仅统计已有元素的赋值，不含插入新值或修改 length。',
                ),
                if (input.operation == SqListOperation.locate)
                  Text(
                    n == 0
                        ? '空表不适用成功查找 ASL。'
                        : '不同元素且各成功位序等概率：ASL=(n+1)/2=${(n + 1) / 2}；未命中为 n 次。重复值返回首次匹配。',
                  ),
                const SizedBox(height: 8),
                Text(frame.explanation),
                const SizedBox(height: 8),
                const Text(
                  '物理下标 [0] 就是第一个元素，不是哨兵。浅色槽在有效区外；弧线徽标是赋值副本。画布支持缩放、平移与点击查看槽。',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
