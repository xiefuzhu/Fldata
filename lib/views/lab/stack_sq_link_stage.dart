import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch3_stack_queue/stack_sq_link.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class StackSqLinkStage extends StatelessWidget {
  const StackSqLinkStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
    this.replaySummary,
    this.highlight,
  });
  final String? replaySummary, highlight;
  final TraceFrame frame, next;
  final double progress;
  final StackInput input;
  @override
  Widget build(BuildContext context) {
    final row = frame.scene.auxTables.first.rows.first,
        orders = frame.scene.auxTables[1].rows.first;
    final linked = input.kind == StackKind.linked,
        shared = input.kind == StackKind.shared;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress),
        scale = MediaQuery.textScalerOf(context).scale(1);
    final width = linked
        ? 112.0 * (input.a.length + 1) + 150
        : shared
        ? input.capacity * 64.0 + 280
        : 600.0;
    final height = linked
        ? 540.0
        : shared
        ? 400.0
        : 250 + input.capacity * 88.0;
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
                if (replaySummary != null) Text(replaySummary!),
                if (highlight != null)
                  Text(
                    highlight!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      key: const ValueKey('stack-status'),
                      label: Text(row[0]),
                      backgroundColor: frame.isErrorState
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                    Chip(
                      key: const ValueKey('stack-output'),
                      label: Text('输出 e：${row[1]}'),
                    ),
                    Chip(
                      label: Text(
                        linked
                            ? '无头结点 · S 指首元'
                            : shared
                            ? 'top = [${row[2]}, ${row[3]}]'
                            : 'top−base = ${row[2]}',
                      ),
                    ),
                    if (!linked) Chip(label: Text('剩余槽 ${row[4]}')),
                  ],
                ),
                Text(
                  linked
                      ? '最左侧为栈顶；S=NULL 为空栈。灰色节点已释放。'
                      : shared
                      ? '左栈向右、右栈向左增长；top 都指有效栈顶。top[0]+1==top[1] 即满。'
                      : '从底部向上增长；top 指下一空位置。顶部单越界地址不是数据槽，不能解引用。',
                ),
                SizedBox(
                  height: math.min(
                    height,
                    math.max(
                      240 * math.min(scale, 1.3),
                      c.maxHeight - 140 * scale,
                    ),
                  ),
                  child: DsStageCanvas(
                    key: ValueKey('stack-${input.raw}'),
                    scene: scene,
                    sceneSize: Size(width, height),
                  ),
                ),
                Text(
                  '${shared ? '左栈' : '栈'}（底→顶）：${orders[0].isEmpty ? '空' : orders[0]}',
                  key: const ValueKey('stack-order'),
                ),
                if (shared)
                  Text(
                    '右栈（底→顶）：${orders[1].isEmpty ? '空' : orders[1]}',
                    key: const ValueKey('stack-right-order'),
                  ),
                const SizedBox(height: 8),
                Text(
                  frame.explanation,
                  style: frame.isErrorState
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
                Text(
                  '栈字段/数据写入 ${frame.metrics.writes} · 读取 ${frame.metrics.reads} · 新分配 ${frame.metrics.allocations}',
                ),
                const SizedBox(height: 12),
                StackTheory(input: input),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StackTheory extends StatelessWidget {
  const StackTheory({super.key, required this.input});
  final StackInput input;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '算法 3.1～3.8 · 三种栈顶约定',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const Text(
        '顺序栈：base 指数据区起点，top 指下一空位置；空时 top==base，满时 top−base==stacksize。Push 先 *top=e 再 top++；Pop 先 --top 再 e=*top；GetTop 读取 *(top−1)，不移动 top。',
      ),
      const SizedBox(height: 8),
      const Text(
        '无头链栈：S 直接指栈顶数据节点；空栈 S=NULL，Init 无需分配。Push 先 p.next=S，再 S=p；Pop 先读值、保存 p、移动 S，再释放 p。S 变为 NULL 时不能再解引用它。',
      ),
      const SizedBox(height: 8),
      const Text(
        '共享双栈：左栈顶初值 −1，右栈顶初值 capacity；都指有效元素，与顺序栈 top 约定不同。Push 先向中间调整 top 再写槽；Pop 先取值再向外调整 top。没有固定分区，一栈可使用全部空闲空间。',
      ),
      const SizedBox(height: 8),
      const Text(
        '每个操作独立使用编辑框中的初始数据；Init 创建新空栈，不能当作销毁已有栈使用。Push/Pop/GetTop 为 O(1)，链栈 Push 需要一个新节点。Dart 用下标或对象引用表达 C 指针，GC 不保证立即回收；初始化 List 的填充成本为 O(capacity)。地址均为教学模拟。',
      ),
    ],
  );
}
