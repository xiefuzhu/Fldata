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
import 'package:fldata/views/lab/sqlist_stage.dart';

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
    container.read(appRouterProvider).go('/catalog?chapter=ch2');
    await tester.pumpAndSettle();
    final course = find.byKey(const ValueKey('course-ch2_sqlist_ops'));
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
    const Size(800, 1100),
    const Size(1360, 860),
    const Size(320, 640),
  ]) {
    testWidgets('SqList input, arc playback and reverse fit $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      final edit = find.byKey(const ValueKey('sqlist-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('sqlist-input-0')),
        '1,2,3',
      );
      final apply = find.byKey(const ValueKey('sqlist-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      final trace = container.read(playbackProvider).timeline!;
      final k = trace.frames.indexWhere(
        (f) => f.phaseTitle == '准备复制 [2] → [3]',
      );
      vm.seek(k + .5);
      await tester.pump();
      expect(tester.widget<SqListStage>(find.byType(SqListStage)).progress, .5);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['length'],
        '4',
      );
      expect(container.read(playbackProvider).currentFrame!.metrics.moves, 2);
      vm.first();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['length'],
        '3',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets('SqList operation, error preset, pause and completion persist', (
    tester,
  ) async {
    final (container, db) = await mount(tester, const Size(1360, 860));
    await tester.tap(find.byKey(const ValueKey('sqlist-operation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GetElem').last);
    await tester.pumpAndSettle();
    expect(
      container.read(playbackProvider).timeline!.inputSummary,
      startsWith('GetElem'),
    );
    await tester.tap(find.byKey(const ValueKey('sqlist-preset')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('边界 · 表满插入'));
    await tester.pumpAndSettle();
    final vm = container.read(playbackProvider.notifier);
    vm.play();
    vm.advance(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(
      container.read(playbackProvider).currentFrame!.inlineVars['result'],
      'OVERFLOW',
    );
    expect(container.read(playbackProvider).isPlaying, isFalse);
    await tester.tap(find.byKey(const ValueKey('lesson-complete')));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => db
          .select(db.lessonProgressTable)
          .watch()
          .firstWhere(
            (rows) => rows.any(
              (r) => r.moduleId == 'ch2_sqlist_ops' && r.status == 2,
            ),
          )
          .timeout(const Duration(seconds: 5)),
    );
    await leave(tester, container, db);
  });
}
