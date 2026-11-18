import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/curriculum/achievement_practice.dart';
import 'package:fldata/common/math_utils.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/database/repositories/progress_repository.dart';
import 'package:fldata/database/repositories/quiz_repository.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/router/app_router.dart';

void main() {
  test('SM-2 低分单独降 EF，第三次成功按旧 EF 四舍五入', () {
    final fail = scheduleReview(
      quality: 1,
      repetitions: 2,
      intervalDays: 6,
      easinessFactor: 2.5,
    );
    expect(fail.easinessFactor, closeTo(2.3, 1e-8));
    expect(fail.repetitions, 0);
    expect(fail.intervalDays, 1);
    expect(
      scheduleReview(
        quality: 4,
        repetitions: 2,
        intervalDays: 6,
        easinessFactor: 2.38,
      ).intervalDays,
      14,
    );
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('首页日历与雷达显示真实数据，复习直达题目 $width', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 950);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime(2026, 1, 2, 12);
      final progress = ProgressRepository(db);
      final quiz = QuizRepository(db);
      await progress.recordVisit(
        moduleId: 'ch2_sqlist_ops',
        chapterId: ChapterId.ch2,
        elapsedSeconds: 120,
        at: DateTime(2025, 12, 31, 16),
        watchedFullTrace: true,
      );
      await progress.recordVisit(
        moduleId: 'ch2_linklist_ops',
        chapterId: ChapterId.ch2,
        elapsedSeconds: 60,
        customRun: true,
        at: DateTime(2026, 1, 1),
      );
      await progress.recordVisit(
        moduleId: 'ch2_merge_compare',
        chapterId: ChapterId.ch2,
        elapsedSeconds: 80,
        completed: true,
        at: now,
      );
      await quiz.recordAttempt(
        questionId: 'textbook_ch2_1_01',
        chapterId: ChapterId.ch2,
        type: QuestionType.choice,
        isCorrect: false,
        score: 0,
        answer: {},
        durationMs: 6000,
        quality: 1,
        at: DateTime(2026, 1, 1),
      );
      // Simulate a v1 cache saved under the old manual-completion rule.
      await (db.update(db.chapterMasteryTable)
            ..where((t) => t.chapterId.equals('ch2')))
          .write(const ChapterMasteryTableCompanion(overallMastery: Value(99)));
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(prefs),
          nativeWindowProvider.overrideWithValue(false),
          studyClockProvider.overrideWith((ref) => Stream.value(now)),
        ],
      );
      addTearDown(container.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FldataApp(),
        ),
      );
      await t.pumpAndSettle();
      final outer = find.byKey(
        width < 600
            ? const ValueKey('dashboard-summary')
            : const PageStorageKey('dashboard-wide-scroll'),
      );
      final scrollable = find
          .descendant(of: outer, matching: find.byType(Scrollable))
          .first;
      Future<void> reveal(Finder f) async {
        await t.scrollUntilVisible(f, 220, scrollable: scrollable);
        await t.pumpAndSettle();
      }

      Future<void> tap(Finder f) async {
        await Scrollable.ensureVisible(t.element(f), alignment: .5);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      await reveal(find.text('本年学习 2 天 · 当前连续 3 天'));
      expect(find.text('学习 1 分钟 · 实验 1 · 作答 0'), findsOneWidget);
      final year = find.byType(DropdownButton<int>);
      await t.ensureVisible(year);
      await tap(year);
      await t.pumpAndSettle();
      await tap(find.text('2025 年').last);
      await t.pumpAndSettle();
      expect(find.text('2025-12-31'), findsOneWidget);
      expect(find.text('学习 2 分钟 · 实验 0 · 作答 0'), findsOneWidget);
      await reveal(find.text('2 · 12%'));
      await tap(find.text('2 · 12%'));
      await t.pumpAndSettle();
      expect(find.text('实验 40%　概念 0%　推演 0%　设计 0%'), findsOneWidget);
      if (width < 600) {
        await t.scrollUntilVisible(
          find.text('今日到期复习：1 题'),
          -260,
          scrollable: scrollable,
        );
        await t.pumpAndSettle();
        await tap(find.text('今日到期复习：1 题'));
        await t.pumpAndSettle();
        await tap(
          find
              .descendant(
                of: find.byKey(const PageStorageKey('due-reviews')),
                matching: find.byType(ListTile),
              )
              .first,
        );
        await t.pumpAndSettle();
        expect(find.textContaining('顺序表中第一个元素的存储地址是100'), findsOneWidget);
        await tap(find.byKey(const ValueKey('option-0-1')));
        await t.pumpAndSettle();
        final submit = find.text('提交答案');
        await t.ensureVisible(submit);
        await tap(submit);
        await t.pumpAndSettle();
        expect(find.text('回答正确'), findsOneWidget);
        container.read(appRouterProvider).pop();
        await t.pumpAndSettle();
        expect(find.text('今日到期复习：0 题'), findsOneWidget);
        final updated = await (db.select(
          db.chapterMasteryTable,
        )..where((t) => t.chapterId.equals('ch2'))).getSingle();
        expect(updated.overallMastery, 37);
      }
      final badgeTile = find.byKey(const ValueKey('critical_architect'));
      await reveal(badgeTile);
      await tap(badgeTile);
      await tap(find.text('标定关键活动'));
      await tap(find.byKey(const ValueKey('critical-v0→v1')));
      await tap(find.text('提交整题'));
      expect(find.textContaining('关键活动集合有误'), findsOneWidget);
      await tap(find.text('重新推演'));
      for (final edge in [
        'v0→v1',
        'v1→v4',
        'v4→v6',
        'v4→v7',
        'v6→v8',
        'v7→v8',
      ]) {
        await tap(find.byKey(ValueKey('critical-$edge')));
      }
      await tap(find.text('提交整题'));
      expect(find.text('关键活动集合正确'), findsOneWidget);
      container.read(appRouterProvider).pop();
      await t.pumpAndSettle();
      await reveal(badgeTile);
      expect(
        find.descendant(of: badgeTile, matching: find.text('已解锁')),
        findsOneWidget,
      );
      if (width > 1000) {
        await tap(find.byKey(const ValueKey('shortest_pathfinder')));
        await tap(find.text('填写表 6.4'));
        for (final (r, answers) in table64Practice.answerRows.indexed) {
          for (final (c, value) in answers.indexed) {
            final field = find.descendant(
              of: find.byKey(ValueKey('trace-0-$r-$c')),
              matching: find.byType(TextField),
            );
            await t.enterText(field, value);
          }
        }
        await t.pumpAndSettle();
        await tap(find.text('提交整题'));
        expect(find.text('100 分 · 答对 30/30 项'), findsOneWidget);
        expect(
          (await (db.select(db.achievementsTable)..where(
                    (r) => r.achievementId.equals('shortest_pathfinder'),
                  ))
                  .getSingle())
              .unlockedAt,
          isNotNull,
        );
      }
      expect(t.takeException(), isNull);
    });
  }
}
