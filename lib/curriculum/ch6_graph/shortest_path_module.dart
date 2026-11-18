import '../../engine/layout/graph_presets.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';

GraphInputModel _g6() {
  var graph = GraphInputModel.empty(
    GraphKind.dn,
    vertexPrefix: 'v',
    firstVertex: 0,
  );
  for (final (x, y) in const [
    (.08, .28),
    (.08, .72),
    (.48, .96),
    (.92, .72),
    (.92, .28),
    (.48, .04),
  ]) {
    graph = graph.addVertex(Vec2(x: x, y: y));
  }
  for (final (i, j, weight) in GraphPresets.table64Edges) {
    graph = graph.connect('v$i', 'v$j', weight: weight);
  }
  return graph;
}

GraphInputModel _g7() {
  var graph = GraphInputModel.empty(
    GraphKind.dn,
    vertexPrefix: '',
    firstVertex: 0,
  );
  for (final (x, y) in const [(.16, .83), (.84, .83), (.16, .17), (.84, .17)]) {
    graph = graph.addVertex(Vec2(x: x, y: y));
  }
  for (final (i, j, w) in const [
    (0, 1, 1),
    (0, 3, 4),
    (1, 2, 9),
    (1, 3, 2),
    (2, 0, 3),
    (2, 1, 5),
    (2, 3, 8),
    (3, 2, 6),
  ]) {
    graph = graph.connect('$i', '$j', weight: w);
  }
  return graph;
}

final shortestPathPresets = [
  AlgorithmPreset(id: 'g6', name: 'G₆ · 图 6.22 / 表 6.4', input: _g6()),
  AlgorithmPreset(id: 'g7', name: 'G₇ · 图 6.24 / 表 6.5', input: _g7()),
  ...graphPresets.where((p) => p.input.kind.weighted),
];

abstract class ShortestPathModule implements AlgorithmModule<GraphInputModel> {
  const ShortestPathModule();
  @override
  String get id => 'ch6_shortest_path';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => shortestPathPresets;
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final p = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择最短路径预设')
        : ValidationResult.success(p.input);
  }
}
