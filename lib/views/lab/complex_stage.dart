import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../curriculum/ch1_intro/adt_complex.dart';
import '../../models/trace_model.dart';

SceneSnapshot complexMemory(SceneSnapshot scene) => SceneSnapshot(
  nodes: scene.nodes.where((n) => n.groupTag == 'memory').toList(),
  pointers: scene.pointers,
  auxTables: scene.auxTables.where((t) => t.id == 'complex-memory').toList(),
);

/// Interpolates pedagogical geometry only; memory values remain frame snapshots.
class ComplexPlaneGeometry {
  ComplexPlaneGeometry(
    TraceFrame frame,
    TraceFrame next,
    double t,
    ComplexOperation op,
  ) {
    List<double> params(TraceFrame f) => f.scene.auxTables
        .singleWhere((v) => v.id == 'complex-geometry')
        .rows
        .single
        .map(double.parse)
        .toList();
    final f = params(frame), n = params(next);
    point(String id, TraceFrame frame) {
      final p = frame.scene.nodes.singleWhere((v) => v.id == id);
      return Offset(p.x, p.y);
    }

    a = point('A', frame);
    b = point('B', frame);
    limit = f[1];
    progress = lerpDouble(f[0], n[0], t)!;
    final polar =
        op == ComplexOperation.multiply || op == ComplexOperation.divide;
    if (polar) {
      final radius = lerpDouble(f[2], n[2], t)!,
          angle = lerpDouble(f[3], n[3], t)!;
      result = Offset(radius * math.cos(angle), radius * math.sin(angle));
    } else {
      result = Offset.lerp(point('R', frame), point('R', next), t)!;
    }
  }
  late final Offset a, b, result;
  late final double limit, progress;
}

