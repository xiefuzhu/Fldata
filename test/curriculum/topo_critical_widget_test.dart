import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('拓扑与关键路径工作台 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_topo_critical',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String k) => find.byKey(ValueKey(k));
      DsStageCanvas graph() => tester.widget(find.byType(DsStageCanvas));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      final frames = container.read(playbackProvider).timeline!.frames;
      final i = frames.indexWhere((f) => f.phaseTitle == '移去 v6 → v5');
      vm.seek(i.toDouble());
      await tester.pumpAndSettle();
      final eid = frames[i].inlineVars['弧'];
      expect(graph().scene.edges.singleWhere((e) => e.id == eid).opacity, 0);
      expect(
        find.descendant(of: key('scene-node-v5'), matching: find.text('in: 2')),
        findsOneWidget,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(graph().scene.edges.singleWhere((e) => e.id == eid).opacity, 1);
      expect(
        find.descendant(of: key('scene-node-v5'), matching: find.text('in: 3')),
        findsOneWidget,
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('topo-order')).data,
        contains('v6 → v1 → v4 → v3 → v2 → v5'),
      );
      await tap(key('topo-preset'));
      await tap(find.text('含死锁环路有向图').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('topo-title')).data, '拓扑排序失败：图中存在有向环！');
      expect(
        graph().scene.edges
            .where((e) => e.visualState == NodeVisualState.error)
            .length,
        3,
      );
      await tap(key('topo-preset'));
      await tap(find.text('AOE · 图 6.28 / 表 6.7').last);
      await tap(key('topo-method'));
      await tap(find.text('关键路径').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('topo-title')).data, '工程总工期 18');
      expect(find.text('活动开始时间与余量'), findsWidgets);
      expect(graph().backdropPainter, isNotNull);
      expect(
        graph().scene.edges
            .where((e) => e.visualState == NodeVisualState.sorted)
            .length,
        6,
      );
      expect(
        graph().scene.nodes.singleWhere((n) => n.id == 'v5').logicBadge,
        '7 / 10',
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(graph().backdropPainter, isNull);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
