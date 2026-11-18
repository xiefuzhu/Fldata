import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/database/repositories/quiz_repository.dart';
import 'package:fldata/features/assessment/trace_table_grader.dart';
import 'package:fldata/models/quiz_question.dart';

void main() {
  test(
    'partial table, three recalls and a relapse update the same review entry',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = QuizRepository(db);
      final q = questionById(dijkstraTableId)! as TraceTableQuestion;
      final complete = const TraceTableGrader().grade(q, q.answerRows);
      final partial = const TraceTableGrader().grade(q, [
        for (final row in q.answerRows) List.filled(row.length, ''),
      ]);
      expect(complete.complete, isTrue);
      expect(partial.complete, isFalse);
      var now = DateTime.utc(2026, 1, 1, 10);
      Future<WrongQuestion> submit(TraceTableGrade grade) async {
        await repo.recordAttempt(
          questionId: q.id,
          chapterId: q.chapterId,
          type: q.type,
          isCorrect: grade.complete,
          score: grade.score,
          answer: {'hits': grade.hits, 'total': grade.total},
          durationMs: 6000,
          quality: grade.complete ? 4 : 1,
          at: now,
        );
        return db.select(db.wrongQuestionBookTable).getSingle();
      }

      var row = await submit(partial);
      expect(
        (row.consecutiveCorrect, row.intervalDays, row.errorCount),
        (0, 1, 1),
      );
      for (final (i, days) in [1, 6, 14].indexed) {
        now = row.nextReviewAt.toUtc();
        expect(
          await repo.watchDue(now.subtract(const Duration(seconds: 1))).first,
          isEmpty,
        );
        expect((await repo.watchDue(now).first).single.questionId, q.id);
        row = await submit(complete);
        expect((row.consecutiveCorrect, row.intervalDays), (i + 1, days));
        expect(row.nextReviewAt.toUtc(), now.add(Duration(days: days)));
      }
      now = row.nextReviewAt.toUtc();
      expect(row.isMastered, isTrue);
      expect(await repo.watchDue(now).first, isEmpty);
      row = await submit(partial);
      expect(
        (
          row.isMastered,
          row.consecutiveCorrect,
          row.intervalDays,
          row.errorCount,
        ),
        (false, 0, 1, 2),
      );
      final attempts = await db.select(db.quizAttemptsTable).get();
      expect(attempts.map((a) => a.score), [
        partial.score,
        100,
        100,
        100,
        partial.score,
      ]);
      expect(
        (await repo.watchDue(row.nextReviewAt).first).single.questionId,
        q.id,
      );
    },
  );
}
