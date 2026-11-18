import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/trace_model.dart';
import '../canvas/ds_stage_canvas.dart';
import 'call_tree_projection.dart';

class CallStackInspector extends StatefulWidget {
  const CallStackInspector({
    super.key,
    required this.timeline,
    required this.frameIndex,
  });
  final TraceTimeline timeline;
  final int frameIndex;
  @override
  State<CallStackInspector> createState() => _CallStackInspectorState();
}

class _CallStackInspectorState extends State<CallStackInspector> {
  bool tree = false;
  String? selected;
  late CallTreeProjection projection;
  late SceneSnapshot treeScene;
  @override
  void initState() {
    super.initState();
    rebuildProjection();
  }

  @override
  void didUpdateWidget(CallStackInspector old) {
    super.didUpdateWidget(old);
    if (!identical(old.timeline, widget.timeline) ||
        old.frameIndex != widget.frameIndex) {
      rebuildProjection();
    }
  }

  void rebuildProjection() {
    projection = CallTreeProjection(widget.timeline, widget.frameIndex);
    treeScene = projection.scene;
    if (!projection.records.containsKey(selected)) selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final stack = widget.timeline.frames[widget.frameIndex].callStack;
    final selectedId = selected ?? projection.topId;
    final record = projection.records[selectedId];
    final colors = Theme.of(context).colorScheme;
    Widget card(StackActivationRecord r, {bool selectable = true}) => Card(
      key: ValueKey('call-card-${r.id}'),
      color: r.id == selectedId
          ? colors.secondaryContainer
          : colors.surfaceContainer,
      child: InkWell(
        onTap: selectable ? () => setState(() => selected = r.id) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.functionName + (r.id == projection.topId ? ' · 栈顶' : ''),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '实参：${r.arguments.isEmpty ? '无' : r.arguments.entries.map((e) => '${e.key}=${e.value}').join('，')}',
              ),
              Text(
                '局部：${r.locals.isEmpty ? '无' : r.locals.entries.map((e) => '${e.key}=${e.value}').join('，')}',
              ),
              Text(
                'RetLoc：${r.returnLocation}',
                key: ValueKey('retloc-${r.id}'),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    var width = 500.0, height = 260.0;
    for (final n in treeScene.nodes) {
      width = math.max(width, n.x + n.width + 32);
      height = math.max(height, n.y + n.height + 48);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          key: const ValueKey('call-view'),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: false, label: Text('调用栈')),
            ButtonSegment(value: true, label: Text('递归树')),
          ],
          selected: {tree},
          onSelectionChanged: (v) => setState(() => tree = v.single),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: tree
              ? Column(
                  children: [
                    Expanded(
                      child: projection.records.isEmpty
                          ? const Center(child: Text('尚无调用'))
                          : DsStageCanvas(
                              scene: treeScene,
                              sceneSize: Size(width, height),
                              selectedNodeId: selectedId,
                              onSelect: (id) => setState(() => selected = id),
                            ),
                    ),
                    if (record != null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: card(record, selectable: false),
                        ),
                      ),
                  ],
                )
              : stack.isEmpty
              ? const Center(child: Text('调用栈：已返回'))
              : ListView(
                  children: [
                    const Text('栈顶 ↓ · 选择栈帧可在递归树中查看'),
                    for (final r in stack.reversed) card(r),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('栈底'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
