import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/database/repositories/progress_repository.dart';
import 'package:fldata/database/repositories/quiz_repository.dart';
import 'package:fldata/database/repositories/backup_repository.dart';
import 'package:fldata/enum/ds_enums.dart';

void main() {
  // Each round-trip endpoint uses its own independent in-memory executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime.utc(2026, 11, 15, 8);
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());
  Future<void> visit({int seconds = 30, bool completed = false}) =>
      ProgressRepository(db).recordVisit(
        moduleId: 'list',
        chapterId: ChapterId.ch2,
        elapsedSeconds: seconds,
        completed: completed,
        at: now,
      );
  Future<void> attempt({bool correct = false, int quality = 1}) =>
      QuizRepository(db).recordAttempt(
        questionId: 'q1',
        chapterId: ChapterId.ch2,
        type: QuestionType.choice,
        isCorrect: correct,
        score: correct ? 100 : 0,
        answer: {'choice': correct ? 'A' : 'B'},
        durationMs: 1234,
        quality: quality,
        at: now,
      );
  test('short answers contribute to concept mastery with choices', () async {
    final repo = QuizRepository(db);
    await attempt();
    await repo.recordAttempt(
      questionId: 'short1',
      chapterId: ChapterId.ch2,
      type: QuestionType.shortAnswer,
      isCorrect: true,
      score: 100,
      answer: {'text': '示例'},
      durationMs: 500,
      quality: 5,
      at: now,
    );
    await repo.recomputeMastery({});
    final mastery = await (db.select(
      db.chapterMasteryTable,
    )..where((t) => t.chapterId.equals(ChapterId.ch2.name))).getSingle();
    expect(mastery.conceptScore, 50);
    expect(mastery.traceScore, 0);
  });
  test('creates all eight domain tables', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    expect(
      rows.map((r) => r.read<String>('name')).toSet(),
      BackupRepository.tables.values.toSet(),
    );
  });
  test(
    'short visits accumulate minutes and completion counts only once',
    () async {
      await visit(completed: true);
      await visit(completed: true);
      final lesson = await db.select(db.lessonProgressTable).getSingle();
      final day = await db.select(db.dailyStudyStatsTable).getSingle();
      expect(lesson.timeSpentSeconds, 60);
      expect(day.studyMinutes, 1);
      expect(day.labsCompleted, 1);
      await visit();
      expect((await db.select(db.lessonProgressTable).getSingle()).status, 2);
    },
  );
  test(
    'SM-2 writes history, schedules reviews and resets after failure',
    () async {
      await attempt();
      var wrong = await db.select(db.wrongQuestionBookTable).getSingle();
      expect(wrong.errorCount, 1);
      expect(wrong.intervalDays, 1);
      await attempt(correct: true, quality: 4);
      await attempt(correct: true, quality: 4);
      wrong = await db.select(db.wrongQuestionBookTable).getSingle();
      expect(wrong.consecutiveCorrect, 2);
      expect(wrong.intervalDays, 6);
      await attempt(correct: true, quality: 5);
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle()).isMastered,
        isTrue,
      );
      await attempt(quality: 0);
      wrong = await db.select(db.wrongQuestionBookTable).getSingle();
      expect(wrong.consecutiveCorrect, 0);
      expect(wrong.isMastered, isFalse);
      expect(wrong.easinessFactor, greaterThanOrEqualTo(1.3));
      expect((await db.select(db.quizAttemptsTable).get()).length, 5);
    },
  );
  test(
    'round-trips all eight tables including quiz history and drafts',
    () async {
      await visit(completed: true);
      await attempt();
      await db
          .into(db.userCustomDatasetsTable)
          .insert(
            UserCustomDatasetsTableCompanion.insert(
              moduleId: 'list',
              name: '样例',
              payloadJson: {
                'values': [1, 2],
              },
              createdAt: now,
            ),
          );
      await db
          .into(db.codeDraftsTable)
          .insert(
            CodeDraftsTableCompanion.insert(
              questionId: 'code1',
              codeLang: 'c99',
              sourceCode: 'int main() {}',
              updatedAt: now,
            ),
          );
      await db
          .into(db.achievementsTable)
          .insert(
            AchievementsTableCompanion.insert(
              achievementId: 'first',
              title: '首次探索',
              progressTarget: 1,
              unlockedAt: Value(now),
            ),
          );
      await QuizRepository(db).recomputeMastery({ChapterId.ch2: 2});
      final backup = await BackupRepository(db).exportJson();
      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      await BackupRepository(
        other,
        moduleTotals: {ChapterId.ch2: 2},
      ).importJson(backup, strategy: ImportStrategy.overwrite);
      expect(
        (await other.select(other.quizAttemptsTable).getSingle())
            .userAnswerJson,
        {'choice': 'B'},
      );
      expect(
        (await other.select(other.userCustomDatasetsTable).getSingle())
            .payloadJson,
        {
          'values': [1, 2],
        },
      );
      expect(
        (await other.select(other.codeDraftsTable).getSingle()).sourceCode,
        'int main() {}',
      );
      expect(
        (await (other.select(
              other.achievementsTable,
            )..where((r) => r.achievementId.equals('first'))).getSingle())
            .unlockedAt
            ?.toUtc(),
        now,
      );
      expect((await other.select(other.chapterMasteryTable).get()).length, 8);
      expect(
        (await other.select(other.lessonProgressTable).getSingle()).status,
        2,
      );
    },
  );
  test(
    'merge preserves higher progress and deduplicates identical attempt history',
    () async {
      await visit(completed: true);
      await attempt();
      final backup = await BackupRepository(db).exportJson();
      await visit(seconds: 10);
      await BackupRepository(db).importJson(backup);
      expect(
        (await db.select(db.lessonProgressTable).getSingle()).timeSpentSeconds,
        70,
      );
      expect((await db.select(db.quizAttemptsTable).get()).length, 1);
    },
  );
  test('invalid schema is rejected before an overwrite', () async {
    await visit();
    final backup =
        jsonDecode(await BackupRepository(db).exportJson())
            as Map<String, dynamic>;
    backup['schemaVersion'] = 99;
    await expectLater(
      BackupRepository(
        db,
      ).importJson(jsonEncode(backup), strategy: ImportStrategy.overwrite),
      throwsFormatException,
    );
    expect(
      (await db.select(db.lessonProgressTable).getSingle()).timeSpentSeconds,
      30,
    );
  });
  test(
    'failed row import rolls back the whole overwrite transaction',
    () async {
      await visit();
      await attempt();
      final backup =
          jsonDecode(await BackupRepository(db).exportJson())
              as Map<String, dynamic>;
      backup['payload']['lessonProgress'][0]['time_spent_seconds'] = 999;
      backup['payload']['quizAttempts'][0]['score'] = 101;
      await expectLater(
        BackupRepository(
          db,
        ).importJson(jsonEncode(backup), strategy: ImportStrategy.overwrite),
        throwsA(anything),
      );
      expect(
        (await db.select(db.lessonProgressTable).getSingle()).timeSpentSeconds,
        30,
      );
      expect((await db.select(db.quizAttemptsTable).getSingle()).score, 0);
    },
  );
}
