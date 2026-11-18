// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodeBreakpoint _$CodeBreakpointFromJson(Map<String, dynamic> json) =>
    _CodeBreakpoint(
      language: $enumDecode(_$CodeLangEnumMap, json['language']),
      line: (json['line'] as num).toInt(),
    );

Map<String, dynamic> _$CodeBreakpointToJson(_CodeBreakpoint instance) =>
    <String, dynamic>{
      'language': _$CodeLangEnumMap[instance.language]!,
      'line': instance.line,
    };

const _$CodeLangEnumMap = {
  CodeLang.cLike: 'cLike',
  CodeLang.c99: 'c99',
  CodeLang.dart: 'dart',
};

_PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) =>
    _PlaybackState(
      timeline: json['timeline'] == null
          ? null
          : TraceTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
      frameIndex: (json['frameIndex'] as num?)?.toInt() ?? 0,
      subProgress: (json['subProgress'] as num?)?.toDouble() ?? 0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1,
      isPlaying: json['isPlaying'] as bool? ?? false,
      direction:
          $enumDecodeNullable(_$PlaybackDirectionEnumMap, json['direction']) ??
          PlaybackDirection.forward,
      breakpoints:
          (json['breakpoints'] as List<dynamic>?)
              ?.map((e) => CodeBreakpoint.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          const {},
      language:
          $enumDecodeNullable(_$CodeLangEnumMap, json['language']) ??
          CodeLang.cLike,
      pauseReason:
          $enumDecodeNullable(_$PauseReasonEnumMap, json['pauseReason']) ??
          PauseReason.none,
      hitBreakpoint: json['hitBreakpoint'] == null
          ? null
          : CodeBreakpoint.fromJson(
              json['hitBreakpoint'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PlaybackStateToJson(_PlaybackState instance) =>
    <String, dynamic>{
      'timeline': instance.timeline,
      'frameIndex': instance.frameIndex,
      'subProgress': instance.subProgress,
      'speed': instance.speed,
      'isPlaying': instance.isPlaying,
      'direction': _$PlaybackDirectionEnumMap[instance.direction]!,
      'breakpoints': instance.breakpoints.toList(),
      'language': _$CodeLangEnumMap[instance.language]!,
      'pauseReason': _$PauseReasonEnumMap[instance.pauseReason]!,
      'hitBreakpoint': instance.hitBreakpoint,
    };

const _$PlaybackDirectionEnumMap = {
  PlaybackDirection.forward: 'forward',
  PlaybackDirection.reverse: 'reverse',
};

const _$PauseReasonEnumMap = {
  PauseReason.none: 'none',
  PauseReason.user: 'user',
  PauseReason.breakpoint: 'breakpoint',
  PauseReason.boundary: 'boundary',
  PauseReason.error: 'error',
};
