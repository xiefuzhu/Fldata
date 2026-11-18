// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeProps {

 ColorStyle get palette; AppearanceMode get mode; bool get pureBlack; bool get translucentSidebar;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.palette, _this.palette) || other.palette == _this.palette)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.pureBlack, _this.pureBlack) || other.pureBlack == _this.pureBlack)&&(identical(other.translucentSidebar, _this.translucentSidebar) || other.translucentSidebar == _this.translucentSidebar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeProps;
  return Object.hash(runtimeType,_this.palette,_this.mode,_this.pureBlack,_this.translucentSidebar);
}

@override
String toString() {
  final _this = this as ThemeProps;
  return 'ThemeProps(palette: ${_this.palette}, mode: ${_this.mode}, pureBlack: ${_this.pureBlack}, translucentSidebar: ${_this.translucentSidebar})';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 ColorStyle palette, AppearanceMode mode, bool pureBlack, bool translucentSidebar
});




}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? palette = null,Object? mode = null,Object? pureBlack = null,Object? translucentSidebar = null,}) {
  return _then(ThemeProps(
palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as ColorStyle,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppearanceMode,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,translucentSidebar: null == translucentSidebar ? _self.translucentSidebar : translucentSidebar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ColorStyle palette,  AppearanceMode mode,  bool pureBlack,  bool translucentSidebar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.palette,_that.mode,_that.pureBlack,_that.translucentSidebar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ColorStyle palette,  AppearanceMode mode,  bool pureBlack,  bool translucentSidebar)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.palette,_that.mode,_that.pureBlack,_that.translucentSidebar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ColorStyle palette,  AppearanceMode mode,  bool pureBlack,  bool translucentSidebar)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.palette,_that.mode,_that.pureBlack,_that.translucentSidebar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.palette = ColorStyle.textbookDualTone, this.mode = AppearanceMode.system, this.pureBlack = false, this.translucentSidebar = false});
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override@JsonKey() final  ColorStyle palette;
@override@JsonKey() final  AppearanceMode mode;
@override@JsonKey() final  bool pureBlack;
@override@JsonKey() final  bool translucentSidebar;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.palette, palette) || other.palette == palette)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.translucentSidebar, translucentSidebar) || other.translucentSidebar == translucentSidebar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,palette,mode,pureBlack,translucentSidebar);
}

@override
String toString() {
    return 'ThemeProps(palette: $palette, mode: $mode, pureBlack: $pureBlack, translucentSidebar: $translucentSidebar)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 ColorStyle palette, AppearanceMode mode, bool pureBlack, bool translucentSidebar
});




}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? palette = null,Object? mode = null,Object? pureBlack = null,Object? translucentSidebar = null,}) {
  return _then(_ThemeProps(
palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as ColorStyle,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppearanceMode,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,translucentSidebar: null == translucentSidebar ? _self.translucentSidebar : translucentSidebar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WindowProps {

 double get width; double get height; bool get maximized;
/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<WindowProps> get copyWith => _$WindowPropsCopyWithImpl<WindowProps>(this as WindowProps, _$identity);

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WindowProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowProps&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.maximized, _this.maximized) || other.maximized == _this.maximized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WindowProps;
  return Object.hash(runtimeType,_this.width,_this.height,_this.maximized);
}

@override
String toString() {
  final _this = this as WindowProps;
  return 'WindowProps(width: ${_this.width}, height: ${_this.height}, maximized: ${_this.maximized})';
}


}

/// @nodoc
abstract mixin class $WindowPropsCopyWith<$Res>  {
  factory $WindowPropsCopyWith(WindowProps value, $Res Function(WindowProps) _then) = _$WindowPropsCopyWithImpl;
@useResult
$Res call({
 double width, double height, bool maximized
});




}
/// @nodoc
class _$WindowPropsCopyWithImpl<$Res>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._self, this._then);

  final WindowProps _self;
  final $Res Function(WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? maximized = null,}) {
  return _then(WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,maximized: null == maximized ? _self.maximized : maximized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowProps].
extension WindowPropsPatterns on WindowProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowProps value)  $default,){
final _that = this;
switch (_that) {
case _WindowProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowProps value)?  $default,){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  bool maximized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.maximized);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  bool maximized)  $default,) {final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that.width,_that.height,_that.maximized);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  bool maximized)?  $default,) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.maximized);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowProps implements WindowProps {
  const _WindowProps({this.width = 1360, this.height = 860, this.maximized = false});
  factory _WindowProps.fromJson(Map<String, dynamic> json) => _$WindowPropsFromJson(json);

@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override@JsonKey() final  bool maximized;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPropsCopyWith<_WindowProps> get copyWith => __$WindowPropsCopyWithImpl<_WindowProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.maximized, maximized) || other.maximized == maximized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height,maximized);
}

@override
String toString() {
    return 'WindowProps(width: $width, height: $height, maximized: $maximized)';
}


}

