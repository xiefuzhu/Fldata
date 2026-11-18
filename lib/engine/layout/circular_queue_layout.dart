import 'dart:math' as math;
import '../../models/trace_model.dart';
import '../vm/trace_validation.dart';

abstract final class CircularQueueLayout {
  static const turn = 2 * math.pi;
  static double slotAngle(int index, int capacity) {
    if (capacity < 2 || index < 0 || index >= capacity) {
      throw ArgumentError('Invalid circular queue slot');
    }
    return -math.pi / 2 + turn * index / capacity;
  }

  /// The minimum nonnegative clockwise sweep, not a signed shortest path.
  static double clockwiseDelta(double from, double to) {
    if (!from.isFinite || !to.isFinite) throw ArgumentError('Nonfinite angle');
    return ((to - from) % turn + turn) % turn;
  }

  static PointerOrbit interpolate(
    PointerOrbit from,
    PointerOrbit to,
    double t,
  ) {
    if (!t.isFinite) throw ArgumentError.value(t, 't');
    if (t <= 0) return from;
    if (t >= 1) return to;
    return PointerOrbit(
      center: Vec2(
        x: from.center.x + (to.center.x - from.center.x) * t,
        y: from.center.y + (to.center.y - from.center.y) * t,
      ),
      radius: from.radius + (to.radius - from.radius) * t,
      angle: from.angle + clockwiseDelta(from.angle, to.angle) * t,
    );
  }

  static Vec2 position(PointerOrbit orbit) => Vec2(
    x: orbit.center.x + math.cos(orbit.angle) * orbit.radius,
    y: orbit.center.y + math.sin(orbit.angle) * orbit.radius,
  );

  static SceneSnapshot arrange(
    List<SceneNode> slots, {
    required int front,
    required int rear,
    Vec2 center = const Vec2(x: 290, y: 190),
    double radius = 100,
  }) {
    final capacity = slots.length;
    slotAngle(front, capacity);
    slotAngle(rear, capacity);
    if (!center.x.isFinite ||
        !center.y.isFinite ||
        !radius.isFinite ||
        radius <= 0) {
      throw ArgumentError('Invalid queue geometry');
    }
    final count = (rear - front + capacity) % capacity;
    final full = (rear + 1) % capacity == front;
    final nodes = [
      for (var i = 0; i < capacity; i++)
        slots[i].copyWith(
          x: center.x + radius * math.cos(slotAngle(i, capacity)) - 28,
          y: center.y + radius * math.sin(slotAngle(i, capacity)) - 24,
          width: 56,
          height: 48,
          shape: NodeShape.arraySlot,
          indexBadge: '[$i]',
          logicBadge: null,
          visualState: (i - front + capacity) % capacity < count
              ? NodeVisualState.active
              : NodeVisualState.normal,
        ),
    ];
    final result = SceneSnapshot(
      layoutMode: SceneLayoutMode.circularQueue,
      nodes: nodes,
      pointers: [
        PointerBadge(
          id: 'front',
          label: 'front',
          targetNodeId: slots[front].id,
          orbit: PointerOrbit(
            center: center,
            radius: radius + 50,
            angle: slotAngle(front, capacity),
          ),
        ),
        PointerBadge(
          id: 'rear',
          label: 'rear',
          targetNodeId: slots[rear].id,
          orbit: PointerOrbit(
            center: center,
            radius: radius + 70,
            angle: slotAngle(rear, capacity),
          ),
        ),
      ],
      zones: [
        if (full)
          SceneZoneOverlay(
            id: 'queue-reserved',
            label: '(rear+1)%M == front：留空防冲突位',
            x: nodes[rear].x - 4,
            y: nodes[rear].y - 4,
            width: 64,
            height: 56,
            pattern: ZonePattern.hatched,
            visualState: NodeVisualState.sentinel,
          ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'queue-state',
          title: '循环队列',
          columns: const ['front', 'rear', '长度', '可用容量', '状态'],
          rows: [
            [
              front.toString(),
              rear.toString(),
              count.toString(),
              (capacity - 1).toString(),
              full
                  ? '满'
                  : count == 0
                  ? '空'
                  : '可入队',
            ],
          ],
        ),
      ],
    );
    validateScene(result);
    return result;
  }
}
