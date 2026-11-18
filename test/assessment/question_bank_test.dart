import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('题库筛选、作答、错题重现与多空同选在 $width 宽度可用', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 900);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          nativeWindowProvider.overrideWithValue(false),
          preferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FldataApp(),
        ),
      );
      router.go('/assessment');
      await t.pumpAndSettle();
      Future<void> tap(Finder f) async {
        await t.ensureVisible(f);
        await t.tap(f);
        await t.pumpAndSettle();
      }

      Future<void> filter(String name, String choice) async {
        await tap(find.byTooltip('筛选$name'));
        await tap(find.widgetWithText(PopupMenuItem<int>, choice));
      }

      expect(find.text('符合条件 195 项'), findsOneWidget);
      await filter('章节', '第 3 章 · 栈和队列');
      await filter('题型', '选择题');
      expect(find.text('符合条件 15 项'), findsOneWidget);
      await filter('难度', '进阶');
      const id = 'textbook_ch3_1_01';
      await tap(find.byKey(const ValueKey(id)));
      await tap(find.byKey(const ValueKey('option-0-0')));
      await tap(find.text('提交答案'));
      expect(find.text('回答有误 · 正确答案 C'), findsOneWidget);
      final attempt = await db.select(db.quizAttemptsTable).getSingle();
      expect(attempt.userAnswerJson, {
        'indices': [0],
      });
      expect(attempt.isCorrect, isFalse);
      await tap(find.text('在顺序栈实验室中运行验证'));
      final state = container.read(playbackProvider);
      expect(state.timeline!.moduleId, 'ch3_stack_sq_link');
      expect(state.frameIndex, 7);
      expect(state.isPlaying, isFalse);
      expect(state.currentFrame!.isErrorState, isTrue);
      expect(state.currentFrame!.scene.auxTables[1].rows.first.first, '1 → 2');
      expect(state.currentFrame!.inlineVars['已弹出'], '4 3');
      expect(find.text('弹出 4 和 3 后，2 挡在 1 上方。'), findsWidgets);
      await tap(find.byTooltip('返回习题'));
      expect(find.text('回答有误 · 正确答案 C'), findsOneWidget);
      router.pop();
      await t.pumpAndSettle();
      await tap(find.text('只看错题'));
      expect(find.text('符合条件 1 项'), findsOneWidget);
      await tap(find.byKey(const ValueKey(id)));
      await tap(find.byKey(const ValueKey('option-0-2')));
      await tap(find.text('提交答案'));
      expect(find.text('回答正确'), findsOneWidget);
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle())
            .consecutiveCorrect,
        1,
      );
      expect(
        (await (db.select(
          db.chapterMasteryTable,
        )..where((t) => t.chapterId.equals('ch3'))).getSingle()).conceptScore,
        100,
      );

      router.go('/assessment/textbook_ch6_1_14');
      await t.pumpAndSettle();
      expect(find.byType(Image), findsWidgets);
      await tap(find.byKey(const ValueKey('option-0-3')));
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, '提交答案'))
            .onPressed,
        isNull,
      );
      await tap(find.byKey(const ValueKey('option-1-3')));
      await tap(find.text('提交答案'));
      expect(find.text('回答正确'), findsOneWidget);
      final attempts = await db.select(db.quizAttemptsTable).get();
      expect(attempts, hasLength(3));
      expect(attempts.last.userAnswerJson, {
        'indices': [3, 3],
      });
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    });
  }
}
