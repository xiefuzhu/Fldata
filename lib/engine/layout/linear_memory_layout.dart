import '../../models/trace_model.dart';
import '../vm/trace_validation.dart';

/// List order is storage order. Stable node IDs remain owned by the caller.
abstract final class LinearMemoryLayout {
  static const slotWidth = 56.0;
  static const slotHeight = 48.0;
  static const gap = 8.0;
  static const sentinelGap = 24.0;

  static SceneSnapshot arrange(
    List<SceneNode> slots, {
    bool hasSentinelZero = false,
    Vec2 origin = const Vec2(x: 32, y: 120),
  }) {
    if (!origin.x.isFinite ||
        !origin.y.isFinite ||
        (hasSentinelZero && slots.isEmpty)) {
      throw ArgumentError('A sentinel needs slot zero and a finite origin');
    }
    final result = SceneSnapshot(
      layoutMode: SceneLayoutMode.linearMemory,
      nodes: [
        for (var i = 0; i < slots.length; i++)
          slots[i].copyWith(
            x:
                origin.x +
                i * (slotWidth + gap) +
                (hasSentinelZero && i > 0 ? sentinelGap - gap : 0),
            y: origin.y,
            width: slotWidth,
            height: slotHeight,
            shape: NodeShape.arraySlot,
            indexBadge: '[$i]',
            logicBadge: hasSentinelZero && i == 0
                ? '哨兵 / 暂存'
                : '位序 ${hasSentinelZero ? i : i + 1}',
            isZeroSentinelSlot: hasSentinelZero && i == 0,
            visualState: hasSentinelZero && i == 0
                ? NodeVisualState.sentinel
                : slots[i].visualState,
          ),
      ],
      zones: [
        if (hasSentinelZero)
          SceneZoneOverlay(
            id: 'sentinel-divider',
            label: '监视哨/枢轴暂存',
            x: origin.x + slotWidth + sentinelGap / 2,
            y: origin.y - 8,
            width: 1,
            height: slotHeight + 16,
            pattern: ZonePattern.dashed,
            visualState: NodeVisualState.sentinel,
          ),
      ],
    );
    validateScene(result);
    return result;
  }

  static SceneSnapshot sharedStacks(
    List<SceneNode> slots, {
    int topLeft = -1,
    int? topRight,
    Vec2 origin = const Vec2(x: 32, y: 120),
  }) {
    final right = topRight ?? slots.length;
    if (slots.isEmpty ||
        topLeft < -1 ||
        topLeft >= slots.length ||
        right < 0 ||
        right > slots.length ||
        topLeft + 1 > right) {
      throw ArgumentError('Stack tops overlap or are outside storage');
    }
    final scene = arrange(slots, origin: origin);
    final full = topLeft + 1 == right;
    return scene.copyWith(
      nodes: [
        for (var i = 0; i < slots.length; i++)
          scene.nodes[i].copyWith(
            groupTag: i <= topLeft
                ? 'left-stack'
                : i >= right
                ? 'right-stack'
                : null,
            visualState: i <= topLeft || i >= right
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
      ],
      pointers: [
        PointerBadge(
          id: 'top-left',
          label: 'top[0]=$topLeft',
          targetNodeId: topLeft < 0 ? nullNodeId : slots[topLeft].id,
        ),
        PointerBadge(
          id: 'top-right',
          label: 'top[1]=$right',
          targetNodeId: right == slots.length ? nullNodeId : slots[right].id,
          dy: 76,
        ),
      ],
      zones: [
        if (full)
          SceneZoneOverlay(
            id: 'stack-full',
            label: '满栈告警：top[0] + 1 == top[1]',
            x: origin.x + right * (slotWidth + gap) - gap,
            y: origin.y - 8,
            width: gap,
            height: slotHeight + 16,
            visualState: NodeVisualState.error,
            pattern: ZonePattern.dashed,
          ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'stack-tops',
          title: '共享双栈',
          columns: const ['top[0]', 'top[1]', '剩余槽位'],
          rows: [
            [
              topLeft.toString(),
              right.toString(),
              (right - topLeft - 1).toString(),
            ],
          ],
        ),
      ],
    );
  }
}
