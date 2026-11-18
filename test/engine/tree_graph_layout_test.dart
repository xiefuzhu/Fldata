import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/layout/tree_reingold_layout.dart';
import 'package:fldata/engine/layout/graph_layout_engine.dart';
import 'package:fldata/engine/layout/graph_presets.dart';
import 'package:fldata/engine/examples/tree_graph_trace_demo.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/engine/vm/trace_validation.dart';
import 'package:fldata/models/trace_model.dart';

SceneNode node(String id, {double width = 48, double height = 48}) =>
    SceneNode(id: id, label: id, x: 0, y: 0, width: width, height: height);
SceneEdge edge(String a, String b, {EdgePort port = EdgePort.auto}) =>
    SceneEdge(id: '$a-$b', fromNodeId: a, toNodeId: b, fromPort: port);
Vec2 center(SceneNode n) => Vec2(x: n.x + n.width / 2, y: n.y + n.height / 2);
void separated(SceneSnapshot scene) {
  for (var i = 0; i < scene.nodes.length; i++) {
    final a = scene.nodes[i];
    for (final b in scene.nodes.skip(i + 1)) {
      if (a.y == b.y) {
        final left = a.x < b.x ? a : b, right = a.x < b.x ? b : a;
        expect(
          right.x - left.x - left.width,
          greaterThanOrEqualTo(24 - 1e-8),
          reason: '${a.id}/${b.id}',
        );
      }
      final overlapX =
          math.min(a.x + a.width, b.x + b.width) - math.max(a.x, b.x);
      final overlapY =
          math.min(a.y + a.height, b.y + b.height) - math.max(a.y, b.y);
      expect(
        overlapX > 1e-8 && overlapY > 1e-8,
        isFalse,
        reason: '${a.id}/${b.id}',
      );
    }
  }
}

