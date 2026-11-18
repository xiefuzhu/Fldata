import 'package:flutter/material.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/trace_model.dart';
import '../../curriculum/achievement_practice.dart';
import '../../curriculum/ch6_graph/graph_examples.dart';
import '../../curriculum/ch6_graph/graph_input.dart';

class CriticalEdgePicker extends StatelessWidget {
  const CriticalEdgePicker({
    super.key,
    required this.edges,
    required this.toggle,
    this.parallel = false,
  });
  final bool parallel;
  final Set<String> edges;
  final ValueChanged<String>? toggle;
  static const activities = [
    (1, 2, 2),
    (1, 3, 15),
    (3, 2, 4),
    (2, 4, 10),
    (2, 5, 19),
    (3, 5, 11),
    (4, 6, 6),
    (5, 6, 5),
  ];
  @override
  Widget build(BuildContext context) {
    const positions = [
      (12.0, 90.0),
      (140.0, 30.0),
      (140.0, 150.0),
      (300.0, 30.0),
      (300.0, 150.0),
      (438.0, 90.0),
    ];
    final graph = parallelAoeGraph;
    final base = parallel
        ? graphScene(graph, GraphStorage(graph, graph.arcs.length))
        : null;
    final scene = base == null
        ? SceneSnapshot(
            nodes: [
              for (final (i, p) in positions.indexed)
                SceneNode(
                  id: '${i + 1}',
                  label: '${i + 1}',
                  shape: NodeShape.circle,
                  x: p.$1,
                  y: p.$2,
                  width: 40,
                  height: 40,
                ),
            ],
            edges: [
              for (final (u, v, w) in activities)
                SceneEdge(
                  id: '$u→$v',
                  fromNodeId: '$u',
                  toNodeId: '$v',
                  weightLabel: '$w',
                  visualState: edges.contains('$u→$v')
                      ? NodeVisualState.active
                      : NodeVisualState.normal,
                ),
            ],
          )
        : base.copyWith(
            edges: [
              for (final e in base.edges)
                e.copyWith(
                  id: '${e.fromNodeId}→${e.toNodeId}',
                  visualState: edges.contains('${e.fromNodeId}→${e.toNodeId}')
                      ? NodeVisualState.active
                      : NodeVisualState.normal,
                ),
            ],
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('点选关键活动弧', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(
          height: 230,
          child: DsStageCanvas(
            scene: scene,
            sceneSize: parallel
                ? const Size(graphWidth, graphHeight)
                : const Size(500, 220),
            onEdgeTap: toggle,
          ),
        ),
        Wrap(
          spacing: 6,
          children: [
            for (final edge in scene.edges)
              FilterChip(
                key: ValueKey('critical-${edge.id}'),
                label: Text(edge.id),
                selected: edges.contains(edge.id),
                onSelected: toggle == null ? null : (_) => toggle!(edge.id),
              ),
          ],
        ),
      ],
    );
  }
}
