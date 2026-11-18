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
import 'package:fldata/views/lab/cases_polyn_book_stage.dart';

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
    final course = find.byKey(const ValueKey('course-ch2_cases_polyn_book'));
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
    testWidgets('polynomial input, cancellation, reverse and layout $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('cases-result'))).data,
        '结果：7 + 11x + 22x^7 + 5x^17',
      );
      final edit = find.byKey(const ValueKey('cases-input'));
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('cases-input-0')),
        '2:0,5:4',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cases-input-1')),
        '-2:0,3:2',
      );
      final apply = find.byKey(const ValueKey('cases-apply-input'));
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('cases-result'))).data,
        '结果：3x^2 + 5x^4',
      );
      final timeline = container.read(playbackProvider).timeline!;
      final free = timeline.frames.indexWhere(
        (f) => f.phaseTitle == '同指数相消 · 释放 A 节点',
      );
      vm.seek(free.toDouble());
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.isErrorState,
        false,
      );
      vm.seek(free + .5);
      await tester.pump();
      expect(
        tester
            .widget<CasesPolynBookStage>(find.byType(CasesPolynBookStage))
            .progress,
        .5,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .nodes
            .any((n) => n.isDeleted),
        false,
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  for (final size in [const Size(1360, 860), const Size(320, 640)]) {
    testWidgets('book storage, result reuse, delete and progress $size', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      Future<void> tapKey(String key) async {
        final target = find.byKey(ValueKey(key));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tapKey('cases-preset');
      await tester.tap(find.text('图书 · 链式插入第二位'));
      await tester.pumpAndSettle();
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      List<String> ids() => container
          .read(playbackProvider)
          .currentFrame!
          .scene
          .auxTables
          .singleWhere((t) => t.id == 'books')
          .rows
          .map((r) => r[0])
          .toList();
      expect(ids(), ['DS01', 'DS04', 'DS02', 'DS03']);
      await tapKey('book-use-result');
      vm.last();
      await tester.pumpAndSettle();
      expect(ids(), ['DS01', 'DS04', 'DS02', 'DS03']);
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .auxTables
            .first
            .rows
            .first[0],
        'FOUND',
      );
      await tapKey('book-storage');
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .scene
            .nodes
            .every((n) => n.id.startsWith('slot-')),
        true,
      );
      await tapKey('cases-operation');
      await tester.tap(find.text('图书按位序删除').last);
      await tester.pumpAndSettle();
      vm.last();
      await tester.pumpAndSettle();
      expect(ids(), ['DS01', 'DS02', 'DS03']);
      await tapKey('book-use-result');
      vm.last();
      await tester.pumpAndSettle();
      expect(ids(), ['DS01', 'DS02', 'DS03']);
      await tapKey('lesson-complete');
      await tester.runAsync(
        () => db
            .select(db.lessonProgressTable)
            .watch()
            .firstWhere(
              (rows) => rows.any(
                (r) => r.moduleId == 'ch2_cases_polyn_book' && r.status == 2,
              ),
            )
            .timeout(const Duration(seconds: 5)),
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