/// @nodoc
abstract mixin class _$WindowPropsCopyWith<$Res> implements $WindowPropsCopyWith<$Res> {
  factory _$WindowPropsCopyWith(_WindowProps value, $Res Function(_WindowProps) _then) = __$WindowPropsCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, bool maximized
});




}
/// @nodoc
class __$WindowPropsCopyWithImpl<$Res>
    implements _$WindowPropsCopyWith<$Res> {
  __$WindowPropsCopyWithImpl(this._self, this._then);

  final _WindowProps _self;
  final $Res Function(_WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? maximized = null,}) {
  return _then(_WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,maximized: null == maximized ? _self.maximized : maximized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LabPrefs {

 CodeLang get codeLang; double get playbackSpeed; ViewDensity get density;
/// Create a copy of LabPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabPrefsCopyWith<LabPrefs> get copyWith => _$LabPrefsCopyWithImpl<LabPrefs>(this as LabPrefs, _$identity);

  /// Serializes this LabPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LabPrefs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabPrefs&&(identical(other.codeLang, _this.codeLang) || other.codeLang == _this.codeLang)&&(identical(other.playbackSpeed, _this.playbackSpeed) || other.playbackSpeed == _this.playbackSpeed)&&(identical(other.density, _this.density) || other.density == _this.density));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LabPrefs;
  return Object.hash(runtimeType,_this.codeLang,_this.playbackSpeed,_this.density);
}

@override
String toString() {
  final _this = this as LabPrefs;
  return 'LabPrefs(codeLang: ${_this.codeLang}, playbackSpeed: ${_this.playbackSpeed}, density: ${_this.density})';
}


}

/// @nodoc
abstract mixin class $LabPrefsCopyWith<$Res>  {
  factory $LabPrefsCopyWith(LabPrefs value, $Res Function(LabPrefs) _then) = _$LabPrefsCopyWithImpl;
@useResult
$Res call({
 CodeLang codeLang, double playbackSpeed, ViewDensity density
});




}
/// @nodoc
class _$LabPrefsCopyWithImpl<$Res>
    implements $LabPrefsCopyWith<$Res> {
  _$LabPrefsCopyWithImpl(this._self, this._then);

  final LabPrefs _self;
  final $Res Function(LabPrefs) _then;

/// Create a copy of LabPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codeLang = null,Object? playbackSpeed = null,Object? density = null,}) {
  return _then(LabPrefs(
codeLang: null == codeLang ? _self.codeLang : codeLang // ignore: cast_nullable_to_non_nullable
as CodeLang,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as ViewDensity,
  ));
}

}


/// Adds pattern-matching-related methods to [LabPrefs].
extension LabPrefsPatterns on LabPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabPrefs value)  $default,){
final _that = this;
switch (_that) {
case _LabPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _LabPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CodeLang codeLang,  double playbackSpeed,  ViewDensity density)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabPrefs() when $default != null:
return $default(_that.codeLang,_that.playbackSpeed,_that.density);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CodeLang codeLang,  double playbackSpeed,  ViewDensity density)  $default,) {final _that = this;
switch (_that) {
case _LabPrefs():
return $default(_that.codeLang,_that.playbackSpeed,_that.density);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CodeLang codeLang,  double playbackSpeed,  ViewDensity density)?  $default,) {final _that = this;
switch (_that) {
case _LabPrefs() when $default != null:
return $default(_that.codeLang,_that.playbackSpeed,_that.density);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabPrefs implements LabPrefs {
  const _LabPrefs({this.codeLang = CodeLang.cLike, this.playbackSpeed = 1, this.density = ViewDensity.comfortable});
  factory _LabPrefs.fromJson(Map<String, dynamic> json) => _$LabPrefsFromJson(json);

@override@JsonKey() final  CodeLang codeLang;
@override@JsonKey() final  double playbackSpeed;
@override@JsonKey() final  ViewDensity density;

/// Create a copy of LabPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabPrefsCopyWith<_LabPrefs> get copyWith => __$LabPrefsCopyWithImpl<_LabPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabPrefs&&(identical(other.codeLang, codeLang) || other.codeLang == codeLang)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed)&&(identical(other.density, density) || other.density == density));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,codeLang,playbackSpeed,density);
}

@override
String toString() {
    return 'LabPrefs(codeLang: $codeLang, playbackSpeed: $playbackSpeed, density: $density)';
}


}

/// @nodoc
abstract mixin class _$LabPrefsCopyWith<$Res> implements $LabPrefsCopyWith<$Res> {
  factory _$LabPrefsCopyWith(_LabPrefs value, $Res Function(_LabPrefs) _then) = __$LabPrefsCopyWithImpl;
@override @useResult
$Res call({
 CodeLang codeLang, double playbackSpeed, ViewDensity density
});




}
/// @nodoc
class __$LabPrefsCopyWithImpl<$Res>
    implements _$LabPrefsCopyWith<$Res> {
  __$LabPrefsCopyWithImpl(this._self, this._then);

  final _LabPrefs _self;
  final $Res Function(_LabPrefs) _then;

/// Create a copy of LabPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codeLang = null,Object? playbackSpeed = null,Object? density = null,}) {
  return _then(_LabPrefs(
codeLang: null == codeLang ? _self.codeLang : codeLang // ignore: cast_nullable_to_non_nullable
as CodeLang,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as ViewDensity,
  ));
}


}

// dart format on