void main() {
  test('100 mixed-width nodes have disjoint contours and centered parents', () {
    final nodes = [
      for (var i = 0; i < 100; i++)
        node(
          'n$i',
          width: i % 3 == 0
              ? 48
              : i % 3 == 1
              ? 120
              : 172,
          height: i % 4 == 0 ? 76 : 44,
        ),
    ];
    final edges = [
      for (var i = 1; i < 100; i++) edge('n${(i - 1) ~/ 3}', 'n$i'),
    ];
    final source = SceneSnapshot(nodes: nodes, edges: edges);
    final result = TreeReingoldLayout.arrange(source);
    separated(result);
    validateScene(result);
    final byId = {for (final n in result.nodes) n.id: n};
    for (final parent in result.nodes) {
      final kids = edges
          .where((e) => e.fromNodeId == parent.id)
          .map((e) => byId[e.toNodeId]!)
          .toList();
      if (kids.isNotEmpty) {
        expect(
          center(parent).x,
          closeTo(
            kids.map((n) => center(n).x).reduce((a, b) => a + b) / kids.length,
            1e-8,
          ),
        );
        for (final child in kids) {
          expect(child.y - parent.y - parent.height, greaterThanOrEqualTo(56));
        }
      }
    }
    expect(source.nodes.every((n) => n.x == 0 && n.y == 0), isTrue);
    expect(TreeReingoldLayout.arrange(source), result);
    expect(result.edges, source.edges);
  });
  test(
    'forest order, binary ports and deep chains preserve layout semantics',
    () {
      final scene = SceneSnapshot(
        nodes: [
          node('root'),
          node('left', width: 120),
          node('right'),
          node('other', width: 172),
        ],
        edges: [
          edge('root', 'right', port: EdgePort.rchild),
          edge('root', 'left', port: EdgePort.lchild),
        ],
      );
      final result = TreeReingoldLayout.arrange(
        scene,
        roots: ['other', 'root'],
      );
      separated(result);
      final byId = {for (final n in result.nodes) n.id: n};
      expect(byId['other']!.x, lessThan(byId['root']!.x));
      expect(byId['left']!.x, lessThan(byId['right']!.x));
      expect(TreeReingoldLayout.arrange(const SceneSnapshot()).nodes, isEmpty);
      final chain = SceneSnapshot(
        nodes: [for (var i = 0; i < 100; i++) node(i.toString())],
        edges: [
          for (var i = 1; i < 100; i++) edge((i - 1).toString(), i.toString()),
        ],
      );
      final laid = TreeReingoldLayout.arrange(chain);
      expect(laid.nodes.map((n) => center(n).x).toSet(), hasLength(1));
      separated(laid);
    },
  );
  test('tree rejects cycles and shared children while ignoring threads', () {
    final nodes = [node('a'), node('b'), node('c')];
    expect(
      () => TreeReingoldLayout.arrange(
        SceneSnapshot(nodes: nodes, edges: [edge('a', 'b'), edge('b', 'a')]),
      ),
      throwsArgumentError,
    );
    expect(
      () => TreeReingoldLayout.arrange(
        SceneSnapshot(nodes: nodes, edges: [edge('a', 'c'), edge('b', 'c')]),
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          TreeReingoldLayout.arrange(SceneSnapshot(nodes: nodes), roots: ['a']),
      throwsArgumentError,
    );
    final threaded = TreeReingoldLayout.arrange(
      SceneSnapshot(
        nodes: nodes,
        edges: [
          edge('a', 'b'),
          edge('b', 'a').copyWith(style: EdgeStyle.dashedThread),
        ],
      ),
    );
    separated(threaded);
    expect(threaded.edges, hasLength(2));
  });
  test('B-tree widths, split IDs, reversible rotation and JSON snapshots', () {
    expect(
      TreeReingoldLayout.bTreeNode(id: 'b', keys: ['10', '20', '30']).width,
      136,
    );
    const demo = TreeGraphTraceDemo();
    for (final p in demo.presets) {
      final trace = demo.generateTrace(p.input);
      validateTimeline(trace);
      expect(
        TraceTimeline.fromJson(
          jsonDecode(jsonEncode(trace.toJson())) as Map<String, dynamic>,
        ),
        trace,
      );
      for (final frame in trace.frames.where(
        (f) => f.scene.layoutMode == SceneLayoutMode.tree,
      )) {
        separated(frame.scene);
      }
      if (trace.frames.length > 1) {
        final from = trace.frames.first.scene, to = trace.frames.last.scene;
        final halfway = SceneInterpolator.lerp(
          from,
          to,
          .5,
          spatialProgress: .7,
        );
        expect(SceneInterpolator.lerp(from, to, 0), from);
        expect(SceneInterpolator.lerp(from, to, 1), to);
        expect(
          SceneInterpolator.lerp(from, to, .5, spatialProgress: .7),
          halfway,
        );
        final old = from.nodes.first,
            next = to.nodes.firstWhere((n) => n.id == old.id);
        expect(
          halfway.nodes.first.x,
          closeTo(old.x + (next.x - old.x) * .7, 1e-8),
        );
      }
    }
  });
  test(
    'table 6.4 preset retains supplied edges and normalized coordinates',
    () {
      final graph = GraphPresets.table64();
      expect(graph.nodes, hasLength(6));
      expect(graph.edges, hasLength(8));
      expect(
        graph.edges
            .map((e) => '${e.fromNodeId}->${e.toNodeId}:${e.weightLabel!}')
            .toSet(),
        {
          'v0->v2:10',
          'v0->v4:30',
          'v0->v5:100',
          'v1->v2:5',
          'v2->v3:50',
          'v3->v5:10',
          'v4->v3:20',
          'v4->v5:60',
        },
      );
      final pinned = GraphLayoutEngine.preset(
        graph,
        GraphPresets.table64Coordinates,
        pins: const {'v0': Vec2(x: 100, y: 100)},
      );
      expect(center(pinned.nodes.first), const Vec2(x: 100, y: 100));
      expect(() => GraphLayoutEngine.preset(graph, {}), throwsArgumentError);
    },
  );
  test('force layout is deterministic, bounded and respects fixed centers', () {
    final graph = GraphPresets.table64();
    const pins = {'v0': Vec2(x: 100, y: 100), 'v5': Vec2(x: 480, y: 300)};
    final result = GraphLayoutEngine.forceDirected(graph, pins: pins);
    final reversed = GraphLayoutEngine.forceDirected(
      graph.copyWith(
        nodes: graph.nodes.reversed.toList(),
        edges: graph.edges.reversed.toList(),
      ),
      pins: pins,
    );
    expect(
      {for (final n in reversed.nodes) n.id: center(n)},
      {for (final n in result.nodes) n.id: center(n)},
    );
    for (final n in result.nodes) {
      expect(n.x.isFinite && n.y.isFinite, isTrue);
      expect(n.x, greaterThanOrEqualTo(32));
      expect(n.y, greaterThanOrEqualTo(32));
      expect(n.x + n.width, lessThanOrEqualTo(548));
      expect(n.y + n.height, lessThanOrEqualTo(368));
      if (pins.containsKey(n.id)) expect(center(n), pins[n.id]);
    }
    expect(graph, GraphPresets.table64());
    expect(
      GraphLayoutEngine.forceDirected(const SceneSnapshot()).nodes,
      isEmpty,
    );
    expect(
      GraphLayoutEngine.forceDirected(
        SceneSnapshot(nodes: [node('solo')]),
      ).nodes,
      hasLength(1),
    );
    expect(
      GraphLayoutEngine.forceDirected(
        SceneSnapshot(nodes: [node('a'), node('b'), node('c')]),
      ).nodes.map(center).toSet(),
      hasLength(3),
    );
    expect(
      () => GraphLayoutEngine.forceDirected(
        graph,
        pins: const {'v0': Vec2(x: -1, y: 0)},
      ),
      throwsArgumentError,
    );
    expect(
      () => GraphLayoutEngine.forceDirected(
        graph,
        pins: const {'missing': Vec2(x: 100, y: 100)},
      ),
      throwsArgumentError,
    );
    expect(
      () => GraphLayoutEngine.forceDirected(graph, iterations: 0),
      throwsArgumentError,
    );
  });
  test(
    'isolate layout owns inputs and matches the synchronous solver',
    () async {
      final graph = GraphPresets.table64();
      final nodes = graph.nodes.toList();
      final pins = {'v0': const Vec2(x: 100, y: 100)};
      final expected = GraphLayoutEngine.forceDirected(graph, pins: pins);
      final future = GraphLayoutEngine.forceDirectedAsync(
        graph.copyWith(nodes: nodes),
        pins: pins,
      );
      nodes.clear();
      pins.clear();
      expect(await future, expected);
    },
  );
}
