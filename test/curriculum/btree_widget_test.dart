import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/engine/canvas/edge_geometry.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('多路树 · 分裂回退、阶数、叶链与闭区间编辑 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch7_btree_bplustree',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      SceneSnapshot scene() =>
          tester.widget<DsStageCanvas>(find.byType(DsStageCanvas)).scene;
      final frames = container.read(playbackProvider).timeline!.frames;
      final split = frames.indexWhere((f) => f.inlineVars['阶段'] == '分裂');
      vm.seek(split - 1.0);
      await tester.pumpAndSettle();
      expect(scene().zones.single.pattern, ZonePattern.dashed);
      final raised = 'key${frames[split].inlineVars['键']}';
      final before = scene().nodes.singleWhere((n) => n.id == raised);
      vm.seek(split - .5);
      await tester.pumpAndSettle();
      expect(
        scene().nodes.singleWhere((n) => n.id == raised).visualState,
        NodeVisualState.moving,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(scene().nodes.singleWhere((n) => n.id == raised), before);
      await tap(key('btree-order'));
      await tap(find.text('5 阶').last);
      expect(
        tester.widget<Text>(key('btree-threshold')).data,
        contains('2 ≤ 键数 ≤ 4'),
      );
      await tap(key('btree-edit'));
      await tester.enterText(key('btree-seed'), '');
      await tester.enterText(key('btree-ops'), '+5 -5 ?5');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('空树 ∅'), findsOneWidget);
      expect(tester.widget<Text>(key('btree-result')).data, contains('未找到 5'));
      await tap(key('btree-presets'));
      await tap(find.text('图 7.27 · 沿叶链查 [37, 72]').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('btree-hits')).data,
        contains('37 44 51 59 63 72'),
      );
      final s = scene(), nodes = {for (final n in s.nodes) n.id: n};
      final links = s.edges.where(
        (e) => isBPlusLeafLink(s, e, nodes[e.fromNodeId], nodes[e.toNodeId]),
      );
      expect(links, hasLength(4));
      for (final e in links) {
        final (a, _, b) = edgeGeometry(s, e, nodes)!;
        expect(a.dy, b.dy);
        expect(a.dx, lessThan(b.dx));
      }
      await tap(key('btree-edit'));
      await tester.enterText(key('btree-low'), '59');
      await tester.enterText(key('btree-high'), '58');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.textContaining('下界应小于或等于上界'), findsOneWidget);
      await tester.enterText(key('btree-high'), '59');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('btree-hits')).data, '命中记录　59');
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
