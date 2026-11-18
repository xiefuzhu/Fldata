import 'dart:isolate';
import 'dart:math' as math;
import '../../models/trace_model.dart';
import '../vm/trace_snapshot.dart';
import '../vm/trace_validation.dart';

/// Coordinates are node centers in the logical canvas; pins survive re-layout.
abstract final class GraphLayoutEngine {
  static void _validate(
    SceneSnapshot scene,
    double width,
    double height,
    double padding,
    Map<String, Vec2> pins,
  ) {
    validateScene(scene);
    if (![width, height, padding].every((v) => v.isFinite) ||
        padding < 0 ||
        width <= 2 * padding ||
        height <= 2 * padding) {
      throw ArgumentError('Invalid graph bounds');
    }
    final nodes = {for (final n in scene.nodes) n.id: n};
    if (pins.keys.any((id) => !nodes.containsKey(id))) {
      throw ArgumentError('Unknown pinned node');
    }
    for (final n in nodes.values) {
      if (n.width > width - 2 * padding || n.height > height - 2 * padding) {
        throw ArgumentError('Node does not fit graph canvas');
      }
      final pin = pins[n.id];
      if (pin != null &&
          (!pin.x.isFinite ||
              !pin.y.isFinite ||
              pin !=
                  clampCenter(
                    n,
                    pin,
                    width: width,
                    height: height,
                    padding: padding,
                  ))) {
        throw ArgumentError('Pin is outside graph canvas');
      }
    }
  }

  static Vec2 clampCenter(
    SceneNode node,
    Vec2 point, {
    double width = 580,
    double height = 400,
    double padding = 32,
  }) => Vec2(
    x: point.x.clamp(
      padding + node.width / 2,
      width - padding - node.width / 2,
    ),
    y: point.y.clamp(
      padding + node.height / 2,
      height - padding - node.height / 2,
    ),
  );

  static SceneSnapshot preset(
    SceneSnapshot scene,
    Map<String, Vec2> normalized, {
    Map<String, Vec2> pins = const {},
    double width = 580,
    double height = 400,
    double padding = 32,
  }) {
    _validate(scene, width, height, padding, pins);
    if (normalized.length != scene.nodes.length ||
        !normalized.keys.toSet().containsAll(scene.nodes.map((n) => n.id)) ||
        normalized.values.any(
          (p) =>
              !p.x.isFinite ||
              !p.y.isFinite ||
              p.x < 0 ||
              p.x > 1 ||
              p.y < 0 ||
              p.y > 1,
        )) {
      throw ArgumentError(
        'Preset must supply normalized coordinates for every node',
      );
    }
    return scene.copyWith(
      layoutMode: SceneLayoutMode.graph,
      nodes: [
        for (final n in scene.nodes)
          n.copyWith(
            x: pins.containsKey(n.id)
                ? pins[n.id]!.x - n.width / 2
                : padding +
                      normalized[n.id]!.x * (width - 2 * padding - n.width),
            y: pins.containsKey(n.id)
                ? pins[n.id]!.y - n.height / 2
                : padding +
                      normalized[n.id]!.y * (height - 2 * padding - n.height),
          ),
      ],
    );
  }

  static Future<SceneSnapshot> forceDirectedAsync(
    SceneSnapshot scene, {
    Map<String, Vec2> pins = const {},
    int iterations = 80,
    int seed = 106,
    double width = 580,
    double height = 400,
    double padding = 32,
  }) {
    final owned = freezeScene(scene);
    final fixed = Map<String, Vec2>.unmodifiable(pins);
    return Isolate.run(
      () => forceDirected(
        owned,
        pins: fixed,
        iterations: iterations,
        seed: seed,
        width: width,
        height: height,
        padding: padding,
      ),
    );
  }

  static SceneSnapshot forceDirected(
    SceneSnapshot scene, {
    Map<String, Vec2> pins = const {},
    int iterations = 80,
    int seed = 106,
    double width = 580,
    double height = 400,
    double padding = 32,
  }) {
    _validate(scene, width, height, padding, pins);
    if (iterations < 60 || iterations > 100) {
      throw ArgumentError('Expected 60..100 force iterations');
    }
    final nodes = scene.nodes.toList()..sort((a, b) => a.id.compareTo(b.id));
    if (nodes.isEmpty) return scene.copyWith(layoutMode: SceneLayoutMode.graph);
    final index = {for (var i = 0; i < nodes.length; i++) nodes[i].id: i};
    final random = math.Random(seed);
    final positions = [
      for (final n in nodes)
        pins[n.id] ??
            clampCenter(
              n,
              Vec2(
                x: width * (.2 + .6 * random.nextDouble()),
                y: height * (.2 + .6 * random.nextDouble()),
              ),
              width: width,
              height: height,
              padding: padding,
            ),
    ];
    final edges =
        scene.edges
            .where(
              (e) => e.toNodeId != nullNodeId && e.fromNodeId != e.toNodeId,
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final k = math.sqrt(
      (width - 2 * padding) * (height - 2 * padding) / nodes.length,
    );
    for (var step = 0; step < iterations; step++) {
      final dx = List.filled(nodes.length, 0.0),
          dy = List.filled(nodes.length, 0.0);
      for (var i = 0; i < nodes.length; i++) {
        for (var j = i + 1; j < nodes.length; j++) {
          var x = positions[i].x - positions[j].x,
              y = positions[i].y - positions[j].y;
          if (x.abs() + y.abs() < 1e-6) {
            x = .01 * (i + 1);
            y = -.01 * (j + 1);
          }
          final distance = math.sqrt(x * x + y * y);
          final force = k * k / distance;
          dx[i] += x / distance * force;
          dy[i] += y / distance * force;
          dx[j] -= x / distance * force;
          dy[j] -= y / distance * force;
        }
      }
      for (final e in edges) {
        final i = index[e.fromNodeId]!, j = index[e.toNodeId]!;
        final x = positions[i].x - positions[j].x,
            y = positions[i].y - positions[j].y;
        final distance = math.max(.001, math.sqrt(x * x + y * y));
        final force = distance * distance / k;
        dx[i] -= x / distance * force;
        dy[i] -= y / distance * force;
        dx[j] += x / distance * force;
        dy[j] += y / distance * force;
      }
      final temperature = math.min(width, height) / 8 * (1 - step / iterations);
      for (var i = 0; i < nodes.length; i++) {
        if (pins.containsKey(nodes[i].id)) continue;
        final distance = math.max(
          .001,
          math.sqrt(dx[i] * dx[i] + dy[i] * dy[i]),
        );
        final travel = math.min(distance, temperature);
        positions[i] = clampCenter(
          nodes[i],
          Vec2(
            x: positions[i].x + dx[i] / distance * travel,
            y: positions[i].y + dy[i] / distance * travel,
          ),
          width: width,
          height: height,
          padding: padding,
        );
      }
    }
    return scene.copyWith(
      layoutMode: SceneLayoutMode.graph,
      nodes: [
        for (final n in scene.nodes)
          n.copyWith(
            x: positions[index[n.id]!].x - n.width / 2,
            y: positions[index[n.id]!].y - n.height / 2,
          ),
      ],
    );
  }
}
