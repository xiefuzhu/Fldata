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
import 'package:fldata/views/lab/linklist_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch2_linklist_ops'));
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
    testWidgets('linked list head switch, custom input and reverse fit $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      final toggle = find.byKey(const ValueKey('linklist-head'));
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).timeline!.inputSummary,
        contains('无头结点'),
      );
      final edit = find.byKey(const ValueKey('linklist-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('linklist-input-0')),
        'M,N',
      );
      await tester.enterText(
        find.byKey(const ValueKey('linklist-input-1')),
        '1',
      );
      final apply = find.byKey(const ValueKey('linklist-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('linklist-chain'))).data,
        'L 可达数据链：X → M → N',
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('linklist-chain'))).data,
        'L 可达数据链：M → N',
      );
      final t = container.read(playbackProvider).timeline!;
      vm.seek(t.frames.length - 2.5);
      await tester.pump();
      expect(
        tester.widget<LinkListStage>(find.byType(LinkListStage)).progress,
        .5,
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'wrong order pauses on loss then single steps to self-cycle and reverses',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      await tester.tap(find.byKey(const ValueKey('linklist-wrong')));
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.play();
      vm.advance(const Duration(seconds: 20));
      await tester.pumpAndSettle();
      final f = container.read(playbackProvider).currentFrame!;
      expect(f.phaseTitle, '错误① · 先覆盖入口');
      expect(f.scene.nodes.where((n) => n.isOrphanLeak).length, 3);
      expect(container.read(playbackProvider).isPlaying, isFalse);
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .edges
            .firstWhere((e) => e.fromNodeId == 'new')
            .toNodeId,
        'new',
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .nodes
            .any((n) => n.isOrphanLeak),
        isFalse,
      );
      await tester.tap(find.byKey(const ValueKey('linklist-wrong')));
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .timeline!
            .frames
            .any((f) => f.isErrorState),
        isFalse,
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch2_linklist_ops' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      await leave(tester, container, db);
    },
  );
}
