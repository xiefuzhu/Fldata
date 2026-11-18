// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vec2 _$Vec2FromJson(Map<String, dynamic> json) =>
    _Vec2(x: (json['x'] as num).toDouble(), y: (json['y'] as num).toDouble());

Map<String, dynamic> _$Vec2ToJson(_Vec2 instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};

_TraceTimeline _$TraceTimelineFromJson(Map<String, dynamic> json) =>
    _TraceTimeline(
      moduleId: json['moduleId'] as String,
      inputSummary: json['inputSummary'] as String,
      frames: (json['frames'] as List<dynamic>)
          .map((e) => TraceFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      codeLines: (json['codeLines'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$CodeLangEnumMap, k),
          (e as List<dynamic>).map((e) => e as String).toList(),
        ),
      ),
    );

Map<String, dynamic> _$TraceTimelineToJson(_TraceTimeline instance) =>
    <String, dynamic>{
      'moduleId': instance.moduleId,
      'inputSummary': instance.inputSummary,
      'frames': instance.frames,
      'codeLines': instance.codeLines.map(
        (k, e) => MapEntry(_$CodeLangEnumMap[k]!, e),
      ),
    };

const _$CodeLangEnumMap = {
  CodeLang.cLike: 'cLike',
  CodeLang.c99: 'c99',
  CodeLang.dart: 'dart',
};

