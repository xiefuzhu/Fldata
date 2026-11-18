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
    container.read(appRouterProvider).go('/catalog?chapter=ch4');
    await tester.pumpAndSettle();
    final course = find.byKey(const ValueKey('course-ch4_array_matrix'));
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
    const Size(320, 640),
    const Size(390, 844),
    const Size(990, 856),
    const Size(1360, 860),
  ]) {
    testWidgets(
      'matrix cell tap, order switch and sparse parameters at $size',
      (tester) async {
        final (container, db) = await mount(
          tester,
          size,
          textScale: size.width == 320 ? 1.7 : 1,
        );
        final vm = container.read(playbackProvider.notifier);
        final cell = find.byKey(const ValueKey('scene-node-cell-0-2-0'));
        await tester.ensureVisible(cell);
        await tester.pumpAndSettle();
        await tester.tap(cell);
        await tester.pump();
        vm.last();
        await tester.pumpAndSettle();
        expect(
          container.read(playbackProvider).currentFrame!.inlineVars['LOC'],
          '4128',
        );
        final order = find.text('行主序');
        await tester.ensureVisible(order);
        await tester.tap(order);
        await tester.pumpAndSettle();
        vm.last();
        await tester.pumpAndSettle();
        expect(
          container.read(playbackProvider).currentFrame!.inlineVars['LOC'],
          '4104',
        );
        final mode = find.byKey(const ValueKey('matrix-mode'));
        await tester.ensureVisible(mode);
        await tester.tap(mode);
        await tester.pumpAndSettle();
        await tester.tap(find.text('快速转置').last);
        await tester.pumpAndSettle();
        final edit = find.text('参数');
        await tester.ensureVisible(edit);
        await tester.tap(edit);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('matrix-triples')),
          '1,2,-7;3,1,4',
        );
        final apply = find.text('应用');
        await tester.ensureVisible(apply);
        await tester.tap(apply);
        await tester.pumpAndSettle();
        vm.last();
        await tester.pumpAndSettle();
        expect(
          container
              .read(playbackProvider)
              .currentFrame!
              .scene
              .auxTables
              .last
              .rows,
          [
            ['1', '(1,3,4)'],
            ['2', '(2,1,-7)'],
          ],
        );
        vm.first();
        await tester.pumpAndSettle();
        expect(
          container.read(playbackProvider).currentFrame!.metrics.writes,
          0,
        );
        expect(tester.takeException(), isNull);
        await leave(tester, container, db);
      },
    );
  }
}
