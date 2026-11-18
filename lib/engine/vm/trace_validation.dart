import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

void validateTimeline(TraceTimeline timeline) {
  if (timeline.moduleId.isEmpty || timeline.frames.isEmpty) {
    throw ArgumentError(
      'TraceTimeline requires a module ID and at least one frame',
    );
  }
  for (final lang in CodeLang.values) {
    if (!timeline.codeLines.containsKey(lang) ||
        timeline.codeLines[lang]!.isEmpty) {
      throw ArgumentError('Missing source for ${lang.name}');
    }
  }
  for (var i = 0; i < timeline.frames.length; i++) {
    final frame = timeline.frames[i];
    if (frame.stepIndex != i) throw ArgumentError('Non-contiguous stepIndex');
    for (final entry in frame.activeLines.entries) {
      if (entry.value.any(
        (line) => line < 1 || line > timeline.codeLines[entry.key]!.length,
      )) {
        throw ArgumentError('Code line outside source range');
      }
    }
    validateScene(frame.scene);
    final m = frame.metrics;
    if ([
      m.comparisons,
      m.moves,
      m.reads,
      m.writes,
      m.allocations,
      m.auxiliarySpace,
      m.peakAuxiliarySpace,
      m.callDepth,
      m.maxCallDepth,
      ...m.statementCounts.values,
    ].any((v) => v < 0)) {
      throw ArgumentError('Negative complexity counter');
    }
  }
}

void validateScene(SceneSnapshot scene) {
  void unique(Iterable<String> ids) {
    final values = ids.toList();
    if (values.any((id) => id.isEmpty) ||
        values.toSet().length != values.length) {
      throw ArgumentError('Scene IDs must be nonempty and unique');
    }
  }

  unique(scene.nodes.map((n) => n.id));
  unique(scene.edges.map((e) => e.id));
  unique(scene.pointers.map((p) => p.id));
  unique(scene.zones.map((z) => z.id));
  unique(scene.auxTables.map((t) => t.id));
  final ids = scene.nodes.map((n) => n.id).toSet();
  if (ids.contains(nullNodeId)) throw ArgumentError('Reserved NULL node ID');
  bool target(String id) => id == nullNodeId || ids.contains(id);
  for (final node in scene.nodes) {
    if (![
          node.x,
          node.y,
          node.width,
          node.height,
          node.opacity,
          node.scale,
        ].every((v) => v.isFinite) ||
        node.width <= 0 ||
        node.height <= 0 ||
        node.scale < 0 ||
        node.opacity < 0 ||
        node.opacity > 1) {
      throw ArgumentError('Invalid node geometry');
    }
  }
  for (final edge in scene.edges) {
    if (!ids.contains(edge.fromNodeId) ||
        !target(edge.toNodeId) ||
        !edge.curvature.isFinite ||
        !edge.drawProgress.isFinite ||
        edge.drawProgress < 0 ||
        edge.drawProgress > 1 ||
        !edge.opacity.isFinite ||
        edge.opacity < 0 ||
        edge.opacity > 1) {
      throw ArgumentError('Invalid edge');
    }
  }
  for (final pointer in scene.pointers) {
    final orbit = pointer.orbit;
    if (orbit != null &&
        (![
              orbit.center.x,
              orbit.center.y,
              orbit.radius,
              orbit.angle,
            ].every((v) => v.isFinite) ||
            orbit.radius <= 0)) {
      throw ArgumentError('Invalid pointer orbit');
    }
    if (!target(pointer.targetNodeId) ||
        !pointer.dx.isFinite ||
        !pointer.dy.isFinite ||
        !pointer.opacity.isFinite ||
        pointer.opacity < 0 ||
        pointer.opacity > 1) {
      throw ArgumentError('Invalid pointer');
    }
  }
  for (final zone in scene.zones) {
    if (![
          zone.x,
          zone.y,
          zone.width,
          zone.height,
          zone.opacity,
        ].every((v) => v.isFinite) ||
        zone.width <= 0 ||
        zone.height <= 0 ||
        zone.opacity < 0 ||
        zone.opacity > 1) {
      throw ArgumentError('Invalid scene zone');
    }
  }
  for (final table in scene.auxTables) {
    if (table.rows.any((row) => row.length != table.columns.length) ||
        table.highlightedRows.any((i) => i < 0 || i >= table.rows.length)) {
      throw ArgumentError('Invalid auxiliary table');
    }
  }
}
