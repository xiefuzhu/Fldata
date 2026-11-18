import 'package:drift/drift.dart';
import '../../common/math_utils.dart';
import '../../curriculum/catalog.dart' show chapters;
import '../../enum/ds_enums.dart';
import '../app_database.dart';
import 'achievement_repository.dart';
import '../../common/study_days.dart';

class QuizRepository {
  QuizRepository(this.db);
  final AppDatabase db;
  Stream<Set<String>> watchUnmasteredIds() =>
      (db.select(db.wrongQuestionBookTable)
            ..where((t) => t.isMastered.equals(false)))
          .watch()
          .map((rows) => rows.map((r) => r.questionId).toSet());

  Stream<List<WrongQuestion>> watchDue(DateTime now) =>
      (db.select(db.wrongQuestionBookTable)
            ..where(
              (t) =>
                  t.isMastered.equals(false) &
                  t.nextReviewAt.isSmallerOrEqualValue(now.toUtc()),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
          .watch();
  Stream<List<ChapterMastery>> watchMastery() =>
      db.select(db.chapterMasteryTable).watch();

  Future<void> updateChapterMastery(ChapterId chapter) async {
    await _updateMastery(
      chapter,
      chapters.firstWhere((c) => c.id == chapter).moduleIds.length,
    );
    await AchievementRepository(db).refreshMastery();
  }

  Future<void> recordAttempt({
    required String questionId,
    required ChapterId chapterId,
    required QuestionType type,
    required bool isCorrect,
    required int score,
    required Map<String, dynamic> answer,
    required int durationMs,
    required int quality,
    DateTime? at,
  }) async {
    if (score < 0 ||
        score > 100 ||
        durationMs < 0 ||
        quality < 0 ||
        quality > 5 ||
        isCorrect != (quality >= 3)) {
      throw ArgumentError('Invalid score, duration or recall quality');
    }
    final now = at ?? DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.quizAttemptsTable)
          .insert(
            QuizAttemptsTableCompanion.insert(
              questionId: questionId,
              chapterId: chapterId.name,
              questionType: type.name,
              isCorrect: isCorrect,
              score: score,
              userAnswerJson: answer,
              durationMs: durationMs,
              attemptedAt: now.toUtc(),
            ),
          );
      final wrong = await (db.select(
        db.wrongQuestionBookTable,
      )..where((t) => t.questionId.equals(questionId))).getSingleOrNull();
      if (!isCorrect || wrong != null) {
        final schedule = scheduleReview(
          quality: quality,
          repetitions: wrong?.consecutiveCorrect ?? 0,
          intervalDays: wrong?.intervalDays ?? 1,
          easinessFactor: wrong?.easinessFactor ?? 2.5,
        );
        await db
            .into(db.wrongQuestionBookTable)
            .insertOnConflictUpdate(
              WrongQuestionBookTableCompanion.insert(
                questionId: questionId,
                chapterId: chapterId.name,
                errorCount: Value(
                  (wrong?.errorCount ?? 0) + (isCorrect ? 0 : 1),
                ),
                consecutiveCorrect: Value(schedule.repetitions),
                easinessFactor: Value(schedule.easinessFactor),
                intervalDays: Value(schedule.intervalDays),
                nextReviewAt: now.toUtc().add(
                  Duration(days: schedule.intervalDays),
                ),
                userNote: Value(wrong?.userNote ?? ''),
                isMastered: Value(schedule.repetitions >= 3),
              ),
            );
      }
      final key = localDateKey(now);
      final day = await (db.select(
        db.dailyStudyStatsTable,
      )..where((t) => t.dateKey.equals(key))).getSingleOrNull();
      await db
          .into(db.dailyStudyStatsTable)
          .insertOnConflictUpdate(
            DailyStudyStatsTableCompanion.insert(
              dateKey: key,
              studySeconds: Value(day?.studySeconds ?? 0),
              studyMinutes: Value(day?.studyMinutes ?? 0),
              labsCompleted: Value(day?.labsCompleted ?? 0),
              questionsSolved: Value((day?.questionsSolved ?? 0) + 1),
              correctCount: Value(
                (day?.correctCount ?? 0) + (isCorrect ? 1 : 0),
              ),
            ),
          );
      final badges = AchievementRepository(db);
      if (!studied(day)) await badges.refreshDays();
      await badges.afterAttempt(
        questionId,
        type,
        isCorrect,
        score,
        answer,
        now,
      );
      await updateChapterMastery(chapterId);
    });
  }

  /// Module totals come from the installed curriculum, not visited rows.
  Future<void> recomputeMastery(Map<ChapterId, int> moduleTotals) async {
    for (final chapter in ChapterId.values) {
      await _updateMastery(chapter, moduleTotals[chapter] ?? 0);
    }
  }

  Future<void> _updateMastery(ChapterId chapter, int total) async {
    final attempts = await (db.select(
      db.quizAttemptsTable,
    )..where((t) => t.chapterId.equals(chapter.name))).get();
    final latest = <String, QuizAttempt>{};
    for (final attempt in attempts) {
      final old = latest[attempt.questionId];
      if (old == null || !attempt.attemptedAt.isBefore(old.attemptedAt)) {
        latest[attempt.questionId] = attempt;
      }
    }
    double average(Set<String> types) {
      final selected = latest.values
          .where((a) => types.contains(a.questionType))
          .toList();
      return selected.isEmpty
          ? 0
          : selected.fold<double>(0, (sum, a) => sum + a.score) /
                selected.length;
    }

    final lessons =
        await (db.select(db.lessonProgressTable)..where(
              (t) =>
                  t.chapterId.equals(chapter.name) &
                  t.moduleId.isIn(
                    chapters.firstWhere((c) => c.id == chapter).moduleIds,
                  ) &
                  (t.watchedFullTrace.equals(true) |
                      t.customRunCount.isBiggerThanValue(0)),
            ))
            .get();
    final labs = total == 0
        ? 0.0
        : (lessons.length / total * 100).clamp(0.0, 100.0);
    final concept = average({
      QuestionType.choice.name,
      QuestionType.shortAnswer.name,
    });
    final trace = average({
      QuestionType.traceTable.name,
      QuestionType.pointerSandbox.name,
    });
    final coding = average({QuestionType.code.name});
    await db
        .into(db.chapterMasteryTable)
        .insertOnConflictUpdate(
          ChapterMasteryTableCompanion.insert(
            chapterId: chapter.name,
            conceptScore: Value(concept),
            traceScore: Value(trace),
            codingScore: Value(coding),
            labCompletionRate: Value(labs),
            overallMastery: Value(
              0.30 * labs + 0.25 * concept + 0.25 * trace + 0.20 * coding,
            ),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
