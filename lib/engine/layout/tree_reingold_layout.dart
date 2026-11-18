import 'dart:math' as math;
import '../../models/trace_model.dart';
import '../vm/trace_validation.dart';

/// Ordered contour packing, using real node extents at every depth.
/// No recursive Dart calls: deep chains do not consume the call stack.
abstract final class TreeReingoldLayout {
  static SceneNode bTreeNode({
    required String id,
    required List<String> keys,
  }) => SceneNode(
    id: id,
    label: keys.join(' | '),
    x: 0,
    y: 0,
    width: keys.length * 36.0 + 28,
    height: 48,
    shape: NodeShape.bTreeBox,
  );

  static SceneSnapshot arrange(
    SceneSnapshot scene, {
    List<String>? roots,
    double siblingGap = 24,
    double levelGap = 56,
    bool slantSingleChild = false,
    Vec2 origin = const Vec2(x: 32, y: 48),
  }) {
    validateScene(scene);
    if (![siblingGap, levelGap, origin.x, origin.y].every((n) => n.isFinite) ||
        siblingGap < 24 ||
        levelGap < 0) {
      throw ArgumentError('Invalid tree spacing');
    }
    final nodes = {for (final n in scene.nodes) n.id: n};
    final children = {for (final id in nodes.keys) id: <SceneEdge>[]};
    final parents = <String, String>{};
    for (final edge in scene.edges) {
      if (edge.toNodeId == nullNodeId ||
          edge.style != EdgeStyle.solidArrow ||
          edge.fromPort == EdgePort.prior) {
        continue;
      }
      if (parents.containsKey(edge.toNodeId)) {
        throw ArgumentError(
          'A tree node has multiple incoming structural edges',
        );
      }
      parents[edge.toNodeId] = edge.fromNodeId;
      children[edge.fromNodeId]!.add(edge);
    }
    for (final edges in children.values) {
      // Keep general/B-tree child order; explicit binary ports enforce left/right.
      if (edges.every(
        (e) => e.fromPort == EdgePort.lchild || e.fromPort == EdgePort.rchild,
      )) {
        if (edges.map((e) => e.fromPort).toSet().length != edges.length) {
          throw ArgumentError('Duplicate binary child port');
        }
        edges.sort((a, b) => a.fromPort.index.compareTo(b.fromPort.index));
      }
    }
    final naturalRoots = nodes.keys
        .where((id) => !parents.containsKey(id))
        .toList();
    final orderedRoots = roots ?? naturalRoots;
    if (orderedRoots.toSet().length != orderedRoots.length ||
        orderedRoots.length != naturalRoots.length ||
        !orderedRoots.toSet().containsAll(naturalRoots)) {
      throw ArgumentError('Roots must cover the entire forest');
    }
    final order = <String>[...orderedRoots];
    final depths = {for (final id in orderedRoots) id: 0};
    for (var i = 0; i < order.length; i++) {
      final id = order[i];
      for (final edge in children[id]!) {
        order.add(edge.toNodeId);
        depths[edge.toNodeId] = depths[id]! + 1;
      }
    }
    if (order.length != nodes.length) {
      throw ArgumentError('Tree contains a cycle');
    }
    final contours = <String, _Contour>{};
    final offsets = <String, double>{};
    for (final id in order.reversed) {
      final kids = children[id]!.map((e) => e.toNodeId).toList();
      if (kids.isEmpty) {
        contours[id] = _Contour(
          [-nodes[id]!.width / 2],
          [nodes[id]!.width / 2],
        );
        continue;
      }
      final pack = _pack(kids, contours, siblingGap);
      var mean = pack.offsets.values.reduce((a, b) => a + b) / kids.length;
      if (slantSingleChild && kids.length == 1) {
        final stride = nodes[id]!.height + levelGap;
        mean += switch (children[id]!.single.fromPort) {
          EdgePort.lchild => stride,
          EdgePort.rchild => -stride,
          _ => 0,
        };
      }
      for (final child in kids) {
        offsets[child] = pack.offsets[child]! - mean;
      }
      contours[id] = _Contour(
        [-nodes[id]!.width / 2, ...pack.left.map((x) => x - mean)],
        [nodes[id]!.width / 2, ...pack.right.map((x) => x - mean)],
      );
    }
    final forest = _pack(orderedRoots, contours, siblingGap);
    if (nodes.isEmpty) return scene.copyWith(layoutMode: SceneLayoutMode.tree);
    final minLeft = forest.left.reduce(math.min);
    final centers = {
      for (final id in orderedRoots)
        id: forest.offsets[id]! + origin.x - minLeft,
    };
    final heights = <int, double>{};
    for (final id in order) {
      final parent = parents[id];
      if (parent != null) centers[id] = centers[parent]! + offsets[id]!;
      heights.update(
        depths[id]!,
        (h) => math.max(h, nodes[id]!.height),
        ifAbsent: () => nodes[id]!.height,
      );
    }
    final rows = <double>[origin.y];
    for (var depth = 1; depth < heights.length; depth++) {
      rows.add(rows.last + heights[depth - 1]! + levelGap);
    }
    return scene.copyWith(
      layoutMode: SceneLayoutMode.tree,
      nodes: [
        for (final n in scene.nodes)
          n.copyWith(x: centers[n.id]! - n.width / 2, y: rows[depths[n.id]!]),
      ],
    );
  }

  static _Pack _pack(
    List<String> ids,
    Map<String, _Contour> contours,
    double gap,
  ) {
    final left = <double>[], right = <double>[];
    final offsets = <String, double>{};
    for (final id in ids) {
      final contour = contours[id]!;
      var shift = 0.0;
      for (
        var depth = 0;
        depth < math.min(right.length, contour.left.length);
        depth++
      ) {
        shift = math.max(shift, right[depth] + gap - contour.left[depth]);
      }
      offsets[id] = shift;
      for (var depth = 0; depth < contour.left.length; depth++) {
        if (depth == left.length) {
          left.add(contour.left[depth] + shift);
          right.add(contour.right[depth] + shift);
        } else {
          left[depth] = math.min(left[depth], contour.left[depth] + shift);
          right[depth] = math.max(right[depth], contour.right[depth] + shift);
        }
      }
    }
    return _Pack(left, right, offsets);
  }
}

class _Contour {
  const _Contour(this.left, this.right);
  final List<double> left, right;
}

class _Pack extends _Contour {
  const _Pack(super.left, super.right, this.offsets);
  final Map<String, double> offsets;
}
