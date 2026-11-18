import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('AVL · 失衡暂停、双旋回放与追加关键字 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch7_bst_avl_lab',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      DsStageCanvas canvas() => tester.widget(find.byType(DsStageCanvas));
      await tap(key('bst-operation'));
      await tap(find.text('AVL 插入').last);
      await tap(key('bst-edit'));
      await tester.enterText(key('bst-values'), '30 10 20');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.play();
      vm.advance(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      final paused = container.read(playbackProvider), lock = paused.frameIndex;
      expect(paused.isPlaying, false);
      expect(paused.currentFrame!.inlineVars['阶段'], '失衡');
      expect(find.text('BF +2'), findsOneWidget);
      expect(canvas().scene.zones.single.label, contains('LR'));
      final start = canvas().scene.nodes.singleWhere((n) => n.label == '20');
      vm.seek(lock + .5);
      await tester.pumpAndSettle();
      final moving = canvas().scene.nodes.singleWhere((n) => n.id == start.id);
      vm.seek(lock + 1.0);
      await tester.pumpAndSettle();
      final raised = canvas().scene.nodes.singleWhere((n) => n.id == start.id);
      expect(moving.y, isNot(start.y));
      expect(moving.y, isNot(closeTo((start.y + raised.y) / 2, .01)));
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['阶段'],
        '中间态',
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.singleWhere((n) => n.id == start.id), raised);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('BF 0'), findsNWidgets(3));
      await tap(key('bst-continue'));
      await tester.enterText(key('bst-key'), '25');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['已读'],
        '3',
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.map((n) => n.label), contains('25'));
      final badge = db.select(db.achievementsTable)
        ..where((r) => r.achievementId.equals('avl_balancer'));
      expect((await badge.getSingle()).evidenceMask, 4);
      if (width > 320) {
        for (final keys in ['30 20 10', '10 20 30', '10 30 20']) {
          await tap(key('bst-edit'));
          await tester.enterText(key('bst-values'), keys);
          await tap(find.widgetWithText(FilledButton, '开始推演'));
          final frame = container
              .read(playbackProvider)
              .timeline!
              .frames
              .firstWhere((f) => f.inlineVars['阶段'] == '旋转');
          vm.seek(frame.stepIndex.toDouble());
          await tester.pumpAndSettle();
        }
        expect((await badge.getSingle()).unlockedAt, isNotNull);
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
    testWidgets('二叉排序树 · 复制、回退、接续与建树对照 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch7_bst_avl_lab',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      DsStageCanvas canvas() => tester.widget(find.byType(DsStageCanvas));
      final frames = container.read(playbackProvider).timeline!.frames;
      final copyIndex = frames.indexWhere((f) => f.inlineVars['阶段'] == '复制');
      vm.seek(copyIndex - .5);
      await tester.pumpAndSettle();
      final moving = canvas().scene.nodes.singleWhere((n) => n.id == 's.data');
      expect(moving.label, '75');
      expect(canvas().scene.nodes.singleWhere((n) => n.id == 'n3').label, '78');
      vm.seek(copyIndex.toDouble());
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.where((n) => n.label == '75').length, 2);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.singleWhere((n) => n.id == 'n3').label, '78');
      vm.last();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.singleWhere((n) => n.id == 'n3').label, '75');
      await tap(key('bst-continue'));
      await tap(key('bst-dialog-operation'));
      await tap(find.text('插入').last);
      await tester.enterText(key('bst-key'), '78');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(canvas().scene.nodes.where((n) => n.label == '78'), isEmpty);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        canvas().scene.nodes.singleWhere((n) => n.label == '78').id,
        'n12',
      );
      await tap(key('bst-edit'));
      await tester.enterText(key('bst-key'), '77');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(canvas().scene.nodes.singleWhere((n) => n.id == 'n3').label, '75');
      await tap(key('bst-presets'));
      await tap(find.text('图 7.6 · 相同六键的两种树形').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('bst-stats-A')).data, contains('14/6'));
      expect(tester.widget<Text>(key('bst-stats-B')).data, contains('21/6'));
      await tap(key('bst-edit'));
      await tester.enterText(key('bst-values'), '45 24 45*');
      await tester.enterText(key('bst-other'), '');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.length, 2);
      expect(key('bst-stats-B'), findsNothing);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
