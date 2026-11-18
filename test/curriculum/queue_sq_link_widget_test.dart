import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/curriculum/ch3_stack_queue/queue_sq_link.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';
import 'package:fldata/views/lab/queue_sq_link_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch3_queue_sq_link'));
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
    testWidgets('queue edit, ring wrap, reverse and responsive layout $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      final vm = container.read(playbackProvider.notifier),
          edit = find.byKey(const ValueKey('queue-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('queue-input-0')),
        '8,9',
      );
      await tester.enterText(find.byKey(const ValueKey('queue-input-1')), '5');
      await tester.enterText(find.byKey(const ValueKey('queue-input-2')), '2');
      final apply = find.byKey(const ValueKey('queue-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('有效队序（首→尾）：8 → 9 → 99'), findsOneWidget);
      final t = container.read(playbackProvider).timeline!,
          i = t.frames.indexWhere((f) => f.phaseTitle.startsWith('② rear'));
      vm.seek(i - .5);
      await tester.pump();
      expect(
        tester.widget<QueueSqLinkStage>(find.byType(QueueSqLinkStage)).progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(find.text('有效队序（首→尾）：8 → 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'demo mode switch, reserved sector, linked tail reset and progress',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 1000));
      final vm = container.read(playbackProvider.notifier);
      Future<void> preset(String text) async {
        await tester.tap(find.byKey(const ValueKey('queue-preset')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      await preset('对照 · 线性假溢出');
      vm.play();
      vm.advance(const Duration(seconds: 100));
      await tester.pumpAndSettle();
      expect(container.read(playbackProvider).currentFrame!.isErrorState, true);
      expect(container.read(playbackProvider).isPlaying, false);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('有效队序（首→尾）：4 → 9'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('queue-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('循环队列').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<QueueSqLinkStage>(find.byType(QueueSqLinkStage))
            .input
            .operation,
        QueueOperation.demo,
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('有效队序（首→尾）：4 → 9 → 10 → 11'), findsOneWidget);
      final canvas = tester.widget<DsStageCanvas>(find.byType(DsStageCanvas));
      expect(
        (canvas.backdropPainter! as QueueReservedSectorPainter).visible,
        true,
      );
      await preset('链队 · 删除唯一节点');
      final trace = container.read(playbackProvider).timeline!,
          reset = trace.frames.indexWhere(
            (f) => f.phaseTitle.startsWith('rear = front'),
          );
      vm.seek(reset.toDouble());
      await tester.pumpAndSettle();
      expect(find.text('rear = front · 先复位尾指针'), findsOneWidget);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('输出：42'), findsOneWidget);
      expect(find.text('有效队序（首→尾）：空'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch3_queue_sq_link' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
