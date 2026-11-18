// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) => _ThemeProps(
  palette:
      $enumDecodeNullable(_$ColorStyleEnumMap, json['palette']) ??
      ColorStyle.textbookDualTone,
  mode:
      $enumDecodeNullable(_$AppearanceModeEnumMap, json['mode']) ??
      AppearanceMode.system,
  pureBlack: json['pureBlack'] as bool? ?? false,
  translucentSidebar: json['translucentSidebar'] as bool? ?? false,
);

Map<String, dynamic> _$ThemePropsToJson(_ThemeProps instance) =>
    <String, dynamic>{
      'palette': _$ColorStyleEnumMap[instance.palette]!,
      'mode': _$AppearanceModeEnumMap[instance.mode]!,
      'pureBlack': instance.pureBlack,
      'translucentSidebar': instance.translucentSidebar,
    };

const _$ColorStyleEnumMap = {
  ColorStyle.systemDynamic: 'systemDynamic',
  ColorStyle.textbookDualTone: 'textbookDualTone',
  ColorStyle.clashBlue: 'clashBlue',
  ColorStyle.violetExpressive: 'violetExpressive',
  ColorStyle.emeraldForest: 'emeraldForest',
  ColorStyle.amberGold: 'amberGold',
  ColorStyle.roseCrimson: 'roseCrimson',
  ColorStyle.monochrome: 'monochrome',
};

const _$AppearanceModeEnumMap = {
  AppearanceMode.system: 'system',
  AppearanceMode.light: 'light',
  AppearanceMode.dark: 'dark',
};

_WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) => _WindowProps(
  width: (json['width'] as num?)?.toDouble() ?? 1360,
  height: (json['height'] as num?)?.toDouble() ?? 860,
  maximized: json['maximized'] as bool? ?? false,
);

Map<String, dynamic> _$WindowPropsToJson(_WindowProps instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'maximized': instance.maximized,
    };

_LabPrefs _$LabPrefsFromJson(Map<String, dynamic> json) => _LabPrefs(
  codeLang:
      $enumDecodeNullable(_$CodeLangEnumMap, json['codeLang']) ??
      CodeLang.cLike,
  playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1,
  density:
      $enumDecodeNullable(_$ViewDensityEnumMap, json['density']) ??
      ViewDensity.comfortable,
);

Map<String, dynamic> _$LabPrefsToJson(_LabPrefs instance) => <String, dynamic>{
  'codeLang': _$CodeLangEnumMap[instance.codeLang]!,
  'playbackSpeed': instance.playbackSpeed,
  'density': _$ViewDensityEnumMap[instance.density]!,
};

const _$CodeLangEnumMap = {
  CodeLang.cLike: 'cLike',
  CodeLang.c99: 'c99',
  CodeLang.dart: 'dart',
};

const _$ViewDensityEnumMap = {
  ViewDensity.comfortable: 'comfortable',
  ViewDensity.compact: 'compact',
};
