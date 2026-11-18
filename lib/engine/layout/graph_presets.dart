import '../../models/trace_model.dart';
import 'graph_layout_engine.dart';

/// Edge/weight data is explicitly supplied in .doc/06, table 6.4.
/// Coordinates are our layout, not a claim of a scanned textbook drawing.
abstract final class GraphPresets {
  static const table64Edges = [
    (0, 2, 10),
    (0, 4, 30),
    (0, 5, 100),
    (1, 2, 5),
    (2, 3, 50),
    (3, 5, 10),
    (4, 3, 20),
    (4, 5, 60),
  ];
  static const table64Coordinates = <String, Vec2>{
    'v0': Vec2(x: .02, y: .45),
    'v1': Vec2(x: .02, y: .02),
    'v2': Vec2(x: .37, y: .06),
    'v3': Vec2(x: .70, y: .36),
    'v4': Vec2(x: .37, y: .82),
    'v5': Vec2(x: .98, y: .72),
  };
  static SceneSnapshot table64() => GraphLayoutEngine.preset(
    SceneSnapshot(
      nodes: [
        for (var i = 0; i < 6; i++)
          SceneNode(
            id: 'v$i',
            label: 'v$i',
            x: 0,
            y: 0,
            width: 48,
            height: 48,
            shape: NodeShape.circle,
          ),
      ],
      edges: [
        for (final e in table64Edges)
          SceneEdge(
            id: 'v${e.$1}-v${e.$2}',
            fromNodeId: 'v${e.$1}',
            toNodeId: 'v${e.$2}',
            weightLabel: e.$3.toString(),
            curvature: e.$1 == 0 && e.$2 == 5 ? 220 : 0,
          ),
      ],
    ),
    table64Coordinates,
  );
}
