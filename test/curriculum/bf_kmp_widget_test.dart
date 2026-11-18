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
    final course = find.byKey(const ValueKey('course-ch4_bf_kmp_lab'));
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

  for (final size in [const Size(390, 844), const Size(1360, 860)]) {
    testWidgets('catalog to matching lab, edit strings and replay at $size', (
      tester,
    ) async {
      final (container, db) = await mount(tester, size);
      final edit = find.text('编辑串');
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'aaaaab');
      await tester.enterText(find.byType(TextField).at(1), 'aab');
      await tester.tap(find.text('应用'));
      await tester.pumpAndSettle();
      final toggle = find.text('next').first;
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      final last = container.read(playbackProvider).currentFrame!;
      expect(last.inlineVars['BF.result'], '4');
      expect(last.inlineVars['KMP.result'], '4');
      expect(last.scene.auxTables.first.title, 'nextval');
      vm.first();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['KMP.i'],
        '1',
      );
      for (final mode in ['递推显微镜', '环串检测']) {
        final menu = find.byKey(const ValueKey('match-mode'));
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text(mode).last);
        await tester.pumpAndSettle();
        vm.last();
        await tester.pumpAndSettle();
        final f = container.read(playbackProvider).currentFrame!;
        if (mode == '递推显微镜') {
          expect(f.scene.auxTables.single.rows.map((r) => r.last), [
            '0',
            '0',
            '2',
          ]);
        } else {
          expect(f.scene.auxTables.single.rows.map((r) => r[1]), [
            'aab',
            'aba',
            'baa',
          ]);
        }
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
