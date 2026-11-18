import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch1_intro/struct_mapping.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/canvas/pointer_edge_painter.dart';
import '../../models/trace_model.dart';

SceneSnapshot mappingScene(SceneSnapshot scene, String group) {
  final nodes = scene.nodes.where((n) => n.groupTag == group).toList();
  final ids = nodes.map((n) => n.id).toSet();
  return SceneSnapshot(
    nodes: nodes,
    edges: scene.edges
        .where((e) => ids.contains(e.fromNodeId) && ids.contains(e.toNodeId))
        .toList(),
    auxTables: group == 'physical' ? scene.auxTables : const [],
  );
}

class StructMappingStage extends StatefulWidget {
  const StructMappingStage({
    super.key,
    required this.scene,
    required this.frameIndex,
    required this.logical,
    required this.onLogicalChanged,
    required this.onSelect,
    required this.followCamera,
    required this.onCameraInteraction,
  });
  final SceneSnapshot scene;
  final int frameIndex;
  final LogicalStructure logical;
  final ValueChanged<LogicalStructure> onLogicalChanged;
  final ValueChanged<int> onSelect;
  final bool followCamera;
  final VoidCallback onCameraInteraction;
  @override
  State<StructMappingStage> createState() => _StructMappingStageState();
}

class _StructMappingStageState extends State<StructMappingStage> {
  final memoryScroll = ScrollController();
  final memoryVertical = ScrollController(initialScrollOffset: 60);
  @override
  void initState() {
    super.initState();
    revealSelection();
  }

  @override
  void didUpdateWidget(StructMappingStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frameIndex != widget.frameIndex ||
        !identical(oldWidget.scene, widget.scene)) {
      revealSelection();
    }
  }

  void revealSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !memoryScroll.hasClients) return;
      final selected = widget.scene.nodes
          .where(
            (n) =>
                n.groupTag == 'physical' &&
                n.visualState == NodeVisualState.active,
          )
          .firstOrNull;
      if (selected == null) return;
      if (memoryVertical.hasClients) {
        final p = memoryVertical.position;
        memoryVertical.jumpTo(
          (148 - p.viewportDimension / 2).clamp(0.0, p.maxScrollExtent),
        );
      }
      final position = memoryScroll.position;
      memoryScroll.jumpTo(
        (selected.x + selected.width / 2 - position.viewportDimension / 2)
            .clamp(0.0, position.maxScrollExtent),
      );
    });
  }

  @override
  void dispose() {
    memoryScroll.dispose();
    memoryVertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logical = mappingScene(widget.scene, 'logical');
    final physical = mappingScene(widget.scene, 'physical');
    var width = 500.0, height = 320.0;
    for (final node in logical.nodes) {
      width = math.max(width, node.x + node.width + 32);
      height = math.max(height, node.y + node.height + 32);
    }
    final logicPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '逻辑关系 · 点击结点定位内存',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: DsStageCanvas(
            key: const ValueKey('mapping-logical-canvas'),
            scene: logical,
            sceneSize: Size(width, height),
            selectedNodeId: widget.frameIndex == 0
                ? null
                : 'logical-${widget.frameIndex - 1}',
            followCamera: widget.followCamera,
            onCameraInteraction: widget.onCameraInteraction,
            onSelect: (id) => widget.onSelect(int.parse(id.split('-').last)),
          ),
        ),
      ],
    );
    final memoryPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '物理内存条 · 0x2000 → 0x2040',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: Scrollbar(
            controller: memoryScroll,
            thumbVisibility: true,
            notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: memoryScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1040,
                child: SingleChildScrollView(
                  controller: memoryVertical,
                  primary: false,
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PointerEdgePainter(
                              physical,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        for (final node in physical.nodes)
                          Positioned(
                            left: node.x,
                            top: 80,
                            width: node.width,
                            child: _MemoryRecord(
                              node: node,
                              frameIndex: widget.frameIndex,
                              onTap: node.id.startsWith('physical-')
                                  ? () => widget.onSelect(
                                      int.parse(node.id.split('-').last),
                                    )
                                  : null,
                            ),
                          ),
                        const Positioned(
                          right: 4,
                          top: 216,
                          child: Text(
                            '0x2040\n区间终点',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    final content = Column(
      children: [
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<LogicalStructure>(
              key: const ValueKey('mapping-logical-kind'),
              showSelectedIcon: false,
              segments: [
                for (final kind in LogicalStructure.values)
                  ButtonSegment(
                    value: kind,
                    label: Text(['集合', '线性', '树形', '图形'][kind.index]),
                    tooltip: StructMappingModule.logicalNames[kind.index],
                  ),
              ],
              selected: {widget.logical},
              onSelectionChanged: (v) => widget.onLogicalChanged(v.single),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 700
                ? Row(
                    children: [
                      Expanded(flex: 4, child: logicPane),
                      const SizedBox(width: 12),
                      Expanded(flex: 6, child: memoryPane),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(flex: 55, child: logicPane),
                      const SizedBox(height: 8),
                      Expanded(flex: 45, child: memoryPane),
                    ],
                  ),
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        primary: false,
        child: SizedBox(
          height: math.max(320, constraints.maxHeight),
          child: content,
        ),
      ),
    );
  }
}

class _MemoryRecord extends StatelessWidget {
  const _MemoryRecord({
    required this.node,
    required this.frameIndex,
    required this.onTap,
  });
  final SceneNode node;
  final int frameIndex;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final active = node.visualState == NodeVisualState.active;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: active,
      button: onTap != null,
      child: InkWell(
        key: ValueKey('memory-slot-${node.id}'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              node.memoryAddress!,
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
            ),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              key: ValueKey('pulse-${node.id}-${active ? frameIndex : -1}'),
              tween: Tween(begin: 0, end: 1),
              duration: !active || MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 450),
              builder: (context, t, _) => Container(
                height: node.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? Color.lerp(
                          colors.primaryContainer,
                          colors.primary,
                          .25 * math.sin(math.pi * t),
                        )
                      : colors.surfaceContainerHighest,
                  border: Border.all(
                    color: active ? colors.primary : colors.outlineVariant,
                    width: active ? 3 : 1,
                  ),
                ),
                child: Text(
                  node.label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              node.logicBadge!,
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
