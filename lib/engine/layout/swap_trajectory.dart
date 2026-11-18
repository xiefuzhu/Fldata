import 'dart:math' as math;
import '../../models/trace_model.dart';

abstract final class SwapTrajectory {
  static Vec2 position(Vec2 from, Vec2 to, double t) {
    if (![from.x, from.y, to.x, to.y, t].every((v) => v.isFinite)) {
      throw ArgumentError('Nonfinite trajectory');
    }
    if (t <= 0) return from;
    if (t >= 1) return to;
    final dx = to.x - from.x;
    final height = math.min(56.0, .25 * dx.abs() + 18);
    return Vec2(
      x: from.x + dx * t,
      y:
          from.y +
          (to.y - from.y) * t -
          dx.sign * math.sin(math.pi * t) * height,
    );
  }

  /// Only opposing, same-row swaps. Vertical/tree moves retain their own layout.
  static Set<String> swappedIds(
    Map<String, SceneNode> before,
    Map<String, SceneNode> after,
  ) {
    final result = <String>{};
    bool near(double a, double b) => (a - b).abs() < 1e-8;
    final destinations = <(double, double), List<SceneNode>>{};
    for (final a in before.values) {
      destinations.putIfAbsent((a.x, a.y), () => []).add(a);
    }
    for (final a in before.values) {
      final b = after[a.id];
      if (b == null || near(a.x, b.x) || !near(a.y, b.y)) continue;
      for (final other in destinations[(b.x, b.y)] ?? const <SceneNode>[]) {
        final moved = after[other.id];
        if (other.id != a.id &&
            moved != null &&
            near(moved.x, a.x) &&
            near(moved.y, a.y)) {
          result.add(a.id);
          result.add(other.id);
        }
      }
    }
    return result;
  }
}
