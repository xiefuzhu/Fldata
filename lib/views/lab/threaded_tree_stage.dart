import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/trace_model.dart';

class ThreadedTreeStage extends StatefulWidget {
  const ThreadedTreeStage({
    super.key,
    required this.frame,
    required this.traversal,
  });
  final TraceFrame frame;
  final bool traversal;
  @override
  State<ThreadedTreeStage> createState() => _ThreadedTreeStageState();
}

class _ThreadedTreeStageState extends State<ThreadedTreeStage> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    final frame = widget.frame, scene = frame.scene, vars = frame.inlineVars;
    final table = scene.auxTables.single;
    final fields = {for (final row in table.rows) row.first: row};
    final inspect = fields[selected] ?? fields[vars['p']];
    final width = scene.nodes.fold<double>(
      445,
      (v, n) => math.max(v, n.x + n.width + 100),
    );
    final height = scene.nodes.fold<double>(
      205,
      (v, n) => math.max(v, n.y + n.height + 46),
    );
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              frame.phaseTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.traversal
                  ? 'p = ${vars["p"]}　栈深 ${vars["栈深"]}'
                  : 'p = ${vars["p"]}　pre = ${vars["pre"]}',
            ),
            if (widget.traversal)
              Text(
                '中序输出　${vars["输出"]!.isEmpty ? "∅" : vars["输出"]}',
                key: const ValueKey('thread-output'),
              ),
            const Text('实线为孩子，紫色虚线为线索。'),
            SizedBox(
              height: (c.maxHeight - 128).clamp(210.0, 600.0),
              child: DsStageCanvas(
                scene: scene,
                sceneSize: Size(width, height),
                selectedNodeId: selected,
                onSelect: (id) => setState(() => selected = id),
                nodeContentBuilder: (context, node) =>
                    _ThreadBox(row: fields[node.id]!, node: node),
              ),
            ),
            if (inspect != null)
              Text(
                '${inspect[0]}　LTag=${inspect[1]}　lchild=${inspect[2]}　data=${inspect[3]}　rchild=${inspect[4]}　RTag=${inspect[5]}',
                key: const ValueKey('thread-inspect'),
              ),
            Text(frame.explanation),
          ],
        ),
      ),
    );
  }
}

class _ThreadBox extends StatelessWidget {
  const _ThreadBox({required this.row, required this.node});
  final List<String> row;
  final SceneNode node;
  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final color = node.visualState == NodeVisualState.sentinel
        ? Colors.white
        : palette.onSurface;
    const labels = ['LTag', 'lchild', 'data', 'rchild', 'RTag'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++)
            Expanded(
              flex: i == 1 || i == 3 ? 3 : 2,
              child: Container(
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(
                          left: BorderSide(color: color.withValues(alpha: .4)),
                        ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        style: TextStyle(fontSize: 10, color: color),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          row[i + 1],
                          style: TextStyle(
                            fontSize: 15,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
