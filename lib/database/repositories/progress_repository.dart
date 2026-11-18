import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../../common/math_utils.dart';
import '../../enum/ds_enums.dart';
import '../app_database.dart';
import 'quiz_repository.dart';
import 'achievement_repository.dart';
import '../../models/study_badge.dart';
import '../../common/study_days.dart';

class ProgressRepository {
  ProgressRepository(this.db);
  final AppDatabase db;
  Stream<List<LessonProgress>> watchAll() =>
      db.select(db.lessonProgressTable).watch();
  Stream<List<DailyStudyStats>> watchDays() =>
      db.select(db.dailyStudyStatsTable).watch();

  /// Adds only elapsed time from this visit, never a cumulative timer value.
  Future<void> recordVisit({
    required String moduleId,
    required ChapterId chapterId,
    required int elapsedSeconds,
    bool watchedFullTrace = false,
    bool customRun = false,
    int additionalCustomRuns = 0,
    bool completed = false,
    DateTime? at,
  }) async {
    if (additionalCustomRuns < 0) {
      throw ArgumentError.value(additionalCustomRuns);
    }
    final customCount = additionalCustomRuns + (customRun ? 1 : 0);
    if (elapsedSeconds < 0) {
      throw ArgumentError.value(elapsedSeconds, 'elapsedSeconds');
    }
    final now = at ?? DateTime.now();
    await db.transaction(() async {
      final existing = await (db.select(
        db.lessonProgressTable,
      )..where((t) => t.moduleId.equals(moduleId))).getSingleOrNull();
      final oldTime = existing?.timeSpentSeconds ?? 0;
      final status = math.max(existing?.status ?? 0, completed ? 2 : 1);
      await db
          .into(db.lessonProgressTable)
          .insertOnConflictUpdate(
            LessonProgressTableCompanion.insert(
              moduleId: moduleId,
              chapterId: chapterId.name,
              status: Value(status),
              watchedFullTrace: Value(
                watchedFullTrace || (existing?.watchedFullTrace ?? false),
              ),
              customRunCount: Value(
                (existing?.customRunCount ?? 0) + customCount,
              ),
              timeSpentSeconds: Value(oldTime + elapsedSeconds),
              lastVisitedAt: now.toUtc(),
            ),
          );
      final key = localDateKey(now);
      final day = await (db.select(
        db.dailyStudyStatsTable,
      )..where((t) => t.dateKey.equals(key))).getSingleOrNull();
      await db
          .into(db.dailyStudyStatsTable)
          .insertOnConflictUpdate(
            DailyStudyStatsTableCompanion.insert(
              dateKey: key,
              studySeconds: Value((day?.studySeconds ?? 0) + elapsedSeconds),
              studyMinutes: Value(
                ((day?.studySeconds ?? 0) + elapsedSeconds) ~/ 60,
              ),
              labsCompleted: Value(
                (day?.labsCompleted ?? 0) +
                    (status == 2 && existing?.status != 2 ? 1 : 0),
              ),
              questionsSolved: Value(day?.questionsSolved ?? 0),
              correctCount: Value(day?.correctCount ?? 0),
            ),
          );
      final badges = AchievementRepository(db);
      if (!studied(day) &&
          (elapsedSeconds > 0 || status == 2 && existing?.status != 2)) {
        await badges.refreshDays();
      }
      if (watchedFullTrace && existing?.watchedFullTrace != true) {
        await badges.unlock(StudyBadge.firstTrace, at: now);
      }
      if ((watchedFullTrace || customCount > 0) &&
          existing?.watchedFullTrace != true &&
          (existing?.customRunCount ?? 0) == 0) {
        await QuizRepository(db).updateChapterMastery(chapterId);
      }
    });
  }
}
