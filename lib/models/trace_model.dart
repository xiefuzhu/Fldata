import 'package:freezed_annotation/freezed_annotation.dart';
import '../enum/ds_enums.dart';
part 'trace_model.freezed.dart';
part 'trace_model.g.dart';

enum ZonePattern { solid, dashed, hatched }

enum SceneLayoutMode { freeCanvas, linearMemory, circularQueue, tree, graph }

enum NodeShape { roundedRect, circle, arraySlot, linkedCell, bTreeBox, bucket }

enum NodeVisualState {
  normal,
  active,
  comparing,
  moving,
  sorted,
  sentinel,
  error,
}

enum EdgePort { auto, next, prior, lchild, rchild, center }

enum EdgeStyle { solidArrow, dashedThread, undirected, shellArc, swapArc }

const nullNodeId = '_NULL_';

@freezed
abstract class Vec2 with _$Vec2 {
  const factory Vec2({required double x, required double y}) = _Vec2;
  factory Vec2.fromJson(Map<String, dynamic> json) => _$Vec2FromJson(json);
}

@freezed
abstract class TraceTimeline with _$TraceTimeline {
  const factory TraceTimeline({
    required String moduleId,
    required String inputSummary,
    required List<TraceFrame> frames,
    required Map<CodeLang, List<String>> codeLines,
  }) = _TraceTimeline;
  factory TraceTimeline.fromJson(Map<String, dynamic> json) =>
      _$TraceTimelineFromJson(json);
}

@freezed
abstract class TraceFrame with _$TraceFrame {
  const factory TraceFrame({
    required int stepIndex,
    required String phaseTitle,
    required String explanation,
    required Map<CodeLang, List<int>> activeLines,
    @Default({}) Map<String, String> inlineVars,
    required SceneSnapshot scene,
    @Default([]) List<StackActivationRecord> callStack,
    @Default(ComplexityMetrics()) ComplexityMetrics metrics,
    @Default(false) bool isKeyMilestone,
    @Default(false) bool isErrorState,
  }) = _TraceFrame;
  factory TraceFrame.fromJson(Map<String, dynamic> json) =>
      _$TraceFrameFromJson(json);
}

@freezed
abstract class SceneSnapshot with _$SceneSnapshot {
  const factory SceneSnapshot({
    @Default(SceneLayoutMode.freeCanvas) SceneLayoutMode layoutMode,
    @Default([]) List<SceneNode> nodes,
    @Default([]) List<SceneEdge> edges,
    @Default([]) List<PointerBadge> pointers,
    @Default([]) List<AuxTableSnapshot> auxTables,
    @Default([]) List<SceneZoneOverlay> zones,
  }) = _SceneSnapshot;
  factory SceneSnapshot.fromJson(Map<String, dynamic> json) =>
      _$SceneSnapshotFromJson(json);
}

@freezed
abstract class SceneNode with _$SceneNode {
  const factory SceneNode({
    required String id,
    required String label,
    required double x,
    required double y,
    @Default(56) double width,
    @Default(48) double height,
    @Default(NodeShape.roundedRect) NodeShape shape,
    @Default(NodeVisualState.normal) NodeVisualState visualState,
    String? indexBadge,
    String? logicBadge,
    String? memoryAddress,
    @Default(false) bool isZeroSentinelSlot,
    @Default(false) bool isOrphanLeak,
    @Default(false) bool isDeleted,
    @Default(1) double opacity,
    @Default(1) double scale,
    String? groupTag,
  }) = _SceneNode;
  factory SceneNode.fromJson(Map<String, dynamic> json) =>
      _$SceneNodeFromJson(json);
}

@freezed
abstract class SceneEdge with _$SceneEdge {
  const factory SceneEdge({
    required String id,
    required String fromNodeId,
    required String toNodeId,
    @Default(EdgePort.auto) EdgePort fromPort,
    @Default(EdgeStyle.solidArrow) EdgeStyle style,
    @Default(NodeVisualState.normal) NodeVisualState visualState,
    String? weightLabel,
    @Default(0) double curvature,
    @Default(1) double drawProgress,
    @Default(1) double opacity,
  }) = _SceneEdge;
  factory SceneEdge.fromJson(Map<String, dynamic> json) =>
      _$SceneEdgeFromJson(json);
}

/// Screen coordinates: increasing angle is clockwise (positive Y points down).
@freezed
abstract class PointerOrbit with _$PointerOrbit {
  const factory PointerOrbit({
    required Vec2 center,
    required double radius,
    required double angle,
  }) = _PointerOrbit;
  factory PointerOrbit.fromJson(Map<String, dynamic> json) =>
      _$PointerOrbitFromJson(json);
}

@freezed
abstract class PointerBadge with _$PointerBadge {
  const factory PointerBadge({
    required String id,
    required String label,
    required String targetNodeId,
    PointerOrbit? orbit,
    @Default(0) double dx,
    @Default(-28) double dy,
    @Default(NodeVisualState.active) NodeVisualState visualState,
    @Default(1) double opacity,
  }) = _PointerBadge;
  factory PointerBadge.fromJson(Map<String, dynamic> json) =>
      _$PointerBadgeFromJson(json);
}

@freezed
abstract class AuxTableSnapshot with _$AuxTableSnapshot {
  const factory AuxTableSnapshot({
    required String id,
    required String title,
    required List<String> columns,
    required List<List<String>> rows,
    @Default({}) Set<int> highlightedRows,
  }) = _AuxTableSnapshot;
  factory AuxTableSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AuxTableSnapshotFromJson(json);
}

@freezed
abstract class StackActivationRecord with _$StackActivationRecord {
  const factory StackActivationRecord({
    required String id,
    required String functionName,
    @Default({}) Map<String, String> arguments,
    @Default({}) Map<String, String> locals,
    required String returnLocation,
    String? parentCallId,
  }) = _StackActivationRecord;
  factory StackActivationRecord.fromJson(Map<String, dynamic> json) =>
      _$StackActivationRecordFromJson(json);
}

@freezed
abstract class SceneZoneOverlay with _$SceneZoneOverlay {
  const factory SceneZoneOverlay({
    required String id,
    required String label,
    required double x,
    required double y,
    required double width,
    required double height,
    @Default(ZonePattern.solid) ZonePattern pattern,
    @Default(NodeVisualState.normal) NodeVisualState visualState,
    @Default(1) double opacity,
  }) = _SceneZoneOverlay;
  factory SceneZoneOverlay.fromJson(Map<String, dynamic> json) =>
      _$SceneZoneOverlayFromJson(json);
}

@freezed
abstract class ComplexityMetrics with _$ComplexityMetrics {
  const factory ComplexityMetrics({
    @Default(0) int comparisons,
    @Default(0) int moves,
    @Default(0) int reads,
    @Default(0) int writes,
    @Default(0) int allocations,
    @Default(0) int auxiliarySpace,
    @Default(0) int peakAuxiliarySpace,
    @Default(0) int callDepth,
    @Default(0) int maxCallDepth,
    @Default({}) Map<String, int> statementCounts,
  }) = _ComplexityMetrics;
  factory ComplexityMetrics.fromJson(Map<String, dynamic> json) =>
      _$ComplexityMetricsFromJson(json);
}
