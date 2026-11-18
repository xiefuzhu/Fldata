import '../../models/trace_model.dart';

class ValidationResult<T extends Object> {
  const ValidationResult.success(T input) : value = input, error = null;
  const ValidationResult.failure(String message)
    : value = null,
      error = message;
  final T? value;
  final String? error;
  bool get isValid => error == null;
}

/// Typed execution inputs are separate from JSON-backed saved PresetDataset rows.
class AlgorithmPreset<T extends Object> {
  const AlgorithmPreset({
    required this.id,
    required this.name,
    required this.input,
  });
  final String id;
  final String name;
  final T input;
}

abstract interface class AlgorithmModule<T extends Object> {
  String get id;
  ValidationResult<T> validateInput(String raw);
  List<AlgorithmPreset<T>> get presets;
  TraceTimeline generateTrace(T input);
}
