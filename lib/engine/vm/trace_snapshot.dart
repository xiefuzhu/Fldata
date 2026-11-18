import '../../models/trace_model.dart';

// Copy at recording/loading boundaries: Freezed's read-only views alone do not
// prevent a caller from mutating the original backing collections afterwards.
SceneSnapshot freezeScene(SceneSnapshot scene) => scene.copyWith(
  nodes: List.unmodifiable(scene.nodes),
  edges: List.unmodifiable(scene.edges),
  pointers: List.unmodifiable(scene.pointers),
  zones: List.unmodifiable(scene.zones),
  auxTables: List.unmodifiable(
    scene.auxTables.map(
      (table) => table.copyWith(
        columns: List.unmodifiable(table.columns),
        rows: List.unmodifiable(
          table.rows.map((row) => List<String>.unmodifiable(row)),
        ),
        highlightedRows: Set.unmodifiable(table.highlightedRows),
      ),
    ),
  ),
);
TraceFrame freezeFrame(TraceFrame frame) => frame.copyWith(
  activeLines: Map.unmodifiable(
    frame.activeLines.map(
      (lang, lines) => MapEntry(lang, List<int>.unmodifiable(lines)),
    ),
  ),
  inlineVars: Map.unmodifiable(frame.inlineVars),
  scene: freezeScene(frame.scene),
  callStack: List.unmodifiable(
    frame.callStack.map(
      (call) => call.copyWith(
        arguments: Map.unmodifiable(call.arguments),
        locals: Map.unmodifiable(call.locals),
      ),
    ),
  ),
  metrics: frame.metrics.copyWith(
    statementCounts: Map.unmodifiable(frame.metrics.statementCounts),
  ),
);
TraceTimeline freezeTimeline(TraceTimeline timeline) => timeline.copyWith(
  frames: List.unmodifiable(timeline.frames.map(freezeFrame)),
  codeLines: Map.unmodifiable(
    timeline.codeLines.map(
      (lang, lines) => MapEntry(lang, List<String>.unmodifiable(lines)),
    ),
  ),
);