class ComplexStage extends StatelessWidget {
  const ComplexStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.operation,
  });
  final TraceFrame frame, next;
  final double progress;
  final ComplexOperation operation;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final geometry = ComplexPlaneGeometry(
      frame,
      next,
      reduced ? 0 : progress,
      operation,
    );
    final memory = frame.scene.auxTables.singleWhere(
      (t) => t.id == 'complex-memory',
    );
    final colors = Theme.of(context).colorScheme;
    final getter =
        operation == ComplexOperation.getReal ||
        operation == ComplexOperation.getImag;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    frame.phaseTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final size = Size(c.maxWidth, c.maxHeight);
                        final scale =
                            math.max(
                              1.0,
                              math.min(size.width, size.height) - 52,
                            ) /
                            (2 * geometry.limit);
                        Offset screen(Offset p) => Offset(
                          size.width / 2 + p.dx * scale,
                          size.height / 2 - p.dy * scale,
                        );
                        final endpoints = {
                          'A': geometry.a,
                          if (operation != ComplexOperation.creat && !getter)
                            'B': geometry.b,
                          if (geometry.progress > 0) 'R': geometry.result,
                        };
                        return Semantics(
                          label: '复平面，A 与 B 为输入，R 为几何结果',
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _ComplexPlanePainter(
                                    geometry,
                                    operation,
                                    colors,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                top: size.height / 2 + 4,
                                child: const Text(
                                  'Re',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              Positioned(
                                left: size.width / 2 + 4,
                                top: 0,
                                child: const Text(
                                  'Im',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              for (final entry in endpoints.entries)
                                Positioned(
                                  left: (screen(entry.value).dx + 6).clamp(
                                    0.0,
                                    math.max(0, size.width - 28),
                                  ),
                                  top: (screen(entry.value).dy - 20).clamp(
                                    0.0,
                                    math.max(0, size.height - 24),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: entry.key == 'R'
                                          ? colors.tertiary
                                          : entry.key == 'A'
                                          ? colors.primary
                                          : colors.secondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    'A=${frame.inlineVars['A']}   B=${frame.inlineVars['B']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '每轴范围 ±${ComplexValue.number(geometry.limit)} · ${getter ? '返回值：${frame.inlineVars['返回值'] ?? '尚未读取'}' : 'R 为几何结果，C 按下面两次赋值更新'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          getter
              ? '读取操作不写入 C'
              : '${frame.scene.pointers.isEmpty ? '调用方 C' : '形参 C ≡ 调用方 C'} · 0x3020',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(
          height:
              116 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.7),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final row in [memory.rows[2], ...memory.rows.take(2)])
                  SizedBox(
                    width: 168 * MediaQuery.textScalerOf(context).scale(1),
                    child: Card(
                      color: row[0] == 'C' && memory.highlightedRows.contains(2)
                          ? colors.primaryContainer
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${row[0]} @ ${row[1]}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              'realpart = ${row[2]}',
                              key: ValueKey('complex-${row[0]}-real'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'imagpart = ${row[3]}',
                              key: ValueKey('complex-${row[0]}-imag'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    const contract = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ADT Complex', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text('D · 数据域\n(r, i) ∈ ℝ²'),
        SizedBox(height: 12),
        Text('S · 结构\n复数值间没有固定的前驱/后继'),
        SizedBox(height: 12),
        Text('P · 操作\nCreat\nGetReal / GetImag\nAdd / Sub\nMultiply / Divide'),
        SizedBox(height: 12),
        Text('封装边界\n调用者使用操作契约，内部可选实部/虚部表示。'),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        primary: false,
        child: SizedBox(
          height: math.max(
            c.maxHeight,
            440 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
          ),
          child: c.maxWidth >= 700
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Card(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: contract,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: content),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton.icon(
                      key: const ValueKey('complex-contract'),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('抽象数据类型'),
                          content: const SingleChildScrollView(child: contract),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('ADT Complex · 查看 D / S / P'),
                    ),
                    Expanded(child: content),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ComplexPlanePainter extends CustomPainter {
  _ComplexPlanePainter(this.g, this.operation, this.colors);
  final ComplexPlaneGeometry g;
  final ComplexOperation operation;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final scale =
        math.max(1.0, math.min(size.width, size.height) - 52) / (2 * g.limit);
    Offset screen(Offset p) =>
        Offset(size.width / 2 + p.dx * scale, size.height / 2 - p.dy * scale);
    final origin = screen(Offset.zero);
    final axis = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axis);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axis);
    for (var i = -4; i <= 4; i++) {
      final x = screen(Offset(g.limit * i / 4, 0)).dx,
          y = screen(Offset(0, g.limit * i / 4)).dy;
      canvas.drawLine(Offset(x, origin.dy - 3), Offset(x, origin.dy + 3), axis);
      canvas.drawLine(Offset(origin.dx - 3, y), Offset(origin.dx + 3, y), axis);
    }
    void arrow(Offset from, Offset to, Color color, {bool dashed = false}) {
      final p = screen(from), q = screen(to), delta = q - p;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;
      if (delta.distance < .5) {
        canvas.drawCircle(q, 3, paint);
        return;
      }
      if (dashed) {
        final distance = delta.distance;
        for (var d = 0.0; d < distance; d += 10) {
          canvas.drawLine(
            p + delta * (d / distance),
            p + delta * (math.min(d + 5, distance) / distance),
            paint,
          );
        }
      } else {
        canvas.drawLine(p, q, paint);
      }
      final unit = delta / delta.distance, normal = Offset(-unit.dy, unit.dx);
      canvas.drawPath(
        Path()
          ..moveTo(q.dx, q.dy)
          ..lineTo(
            (q - unit * 8 + normal * 4).dx,
            (q - unit * 8 + normal * 4).dy,
          )
          ..moveTo(q.dx, q.dy)
          ..lineTo(
            (q - unit * 8 - normal * 4).dx,
            (q - unit * 8 - normal * 4).dy,
          ),
        paint,
      );
    }

    arrow(Offset.zero, g.a, colors.primary);
    final getter =
        operation == ComplexOperation.getReal ||
        operation == ComplexOperation.getImag;
    if (operation != ComplexOperation.creat && !getter) {
      arrow(Offset.zero, g.b, colors.secondary);
    }
    if (operation == ComplexOperation.add ||
        operation == ComplexOperation.sub) {
      final b = operation == ComplexOperation.sub ? -g.b : g.b;
      if (operation == ComplexOperation.sub) {
        arrow(Offset.zero, b, colors.secondary, dashed: true);
      }
      arrow(
        g.a * g.progress,
        g.a * g.progress + b,
        colors.secondary,
        dashed: true,
      );
      if (g.progress > 0) {
        arrow(b, b + g.a * g.progress, colors.primary, dashed: true);
      }
    }
    if (g.progress > 0) arrow(Offset.zero, g.result, colors.tertiary);
    if (getter) {
      final projection = operation == ComplexOperation.getReal
          ? Offset(g.a.dx, 0)
          : Offset(0, g.a.dy);
      arrow(g.a, projection, colors.tertiary, dashed: true);
    }
  }

  @override
  bool shouldRepaint(_ComplexPlanePainter old) =>
      old.g != g || old.operation != operation || old.colors != colors;
}
