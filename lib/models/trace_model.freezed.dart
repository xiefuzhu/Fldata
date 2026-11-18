// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trace_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vec2 {

 double get x; double get y;
/// Create a copy of Vec2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Vec2CopyWith<Vec2> get copyWith => _$Vec2CopyWithImpl<Vec2>(this as Vec2, _$identity);

  /// Serializes this Vec2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Vec2;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vec2&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Vec2;
  return Object.hash(runtimeType,_this.x,_this.y);
}

@override
String toString() {
  final _this = this as Vec2;
  return 'Vec2(x: ${_this.x}, y: ${_this.y})';
}


}

/// @nodoc
abstract mixin class $Vec2CopyWith<$Res>  {
  factory $Vec2CopyWith(Vec2 value, $Res Function(Vec2) _then) = _$Vec2CopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$Vec2CopyWithImpl<$Res>
    implements $Vec2CopyWith<$Res> {
  _$Vec2CopyWithImpl(this._self, this._then);

  final Vec2 _self;
  final $Res Function(Vec2) _then;

/// Create a copy of Vec2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(Vec2(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Vec2].
extension Vec2Patterns on Vec2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vec2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vec2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vec2 value)  $default,){
final _that = this;
switch (_that) {
case _Vec2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vec2 value)?  $default,){
final _that = this;
switch (_that) {
case _Vec2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vec2() when $default != null:
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _Vec2():
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _Vec2() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vec2 implements Vec2 {
  const _Vec2({required this.x, required this.y});
  factory _Vec2.fromJson(Map<String, dynamic> json) => _$Vec2FromJson(json);

@override final  double x;
@override final  double y;

/// Create a copy of Vec2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Vec2CopyWith<_Vec2> get copyWith => __$Vec2CopyWithImpl<_Vec2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Vec2ToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vec2&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,x,y);
}

@override
String toString() {
    return 'Vec2(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$Vec2CopyWith<$Res> implements $Vec2CopyWith<$Res> {
  factory _$Vec2CopyWith(_Vec2 value, $Res Function(_Vec2) _then) = __$Vec2CopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$Vec2CopyWithImpl<$Res>
    implements _$Vec2CopyWith<$Res> {
  __$Vec2CopyWithImpl(this._self, this._then);

  final _Vec2 _self;
  final $Res Function(_Vec2) _then;

/// Create a copy of Vec2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_Vec2(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TraceTimeline {

 String get moduleId; String get inputSummary; List<TraceFrame> get frames; Map<CodeLang, List<String>> get codeLines;
/// Create a copy of TraceTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceTimelineCopyWith<TraceTimeline> get copyWith => _$TraceTimelineCopyWithImpl<TraceTimeline>(this as TraceTimeline, _$identity);

  /// Serializes this TraceTimeline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceTimeline;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceTimeline&&(identical(other.moduleId, _this.moduleId) || other.moduleId == _this.moduleId)&&(identical(other.inputSummary, _this.inputSummary) || other.inputSummary == _this.inputSummary)&&const DeepCollectionEquality().equals(other.frames, _this.frames)&&const DeepCollectionEquality().equals(other.codeLines, _this.codeLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceTimeline;
  return Object.hash(runtimeType,_this.moduleId,_this.inputSummary,const DeepCollectionEquality().hash(_this.frames),const DeepCollectionEquality().hash(_this.codeLines));
}

@override
String toString() {
  final _this = this as TraceTimeline;
  return 'TraceTimeline(moduleId: ${_this.moduleId}, inputSummary: ${_this.inputSummary}, frames: ${_this.frames}, codeLines: ${_this.codeLines})';
}


}

/// @nodoc
abstract mixin class $TraceTimelineCopyWith<$Res>  {
  factory $TraceTimelineCopyWith(TraceTimeline value, $Res Function(TraceTimeline) _then) = _$TraceTimelineCopyWithImpl;
@useResult
$Res call({
 String moduleId, String inputSummary, List<TraceFrame> frames, Map<CodeLang, List<String>> codeLines
});




}
/// @nodoc
class _$TraceTimelineCopyWithImpl<$Res>
    implements $TraceTimelineCopyWith<$Res> {
  _$TraceTimelineCopyWithImpl(this._self, this._then);

  final TraceTimeline _self;
  final $Res Function(TraceTimeline) _then;

/// Create a copy of TraceTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? moduleId = null,Object? inputSummary = null,Object? frames = null,Object? codeLines = null,}) {
  return _then(TraceTimeline(
moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,inputSummary: null == inputSummary ? _self.inputSummary : inputSummary // ignore: cast_nullable_to_non_nullable
as String,frames: null == frames ? _self.frames : frames // ignore: cast_nullable_to_non_nullable
as List<TraceFrame>,codeLines: null == codeLines ? _self.codeLines : codeLines // ignore: cast_nullable_to_non_nullable
as Map<CodeLang, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [TraceTimeline].
extension TraceTimelinePatterns on TraceTimeline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceTimeline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceTimeline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceTimeline value)  $default,){
final _that = this;
switch (_that) {
case _TraceTimeline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceTimeline value)?  $default,){
final _that = this;
switch (_that) {
case _TraceTimeline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String moduleId,  String inputSummary,  List<TraceFrame> frames,  Map<CodeLang, List<String>> codeLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceTimeline() when $default != null:
return $default(_that.moduleId,_that.inputSummary,_that.frames,_that.codeLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String moduleId,  String inputSummary,  List<TraceFrame> frames,  Map<CodeLang, List<String>> codeLines)  $default,) {final _that = this;
switch (_that) {
case _TraceTimeline():
return $default(_that.moduleId,_that.inputSummary,_that.frames,_that.codeLines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String moduleId,  String inputSummary,  List<TraceFrame> frames,  Map<CodeLang, List<String>> codeLines)?  $default,) {final _that = this;
switch (_that) {
case _TraceTimeline() when $default != null:
return $default(_that.moduleId,_that.inputSummary,_that.frames,_that.codeLines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceTimeline implements TraceTimeline {
  const _TraceTimeline({required this.moduleId, required this.inputSummary, required  List<TraceFrame> frames, required  Map<CodeLang, List<String>> codeLines}): _frames = frames,_codeLines = codeLines;
  factory _TraceTimeline.fromJson(Map<String, dynamic> json) => _$TraceTimelineFromJson(json);

@override final  String moduleId;
@override final  String inputSummary;
 final  List<TraceFrame> _frames;
@override List<TraceFrame> get frames {
  if (_frames is EqualUnmodifiableListView) return _frames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_frames);
}

 final  Map<CodeLang, List<String>> _codeLines;
@override Map<CodeLang, List<String>> get codeLines {
  if (_codeLines is EqualUnmodifiableMapView) return _codeLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_codeLines);
}


/// Create a copy of TraceTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceTimelineCopyWith<_TraceTimeline> get copyWith => __$TraceTimelineCopyWithImpl<_TraceTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceTimelineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceTimeline&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.inputSummary, inputSummary) || other.inputSummary == inputSummary)&&const DeepCollectionEquality().equals(other.frames, _frames)&&const DeepCollectionEquality().equals(other.codeLines, _codeLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,moduleId,inputSummary,const DeepCollectionEquality().hash(_frames),const DeepCollectionEquality().hash(_codeLines));
}

@override
String toString() {
    return 'TraceTimeline(moduleId: $moduleId, inputSummary: $inputSummary, frames: $frames, codeLines: $codeLines)';
}


}

/// @nodoc
abstract mixin class _$TraceTimelineCopyWith<$Res> implements $TraceTimelineCopyWith<$Res> {
  factory _$TraceTimelineCopyWith(_TraceTimeline value, $Res Function(_TraceTimeline) _then) = __$TraceTimelineCopyWithImpl;
@override @useResult
$Res call({
 String moduleId, String inputSummary, List<TraceFrame> frames, Map<CodeLang, List<String>> codeLines
});




}
/// @nodoc
class __$TraceTimelineCopyWithImpl<$Res>
    implements _$TraceTimelineCopyWith<$Res> {
  __$TraceTimelineCopyWithImpl(this._self, this._then);

  final _TraceTimeline _self;
  final $Res Function(_TraceTimeline) _then;

/// Create a copy of TraceTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? moduleId = null,Object? inputSummary = null,Object? frames = null,Object? codeLines = null,}) {
  return _then(_TraceTimeline(
moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,inputSummary: null == inputSummary ? _self.inputSummary : inputSummary // ignore: cast_nullable_to_non_nullable
as String,frames: null == frames ? _self._frames : frames // ignore: cast_nullable_to_non_nullable
as List<TraceFrame>,codeLines: null == codeLines ? _self._codeLines : codeLines // ignore: cast_nullable_to_non_nullable
as Map<CodeLang, List<String>>,
  ));
}


}


/// @nodoc
mixin _$TraceFrame {

 int get stepIndex; String get phaseTitle; String get explanation; Map<CodeLang, List<int>> get activeLines; Map<String, String> get inlineVars; SceneSnapshot get scene; List<StackActivationRecord> get callStack; ComplexityMetrics get metrics; bool get isKeyMilestone; bool get isErrorState;
/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraceFrameCopyWith<TraceFrame> get copyWith => _$TraceFrameCopyWithImpl<TraceFrame>(this as TraceFrame, _$identity);

  /// Serializes this TraceFrame to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TraceFrame;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraceFrame&&(identical(other.stepIndex, _this.stepIndex) || other.stepIndex == _this.stepIndex)&&(identical(other.phaseTitle, _this.phaseTitle) || other.phaseTitle == _this.phaseTitle)&&(identical(other.explanation, _this.explanation) || other.explanation == _this.explanation)&&const DeepCollectionEquality().equals(other.activeLines, _this.activeLines)&&const DeepCollectionEquality().equals(other.inlineVars, _this.inlineVars)&&(identical(other.scene, _this.scene) || other.scene == _this.scene)&&const DeepCollectionEquality().equals(other.callStack, _this.callStack)&&(identical(other.metrics, _this.metrics) || other.metrics == _this.metrics)&&(identical(other.isKeyMilestone, _this.isKeyMilestone) || other.isKeyMilestone == _this.isKeyMilestone)&&(identical(other.isErrorState, _this.isErrorState) || other.isErrorState == _this.isErrorState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TraceFrame;
  return Object.hash(runtimeType,_this.stepIndex,_this.phaseTitle,_this.explanation,const DeepCollectionEquality().hash(_this.activeLines),const DeepCollectionEquality().hash(_this.inlineVars),_this.scene,const DeepCollectionEquality().hash(_this.callStack),_this.metrics,_this.isKeyMilestone,_this.isErrorState);
}

@override
String toString() {
  final _this = this as TraceFrame;
  return 'TraceFrame(stepIndex: ${_this.stepIndex}, phaseTitle: ${_this.phaseTitle}, explanation: ${_this.explanation}, activeLines: ${_this.activeLines}, inlineVars: ${_this.inlineVars}, scene: ${_this.scene}, callStack: ${_this.callStack}, metrics: ${_this.metrics}, isKeyMilestone: ${_this.isKeyMilestone}, isErrorState: ${_this.isErrorState})';
}


}

/// @nodoc
abstract mixin class $TraceFrameCopyWith<$Res>  {
  factory $TraceFrameCopyWith(TraceFrame value, $Res Function(TraceFrame) _then) = _$TraceFrameCopyWithImpl;
@useResult
$Res call({
 int stepIndex, String phaseTitle, String explanation, Map<CodeLang, List<int>> activeLines, Map<String, String> inlineVars, SceneSnapshot scene, List<StackActivationRecord> callStack, ComplexityMetrics metrics, bool isKeyMilestone, bool isErrorState
});


$SceneSnapshotCopyWith<$Res> get scene;$ComplexityMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class _$TraceFrameCopyWithImpl<$Res>
    implements $TraceFrameCopyWith<$Res> {
  _$TraceFrameCopyWithImpl(this._self, this._then);

  final TraceFrame _self;
  final $Res Function(TraceFrame) _then;

/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepIndex = null,Object? phaseTitle = null,Object? explanation = null,Object? activeLines = null,Object? inlineVars = null,Object? scene = null,Object? callStack = null,Object? metrics = null,Object? isKeyMilestone = null,Object? isErrorState = null,}) {
  return _then(TraceFrame(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,phaseTitle: null == phaseTitle ? _self.phaseTitle : phaseTitle // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,activeLines: null == activeLines ? _self.activeLines : activeLines // ignore: cast_nullable_to_non_nullable
as Map<CodeLang, List<int>>,inlineVars: null == inlineVars ? _self.inlineVars : inlineVars // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scene: null == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as SceneSnapshot,callStack: null == callStack ? _self.callStack : callStack // ignore: cast_nullable_to_non_nullable
as List<StackActivationRecord>,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as ComplexityMetrics,isKeyMilestone: null == isKeyMilestone ? _self.isKeyMilestone : isKeyMilestone // ignore: cast_nullable_to_non_nullable
as bool,isErrorState: null == isErrorState ? _self.isErrorState : isErrorState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SceneSnapshotCopyWith<$Res> get scene {
  
  return $SceneSnapshotCopyWith<$Res>(_self.scene, (value) {
    return _then(_self.copyWith(scene: value));
  });
}/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplexityMetricsCopyWith<$Res> get metrics {
  
  return $ComplexityMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [TraceFrame].
extension TraceFramePatterns on TraceFrame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraceFrame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraceFrame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraceFrame value)  $default,){
final _that = this;
switch (_that) {
case _TraceFrame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraceFrame value)?  $default,){
final _that = this;
switch (_that) {
case _TraceFrame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stepIndex,  String phaseTitle,  String explanation,  Map<CodeLang, List<int>> activeLines,  Map<String, String> inlineVars,  SceneSnapshot scene,  List<StackActivationRecord> callStack,  ComplexityMetrics metrics,  bool isKeyMilestone,  bool isErrorState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraceFrame() when $default != null:
return $default(_that.stepIndex,_that.phaseTitle,_that.explanation,_that.activeLines,_that.inlineVars,_that.scene,_that.callStack,_that.metrics,_that.isKeyMilestone,_that.isErrorState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stepIndex,  String phaseTitle,  String explanation,  Map<CodeLang, List<int>> activeLines,  Map<String, String> inlineVars,  SceneSnapshot scene,  List<StackActivationRecord> callStack,  ComplexityMetrics metrics,  bool isKeyMilestone,  bool isErrorState)  $default,) {final _that = this;
switch (_that) {
case _TraceFrame():
return $default(_that.stepIndex,_that.phaseTitle,_that.explanation,_that.activeLines,_that.inlineVars,_that.scene,_that.callStack,_that.metrics,_that.isKeyMilestone,_that.isErrorState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stepIndex,  String phaseTitle,  String explanation,  Map<CodeLang, List<int>> activeLines,  Map<String, String> inlineVars,  SceneSnapshot scene,  List<StackActivationRecord> callStack,  ComplexityMetrics metrics,  bool isKeyMilestone,  bool isErrorState)?  $default,) {final _that = this;
switch (_that) {
case _TraceFrame() when $default != null:
return $default(_that.stepIndex,_that.phaseTitle,_that.explanation,_that.activeLines,_that.inlineVars,_that.scene,_that.callStack,_that.metrics,_that.isKeyMilestone,_that.isErrorState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TraceFrame implements TraceFrame {
  const _TraceFrame({required this.stepIndex, required this.phaseTitle, required this.explanation, required  Map<CodeLang, List<int>> activeLines,  Map<String, String> inlineVars = const {}, required this.scene,  List<StackActivationRecord> callStack = const [], this.metrics = const ComplexityMetrics(), this.isKeyMilestone = false, this.isErrorState = false}): _activeLines = activeLines,_inlineVars = inlineVars,_callStack = callStack;
  factory _TraceFrame.fromJson(Map<String, dynamic> json) => _$TraceFrameFromJson(json);

@override final  int stepIndex;
@override final  String phaseTitle;
@override final  String explanation;
 final  Map<CodeLang, List<int>> _activeLines;
@override Map<CodeLang, List<int>> get activeLines {
  if (_activeLines is EqualUnmodifiableMapView) return _activeLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_activeLines);
}

 final  Map<String, String> _inlineVars;
@override@JsonKey() Map<String, String> get inlineVars {
  if (_inlineVars is EqualUnmodifiableMapView) return _inlineVars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_inlineVars);
}

@override final  SceneSnapshot scene;
 final  List<StackActivationRecord> _callStack;
@override@JsonKey() List<StackActivationRecord> get callStack {
  if (_callStack is EqualUnmodifiableListView) return _callStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_callStack);
}

@override@JsonKey() final  ComplexityMetrics metrics;
@override@JsonKey() final  bool isKeyMilestone;
@override@JsonKey() final  bool isErrorState;

/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraceFrameCopyWith<_TraceFrame> get copyWith => __$TraceFrameCopyWithImpl<_TraceFrame>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraceFrameToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraceFrame&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.phaseTitle, phaseTitle) || other.phaseTitle == phaseTitle)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&const DeepCollectionEquality().equals(other.activeLines, _activeLines)&&const DeepCollectionEquality().equals(other.inlineVars, _inlineVars)&&(identical(other.scene, scene) || other.scene == scene)&&const DeepCollectionEquality().equals(other.callStack, _callStack)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.isKeyMilestone, isKeyMilestone) || other.isKeyMilestone == isKeyMilestone)&&(identical(other.isErrorState, isErrorState) || other.isErrorState == isErrorState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stepIndex,phaseTitle,explanation,const DeepCollectionEquality().hash(_activeLines),const DeepCollectionEquality().hash(_inlineVars),scene,const DeepCollectionEquality().hash(_callStack),metrics,isKeyMilestone,isErrorState);
}

@override
String toString() {
    return 'TraceFrame(stepIndex: $stepIndex, phaseTitle: $phaseTitle, explanation: $explanation, activeLines: $activeLines, inlineVars: $inlineVars, scene: $scene, callStack: $callStack, metrics: $metrics, isKeyMilestone: $isKeyMilestone, isErrorState: $isErrorState)';
}


}

/// @nodoc
abstract mixin class _$TraceFrameCopyWith<$Res> implements $TraceFrameCopyWith<$Res> {
  factory _$TraceFrameCopyWith(_TraceFrame value, $Res Function(_TraceFrame) _then) = __$TraceFrameCopyWithImpl;
@override @useResult
$Res call({
 int stepIndex, String phaseTitle, String explanation, Map<CodeLang, List<int>> activeLines, Map<String, String> inlineVars, SceneSnapshot scene, List<StackActivationRecord> callStack, ComplexityMetrics metrics, bool isKeyMilestone, bool isErrorState
});


@override $SceneSnapshotCopyWith<$Res> get scene;@override $ComplexityMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class __$TraceFrameCopyWithImpl<$Res>
    implements _$TraceFrameCopyWith<$Res> {
  __$TraceFrameCopyWithImpl(this._self, this._then);

  final _TraceFrame _self;
  final $Res Function(_TraceFrame) _then;

/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepIndex = null,Object? phaseTitle = null,Object? explanation = null,Object? activeLines = null,Object? inlineVars = null,Object? scene = null,Object? callStack = null,Object? metrics = null,Object? isKeyMilestone = null,Object? isErrorState = null,}) {
  return _then(_TraceFrame(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,phaseTitle: null == phaseTitle ? _self.phaseTitle : phaseTitle // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,activeLines: null == activeLines ? _self._activeLines : activeLines // ignore: cast_nullable_to_non_nullable
as Map<CodeLang, List<int>>,inlineVars: null == inlineVars ? _self._inlineVars : inlineVars // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scene: null == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as SceneSnapshot,callStack: null == callStack ? _self._callStack : callStack // ignore: cast_nullable_to_non_nullable
as List<StackActivationRecord>,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as ComplexityMetrics,isKeyMilestone: null == isKeyMilestone ? _self.isKeyMilestone : isKeyMilestone // ignore: cast_nullable_to_non_nullable
as bool,isErrorState: null == isErrorState ? _self.isErrorState : isErrorState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SceneSnapshotCopyWith<$Res> get scene {
  
  return $SceneSnapshotCopyWith<$Res>(_self.scene, (value) {
    return _then(_self.copyWith(scene: value));
  });
}/// Create a copy of TraceFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplexityMetricsCopyWith<$Res> get metrics {
  
  return $ComplexityMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// @nodoc
mixin _$SceneSnapshot {

 SceneLayoutMode get layoutMode; List<SceneNode> get nodes; List<SceneEdge> get edges; List<PointerBadge> get pointers; List<AuxTableSnapshot> get auxTables; List<SceneZoneOverlay> get zones;
/// Create a copy of SceneSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneSnapshotCopyWith<SceneSnapshot> get copyWith => _$SceneSnapshotCopyWithImpl<SceneSnapshot>(this as SceneSnapshot, _$identity);

  /// Serializes this SceneSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneSnapshot&&(identical(other.layoutMode, _this.layoutMode) || other.layoutMode == _this.layoutMode)&&const DeepCollectionEquality().equals(other.nodes, _this.nodes)&&const DeepCollectionEquality().equals(other.edges, _this.edges)&&const DeepCollectionEquality().equals(other.pointers, _this.pointers)&&const DeepCollectionEquality().equals(other.auxTables, _this.auxTables)&&const DeepCollectionEquality().equals(other.zones, _this.zones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneSnapshot;
  return Object.hash(runtimeType,_this.layoutMode,const DeepCollectionEquality().hash(_this.nodes),const DeepCollectionEquality().hash(_this.edges),const DeepCollectionEquality().hash(_this.pointers),const DeepCollectionEquality().hash(_this.auxTables),const DeepCollectionEquality().hash(_this.zones));
}

@override
String toString() {
  final _this = this as SceneSnapshot;
  return 'SceneSnapshot(layoutMode: ${_this.layoutMode}, nodes: ${_this.nodes}, edges: ${_this.edges}, pointers: ${_this.pointers}, auxTables: ${_this.auxTables}, zones: ${_this.zones})';
}


}

/// @nodoc
abstract mixin class $SceneSnapshotCopyWith<$Res>  {
  factory $SceneSnapshotCopyWith(SceneSnapshot value, $Res Function(SceneSnapshot) _then) = _$SceneSnapshotCopyWithImpl;
@useResult
$Res call({
 SceneLayoutMode layoutMode, List<SceneNode> nodes, List<SceneEdge> edges, List<PointerBadge> pointers, List<AuxTableSnapshot> auxTables, List<SceneZoneOverlay> zones
});




}
/// @nodoc
class _$SceneSnapshotCopyWithImpl<$Res>
    implements $SceneSnapshotCopyWith<$Res> {
  _$SceneSnapshotCopyWithImpl(this._self, this._then);

  final SceneSnapshot _self;
  final $Res Function(SceneSnapshot) _then;

/// Create a copy of SceneSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layoutMode = null,Object? nodes = null,Object? edges = null,Object? pointers = null,Object? auxTables = null,Object? zones = null,}) {
  return _then(SceneSnapshot(
layoutMode: null == layoutMode ? _self.layoutMode : layoutMode // ignore: cast_nullable_to_non_nullable
as SceneLayoutMode,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<SceneNode>,edges: null == edges ? _self.edges : edges // ignore: cast_nullable_to_non_nullable
as List<SceneEdge>,pointers: null == pointers ? _self.pointers : pointers // ignore: cast_nullable_to_non_nullable
as List<PointerBadge>,auxTables: null == auxTables ? _self.auxTables : auxTables // ignore: cast_nullable_to_non_nullable
as List<AuxTableSnapshot>,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<SceneZoneOverlay>,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneSnapshot].
extension SceneSnapshotPatterns on SceneSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SceneSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SceneSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SceneLayoutMode layoutMode,  List<SceneNode> nodes,  List<SceneEdge> edges,  List<PointerBadge> pointers,  List<AuxTableSnapshot> auxTables,  List<SceneZoneOverlay> zones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneSnapshot() when $default != null:
return $default(_that.layoutMode,_that.nodes,_that.edges,_that.pointers,_that.auxTables,_that.zones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SceneLayoutMode layoutMode,  List<SceneNode> nodes,  List<SceneEdge> edges,  List<PointerBadge> pointers,  List<AuxTableSnapshot> auxTables,  List<SceneZoneOverlay> zones)  $default,) {final _that = this;
switch (_that) {
case _SceneSnapshot():
return $default(_that.layoutMode,_that.nodes,_that.edges,_that.pointers,_that.auxTables,_that.zones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SceneLayoutMode layoutMode,  List<SceneNode> nodes,  List<SceneEdge> edges,  List<PointerBadge> pointers,  List<AuxTableSnapshot> auxTables,  List<SceneZoneOverlay> zones)?  $default,) {final _that = this;
switch (_that) {
case _SceneSnapshot() when $default != null:
return $default(_that.layoutMode,_that.nodes,_that.edges,_that.pointers,_that.auxTables,_that.zones);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneSnapshot implements SceneSnapshot {
  const _SceneSnapshot({this.layoutMode = SceneLayoutMode.freeCanvas,  List<SceneNode> nodes = const [],  List<SceneEdge> edges = const [],  List<PointerBadge> pointers = const [],  List<AuxTableSnapshot> auxTables = const [],  List<SceneZoneOverlay> zones = const []}): _nodes = nodes,_edges = edges,_pointers = pointers,_auxTables = auxTables,_zones = zones;
  factory _SceneSnapshot.fromJson(Map<String, dynamic> json) => _$SceneSnapshotFromJson(json);

@override@JsonKey() final  SceneLayoutMode layoutMode;
 final  List<SceneNode> _nodes;
@override@JsonKey() List<SceneNode> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

 final  List<SceneEdge> _edges;
@override@JsonKey() List<SceneEdge> get edges {
  if (_edges is EqualUnmodifiableListView) return _edges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_edges);
}

 final  List<PointerBadge> _pointers;
@override@JsonKey() List<PointerBadge> get pointers {
  if (_pointers is EqualUnmodifiableListView) return _pointers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pointers);
}

 final  List<AuxTableSnapshot> _auxTables;
@override@JsonKey() List<AuxTableSnapshot> get auxTables {
  if (_auxTables is EqualUnmodifiableListView) return _auxTables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_auxTables);
}

 final  List<SceneZoneOverlay> _zones;
@override@JsonKey() List<SceneZoneOverlay> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}


/// Create a copy of SceneSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneSnapshotCopyWith<_SceneSnapshot> get copyWith => __$SceneSnapshotCopyWithImpl<_SceneSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneSnapshot&&(identical(other.layoutMode, layoutMode) || other.layoutMode == layoutMode)&&const DeepCollectionEquality().equals(other.nodes, _nodes)&&const DeepCollectionEquality().equals(other.edges, _edges)&&const DeepCollectionEquality().equals(other.pointers, _pointers)&&const DeepCollectionEquality().equals(other.auxTables, _auxTables)&&const DeepCollectionEquality().equals(other.zones, _zones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,layoutMode,const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_edges),const DeepCollectionEquality().hash(_pointers),const DeepCollectionEquality().hash(_auxTables),const DeepCollectionEquality().hash(_zones));
}

@override
String toString() {
    return 'SceneSnapshot(layoutMode: $layoutMode, nodes: $nodes, edges: $edges, pointers: $pointers, auxTables: $auxTables, zones: $zones)';
}


}

/// @nodoc
abstract mixin class _$SceneSnapshotCopyWith<$Res> implements $SceneSnapshotCopyWith<$Res> {
  factory _$SceneSnapshotCopyWith(_SceneSnapshot value, $Res Function(_SceneSnapshot) _then) = __$SceneSnapshotCopyWithImpl;
@override @useResult
$Res call({
 SceneLayoutMode layoutMode, List<SceneNode> nodes, List<SceneEdge> edges, List<PointerBadge> pointers, List<AuxTableSnapshot> auxTables, List<SceneZoneOverlay> zones
});




}
/// @nodoc
class __$SceneSnapshotCopyWithImpl<$Res>
    implements _$SceneSnapshotCopyWith<$Res> {
  __$SceneSnapshotCopyWithImpl(this._self, this._then);

  final _SceneSnapshot _self;
  final $Res Function(_SceneSnapshot) _then;

/// Create a copy of SceneSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layoutMode = null,Object? nodes = null,Object? edges = null,Object? pointers = null,Object? auxTables = null,Object? zones = null,}) {
  return _then(_SceneSnapshot(
layoutMode: null == layoutMode ? _self.layoutMode : layoutMode // ignore: cast_nullable_to_non_nullable
as SceneLayoutMode,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<SceneNode>,edges: null == edges ? _self._edges : edges // ignore: cast_nullable_to_non_nullable
as List<SceneEdge>,pointers: null == pointers ? _self._pointers : pointers // ignore: cast_nullable_to_non_nullable
as List<PointerBadge>,auxTables: null == auxTables ? _self._auxTables : auxTables // ignore: cast_nullable_to_non_nullable
as List<AuxTableSnapshot>,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<SceneZoneOverlay>,
  ));
}


}


/// @nodoc
mixin _$SceneNode {

 String get id; String get label; double get x; double get y; double get width; double get height; NodeShape get shape; NodeVisualState get visualState; String? get indexBadge; String? get logicBadge; String? get memoryAddress; bool get isZeroSentinelSlot; bool get isOrphanLeak; bool get isDeleted; double get opacity; double get scale; String? get groupTag;
/// Create a copy of SceneNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneNodeCopyWith<SceneNode> get copyWith => _$SceneNodeCopyWithImpl<SceneNode>(this as SceneNode, _$identity);

  /// Serializes this SceneNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneNode&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.shape, _this.shape) || other.shape == _this.shape)&&(identical(other.visualState, _this.visualState) || other.visualState == _this.visualState)&&(identical(other.indexBadge, _this.indexBadge) || other.indexBadge == _this.indexBadge)&&(identical(other.logicBadge, _this.logicBadge) || other.logicBadge == _this.logicBadge)&&(identical(other.memoryAddress, _this.memoryAddress) || other.memoryAddress == _this.memoryAddress)&&(identical(other.isZeroSentinelSlot, _this.isZeroSentinelSlot) || other.isZeroSentinelSlot == _this.isZeroSentinelSlot)&&(identical(other.isOrphanLeak, _this.isOrphanLeak) || other.isOrphanLeak == _this.isOrphanLeak)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity)&&(identical(other.scale, _this.scale) || other.scale == _this.scale)&&(identical(other.groupTag, _this.groupTag) || other.groupTag == _this.groupTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneNode;
  return Object.hash(runtimeType,_this.id,_this.label,_this.x,_this.y,_this.width,_this.height,_this.shape,_this.visualState,_this.indexBadge,_this.logicBadge,_this.memoryAddress,_this.isZeroSentinelSlot,_this.isOrphanLeak,_this.isDeleted,_this.opacity,_this.scale,_this.groupTag);
}

@override
String toString() {
  final _this = this as SceneNode;
  return 'SceneNode(id: ${_this.id}, label: ${_this.label}, x: ${_this.x}, y: ${_this.y}, width: ${_this.width}, height: ${_this.height}, shape: ${_this.shape}, visualState: ${_this.visualState}, indexBadge: ${_this.indexBadge}, logicBadge: ${_this.logicBadge}, memoryAddress: ${_this.memoryAddress}, isZeroSentinelSlot: ${_this.isZeroSentinelSlot}, isOrphanLeak: ${_this.isOrphanLeak}, isDeleted: ${_this.isDeleted}, opacity: ${_this.opacity}, scale: ${_this.scale}, groupTag: ${_this.groupTag})';
}


}

/// @nodoc
abstract mixin class $SceneNodeCopyWith<$Res>  {
  factory $SceneNodeCopyWith(SceneNode value, $Res Function(SceneNode) _then) = _$SceneNodeCopyWithImpl;
@useResult
$Res call({
 String id, String label, double x, double y, double width, double height, NodeShape shape, NodeVisualState visualState, String? indexBadge, String? logicBadge, String? memoryAddress, bool isZeroSentinelSlot, bool isOrphanLeak, bool isDeleted, double opacity, double scale, String? groupTag
});




}
/// @nodoc
class _$SceneNodeCopyWithImpl<$Res>
    implements $SceneNodeCopyWith<$Res> {
  _$SceneNodeCopyWithImpl(this._self, this._then);

  final SceneNode _self;
  final $Res Function(SceneNode) _then;

/// Create a copy of SceneNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? shape = null,Object? visualState = null,Object? indexBadge = freezed,Object? logicBadge = freezed,Object? memoryAddress = freezed,Object? isZeroSentinelSlot = null,Object? isOrphanLeak = null,Object? isDeleted = null,Object? opacity = null,Object? scale = null,Object? groupTag = freezed,}) {
  return _then(SceneNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as NodeShape,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,indexBadge: freezed == indexBadge ? _self.indexBadge : indexBadge // ignore: cast_nullable_to_non_nullable
as String?,logicBadge: freezed == logicBadge ? _self.logicBadge : logicBadge // ignore: cast_nullable_to_non_nullable
as String?,memoryAddress: freezed == memoryAddress ? _self.memoryAddress : memoryAddress // ignore: cast_nullable_to_non_nullable
as String?,isZeroSentinelSlot: null == isZeroSentinelSlot ? _self.isZeroSentinelSlot : isZeroSentinelSlot // ignore: cast_nullable_to_non_nullable
as bool,isOrphanLeak: null == isOrphanLeak ? _self.isOrphanLeak : isOrphanLeak // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,groupTag: freezed == groupTag ? _self.groupTag : groupTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneNode].
extension SceneNodePatterns on SceneNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneNode value)  $default,){
final _that = this;
switch (_that) {
case _SceneNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneNode value)?  $default,){
final _that = this;
switch (_that) {
case _SceneNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  double x,  double y,  double width,  double height,  NodeShape shape,  NodeVisualState visualState,  String? indexBadge,  String? logicBadge,  String? memoryAddress,  bool isZeroSentinelSlot,  bool isOrphanLeak,  bool isDeleted,  double opacity,  double scale,  String? groupTag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneNode() when $default != null:
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.shape,_that.visualState,_that.indexBadge,_that.logicBadge,_that.memoryAddress,_that.isZeroSentinelSlot,_that.isOrphanLeak,_that.isDeleted,_that.opacity,_that.scale,_that.groupTag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  double x,  double y,  double width,  double height,  NodeShape shape,  NodeVisualState visualState,  String? indexBadge,  String? logicBadge,  String? memoryAddress,  bool isZeroSentinelSlot,  bool isOrphanLeak,  bool isDeleted,  double opacity,  double scale,  String? groupTag)  $default,) {final _that = this;
switch (_that) {
case _SceneNode():
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.shape,_that.visualState,_that.indexBadge,_that.logicBadge,_that.memoryAddress,_that.isZeroSentinelSlot,_that.isOrphanLeak,_that.isDeleted,_that.opacity,_that.scale,_that.groupTag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  double x,  double y,  double width,  double height,  NodeShape shape,  NodeVisualState visualState,  String? indexBadge,  String? logicBadge,  String? memoryAddress,  bool isZeroSentinelSlot,  bool isOrphanLeak,  bool isDeleted,  double opacity,  double scale,  String? groupTag)?  $default,) {final _that = this;
switch (_that) {
case _SceneNode() when $default != null:
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.shape,_that.visualState,_that.indexBadge,_that.logicBadge,_that.memoryAddress,_that.isZeroSentinelSlot,_that.isOrphanLeak,_that.isDeleted,_that.opacity,_that.scale,_that.groupTag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneNode implements SceneNode {
  const _SceneNode({required this.id, required this.label, required this.x, required this.y, this.width = 56, this.height = 48, this.shape = NodeShape.roundedRect, this.visualState = NodeVisualState.normal, this.indexBadge, this.logicBadge, this.memoryAddress, this.isZeroSentinelSlot = false, this.isOrphanLeak = false, this.isDeleted = false, this.opacity = 1, this.scale = 1, this.groupTag});
  factory _SceneNode.fromJson(Map<String, dynamic> json) => _$SceneNodeFromJson(json);

@override final  String id;
@override final  String label;
@override final  double x;
@override final  double y;
@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override@JsonKey() final  NodeShape shape;
@override@JsonKey() final  NodeVisualState visualState;
@override final  String? indexBadge;
@override final  String? logicBadge;
@override final  String? memoryAddress;
@override@JsonKey() final  bool isZeroSentinelSlot;
@override@JsonKey() final  bool isOrphanLeak;
@override@JsonKey() final  bool isDeleted;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  double scale;
@override final  String? groupTag;

/// Create a copy of SceneNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneNodeCopyWith<_SceneNode> get copyWith => __$SceneNodeCopyWithImpl<_SceneNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneNodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneNode&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.visualState, visualState) || other.visualState == visualState)&&(identical(other.indexBadge, indexBadge) || other.indexBadge == indexBadge)&&(identical(other.logicBadge, logicBadge) || other.logicBadge == logicBadge)&&(identical(other.memoryAddress, memoryAddress) || other.memoryAddress == memoryAddress)&&(identical(other.isZeroSentinelSlot, isZeroSentinelSlot) || other.isZeroSentinelSlot == isZeroSentinelSlot)&&(identical(other.isOrphanLeak, isOrphanLeak) || other.isOrphanLeak == isOrphanLeak)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.groupTag, groupTag) || other.groupTag == groupTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,x,y,width,height,shape,visualState,indexBadge,logicBadge,memoryAddress,isZeroSentinelSlot,isOrphanLeak,isDeleted,opacity,scale,groupTag);
}

@override
String toString() {
    return 'SceneNode(id: $id, label: $label, x: $x, y: $y, width: $width, height: $height, shape: $shape, visualState: $visualState, indexBadge: $indexBadge, logicBadge: $logicBadge, memoryAddress: $memoryAddress, isZeroSentinelSlot: $isZeroSentinelSlot, isOrphanLeak: $isOrphanLeak, isDeleted: $isDeleted, opacity: $opacity, scale: $scale, groupTag: $groupTag)';
}


}

/// @nodoc
abstract mixin class _$SceneNodeCopyWith<$Res> implements $SceneNodeCopyWith<$Res> {
  factory _$SceneNodeCopyWith(_SceneNode value, $Res Function(_SceneNode) _then) = __$SceneNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, double x, double y, double width, double height, NodeShape shape, NodeVisualState visualState, String? indexBadge, String? logicBadge, String? memoryAddress, bool isZeroSentinelSlot, bool isOrphanLeak, bool isDeleted, double opacity, double scale, String? groupTag
});




}
/// @nodoc
class __$SceneNodeCopyWithImpl<$Res>
    implements _$SceneNodeCopyWith<$Res> {
  __$SceneNodeCopyWithImpl(this._self, this._then);

  final _SceneNode _self;
  final $Res Function(_SceneNode) _then;

/// Create a copy of SceneNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? shape = null,Object? visualState = null,Object? indexBadge = freezed,Object? logicBadge = freezed,Object? memoryAddress = freezed,Object? isZeroSentinelSlot = null,Object? isOrphanLeak = null,Object? isDeleted = null,Object? opacity = null,Object? scale = null,Object? groupTag = freezed,}) {
  return _then(_SceneNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as NodeShape,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,indexBadge: freezed == indexBadge ? _self.indexBadge : indexBadge // ignore: cast_nullable_to_non_nullable
as String?,logicBadge: freezed == logicBadge ? _self.logicBadge : logicBadge // ignore: cast_nullable_to_non_nullable
as String?,memoryAddress: freezed == memoryAddress ? _self.memoryAddress : memoryAddress // ignore: cast_nullable_to_non_nullable
as String?,isZeroSentinelSlot: null == isZeroSentinelSlot ? _self.isZeroSentinelSlot : isZeroSentinelSlot // ignore: cast_nullable_to_non_nullable
as bool,isOrphanLeak: null == isOrphanLeak ? _self.isOrphanLeak : isOrphanLeak // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,groupTag: freezed == groupTag ? _self.groupTag : groupTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SceneEdge {

 String get id; String get fromNodeId; String get toNodeId; EdgePort get fromPort; EdgeStyle get style; NodeVisualState get visualState; String? get weightLabel; double get curvature; double get drawProgress; double get opacity;
/// Create a copy of SceneEdge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneEdgeCopyWith<SceneEdge> get copyWith => _$SceneEdgeCopyWithImpl<SceneEdge>(this as SceneEdge, _$identity);

  /// Serializes this SceneEdge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneEdge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneEdge&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fromNodeId, _this.fromNodeId) || other.fromNodeId == _this.fromNodeId)&&(identical(other.toNodeId, _this.toNodeId) || other.toNodeId == _this.toNodeId)&&(identical(other.fromPort, _this.fromPort) || other.fromPort == _this.fromPort)&&(identical(other.style, _this.style) || other.style == _this.style)&&(identical(other.visualState, _this.visualState) || other.visualState == _this.visualState)&&(identical(other.weightLabel, _this.weightLabel) || other.weightLabel == _this.weightLabel)&&(identical(other.curvature, _this.curvature) || other.curvature == _this.curvature)&&(identical(other.drawProgress, _this.drawProgress) || other.drawProgress == _this.drawProgress)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneEdge;
  return Object.hash(runtimeType,_this.id,_this.fromNodeId,_this.toNodeId,_this.fromPort,_this.style,_this.visualState,_this.weightLabel,_this.curvature,_this.drawProgress,_this.opacity);
}

@override
String toString() {
  final _this = this as SceneEdge;
  return 'SceneEdge(id: ${_this.id}, fromNodeId: ${_this.fromNodeId}, toNodeId: ${_this.toNodeId}, fromPort: ${_this.fromPort}, style: ${_this.style}, visualState: ${_this.visualState}, weightLabel: ${_this.weightLabel}, curvature: ${_this.curvature}, drawProgress: ${_this.drawProgress}, opacity: ${_this.opacity})';
}


}

