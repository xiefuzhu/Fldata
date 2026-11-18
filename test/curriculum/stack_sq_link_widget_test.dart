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
import 'package:fldata/views/lab/stack_sq_link_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch3_stack_sq_link'));
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
    const Size(990, 856),
    const Size(1360, 860),
    const Size(320, 640),
  ]) {
    testWidgets('stack input, next empty top, reverse and layout $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      if (size.width == 990) {
        final stage = tester.getRect(find.byType(StackSqLinkStage));
        final bottom = find.byKey(const ValueKey('scene-node-slot-0'));
        expect(
          stage.contains(tester.getTopLeft(bottom)),
          true,
          reason: 'initial stack bottom must be visible',
        );
        expect(
          stage.contains(tester.getBottomRight(bottom)),
          true,
          reason: 'initial stack bottom must fit the stage',
        );
      }
      final vm = container.read(playbackProvider.notifier);
      final edit = find.byKey(const ValueKey('stack-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('stack-input-0')),
        '1,2',
      );
      await tester.enterText(find.byKey(const ValueKey('stack-input-2')), '3');
      await tester.enterText(find.byKey(const ValueKey('stack-input-3')), '9');
      final apply = find.byKey(const ValueKey('stack-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('stack-order'))).data,
        '栈（底→顶）：1 → 2 → 9',
      );
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .pointers
            .singleWhere((p) => p.id == 'top')
            .targetNodeId,
        'end',
      );
      vm.seek(2.5);
      await tester.pump();
      expect(
        tester.widget<StackSqLinkStage>(find.byType(StackSqLinkStage)).progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('stack-order'))).data,
        '栈（底→顶）：1 → 2',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'shared collision pause, right stack and linked last pop, progress',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      Future<void> preset(String text) async {
        await tester.tap(find.byKey(const ValueKey('stack-preset')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      final vm = container.read(playbackProvider.notifier);
      await preset('共享 · 两栈相邻已满');
      vm.play();
      vm.advance(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(container.read(playbackProvider).isPlaying, false);
      expect(find.text('OVERFLOW'), findsOneWidget);
      await preset('共享 · 右栈向左增长');
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('stack-right-order')))
            .data,
        '右栈（底→顶）：8 → 9 → 99',
      );
      await preset('链栈 · 删除唯一节点');
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('输出 e：42'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('stack-order'))).data,
        '栈（底→顶）：空',
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch3_stack_sq_link' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
