import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/graph_examples.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';

enum _GraphTool {
  move('拖动固定'),
  add('加点'),
  link('连边'),
  remove('删除点边');

  const _GraphTool(this.label);
  final String label;
}

abstract class GraphLessonPlayer<W extends ConsumerStatefulWidget>
    extends LessonPlayer<W, GraphInputModel> {
  bool get startAtLast => false;
  String get replayLabel;
  bool get showGraphTools => true;
  String? marked;
  var tool = _GraphTool.move;
  String? start, error;
  GraphInputModel? dragPreview;
  Vec2? grabOffset;
  @override
  void loadInput(GraphInputModel next) {
    start = null;
    marked = null;
    error = null;
    dragPreview = null;
    grabOffset = null;
    super.loadInput(next);
    if (startAtLast) vm.last();
  }

  void _selectTool(_GraphTool next) {
    if (startAtLast) {
      vm.last();
    } else {
      vm.pause();
    }
    setState(() {
      tool = next;
      start = null;
      error = null;
      marked = null;
    });
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    if (showGraphTools)
      DropdownButton<_GraphTool>(
        key: const ValueKey('graph-tool'),
        value: tool,
        items: [
          for (final t in _GraphTool.values)
            DropdownMenuItem(value: t, child: Text(t.label)),
        ],
        onChanged: (t) {
          if (t != null) _selectTool(t);
        },
      ),
    IconButton(
      tooltip: replayLabel,
      icon: const Icon(Icons.replay),
      onPressed: () {
        setState(() {
          start = null;
          marked = null;
          error = null;
        });
        vm.first();
        vm.play(direction: PlaybackDirection.forward);
      },
    ),
  ];

  Future<void> selectVertex(String id) async {
    if (tool == _GraphTool.remove) {
      runCustomInput(input.removeVertex(id));
      return;
    }
    if (tool != _GraphTool.link) return;
    if (start == null) {
      setState(() {
        start = id;
        error = null;
      });
      return;
    }
    final tail = start!;
    setState(() => start = null);
    if (input.edge(tail, id) != null) {
      setState(() => error = '$tail 与 $id 的这条边已存在');
      return;
    }
    final weight = input.kind.weighted
        ? await showDialog<int>(
            context: context,
            builder: (_) => _WeightDialog(
              tail: tail,
              head: id,
              directed: input.kind.directed,
            ),
          )
        : 1;
    if (mounted && weight != null) {
      runCustomInput(input.connect(tail, id, weight: weight));
    }
  }

  String get editorHint =>
      error ??
      switch (tool) {
        _GraphTool.add => '点击画布空白处添加顶点',
        _GraphTool.link => start == null ? '选择起点' : '已选 $start，点击终点',
        _GraphTool.remove => '点击顶点或边删除',
        _GraphTool.move => '拖动顶点固定位置',
      };
  Widget editorCanvas(
    SceneSnapshot scene, {
    bool traversal = false,
    CustomPainter Function(SceneSnapshot)? backdrop,
    Widget Function(BuildContext, SceneNode)? nodeContentBuilder,
  }) {
    final graph = dragPreview ?? input;
    final previewScene = dragPreview == null
        ? scene
        : graphScene(graph, GraphStorage(graph, graph.arcs.length));
    final positions = {for (final v in previewScene.nodes) v.id: v};
    final displayed = dragPreview == null
        ? scene
        : scene.copyWith(
            nodes: [
              for (final n in scene.nodes)
                n.copyWith(x: positions[n.id]!.x, y: positions[n.id]!.y),
            ],
          );
    return DsStageCanvas(
      scene: displayed,
      backdropPainter: backdrop?.call(displayed),
      nodeContentBuilder: nodeContentBuilder,
      traversalEdges: traversal,
      sceneSize: const Size(graphWidth, graphHeight),
      selectedNodeId: start,
      pulseEdgeId: marked,
      pinnedIds: {
        for (final v in graph.vertices)
          if (v.pinned) v.id,
      },
      onSelect: selectVertex,
      onBlankTap: tool == _GraphTool.add
          ? (p) => runCustomInput(input.addVertex(normalizedGraphPoint(p)))
          : null,
      onEdgeTap: tool == _GraphTool.remove
          ? (id) => runCustomInput(input.removeEdge(id))
          : null,
      onDragStart: (id, p) {
        vm.pause();
        final node = scene.nodes.firstWhere((v) => v.id == id);
        grabOffset = Vec2(
          x: node.x + node.width / 2 - p.x,
          y: node.y + node.height / 2 - p.y,
        );
      },
      onDrag: tool == _GraphTool.move
          ? (id, p) {
              final point = normalizedGraphPoint(
                Vec2(
                  x: p.x + (grabOffset?.x ?? 0),
                  y: p.y + (grabOffset?.y ?? 0),
                ),
              );
              setState(() => dragPreview = input.pin(id, point));
            }
          : null,
      onDragEnd: (id, cancelled) {
        final next = dragPreview;
        if (next != null && !cancelled) {
          changeInput(next);
        } else {
          setState(() => dragPreview = null);
        }
      },
    );
  }
}

class _WeightDialog extends StatefulWidget {
  const _WeightDialog({
    required this.tail,
    required this.head,
    required this.directed,
  });
  final String tail, head;
  final bool directed;
  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  String value = '1';
  String? error;
  void submit() {
    final w = int.tryParse(value.trim());
    if (w == null || w >= GraphInputModel.infinity) {
      setState(() => error = '请输入小于 32767 的整数');
      return;
    }
    Navigator.pop(context, w);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${widget.tail} ${widget.directed ? '→' : '—'} ${widget.head}'),
    content: TextFormField(
      initialValue: value,
      autofocus: true,
      decoration: InputDecoration(labelText: '权值', errorText: error),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      onChanged: (s) => value = s,
      onFieldSubmitted: (_) => submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: submit, child: const Text('连边')),
    ],
  );
}
