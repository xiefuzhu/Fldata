import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/router/app_router.dart';

Future<(ProviderContainer, AppDatabase)> mount(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
  String courseId = 'ch5_bitree_traverse',
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
  container
      .read(appRouterProvider)
      .go('/catalog?chapter=${courseId.split('_').first}');
  await tester.pumpAndSettle();
  final course = find.byKey(ValueKey('course-$courseId'));
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
