import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/trace_model.dart';

bool isBPlusLeafLink(
  SceneSnapshot scene,
  SceneEdge edge,
  SceneNode? source,
  SceneNode? target,
) =>
    scene.layoutMode == SceneLayoutMode.tree &&
    edge.fromPort == EdgePort.next &&
    source?.shape == NodeShape.bTreeBox &&
    target?.shape == NodeShape.bTreeBox;

Offset curvePoint((Offset, Offset, Offset) geometry, double t) {
  final (a, c, b) = geometry;
  return a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);
}

(Offset, Offset, Offset)? edgeGeometry(
  SceneSnapshot scene,
  SceneEdge edge,
  Map<String, SceneNode> nodes,
) {
  final source = nodes[edge.fromNodeId], target = nodes[edge.toNodeId];
  if (source == null || (target == null && edge.toNodeId != nullNodeId)) {
    return null;
  }
  if (target != null && isBPlusLeafLink(scene, edge, source, target)) {
    final a = Offset(source.x + source.width, source.y + source.height / 2);
    final b = Offset(target.x, target.y + target.height / 2);
    return (a, (a + b) / 2, b);
  }
  if (target != null && source.id == target.id) {
    if (edge.fromPort == EdgePort.lchild || edge.fromPort == EdgePort.rchild) {
      final left = edge.fromPort == EdgePort.lchild;
      final x = left ? source.x : source.x + source.width;
      return (
        Offset(x, source.y + source.height * .78),
        Offset(x + (left ? -80 : 80), source.y + source.height / 2),
        Offset(x, source.y + source.height * .22),
      );
    }
    if (edge.fromPort == EdgePort.prior) {
      return (
        Offset(source.x + source.width * .15, source.y + source.height * .8),
        Offset(source.x - 80, source.y + source.height / 2),
        Offset(source.x + source.width * .15, source.y + source.height * .2),
      );
    }
    return (
      Offset(source.x + source.width * .85, source.y + source.height * .2),
      Offset(source.x + source.width + 80, source.y + source.height / 2),
      Offset(source.x + source.width * .85, source.y + source.height * .8),
    );
  }
  if (target != null &&
      scene.layoutMode == SceneLayoutMode.tree &&
      edge.style == EdgeStyle.dashedThread) {
    final right = edge.fromPort == EdgePort.rchild;
    final a = Offset(
      right ? source.x + source.width : source.x,
      source.y + source.height / 2,
    );
    final b = Offset(
      right ? target.x + target.width : target.x,
      target.y + target.height / 2,
    );
    final bend = edge.curvature.abs();
    return (
      a,
      Offset(
        right ? math.max(a.dx, b.dx) + bend : math.min(a.dx, b.dx) - bend,
        (a.dy + b.dy) / 2,
      ),
      b,
    );
  }
  var a = Offset(source.x + source.width, source.y + source.height / 2);
  var b = target == null
      ? a + const Offset(24, 0)
      : Offset(target.x, target.y + target.height / 2);
  final sibling =
      edge.fromPort == EdgePort.rchild &&
      edge.visualState == NodeVisualState.comparing &&
      scene.layoutMode == SceneLayoutMode.tree;
  if (target != null && scene.layoutMode == SceneLayoutMode.tree && !sibling) {
    a = Offset(source.x + source.width / 2, source.y + source.height);
    b = Offset(target.x + target.width / 2, target.y);
  } else if (target != null &&
      (scene.layoutMode == SceneLayoutMode.graph || sibling)) {
    final ac = Offset(
          source.x + source.width / 2,
          source.y + source.height / 2,
        ),
        bc = Offset(target.x + target.width / 2, target.y + target.height / 2);
    Offset boundary(SceneNode n, Offset center, Offset towards) {
      final d = towards - center;
      if (d.distance < .001) return center;
      final factor = n.shape == NodeShape.circle
          ? n.width / 2 / d.distance
          : 1 /
                math.max(
                  d.dx.abs() / (n.width / 2),
                  d.dy.abs() / (n.height / 2),
                );
      return center + d * factor;
    }

    final delta = bc - ac;
    final normal = delta.distance < .001
        ? Offset.zero
        : Offset(-delta.dy, delta.dx) / delta.distance;
    final control = (ac + bc) / 2 + normal * edge.curvature;
    a = boundary(source, ac, control);
    b = boundary(target, bc, control);
    return (a, control, b);
  }
  switch (edge.fromPort) {
    case EdgePort.prior:
      a = Offset(source.x, source.y + source.height / 2);
      b = target == null
          ? a - const Offset(24, 0)
          : Offset(target.x + target.width, target.y + target.height / 2);
    case EdgePort.lchild:
      a = Offset(source.x + source.width * .25, source.y + source.height);
    case EdgePort.rchild:
      a = Offset(source.x + source.width * .75, source.y + source.height);
    case EdgePort.center:
      a = Offset(source.x + source.width / 2, source.y + source.height / 2);
    case EdgePort.next:
      a = Offset(source.x + source.width, source.y + source.height / 2);
    case EdgePort.auto:
      break;
  }
  if (edge.style == EdgeStyle.shellArc || edge.style == EdgeStyle.swapArc) {
    a = Offset(source.x + source.width / 2, source.y);
    b = target == null
        ? a + const Offset(24, 0)
        : Offset(target.x + target.width / 2, target.y);
    return (
      a,
      (a + b) / 2 + Offset(0, edge.curvature == 0 ? -48 : edge.curvature),
      b,
    );
  }
  final d = b - a;
  final normal = d.distance < .001
      ? Offset.zero
      : Offset(-d.dy, d.dx) / d.distance;
  return (a, (a + b) / 2 + normal * edge.curvature, b);
}
