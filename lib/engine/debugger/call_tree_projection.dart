import '../../models/trace_model.dart';
import '../layout/tree_reingold_layout.dart';

/// Derive history from a prefix only. Stable activation IDs distinguish repeated
/// calls of the same function, and rewind never exposes a future invocation.
class CallTreeProjection {
  CallTreeProjection(TraceTimeline timeline, int frameIndex) {
    RangeError.checkValidIndex(frameIndex, timeline.frames);
    for (var i = 0; i <= frameIndex; i++) {
      final stack = timeline.frames[i].callStack;
      for (var depth = 0; depth < stack.length; depth++) {
        final record = stack[depth];
        final parent =
            record.parentCallId ?? (depth == 0 ? null : stack[depth - 1].id);
        records[record.id] = record;
        parents.putIfAbsent(record.id, () => parent);
        firstFrames.putIfAbsent(record.id, () => i);
      }
    }
    final stack = timeline.frames[frameIndex].callStack;
    activeIds = stack.map((r) => r.id).toSet();
    topId = stack.lastOrNull?.id;
  }
  final records = <String, StackActivationRecord>{};
  final parents = <String, String?>{};
  final firstFrames = <String, int>{};
  late final Set<String> activeIds;
  String? topId;
  SceneSnapshot get scene => TreeReingoldLayout.arrange(
    SceneSnapshot(
      layoutMode: SceneLayoutMode.tree,
      nodes: [
        for (final r in records.values)
          SceneNode(
            id: r.id,
            label: '${r.functionName}(${r.arguments.values.join(', ')})',
            x: 0,
            y: 0,
            width: 160,
            height: 52,
            logicBadge: r.id == topId
                ? '当前执行'
                : activeIds.contains(r.id)
                ? '等待返回'
                : '已返回',
            visualState: r.id == topId
                ? NodeVisualState.active
                : activeIds.contains(r.id)
                ? NodeVisualState.comparing
                : NodeVisualState.sorted,
          ),
      ],
      edges: [
        for (final id in records.keys)
          if (parents[id] != null && records.containsKey(parents[id]))
            SceneEdge(id: 'call-$id', fromNodeId: parents[id]!, toNodeId: id),
      ],
    ),
  );
}
