import 'package:freezed_annotation/freezed_annotation.dart';
import '../enum/ds_enums.dart';
import 'trace_model.dart';
part 'playback_model.freezed.dart';
part 'playback_model.g.dart';

enum PlaybackDirection { forward, reverse }

enum PauseReason { none, user, breakpoint, boundary, error }

@freezed
abstract class CodeBreakpoint with _$CodeBreakpoint {
  const factory CodeBreakpoint({
    required CodeLang language,
    required int line,
  }) = _CodeBreakpoint;
  factory CodeBreakpoint.fromJson(Map<String, dynamic> json) =>
      _$CodeBreakpointFromJson(json);
}

@freezed
abstract class PlaybackState with _$PlaybackState {
  const PlaybackState._();
  const factory PlaybackState({
    TraceTimeline? timeline,
    @Default(0) int frameIndex,
    @Default(0) double subProgress,
    @Default(1) double speed,
    @Default(false) bool isPlaying,
    @Default(PlaybackDirection.forward) PlaybackDirection direction,
    @Default({}) Set<CodeBreakpoint> breakpoints,
    @Default(CodeLang.cLike) CodeLang language,
    @Default(PauseReason.none) PauseReason pauseReason,
    CodeBreakpoint? hitBreakpoint,
  }) = _PlaybackState;
  factory PlaybackState.fromJson(Map<String, dynamic> json) =>
      _$PlaybackStateFromJson(json);
  double get position => frameIndex + subProgress;
  TraceFrame? get currentFrame =>
      timeline == null ? null : timeline!.frames[frameIndex];
}
