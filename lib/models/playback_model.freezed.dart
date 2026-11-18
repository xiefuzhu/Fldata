// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodeBreakpoint {

 CodeLang get language; int get line;
/// Create a copy of CodeBreakpoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeBreakpointCopyWith<CodeBreakpoint> get copyWith => _$CodeBreakpointCopyWithImpl<CodeBreakpoint>(this as CodeBreakpoint, _$identity);

  /// Serializes this CodeBreakpoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CodeBreakpoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeBreakpoint&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.line, _this.line) || other.line == _this.line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CodeBreakpoint;
  return Object.hash(runtimeType,_this.language,_this.line);
}

@override
String toString() {
  final _this = this as CodeBreakpoint;
  return 'CodeBreakpoint(language: ${_this.language}, line: ${_this.line})';
}


}

/// @nodoc
abstract mixin class $CodeBreakpointCopyWith<$Res>  {
  factory $CodeBreakpointCopyWith(CodeBreakpoint value, $Res Function(CodeBreakpoint) _then) = _$CodeBreakpointCopyWithImpl;
@useResult
$Res call({
 CodeLang language, int line
});




}
/// @nodoc
class _$CodeBreakpointCopyWithImpl<$Res>
    implements $CodeBreakpointCopyWith<$Res> {
  _$CodeBreakpointCopyWithImpl(this._self, this._then);

  final CodeBreakpoint _self;
  final $Res Function(CodeBreakpoint) _then;

/// Create a copy of CodeBreakpoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? line = null,}) {
  return _then(CodeBreakpoint(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CodeLang,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CodeBreakpoint].
extension CodeBreakpointPatterns on CodeBreakpoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodeBreakpoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodeBreakpoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodeBreakpoint value)  $default,){
final _that = this;
switch (_that) {
case _CodeBreakpoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodeBreakpoint value)?  $default,){
final _that = this;
switch (_that) {
case _CodeBreakpoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CodeLang language,  int line)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodeBreakpoint() when $default != null:
return $default(_that.language,_that.line);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CodeLang language,  int line)  $default,) {final _that = this;
switch (_that) {
case _CodeBreakpoint():
return $default(_that.language,_that.line);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CodeLang language,  int line)?  $default,) {final _that = this;
switch (_that) {
case _CodeBreakpoint() when $default != null:
return $default(_that.language,_that.line);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodeBreakpoint implements CodeBreakpoint {
  const _CodeBreakpoint({required this.language, required this.line});
  factory _CodeBreakpoint.fromJson(Map<String, dynamic> json) => _$CodeBreakpointFromJson(json);

@override final  CodeLang language;
@override final  int line;

/// Create a copy of CodeBreakpoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeBreakpointCopyWith<_CodeBreakpoint> get copyWith => __$CodeBreakpointCopyWithImpl<_CodeBreakpoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodeBreakpointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeBreakpoint&&(identical(other.language, language) || other.language == language)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,language,line);
}

@override
String toString() {
    return 'CodeBreakpoint(language: $language, line: $line)';
}


}

/// @nodoc
abstract mixin class _$CodeBreakpointCopyWith<$Res> implements $CodeBreakpointCopyWith<$Res> {
  factory _$CodeBreakpointCopyWith(_CodeBreakpoint value, $Res Function(_CodeBreakpoint) _then) = __$CodeBreakpointCopyWithImpl;
@override @useResult
$Res call({
 CodeLang language, int line
});




}
/// @nodoc
class __$CodeBreakpointCopyWithImpl<$Res>
    implements _$CodeBreakpointCopyWith<$Res> {
  __$CodeBreakpointCopyWithImpl(this._self, this._then);

  final _CodeBreakpoint _self;
  final $Res Function(_CodeBreakpoint) _then;

/// Create a copy of CodeBreakpoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? line = null,}) {
  return _then(_CodeBreakpoint(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CodeLang,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PlaybackState {

 TraceTimeline? get timeline; int get frameIndex; double get subProgress; double get speed; bool get isPlaying; PlaybackDirection get direction; Set<CodeBreakpoint> get breakpoints; CodeLang get language; PauseReason get pauseReason; CodeBreakpoint? get hitBreakpoint;
/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackStateCopyWith<PlaybackState> get copyWith => _$PlaybackStateCopyWithImpl<PlaybackState>(this as PlaybackState, _$identity);

  /// Serializes this PlaybackState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaybackState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackState&&(identical(other.timeline, _this.timeline) || other.timeline == _this.timeline)&&(identical(other.frameIndex, _this.frameIndex) || other.frameIndex == _this.frameIndex)&&(identical(other.subProgress, _this.subProgress) || other.subProgress == _this.subProgress)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&const DeepCollectionEquality().equals(other.breakpoints, _this.breakpoints)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.pauseReason, _this.pauseReason) || other.pauseReason == _this.pauseReason)&&(identical(other.hitBreakpoint, _this.hitBreakpoint) || other.hitBreakpoint == _this.hitBreakpoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaybackState;
  return Object.hash(runtimeType,_this.timeline,_this.frameIndex,_this.subProgress,_this.speed,_this.isPlaying,_this.direction,const DeepCollectionEquality().hash(_this.breakpoints),_this.language,_this.pauseReason,_this.hitBreakpoint);
}

@override
String toString() {
  final _this = this as PlaybackState;
  return 'PlaybackState(timeline: ${_this.timeline}, frameIndex: ${_this.frameIndex}, subProgress: ${_this.subProgress}, speed: ${_this.speed}, isPlaying: ${_this.isPlaying}, direction: ${_this.direction}, breakpoints: ${_this.breakpoints}, language: ${_this.language}, pauseReason: ${_this.pauseReason}, hitBreakpoint: ${_this.hitBreakpoint})';
}


}

/// @nodoc
abstract mixin class $PlaybackStateCopyWith<$Res>  {
  factory $PlaybackStateCopyWith(PlaybackState value, $Res Function(PlaybackState) _then) = _$PlaybackStateCopyWithImpl;
@useResult
$Res call({
 TraceTimeline? timeline, int frameIndex, double subProgress, double speed, bool isPlaying, PlaybackDirection direction, Set<CodeBreakpoint> breakpoints, CodeLang language, PauseReason pauseReason, CodeBreakpoint? hitBreakpoint
});


$TraceTimelineCopyWith<$Res>? get timeline;$CodeBreakpointCopyWith<$Res>? get hitBreakpoint;

}
/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._self, this._then);

  final PlaybackState _self;
  final $Res Function(PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeline = freezed,Object? frameIndex = null,Object? subProgress = null,Object? speed = null,Object? isPlaying = null,Object? direction = null,Object? breakpoints = null,Object? language = null,Object? pauseReason = null,Object? hitBreakpoint = freezed,}) {
  return _then(PlaybackState(
timeline: freezed == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as TraceTimeline?,frameIndex: null == frameIndex ? _self.frameIndex : frameIndex // ignore: cast_nullable_to_non_nullable
as int,subProgress: null == subProgress ? _self.subProgress : subProgress // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as PlaybackDirection,breakpoints: null == breakpoints ? _self.breakpoints : breakpoints // ignore: cast_nullable_to_non_nullable
as Set<CodeBreakpoint>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CodeLang,pauseReason: null == pauseReason ? _self.pauseReason : pauseReason // ignore: cast_nullable_to_non_nullable
as PauseReason,hitBreakpoint: freezed == hitBreakpoint ? _self.hitBreakpoint : hitBreakpoint // ignore: cast_nullable_to_non_nullable
as CodeBreakpoint?,
  ));
}
/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceTimelineCopyWith<$Res>? get timeline {
    if (_self.timeline == null) {
    return null;
  }

  return $TraceTimelineCopyWith<$Res>(_self.timeline!, (value) {
    return _then(_self.copyWith(timeline: value));
  });
}/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CodeBreakpointCopyWith<$Res>? get hitBreakpoint {
    if (_self.hitBreakpoint == null) {
    return null;
  }

  return $CodeBreakpointCopyWith<$Res>(_self.hitBreakpoint!, (value) {
    return _then(_self.copyWith(hitBreakpoint: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaybackState].
extension PlaybackStatePatterns on PlaybackState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackState value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TraceTimeline? timeline,  int frameIndex,  double subProgress,  double speed,  bool isPlaying,  PlaybackDirection direction,  Set<CodeBreakpoint> breakpoints,  CodeLang language,  PauseReason pauseReason,  CodeBreakpoint? hitBreakpoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.timeline,_that.frameIndex,_that.subProgress,_that.speed,_that.isPlaying,_that.direction,_that.breakpoints,_that.language,_that.pauseReason,_that.hitBreakpoint);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TraceTimeline? timeline,  int frameIndex,  double subProgress,  double speed,  bool isPlaying,  PlaybackDirection direction,  Set<CodeBreakpoint> breakpoints,  CodeLang language,  PauseReason pauseReason,  CodeBreakpoint? hitBreakpoint)  $default,) {final _that = this;
switch (_that) {
case _PlaybackState():
return $default(_that.timeline,_that.frameIndex,_that.subProgress,_that.speed,_that.isPlaying,_that.direction,_that.breakpoints,_that.language,_that.pauseReason,_that.hitBreakpoint);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TraceTimeline? timeline,  int frameIndex,  double subProgress,  double speed,  bool isPlaying,  PlaybackDirection direction,  Set<CodeBreakpoint> breakpoints,  CodeLang language,  PauseReason pauseReason,  CodeBreakpoint? hitBreakpoint)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.timeline,_that.frameIndex,_that.subProgress,_that.speed,_that.isPlaying,_that.direction,_that.breakpoints,_that.language,_that.pauseReason,_that.hitBreakpoint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackState extends PlaybackState {
  const _PlaybackState({this.timeline, this.frameIndex = 0, this.subProgress = 0, this.speed = 1, this.isPlaying = false, this.direction = PlaybackDirection.forward,  Set<CodeBreakpoint> breakpoints = const {}, this.language = CodeLang.cLike, this.pauseReason = PauseReason.none, this.hitBreakpoint}): _breakpoints = breakpoints,super._();
  factory _PlaybackState.fromJson(Map<String, dynamic> json) => _$PlaybackStateFromJson(json);

@override final  TraceTimeline? timeline;
@override@JsonKey() final  int frameIndex;
@override@JsonKey() final  double subProgress;
@override@JsonKey() final  double speed;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  PlaybackDirection direction;
 final  Set<CodeBreakpoint> _breakpoints;
@override@JsonKey() Set<CodeBreakpoint> get breakpoints {
  if (_breakpoints is EqualUnmodifiableSetView) return _breakpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_breakpoints);
}

@override@JsonKey() final  CodeLang language;
@override@JsonKey() final  PauseReason pauseReason;
@override final  CodeBreakpoint? hitBreakpoint;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackStateCopyWith<_PlaybackState> get copyWith => __$PlaybackStateCopyWithImpl<_PlaybackState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackState&&(identical(other.timeline, timeline) || other.timeline == timeline)&&(identical(other.frameIndex, frameIndex) || other.frameIndex == frameIndex)&&(identical(other.subProgress, subProgress) || other.subProgress == subProgress)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other.breakpoints, _breakpoints)&&(identical(other.language, language) || other.language == language)&&(identical(other.pauseReason, pauseReason) || other.pauseReason == pauseReason)&&(identical(other.hitBreakpoint, hitBreakpoint) || other.hitBreakpoint == hitBreakpoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,timeline,frameIndex,subProgress,speed,isPlaying,direction,const DeepCollectionEquality().hash(_breakpoints),language,pauseReason,hitBreakpoint);
}

@override
String toString() {
    return 'PlaybackState(timeline: $timeline, frameIndex: $frameIndex, subProgress: $subProgress, speed: $speed, isPlaying: $isPlaying, direction: $direction, breakpoints: $breakpoints, language: $language, pauseReason: $pauseReason, hitBreakpoint: $hitBreakpoint)';
}


}

