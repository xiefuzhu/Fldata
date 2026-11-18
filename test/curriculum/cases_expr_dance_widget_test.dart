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
import 'package:fldata/views/lab/cases_expr_dance_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch3_cases_expr_dance'));
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
    testWidgets('cases expression input, matrix, reverse and layout $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      final vm = container.read(playbackProvider.notifier);
      final edit = find.byKey(const ValueKey('cases-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('cases-input-0')),
        '4+2*3-10/5#',
      );
      final apply = find.byKey(const ValueKey('cases-apply-input'));
      await tester.ensureVisible(apply);
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final t = container.read(playbackProvider).timeline!;
      final comparison = t.frames.indexWhere(
        (f) => f.phaseTitle == '查表 Precede(+, *) = <',
      );
      expect(comparison, greaterThan(0));
      vm.seek(comparison.toDouble());
      await tester.pumpAndSettle();
      final matrix = tester.widget<PrecedenceMatrix>(
        find.byType(PrecedenceMatrix),
      );
      expect(matrix.top, '+');
      expect(matrix.current, '*');
      expect(matrix.relation, '<');
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('输出：8'), findsOneWidget);
      vm.seek(comparison - .5);
      await tester.pump();
      expect(
        tester
            .widget<CasesExprDanceStage>(find.byType(CasesExprDanceStage))
            .progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(find.text('输出：—'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'case presets expose bracket error, dance waiting and lesson completion',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      final vm = container.read(playbackProvider.notifier);
      Future<void> preset(int index) async {
        final menu = tester.widget<PopupMenuButton<int>>(
          find.byKey(const ValueKey('cases-preset')),
        );
        menu.onSelected!(index);
        await tester.pumpAndSettle();
      }

      await preset(9);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('左右类型不符'), findsWidgets);
      await preset(4);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('输出：FF'), findsOneWidget);
      await preset(10);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('Mdancers（首→尾）：阿杰 → 小周 → 阿明 → 小林'), findsOneWidget);
      final complete = find.byKey(const ValueKey('lesson-complete'));
      await tester.ensureVisible(complete);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      final rows = await tester.runAsync(
        () => db.select(db.lessonProgressTable).get(),
      );
      expect(
        rows!.singleWhere((r) => r.moduleId == 'ch3_cases_expr_dance').status,
        2,
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
