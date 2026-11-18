import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch1_intro/complexity_lab.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/trace_model.dart';

int growthNAt(double x, double width) =>
    (1 + (x - 42) / math.max(1, width - 54) * 31).round().clamp(1, 32);
String growthNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
  return value.toStringAsFixed(3);
}

class ComplexityStage extends StatelessWidget {
  const ComplexityStage({super.key, required this.input, required this.frame});
  final ComplexityInput input;
  final TraceFrame frame;
  @override
  Widget build(BuildContext context) {
    if (input.mode == ComplexityMode.growth) return GrowthChart(n: input.n);
    if (input.mode == ComplexityMode.reverse) {
      return LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          primary: false,
          child: SizedBox(
            height: math.max(400, c.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  frame.phaseTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('上：原地 a 与紫色临时变量 t；下：只读 source 与副本 b'),
                Wrap(
                  spacing: 12,
                  children: [
                    for (final row
                        in frame.scene.auxTables
                            .singleWhere((t) => t.id == 'space')
                            .rows)
                      Chip(
                        label: Text(
                          '${row[0]}：${row[1]} 槽 · ${row[2]} · 写 ${row[3]} 次',
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: DsStageCanvas(
                    key: ValueKey('reverse-stage-${input.n}'),
                    scene: frame.scene,
                    sceneSize: Size(math.max(550, input.n * 56 + 48), 340),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final matrix = frame.scene.auxTables
        .where((t) => t.id == 'matrix-C')
        .firstOrNull;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(frame.phaseTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final e in frame.inlineVars.entries)
              Chip(label: Text('${e.key} = ${e.value}')),
          ],
        ),
        const SizedBox(height: 12),
        Text('追踪步骤 ${frame.stepIndex} · 元素比较 ${frame.metrics.comparisons}'),
        const SizedBox(height: 12),
        if (matrix != null) ...[
          const Text('矩阵 C（· 表示尚未初始化）'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: [
                for (final c in matrix.columns) DataColumn(label: Text(c)),
              ],
              rows: [
                for (var i = 0; i < matrix.rows.length; i++)
                  DataRow(
                    color: matrix.highlightedRows.contains(i)
                        ? WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primaryContainer,
                          )
                        : null,
                    cells: [for (final v in matrix.rows[i]) DataCell(Text(v))],
                  ),
              ],
            ),
          ),
        ],
        if (input.mode == ComplexityMode.search) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final node in frame.scene.nodes)
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: node.visualState == NodeVisualState.comparing
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(node.label),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '成功查找：最好 1，最坏 ${input.n}；等概率平均 ${(input.n + 1) / 2}。失败：${input.n} 次。',
          ),
        ],
        const SizedBox(height: 16),
        const Text('源码右侧热力条：循环行计进入循环体次数；其余标注行计语句执行次数。条长按当前最大频度归一化。'),
        const SizedBox(height: 12),
        Text(frame.explanation),
      ],
    );
  }
}

class GrowthChart extends StatefulWidget {
  const GrowthChart({super.key, required this.n});
  final int n;
  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  int? inspected;
  bool logarithmic = true;
  static const palette = [
    Colors.grey,
    Colors.cyan,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.pink,
    Colors.purple,
  ];
  @override
  void didUpdateWidget(GrowthChart old) {
    super.didUpdateWidget(old);
    if (old.n != widget.n) inspected = null;
  }

  @override
  Widget build(BuildContext context) {
    final n = inspected ?? widget.n, values = growthValues(n);
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          '七种增长量级 · n=$n',
          key: const ValueKey('growth-inspection'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              key: const ValueKey('growth-log-scale'),
              label: const Text('对数纵轴 log₁₀(1+y)'),
              selected: logarithmic,
              onSelected: (v) => setState(() => logarithmic = v),
            ),
            const Text('横轴 n=1～32 · 悬停或点击查看'),
          ],
        ),
        SizedBox(
          height: 280,
          child: LayoutBuilder(
            builder: (context, c) => MouseRegion(
              onHover: (event) => setState(
                () => inspected = growthNAt(event.localPosition.dx, c.maxWidth),
              ),
              onExit: (_) => setState(() => inspected = null),
              child: GestureDetector(
                key: const ValueKey('growth-plot'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => setState(
                  () => inspected = growthNAt(d.localPosition.dx, c.maxWidth),
                ),
                child: Semantics(
                  label: '七条增长曲线，当前 n=$n',
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GrowthPainter(
                            n,
                            logarithmic,
                            palette,
                            colors.outlineVariant,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 42,
                        bottom: 0,
                        child: Text('1', style: TextStyle(fontSize: 11)),
                      ),
                      const Positioned(
                        right: 12,
                        bottom: 0,
                        child: Text('32 (n)', style: TextStyle(fontSize: 11)),
                      ),
                      Positioned(
                        left: 0,
                        top: 2,
                        child: Text(
                          logarithmic ? '10¹⁰' : '2³²',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const Positioned(
                        left: 24,
                        bottom: 24,
                        child: Text('0', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (n >= 20)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '指数增长：2^$n = ${growthNumber(values['2ⁿ']!)}',
              key: const ValueKey('growth-exponential-warning'),
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < values.length; i++)
              Chip(
                avatar: Icon(Icons.show_chart, color: palette[i]),
                label: Text(
                  '${values.keys.elementAt(i)} = ${growthNumber(values.values.elementAt(i))}',
                ),
                key: ValueKey('growth-value-$i'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          logarithmic
              ? '对数纵轴用于同时辨认不同量级，不把折线高度当作原始次数；精确函数值见上方。'
              : '线性纵轴按 2³² 设置上限，较低阶曲线会靠近横轴；可切换对数纵轴比较趋势。',
        ),
        const Text('这些是渐近分析的参考函数，不是所有程序的精确操作次数；n·log₂n 等函数可为非整数。'),
      ],
    );
  }
}

class _GrowthPainter extends CustomPainter {
  _GrowthPainter(this.n, this.logarithmic, this.palette, this.axisColor);
  final int n;
  final bool logarithmic;
  final List<Color> palette;
  final Color axisColor;
  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(
      42,
      12,
      math.max(1, size.width - 54),
      size.height - 40,
    );
    final axis = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(plot.bottomLeft, plot.topLeft, axis);
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    final maximum = logarithmic ? 10.0 : math.pow(2, 32).toDouble();
    double y(double v) =>
        plot.bottom -
        ((logarithmic ? math.log(1 + v) / math.ln10 : v) / maximum) *
            plot.height;
    double x(int v) => plot.left + (v - 1) / 31 * plot.width;
    for (var f = 0; f < 7; f++) {
      final path = Path();
      for (var i = 1; i <= 32; i++) {
        final v = growthValues(i).values.elementAt(f);
        if (i == 1) {
          path.moveTo(x(i), y(v));
        } else {
          path.lineTo(x(i), y(v));
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = palette[f]
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        Offset(x(n), y(growthValues(n).values.elementAt(f))),
        3,
        Paint()..color = palette[f],
      );
    }
    canvas.drawLine(Offset(x(n), plot.top), Offset(x(n), plot.bottom), axis);
  }

  @override
  bool shouldRepaint(_GrowthPainter old) =>
      old.n != n ||
      old.logarithmic != logarithmic ||
      old.axisColor != axisColor;
}
