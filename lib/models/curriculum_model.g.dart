// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChapterMeta _$ChapterMetaFromJson(Map<String, dynamic> json) => _ChapterMeta(
  id: $enumDecode(_$ChapterIdEnumMap, json['id']),
  title: json['title'] as String,
  summary: json['summary'] as String,
  moduleIds:
      (json['moduleIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ChapterMetaToJson(_ChapterMeta instance) =>
    <String, dynamic>{
      'id': _$ChapterIdEnumMap[instance.id]!,
      'title': instance.title,
      'summary': instance.summary,
      'moduleIds': instance.moduleIds,
    };

const _$ChapterIdEnumMap = {
  ChapterId.ch1: 'ch1',
  ChapterId.ch2: 'ch2',
  ChapterId.ch3: 'ch3',
  ChapterId.ch4: 'ch4',
  ChapterId.ch5: 'ch5',
  ChapterId.ch6: 'ch6',
  ChapterId.ch7: 'ch7',
  ChapterId.ch8: 'ch8',
};

_ComplexitySpec _$ComplexitySpecFromJson(Map<String, dynamic> json) =>
    _ComplexitySpec(
      time: json['time'] as String,
      space: json['space'] as String,
      bestTime: json['bestTime'] as String?,
      worstTime: json['worstTime'] as String?,
    );

Map<String, dynamic> _$ComplexitySpecToJson(_ComplexitySpec instance) =>
    <String, dynamic>{
      'time': instance.time,
      'space': instance.space,
      'bestTime': instance.bestTime,
      'worstTime': instance.worstTime,
    };

_AlgorithmMeta _$AlgorithmMetaFromJson(Map<String, dynamic> json) =>
    _AlgorithmMeta(
      id: json['id'] as String,
      chapterId: $enumDecode(_$ChapterIdEnumMap, json['chapterId']),
      title: json['title'] as String,
      complexity: ComplexitySpec.fromJson(
        json['complexity'] as Map<String, dynamic>,
      ),
      textbookReferences:
          (json['textbookReferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AlgorithmMetaToJson(_AlgorithmMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterId': _$ChapterIdEnumMap[instance.chapterId]!,
      'title': instance.title,
      'complexity': instance.complexity,
      'textbookReferences': instance.textbookReferences,
    };

_PresetDataset _$PresetDatasetFromJson(Map<String, dynamic> json) =>
    _PresetDataset(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      name: json['name'] as String,
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PresetDatasetToJson(_PresetDataset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'name': instance.name,
      'payload': instance.payload,
    };
