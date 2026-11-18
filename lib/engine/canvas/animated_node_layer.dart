import 'package:flutter/material.dart';
import '../../models/trace_model.dart';
import '../layout/circular_queue_layout.dart';
import 'edge_geometry.dart';

/// Geometry arrives from the single playback Ticker/SceneInterpolator. No local
/// position tween: seeking and reverse playback must render the exact same frame.
class AnimatedNodeLayer extends StatelessWidget {
  const AnimatedNodeLayer({
    super.key,
    required this.scene,
    this.pinnedIds = const {},
    this.selectedId,
    this.onSelect,
    this.barMode = false,
    this.nodeContentBuilder,
  });
  final SceneSnapshot scene;
  final Set<String> pinnedIds;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final bool barMode;
  final Widget Function(BuildContext, SceneNode)? nodeContentBuilder;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final byId = {for (final n in scene.nodes) n.id: n};
    Color tint(SceneNode n) =>
        n.isOrphanLeak || n.visualState == NodeVisualState.error
        ? colors.errorContainer
        : (n.isZeroSentinelSlot || n.visualState == NodeVisualState.sentinel)
        ? Colors.deepPurple.shade700
        : switch (n.visualState) {
            NodeVisualState.active => colors.primaryContainer,
            NodeVisualState.comparing => colors.tertiaryContainer,
            NodeVisualState.moving => colors.secondaryContainer,
            NodeVisualState.sorted => colors.tertiaryContainer,
            _ => colors.surfaceContainerHighest,
          };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final node in scene.nodes) ...[
          Positioned(
            key: ValueKey('node-position-${node.id}'),
            left: node.x,
            top: node.y,
            width: node.width,
            height: node.height,
            child: RepaintBoundary(
              key: ValueKey('scene-node-${node.id}'),
              child: Semantics(
                label: node.label,
                excludeSemantics: true,
                hidden:
                    node.isDeleted || node.opacity <= .01 || node.scale <= 0,
                selected: node.id == selectedId,
                button: true,
                onTap: () => onSelect?.call(node.id),
                child: Opacity(
                  opacity: node.opacity,
                  child: Transform.scale(
                    scale: node.scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            (barMode &&
                                        node.visualState ==
                                            NodeVisualState.normal
                                    ? colors.primary
                                    : tint(node))
                                .withValues(
                                  alpha:
                                      scene.zones.any(
                                        (z) =>
                                            z.pattern == ZonePattern.hatched &&
                                            node.x >= z.x &&
                                            node.x < z.x + z.width &&
                                            node.y >= z.y &&
                                            node.y < z.y + z.height,
                                      )
                                      ? .45
                                      : 1,
                                ),
                        borderRadius: BorderRadius.circular(
                          barMode
                              ? 2
                              : node.shape == NodeShape.circle
                              ? node.width / 2
                              : 10,
                        ),
                        border: Border.all(
                          color: node.isOrphanLeak
                              ? colors.error
                              : (node.isZeroSentinelSlot ||
                                    node.visualState ==
                                        NodeVisualState.sentinel)
                              ? Colors.deepPurple.shade200
                              : colors.primary,
                          width: node.id == selectedId ? 4 : 2,
                        ),
                      ),
                      child: barMode
                          ? null
                          : nodeContentBuilder?.call(context, node) ??
                                Center(
                                  child: Text(
                                    node.label,
                                    style: TextStyle(
                                      color: node.isOrphanLeak
                                          ? colors.onErrorContainer
                                          : (node.isZeroSentinelSlot ||
                                                node.visualState ==
                                                    NodeVisualState.sentinel)
                                          ? Colors.white
                                          : colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (pinnedIds.contains(node.id))
            Positioned(
              left: node.x + node.width - 8,
              top: node.y - 8,
              child: Icon(Icons.push_pin, size: 16, color: colors.tertiary),
            ),
          if (!barMode && node.indexBadge != null)
            Positioned(
              left: node.x,
              top: node.y - 20,
              child: Text(
                node.indexBadge!,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          if (!barMode && node.logicBadge != null)
            Positioned(
              left: node.x,
              top: node.y + node.height + 4,
              child: Text(
                node.logicBadge!,
                style: const TextStyle(fontSize: 10),
              ),
            ),
        ],
        for (final edge in scene.edges)
          if (edge.weightLabel != null &&
              edge.opacity > .01 &&
              edge.drawProgress > 0 &&
              byId.containsKey(edge.toNodeId))
            Builder(
              builder: (context) {
                final geometry = edgeGeometry(scene, edge, byId);
                if (geometry == null) return const SizedBox.shrink();
                final label = curvePoint(geometry, .5);
                return Positioned(
                  left: label.dx - 12,
                  top: label.dy - 10,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        child: Opacity(
                          opacity: edge.opacity,
                          child: Text(
                            edge.weightLabel!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        for (final p in scene.pointers)
          if (p.orbit != null || byId.containsKey(p.targetNodeId))
            Builder(
              builder: (context) {
                final orbit = p.orbit;
                final point = orbit != null
                    ? CircularQueueLayout.position(orbit)
                    : Vec2(
                        x: byId[p.targetNodeId]!.x + p.dx,
                        y: byId[p.targetNodeId]!.y + p.dy,
                      );
                return Positioned(
                  left: point.x - (orbit == null ? 0 : 16),
                  top: point.y,
                  child: Opacity(
                    opacity: p.opacity,
                    child: Text(
                      p.label + (orbit == null ? ' ↓' : ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
        if (scene.zones.isNotEmpty)
          Positioned(
            left: 16,
            top: 8,
            right: 16,
            child: Text(
              scene.zones.map((z) => z.label).join(' · '),
              style: TextStyle(
                fontSize: 12,
                color:
                    scene.zones.any(
                      (z) => z.visualState == NodeVisualState.error,
                    )
                    ? colors.error
                    : colors.onSurface,
              ),
            ),
          ),
        if (scene.nodes.any((n) => n.isOrphanLeak))
          Positioned(
            left: 32,
            top: 12,
            child: Text(
              '警告：红框结点不可达，发生内存泄漏',
              style: TextStyle(color: colors.error),
            ),
          ),
      ],
    );
  }
}
