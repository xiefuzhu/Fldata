import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch3_stack_queue/cases_expr_dance.dart';
import '../../curriculum/ch3_stack_queue/cases_trace.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/trace_model.dart';

class CasesExprDanceStage extends StatelessWidget {
  const CasesExprDanceStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final CasesInput input;
  @override
  Widget build(BuildContext context) {
    final tables = frame.scene.auxTables,
        row = tables[0].rows.first,
        colors = Theme.of(context).colorScheme;
    String value(String s) =>
        input.kind == CaseKind.expression && double.tryParse(s) != null
        ? caseNumber(double.parse(s))
        : s;
    Widget canvas(double height) => SizedBox(
      height: height,
      child: DsStageCanvas(
        key: ValueKey('cases-scene-${input.raw}'),
        scene: SceneInterpolator.lerp(frame.scene, next.scene, progress),
        sceneSize: const Size(630, 630),
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
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
                    key: const ValueKey('case-status'),
                    label: Text(row[0]),
                    backgroundColor: frame.isErrorState
                        ? colors.errorContainer
                        : null,
                  ),
                  Chip(
                    key: const ValueKey('case-output'),
                    label: Text('输出：${row[1].isEmpty ? '—' : row[1]}'),
                  ),
                  if (input.kind == CaseKind.dance)
                    Chip(label: Text('第 ${row[5]} 曲')),
                ],
              ),
              if (input.kind == CaseKind.expression ||
                  input.kind == CaseKind.brackets) ...[
                const Text('输入（忽略空白）'),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < tables[1].rows.length; i++)
                      Container(
                        key: ValueKey('case-token-$i'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tables[1].highlightedRows.contains(i)
                                ? colors.primary
                                : colors.outlineVariant,
                          ),
                          color: tables[1].highlightedRows.contains(i)
                              ? (frame.isErrorState
                                    ? colors.errorContainer
                                    : colors.primaryContainer)
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tables[1].rows[i][1],
                          style: const TextStyle(fontFamily: 'JetBrainsMono'),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              for (var k = 2; k <= 3; k++)
                if (k == 2 ||
                    input.kind == CaseKind.expression ||
                    input.kind == CaseKind.dance)
                  Text(
                    '${tables[k].title}（${input.kind == CaseKind.dance ? '首→尾' : '底→顶'}）：${tables[k].rows.isEmpty ? '空' : tables[k].rows.map((r) => value(r[1])).join(' → ')}',
                    key: ValueKey('case-container-$k'),
                  ),
              if (input.kind == CaseKind.expression &&
                  c.maxWidth >=
                      720 * MediaQuery.textScalerOf(context).scale(1) &&
                  c.maxHeight > 500)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 344 * MediaQuery.textScalerOf(context).scale(1),
                      child: PrecedenceMatrix(
                        top: row[3],
                        current: row[2],
                        relation: row[4],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: canvas(math.min(540, c.maxHeight - 220))),
                  ],
                )
              else ...[
                if (input.kind == CaseKind.expression) ...[
                  const SizedBox(height: 12),
                  PrecedenceMatrix(
                    top: row[3],
                    current: row[2],
                    relation: row[4],
                  ),
                ],
                canvas(math.max(320, math.min(600, c.maxHeight * .65))),
              ],
              const Text('画布：上排为第一容器，中排为第二容器，下排为取出项 / 本曲舞池。'),
              const SizedBox(height: 8),
              Text(
                frame.explanation,
                key: const ValueKey('case-explanation'),
                style: frame.isErrorState
                    ? TextStyle(color: colors.error)
                    : null,
              ),
              Text(
                '容器读取 ${frame.metrics.reads} · 写入 ${frame.metrics.writes} · 比较 ${frame.metrics.comparisons} · 峰值容器项 ${frame.metrics.peakAuxiliarySpace}',
              ),
              if (tables[4].rows.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('输出 / 配对记录'),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final h in tables[4].rows)
                      Chip(label: Text('${h[0]}：${h[1]}')),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const CasesTheory(),
            ],
          ),
        ),
      ),
    );
  }
}

class PrecedenceMatrix extends StatelessWidget {
  const PrecedenceMatrix({
    super.key,
    required this.top,
    required this.current,
    required this.relation,
  });
  final String top, current, relation;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = relation.isNotEmpty;
    final r = OperatorPrecedence.operators.indexOf(top),
        c = OperatorPrecedence.operators.indexOf(current);
    final extent = 42.0 * MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '表 3.1 · 行：OPTR 栈顶；列：当前输入${active ? ' · $top / $current → ${relation == '!' ? '报错' : relation}' : ''}',
          key: const ValueKey('precedence-caption'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              for (var y = -1; y < 7; y++)
                Row(
                  children: [
                    for (var x = -1; x < 7; x++)
                      Container(
                        key: ValueKey('precedence-$y-$x'),
                        width: extent,
                        height: extent,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colors.outlineVariant,
                            width: .5,
                          ),
                          color: active && y == r && x == c
                              ? colors.primaryContainer
                              : active && (y == r || x == c)
                              ? colors.secondaryContainer.withValues(alpha: .55)
                              : colors.surfaceContainer,
                        ),
                        child: Text(
                          y == -1
                              ? (x == -1
                                    ? '栈/入'
                                    : OperatorPrecedence.operators[x])
                              : x == -1
                              ? OperatorPrecedence.operators[y]
                              : OperatorPrecedence.rows[y][x] == '!'
                              ? '错'
                              : OperatorPrecedence.rows[y][x],
                          style: TextStyle(
                            fontWeight: active && y == r && x == c
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CasesTheory extends StatelessWidget {
  const CasesTheory({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '数制转换：反复 N%d 入栈、N~/d，弹栈输出高位到低位。N=0 单独压入 0；进制 2/8/16。时间和辅助栈空间 O(log_d(N+1))，零为常数特例。',
      ),
      SizedBox(height: 8),
      Text(
        '括号匹配：左括号入栈；右括号遇空栈为右冗余，弹出后类型不同为不匹配，扫描完仍有左括号为左冗余。时间 O(n)，最坏栈空间 O(n)。',
      ),
      SizedBox(height: 8),
      Text(
        '算符优先：< 压入 OPTR，= 脱括号，> 弹 b、a、theta 后计算 a theta b 并压回 OPND；归约不移动输入。# 与 # 相遇后返回唯一操作数。支持多位整数，采用 double 实数除法；不支持一元负号。矩阵中的“错”对应无效括号关系。时间 O(n)，双栈空间 O(n)。',
      ),
      SizedBox(height: 8),
      Text(
        '舞伴配对：男、女队均遵循 FIFO。每曲配至一队为空，等待者保留队首；已配对者曲终依次回队尾。本课以多轮扩展教材单曲，姓名为模拟数据。每轮配对 O(min(m,f)) 次；Dart List.removeAt(0) 和 C 顺序数组移动还有线性成本，循环队列可使单次出队 O(1)。',
      ),
      SizedBox(height: 8),
      Text('画布的视觉容器和取出区用于解释算法。计数为教学语义操作；峰值容器项不包含输出、输入、轨迹存储或舞池暂存。'),
    ],
  );
}
