import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../../common/study_days.dart';
import '../../curriculum/achievement_practice.dart';
import '../../enum/ds_enums.dart';
import '../../models/study_badge.dart';
import '../app_database.dart';

class AchievementRepository {
  AchievementRepository(this.db);
  final AppDatabase db;
  Stream<List<Achievement>> watch() => db.select(db.achievementsTable).watch();

  Future<void> _update(
    StudyBadge badge,
    int Function(int old, int mask) next, {
    int bits = 0,
    DateTime? at,
  }) => db.transaction(() async {
    final old = await (db.select(
      db.achievementsTable,
    )..where((r) => r.achievementId.equals(badge.id))).getSingleOrNull();
    if (old?.unlockedAt != null) return;
    final mask = (old?.evidenceMask ?? 0) | bits;
    final count = next(old?.progressCurrent ?? 0, mask).clamp(0, badge.target);
    if (count == (old?.progressCurrent ?? 0) &&
        mask == (old?.evidenceMask ?? 0)) {
      return;
    }
    await db
        .into(db.achievementsTable)
        .insertOnConflictUpdate(
          AchievementsTableCompanion.insert(
            achievementId: badge.id,
            title: badge.title,
            progressTarget: badge.target,
            progressCurrent: Value(count),
            evidenceMask: Value(mask),
            unlockedAt: Value(
              badge.reached(count, mask)
                  ? (at ?? DateTime.now()).toUtc()
                  : null,
            ),
          ),
        );
  });

  Future<void> unlock(StudyBadge badge, {DateTime? at}) =>
      _update(badge, (_, _) => badge.target, at: at);
  Future<void> milestone(StudyBadge badge, int index) => _update(
    badge,
    (old, mask) => math.max(
      old,
      [
        for (var i = 0; i < badge.target; i++)
          if (mask & (1 << i) != 0) i,
      ].length,
    ),
    bits: 1 << index,
  );
  Future<void> finishRace({required bool mixed}) => _update(
    StudyBadge.raceChampion,
    (old, _) => old + 1,
    bits: mixed ? 1 : 0,
  );

  Future<void> afterAttempt(
    String id,
    QuestionType type,
    bool correct,
    int score,
    Map<String, dynamic> answer,
    DateTime at,
  ) async {
    if (type == QuestionType.pointerSandbox) {
      await _update(
        StudyBadge.pointerSurgeon,
        (old, _) => correct && answer['zeroLeak'] == true ? old + 1 : 0,
        at: at,
      );
    }
    if (!correct || score != 100) return;
    final badge = switch (id) {
      'textbook_ch4_2_01' || 'textbook_ch4_2_02' => StudyBadge.kmpNavigator,
      dijkstraPracticeId => StudyBadge.shortestPathfinder,
      parallelAoeId => StudyBadge.criticalArchitect,
      _ => null,
    };
    if (badge != null) await unlock(badge, at: at);
  }

  Future<void> refreshMastery() async {
    final rows = await (db.select(
      db.chapterMasteryTable,
    )..where((t) => t.overallMastery.isBiggerThanValue(80))).get();
    final count = rows
        .where((r) => ChapterId.values.any((c) => c.name == r.chapterId))
        .length;
    await _update(StudyBadge.grandmaster, (_, _) => count);
  }

  Future<void> refreshDays() async {
    final rows = await (db.select(
      db.dailyStudyStatsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.dateKey)])).get();
    DateTime? previous, reached;
    var longest = 0, run = 0;
    for (final row in rows.where(studied)) {
      final date = DateTime.tryParse('${row.dateKey}T00:00:00Z');
      if (date == null) continue;
      run = previous != null && date.difference(previous).inDays == 1
          ? run + 1
          : 1;
      longest = math.max(longest, run);
      if (run == 7) reached ??= DateTime(date.year, date.month, date.day);
      previous = date;
    }
    await _update(StudyBadge.streak7days, (_, _) => longest, at: reached);
  }

  /// Reconstruct evidence available before badges were tracked, without
  /// re-counting attempts each time the dashboard opens.
  Future<void> reconcile() => db.transaction(() async {
    final watched =
        await (db.select(db.lessonProgressTable)
              ..where((t) => t.watchedFullTrace.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (watched != null) await unlock(StudyBadge.firstTrace);
    final attempts =
        await (db.select(db.quizAttemptsTable)..orderBy([
              (r) => OrderingTerm.asc(r.attemptedAt),
              (r) => OrderingTerm.asc(r.id),
            ]))
            .get();
    var consecutive = 0;
    DateTime? fifth;
    for (final row in attempts) {
      if (row.questionType == QuestionType.pointerSandbox.name) {
        consecutive = row.isCorrect && row.userAnswerJson['zeroLeak'] == true
            ? consecutive + 1
            : 0;
        if (consecutive == 5) fifth ??= row.attemptedAt;
      } else if (row.isCorrect &&
          row.score == 100 &&
          row.questionType == QuestionType.traceTable.name) {
        await afterAttempt(
          row.questionId,
          QuestionType.traceTable,
          true,
          100,
          row.userAnswerJson,
          row.attemptedAt,
        );
      }
    }
    await _update(
      StudyBadge.pointerSurgeon,
      (_, _) => fifth != null ? 5 : consecutive,
      at: fifth,
    );
    await refreshDays();
    await refreshMastery();
  });
}
