import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch2_linear_list/cases_polyn_book.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/canvas/ds_stage_canvas.dart';

class CasesPolynBookStage extends StatelessWidget {
  const CasesPolynBookStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
    this.onUseBooks,
  });
  final TraceFrame frame, next;
  final double progress;
  final CasesInput input;
  final VoidCallback? onUseBooks;
  @override
  Widget build(BuildContext context) {
    final row = frame.scene.auxTables.first.rows.first, isBook = input.isBook;
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final sums = <int, double>{};
    for (final t in [...input.a, ...input.b]) {
      sums.update(
        t.exponent,
        (c) => c + t.coefficient,
        ifAbsent: () => t.coefficient,
      );
    }
    final count = input.operation == CaseOperation.create
        ? input.a.length
        : math.max(
            math.max(input.a.length, input.b.length),
            sums.values.where((v) => v != 0).length,
          );
    final width = isBook
        ? (input.linked ? 136.0 * (input.books.length + 2) + 120 : 1080.0)
        : 130.0 * (count + 1) + 140;
    final height = isBook ? 520.0 : 650.0,
        scale = MediaQuery.textScalerOf(context).scale(1);
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
                      key: const ValueKey('cases-status'),
                      label: Text(row[0]),
                      backgroundColor: frame.isErrorState
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                    ),
                    Chip(
                      label: Text(
                        isBook
                            ? '${input.linked ? '链式' : '顺序'} · 有效 ${row[2]} 本'
                            : '已释放数据节点 ${row[2]}',
                      ),
                    ),
                    if (!isBook && row[3] != '0')
                      Chip(label: Text('暂存悬空 next ${row[3]} 条')),
                    Chip(
                      label: Text(
                        '比较 ${frame.metrics.comparisons} · 写入 ${frame.metrics.writes}',
                      ),
                    ),
                  ],
                ),
                Text(
                  isBook
                      ? '记录包含编号、书名、价格。下标从 0、位序从 1 开始。'
                      : '上两行是输入链，下行是结果。蓝边为接链写入，灰色节点已释放；红边是尚未覆盖的悬空引用，不解引用。',
                ),
                SizedBox(
                  height: math.max(height, 440 * scale),
                  child: DsStageCanvas(
                    key: ValueKey('cases-${input.raw}'),
                    scene: scene,
                    sceneSize: Size(width, height),
                  ),
                ),
                Text(
                  isBook
                      ? '选中记录：${row[1]}'
                      : '${row[0] == '完成' ? '结果' : '已确定结果'}：${row[1]}',
                  key: const ValueKey('cases-result'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  frame.explanation,
                  style: frame.isErrorState
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
                Text(
                  '读取 ${frame.metrics.reads} · 值复制 ${frame.metrics.moves} · 新分配 ${frame.metrics.allocations}',
                ),
                if (isBook) ...[
                  FilledButton.tonal(
                    key: const ValueKey('book-use-result'),
                    onPressed: onUseBooks,
                    child: const Text('将结果作为当前书库'),
                  ),
                  const Text('当前有效书库（本课会话数据）'),
                  for (final b
                      in frame.scene.auxTables
                          .singleWhere((t) => t.id == 'books')
                          .rows)
                    Card(
                      child: ListTile(
                        title: Text('${b[0]} · ${b[1]}'),
                        subtitle: Text('¥${b[2]}'),
                      ),
                    ),
                ] else ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final density = frame.scene.auxTables
                          .singleWhere((t) => t.id == 'density')
                          .rows
                          .first;
                      return Text(
                        'A 稠密表示：${density[0]} 个系数槽，其中 ${density[2]} 个为零；稀疏表示：${density[1]} 个数据节点 + 头结点。',
                        key: const ValueKey('polynomial-density'),
                      );
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final r
                            in frame.scene.auxTables
                                .singleWhere((t) => t.id == 'dense')
                                .rows)
                          Container(
                            width: 72 * scale,
                            height: 70 * scale,
                            margin: const EdgeInsets.all(2),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              color: r[1] == '0'
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '[${r[0]}]',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(r[1]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                CasesTheory(input: input),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CasesTheory extends StatelessWidget {
  const CasesTheory({super.key, required this.input});
  final CasesInput input;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        input.isBook ? '案例 2.3 · 图书表' : '案例 2.1 / 2.2 · 稠密与稀疏',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(
        input.isBook
            ? '按编号线性查找 O(n)。顺序表插删需要搬移记录；链表按位序定位 O(n)，已知前驱后接链 O(1)。插入先检查编号唯一性。顺序表容量 8；链式也限制为 8 本教学展示，不能据此说链表物理容量为 8。图书内容和价格均为虚构演示。'
            : '指数 17 的多项式用系数数组需 18 槽，即使只有 4 项非零也不能省略中间下标；稀疏链只存非零项，但每项额外存 expn/next。这里比较槽与节点数量，不把不同大小对象直接当作相同字节成本。',
      ),
      const SizedBox(height: 8),
      if (!input.isBook)
        const Text(
          'CreatePolyn（2.18）按输入次序逐项寻找前驱并插入，最坏 O(n²)。AddPolyn（2.19）双游标合并 O(m+n)：同指数非零和保留 A、释放 B；和为零释放两节点。释放前先保存后继，结果不保留零项。Dart GC 不承诺与 C99 free 同时回收。',
        ),
      const SizedBox(height: 8),
      const Text(
        '地址为教学模拟，动画位置不代表真实内存迁移。回退读取旧快照；输入与书库续用仅作用于当前课程会话，学习时间与完成标记另行保存。',
      ),
    ],
  );
}