/// @nodoc
abstract mixin class $SceneEdgeCopyWith<$Res>  {
  factory $SceneEdgeCopyWith(SceneEdge value, $Res Function(SceneEdge) _then) = _$SceneEdgeCopyWithImpl;
@useResult
$Res call({
 String id, String fromNodeId, String toNodeId, EdgePort fromPort, EdgeStyle style, NodeVisualState visualState, String? weightLabel, double curvature, double drawProgress, double opacity
});




}
/// @nodoc
class _$SceneEdgeCopyWithImpl<$Res>
    implements $SceneEdgeCopyWith<$Res> {
  _$SceneEdgeCopyWithImpl(this._self, this._then);

  final SceneEdge _self;
  final $Res Function(SceneEdge) _then;

/// Create a copy of SceneEdge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromNodeId = null,Object? toNodeId = null,Object? fromPort = null,Object? style = null,Object? visualState = null,Object? weightLabel = freezed,Object? curvature = null,Object? drawProgress = null,Object? opacity = null,}) {
  return _then(SceneEdge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromNodeId: null == fromNodeId ? _self.fromNodeId : fromNodeId // ignore: cast_nullable_to_non_nullable
as String,toNodeId: null == toNodeId ? _self.toNodeId : toNodeId // ignore: cast_nullable_to_non_nullable
as String,fromPort: null == fromPort ? _self.fromPort : fromPort // ignore: cast_nullable_to_non_nullable
as EdgePort,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as EdgeStyle,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,weightLabel: freezed == weightLabel ? _self.weightLabel : weightLabel // ignore: cast_nullable_to_non_nullable
as String?,curvature: null == curvature ? _self.curvature : curvature // ignore: cast_nullable_to_non_nullable
as double,drawProgress: null == drawProgress ? _self.drawProgress : drawProgress // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneEdge].
extension SceneEdgePatterns on SceneEdge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneEdge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneEdge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneEdge value)  $default,){
final _that = this;
switch (_that) {
case _SceneEdge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneEdge value)?  $default,){
final _that = this;
switch (_that) {
case _SceneEdge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromNodeId,  String toNodeId,  EdgePort fromPort,  EdgeStyle style,  NodeVisualState visualState,  String? weightLabel,  double curvature,  double drawProgress,  double opacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneEdge() when $default != null:
return $default(_that.id,_that.fromNodeId,_that.toNodeId,_that.fromPort,_that.style,_that.visualState,_that.weightLabel,_that.curvature,_that.drawProgress,_that.opacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromNodeId,  String toNodeId,  EdgePort fromPort,  EdgeStyle style,  NodeVisualState visualState,  String? weightLabel,  double curvature,  double drawProgress,  double opacity)  $default,) {final _that = this;
switch (_that) {
case _SceneEdge():
return $default(_that.id,_that.fromNodeId,_that.toNodeId,_that.fromPort,_that.style,_that.visualState,_that.weightLabel,_that.curvature,_that.drawProgress,_that.opacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromNodeId,  String toNodeId,  EdgePort fromPort,  EdgeStyle style,  NodeVisualState visualState,  String? weightLabel,  double curvature,  double drawProgress,  double opacity)?  $default,) {final _that = this;
switch (_that) {
case _SceneEdge() when $default != null:
return $default(_that.id,_that.fromNodeId,_that.toNodeId,_that.fromPort,_that.style,_that.visualState,_that.weightLabel,_that.curvature,_that.drawProgress,_that.opacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneEdge implements SceneEdge {
  const _SceneEdge({required this.id, required this.fromNodeId, required this.toNodeId, this.fromPort = EdgePort.auto, this.style = EdgeStyle.solidArrow, this.visualState = NodeVisualState.normal, this.weightLabel, this.curvature = 0, this.drawProgress = 1, this.opacity = 1});
  factory _SceneEdge.fromJson(Map<String, dynamic> json) => _$SceneEdgeFromJson(json);

@override final  String id;
@override final  String fromNodeId;
@override final  String toNodeId;
@override@JsonKey() final  EdgePort fromPort;
@override@JsonKey() final  EdgeStyle style;
@override@JsonKey() final  NodeVisualState visualState;
@override final  String? weightLabel;
@override@JsonKey() final  double curvature;
@override@JsonKey() final  double drawProgress;
@override@JsonKey() final  double opacity;

/// Create a copy of SceneEdge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneEdgeCopyWith<_SceneEdge> get copyWith => __$SceneEdgeCopyWithImpl<_SceneEdge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneEdgeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneEdge&&(identical(other.id, id) || other.id == id)&&(identical(other.fromNodeId, fromNodeId) || other.fromNodeId == fromNodeId)&&(identical(other.toNodeId, toNodeId) || other.toNodeId == toNodeId)&&(identical(other.fromPort, fromPort) || other.fromPort == fromPort)&&(identical(other.style, style) || other.style == style)&&(identical(other.visualState, visualState) || other.visualState == visualState)&&(identical(other.weightLabel, weightLabel) || other.weightLabel == weightLabel)&&(identical(other.curvature, curvature) || other.curvature == curvature)&&(identical(other.drawProgress, drawProgress) || other.drawProgress == drawProgress)&&(identical(other.opacity, opacity) || other.opacity == opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fromNodeId,toNodeId,fromPort,style,visualState,weightLabel,curvature,drawProgress,opacity);
}

@override
String toString() {
    return 'SceneEdge(id: $id, fromNodeId: $fromNodeId, toNodeId: $toNodeId, fromPort: $fromPort, style: $style, visualState: $visualState, weightLabel: $weightLabel, curvature: $curvature, drawProgress: $drawProgress, opacity: $opacity)';
}


}

/// @nodoc
abstract mixin class _$SceneEdgeCopyWith<$Res> implements $SceneEdgeCopyWith<$Res> {
  factory _$SceneEdgeCopyWith(_SceneEdge value, $Res Function(_SceneEdge) _then) = __$SceneEdgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromNodeId, String toNodeId, EdgePort fromPort, EdgeStyle style, NodeVisualState visualState, String? weightLabel, double curvature, double drawProgress, double opacity
});




}
/// @nodoc
class __$SceneEdgeCopyWithImpl<$Res>
    implements _$SceneEdgeCopyWith<$Res> {
  __$SceneEdgeCopyWithImpl(this._self, this._then);

  final _SceneEdge _self;
  final $Res Function(_SceneEdge) _then;

/// Create a copy of SceneEdge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromNodeId = null,Object? toNodeId = null,Object? fromPort = null,Object? style = null,Object? visualState = null,Object? weightLabel = freezed,Object? curvature = null,Object? drawProgress = null,Object? opacity = null,}) {
  return _then(_SceneEdge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromNodeId: null == fromNodeId ? _self.fromNodeId : fromNodeId // ignore: cast_nullable_to_non_nullable
as String,toNodeId: null == toNodeId ? _self.toNodeId : toNodeId // ignore: cast_nullable_to_non_nullable
as String,fromPort: null == fromPort ? _self.fromPort : fromPort // ignore: cast_nullable_to_non_nullable
as EdgePort,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as EdgeStyle,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,weightLabel: freezed == weightLabel ? _self.weightLabel : weightLabel // ignore: cast_nullable_to_non_nullable
as String?,curvature: null == curvature ? _self.curvature : curvature // ignore: cast_nullable_to_non_nullable
as double,drawProgress: null == drawProgress ? _self.drawProgress : drawProgress // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PointerOrbit {

 Vec2 get center; double get radius; double get angle;
/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointerOrbitCopyWith<PointerOrbit> get copyWith => _$PointerOrbitCopyWithImpl<PointerOrbit>(this as PointerOrbit, _$identity);

  /// Serializes this PointerOrbit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PointerOrbit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointerOrbit&&(identical(other.center, _this.center) || other.center == _this.center)&&(identical(other.radius, _this.radius) || other.radius == _this.radius)&&(identical(other.angle, _this.angle) || other.angle == _this.angle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PointerOrbit;
  return Object.hash(runtimeType,_this.center,_this.radius,_this.angle);
}

@override
String toString() {
  final _this = this as PointerOrbit;
  return 'PointerOrbit(center: ${_this.center}, radius: ${_this.radius}, angle: ${_this.angle})';
}


}

/// @nodoc
abstract mixin class $PointerOrbitCopyWith<$Res>  {
  factory $PointerOrbitCopyWith(PointerOrbit value, $Res Function(PointerOrbit) _then) = _$PointerOrbitCopyWithImpl;
@useResult
$Res call({
 Vec2 center, double radius, double angle
});


$Vec2CopyWith<$Res> get center;

}
/// @nodoc
class _$PointerOrbitCopyWithImpl<$Res>
    implements $PointerOrbitCopyWith<$Res> {
  _$PointerOrbitCopyWithImpl(this._self, this._then);

  final PointerOrbit _self;
  final $Res Function(PointerOrbit) _then;

/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? center = null,Object? radius = null,Object? angle = null,}) {
  return _then(PointerOrbit(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as Vec2,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Vec2CopyWith<$Res> get center {
  
  return $Vec2CopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}


/// Adds pattern-matching-related methods to [PointerOrbit].
extension PointerOrbitPatterns on PointerOrbit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointerOrbit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointerOrbit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointerOrbit value)  $default,){
final _that = this;
switch (_that) {
case _PointerOrbit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointerOrbit value)?  $default,){
final _that = this;
switch (_that) {
case _PointerOrbit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Vec2 center,  double radius,  double angle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointerOrbit() when $default != null:
return $default(_that.center,_that.radius,_that.angle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Vec2 center,  double radius,  double angle)  $default,) {final _that = this;
switch (_that) {
case _PointerOrbit():
return $default(_that.center,_that.radius,_that.angle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Vec2 center,  double radius,  double angle)?  $default,) {final _that = this;
switch (_that) {
case _PointerOrbit() when $default != null:
return $default(_that.center,_that.radius,_that.angle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PointerOrbit implements PointerOrbit {
  const _PointerOrbit({required this.center, required this.radius, required this.angle});
  factory _PointerOrbit.fromJson(Map<String, dynamic> json) => _$PointerOrbitFromJson(json);

@override final  Vec2 center;
@override final  double radius;
@override final  double angle;

/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointerOrbitCopyWith<_PointerOrbit> get copyWith => __$PointerOrbitCopyWithImpl<_PointerOrbit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointerOrbitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointerOrbit&&(identical(other.center, center) || other.center == center)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.angle, angle) || other.angle == angle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,center,radius,angle);
}

@override
String toString() {
    return 'PointerOrbit(center: $center, radius: $radius, angle: $angle)';
}


}

/// @nodoc
abstract mixin class _$PointerOrbitCopyWith<$Res> implements $PointerOrbitCopyWith<$Res> {
  factory _$PointerOrbitCopyWith(_PointerOrbit value, $Res Function(_PointerOrbit) _then) = __$PointerOrbitCopyWithImpl;
@override @useResult
$Res call({
 Vec2 center, double radius, double angle
});


@override $Vec2CopyWith<$Res> get center;

}
/// @nodoc
class __$PointerOrbitCopyWithImpl<$Res>
    implements _$PointerOrbitCopyWith<$Res> {
  __$PointerOrbitCopyWithImpl(this._self, this._then);

  final _PointerOrbit _self;
  final $Res Function(_PointerOrbit) _then;

/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? center = null,Object? radius = null,Object? angle = null,}) {
  return _then(_PointerOrbit(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as Vec2,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of PointerOrbit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Vec2CopyWith<$Res> get center {
  
  return $Vec2CopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}


/// @nodoc
mixin _$PointerBadge {

 String get id; String get label; String get targetNodeId; PointerOrbit? get orbit; double get dx; double get dy; NodeVisualState get visualState; double get opacity;
/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointerBadgeCopyWith<PointerBadge> get copyWith => _$PointerBadgeCopyWithImpl<PointerBadge>(this as PointerBadge, _$identity);

  /// Serializes this PointerBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PointerBadge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointerBadge&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.targetNodeId, _this.targetNodeId) || other.targetNodeId == _this.targetNodeId)&&(identical(other.orbit, _this.orbit) || other.orbit == _this.orbit)&&(identical(other.dx, _this.dx) || other.dx == _this.dx)&&(identical(other.dy, _this.dy) || other.dy == _this.dy)&&(identical(other.visualState, _this.visualState) || other.visualState == _this.visualState)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PointerBadge;
  return Object.hash(runtimeType,_this.id,_this.label,_this.targetNodeId,_this.orbit,_this.dx,_this.dy,_this.visualState,_this.opacity);
}

@override
String toString() {
  final _this = this as PointerBadge;
  return 'PointerBadge(id: ${_this.id}, label: ${_this.label}, targetNodeId: ${_this.targetNodeId}, orbit: ${_this.orbit}, dx: ${_this.dx}, dy: ${_this.dy}, visualState: ${_this.visualState}, opacity: ${_this.opacity})';
}


}

/// @nodoc
abstract mixin class $PointerBadgeCopyWith<$Res>  {
  factory $PointerBadgeCopyWith(PointerBadge value, $Res Function(PointerBadge) _then) = _$PointerBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String label, String targetNodeId, PointerOrbit? orbit, double dx, double dy, NodeVisualState visualState, double opacity
});


$PointerOrbitCopyWith<$Res>? get orbit;

}
/// @nodoc
class _$PointerBadgeCopyWithImpl<$Res>
    implements $PointerBadgeCopyWith<$Res> {
  _$PointerBadgeCopyWithImpl(this._self, this._then);

  final PointerBadge _self;
  final $Res Function(PointerBadge) _then;

/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? targetNodeId = null,Object? orbit = freezed,Object? dx = null,Object? dy = null,Object? visualState = null,Object? opacity = null,}) {
  return _then(PointerBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,targetNodeId: null == targetNodeId ? _self.targetNodeId : targetNodeId // ignore: cast_nullable_to_non_nullable
as String,orbit: freezed == orbit ? _self.orbit : orbit // ignore: cast_nullable_to_non_nullable
as PointerOrbit?,dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PointerOrbitCopyWith<$Res>? get orbit {
    if (_self.orbit == null) {
    return null;
  }

  return $PointerOrbitCopyWith<$Res>(_self.orbit!, (value) {
    return _then(_self.copyWith(orbit: value));
  });
}
}


/// Adds pattern-matching-related methods to [PointerBadge].
extension PointerBadgePatterns on PointerBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointerBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointerBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointerBadge value)  $default,){
final _that = this;
switch (_that) {
case _PointerBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointerBadge value)?  $default,){
final _that = this;
switch (_that) {
case _PointerBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String targetNodeId,  PointerOrbit? orbit,  double dx,  double dy,  NodeVisualState visualState,  double opacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointerBadge() when $default != null:
return $default(_that.id,_that.label,_that.targetNodeId,_that.orbit,_that.dx,_that.dy,_that.visualState,_that.opacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String targetNodeId,  PointerOrbit? orbit,  double dx,  double dy,  NodeVisualState visualState,  double opacity)  $default,) {final _that = this;
switch (_that) {
case _PointerBadge():
return $default(_that.id,_that.label,_that.targetNodeId,_that.orbit,_that.dx,_that.dy,_that.visualState,_that.opacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String targetNodeId,  PointerOrbit? orbit,  double dx,  double dy,  NodeVisualState visualState,  double opacity)?  $default,) {final _that = this;
switch (_that) {
case _PointerBadge() when $default != null:
return $default(_that.id,_that.label,_that.targetNodeId,_that.orbit,_that.dx,_that.dy,_that.visualState,_that.opacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PointerBadge implements PointerBadge {
  const _PointerBadge({required this.id, required this.label, required this.targetNodeId, this.orbit, this.dx = 0, this.dy = -28, this.visualState = NodeVisualState.active, this.opacity = 1});
  factory _PointerBadge.fromJson(Map<String, dynamic> json) => _$PointerBadgeFromJson(json);

@override final  String id;
@override final  String label;
@override final  String targetNodeId;
@override final  PointerOrbit? orbit;
@override@JsonKey() final  double dx;
@override@JsonKey() final  double dy;
@override@JsonKey() final  NodeVisualState visualState;
@override@JsonKey() final  double opacity;

/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointerBadgeCopyWith<_PointerBadge> get copyWith => __$PointerBadgeCopyWithImpl<_PointerBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointerBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointerBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.targetNodeId, targetNodeId) || other.targetNodeId == targetNodeId)&&(identical(other.orbit, orbit) || other.orbit == orbit)&&(identical(other.dx, dx) || other.dx == dx)&&(identical(other.dy, dy) || other.dy == dy)&&(identical(other.visualState, visualState) || other.visualState == visualState)&&(identical(other.opacity, opacity) || other.opacity == opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,targetNodeId,orbit,dx,dy,visualState,opacity);
}

@override
String toString() {
    return 'PointerBadge(id: $id, label: $label, targetNodeId: $targetNodeId, orbit: $orbit, dx: $dx, dy: $dy, visualState: $visualState, opacity: $opacity)';
}


}

/// @nodoc
abstract mixin class _$PointerBadgeCopyWith<$Res> implements $PointerBadgeCopyWith<$Res> {
  factory _$PointerBadgeCopyWith(_PointerBadge value, $Res Function(_PointerBadge) _then) = __$PointerBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String targetNodeId, PointerOrbit? orbit, double dx, double dy, NodeVisualState visualState, double opacity
});


@override $PointerOrbitCopyWith<$Res>? get orbit;

}
/// @nodoc
class __$PointerBadgeCopyWithImpl<$Res>
    implements _$PointerBadgeCopyWith<$Res> {
  __$PointerBadgeCopyWithImpl(this._self, this._then);

  final _PointerBadge _self;
  final $Res Function(_PointerBadge) _then;

/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? targetNodeId = null,Object? orbit = freezed,Object? dx = null,Object? dy = null,Object? visualState = null,Object? opacity = null,}) {
  return _then(_PointerBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,targetNodeId: null == targetNodeId ? _self.targetNodeId : targetNodeId // ignore: cast_nullable_to_non_nullable
as String,orbit: freezed == orbit ? _self.orbit : orbit // ignore: cast_nullable_to_non_nullable
as PointerOrbit?,dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of PointerBadge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PointerOrbitCopyWith<$Res>? get orbit {
    if (_self.orbit == null) {
    return null;
  }

  return $PointerOrbitCopyWith<$Res>(_self.orbit!, (value) {
    return _then(_self.copyWith(orbit: value));
  });
}
}


/// @nodoc
mixin _$AuxTableSnapshot {

 String get id; String get title; List<String> get columns; List<List<String>> get rows; Set<int> get highlightedRows;
/// Create a copy of AuxTableSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuxTableSnapshotCopyWith<AuxTableSnapshot> get copyWith => _$AuxTableSnapshotCopyWithImpl<AuxTableSnapshot>(this as AuxTableSnapshot, _$identity);

  /// Serializes this AuxTableSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuxTableSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuxTableSnapshot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.columns, _this.columns)&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&const DeepCollectionEquality().equals(other.highlightedRows, _this.highlightedRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuxTableSnapshot;
  return Object.hash(runtimeType,_this.id,_this.title,const DeepCollectionEquality().hash(_this.columns),const DeepCollectionEquality().hash(_this.rows),const DeepCollectionEquality().hash(_this.highlightedRows));
}

@override
String toString() {
  final _this = this as AuxTableSnapshot;
  return 'AuxTableSnapshot(id: ${_this.id}, title: ${_this.title}, columns: ${_this.columns}, rows: ${_this.rows}, highlightedRows: ${_this.highlightedRows})';
}


}

