import 'package:freezed_annotation/freezed_annotation.dart';
import '../enum/ds_enums.dart';
part 'curriculum_model.freezed.dart';
part 'curriculum_model.g.dart';

@freezed
abstract class ChapterMeta with _$ChapterMeta {
  const factory ChapterMeta({
    required ChapterId id,
    required String title,
    required String summary,
    @Default([]) List<String> moduleIds,
  }) = _ChapterMeta;
  factory ChapterMeta.fromJson(Map<String, dynamic> json) =>
      _$ChapterMetaFromJson(json);
}

@freezed
abstract class ComplexitySpec with _$ComplexitySpec {
  const factory ComplexitySpec({
    required String time,
    required String space,
    String? bestTime,
    String? worstTime,
  }) = _ComplexitySpec;
  factory ComplexitySpec.fromJson(Map<String, dynamic> json) =>
      _$ComplexitySpecFromJson(json);
}

@freezed
abstract class AlgorithmMeta with _$AlgorithmMeta {
  const factory AlgorithmMeta({
    required String id,
    required ChapterId chapterId,
    required String title,
    required ComplexitySpec complexity,
    @Default([]) List<String> textbookReferences,
  }) = _AlgorithmMeta;
  factory AlgorithmMeta.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmMetaFromJson(json);
}

@freezed
abstract class PresetDataset with _$PresetDataset {
  const factory PresetDataset({
    required String id,
    required String moduleId,
    required String name,
    @Default({}) Map<String, dynamic> payload,
  }) = _PresetDataset;
  factory PresetDataset.fromJson(Map<String, dynamic> json) =>
      _$PresetDatasetFromJson(json);
}
