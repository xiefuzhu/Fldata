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
    final course = find.byKey(const ValueKey('course-ch4_glist_explorer'));
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
    const Size(320, 640),
    const Size(990, 856),
    const Size(1360, 860),
  ]) {
    testWidgets(
      'edit, peel, switch representation and branch from playback at $size',
      (tester) async {
        final (container, db) = await mount(
          tester,
          size,
          textScale: size.width == 320 ? 1.7 : 1,
        );
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        final edit = find.text('表达式'),
            head = find.byKey(const ValueKey('peel-head')),
            tail = find.byKey(const ValueKey('peel-tail')),
            mode = find.byKey(const ValueKey('glist-mode'));
        final vm = container.read(playbackProvider.notifier);
        String current() =>
            container.read(playbackProvider).currentFrame!.inlineVars['当前值']!;
        await tap(edit);
        await tester.enterText(
          find.byKey(const ValueKey('glist-expression')),
          '(a,)',
        );
        await tap(find.text('应用'));
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('glist-expression')),
          'M = ((a), (), b)',
        );
        await tap(find.text('应用'));
        await tap(tail);
        expect(current(), '((), b)');
        await tap(mode);
        await tap(find.text('头尾链表').last);
        expect(current(), '((), b)');
        await tap(head);
        expect(current(), '()');
        expect(tester.widget<TextButton>(head).onPressed, isNull);
        await tap(mode);
        await tap(find.text('扩展线性链表').last);
        vm.stepBack();
        await tester.pumpAndSettle();
        expect(current(), '((), b)');
        await tap(tail);
        expect(current(), '(b)');
        await tap(head);
        expect(current(), 'b');
        expect(tester.widget<TextButton>(tail).onPressed, isNull);
        await tap(find.byTooltip('回到原表'));
        expect(current(), '((a), (), b)');
        expect(tester.takeException(), isNull);
        await leave(tester, container, db);
      },
    );
  }
}
