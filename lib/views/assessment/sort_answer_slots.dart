import 'package:flutter/material.dart';
import '../../engine/canvas/animated_node_layer.dart';
import '../../models/trace_model.dart';

class SortAnswerSlots extends StatelessWidget {
  const SortAnswerSlots({
    super.key,
    required this.values,
    required this.swap,
    required this.edit,
    this.marks,
  });
  final List<String> values;
  final List<bool?>? marks;
  final void Function(int, int)? swap;
  final void Function(int, String)? edit;
  Future<void> enter(BuildContext context, int index) async {
    var value = values[index];
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('填写 r[${index + 1}]'),
        content: TextFormField(
          autofocus: true,
          initialValue: value,
          decoration: const InputDecoration(labelText: '记录值（保留 * 标记）'),
          onChanged: (v) => value = v,
          onFieldSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, value),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (context.mounted && result != null) edit?.call(index, result.trim());
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (i, value) in values.indexed)
        DragTarget<int>(
          onWillAcceptWithDetails: (d) => swap != null && d.data != i,
          onAcceptWithDetails: (d) => swap?.call(d.data, i),
          builder: (context, candidates, _) {
            final label = value.isEmpty ? '…' : value;
            final slot = SceneNode(
              id: 'r$i',
              label: label,
              x: 1,
              y: 19,
              width: 60,
              height: 44,
              indexBadge: 'r[${i + 1}]',
              shape: NodeShape.arraySlot,
              visualState: candidates.isNotEmpty
                  ? NodeVisualState.active
                  : marks == null
                  ? NodeVisualState.normal
                  : marks![i] == true
                  ? NodeVisualState.sorted
                  : NodeVisualState.error,
            );
            return Semantics(
              label: 'r[${i + 1}]，$label',
              button: true,
              child: Draggable<int>(
                maxSimultaneousDrags: swap == null ? 0 : 1,
                data: i,
                feedback: Material(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(label),
                  ),
                ),
                child: InkWell(
                  key: ValueKey('answer-slot-$i'),
                  onTap: edit == null ? null : () => enter(context, i),
                  child: SizedBox(
                    width: 64,
                    height: 66,
                    child: IgnorePointer(
                      child: AnimatedNodeLayer(
                        scene: SceneSnapshot(nodes: [slot]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    ],
  );
}
