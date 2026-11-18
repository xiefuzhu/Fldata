import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('交换排序回放、区间树和 flag · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch8_swap_bubble_quick',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      SceneSnapshot array() =>
          tester.widget<DsStageCanvas>(find.byType(DsStageCanvas).first).scene;
      SceneSnapshot tree() =>
          tester.widget<DsStageCanvas>(key('quick-tree')).scene;
      int step(String phase) => container
          .read(playbackProvider)
          .timeline!
          .frames
          .firstWhere((f) => f.inlineVars['阶段'] == phase)
          .stepIndex;
      Future<void> seek(double index) async {
        vm.seek(index);
        await tester.pumpAndSettle();
      }

      Future<void> tap(Finder target) async {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      expect(key('quick-tree'), findsNothing);
      await seek(step('暂存').toDouble());
      expect(tree().nodes.single.label, '[1, 8]');
      expect(
        array().zones.singleWhere((z) => z.id == 'hole').pattern,
        ZonePattern.dashed,
      );
      expect(array().nodes[1].label, '空坑');
      final fill = step('填坑');
      await seek(fill - .5);
      expect(
        array().nodes.singleWhere((n) => n.id == 'record-copy').label,
        '27',
      );
      await seek(fill.toDouble());
      expect(array().nodes[7].label, '空坑');
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(array().nodes[1].label, '空坑');
      vm.last();
      await tester.pumpAndSettle();
      expect(tree().nodes, hasLength(8));
      expect(tree().nodes.first.label, '[1, 8]　49');
      expect(tester.widget<Text>(key('quick-depth')).data, contains('峰值 4'));
      await seek(step('枢轴归位').toDouble());
      expect(tree().nodes, hasLength(1));
      await tap(key('exchange-presets'));
      await tap(find.text('同键跨位 · 2 与 2*').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(key('sort-unstable'), findsOneWidget);
      final witness = container
          .read(playbackProvider)
          .currentFrame!
          .inlineVars['逆序帧'];
      await tap(key('sort-jump'));
      expect(container.read(playbackProvider).frameIndex, int.parse(witness!));
      await tap(key('exchange-method'));
      await tap(find.text('冒泡排序').last);
      await seek(step('交换') - .5);
      expect(
        array().nodes
            .where((n) => n.id == 'record-copy' || n.id == 'record-return')
            .map((n) => n.label),
        containsAll(['2*', '1']),
      );
      await tap(key('exchange-edit'));
      await tester.enterText(key('exchange-keys'), '1, 2, 3, 4');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('exchange-metrics')).data, 'KCN　3　　RMN　0');
      await tap(key('bubble-flag'));
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('exchange-metrics')).data, 'KCN　6　　RMN　0');
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
