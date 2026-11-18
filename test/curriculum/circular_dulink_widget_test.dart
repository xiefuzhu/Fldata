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
import 'package:fldata/views/lab/circular_dulink_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch2_circular_dulink'));
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
    testWidgets('circular lesson merge, input and reverse fit $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      final edit = find.byKey(const ValueKey('circular-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('circular-input-0')),
        'M,N',
      );
      await tester.enterText(
        find.byKey(const ValueKey('circular-input-1')),
        'Q',
      );
      final apply = find.byKey(const ValueKey('circular-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('circular-order'))).data,
        '从 HA 沿 next：M → N → Q',
      );
      vm.seek(4);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('circular-dangling')), findsOneWidget);
      vm.seek(3.5);
      await tester.pump();
      expect(
        tester
            .widget<CircularDulinkStage>(find.byType(CircularDulinkStage))
            .progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('circular-order'))).data,
        '从 HA 沿 next：M → N',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'dual operation, swapped-order error pause, single step and completion',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      await tester.tap(find.byKey(const ValueKey('circular-operation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('双向表插入').last);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .auxTables
            .first
            .rows
            .first[2],
        '0',
      );
      await tester.tap(find.byKey(const ValueKey('circular-operation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('四指针误序反例').last);
      await tester.pumpAndSettle();
      vm.play();
      vm.advance(const Duration(seconds: 20));
      await tester.pumpAndSettle();
      expect(container.read(playbackProvider).isPlaying, isFalse);
      expect(
        container.read(playbackProvider).currentFrame!.phaseTitle,
        '错误④ · 提前覆盖 p->prior',
      );
      vm.stepInto();
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .edges
            .singleWhere((e) => e.id == 'new-next')
            .toNodeId,
        'new',
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch2_circular_dulink' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      await leave(tester, container, db);
    },
  );
}