/// @nodoc
abstract mixin class _$PlaybackStateCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory _$PlaybackStateCopyWith(_PlaybackState value, $Res Function(_PlaybackState) _then) = __$PlaybackStateCopyWithImpl;
@override @useResult
$Res call({
 TraceTimeline? timeline, int frameIndex, double subProgress, double speed, bool isPlaying, PlaybackDirection direction, Set<CodeBreakpoint> breakpoints, CodeLang language, PauseReason pauseReason, CodeBreakpoint? hitBreakpoint
});


@override $TraceTimelineCopyWith<$Res>? get timeline;@override $CodeBreakpointCopyWith<$Res>? get hitBreakpoint;

}
/// @nodoc
class __$PlaybackStateCopyWithImpl<$Res>
    implements _$PlaybackStateCopyWith<$Res> {
  __$PlaybackStateCopyWithImpl(this._self, this._then);

  final _PlaybackState _self;
  final $Res Function(_PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeline = freezed,Object? frameIndex = null,Object? subProgress = null,Object? speed = null,Object? isPlaying = null,Object? direction = null,Object? breakpoints = null,Object? language = null,Object? pauseReason = null,Object? hitBreakpoint = freezed,}) {
  return _then(_PlaybackState(
timeline: freezed == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as TraceTimeline?,frameIndex: null == frameIndex ? _self.frameIndex : frameIndex // ignore: cast_nullable_to_non_nullable
as int,subProgress: null == subProgress ? _self.subProgress : subProgress // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as PlaybackDirection,breakpoints: null == breakpoints ? _self._breakpoints : breakpoints // ignore: cast_nullable_to_non_nullable
as Set<CodeBreakpoint>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CodeLang,pauseReason: null == pauseReason ? _self.pauseReason : pauseReason // ignore: cast_nullable_to_non_nullable
as PauseReason,hitBreakpoint: freezed == hitBreakpoint ? _self.hitBreakpoint : hitBreakpoint // ignore: cast_nullable_to_non_nullable
as CodeBreakpoint?,
  ));
}

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TraceTimelineCopyWith<$Res>? get timeline {
    if (_self.timeline == null) {
    return null;
  }

  return $TraceTimelineCopyWith<$Res>(_self.timeline!, (value) {
    return _then(_self.copyWith(timeline: value));
  });
}/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CodeBreakpointCopyWith<$Res>? get hitBreakpoint {
    if (_self.hitBreakpoint == null) {
    return null;
  }

  return $CodeBreakpointCopyWith<$Res>(_self.hitBreakpoint!, (value) {
    return _then(_self.copyWith(hitBreakpoint: value));
  });
}
}

// dart format on
