import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enum/ds_enums.dart';
import '../models/playback_model.dart';
import '../models/trace_model.dart';
import '../engine/vm/trace_snapshot.dart';
import '../engine/vm/trace_validation.dart';

final playbackProvider =
    NotifierProvider.autoDispose<PlaybackController, PlaybackState>(
      PlaybackController.new,
    );

/// The view supplies elapsed time; no timers or irreversible algorithm actions.
class PlaybackController extends Notifier<PlaybackState> {
  static const frameDuration = Duration(milliseconds: 700);
  @override
  PlaybackState build() => const PlaybackState();

  void load(TraceTimeline timeline) {
    validateTimeline(timeline);
    state = PlaybackState(
      timeline: freezeTimeline(timeline),
      speed: state.speed,
      language: state.language,
    );
  }

  void clear() => state = const PlaybackState();
  double get _end => (state.timeline!.frames.length - 1).toDouble();
  void setSpeed(double speed) {
    if (!speed.isFinite || speed < .25 || speed > 4) {
      throw ArgumentError.value(speed, 'speed', 'Expected 0.25..4');
    }
    state = state.copyWith(speed: speed);
  }

  void setLanguage(CodeLang language) =>
      state = state.copyWith(language: language);
  void setDirection(PlaybackDirection direction) =>
      state = state.copyWith(direction: direction);
  void toggleBreakpoint(CodeLang language, int line) {
    final lines = state.timeline?.codeLines[language];
    if (lines == null || line < 1 || line > lines.length) {
      throw ArgumentError('Breakpoint outside code');
    }
    final points = Set<CodeBreakpoint>.of(state.breakpoints);
    final point = CodeBreakpoint(language: language, line: line);
    if (!points.remove(point)) points.add(point);
    state = state.copyWith(breakpoints: Set.unmodifiable(points));
  }

  void play({PlaybackDirection? direction}) {
    if (state.timeline == null) return;
    final nextDirection = direction ?? state.direction;
    final atEnd = nextDirection == PlaybackDirection.forward
        ? state.position >= _end
        : state.position <= 0;
    state = state.copyWith(
      direction: nextDirection,
      isPlaying: !atEnd,
      pauseReason: atEnd ? PauseReason.boundary : PauseReason.none,
      hitBreakpoint: null,
    );
  }

  void pause() => state = state.copyWith(
    isPlaying: false,
    pauseReason: PauseReason.user,
    hitBreakpoint: null,
  );
  void toggle() => state.isPlaying ? pause() : play();
  void seek(double position) {
    if (!position.isFinite) throw ArgumentError.value(position, 'position');
    if (state.timeline == null) return;
    _position(
      position.clamp(0.0, _end),
      playing: false,
      reason: PauseReason.user,
    );
  }

  void first() => seek(0);
  void last() {
    if (state.timeline != null) seek(_end);
  }

  void stepInto() => seek(state.frameIndex + 1.0);
  void stepBack() => seek(
    state.subProgress > 0
        ? state.frameIndex.toDouble()
        : state.frameIndex - 1.0,
  );
  void nextMilestone() {
    final frames = state.timeline?.frames;
    if (frames == null) return;
    for (var i = state.frameIndex + 1; i < frames.length; i++) {
      if (frames[i].isKeyMilestone) {
        seek(i.toDouble());
        return;
      }
    }
    last();
  }

  /// Inspect every crossed boundary, even after a dropped/very long render frame.
  void advance(Duration elapsed) {
    if (elapsed.isNegative) throw ArgumentError.value(elapsed, 'elapsed');
    if (!state.isPlaying ||
        elapsed == Duration.zero ||
        state.timeline == null) {
      return;
    }
    final forward = state.direction == PlaybackDirection.forward;
    final delta =
        elapsed.inMicroseconds / frameDuration.inMicroseconds * state.speed;
    final target = (state.position + (forward ? delta : -delta)).clamp(
      0.0,
      _end,
    );
    var index = forward
        ? state.position.floor() + 1
        : state.position.ceil() - 1;
    while (index >= 0 &&
        index <= _end &&
        (forward ? index <= target : index >= target)) {
      final frame = state.timeline!.frames[index];
      CodeBreakpoint? hit;
      for (final point in state.breakpoints) {
        if (frame.activeLines[point.language]?.contains(point.line) ?? false) {
          hit = point;
          break;
        }
      }
      if (frame.isErrorState || hit != null) {
        _position(
          index.toDouble(),
          playing: false,
          reason: frame.isErrorState
              ? PauseReason.error
              : PauseReason.breakpoint,
          hit: hit,
        );
        return;
      }
      index += forward ? 1 : -1;
    }
    final boundary = forward ? target == _end : target == 0;
    _position(
      target,
      playing: !boundary,
      reason: boundary ? PauseReason.boundary : PauseReason.none,
    );
  }

  void _position(
    double value, {
    required bool playing,
    required PauseReason reason,
    CodeBreakpoint? hit,
  }) {
    final index = value.floor();
    state = state.copyWith(
      frameIndex: index,
      subProgress: value - index,
      isPlaying: playing,
      pauseReason: reason,
      hitBreakpoint: hit,
    );
  }
}
