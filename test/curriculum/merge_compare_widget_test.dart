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
import 'package:fldata/views/lab/merge_compare_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch2_merge_compare'));
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
    testWidgets('merge lesson, input and reverse fit $size', (tester) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      final edit = find.byKey(const ValueKey('merge-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('merge-input-0')),
        '1,4',
      );
      await tester.enterText(
        find.byKey(const ValueKey('merge-input-1')),
        '2,3',
      );
      final apply = find.byKey(const ValueKey('merge-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('merge-result'))).data,
        '结果：1 → 2 → 3 → 4',
      );
      vm.seek(3.5);
      await tester.pump();
      expect(
        tester
            .widget<MergeCompareStage>(find.byType(MergeCompareStage))
            .progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('merge-result'))).data,
        '已确定前缀：空',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'mode changes, invalid sorted input, array result and completion',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      await tester.tap(find.byKey(const ValueKey('merge-operation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('顺序有序归并').last);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.metrics.auxiliarySpace,
        6,
      );
      expect(find.text('新 LC 数据槽 6'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('merge-input')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('merge-input-0')),
        '4,1',
      );
      await tester.tap(find.byKey(const ValueKey('merge-apply-input')));
      await tester.pumpAndSettle();
      expect(find.textContaining('有序归并要求 A、B 各自非递减'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('merge-preset')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('集合 · 无序且部分重合'));
      await tester.pumpAndSettle();
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('merge-result'))).data,
        '结果：5 → 1 → 3 → 2 → 7',
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch2_merge_compare' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      await leave(tester, container, db);
    },
  );
}
