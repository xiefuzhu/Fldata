// Drift resolves column getter references when generating SQL constraints.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'converters.dart';
part 'app_database.g.dart';

@TableIndex(name: 'lesson_chapter', columns: {#chapterId})
@DataClassName('LessonProgress')
class LessonProgressTable extends Table {
  TextColumn get moduleId => text()();
  TextColumn get chapterId => text()();
  IntColumn get status => integer()
      .withDefault(const Constant(0))
      .check(status.isBetweenValues(0, 2))();
  BoolColumn get watchedFullTrace =>
      boolean().withDefault(const Constant(false))();
  IntColumn get customRunCount => integer()
      .withDefault(const Constant(0))
      .check(customRunCount.isBiggerOrEqualValue(0))();
  IntColumn get timeSpentSeconds => integer()
      .withDefault(const Constant(0))
      .check(timeSpentSeconds.isBiggerOrEqualValue(0))();
  DateTimeColumn get lastVisitedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {moduleId};
}

@DataClassName('QuizAttempt')
class QuizAttemptsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get questionId => text()();
  TextColumn get chapterId => text()();
  TextColumn get questionType => text()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get score => integer().check(score.isBetweenValues(0, 100))();
  TextColumn get userAnswerJson => text().map(const JsonMapConverter())();
  IntColumn get durationMs =>
      integer().check(durationMs.isBiggerOrEqualValue(0))();
  DateTimeColumn get attemptedAt => dateTime()();
}

@TableIndex(name: 'wrong_due_mastered', columns: {#nextReviewAt, #isMastered})
@DataClassName('WrongQuestion')
class WrongQuestionBookTable extends Table {
  TextColumn get questionId => text()();
  TextColumn get chapterId => text()();
  IntColumn get errorCount => integer().withDefault(const Constant(0))();
  IntColumn get consecutiveCorrect =>
      integer().withDefault(const Constant(0))();
  RealColumn get easinessFactor => real()
      .withDefault(const Constant(2.5))
      .check(easinessFactor.isBiggerOrEqualValue(1.3))();
  IntColumn get intervalDays => integer()
      .withDefault(const Constant(1))
      .check(intervalDays.isBiggerOrEqualValue(1))();
  DateTimeColumn get nextReviewAt => dateTime()();
  TextColumn get userNote => text().withDefault(const Constant(''))();
  BoolColumn get isMastered => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {questionId};
}

@DataClassName('ChapterMastery')
class ChapterMasteryTable extends Table {
  TextColumn get chapterId => text()();
  RealColumn get conceptScore => real().withDefault(const Constant(0))();
  RealColumn get traceScore => real().withDefault(const Constant(0))();
  RealColumn get codingScore => real().withDefault(const Constant(0))();
  RealColumn get labCompletionRate => real().withDefault(const Constant(0))();
  RealColumn get overallMastery => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {chapterId};
}

@DataClassName('DailyStudyStats')
class DailyStudyStatsTable extends Table {
  TextColumn get dateKey => text()();
  IntColumn get studySeconds => integer().withDefault(const Constant(0))();
  IntColumn get studyMinutes => integer().withDefault(const Constant(0))();
  IntColumn get labsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get questionsSolved => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {dateKey};
}

@TableIndex(
  name: 'dataset_module_name',
  columns: {#moduleId, #name},
  unique: true,
)
@DataClassName('UserCustomDataset')
class UserCustomDatasetsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get moduleId => text()();
  TextColumn get name => text()();
  TextColumn get payloadJson => text().map(const JsonMapConverter())();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('CodeDraft')
class CodeDraftsTable extends Table {
  TextColumn get questionId => text()();
  TextColumn get codeLang => text()();
  TextColumn get sourceCode => text()();
  RealColumn get lastPassRate => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {questionId};
}

@DataClassName('Achievement')
class AchievementsTable extends Table {
  TextColumn get achievementId => text()();
  TextColumn get title => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().withDefault(const Constant(0))();
  IntColumn get progressTarget => integer()();
  IntColumn get evidenceMask => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {achievementId};
}

@DriftDatabase(
  tables: [
    LessonProgressTable,
    QuizAttemptsTable,
    WrongQuestionBookTable,
    ChapterMasteryTable,
    DailyStudyStatsTable,
    UserCustomDatasetsTable,
    CodeDraftsTable,
    AchievementsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'fldata',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationSupportDirectory,
              ),
            ),
      );
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(achievementsTable, achievementsTable.evidenceMask);
      }
    },
  );
}
