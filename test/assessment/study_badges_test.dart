import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/achievement_practice.dart';
import 'package:fldata/curriculum/catalog.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/curriculum/ch6_graph/dijkstra.dart';
import 'package:fldata/curriculum/pointer_practice.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/database/repositories/achievement_repository.dart';
import 'package:fldata/database/repositories/backup_repository.dart';
import 'package:fldata/database/repositories/progress_repository.dart';
import 'package:fldata/database/repositories/quiz_repository.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/features/assessment/algorithm_code_judge.dart';
import 'package:fldata/features/assessment/function_judge.dart';
import 'package:fldata/features/assessment/trace_table_grader.dart';
import 'package:fldata/models/quiz_question.dart';
import 'package:fldata/models/study_badge.dart';

void main() {
  late AppDatabase db;
  late AchievementRepository badges;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    badges = AchievementRepository(db);
  });
  tearDown(() => db.close());
  Future<Achievement?> row(StudyBadge b) => (db.select(
    db.achievementsTable,
  )..where((r) => r.achievementId.equals(b.id))).getSingleOrNull();
  Future<void> attempt(
    QuizQuestion q, {
    bool passed = true,
    bool clean = true,
  }) => QuizRepository(db).recordAttempt(
    questionId: q.id,
    chapterId: q.chapterId,
    type: q.type,
    isCorrect: passed,
    score: passed ? 100 : 40,
    durationMs: 6000,
    quality: passed ? 4 : 1,
    answer: q.type == QuestionType.pointerSandbox ? {'zeroLeak': clean} : {},
  );

  test('SQLite v1 成就表升级后保留原解锁日期', () async {
    final upgraded = AppDatabase(
      NativeDatabase.memory(
        setup: (sql) {
          sql.execute(
            'CREATE TABLE achievements_table (achievement_id TEXT PRIMARY KEY NOT NULL,title TEXT NOT NULL,unlocked_at INTEGER,progress_current INTEGER NOT NULL DEFAULT 0,progress_target INTEGER NOT NULL)',
          );
          sql.execute(
            "INSERT INTO achievements_table VALUES ('first_trace','初窥内存',1000,1,1)",
          );
          sql.execute('PRAGMA user_version=1');
        },
      ),
    );
    addTearDown(upgraded.close);
    final saved = await upgraded.select(upgraded.achievementsTable).getSingle();
    expect(saved.evidenceMask, 0);
    expect(saved.unlockedAt?.millisecondsSinceEpoch, 1000000);
  });

  test('连续零泄漏、自然日和 KMP 成就取自真实流水且解锁保留', () async {
    final p = pointerPractice.values.first;
    for (var i = 0; i < 4; i++) {
      await attempt(p);
    }
    expect((await row(StudyBadge.pointerSurgeon))?.progressCurrent, 4);
    await attempt(p, clean: false);
    expect((await row(StudyBadge.pointerSurgeon))?.progressCurrent, 0);
    for (var i = 0; i < 5; i++) {
      await attempt(p);
    }
    await attempt(p, passed: false);
    await badges.reconcile();
    expect((await row(StudyBadge.pointerSurgeon))?.unlockedAt, isNotNull);
    for (var i = 0; i < 7; i++) {
      await ProgressRepository(db).recordVisit(
        moduleId: 'ch1_struct_mapping',
        chapterId: ChapterId.ch1,
        elapsedSeconds: 10,
        watchedFullTrace: i == 6,
        at: DateTime(2025, 12, 28 + i),
      );
    }
    expect((await row(StudyBadge.streak7days))?.unlockedAt, isNotNull);
    expect((await row(StudyBadge.firstTrace))?.unlockedAt, isNotNull);
    final kmp = questionById(kmpTableId)!;
    await attempt(kmp, passed: false);
    expect(await row(StudyBadge.kmpNavigator), isNull);
    await attempt(kmp);
    expect((await row(StudyBadge.kmpNavigator))?.unlockedAt, isNotNull);
  });

  test('重复旋转不加分，跨备份合并互补类型并保留旧格式数据', () async {
    await badges.milestone(StudyBadge.avlBalancer, 0);
    await badges.milestone(StudyBadge.avlBalancer, 0);
    await badges.milestone(StudyBadge.avlBalancer, 1);
    final first = await BackupRepository(db).exportJson();
    final legacy = jsonDecode(first) as Map<String, dynamic>;
    expect(legacy.remove('achievementEvidence'), {'avl_balancer': 3});
    expect(
      (legacy['payload']['achievements'] as List).first,
      isNot(containsPair('evidence_mask', 3)),
    );
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await BackupRepository(
      other,
    ).importJson(jsonEncode(legacy), strategy: ImportStrategy.overwrite);
    expect(
      (await other.select(other.achievementsTable).getSingle()).progressCurrent,
      2,
    );
    await badges.milestone(StudyBadge.avlBalancer, 2);
    final right = AchievementRepository(other);
    await right.milestone(StudyBadge.avlBalancer, 3);
    await BackupRepository(
      db,
    ).importJson(await BackupRepository(other).exportJson());
    final record = await row(StudyBadge.avlBalancer);
    expect(record?.evidenceMask, 15);
    expect(record?.progressCurrent, 4);
    expect(record?.unlockedAt, isNotNull);
    for (var i = 0; i < 3; i++) {
      await badges.finishRace(mixed: false);
    }
    expect((await row(StudyBadge.raceChampion))?.unlockedAt, isNull);
    await badges.finishRace(mixed: true);
    expect((await row(StudyBadge.raceChampion))?.unlockedAt, isNotNull);
  });

  test('八章均有可作答的四项来源，按目录分母达标', () async {
    final all = [
      ...quizQuestions,
      ...pointerPractice.values,
      ...achievementPractice,
    ];
    for (final chapter in chapters) {
      for (final id in chapter.moduleIds) {
        await ProgressRepository(db).recordVisit(
          moduleId: id,
          chapterId: chapter.id,
          elapsedSeconds: 10,
          watchedFullTrace: true,
        );
      }
      for (final types in [
        {QuestionType.choice},
        {QuestionType.traceTable, QuestionType.pointerSandbox},
        {QuestionType.code},
      ]) {
        await attempt(
          all.firstWhere(
            (q) => q.chapterId == chapter.id && types.contains(q.type),
          ),
        );
      }
    }
    expect(
      (await db.select(db.chapterMasteryTable).get()).map(
        (r) => r.overallMastery,
      ),
      everyElement(100),
    );
    expect((await row(StudyBadge.grandmaster))?.unlockedAt, isNotNull);
  });

  test('独立配套题映射 G₆ 五轮、两条关键路径及第一章矩阵求和', () async {
    expect(quizQuestions.length, 195);
    final rounds = const DijkstraModule()
        .generateTrace(shortestPathPresets.first.input)
        .frames
        .last
        .scene
        .auxTables
        .last
        .rows;
    expect(table64Practice.answerRows, [
      for (final r in rounds) r.skip(4).toList(),
    ]);
    const grader = TraceTableGrader();
    expect(
      grader.grade(table64Practice, table64Practice.answerRows).complete,
      isTrue,
    );
    final edges = {'v0→v1', 'v1→v4', 'v4→v7', 'v7→v8', 'v4→v6', 'v6→v8'};
    expect(
      grader.grade(parallelAoePractice, [], edges: edges).complete,
      isTrue,
    );
    expect(
      grader
          .grade(parallelAoePractice, [], edges: edges..remove('v4→v6'))
          .complete,
      isFalse,
    );
    expect(
      AlgorithmCodeJudge.gradeBlanks(matrixSumPractice, ['j<n', 'B[i][j]']),
      [true, true],
    );
    final cases = await FunctionJudge.run(
      matrixSumPractice.dartReferenceCode,
      matrixSumPractice.testCases,
    );
    expect(cases.map((c) => c.passed), everyElement(isTrue));
  });
}
