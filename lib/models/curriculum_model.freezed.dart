// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChapterMeta {

 ChapterId get id; String get title; String get summary; List<String> get moduleIds;
/// Create a copy of ChapterMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterMetaCopyWith<ChapterMeta> get copyWith => _$ChapterMetaCopyWithImpl<ChapterMeta>(this as ChapterMeta, _$identity);

  /// Serializes this ChapterMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChapterMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterMeta&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.moduleIds, _this.moduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChapterMeta;
  return Object.hash(runtimeType,_this.id,_this.title,_this.summary,const DeepCollectionEquality().hash(_this.moduleIds));
}

@override
String toString() {
  final _this = this as ChapterMeta;
  return 'ChapterMeta(id: ${_this.id}, title: ${_this.title}, summary: ${_this.summary}, moduleIds: ${_this.moduleIds})';
}


}

/// @nodoc
abstract mixin class $ChapterMetaCopyWith<$Res>  {
  factory $ChapterMetaCopyWith(ChapterMeta value, $Res Function(ChapterMeta) _then) = _$ChapterMetaCopyWithImpl;
@useResult
$Res call({
 ChapterId id, String title, String summary, List<String> moduleIds
});




}
/// @nodoc
class _$ChapterMetaCopyWithImpl<$Res>
    implements $ChapterMetaCopyWith<$Res> {
  _$ChapterMetaCopyWithImpl(this._self, this._then);

  final ChapterMeta _self;
  final $Res Function(ChapterMeta) _then;

/// Create a copy of ChapterMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? summary = null,Object? moduleIds = null,}) {
  return _then(ChapterMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChapterId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,moduleIds: null == moduleIds ? _self.moduleIds : moduleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterMeta].
extension ChapterMetaPatterns on ChapterMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterMeta value)  $default,){
final _that = this;
switch (_that) {
case _ChapterMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterMeta value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChapterId id,  String title,  String summary,  List<String> moduleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterMeta() when $default != null:
return $default(_that.id,_that.title,_that.summary,_that.moduleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChapterId id,  String title,  String summary,  List<String> moduleIds)  $default,) {final _that = this;
switch (_that) {
case _ChapterMeta():
return $default(_that.id,_that.title,_that.summary,_that.moduleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChapterId id,  String title,  String summary,  List<String> moduleIds)?  $default,) {final _that = this;
switch (_that) {
case _ChapterMeta() when $default != null:
return $default(_that.id,_that.title,_that.summary,_that.moduleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChapterMeta implements ChapterMeta {
  const _ChapterMeta({required this.id, required this.title, required this.summary,  List<String> moduleIds = const []}): _moduleIds = moduleIds;
  factory _ChapterMeta.fromJson(Map<String, dynamic> json) => _$ChapterMetaFromJson(json);

@override final  ChapterId id;
@override final  String title;
@override final  String summary;
 final  List<String> _moduleIds;
@override@JsonKey() List<String> get moduleIds {
  if (_moduleIds is EqualUnmodifiableListView) return _moduleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moduleIds);
}


/// Create a copy of ChapterMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterMetaCopyWith<_ChapterMeta> get copyWith => __$ChapterMetaCopyWithImpl<_ChapterMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChapterMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.moduleIds, _moduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,summary,const DeepCollectionEquality().hash(_moduleIds));
}

@override
String toString() {
    return 'ChapterMeta(id: $id, title: $title, summary: $summary, moduleIds: $moduleIds)';
}


}

/// @nodoc
abstract mixin class _$ChapterMetaCopyWith<$Res> implements $ChapterMetaCopyWith<$Res> {
  factory _$ChapterMetaCopyWith(_ChapterMeta value, $Res Function(_ChapterMeta) _then) = __$ChapterMetaCopyWithImpl;
@override @useResult
$Res call({
 ChapterId id, String title, String summary, List<String> moduleIds
});




}
/// @nodoc
class __$ChapterMetaCopyWithImpl<$Res>
    implements _$ChapterMetaCopyWith<$Res> {
  __$ChapterMetaCopyWithImpl(this._self, this._then);

  final _ChapterMeta _self;
  final $Res Function(_ChapterMeta) _then;

/// Create a copy of ChapterMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? summary = null,Object? moduleIds = null,}) {
  return _then(_ChapterMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChapterId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,moduleIds: null == moduleIds ? _self._moduleIds : moduleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ComplexitySpec {

 String get time; String get space; String? get bestTime; String? get worstTime;
/// Create a copy of ComplexitySpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplexitySpecCopyWith<ComplexitySpec> get copyWith => _$ComplexitySpecCopyWithImpl<ComplexitySpec>(this as ComplexitySpec, _$identity);

  /// Serializes this ComplexitySpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComplexitySpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplexitySpec&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.space, _this.space) || other.space == _this.space)&&(identical(other.bestTime, _this.bestTime) || other.bestTime == _this.bestTime)&&(identical(other.worstTime, _this.worstTime) || other.worstTime == _this.worstTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComplexitySpec;
  return Object.hash(runtimeType,_this.time,_this.space,_this.bestTime,_this.worstTime);
}

@override
String toString() {
  final _this = this as ComplexitySpec;
  return 'ComplexitySpec(time: ${_this.time}, space: ${_this.space}, bestTime: ${_this.bestTime}, worstTime: ${_this.worstTime})';
}


}

/// @nodoc
abstract mixin class $ComplexitySpecCopyWith<$Res>  {
  factory $ComplexitySpecCopyWith(ComplexitySpec value, $Res Function(ComplexitySpec) _then) = _$ComplexitySpecCopyWithImpl;
@useResult
$Res call({
 String time, String space, String? bestTime, String? worstTime
});




}
/// @nodoc
class _$ComplexitySpecCopyWithImpl<$Res>
    implements $ComplexitySpecCopyWith<$Res> {
  _$ComplexitySpecCopyWithImpl(this._self, this._then);

  final ComplexitySpec _self;
  final $Res Function(ComplexitySpec) _then;

/// Create a copy of ComplexitySpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? space = null,Object? bestTime = freezed,Object? worstTime = freezed,}) {
  return _then(ComplexitySpec(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as String,bestTime: freezed == bestTime ? _self.bestTime : bestTime // ignore: cast_nullable_to_non_nullable
as String?,worstTime: freezed == worstTime ? _self.worstTime : worstTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplexitySpec].
extension ComplexitySpecPatterns on ComplexitySpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplexitySpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplexitySpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplexitySpec value)  $default,){
final _that = this;
switch (_that) {
case _ComplexitySpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplexitySpec value)?  $default,){
final _that = this;
switch (_that) {
case _ComplexitySpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String time,  String space,  String? bestTime,  String? worstTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplexitySpec() when $default != null:
return $default(_that.time,_that.space,_that.bestTime,_that.worstTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String time,  String space,  String? bestTime,  String? worstTime)  $default,) {final _that = this;
switch (_that) {
case _ComplexitySpec():
return $default(_that.time,_that.space,_that.bestTime,_that.worstTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String time,  String space,  String? bestTime,  String? worstTime)?  $default,) {final _that = this;
switch (_that) {
case _ComplexitySpec() when $default != null:
return $default(_that.time,_that.space,_that.bestTime,_that.worstTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplexitySpec implements ComplexitySpec {
  const _ComplexitySpec({required this.time, required this.space, this.bestTime, this.worstTime});
  factory _ComplexitySpec.fromJson(Map<String, dynamic> json) => _$ComplexitySpecFromJson(json);

@override final  String time;
@override final  String space;
@override final  String? bestTime;
@override final  String? worstTime;

/// Create a copy of ComplexitySpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplexitySpecCopyWith<_ComplexitySpec> get copyWith => __$ComplexitySpecCopyWithImpl<_ComplexitySpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplexitySpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplexitySpec&&(identical(other.time, time) || other.time == time)&&(identical(other.space, space) || other.space == space)&&(identical(other.bestTime, bestTime) || other.bestTime == bestTime)&&(identical(other.worstTime, worstTime) || other.worstTime == worstTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,space,bestTime,worstTime);
}

@override
String toString() {
    return 'ComplexitySpec(time: $time, space: $space, bestTime: $bestTime, worstTime: $worstTime)';
}


}

/// @nodoc
abstract mixin class _$ComplexitySpecCopyWith<$Res> implements $ComplexitySpecCopyWith<$Res> {
  factory _$ComplexitySpecCopyWith(_ComplexitySpec value, $Res Function(_ComplexitySpec) _then) = __$ComplexitySpecCopyWithImpl;
@override @useResult
$Res call({
 String time, String space, String? bestTime, String? worstTime
});




}
/// @nodoc
class __$ComplexitySpecCopyWithImpl<$Res>
    implements _$ComplexitySpecCopyWith<$Res> {
  __$ComplexitySpecCopyWithImpl(this._self, this._then);

  final _ComplexitySpec _self;
  final $Res Function(_ComplexitySpec) _then;

/// Create a copy of ComplexitySpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? space = null,Object? bestTime = freezed,Object? worstTime = freezed,}) {
  return _then(_ComplexitySpec(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as String,bestTime: freezed == bestTime ? _self.bestTime : bestTime // ignore: cast_nullable_to_non_nullable
as String?,worstTime: freezed == worstTime ? _self.worstTime : worstTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AlgorithmMeta {

 String get id; ChapterId get chapterId; String get title; ComplexitySpec get complexity; List<String> get textbookReferences;
/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlgorithmMetaCopyWith<AlgorithmMeta> get copyWith => _$AlgorithmMetaCopyWithImpl<AlgorithmMeta>(this as AlgorithmMeta, _$identity);

  /// Serializes this AlgorithmMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AlgorithmMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlgorithmMeta&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.chapterId, _this.chapterId) || other.chapterId == _this.chapterId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.complexity, _this.complexity) || other.complexity == _this.complexity)&&const DeepCollectionEquality().equals(other.textbookReferences, _this.textbookReferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AlgorithmMeta;
  return Object.hash(runtimeType,_this.id,_this.chapterId,_this.title,_this.complexity,const DeepCollectionEquality().hash(_this.textbookReferences));
}

@override
String toString() {
  final _this = this as AlgorithmMeta;
  return 'AlgorithmMeta(id: ${_this.id}, chapterId: ${_this.chapterId}, title: ${_this.title}, complexity: ${_this.complexity}, textbookReferences: ${_this.textbookReferences})';
}


}

/// @nodoc
abstract mixin class $AlgorithmMetaCopyWith<$Res>  {
  factory $AlgorithmMetaCopyWith(AlgorithmMeta value, $Res Function(AlgorithmMeta) _then) = _$AlgorithmMetaCopyWithImpl;
@useResult
$Res call({
 String id, ChapterId chapterId, String title, ComplexitySpec complexity, List<String> textbookReferences
});


$ComplexitySpecCopyWith<$Res> get complexity;

}
/// @nodoc
class _$AlgorithmMetaCopyWithImpl<$Res>
    implements $AlgorithmMetaCopyWith<$Res> {
  _$AlgorithmMetaCopyWithImpl(this._self, this._then);

  final AlgorithmMeta _self;
  final $Res Function(AlgorithmMeta) _then;

/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chapterId = null,Object? title = null,Object? complexity = null,Object? textbookReferences = null,}) {
  return _then(AlgorithmMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as ChapterId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,complexity: null == complexity ? _self.complexity : complexity // ignore: cast_nullable_to_non_nullable
as ComplexitySpec,textbookReferences: null == textbookReferences ? _self.textbookReferences : textbookReferences // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplexitySpecCopyWith<$Res> get complexity {
  
  return $ComplexitySpecCopyWith<$Res>(_self.complexity, (value) {
    return _then(_self.copyWith(complexity: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlgorithmMeta].
extension AlgorithmMetaPatterns on AlgorithmMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlgorithmMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlgorithmMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlgorithmMeta value)  $default,){
final _that = this;
switch (_that) {
case _AlgorithmMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlgorithmMeta value)?  $default,){
final _that = this;
switch (_that) {
case _AlgorithmMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChapterId chapterId,  String title,  ComplexitySpec complexity,  List<String> textbookReferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlgorithmMeta() when $default != null:
return $default(_that.id,_that.chapterId,_that.title,_that.complexity,_that.textbookReferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChapterId chapterId,  String title,  ComplexitySpec complexity,  List<String> textbookReferences)  $default,) {final _that = this;
switch (_that) {
case _AlgorithmMeta():
return $default(_that.id,_that.chapterId,_that.title,_that.complexity,_that.textbookReferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChapterId chapterId,  String title,  ComplexitySpec complexity,  List<String> textbookReferences)?  $default,) {final _that = this;
switch (_that) {
case _AlgorithmMeta() when $default != null:
return $default(_that.id,_that.chapterId,_that.title,_that.complexity,_that.textbookReferences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlgorithmMeta implements AlgorithmMeta {
  const _AlgorithmMeta({required this.id, required this.chapterId, required this.title, required this.complexity,  List<String> textbookReferences = const []}): _textbookReferences = textbookReferences;
  factory _AlgorithmMeta.fromJson(Map<String, dynamic> json) => _$AlgorithmMetaFromJson(json);

@override final  String id;
@override final  ChapterId chapterId;
@override final  String title;
@override final  ComplexitySpec complexity;
 final  List<String> _textbookReferences;
@override@JsonKey() List<String> get textbookReferences {
  if (_textbookReferences is EqualUnmodifiableListView) return _textbookReferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_textbookReferences);
}


/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlgorithmMetaCopyWith<_AlgorithmMeta> get copyWith => __$AlgorithmMetaCopyWithImpl<_AlgorithmMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlgorithmMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlgorithmMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.title, title) || other.title == title)&&(identical(other.complexity, complexity) || other.complexity == complexity)&&const DeepCollectionEquality().equals(other.textbookReferences, _textbookReferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,chapterId,title,complexity,const DeepCollectionEquality().hash(_textbookReferences));
}

@override
String toString() {
    return 'AlgorithmMeta(id: $id, chapterId: $chapterId, title: $title, complexity: $complexity, textbookReferences: $textbookReferences)';
}


}

/// @nodoc
abstract mixin class _$AlgorithmMetaCopyWith<$Res> implements $AlgorithmMetaCopyWith<$Res> {
  factory _$AlgorithmMetaCopyWith(_AlgorithmMeta value, $Res Function(_AlgorithmMeta) _then) = __$AlgorithmMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, ChapterId chapterId, String title, ComplexitySpec complexity, List<String> textbookReferences
});


@override $ComplexitySpecCopyWith<$Res> get complexity;

}
/// @nodoc
class __$AlgorithmMetaCopyWithImpl<$Res>
    implements _$AlgorithmMetaCopyWith<$Res> {
  __$AlgorithmMetaCopyWithImpl(this._self, this._then);

  final _AlgorithmMeta _self;
  final $Res Function(_AlgorithmMeta) _then;

/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chapterId = null,Object? title = null,Object? complexity = null,Object? textbookReferences = null,}) {
  return _then(_AlgorithmMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as ChapterId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,complexity: null == complexity ? _self.complexity : complexity // ignore: cast_nullable_to_non_nullable
as ComplexitySpec,textbookReferences: null == textbookReferences ? _self._textbookReferences : textbookReferences // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of AlgorithmMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplexitySpecCopyWith<$Res> get complexity {
  
  return $ComplexitySpecCopyWith<$Res>(_self.complexity, (value) {
    return _then(_self.copyWith(complexity: value));
  });
}
}


/// @nodoc
mixin _$PresetDataset {

 String get id; String get moduleId; String get name; Map<String, dynamic> get payload;
/// Create a copy of PresetDataset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetDatasetCopyWith<PresetDataset> get copyWith => _$PresetDatasetCopyWithImpl<PresetDataset>(this as PresetDataset, _$identity);

  /// Serializes this PresetDataset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresetDataset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetDataset&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.moduleId, _this.moduleId) || other.moduleId == _this.moduleId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.payload, _this.payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresetDataset;
  return Object.hash(runtimeType,_this.id,_this.moduleId,_this.name,const DeepCollectionEquality().hash(_this.payload));
}

@override
String toString() {
  final _this = this as PresetDataset;
  return 'PresetDataset(id: ${_this.id}, moduleId: ${_this.moduleId}, name: ${_this.name}, payload: ${_this.payload})';
}


}

/// @nodoc
abstract mixin class $PresetDatasetCopyWith<$Res>  {
  factory $PresetDatasetCopyWith(PresetDataset value, $Res Function(PresetDataset) _then) = _$PresetDatasetCopyWithImpl;
@useResult
$Res call({
 String id, String moduleId, String name, Map<String, dynamic> payload
});




}
/// @nodoc
class _$PresetDatasetCopyWithImpl<$Res>
    implements $PresetDatasetCopyWith<$Res> {
  _$PresetDatasetCopyWithImpl(this._self, this._then);

  final PresetDataset _self;
  final $Res Function(PresetDataset) _then;

/// Create a copy of PresetDataset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? moduleId = null,Object? name = null,Object? payload = null,}) {
  return _then(PresetDataset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetDataset].
extension PresetDatasetPatterns on PresetDataset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetDataset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetDataset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetDataset value)  $default,){
final _that = this;
switch (_that) {
case _PresetDataset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetDataset value)?  $default,){
final _that = this;
switch (_that) {
case _PresetDataset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String moduleId,  String name,  Map<String, dynamic> payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetDataset() when $default != null:
return $default(_that.id,_that.moduleId,_that.name,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String moduleId,  String name,  Map<String, dynamic> payload)  $default,) {final _that = this;
switch (_that) {
case _PresetDataset():
return $default(_that.id,_that.moduleId,_that.name,_that.payload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String moduleId,  String name,  Map<String, dynamic> payload)?  $default,) {final _that = this;
switch (_that) {
case _PresetDataset() when $default != null:
return $default(_that.id,_that.moduleId,_that.name,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresetDataset implements PresetDataset {
  const _PresetDataset({required this.id, required this.moduleId, required this.name,  Map<String, dynamic> payload = const {}}): _payload = payload;
  factory _PresetDataset.fromJson(Map<String, dynamic> json) => _$PresetDatasetFromJson(json);

@override final  String id;
@override final  String moduleId;
@override final  String name;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of PresetDataset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetDatasetCopyWith<_PresetDataset> get copyWith => __$PresetDatasetCopyWithImpl<_PresetDataset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetDatasetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetDataset&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,moduleId,name,const DeepCollectionEquality().hash(_payload));
}

@override
String toString() {
    return 'PresetDataset(id: $id, moduleId: $moduleId, name: $name, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$PresetDatasetCopyWith<$Res> implements $PresetDatasetCopyWith<$Res> {
  factory _$PresetDatasetCopyWith(_PresetDataset value, $Res Function(_PresetDataset) _then) = __$PresetDatasetCopyWithImpl;
@override @useResult
$Res call({
 String id, String moduleId, String name, Map<String, dynamic> payload
});




}
/// @nodoc
class __$PresetDatasetCopyWithImpl<$Res>
    implements _$PresetDatasetCopyWith<$Res> {
  __$PresetDatasetCopyWithImpl(this._self, this._then);

  final _PresetDataset _self;
  final $Res Function(_PresetDataset) _then;

/// Create a copy of PresetDataset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? moduleId = null,Object? name = null,Object? payload = null,}) {
  return _then(_PresetDataset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