_TraceFrame _$TraceFrameFromJson(Map<String, dynamic> json) => _TraceFrame(
  stepIndex: (json['stepIndex'] as num).toInt(),
  phaseTitle: json['phaseTitle'] as String,
  explanation: json['explanation'] as String,
  activeLines: (json['activeLines'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$CodeLangEnumMap, k),
      (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
  ),
  inlineVars:
      (json['inlineVars'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  scene: SceneSnapshot.fromJson(json['scene'] as Map<String, dynamic>),
  callStack:
      (json['callStack'] as List<dynamic>?)
          ?.map(
            (e) => StackActivationRecord.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  metrics: json['metrics'] == null
      ? const ComplexityMetrics()
      : ComplexityMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
  isKeyMilestone: json['isKeyMilestone'] as bool? ?? false,
  isErrorState: json['isErrorState'] as bool? ?? false,
);

Map<String, dynamic> _$TraceFrameToJson(_TraceFrame instance) =>
    <String, dynamic>{
      'stepIndex': instance.stepIndex,
      'phaseTitle': instance.phaseTitle,
      'explanation': instance.explanation,
      'activeLines': instance.activeLines.map(
        (k, e) => MapEntry(_$CodeLangEnumMap[k]!, e),
      ),
      'inlineVars': instance.inlineVars,
      'scene': instance.scene,
      'callStack': instance.callStack,
      'metrics': instance.metrics,
      'isKeyMilestone': instance.isKeyMilestone,
      'isErrorState': instance.isErrorState,
    };

_SceneSnapshot _$SceneSnapshotFromJson(Map<String, dynamic> json) =>
    _SceneSnapshot(
      layoutMode:
          $enumDecodeNullable(_$SceneLayoutModeEnumMap, json['layoutMode']) ??
          SceneLayoutMode.freeCanvas,
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map((e) => SceneNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      edges:
          (json['edges'] as List<dynamic>?)
              ?.map((e) => SceneEdge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pointers:
          (json['pointers'] as List<dynamic>?)
              ?.map((e) => PointerBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      auxTables:
          (json['auxTables'] as List<dynamic>?)
              ?.map((e) => AuxTableSnapshot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((e) => SceneZoneOverlay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SceneSnapshotToJson(_SceneSnapshot instance) =>
    <String, dynamic>{
      'layoutMode': _$SceneLayoutModeEnumMap[instance.layoutMode]!,
      'nodes': instance.nodes,
      'edges': instance.edges,
      'pointers': instance.pointers,
      'auxTables': instance.auxTables,
      'zones': instance.zones,
    };

const _$SceneLayoutModeEnumMap = {
  SceneLayoutMode.freeCanvas: 'freeCanvas',
  SceneLayoutMode.linearMemory: 'linearMemory',
  SceneLayoutMode.circularQueue: 'circularQueue',
  SceneLayoutMode.tree: 'tree',
  SceneLayoutMode.graph: 'graph',
};

_SceneNode _$SceneNodeFromJson(Map<String, dynamic> json) => _SceneNode(
  id: json['id'] as String,
  label: json['label'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num?)?.toDouble() ?? 56,
  height: (json['height'] as num?)?.toDouble() ?? 48,
  shape:
      $enumDecodeNullable(_$NodeShapeEnumMap, json['shape']) ??
      NodeShape.roundedRect,
  visualState:
      $enumDecodeNullable(_$NodeVisualStateEnumMap, json['visualState']) ??
      NodeVisualState.normal,
  indexBadge: json['indexBadge'] as String?,
  logicBadge: json['logicBadge'] as String?,
  memoryAddress: json['memoryAddress'] as String?,
  isZeroSentinelSlot: json['isZeroSentinelSlot'] as bool? ?? false,
  isOrphanLeak: json['isOrphanLeak'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  scale: (json['scale'] as num?)?.toDouble() ?? 1,
  groupTag: json['groupTag'] as String?,
);

Map<String, dynamic> _$SceneNodeToJson(_SceneNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'shape': _$NodeShapeEnumMap[instance.shape]!,
      'visualState': _$NodeVisualStateEnumMap[instance.visualState]!,
      'indexBadge': instance.indexBadge,
      'logicBadge': instance.logicBadge,
      'memoryAddress': instance.memoryAddress,
      'isZeroSentinelSlot': instance.isZeroSentinelSlot,
      'isOrphanLeak': instance.isOrphanLeak,
      'isDeleted': instance.isDeleted,
      'opacity': instance.opacity,
      'scale': instance.scale,
      'groupTag': instance.groupTag,
    };

const _$NodeShapeEnumMap = {
  NodeShape.roundedRect: 'roundedRect',
  NodeShape.circle: 'circle',
  NodeShape.arraySlot: 'arraySlot',
  NodeShape.linkedCell: 'linkedCell',
  NodeShape.bTreeBox: 'bTreeBox',
  NodeShape.bucket: 'bucket',
};

const _$NodeVisualStateEnumMap = {
  NodeVisualState.normal: 'normal',
  NodeVisualState.active: 'active',
  NodeVisualState.comparing: 'comparing',
  NodeVisualState.moving: 'moving',
  NodeVisualState.sorted: 'sorted',
  NodeVisualState.sentinel: 'sentinel',
  NodeVisualState.error: 'error',
};

_SceneEdge _$SceneEdgeFromJson(Map<String, dynamic> json) => _SceneEdge(
  id: json['id'] as String,
  fromNodeId: json['fromNodeId'] as String,
  toNodeId: json['toNodeId'] as String,
  fromPort:
      $enumDecodeNullable(_$EdgePortEnumMap, json['fromPort']) ?? EdgePort.auto,
  style:
      $enumDecodeNullable(_$EdgeStyleEnumMap, json['style']) ??
      EdgeStyle.solidArrow,
  visualState:
      $enumDecodeNullable(_$NodeVisualStateEnumMap, json['visualState']) ??
      NodeVisualState.normal,
  weightLabel: json['weightLabel'] as String?,
  curvature: (json['curvature'] as num?)?.toDouble() ?? 0,
  drawProgress: (json['drawProgress'] as num?)?.toDouble() ?? 1,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
);

Map<String, dynamic> _$SceneEdgeToJson(_SceneEdge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromNodeId': instance.fromNodeId,
      'toNodeId': instance.toNodeId,
      'fromPort': _$EdgePortEnumMap[instance.fromPort]!,
      'style': _$EdgeStyleEnumMap[instance.style]!,
      'visualState': _$NodeVisualStateEnumMap[instance.visualState]!,
      'weightLabel': instance.weightLabel,
      'curvature': instance.curvature,
      'drawProgress': instance.drawProgress,
      'opacity': instance.opacity,
    };

const _$EdgePortEnumMap = {
  EdgePort.auto: 'auto',
  EdgePort.next: 'next',
  EdgePort.prior: 'prior',
  EdgePort.lchild: 'lchild',
  EdgePort.rchild: 'rchild',
  EdgePort.center: 'center',
};

const _$EdgeStyleEnumMap = {
  EdgeStyle.solidArrow: 'solidArrow',
  EdgeStyle.dashedThread: 'dashedThread',
  EdgeStyle.undirected: 'undirected',
  EdgeStyle.shellArc: 'shellArc',
  EdgeStyle.swapArc: 'swapArc',
};

_PointerOrbit _$PointerOrbitFromJson(Map<String, dynamic> json) =>
    _PointerOrbit(
      center: Vec2.fromJson(json['center'] as Map<String, dynamic>),
      radius: (json['radius'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
    );

Map<String, dynamic> _$PointerOrbitToJson(_PointerOrbit instance) =>
    <String, dynamic>{
      'center': instance.center,
      'radius': instance.radius,
      'angle': instance.angle,
    };

_PointerBadge _$PointerBadgeFromJson(Map<String, dynamic> json) =>
    _PointerBadge(
      id: json['id'] as String,
      label: json['label'] as String,
      targetNodeId: json['targetNodeId'] as String,
      orbit: json['orbit'] == null
          ? null
          : PointerOrbit.fromJson(json['orbit'] as Map<String, dynamic>),
      dx: (json['dx'] as num?)?.toDouble() ?? 0,
      dy: (json['dy'] as num?)?.toDouble() ?? -28,
      visualState:
          $enumDecodeNullable(_$NodeVisualStateEnumMap, json['visualState']) ??
          NodeVisualState.active,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$PointerBadgeToJson(_PointerBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'targetNodeId': instance.targetNodeId,
      'orbit': instance.orbit,
      'dx': instance.dx,
      'dy': instance.dy,
      'visualState': _$NodeVisualStateEnumMap[instance.visualState]!,
      'opacity': instance.opacity,
    };

_AuxTableSnapshot _$AuxTableSnapshotFromJson(Map<String, dynamic> json) =>
    _AuxTableSnapshot(
      id: json['id'] as String,
      title: json['title'] as String,
      columns: (json['columns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rows: (json['rows'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      highlightedRows:
          (json['highlightedRows'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$AuxTableSnapshotToJson(_AuxTableSnapshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'columns': instance.columns,
      'rows': instance.rows,
      'highlightedRows': instance.highlightedRows.toList(),
    };

_StackActivationRecord _$StackActivationRecordFromJson(
  Map<String, dynamic> json,
) => _StackActivationRecord(
  id: json['id'] as String,
  functionName: json['functionName'] as String,
  arguments:
      (json['arguments'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  locals:
      (json['locals'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  returnLocation: json['returnLocation'] as String,
  parentCallId: json['parentCallId'] as String?,
);

Map<String, dynamic> _$StackActivationRecordToJson(
  _StackActivationRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'functionName': instance.functionName,
  'arguments': instance.arguments,
  'locals': instance.locals,
  'returnLocation': instance.returnLocation,
  'parentCallId': instance.parentCallId,
};

_SceneZoneOverlay _$SceneZoneOverlayFromJson(Map<String, dynamic> json) =>
    _SceneZoneOverlay(
      id: json['id'] as String,
      label: json['label'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      pattern:
          $enumDecodeNullable(_$ZonePatternEnumMap, json['pattern']) ??
          ZonePattern.solid,
      visualState:
          $enumDecodeNullable(_$NodeVisualStateEnumMap, json['visualState']) ??
          NodeVisualState.normal,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$SceneZoneOverlayToJson(_SceneZoneOverlay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'pattern': _$ZonePatternEnumMap[instance.pattern]!,
      'visualState': _$NodeVisualStateEnumMap[instance.visualState]!,
      'opacity': instance.opacity,
    };

const _$ZonePatternEnumMap = {
  ZonePattern.solid: 'solid',
  ZonePattern.dashed: 'dashed',
  ZonePattern.hatched: 'hatched',
};

_ComplexityMetrics _$ComplexityMetricsFromJson(Map<String, dynamic> json) =>
    _ComplexityMetrics(
      comparisons: (json['comparisons'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      reads: (json['reads'] as num?)?.toInt() ?? 0,
      writes: (json['writes'] as num?)?.toInt() ?? 0,
      allocations: (json['allocations'] as num?)?.toInt() ?? 0,
      auxiliarySpace: (json['auxiliarySpace'] as num?)?.toInt() ?? 0,
      peakAuxiliarySpace: (json['peakAuxiliarySpace'] as num?)?.toInt() ?? 0,
      callDepth: (json['callDepth'] as num?)?.toInt() ?? 0,
      maxCallDepth: (json['maxCallDepth'] as num?)?.toInt() ?? 0,
      statementCounts:
          (json['statementCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ComplexityMetricsToJson(_ComplexityMetrics instance) =>
    <String, dynamic>{
      'comparisons': instance.comparisons,
      'moves': instance.moves,
      'reads': instance.reads,
      'writes': instance.writes,
      'allocations': instance.allocations,
      'auxiliarySpace': instance.auxiliarySpace,
      'peakAuxiliarySpace': instance.peakAuxiliarySpace,
      'callDepth': instance.callDepth,
      'maxCallDepth': instance.maxCallDepth,
      'statementCounts': instance.statementCounts,
    };
