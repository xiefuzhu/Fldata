import '../../models/trace_model.dart';

/// Use for owned linked structures, not array/graph scenes without root pointers.
/// Back links and threaded traversal edges do not establish ownership.
Set<String> detectMemoryLeaks(SceneSnapshot scene) {
  final live = {
    for (final n in scene.nodes)
      if (!n.isDeleted) n.id,
  };
  final adjacency = <String, List<String>>{};
  for (final edge in scene.edges) {
    if (edge.style == EdgeStyle.solidArrow &&
        const {
          EdgePort.auto,
          EdgePort.next,
          EdgePort.lchild,
          EdgePort.rchild,
        }.contains(edge.fromPort) &&
        live.contains(edge.fromNodeId) &&
        live.contains(edge.toNodeId)) {
      adjacency.putIfAbsent(edge.fromNodeId, () => []).add(edge.toNodeId);
    }
  }
  return unreachableNodes(
    live,
    adjacency,
    scene.pointers
        .where((p) => p.label.trim().isNotEmpty)
        .map((p) => p.targetNodeId),
  );
}

Set<String> unreachableNodes(
  Set<String> live,
  Map<String, List<String>> adjacency,
  Iterable<String> roots,
) {
  final visited = <String>{};
  final queue = <String>[];
  for (final root in roots) {
    if (live.contains(root) && visited.add(root)) {
      queue.add(root);
    }
  }
  for (var i = 0; i < queue.length; i++) {
    for (final target in adjacency[queue[i]] ?? const <String>[]) {
      if (live.contains(target) && visited.add(target)) queue.add(target);
    }
  }
  return Set.unmodifiable(live.difference(visited));
}

SceneSnapshot markMemoryLeaks(SceneSnapshot scene) {
  final leaks = detectMemoryLeaks(scene);
  return scene.copyWith(
    nodes: List.unmodifiable(
      scene.nodes.map((n) => n.copyWith(isOrphanLeak: leaks.contains(n.id))),
    ),
  );
}
