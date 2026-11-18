import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('选择排序 · 堆顶跨视图交换、胜者重赛和同键定位 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch8_select_heap',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      SceneSnapshot scene() =>
          tester.widget<DsStageCanvas>(find.byType(DsStageCanvas)).scene;
      SceneNode node(String id) => scene().nodes.singleWhere((n) => n.id == id);
      int first(String phase) => container
          .read(playbackProvider)
          .timeline!
          .frames
          .firstWhere((f) => f.inlineVars['阶段'] == phase)
          .stepIndex;
      Future<void> seek(double index) async {
        vm.seek(index);
        await tester.pumpAndSettle();
      }

      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await seek(first('孩子上移') - .5);
      expect(node('heap-rise').label, node('record-copy').label);
      final exchange = first('交换');
      await seek(exchange - 1.0);
      final beforeRoot = node('tree1'), beforeTail = node('slot8');
      expect((beforeRoot.label, beforeTail.label), ('97', '38'));
      await seek(exchange - .5);
      final out = node('heap-out'), incoming = node('heap-in');
      expect((out.label, incoming.label), ('97', '38'));
      expect(out.y, lessThan((beforeRoot.y + beforeTail.y) / 2));
      expect(incoming.y, greaterThan((beforeRoot.y + beforeTail.y) / 2));
      await seek(exchange.toDouble());
      expect(
        (node('tree1').label, node('slot1').label, node('slot8').label),
        ('38', '38', '97'),
      );
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(scene().nodes.any((n) => n.id == 'tree8'), false);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(node('tree8').label, '97');
      await tap(key('selection-presets'));
      await tap(find.text('图 8.8 · 锦标赛树').last);
      await seek(first('置无穷').toDouble());
      expect((node('slot1').label, node('tree13').label), ('13', '∞'));
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(node('tree13').label, '13');
      await tap(key('selection-presets'));
      await tap(find.text('例 8.5 · 简单选择七趟').last);
      vm.last();
      await tester.pumpAndSettle();
      await tap(key('sort-jump'));
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['来源'],
        '1',
      );
      await tap(key('selection-method'));
      await tap(find.text('堆排序').last);
      await tap(key('selection-edit'));
      await tester.enterText(key('selection-keys'), '2, 2*');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect((node('slot1').label, node('slot2').label), ('2*', '2'));
      expect(key('sort-unstable'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
