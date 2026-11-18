import 'package:freezed_annotation/freezed_annotation.dart';
import '../enum/ds_enums.dart';
part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
abstract class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    @Default(ColorStyle.textbookDualTone) ColorStyle palette,
    @Default(AppearanceMode.system) AppearanceMode mode,
    @Default(false) bool pureBlack,
    @Default(false) bool translucentSidebar,
  }) = _ThemeProps;
  factory ThemeProps.fromJson(Map<String, dynamic> json) =>
      _$ThemePropsFromJson(json);
}

@freezed
abstract class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(1360) double width,
    @Default(860) double height,
    @Default(false) bool maximized,
  }) = _WindowProps;
  factory WindowProps.fromJson(Map<String, dynamic> json) =>
      _$WindowPropsFromJson(json);
}

@freezed
abstract class LabPrefs with _$LabPrefs {
  const factory LabPrefs({
    @Default(CodeLang.cLike) CodeLang codeLang,
    @Default(1) double playbackSpeed,
    @Default(ViewDensity.comfortable) ViewDensity density,
  }) = _LabPrefs;
  factory LabPrefs.fromJson(Map<String, dynamic> json) =>
      _$LabPrefsFromJson(json);
}
