import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/trace_model.dart';
import 'edge_geometry.dart';

/// Screen-space expansion keeps a 48dp target even when the camera zooms out.
/// Actual shapes win over expanded neighbours; ties pick the nearest centre,
/// then the last painted node. Invisible/deleted nodes are never interactive.
String? hitTestStageNode(SceneSnapshot scene, Matrix4 camera, Offset point) {
  String? hit;
  var best = double.infinity;
  var bestInside = false;
  for (final n in scene.nodes.reversed) {
    if (n.opacity <= .01 || n.scale <= 0 || n.isDeleted) continue;
    final bounds = MatrixUtils.transformRect(
      camera,
      Rect.fromCenter(
        center: Offset(n.x + n.width / 2, n.y + n.height / 2),
        width: n.width * n.scale,
        height: n.height * n.scale,
      ),
    );
    final target = Rect.fromCenter(
      center: bounds.center,
      width: math.max(48, bounds.width),
      height: math.max(48, bounds.height),
    );
    if (!target.contains(point)) continue;
    final inside = bounds.contains(point);
    final distance = (bounds.center - point).distanceSquared;
    if (hit == null ||
        (inside && !bestInside) ||
        (inside == bestInside && distance < best)) {
      hit = n.id;
      best = distance;
      bestInside = inside;
    }
  }
  return hit;
}

/// Opt-in for sorting race views only; ordinary memory/queue slots stay detailed.
/// Preserve continuous x/y motion and IDs, including an isolated sentinel slot.
SceneSnapshot barScene(SceneSnapshot scene, Size size) {
  if (scene.nodes.isEmpty) return scene;
  final minX = scene.nodes.map((n) => n.x).reduce(math.min);
  final maxX = scene.nodes.map((n) => n.x + n.width).reduce(math.max);
  final factor = (size.width - 64) / math.max(1, maxX - minX);
  final magnitude = scene.nodes
      .map((n) => (double.tryParse(n.label) ?? 0).abs())
      .reduce(math.max);
  final hasNegative = scene.nodes.any(
    (n) => (double.tryParse(n.label) ?? 0) < 0,
  );
  final available = (size.height - 96) / (hasNegative ? 2 : 1);
  final baseline = hasNegative ? size.height / 2 : size.height - 48;
  return scene.copyWith(
    nodes: [
      for (final n in scene.nodes)
        (() {
          final value = double.tryParse(n.label) ?? 0;
          final height = math.max(
            3.0,
            available * value.abs() / math.max(1, magnitude),
          );
          return n.copyWith(
            x: 32 + (n.x - minX) * factor,
            y: baseline - (value >= 0 ? height : 0) + (n.y - 120) * factor,
            width: math.max(1, n.width * factor),
            height: height,
          );
        })(),
    ],
  );
}

/// Measure the painted quadratic in screen space so zoom preserves tap tolerance.
String? hitTestStageEdge(SceneSnapshot scene, Matrix4 camera, Offset point) {
  final nodes = {for (final v in scene.nodes) v.id: v};
  var nearest = 14.0;
  String? hit;
  for (final e in scene.edges) {
    final curve = edgeGeometry(scene, e, nodes);
    if (curve == null || e.opacity <= .01 || e.drawProgress <= 0) continue;
    final path = Path()
      ..moveTo(curve.$1.dx, curve.$1.dy)
      ..quadraticBezierTo(curve.$2.dx, curve.$2.dy, curve.$3.dx, curve.$3.dy);
    final metric = path.transform(camera.storage).computeMetrics().firstOrNull;
    if (metric == null) continue;
    for (double d = 0; d <= metric.length * e.drawProgress; d += 5) {
      final p = metric.getTangentForOffset(d)?.position;
      if (p != null && (point - p).distance < nearest) {
        nearest = (point - p).distance;
        hit = e.id;
      }
    }
  }
  return hit;
}
