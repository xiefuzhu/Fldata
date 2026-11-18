import 'dart:math' as math;
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'trace_snapshot.dart';
import 'memory_leaks.dart';
import 'trace_validation.dart';

/// Recording is synchronous and side-effect free outside this builder.
class TraceBuilder {
  TraceBuilder({
    required this.moduleId,
    required this.inputSummary,
    this.trackLinkedOwnership = false,
    required Map<CodeLang, List<String>> codeLines,
  }) : codeLines = Map.unmodifiable(
         codeLines.map(
           (lang, lines) => MapEntry(lang, List<String>.unmodifiable(lines)),
         ),
       );
  final String moduleId, inputSummary;
  final bool trackLinkedOwnership;
  final Map<CodeLang, List<String>> codeLines;
  final _frames = <TraceFrame>[];
  var _scene = const SceneSnapshot();
  var _stack = <StackActivationRecord>[];
  var _metrics = const ComplexityMetrics();

  TraceBuilder step({
    required String title,
    required String explain,
    List<int> cLikeLines = const [],
    List<int> c99Lines = const [],
    List<int> dartLines = const [],
    Map<String, String> vars = const {},
    SceneSnapshot? scene,
    List<StackActivationRecord>? callStack,
    int deltaCompare = 0,
    int deltaMove = 0,
    int deltaRead = 0,
    int deltaWrite = 0,
    int deltaAllocate = 0,
    int deltaSpace = 0,
    Map<String, int> statementCounts = const {},
    bool milestone = false,
    bool error = false,
  }) {
    if ([
          deltaCompare,
          deltaMove,
          deltaRead,
          deltaWrite,
          deltaAllocate,
          ...statementCounts.values,
        ].any((value) => value < 0) ||
        _metrics.auxiliarySpace + deltaSpace < 0) {
      throw ArgumentError('Invalid complexity delta');
    }
    final counts = Map<String, int>.of(_metrics.statementCounts);
    for (final entry in statementCounts.entries) {
      counts.update(
        entry.key,
        (n) => n + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    final stack = callStack ?? _stack;
    final space = _metrics.auxiliarySpace + deltaSpace;
    final metrics = _metrics.copyWith(
      comparisons: _metrics.comparisons + deltaCompare,
      moves: _metrics.moves + deltaMove,
      reads: _metrics.reads + deltaRead,
      writes: _metrics.writes + deltaWrite,
      allocations: _metrics.allocations + deltaAllocate,
      auxiliarySpace: space,
      peakAuxiliarySpace: math.max(space, _metrics.peakAuxiliarySpace),
      callDepth: stack.length,
      maxCallDepth: math.max(stack.length, _metrics.maxCallDepth),
      statementCounts: Map.unmodifiable(counts),
    );
    final frame = freezeFrame(
      TraceFrame(
        stepIndex: _frames.length,
        phaseTitle: title,
        explanation: explain,
        activeLines: {
          CodeLang.cLike: cLikeLines,
          CodeLang.c99: c99Lines,
          CodeLang.dart: dartLines,
        },
        inlineVars: vars,
        scene: trackLinkedOwnership
            ? markMemoryLeaks(scene ?? _scene)
            : (scene ?? _scene),
        callStack: stack,
        metrics: metrics,
        isKeyMilestone: milestone,
        isErrorState: error,
      ),
    );
    validateScene(frame.scene);
    for (final entry in frame.activeLines.entries) {
      if (entry.value.any(
        (line) => line < 1 || line > (codeLines[entry.key]?.length ?? 0),
      )) {
        throw ArgumentError('Active line outside code');
      }
    }
    _frames.add(frame);
    _scene = frame.scene;
    _stack = frame.callStack;
    _metrics = metrics;
    return this;
  }

  TraceTimeline build() {
    final result = TraceTimeline(
      moduleId: moduleId,
      inputSummary: inputSummary,
      frames: List.unmodifiable(_frames),
      codeLines: codeLines,
    );
    validateTimeline(result);
    return result;
  }
}
