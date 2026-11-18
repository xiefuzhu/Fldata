import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('外部排序 · 重赛上行、冻结与虚段弹窗 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch8_external_sort',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      SceneSnapshot scene() =>
          tester.widget<DsStageCanvas>(find.byType(DsStageCanvas)).scene;
      SceneNode node(String id) => scene().nodes.singleWhere((n) => n.id == id);
      TraceFrame frame() => container.read(playbackProvider).currentFrame!;
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

      await seek(step('建树完成').toDouble());
      expect(node('pos0').label, '冠军 3');
      expect(node('buf5').label, 'MINKEY');
      final refill = step('补读');
      await seek(refill + .5);
      final token = node('advancing');
      expect(token.label, '3');
      expect(token.y, (node('pos8').y + node('pos4').y) / 2);
      await seek(refill.toDouble());
      expect(node('buf3').label, '15');
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(node('buf3').label, '6');
      await tap(key('external-method'));
      await tap(find.text('置换选择').last);
      await seek(step('冻结').toDouble());
      expect(node('buf0').logicBadge, '冻结 · RUN 2');
      vm.last();
      await tester.pumpAndSettle();
      expect(frame().inlineVars['段长'], '7 10 7');
      await tap(key('external-sample'));
      expect(find.textContaining('2w = 12'), findsOneWidget);
      await tap(key('external-presets'));
      await tap(find.text('六段四路 · 补一个虚段').last);
      expect(find.text('补入零权虚段'), findsOneWidget);
      await tap(find.text('查看归并树'));
      expect(scene().nodes.where((n) => n.groupTag == 'virtual'), hasLength(1));
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(scene().nodes.any((n) => n.groupTag == 'virtual'), false);
      vm.last();
      await tester.pumpAndSettle();
      expect(frame().inlineVars['读写次数'], '120');
      await tap(key('external-edit'));
      await tester.enterText(key('external-data'), '4 5 6');
      await tester.enterText(key('external-param'), '1');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.text('归并路数须至少为 2。'), findsOneWidget);
      await tester.enterText(key('external-param'), '3');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.text('补入零权虚段'), findsNothing);
      vm.last();
      await tester.pumpAndSettle();
      expect(frame().inlineVars['读写次数'], '30');
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
