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
import 'package:fldata/models/trace_model.dart';

void main() {
  Future<(ProviderContainer, AppDatabase)> mount(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    await tester.ensureVisible(
      find.byKey(const ValueKey('course-ch1_struct_mapping')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('course-ch1_struct_mapping')));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => db
          .select(db.lessonProgressTable)
          .watch()
          .firstWhere((rows) => rows.isNotEmpty)
          .timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();
    return (container, db);
  }

  for (final size in [
    const Size(390, 844),
    const Size(800, 1100),
    const Size(1360, 860),
  ]) {
    testWidgets(
      'course mapping selection, storage and topology work at $size',
      (tester) async {
        final (container, db) = await mount(tester, size);
        expect(
          container.read(playbackProvider).timeline!.moduleId,
          'ch1_struct_mapping',
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('scene-node-logical-3')));
        await tester.pumpAndSettle();
        expect(container.read(playbackProvider).frameIndex, 4);
        var scene = container.read(playbackProvider).currentFrame!.scene;
        expect(
          scene.nodes.singleWhere((n) => n.id == 'physical-3').visualState,
          NodeVisualState.active,
        );
        expect(
          find.byKey(const ValueKey('memory-slot-physical-3')).hitTestable(),
          findsOneWidget,
        );
        await tester.tap(find.text('链式存储'));
        await tester.pumpAndSettle();
        expect(container.read(playbackProvider).frameIndex, 0);
        await tester.tap(find.text('图形'));
        await tester.pumpAndSettle();
        scene = container.read(playbackProvider).currentFrame!.scene;
        expect(
          scene.edges.where((e) => e.id.startsWith('physical-')).length,
          12,
        );
        await tester.tap(find.byKey(const ValueKey('scene-node-logical-0')));
        await tester.pumpAndSettle();
        expect(container.read(playbackProvider).frameIndex, 1);
        final address = container
            .read(playbackProvider)
            .currentFrame!
            .inlineVars['addr'];
        expect(address, scene.auxTables.single.rows.first[3]);
        await tester.tap(find.text('树形'));
        await tester.pumpAndSettle();
        expect(
          container
              .read(playbackProvider)
              .currentFrame!
              .scene
              .nodes
              .singleWhere((n) => n.id == 'logical-0')
              .label
              .split('\n')
              .length,
          3,
        );
        expect(tester.takeException(), isNull);
        container.read(appRouterProvider).go('/dashboard');
        await tester.pumpAndSettle();
        await tester.runAsync(() => db.select(db.lessonProgressTable).get());
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets(
    'visited frames, explicit completion and catalog/dashboard share persisted state',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      var rows = await tester.runAsync(
        () => db.select(db.lessonProgressTable).get(),
      );
      expect(
        rows!.single.watchedFullTrace,
        isFalse,
        reason: 'jumping to the end is not watching every frame',
      );
      vm.first();
      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        vm.stepInto();
        await tester.pumpAndSettle();
      }
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere((rows) => rows.single.watchedFullTrace)
            .timeout(const Duration(seconds: 5)),
      );
      await tester.tap(find.byKey(const ValueKey('lesson-complete')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere((rows) => rows.single.status == 2)
            .timeout(const Duration(seconds: 5)),
      );
      container.read(appRouterProvider).go('/catalog?chapter=ch1');
      await tester.pumpAndSettle();
      expect(find.text('已学'), findsOneWidget);
      container.read(appRouterProvider).go('/dashboard');
      await tester.pumpAndSettle();
      final recent = find.text('逻辑结构与存储结构映射');
      expect(recent, findsOneWidget);
      await tester.tap(recent);
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).timeline!.moduleId,
        'ch1_struct_mapping',
      );
      container.read(appRouterProvider).go('/dashboard');
      await tester.pumpAndSettle();
      final days = await tester.runAsync(
        () => db.select(db.dailyStudyStatsTable).get(),
      );
      expect(days!.single.labsCompleted, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('small phone with larger text keeps course controls usable', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final (container, db) = await mount(tester, const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('mini-code-open')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    container.read(appRouterProvider).go('/dashboard');
    await tester.pumpAndSettle();
    await tester.runAsync(() => db.select(db.lessonProgressTable).get());
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
