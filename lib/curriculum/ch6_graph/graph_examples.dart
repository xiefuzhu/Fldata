import '../../engine/layout/graph_layout_engine.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'graph_input.dart';

GraphInputModel graphExample(
  GraphKind kind,
  List<(double, double)> positions,
  List<(int, int, int)> edges,
) {
  var g = GraphInputModel.empty(kind);
  for (final (x, y) in positions) {
    g = g.addVertex(Vec2(x: x, y: y));
  }
  for (final (a, b, w) in edges) {
    g = g.connect('V$a', 'V$b', weight: w);
  }
  return g;
}

final graphPresets = [
  AlgorithmPreset(
    id: 'g2',
    name: 'G₂ · 无向图 · 图 6.1(b)',
    input: graphExample(
      GraphKind.udg,
      [(.12, .1), (.88, .1), (.5, .49), (.12, .9), (.88, .9)],
      [(1, 2, 1), (1, 4, 1), (2, 3, 1), (2, 5, 1), (3, 4, 1), (3, 5, 1)],
    ),
  ),
  AlgorithmPreset(
    id: 'g1',
    name: 'G₁ · 有向图 · 图 6.1(a)',
    input: graphExample(
      GraphKind.dg,
      [(.14, .12), (.86, .12), (.14, .88), (.86, .88)],
      [(1, 2, 1), (1, 3, 1), (3, 4, 1), (4, 1, 1)],
    ),
  ),
  AlgorithmPreset(
    id: 'n',
    name: 'N · 有向网 · 图 6.10',
    input: graphExample(
      GraphKind.dn,
      [(.32, .06), (.82, .06), (.92, .52), (.62, .91), (.1, .91), (.08, .45)],
      [
        (1, 2, 5),
        (1, 4, 7),
        (2, 3, 4),
        (3, 1, 8),
        (3, 6, 9),
        (4, 3, 5),
        (4, 6, 6),
        (5, 4, 5),
        (6, 1, 3),
        (6, 5, 1),
      ],
    ),
  ),
  AlgorithmPreset(
    id: 'g5',
    name: 'G₅ · 无向网 · 图 6.19(a)',
    input: graphExample(
      GraphKind.udn,
      [(.5, .05), (.08, .36), (.5, .5), (.92, .36), (.25, .95), (.75, .95)],
      [
        (1, 2, 6),
        (1, 3, 1),
        (1, 4, 5),
        (2, 3, 5),
        (2, 5, 3),
        (3, 4, 5),
        (3, 5, 6),
        (3, 6, 4),
        (4, 6, 2),
        (5, 6, 6),
      ],
    ),
  ),
];

const graphWidth = 580.0,
    graphHeight = 400.0,
    vertexSize = 48.0,
    graphPadding = 32.0;
Vec2 normalizedGraphPoint(Vec2 p) => Vec2(
  x:
      ((p.x - graphPadding - vertexSize / 2) /
              (graphWidth - 2 * graphPadding - vertexSize))
          .clamp(0, 1),
  y:
      ((p.y - graphPadding - vertexSize / 2) /
              (graphHeight - 2 * graphPadding - vertexSize))
          .clamp(0, 1),
);

SceneSnapshot graphScene(GraphInputModel input, GraphStorage storage) =>
    GraphLayoutEngine.preset(
      SceneSnapshot(
        nodes: [
          for (final v in input.vertices)
            SceneNode(
              id: v.id,
              label: v.id,
              x: 0,
              y: 0,
              width: vertexSize,
              height: vertexSize,
              shape: NodeShape.circle,
            ),
        ],
        edges: [
          for (final e in storage.arcs)
            SceneEdge(
              id: e.id,
              fromNodeId: e.tail,
              toNodeId: e.head,
              style: input.kind.directed
                  ? EdgeStyle.solidArrow
                  : EdgeStyle.undirected,
              curvature:
                  input.kind.directed &&
                      storage.cells.containsKey((e.head, e.tail))
                  ? 36
                  : 0,
              weightLabel: input.kind.weighted ? e.weight.toString() : null,
            ),
        ],
      ),
      {for (final v in input.vertices) v.id: v.point},
      width: graphWidth,
      height: graphHeight,
      padding: graphPadding,
    );
