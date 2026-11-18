import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';
import 'curriculum/lesson_test_support.dart';

void main() {
  testWidgets(
    'completed lesson and overdue review survive a dashboard round trip',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1440, 1000));
      final router = container.read(appRouterProvider);
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      final timeline = container.read(playbackProvider).timeline!;
      await tap(find.byKey(const ValueKey('lesson-complete')));
      final q = questionById('textbook_ch3_1_01')!;
      await container
          .read(quizRepositoryProvider)
          .recordAttempt(
            questionId: q.id,
            chapterId: q.chapterId,
            type: q.type,
            isCorrect: false,
            score: 0,
            answer: {
              'indices': [0],
            },
            durationMs: 3000,
            quality: 1,
            at: DateTime.now().subtract(const Duration(days: 2)),
          );
      router.go('/dashboard');
      await tester.pumpAndSettle();
      final due = find.descendant(
        of: find.byKey(const PageStorageKey('due-reviews')),
        matching: find.text(q.topic),
      );
      await tap(due);
      await tap(find.byKey(const ValueKey('option-0-2')));
      await tap(find.text('提交答案'));
      expect(find.text('回答正确'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('暂无到期错题'), findsOneWidget);
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle())
            .consecutiveCorrect,
        1,
      );
      final lesson = await db.select(db.lessonProgressTable).getSingle();
      expect(lesson.moduleId, timeline.moduleId);
      expect(lesson.status, 2);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
