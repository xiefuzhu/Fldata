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
import 'package:fldata/views/lab/complex_stage.dart';

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
    container.read(appRouterProvider).go('/catalog?chapter=ch1');
    await tester.pumpAndSettle();
    final course = find.byKey(const ValueKey('course-ch1_adt_complex'));
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
    testWidgets('complex lesson input and separate writes fit $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      expect(
        container.read(playbackProvider).timeline!.moduleId,
        'ch1_adt_complex',
      );
      final edit = find.byKey(const ValueKey('complex-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('complex-input-0')),
        '4',
      );
      final apply = find.byKey(const ValueKey('complex-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['A'],
        '4 + 1i',
      );
      vm.seek(1.5);
      await tester.pump();
      expect(
        tester.widget<ComplexStage>(find.byType(ComplexStage)).progress,
        .5,
      );
      vm.seek(3);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('complex-C-real'))).data,
        'realpart = 5',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('complex-C-imag'))).data,
        'imagpart = -9',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('complex-C-imag')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('complex-C-imag')).hitTestable(),
        findsOneWidget,
      );
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('complex-C-imag'))).data,
        'imagpart = 3',
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('complex-C-imag'))).data,
        'imagpart = -9',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'operation, zero preset, error pause and completion integrate with workbench',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      await tester.tap(find.byKey(const ValueKey('complex-operation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Multiply').last);
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).timeline!.inputSummary,
        startsWith('Multiply'),
      );
      await tester.tap(find.byKey(const ValueKey('complex-preset')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('边界 · 除数为零'));
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.play();
      vm.advance(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.isErrorState,
        isTrue,
      );
      expect(container.read(playbackProvider).isPlaying, isFalse);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('complex-C-real'))).data,
        'realpart = 9',
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch1_adt_complex' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      await leave(tester, container, db);
    },
  );
}
