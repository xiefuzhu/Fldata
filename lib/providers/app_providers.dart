import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../curriculum/catalog.dart';
import '../database/repositories/progress_repository.dart';
import '../database/repositories/quiz_repository.dart';
import '../database/repositories/achievement_repository.dart';
import '../database/repositories/backup_repository.dart';
import '../models/settings_model.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Preferences must be initialized before runApp'),
);
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
final progressRepositoryProvider = Provider(
  (ref) => ProgressRepository(ref.watch(databaseProvider)),
);
final quizRepositoryProvider = Provider(
  (ref) => QuizRepository(ref.watch(databaseProvider)),
);
final backupRepositoryProvider = Provider(
  (ref) => BackupRepository(ref.watch(databaseProvider)),
);
final lessonProgressProvider = StreamProvider(
  (ref) => ref.watch(progressRepositoryProvider).watchAll(),
);
final achievementRepositoryProvider = Provider(
  (ref) => AchievementRepository(ref.watch(databaseProvider)),
);
final _summaryReady = FutureProvider((ref) {
  final repo = ref.watch(quizRepositoryProvider),
      badges = ref.watch(achievementRepositoryProvider);
  return repo.db.transaction(() async {
    await repo.recomputeMastery({
      for (final chapter in chapters) chapter.id: chapter.moduleIds.length,
    });
    await badges.reconcile();
  });
});
final chapterMasteryProvider = StreamProvider((ref) async* {
  final repo = ref.watch(quizRepositoryProvider);
  await ref.watch(_summaryReady.future);
  yield* repo.watchMastery();
});
final achievementsProvider = StreamProvider((ref) async* {
  final badges = ref.watch(achievementRepositoryProvider);
  await ref.watch(_summaryReady.future);
  yield* badges.watch();
});
final dailyStatsProvider = StreamProvider(
  (ref) => ref.watch(progressRepositoryProvider).watchDays(),
);
final themeSettingsProvider = NotifierProvider<ThemeSettings, ThemeProps>(
  ThemeSettings.new,
);

class ThemeSettings extends Notifier<ThemeProps> {
  @override
  ThemeProps build() {
    final raw = ref.watch(preferencesProvider).getString('theme');
    if (raw == null) return const ThemeProps();
    try {
      return ThemeProps.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const ThemeProps();
    }
  }

  Future<void> update(ThemeProps value) async {
    final saved = await ref
        .read(preferencesProvider)
        .setString('theme', jsonEncode(value.toJson()));
    if (!saved) throw StateError('外观设置保存失败');
    state = value;
  }
}

// Shared minute tick for due-time queries and foreground lesson checkpoints.
final studyClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});
final unmasteredQuestionIdsProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(quizRepositoryProvider).watchUnmasteredIds(),
);
final dueQuestionsProvider = StreamProvider.autoDispose((ref) {
  final now = ref.watch(studyClockProvider).value ?? DateTime.now();
  return ref.watch(quizRepositoryProvider).watchDue(now);
});
