import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';
import 'package:fldata/views/lab/recursion_hanoi_stage.dart';

void main() {
  Future<(ProviderContainer, AppDatabase)> mount(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        nativeWindowProvider.overrideWithValue(false),
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FldataApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go('/catalog?chapter=ch3');
    await tester.pumpAndSettle();
    final course = find.byKey(const ValueKey('course-ch3_recursion_hanoi'));
    await tester.ensureVisible(course);
    await tester.pumpAndSettle();
    await tester.tap(course);
    await tester.pumpAndSettle();
    return (container, db);
  }

  Future<void> leave(
    WidgetTester tester,
    ProviderContainer container,
    AppDatabase db,
  ) async {
    container.read(appRouterProvider).go('/dashboard');
    await tester.pumpAndSettle();
    await tester.runAsync(() => db.select(db.lessonProgressTable).get());
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final size in [
    const Size(390, 844),
    const Size(990, 856),
    const Size(1360, 860),
    const Size(320, 640),
  ]) {
    testWidgets('recursion input, three views, seek and rewind $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      final vm = container.read(playbackProvider.notifier);
      expect(tester.takeException(), isNull);
      final edit = find.byKey(const ValueKey('recursion-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('recursion-input-value')),
        '4',
      );
      await tester.tap(find.byKey(const ValueKey('recursion-apply-input')));
      await tester.pumpAndSettle();
      final t = container.read(playbackProvider).timeline!;
      expect(
        (await db.select(db.lessonProgressTable).getSingle()).customRunCount,
        1,
      );
      final chapter = await (db.select(
        db.chapterMasteryTable,
      )..where((t) => t.chapterId.equals('ch3'))).getSingle();
      expect(chapter.labCompletionRate, 25);
      final move = t.frames.indexWhere((f) => f.metrics.moves == 1);
      vm.seek(move - .5);
      await tester.pump();
      expect(
        tester
            .widget<RecursionHanoiStage>(find.byType(RecursionHanoiStage))
            .progress,
        .5,
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('搬移 15 / 15'), findsOneWidget);
      final tree = tester.widget<DsStageCanvas>(
        find.descendant(
          of: find.byType(RecursionTree),
          matching: find.byType(DsStageCanvas),
        ),
      );
      expect(
        tree.scene.nodes.every((n) => n.visualState == NodeVisualState.normal),
        true,
      );
      expect(container.read(playbackProvider).currentFrame!.callStack, isEmpty);
      vm.first();
      await tester.pumpAndSettle();
      expect(find.text('搬移 0 / 15'), findsOneWidget);
      if (size.width == 1360) {
        final badge = db.select(db.achievementsTable)
          ..where((r) => r.achievementId.equals('hanoi_master'));
        expect(await badge.getSingleOrNull(), isNull);
        await tester.tap(edit);
        await tester.pumpAndSettle();
        final slider = find.byKey(const ValueKey('hanoi-disks'));
        final rect = tester.getRect(slider);
        final trackWidth = rect.width - 48;
        await tester.dragFrom(
          Offset(rect.left + 24 + trackWidth * .6, rect.center.dy),
          Offset(trackWidth * .2, 0),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('recursion-input-value')),
              )
              .controller!
              .text,
          '5',
        );
        await tester.tap(find.byKey(const ValueKey('recursion-apply-input')));
        await tester.pumpAndSettle();
        vm.last();
        await tester.pumpAndSettle();
        expect((await badge.getSingle()).unlockedAt, isNotNull);
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'RetLoc1 and RetLoc2 visible with parent PC, other modes and learning progress',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 1000));
      final vm = container.read(playbackProvider.notifier),
          t = container.read(playbackProvider).timeline!;
      for (final dest in ['RetLoc1', 'RetLoc2']) {
        final index = t.frames.indexWhere((f) => f.phaseTitle == '弹栈 → $dest');
        vm.seek(index.toDouble());
        await tester.pumpAndSettle();
        expect(find.text('当前 PC：$dest'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('recursion-return-event')),
          findsOneWidget,
        );
      }
      Future<void> preset(String text) async {
        await tester.tap(find.byKey(const ValueKey('recursion-preset')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      await preset('阶乘 · 5!');
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('结果：120'), findsOneWidget);
      await preset('斐波 · Fib(5) 重复子问题');
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('结果：5'), findsOneWidget);
      await preset('链表 · 先输出再递归');
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('输出：12 → 24 → 36 → 48'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch3_recursion_hanoi' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
