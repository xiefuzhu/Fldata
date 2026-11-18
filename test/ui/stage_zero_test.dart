import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/router/app_router.dart';
import 'package:fldata/ui/managers/build_manager_stack.dart';
import 'package:fldata/ui/managers/playback_actions.dart';

void main() {
  testWidgets(
    'playback keys dispatch only with an active action scope; editing is protected',
    (tester) async {
      final calls = <PlaybackCommand>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyManager(
              openCommand: () {},
              child: PlaybackActions(
                onCommand: calls.add,
                child: Focus(
                  autofocus: true,
                  child: Column(
                    children: [
                      const Text('stage'),
                      TextField(focusNode: focus),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final key in [
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.home,
        LogicalKeyboardKey.end,
      ]) {
        await tester.sendKeyEvent(key);
      }
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(calls, [
        PlaybackCommand.toggle,
        PlaybackCommand.stepBack,
        PlaybackCommand.stepInto,
        PlaybackCommand.first,
        PlaybackCommand.last,
        PlaybackCommand.nextMilestone,
      ]);
      calls.clear();
      focus.requestFocus();
      await tester.pump();
      for (final key in [
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.home,
        LogicalKeyboardKey.end,
      ]) {
        await tester.sendKeyEvent(key);
      }
      expect(calls, isEmpty);
    },
  );
  testWidgets(
    'dashboard sorts recent visits, excludes future/mastered reviews, and switches layout in place',
    (tester) async {
      tester.view.physicalSize = const Size(1360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.utc(2026, 11, 15, 8);
      for (var i = 0; i < 12; i++) {
        await db
            .into(db.lessonProgressTable)
            .insert(
              LessonProgressTableCompanion.insert(
                moduleId: 'recent-$i',
                chapterId: 'ch2',
                lastVisitedAt: now.add(Duration(minutes: i)),
              ),
            );
      }
      for (final entry in [
        ('due', now.subtract(const Duration(days: 1)), false),
        ('future', now.add(const Duration(days: 1)), false),
        ('mastered', now, true),
      ]) {
        await db
            .into(db.wrongQuestionBookTable)
            .insert(
              WrongQuestionBookTableCompanion.insert(
                questionId: entry.$1,
                chapterId: 'ch2',
                nextReviewAt: entry.$2,
                isMastered: Value(entry.$3),
              ),
            );
      }
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          nativeWindowProvider.overrideWithValue(false),
          studyClockProvider.overrideWith((ref) => Stream.value(now)),
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
      expect(find.byKey(const ValueKey('dashboard-panels')), findsOneWidget);
      expect(find.text('recent-11'), findsOneWidget);
      expect(find.text('due'), findsOneWidget);
      expect(find.text('future'), findsNothing);
      expect(find.text('mastered'), findsNothing);
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(1280, 620);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('dashboard-summary')), findsOneWidget);
      expect(find.text('今日到期复习：1 题'), findsOneWidget);
      expect(find.byKey(const PageStorageKey('due-reviews')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
