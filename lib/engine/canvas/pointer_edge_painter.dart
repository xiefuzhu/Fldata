import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/trace_model.dart';
import 'edge_geometry.dart';

class PointerEdgePainter extends CustomPainter {
  PointerEdgePainter(
    this.scene,
    this.color, {
    this.zonePulse = 1,
    this.pulseEdgeId,
    this.edgePulse = 0,
    this.traversalEdges = false,
  });
  final double zonePulse, edgePulse;
  final String? pulseEdgeId;
  final bool traversalEdges;
  final SceneSnapshot scene;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: .08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final nodes = {for (final node in scene.nodes) node.id: node};
    for (final zone in scene.zones) {
      final rect = Rect.fromLTWH(zone.x, zone.y, zone.width, zone.height);
      final pen = Paint()
        ..color =
            (zone.visualState == NodeVisualState.error
                    ? Colors.redAccent
                    : zone.visualState == NodeVisualState.comparing
                    ? Colors.orange.shade800
                    : color)
                .withValues(
                  alpha:
                      zone.opacity *
                      (zone.visualState == NodeVisualState.error
                          ? zonePulse
                          : 1),
                )
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      if (zone.visualState == NodeVisualState.sorted) {
        pen.color = Colors.green.shade700.withValues(alpha: zone.opacity);
        canvas.drawRect(
          rect,
          Paint()..color = Colors.green.withValues(alpha: .16 * zone.opacity),
        );
      } else if (zone.visualState == NodeVisualState.sentinel) {
        pen.color = Colors.deepPurpleAccent.withValues(alpha: zone.opacity);
      }
      if (zone.pattern == ZonePattern.dashed) {
        drawDashedPath(
          canvas,
          rect.width <= 2
              ? (Path()
                  ..moveTo(rect.center.dx, rect.top)
                  ..lineTo(rect.center.dx, rect.bottom))
              : (Path()..addRect(rect)),
          pen,
        );
      } else if (zone.pattern == ZonePattern.hatched) {
        canvas.save();
        canvas.clipRect(rect);
        for (var x = rect.left - rect.height; x < rect.right; x += 8) {
          canvas.drawLine(
            Offset(x, rect.bottom),
            Offset(x + rect.height, rect.top),
            pen,
          );
        }
        canvas.restore();
        canvas.drawRect(rect, pen);
      } else {
        canvas.drawRect(rect, pen);
      }
    }
    for (final edge in scene.edges) {
      final geometry = edgeGeometry(scene, edge, nodes);
      if (geometry == null || edge.opacity <= 0 || edge.drawProgress <= 0) {
        continue;
      }
      final (a, c, _) = geometry;
      final end = curvePoint(geometry, edge.drawProgress);
      final control = Offset.lerp(a, c, edge.drawProgress)!;
      final pen = Paint()
        ..color =
            (edge.visualState == NodeVisualState.error
                    ? Colors.redAccent
                    : isBPlusLeafLink(
                            scene,
                            edge,
                            nodes[edge.fromNodeId],
                            nodes[edge.toNodeId],
                          ) ||
                          edge.style == EdgeStyle.dashedThread
                    ? Colors.deepPurpleAccent
                    : edge.visualState == NodeVisualState.comparing
                    ? Colors.amber.shade700
                    : edge.visualState == NodeVisualState.active
                    ? Colors.blueAccent
                    : color)
                .withValues(alpha: edge.opacity)
        ..strokeWidth = edge.visualState == NodeVisualState.active ? 3.5 : 2
        ..style = PaintingStyle.stroke;
      if (edge.style == EdgeStyle.shellArc) {
        final group = int.tryParse(nodes[edge.fromNodeId]?.groupTag ?? '');
        if (group != null) {
          pen.color = HSLColor.fromAHSL(
            edge.opacity,
            (group * 137.508) % 360,
            .7,
            .43,
          ).toColor();
        }
      }
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      final treeEdge =
          traversalEdges && edge.visualState == NodeVisualState.sorted;
      final nonTreeEdge =
          traversalEdges && edge.visualState == NodeVisualState.sentinel;
      if (treeEdge) {
        pen.color = const Color(0xff14966c).withValues(alpha: edge.opacity);
        pen.strokeWidth = 4;
      }
      if (nonTreeEdge) {
        pen.color = Colors.grey.withValues(alpha: .7 * edge.opacity);
      }
      if (edge.id == pulseEdgeId) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6 + 8 * edgePulse
            ..color = Colors.blueAccent.withValues(
              alpha: .18 + .22 * edgePulse,
            ),
        );
        pen.color = Colors.blueAccent;
      }
      if (edge.style == EdgeStyle.dashedThread || nonTreeEdge) {
        drawDashedPath(canvas, path, pen);
      } else {
        canvas.drawPath(path, pen);
      }
      if (edge.toNodeId == nullNodeId) {
        canvas.drawLine(
          end + const Offset(0, -6),
          end + const Offset(0, 6),
          pen,
        );
      } else if (edge.style != EdgeStyle.undirected &&
          edge.style != EdgeStyle.shellArc) {
        final tangent = end - control;
        final angle = math.atan2(tangent.dy, tangent.dx);
        for (final sign in [-1, 1]) {
          canvas.drawLine(
            end,
            end -
                Offset(
                  math.cos(angle + sign * .5) * 9,
                  math.sin(angle + sign * .5) * 9,
                ),
            pen,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(PointerEdgePainter oldDelegate) =>
      !identical(scene, oldDelegate.scene) ||
      color != oldDelegate.color ||
      zonePulse != oldDelegate.zonePulse ||
      pulseEdgeId != oldDelegate.pulseEdgeId ||
      edgePulse != oldDelegate.edgePulse ||
      traversalEdges != oldDelegate.traversalEdges;
}

void drawDashedPath(Canvas canvas, Path path, Paint pen) {
  for (final metric in path.computeMetrics()) {
    for (double start = 0; start < metric.length; start += 10) {
      canvas.drawPath(
        metric.extractPath(start, math.min(start + 5, metric.length)),
        pen,
      );
    }
  }
}
