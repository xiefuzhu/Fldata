import 'package:flutter/services.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/router/app_router.dart';

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(800, 1100),
    const Size(1360, 860),
    const Size(1280, 620),
  ]) {
    testWidgets('navigation and settings fit $size', (tester) async {
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
      final initialError = tester.takeException();
      if (initialError is FlutterError) debugPrint(initialError.toStringDeep());
      expect(initialError, isNull);
      expect(find.text('让结构，一目了然'), findsOneWidget);
      expect(
        find.byType(size.width < 600 ? NavigationBar : NavigationRail),
        findsOneWidget,
      );
      if (size.width == 1360) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
      for (final route in [
        '/catalog',
        '/lab/overview',
        '/assessment',
        '/settings',
      ]) {
        container.read(appRouterProvider).go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        if (route == '/lab/overview') {
          final mode = size.width < 600
              ? 'compact'
              : size.width < 1100
              ? 'medium'
              : 'expanded';
          expect(find.byKey(ValueKey('workspace-$mode')), findsOneWidget);
        }
      }
      await tester.tap(find.text('紫罗兰'));
      await tester.pumpAndSettle();
      expect(preferences.getString('theme'), contains('violetExpressive'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