/// @nodoc
abstract mixin class $AuxTableSnapshotCopyWith<$Res>  {
  factory $AuxTableSnapshotCopyWith(AuxTableSnapshot value, $Res Function(AuxTableSnapshot) _then) = _$AuxTableSnapshotCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<String> columns, List<List<String>> rows, Set<int> highlightedRows
});




}
/// @nodoc
class _$AuxTableSnapshotCopyWithImpl<$Res>
    implements $AuxTableSnapshotCopyWith<$Res> {
  _$AuxTableSnapshotCopyWithImpl(this._self, this._then);

  final AuxTableSnapshot _self;
  final $Res Function(AuxTableSnapshot) _then;

/// Create a copy of AuxTableSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? columns = null,Object? rows = null,Object? highlightedRows = null,}) {
  return _then(AuxTableSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<String>>,highlightedRows: null == highlightedRows ? _self.highlightedRows : highlightedRows // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuxTableSnapshot].
extension AuxTableSnapshotPatterns on AuxTableSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuxTableSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuxTableSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuxTableSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AuxTableSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuxTableSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AuxTableSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<String> columns,  List<List<String>> rows,  Set<int> highlightedRows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuxTableSnapshot() when $default != null:
return $default(_that.id,_that.title,_that.columns,_that.rows,_that.highlightedRows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<String> columns,  List<List<String>> rows,  Set<int> highlightedRows)  $default,) {final _that = this;
switch (_that) {
case _AuxTableSnapshot():
return $default(_that.id,_that.title,_that.columns,_that.rows,_that.highlightedRows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<String> columns,  List<List<String>> rows,  Set<int> highlightedRows)?  $default,) {final _that = this;
switch (_that) {
case _AuxTableSnapshot() when $default != null:
return $default(_that.id,_that.title,_that.columns,_that.rows,_that.highlightedRows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuxTableSnapshot implements AuxTableSnapshot {
  const _AuxTableSnapshot({required this.id, required this.title, required  List<String> columns, required  List<List<String>> rows,  Set<int> highlightedRows = const {}}): _columns = columns,_rows = rows,_highlightedRows = highlightedRows;
  factory _AuxTableSnapshot.fromJson(Map<String, dynamic> json) => _$AuxTableSnapshotFromJson(json);

@override final  String id;
@override final  String title;
 final  List<String> _columns;
@override List<String> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<List<String>> _rows;
@override List<List<String>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

 final  Set<int> _highlightedRows;
@override@JsonKey() Set<int> get highlightedRows {
  if (_highlightedRows is EqualUnmodifiableSetView) return _highlightedRows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_highlightedRows);
}


/// Create a copy of AuxTableSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuxTableSnapshotCopyWith<_AuxTableSnapshot> get copyWith => __$AuxTableSnapshotCopyWithImpl<_AuxTableSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuxTableSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuxTableSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.columns, _columns)&&const DeepCollectionEquality().equals(other.rows, _rows)&&const DeepCollectionEquality().equals(other.highlightedRows, _highlightedRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rows),const DeepCollectionEquality().hash(_highlightedRows));
}

@override
String toString() {
    return 'AuxTableSnapshot(id: $id, title: $title, columns: $columns, rows: $rows, highlightedRows: $highlightedRows)';
}


}

/// @nodoc
abstract mixin class _$AuxTableSnapshotCopyWith<$Res> implements $AuxTableSnapshotCopyWith<$Res> {
  factory _$AuxTableSnapshotCopyWith(_AuxTableSnapshot value, $Res Function(_AuxTableSnapshot) _then) = __$AuxTableSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<String> columns, List<List<String>> rows, Set<int> highlightedRows
});




}
/// @nodoc
class __$AuxTableSnapshotCopyWithImpl<$Res>
    implements _$AuxTableSnapshotCopyWith<$Res> {
  __$AuxTableSnapshotCopyWithImpl(this._self, this._then);

  final _AuxTableSnapshot _self;
  final $Res Function(_AuxTableSnapshot) _then;

/// Create a copy of AuxTableSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? columns = null,Object? rows = null,Object? highlightedRows = null,}) {
  return _then(_AuxTableSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<String>>,highlightedRows: null == highlightedRows ? _self._highlightedRows : highlightedRows // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}


}


/// @nodoc
mixin _$StackActivationRecord {

 String get id; String get functionName; Map<String, String> get arguments; Map<String, String> get locals; String get returnLocation; String? get parentCallId;
/// Create a copy of StackActivationRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StackActivationRecordCopyWith<StackActivationRecord> get copyWith => _$StackActivationRecordCopyWithImpl<StackActivationRecord>(this as StackActivationRecord, _$identity);

  /// Serializes this StackActivationRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StackActivationRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StackActivationRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.functionName, _this.functionName) || other.functionName == _this.functionName)&&const DeepCollectionEquality().equals(other.arguments, _this.arguments)&&const DeepCollectionEquality().equals(other.locals, _this.locals)&&(identical(other.returnLocation, _this.returnLocation) || other.returnLocation == _this.returnLocation)&&(identical(other.parentCallId, _this.parentCallId) || other.parentCallId == _this.parentCallId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StackActivationRecord;
  return Object.hash(runtimeType,_this.id,_this.functionName,const DeepCollectionEquality().hash(_this.arguments),const DeepCollectionEquality().hash(_this.locals),_this.returnLocation,_this.parentCallId);
}

@override
String toString() {
  final _this = this as StackActivationRecord;
  return 'StackActivationRecord(id: ${_this.id}, functionName: ${_this.functionName}, arguments: ${_this.arguments}, locals: ${_this.locals}, returnLocation: ${_this.returnLocation}, parentCallId: ${_this.parentCallId})';
}


}

/// @nodoc
abstract mixin class $StackActivationRecordCopyWith<$Res>  {
  factory $StackActivationRecordCopyWith(StackActivationRecord value, $Res Function(StackActivationRecord) _then) = _$StackActivationRecordCopyWithImpl;
@useResult
$Res call({
 String id, String functionName, Map<String, String> arguments, Map<String, String> locals, String returnLocation, String? parentCallId
});




}
/// @nodoc
class _$StackActivationRecordCopyWithImpl<$Res>
    implements $StackActivationRecordCopyWith<$Res> {
  _$StackActivationRecordCopyWithImpl(this._self, this._then);

  final StackActivationRecord _self;
  final $Res Function(StackActivationRecord) _then;

/// Create a copy of StackActivationRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? functionName = null,Object? arguments = null,Object? locals = null,Object? returnLocation = null,Object? parentCallId = freezed,}) {
  return _then(StackActivationRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,locals: null == locals ? _self.locals : locals // ignore: cast_nullable_to_non_nullable
as Map<String, String>,returnLocation: null == returnLocation ? _self.returnLocation : returnLocation // ignore: cast_nullable_to_non_nullable
as String,parentCallId: freezed == parentCallId ? _self.parentCallId : parentCallId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StackActivationRecord].
extension StackActivationRecordPatterns on StackActivationRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StackActivationRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StackActivationRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StackActivationRecord value)  $default,){
final _that = this;
switch (_that) {
case _StackActivationRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StackActivationRecord value)?  $default,){
final _that = this;
switch (_that) {
case _StackActivationRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String functionName,  Map<String, String> arguments,  Map<String, String> locals,  String returnLocation,  String? parentCallId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StackActivationRecord() when $default != null:
return $default(_that.id,_that.functionName,_that.arguments,_that.locals,_that.returnLocation,_that.parentCallId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String functionName,  Map<String, String> arguments,  Map<String, String> locals,  String returnLocation,  String? parentCallId)  $default,) {final _that = this;
switch (_that) {
case _StackActivationRecord():
return $default(_that.id,_that.functionName,_that.arguments,_that.locals,_that.returnLocation,_that.parentCallId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String functionName,  Map<String, String> arguments,  Map<String, String> locals,  String returnLocation,  String? parentCallId)?  $default,) {final _that = this;
switch (_that) {
case _StackActivationRecord() when $default != null:
return $default(_that.id,_that.functionName,_that.arguments,_that.locals,_that.returnLocation,_that.parentCallId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StackActivationRecord implements StackActivationRecord {
  const _StackActivationRecord({required this.id, required this.functionName,  Map<String, String> arguments = const {},  Map<String, String> locals = const {}, required this.returnLocation, this.parentCallId}): _arguments = arguments,_locals = locals;
  factory _StackActivationRecord.fromJson(Map<String, dynamic> json) => _$StackActivationRecordFromJson(json);

@override final  String id;
@override final  String functionName;
 final  Map<String, String> _arguments;
@override@JsonKey() Map<String, String> get arguments {
  if (_arguments is EqualUnmodifiableMapView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_arguments);
}

 final  Map<String, String> _locals;
@override@JsonKey() Map<String, String> get locals {
  if (_locals is EqualUnmodifiableMapView) return _locals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_locals);
}

@override final  String returnLocation;
@override final  String? parentCallId;

/// Create a copy of StackActivationRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StackActivationRecordCopyWith<_StackActivationRecord> get copyWith => __$StackActivationRecordCopyWithImpl<_StackActivationRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StackActivationRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StackActivationRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.functionName, functionName) || other.functionName == functionName)&&const DeepCollectionEquality().equals(other.arguments, _arguments)&&const DeepCollectionEquality().equals(other.locals, _locals)&&(identical(other.returnLocation, returnLocation) || other.returnLocation == returnLocation)&&(identical(other.parentCallId, parentCallId) || other.parentCallId == parentCallId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,functionName,const DeepCollectionEquality().hash(_arguments),const DeepCollectionEquality().hash(_locals),returnLocation,parentCallId);
}

@override
String toString() {
    return 'StackActivationRecord(id: $id, functionName: $functionName, arguments: $arguments, locals: $locals, returnLocation: $returnLocation, parentCallId: $parentCallId)';
}


}

/// @nodoc
abstract mixin class _$StackActivationRecordCopyWith<$Res> implements $StackActivationRecordCopyWith<$Res> {
  factory _$StackActivationRecordCopyWith(_StackActivationRecord value, $Res Function(_StackActivationRecord) _then) = __$StackActivationRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String functionName, Map<String, String> arguments, Map<String, String> locals, String returnLocation, String? parentCallId
});




}
/// @nodoc
class __$StackActivationRecordCopyWithImpl<$Res>
    implements _$StackActivationRecordCopyWith<$Res> {
  __$StackActivationRecordCopyWithImpl(this._self, this._then);

  final _StackActivationRecord _self;
  final $Res Function(_StackActivationRecord) _then;

/// Create a copy of StackActivationRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? functionName = null,Object? arguments = null,Object? locals = null,Object? returnLocation = null,Object? parentCallId = freezed,}) {
  return _then(_StackActivationRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,locals: null == locals ? _self._locals : locals // ignore: cast_nullable_to_non_nullable
as Map<String, String>,returnLocation: null == returnLocation ? _self.returnLocation : returnLocation // ignore: cast_nullable_to_non_nullable
as String,parentCallId: freezed == parentCallId ? _self.parentCallId : parentCallId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SceneZoneOverlay {

 String get id; String get label; double get x; double get y; double get width; double get height; ZonePattern get pattern; NodeVisualState get visualState; double get opacity;
/// Create a copy of SceneZoneOverlay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneZoneOverlayCopyWith<SceneZoneOverlay> get copyWith => _$SceneZoneOverlayCopyWithImpl<SceneZoneOverlay>(this as SceneZoneOverlay, _$identity);

  /// Serializes this SceneZoneOverlay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneZoneOverlay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneZoneOverlay&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.pattern, _this.pattern) || other.pattern == _this.pattern)&&(identical(other.visualState, _this.visualState) || other.visualState == _this.visualState)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneZoneOverlay;
  return Object.hash(runtimeType,_this.id,_this.label,_this.x,_this.y,_this.width,_this.height,_this.pattern,_this.visualState,_this.opacity);
}

@override
String toString() {
  final _this = this as SceneZoneOverlay;
  return 'SceneZoneOverlay(id: ${_this.id}, label: ${_this.label}, x: ${_this.x}, y: ${_this.y}, width: ${_this.width}, height: ${_this.height}, pattern: ${_this.pattern}, visualState: ${_this.visualState}, opacity: ${_this.opacity})';
}


}

/// @nodoc
abstract mixin class $SceneZoneOverlayCopyWith<$Res>  {
  factory $SceneZoneOverlayCopyWith(SceneZoneOverlay value, $Res Function(SceneZoneOverlay) _then) = _$SceneZoneOverlayCopyWithImpl;
@useResult
$Res call({
 String id, String label, double x, double y, double width, double height, ZonePattern pattern, NodeVisualState visualState, double opacity
});




}
/// @nodoc
class _$SceneZoneOverlayCopyWithImpl<$Res>
    implements $SceneZoneOverlayCopyWith<$Res> {
  _$SceneZoneOverlayCopyWithImpl(this._self, this._then);

  final SceneZoneOverlay _self;
  final $Res Function(SceneZoneOverlay) _then;

/// Create a copy of SceneZoneOverlay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? pattern = null,Object? visualState = null,Object? opacity = null,}) {
  return _then(SceneZoneOverlay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as ZonePattern,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneZoneOverlay].
extension SceneZoneOverlayPatterns on SceneZoneOverlay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneZoneOverlay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneZoneOverlay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneZoneOverlay value)  $default,){
final _that = this;
switch (_that) {
case _SceneZoneOverlay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneZoneOverlay value)?  $default,){
final _that = this;
switch (_that) {
case _SceneZoneOverlay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  double x,  double y,  double width,  double height,  ZonePattern pattern,  NodeVisualState visualState,  double opacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneZoneOverlay() when $default != null:
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.pattern,_that.visualState,_that.opacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  double x,  double y,  double width,  double height,  ZonePattern pattern,  NodeVisualState visualState,  double opacity)  $default,) {final _that = this;
switch (_that) {
case _SceneZoneOverlay():
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.pattern,_that.visualState,_that.opacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  double x,  double y,  double width,  double height,  ZonePattern pattern,  NodeVisualState visualState,  double opacity)?  $default,) {final _that = this;
switch (_that) {
case _SceneZoneOverlay() when $default != null:
return $default(_that.id,_that.label,_that.x,_that.y,_that.width,_that.height,_that.pattern,_that.visualState,_that.opacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneZoneOverlay implements SceneZoneOverlay {
  const _SceneZoneOverlay({required this.id, required this.label, required this.x, required this.y, required this.width, required this.height, this.pattern = ZonePattern.solid, this.visualState = NodeVisualState.normal, this.opacity = 1});
  factory _SceneZoneOverlay.fromJson(Map<String, dynamic> json) => _$SceneZoneOverlayFromJson(json);

@override final  String id;
@override final  String label;
@override final  double x;
@override final  double y;
@override final  double width;
@override final  double height;
@override@JsonKey() final  ZonePattern pattern;
@override@JsonKey() final  NodeVisualState visualState;
@override@JsonKey() final  double opacity;

/// Create a copy of SceneZoneOverlay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneZoneOverlayCopyWith<_SceneZoneOverlay> get copyWith => __$SceneZoneOverlayCopyWithImpl<_SceneZoneOverlay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneZoneOverlayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneZoneOverlay&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.visualState, visualState) || other.visualState == visualState)&&(identical(other.opacity, opacity) || other.opacity == opacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,x,y,width,height,pattern,visualState,opacity);
}

@override
String toString() {
    return 'SceneZoneOverlay(id: $id, label: $label, x: $x, y: $y, width: $width, height: $height, pattern: $pattern, visualState: $visualState, opacity: $opacity)';
}


}

/// @nodoc
abstract mixin class _$SceneZoneOverlayCopyWith<$Res> implements $SceneZoneOverlayCopyWith<$Res> {
  factory _$SceneZoneOverlayCopyWith(_SceneZoneOverlay value, $Res Function(_SceneZoneOverlay) _then) = __$SceneZoneOverlayCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, double x, double y, double width, double height, ZonePattern pattern, NodeVisualState visualState, double opacity
});




}
/// @nodoc
class __$SceneZoneOverlayCopyWithImpl<$Res>
    implements _$SceneZoneOverlayCopyWith<$Res> {
  __$SceneZoneOverlayCopyWithImpl(this._self, this._then);

  final _SceneZoneOverlay _self;
  final $Res Function(_SceneZoneOverlay) _then;

/// Create a copy of SceneZoneOverlay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? pattern = null,Object? visualState = null,Object? opacity = null,}) {
  return _then(_SceneZoneOverlay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as ZonePattern,visualState: null == visualState ? _self.visualState : visualState // ignore: cast_nullable_to_non_nullable
as NodeVisualState,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ComplexityMetrics {

 int get comparisons; int get moves; int get reads; int get writes; int get allocations; int get auxiliarySpace; int get peakAuxiliarySpace; int get callDepth; int get maxCallDepth; Map<String, int> get statementCounts;
/// Create a copy of ComplexityMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplexityMetricsCopyWith<ComplexityMetrics> get copyWith => _$ComplexityMetricsCopyWithImpl<ComplexityMetrics>(this as ComplexityMetrics, _$identity);

  /// Serializes this ComplexityMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComplexityMetrics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplexityMetrics&&(identical(other.comparisons, _this.comparisons) || other.comparisons == _this.comparisons)&&(identical(other.moves, _this.moves) || other.moves == _this.moves)&&(identical(other.reads, _this.reads) || other.reads == _this.reads)&&(identical(other.writes, _this.writes) || other.writes == _this.writes)&&(identical(other.allocations, _this.allocations) || other.allocations == _this.allocations)&&(identical(other.auxiliarySpace, _this.auxiliarySpace) || other.auxiliarySpace == _this.auxiliarySpace)&&(identical(other.peakAuxiliarySpace, _this.peakAuxiliarySpace) || other.peakAuxiliarySpace == _this.peakAuxiliarySpace)&&(identical(other.callDepth, _this.callDepth) || other.callDepth == _this.callDepth)&&(identical(other.maxCallDepth, _this.maxCallDepth) || other.maxCallDepth == _this.maxCallDepth)&&const DeepCollectionEquality().equals(other.statementCounts, _this.statementCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComplexityMetrics;
  return Object.hash(runtimeType,_this.comparisons,_this.moves,_this.reads,_this.writes,_this.allocations,_this.auxiliarySpace,_this.peakAuxiliarySpace,_this.callDepth,_this.maxCallDepth,const DeepCollectionEquality().hash(_this.statementCounts));
}

@override
String toString() {
  final _this = this as ComplexityMetrics;
  return 'ComplexityMetrics(comparisons: ${_this.comparisons}, moves: ${_this.moves}, reads: ${_this.reads}, writes: ${_this.writes}, allocations: ${_this.allocations}, auxiliarySpace: ${_this.auxiliarySpace}, peakAuxiliarySpace: ${_this.peakAuxiliarySpace}, callDepth: ${_this.callDepth}, maxCallDepth: ${_this.maxCallDepth}, statementCounts: ${_this.statementCounts})';
}


}

/// @nodoc
abstract mixin class $ComplexityMetricsCopyWith<$Res>  {
  factory $ComplexityMetricsCopyWith(ComplexityMetrics value, $Res Function(ComplexityMetrics) _then) = _$ComplexityMetricsCopyWithImpl;
@useResult
$Res call({
 int comparisons, int moves, int reads, int writes, int allocations, int auxiliarySpace, int peakAuxiliarySpace, int callDepth, int maxCallDepth, Map<String, int> statementCounts
});




}
/// @nodoc
class _$ComplexityMetricsCopyWithImpl<$Res>
    implements $ComplexityMetricsCopyWith<$Res> {
  _$ComplexityMetricsCopyWithImpl(this._self, this._then);

  final ComplexityMetrics _self;
  final $Res Function(ComplexityMetrics) _then;

/// Create a copy of ComplexityMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? comparisons = null,Object? moves = null,Object? reads = null,Object? writes = null,Object? allocations = null,Object? auxiliarySpace = null,Object? peakAuxiliarySpace = null,Object? callDepth = null,Object? maxCallDepth = null,Object? statementCounts = null,}) {
  return _then(ComplexityMetrics(
comparisons: null == comparisons ? _self.comparisons : comparisons // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,writes: null == writes ? _self.writes : writes // ignore: cast_nullable_to_non_nullable
as int,allocations: null == allocations ? _self.allocations : allocations // ignore: cast_nullable_to_non_nullable
as int,auxiliarySpace: null == auxiliarySpace ? _self.auxiliarySpace : auxiliarySpace // ignore: cast_nullable_to_non_nullable
as int,peakAuxiliarySpace: null == peakAuxiliarySpace ? _self.peakAuxiliarySpace : peakAuxiliarySpace // ignore: cast_nullable_to_non_nullable
as int,callDepth: null == callDepth ? _self.callDepth : callDepth // ignore: cast_nullable_to_non_nullable
as int,maxCallDepth: null == maxCallDepth ? _self.maxCallDepth : maxCallDepth // ignore: cast_nullable_to_non_nullable
as int,statementCounts: null == statementCounts ? _self.statementCounts : statementCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplexityMetrics].
extension ComplexityMetricsPatterns on ComplexityMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplexityMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplexityMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplexityMetrics value)  $default,){
final _that = this;
switch (_that) {
case _ComplexityMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplexityMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _ComplexityMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int comparisons,  int moves,  int reads,  int writes,  int allocations,  int auxiliarySpace,  int peakAuxiliarySpace,  int callDepth,  int maxCallDepth,  Map<String, int> statementCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplexityMetrics() when $default != null:
return $default(_that.comparisons,_that.moves,_that.reads,_that.writes,_that.allocations,_that.auxiliarySpace,_that.peakAuxiliarySpace,_that.callDepth,_that.maxCallDepth,_that.statementCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int comparisons,  int moves,  int reads,  int writes,  int allocations,  int auxiliarySpace,  int peakAuxiliarySpace,  int callDepth,  int maxCallDepth,  Map<String, int> statementCounts)  $default,) {final _that = this;
switch (_that) {
case _ComplexityMetrics():
return $default(_that.comparisons,_that.moves,_that.reads,_that.writes,_that.allocations,_that.auxiliarySpace,_that.peakAuxiliarySpace,_that.callDepth,_that.maxCallDepth,_that.statementCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int comparisons,  int moves,  int reads,  int writes,  int allocations,  int auxiliarySpace,  int peakAuxiliarySpace,  int callDepth,  int maxCallDepth,  Map<String, int> statementCounts)?  $default,) {final _that = this;
switch (_that) {
case _ComplexityMetrics() when $default != null:
return $default(_that.comparisons,_that.moves,_that.reads,_that.writes,_that.allocations,_that.auxiliarySpace,_that.peakAuxiliarySpace,_that.callDepth,_that.maxCallDepth,_that.statementCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplexityMetrics implements ComplexityMetrics {
  const _ComplexityMetrics({this.comparisons = 0, this.moves = 0, this.reads = 0, this.writes = 0, this.allocations = 0, this.auxiliarySpace = 0, this.peakAuxiliarySpace = 0, this.callDepth = 0, this.maxCallDepth = 0,  Map<String, int> statementCounts = const {}}): _statementCounts = statementCounts;
  factory _ComplexityMetrics.fromJson(Map<String, dynamic> json) => _$ComplexityMetricsFromJson(json);

@override@JsonKey() final  int comparisons;
@override@JsonKey() final  int moves;
@override@JsonKey() final  int reads;
@override@JsonKey() final  int writes;
@override@JsonKey() final  int allocations;
@override@JsonKey() final  int auxiliarySpace;
@override@JsonKey() final  int peakAuxiliarySpace;
@override@JsonKey() final  int callDepth;
@override@JsonKey() final  int maxCallDepth;
 final  Map<String, int> _statementCounts;
@override@JsonKey() Map<String, int> get statementCounts {
  if (_statementCounts is EqualUnmodifiableMapView) return _statementCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_statementCounts);
}


/// Create a copy of ComplexityMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplexityMetricsCopyWith<_ComplexityMetrics> get copyWith => __$ComplexityMetricsCopyWithImpl<_ComplexityMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplexityMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplexityMetrics&&(identical(other.comparisons, comparisons) || other.comparisons == comparisons)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.reads, reads) || other.reads == reads)&&(identical(other.writes, writes) || other.writes == writes)&&(identical(other.allocations, allocations) || other.allocations == allocations)&&(identical(other.auxiliarySpace, auxiliarySpace) || other.auxiliarySpace == auxiliarySpace)&&(identical(other.peakAuxiliarySpace, peakAuxiliarySpace) || other.peakAuxiliarySpace == peakAuxiliarySpace)&&(identical(other.callDepth, callDepth) || other.callDepth == callDepth)&&(identical(other.maxCallDepth, maxCallDepth) || other.maxCallDepth == maxCallDepth)&&const DeepCollectionEquality().equals(other.statementCounts, _statementCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,comparisons,moves,reads,writes,allocations,auxiliarySpace,peakAuxiliarySpace,callDepth,maxCallDepth,const DeepCollectionEquality().hash(_statementCounts));
}

@override
String toString() {
    return 'ComplexityMetrics(comparisons: $comparisons, moves: $moves, reads: $reads, writes: $writes, allocations: $allocations, auxiliarySpace: $auxiliarySpace, peakAuxiliarySpace: $peakAuxiliarySpace, callDepth: $callDepth, maxCallDepth: $maxCallDepth, statementCounts: $statementCounts)';
}


}

/// @nodoc
abstract mixin class _$ComplexityMetricsCopyWith<$Res> implements $ComplexityMetricsCopyWith<$Res> {
  factory _$ComplexityMetricsCopyWith(_ComplexityMetrics value, $Res Function(_ComplexityMetrics) _then) = __$ComplexityMetricsCopyWithImpl;
@override @useResult
$Res call({
 int comparisons, int moves, int reads, int writes, int allocations, int auxiliarySpace, int peakAuxiliarySpace, int callDepth, int maxCallDepth, Map<String, int> statementCounts
});




}
/// @nodoc
class __$ComplexityMetricsCopyWithImpl<$Res>
    implements _$ComplexityMetricsCopyWith<$Res> {
  __$ComplexityMetricsCopyWithImpl(this._self, this._then);

  final _ComplexityMetrics _self;
  final $Res Function(_ComplexityMetrics) _then;

/// Create a copy of ComplexityMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? comparisons = null,Object? moves = null,Object? reads = null,Object? writes = null,Object? allocations = null,Object? auxiliarySpace = null,Object? peakAuxiliarySpace = null,Object? callDepth = null,Object? maxCallDepth = null,Object? statementCounts = null,}) {
  return _then(_ComplexityMetrics(
comparisons: null == comparisons ? _self.comparisons : comparisons // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,writes: null == writes ? _self.writes : writes // ignore: cast_nullable_to_non_nullable
as int,allocations: null == allocations ? _self.allocations : allocations // ignore: cast_nullable_to_non_nullable
as int,auxiliarySpace: null == auxiliarySpace ? _self.auxiliarySpace : auxiliarySpace // ignore: cast_nullable_to_non_nullable
as int,peakAuxiliarySpace: null == peakAuxiliarySpace ? _self.peakAuxiliarySpace : peakAuxiliarySpace // ignore: cast_nullable_to_non_nullable
as int,callDepth: null == callDepth ? _self.callDepth : callDepth // ignore: cast_nullable_to_non_nullable
as int,maxCallDepth: null == maxCallDepth ? _self.maxCallDepth : maxCallDepth // ignore: cast_nullable_to_non_nullable
as int,statementCounts: null == statementCounts ? _self._statementCounts : statementCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
