import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/router/app_router.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('设计题填空 · 部分分、入库与重练 $width', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 950);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          nativeWindowProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FldataApp(),
        ),
      );
      Future<void> open(String path) async {
        router.go(path);
        await t.pumpAndSettle();
      }

      Finder key(String name) => find.byKey(ValueKey(name));
      Future<void> tap(Finder f) async {
        await Scrollable.ensureVisible(t.element(f), alignment: .5);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      await open('/assessment/textbook_ch8_3_01');
      if (width >= 1000) await tap(find.text('关键行填空'));
      Future<void> fill(String second) async {
        await t.enterText(key('code-blank-0'), 'q->key < min->key');
        await t.enterText(key('code-blank-1'), second);
        await t.pumpAndSettle();
        await tap(find.text('提交填空'));
      }

      await fill('p->key');
      expect(find.text('答对 1 / 2 空'), findsOneWidget);
      final row = await db.select(db.quizAttemptsTable).getSingle();
      expect(row.score, 50);
      expect(row.userAnswerJson['correctBlanks'], [true, false]);
      expect(row.userAnswerJson['mode'], 'blanks');
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle()).questionId,
        'textbook_ch8_3_01',
      );
      await tap(find.text('重新作答'));
      await fill('(min -> key)');
      final rows = await db.select(db.quizAttemptsTable).get();
      expect(rows.last.score, 100);
      expect(rows.last.isCorrect, isTrue);
      expect(find.text('答对 2 / 2 空'), findsOneWidget);
      await tap(find.text('完整函数'));
      const source = "Object solve(Map<String,dynamic> data) => data['keys'];";
      await t.enterText(key('solve-editor'), source);
      await tap(find.text('关键行填空'));
      await tap(find.text('完整函数'));
      expect(t.widget<TextField>(key('solve-editor')).controller!.text, source);
      final run = t
          .widget<FilledButton>(find.widgetWithText(FilledButton, '运行判题'))
          .onPressed!;
      await t.runAsync(() async => await (run as Future<void> Function())());
      await t.pumpAndSettle();
      final submitted = (await db.select(db.quizAttemptsTable).get()).last;
      expect(submitted.userAnswerJson['source'], source);
      expect(submitted.userAnswerJson['mode'], 'function');
      expect(submitted.userAnswerJson['passedCases'], [
        true,
        true,
        true,
        false,
        false,
        false,
      ]);
      expect(submitted.score, 50);
      await tap(key('function-case-3'));
      expect(find.text('结构位置'), findsOneWidget);
      expect(find.text('结果[0]'), findsOneWidget);
      await tap(find.text('修改函数并重试'));
      expect(t.widget<TextField>(key('solve-editor')).controller!.text, source);
    });
  }
}
