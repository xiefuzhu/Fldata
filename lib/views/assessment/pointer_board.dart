import 'dart:math' as math;
import '../../common/platform_detector.dart';
import 'package:flutter/material.dart';
import '../../engine/canvas/pointer_edge_painter.dart';
import '../../features/assessment/pointer_sandbox_judge.dart';
import '../../models/quiz_question.dart';
import '../../models/trace_model.dart';

typedef PointerPort = ({String? owner, String field});
String portName(PointerPort port) =>
    port.owner == null ? port.field : '${port.owner}.${port.field}';

class PointerBoard extends StatelessWidget {
  const PointerBoard({
    super.key,
    required this.question,
    required this.heap,
    required this.marked,
    required this.selected,
    required this.onSelect,
    required this.onConnect,
  });
  final PointerSandboxQuestion question;
  final PointerHeap heap;
  final Set<String> marked;
  final PointerPort? selected;
  final ValueChanged<PointerPort>? onSelect;
  final void Function(PointerPort, String?)? onConnect;

  void connect(PointerPort source, String? id) {
    PlatformDetector.selectionFeedback();
    onConnect?.call(source, id);
  }

  Widget port(BuildContext context, String? owner, String field, String? dest) {
    final source = (owner: owner, field: field),
        name = portName(source),
        label = '$field → ${dest ?? "NULL"}';
    return Draggable<PointerPort>(
      data: source,
      maxSimultaneousDrags: onConnect == null ? 0 : 1,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.all(10), child: Text(name)),
      ),
      child: TextButton(
        key: ValueKey('port-$name'),
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: selected == source
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        onPressed: onSelect == null
            ? null
            : () {
                PlatformDetector.selectionFeedback();
                onSelect!(source);
              },
        child: Text(label),
      ),
    );
  }

  Widget target(String? id, Widget Function(bool hover) build) =>
      DragTarget<PointerPort>(
        onWillAcceptWithDetails: (d) =>
            onConnect != null && (id == null || heap.live(id)),
        onAcceptWithDetails: (d) => connect(d.data, id),
        builder: (_, candidates, _) => build(candidates.isNotEmpty),
      );
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fields = [
      question.binaryTree ? 'lchild' : 'next',
      if (heap.prior.isNotEmpty) question.binaryTree ? 'rchild' : 'prior',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final e in heap.roots.entries)
              port(context, null, e.key, e.value),
            target(
              null,
              (hover) => OutlinedButton(
                key: const ValueKey('target-NULL'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: hover ? colors.primaryContainer : null,
                ),
                onPressed: selected == null || onConnect == null
                    ? null
                    : () => connect(selected!, null),
                child: const Text('NULL'),
              ),
            ),
          ],
        ),
        if (selected != null) Text('${portName(selected!)} → 点选目标结点或 NULL'),
        LayoutBuilder(
          builder: (context, c) {
            final count = heap.next.length,
                columns = math.max(
                  1,
                  math.min(count, (c.maxWidth / 148).floor()),
                );
            final slot = c.maxWidth / columns,
                width = math.min(166.0, slot - 24);
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final height = (48.0 + fields.length * 48) * math.max(1.0, scale);
            final nodes = [
              for (final (i, id) in heap.next.keys.indexed)
                SceneNode(
                  id: id,
                  label: id,
                  x: (i % columns) * slot + (slot - width) / 2,
                  y: (i ~/ columns) * (height + 50) + 24,
                  width: width,
                  height: height,
                ),
            ];
            final scene = SceneSnapshot(
              layoutMode: SceneLayoutMode.graph,
              nodes: nodes,
              edges: [
                for (final node in nodes.where((n) => heap.live(n.id)))
                  for (final (i, field) in fields.indexed)
                    if ((i == 0 ? heap.next : heap.prior)[node.id]
                        case final String dest)
                      SceneEdge(
                        id: '${node.id}.$field',
                        fromNodeId: node.id,
                        toNodeId: dest,
                        fromPort: i == 0 ? EdgePort.next : EdgePort.prior,
                        curvature: 32,
                        visualState: !heap.live(dest)
                            ? NodeVisualState.error
                            : i == 0
                            ? NodeVisualState.active
                            : NodeVisualState.normal,
                      ),
              ],
            );
            return SizedBox(
              width: c.maxWidth,
              height: ((count + columns - 1) ~/ columns) * (height + 50),
              child: CustomPaint(
                painter: PointerEdgePainter(scene, colors.outline),
                child: Stack(
                  children: [
                    for (final node in nodes)
                      Positioned(
                        left: node.x,
                        top: node.y,
                        width: width,
                        height: height,
                        child: target(node.id, (hover) {
                          final live = heap.live(node.id),
                              flag = marked.contains(node.id);
                          return Material(
                            color: flag
                                ? colors.errorContainer
                                : hover
                                ? colors.primaryContainer
                                : live
                                ? colors.surfaceContainerHigh
                                : colors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: flag
                                    ? colors.error
                                    : hover
                                    ? colors.primary
                                    : colors.outline,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  key: ValueKey('target-${node.id}'),
                                  onPressed:
                                      selected != null &&
                                          live &&
                                          onConnect != null
                                      ? () => connect(selected!, node.id)
                                      : null,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                    disabledForegroundColor: live
                                        ? colors.onSurface
                                        : colors.outline,
                                  ),
                                  child: Text(
                                    live ? '结点 ${node.id}' : '${node.id} · 已释放',
                                  ),
                                ),
                                if (live)
                                  for (final (i, field) in fields.indexed)
                                    port(
                                      context,
                                      node.id,
                                      field,
                                      (i == 0
                                          ? heap.next
                                          : heap.prior)[node.id],
                                    ),
                              ],
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
