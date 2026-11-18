import 'dart:math' as math;

double lerpAngle(double from, double to, double t) =>
    from + ((to - from + math.pi) % (2 * math.pi) - math.pi) * t;

/// SM-2 interval calculation. Quality is an explicit 0..5 recall grade.
({int repetitions, int intervalDays, double easinessFactor}) scheduleReview({
  required int quality,
  required int repetitions,
  required int intervalDays,
  required double easinessFactor,
}) {
  if (quality < 0 || quality > 5) {
    throw ArgumentError.value(quality, 'quality', 'Must be 0..5');
  }
  final nextInterval = quality < 3
      ? 1
      : switch (repetitions) {
          0 => 1,
          1 => 6,
          _ => (intervalDays * easinessFactor).round(),
        };
  final delta = 5 - quality;
  return (
    repetitions: quality < 3 ? 0 : repetitions + 1,
    intervalDays: nextInterval,
    easinessFactor: math.max(
      1.3,
      quality < 3
          ? easinessFactor - 0.2
          : easinessFactor + 0.1 - delta * (0.08 + delta * 0.02),
    ),
  );
}

String localDateKey(DateTime date) {
  final local = date.toLocal();
  return [
    local.year.toString(),
    local.month.toString().padLeft(2, '0'),
    local.day.toString().padLeft(2, '0'),
  ].join('-');
}
