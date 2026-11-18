import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch3_stack_queue/queue_sq_link.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/layout/circular_queue_layout.dart';
import '../../models/trace_model.dart';

class QueueSqLinkStage extends StatelessWidget {
  const QueueSqLinkStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final QueueInput input;
  @override
  Widget build(BuildContext context) {
    final linked = input.kind == QueueKind.linked,
        ring = input.kind == QueueKind.circular,
        demo = input.operation == QueueOperation.demo;
    final cap = demo ? 5 : input.capacity,
        row = frame.scene.auxTables.first.rows.first,
        scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final width = linked
        ? 112.0 * (input.values.length + 2) + 120
        : ring
        ? 600.0
        : cap * 64.0 + 240;
    final height = linked
        ? 540.0
        : ring
        ? 540.0
        : 400.0;
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
                    key: const ValueKey('queue-status'),
                    label: Text(row[0]),
                    backgroundColor: frame.isErrorState
                        ? Theme.of(context).colorScheme.errorContainer
                        : null,
                  ),
                  Chip(label: Text('输出：${row[1]}')),
                  Chip(label: Text('长度 ${row[4]}')),
                  if (!linked)
                    Chip(label: Text('front=${row[2]} · rear=${row[3]}')),
                ],
              ),
              Text(
                linked
                    ? 'front 始终指头结点，rear 指最后节点；空队时两端同指头结点。'
                    : ring
                    ? 'M=$cap，最多 ${cap - 1} 个元素；斜线扇区为满队时保留空位。'
                    : 'M=$cap，rear 只增不绕回；斜线区为已出队但无法复用的前端槽。',
              ),
              SizedBox(
                height: math.min(
                  height,
                  math.max(
                    240 * math.min(scale, 1.3),
                    c.maxHeight - 170 * scale,
                  ),
                ),
                child: DsStageCanvas(
                  key: ValueKey('queue-${input.raw}'),
                  scene: scene,
                  sceneSize: Size(width, height),
                  backdropPainter: ring
                      ? QueueReservedSectorPainter(
                          capacity: cap,
                          rear: int.tryParse(row[3]) ?? 0,
                          visible: scene.zones.any(
                            (z) => z.id == 'queue-reserved',
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        )
                      : null,
                ),
              ),
              Text(
                '有效队序（首→尾）：${row[5].isEmpty ? '空' : row[5]}',
                key: const ValueKey('queue-order'),
              ),
              const SizedBox(height: 8),
              Text(
                frame.explanation,
                style: frame.isErrorState
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
              Text(
                '字段/数据写入 ${frame.metrics.writes} · 读取 ${frame.metrics.reads} · 新分配 ${frame.metrics.allocations}',
              ),
              if (demo) ...[
                const SizedBox(height: 8),
                const Text(
                  '固定对照：入队 1～4 → 出队 3 次 → 入队 9、10、11。切换线性/循环模式可重放相同操作；遇到错误自动暂停，可继续。',
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final h in frame.scene.auxTables[1].rows)
                      Chip(
                        label: Text(
                          '${h[0]}：${h[1]}${h[2] == '—' ? '' : ' / ${h[2]}'}',
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const QueueTheory(),
            ],
          ),
        ),
      ),
    );
  }
}

class QueueReservedSectorPainter extends CustomPainter {
  const QueueReservedSectorPainter({
    required this.capacity,
    required this.rear,
    required this.visible,
    required this.color,
  });
  final int capacity, rear;
  final bool visible;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    const center = Offset(300, 260);
    final start =
            CircularQueueLayout.slotAngle(rear, capacity) - math.pi / capacity,
        sweep = 2 * math.pi / capacity;
    final path = Path()
      ..arcTo(Rect.fromCircle(center: center, radius: 176), start, sweep, false)
      ..arcTo(
        Rect.fromCircle(center: center, radius: 92),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: .10));
    final paint = Paint()
      ..color = color.withValues(alpha: .55)
      ..strokeWidth = 2;
    for (var x = -540.0; x < 700; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x + 540, 540), paint);
    }
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: .5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(QueueReservedSectorPainter old) =>
      old.capacity != capacity ||
      old.rear != rear ||
      old.visible != visible ||
      old.color != color;
}

class QueueTheory extends StatelessWidget {
  const QueueTheory({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '循环队列：front 是首元下标，rear 是下一空槽。空：front==rear；满：(rear+1)%M==front；长度：(rear−front+M)%M。容量为 M−1，保留空位不是固定某个下标，随 rear 变化。',
      ),
      SizedBox(height: 8),
      Text('线性队列：rear==M 就拒绝入队；前端虽然已有空槽，仍会假溢出。循环队列通过模运算复用这些槽，不需要整体搬移元素。'),
      SizedBox(height: 8),
      Text(
        '带头链队：EnQueue 先 rear.next=p 再 rear=p；DeQueue 先保存 p、读取值、head.next=p.next，若 rear==p 必须 rear=front，然后释放 p。空队仍保留头结点，GetHead 读取 head.next.data。',
      ),
      SizedBox(height: 8),
      Text(
        '入队/出队/读取队首 O(1)；循环/线性求长度 O(1)，未存计数字段的链队求长度 O(n)。Init 建立新队列，不代替销毁旧队列；Dart List 填充为 O(M)，GC 不保证立即回收。每个普通操作独立使用表单初始数据；地址为模拟。',
      ),
    ],
  );
}
