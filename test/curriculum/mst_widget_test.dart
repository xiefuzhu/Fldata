import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('目录进入最小生成树，割集、判环与回退 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_mst_prim_kruskal',
      );
      final vm = container.read(playbackProvider.notifier);
      DsStageCanvas canvas() => tester.widget(find.byType(DsStageCanvas));
      Finder key(String k) => find.byKey(ValueKey(k));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      expect(find.text('closedge'), findsOneWidget);
      expect(canvas().backdropPainter, isNotNull);
      vm.nextMilestone();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.where((v) => v.groupTag == 'U').length, 2);
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.sorted)
            .length,
        1,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.where((v) => v.groupTag == 'U').length, 1);
      await tap(key('mst-source'));
      await tap(find.widgetWithText(DropdownMenuItem<String>, 'V4').last);
      expect(
        canvas().scene.nodes.singleWhere((v) => v.groupTag == 'U').id,
        'V4',
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(find.textContaining('权值和 15　'), findsOneWidget);
      await tap(key('mst-method'));
      await tap(find.text('Kruskal').last);
      expect(find.text('Vexset · 连通分量'), findsOneWidget);
      final frames = container.read(playbackProvider).timeline!.frames;
      final reject = frames.indexWhere((f) => f.phaseTitle.contains('回路'));
      vm.seek(reject.toDouble());
      await tester.pumpAndSettle();
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.error)
            .length,
        1,
      );
      expect(
        tester
            .widgetList<Text>(find.text('舍弃'))
            .any((t) => t.style?.decoration == TextDecoration.lineThrough),
        true,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(
        canvas().scene.edges.where(
          (e) => e.visualState == NodeVisualState.error,
        ),
        isEmpty,
      );
      await tap(key('mst-preset'));
      await tap(find.textContaining('另一个分量'));
      vm.last();
      await tester.pumpAndSettle();
      expect(find.textContaining('无法生成单一生成树'), findsOneWidget);
      expect(canvas().scene.nodes.map((n) => n.groupTag).toSet().length, 2);
      if (width > 320) {
        await tap(key('graph-tool'));
        await tap(find.text('删除点边').last);
        await tap(key('scene-node-V8'));
        vm.last();
        await tester.pumpAndSettle();
        expect(canvas().scene.nodes.length, 7);
        expect(
          container.read(playbackProvider).currentFrame!.inlineVars['权值和'],
          '15',
        );
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
