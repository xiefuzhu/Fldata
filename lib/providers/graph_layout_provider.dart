import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trace_model.dart';
import '../engine/layout/graph_layout_engine.dart';

typedef GraphLayoutRunner =
    Future<SceneSnapshot> Function(SceneSnapshot scene, Map<String, Vec2> pins);
final graphLayoutRunnerProvider = Provider<GraphLayoutRunner>(
  (ref) =>
      (scene, pins) => GraphLayoutEngine.forceDirectedAsync(scene, pins: pins),
);
