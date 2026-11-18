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
    testWidgets('指针沙盒 · 连线、实时泄漏、撤销及交换顺序 $width', (t) async {
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

      Future<void> connect(String source, String target) async {
        await tap(key('port-$source'));
        await tap(key('target-$target'));
      }

      await open('/assessment');
      await tap(find.byTooltip('筛选题型'));
      await tap(find.widgetWithText(PopupMenuItem<int>, '指针操作'));
      expect(find.text('符合条件 5 项'), findsOneWidget);
      await tap(key('practice_ch2_after'));
      await connect('B.next', 'S');
      expect(find.textContaining('发现结点 [C] 指针丢失'), findsOneWidget);
      await tap(find.text('撤销上一步'));
      if (width >= 1000) {
        final from = key('port-S.next'), to = key('target-C');
        await Scrollable.ensureVisible(t.element(from), alignment: .5);
        await t.pumpAndSettle();
        await t.dragFrom(
          t.getCenter(from),
          t.getCenter(to) - t.getCenter(from),
        );
        await t.pumpAndSettle();
        expect(find.textContaining('1. S.next → C'), findsOneWidget);
      } else {
        await connect('S.next', 'C');
      }
      await connect('B.next', 'S');
      await tap(find.text('提交指针图'));
      expect(find.textContaining('100 分 · 连接正确'), findsOneWidget);
      final first = await db.select(db.quizAttemptsTable).getSingle();
      expect(first.userAnswerJson['zeroLeak'], isFalse);
      expect(first.userAnswerJson['next'], {
        'A': 'B',
        'B': 'S',
        'S': 'C',
        'C': null,
      });
      await open('/assessment/textbook_ch2_1_14');
      await tap(find.text('打开配套指针演练'));
      await tap(find.text('指令排序'));
      await tap(key('card-2'));
      await tap(find.text('提交指针图'));
      expect(find.textContaining('0 分 · 发现结点'), findsOneWidget);
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle()).questionId,
        'practice_ch2_remove',
      );
      await tap(find.text('重新演练'));
      for (final i in [1, 0, 2]) {
        await tap(key('card-$i'));
      }
      await tap(find.text('提交指针图'));
      expect(find.textContaining('100 分 · 连接正确'), findsOneWidget);
      final attempts = await db.select(db.quizAttemptsTable).get();
      expect(attempts, hasLength(3));
      expect(attempts.last.userAnswerJson['order'], [1, 0, 2]);
      expect(attempts.last.userAnswerJson['deleted'], ['B']);
      expect(attempts.last.userAnswerJson['zeroLeak'], true);
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle())
            .consecutiveCorrect,
        1,
      );
      await open('/assessment/practice_ch3_dequeue');
      await connect('p', 'A');
      await connect('H.next', 'NULL');
      await connect('rear', 'H');
      await tap(find.byTooltip('释放结点'));
      await tap(find.text('free(p) · A'));
      await tap(find.text('提交指针图'));
      final queueAttempt = (await db.select(db.quizAttemptsTable).get()).last;
      expect(queueAttempt.isCorrect, isTrue);
      expect(queueAttempt.userAnswerJson['roots'], {
        'front': 'H',
        'rear': 'H',
        'p': null,
      });
      expect(queueAttempt.userAnswerJson['deleted'], ['A']);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    });
  }
}
