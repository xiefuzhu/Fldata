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
import 'package:fldata/views/lab/complexity_stage.dart';
import 'package:flutter/gestures.dart';
import 'package:fldata/enum/ds_enums.dart';

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
    final course = find.byKey(const ValueKey('course-ch1_complexity_lab'));
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

  Future<void> preset(WidgetTester tester, String name) async {
    final menu = find.byKey(const ValueKey('complexity-preset'));
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  for (final size in [
    const Size(390, 844),
    const Size(800, 1100),
    const Size(1360, 860),
    const Size(320, 640),
  ]) {
    testWidgets('complexity modes and reverse fit $size', (tester) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      expect(tester.takeException(), isNull);
      await preset(tester, '增长爆炸 · n=20');
      expect(find.text('七种增长量级 · n=20'), findsOneWidget);
      await preset(tester, '矩阵频度 · n=3');
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .metrics
            .statementCounts['line-6'],
        27,
      );
      await preset(tester, '奇数长度逆序 · n=7');
      vm.last();
      await tester.pumpAndSettle();
      final tempBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byKey(const ValueKey('scene-node-temp')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (tempBox.decoration as BoxDecoration).color,
        Colors.deepPurple.shade700,
      );
      expect(find.text('原地：1 槽 · O(1) · 写 9 次'), findsOneWidget);
      expect(find.text('副本：7 槽 · O(n) · 写 7 次'), findsOneWidget);
      vm.first();
      await tester.pumpAndSettle();
      expect(find.text('原地：0 槽 · O(1) · 写 0 次'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  testWidgets(
    'curve mouse hover and touch select exact integer n and preserve function values',
    (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GrowthChart(n: 5))),
      );
      await tester.pumpAndSettle();
      final plot = tester.getRect(find.byKey(const ValueKey('growth-plot')));
      Offset point(int n) => Offset(
        plot.left + 42 + (n - 1) / 31 * (plot.width - 54),
        plot.top + 100,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: point(20));
      await mouse.moveTo(point(20));
      await tester.pumpAndSettle();
      expect(find.text('七种增长量级 · n=20'), findsOneWidget);
      expect(find.text('指数增长：2^20 = 1,048,576'), findsOneWidget);
      await mouse.removePointer();
      await tester.pumpAndSettle();
      await tester.tapAt(point(10));
      await tester.pumpAndSettle();
      expect(find.text('七种增长量级 · n=10'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('growth-log-scale')));
      await tester.pumpAndSettle();
      expect(find.textContaining('线性纵轴按'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'heat bars follow frame rollback, language mapping and a first multiply breakpoint',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1360, 860));
      await preset(tester, '矩阵频度 · n=3');
      final vm = container.read(playbackProvider.notifier);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('line-frequency-6')))
            .data,
        '27 次',
      );
      vm.setLanguage(CodeLang.dart);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('line-frequency-6')))
            .data,
        '27 次',
      );
      vm.first();
      vm.toggleBreakpoint(CodeLang.dart, 6);
      vm.play();
      vm.advance(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(container.read(playbackProvider).isPlaying, isFalse);
      expect(
        container
            .read(playbackProvider)
            .currentFrame!
            .metrics
            .statementCounts['line-6'],
        1,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('line-frequency-6')),
        180,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('code-lines-dart')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('line-frequency-6')))
            .data,
        '1 次',
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('line-frequency-6')), findsNothing);
      await leave(tester, container, db);
    },
  );
}
