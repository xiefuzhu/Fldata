import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('散列表 · 教材双 ASL、墓碑回放与自定义参数 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch7_hash_table',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      String value(String id) => tester.widget<Text>(key(id)).data!;
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      vm.last();
      await tester.pumpAndSettle();
      expect(value('hash-asl-success'), contains('30/12 = 2.5'));
      expect(value('hash-asl-failure'), contains('91/13 = 7'));
      await tap(key('hash-detail'));
      await tap(find.text('逐关键字 · 成功').last);
      expect(find.text('键 79 · 入口 1　9 次'), findsOneWidget);
      await tap(key('hash-method'));
      await tap(find.text('链地址').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(value('hash-asl-success'), contains('21/12'));
      expect(value('hash-asl-failure'), contains('25/13 ≈ 1.923'));
      await tap(key('hash-presets'));
      await tap(find.text('删除标记 · 跨槽查找与复用').last);
      final frames = container.read(playbackProvider).timeline!.frames;
      final deleted = frames.indexWhere((f) => f.inlineVars['阶段'] == '删除');
      vm.seek(deleted.toDouble());
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: key('hash-slot-2'), matching: find.text('DELETED')),
        findsOneWidget,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: key('hash-slot-2'), matching: find.text('6')),
        findsOneWidget,
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: key('hash-slot-2'), matching: find.text('16')),
        findsOneWidget,
      );
      expect(value('hash-path'), contains('1 → 2 → 3 → 4'));
      await tap(key('hash-edit'));
      await tester.enterText(key('hash-m'), '3');
      await tester.enterText(key('hash-p'), '4');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.textContaining('1 ≤ p ≤ m'), findsOneWidget);
      await tester.enterText(key('hash-p'), '2');
      await tester.enterText(key('hash-initial'), '');
      await tester.enterText(key('hash-ops'), '+0 ?0');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(value('hash-params'), contains('m = 3　p = 2'));
      expect(value('hash-phase'), contains('命中 0'));
      await tap(key('hash-presets'));
      await tap(find.text('图 7.28 · 折叠 45387765213').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(key('hash-slot-995'), findsOneWidget);
      await tap(key('hash-edit'));
      await tap(find.text('边界叠加'));
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(key('hash-slot-914'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
