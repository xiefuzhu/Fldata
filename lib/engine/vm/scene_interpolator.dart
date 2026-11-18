import '../../models/trace_model.dart';
import '../layout/circular_queue_layout.dart';
import '../layout/swap_trajectory.dart';

/// Geometry is derived only from the two recorded snapshots and time.
/// Discrete metadata belongs to the left frame until the next exact boundary.
class SceneInterpolator {
  static SceneSnapshot lerp(
    SceneSnapshot from,
    SceneSnapshot to,
    double t, {
    double? spatialProgress,
  }) {
    if (!t.isFinite) throw ArgumentError.value(t, 't');
    final spatial = spatialProgress ?? t;
    if (!spatial.isFinite) {
      throw ArgumentError.value(spatial, 'spatialProgress');
    }
    if (t <= 0) return from;
    if (t >= 1) return to;
    double mix(double a, double b) => a + (b - a) * t;
    final oldNodes = {for (final node in from.nodes) node.id: node};
    final newNodes = {for (final node in to.nodes) node.id: node};
    final treeMotion =
        from.layoutMode == SceneLayoutMode.tree &&
        to.layoutMode == SceneLayoutMode.tree;
    final structural =
        treeMotion ||
        from.layoutMode == SceneLayoutMode.graph ||
        to.layoutMode == SceneLayoutMode.graph;
    final swaps = structural
        ? <String>{}
        : SwapTrajectory.swappedIds(oldNodes, newNodes);
    final nodes = <SceneNode>[];
    for (final id in {...oldNodes.keys, ...newNodes.keys}) {
      final a = oldNodes[id], b = newNodes[id];
      if (a == null) {
        nodes.add(b!.copyWith(opacity: b.opacity * t, scale: b.scale * t));
      } else if (b == null) {
        nodes.add(
          a.copyWith(opacity: a.opacity * (1 - t), scale: a.scale * (1 - t)),
        );
      } else {
        final arc =
            swaps.contains(id) ||
            (from.layoutMode == SceneLayoutMode.linearMemory &&
                to.layoutMode == SceneLayoutMode.linearMemory &&
                (a.visualState == NodeVisualState.moving ||
                    b.visualState == NodeVisualState.moving) &&
                (a.x - b.x).abs() >= a.width + 8);
        final position = arc
            ? SwapTrajectory.position(
                Vec2(x: a.x, y: a.y),
                Vec2(x: b.x, y: b.y),
                spatial,
              )
            : Vec2(
                x: a.x + (b.x - a.x) * (treeMotion ? spatial : t),
                y: a.y + (b.y - a.y) * (treeMotion ? spatial : t),
              );
        nodes.add(
          a.copyWith(
            x: position.x,
            y: position.y,
            width: mix(a.width, b.width),
            height: mix(a.height, b.height),
            opacity: mix(a.opacity, b.opacity),
            scale: mix(a.scale, b.scale),
          ),
        );
      }
    }
    final oldEdges = {for (final edge in from.edges) edge.id: edge};
    final newEdges = {for (final edge in to.edges) edge.id: edge};
    final edges = <SceneEdge>[];
    // Transient ids are allocated outside both recorded namespaces.
    final edgeIds = {...oldEdges.keys, ...newEdges.keys};
    String retiredId(String id) {
      var result = '~out:$id';
      while (edgeIds.contains(result)) {
        result = '~$result';
      }
      edgeIds.add(result);
      return result;
    }

    for (final id in {...oldEdges.keys, ...newEdges.keys}) {
      final a = oldEdges[id], b = newEdges[id];
      if (a == null) {
        edges.add(
          b!.copyWith(opacity: b.opacity * t, drawProgress: b.drawProgress * t),
        );
      } else if (b == null) {
        edges.add(a.copyWith(opacity: a.opacity * (1 - t)));
      } else if (a.fromNodeId != b.fromNodeId ||
          a.toNodeId != b.toNodeId ||
          a.fromPort != b.fromPort ||
          a.style != b.style) {
        edges.add(a.copyWith(id: retiredId(id), opacity: a.opacity * (1 - t)));
        edges.add(
          b.copyWith(opacity: b.opacity * t, drawProgress: b.drawProgress * t),
        );
      } else {
        edges.add(
          a.copyWith(
            curvature: mix(a.curvature, b.curvature),
            drawProgress: mix(a.drawProgress, b.drawProgress),
            opacity: mix(a.opacity, b.opacity),
          ),
        );
      }
    }
    final oldPointers = {for (final p in from.pointers) p.id: p};
    final newPointers = {for (final p in to.pointers) p.id: p};
    final pointers = <PointerBadge>[];
    final pointerIds = {...oldPointers.keys, ...newPointers.keys};
    for (final id in {...oldPointers.keys, ...newPointers.keys}) {
      final a = oldPointers[id], b = newPointers[id];
      if (a == null) {
        pointers.add(b!.copyWith(opacity: b.opacity * t));
      } else if (b == null) {
        pointers.add(a.copyWith(opacity: a.opacity * (1 - t)));
      } else if (a.orbit != null &&
          b.orbit != null &&
          from.layoutMode == SceneLayoutMode.circularQueue &&
          to.layoutMode == SceneLayoutMode.circularQueue) {
        // Reverse playback decreases t on this same forward pair; never swap ends.
        pointers.add(
          a.copyWith(
            orbit: CircularQueueLayout.interpolate(a.orbit!, b.orbit!, t),
            opacity: mix(a.opacity, b.opacity),
          ),
        );
      } else if (a.targetNodeId != b.targetNodeId) {
        var retired = '~out:$id';
        while (pointerIds.contains(retired)) {
          retired = '~$retired';
        }
        pointerIds.add(retired);
        pointers.add(a.copyWith(id: retired, opacity: a.opacity * (1 - t)));
        pointers.add(b.copyWith(opacity: b.opacity * t));
      } else {
        pointers.add(
          a.copyWith(
            dx: mix(a.dx, b.dx),
            dy: mix(a.dy, b.dy),
            opacity: mix(a.opacity, b.opacity),
          ),
        );
      }
    }
    final oldZones = {for (final z in from.zones) z.id: z};
    final newZones = {for (final z in to.zones) z.id: z};
    final zones = <SceneZoneOverlay>[];
    for (final id in {...oldZones.keys, ...newZones.keys}) {
      final a = oldZones[id], b = newZones[id];
      if (a == null) {
        zones.add(b!.copyWith(opacity: b.opacity * t));
      } else if (b == null) {
        zones.add(a.copyWith(opacity: a.opacity * (1 - t)));
      } else {
        zones.add(
          a.copyWith(
            x: mix(a.x, b.x),
            y: mix(a.y, b.y),
            width: mix(a.width, b.width),
            height: mix(a.height, b.height),
            opacity: mix(a.opacity, b.opacity),
          ),
        );
      }
    }
    return from.copyWith(
      nodes: List.unmodifiable(nodes),
      edges: List.unmodifiable(edges),
      pointers: List.unmodifiable(pointers),
      zones: List.unmodifiable(zones),
    );
  }
}
