import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('目录到生成森林 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_dfs_bfs_sixdeg',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      expect(find.text('等待访问起点'), findsOneWidget);
      await tap(key('traversal-mode'));
      await tap(find.text('BFS').last);
      final frames = container.read(playbackProvider).timeline!.frames;
      final step = frames.indexWhere((f) => f.phaseTitle == '树边 V2 → V5');
      vm.seek(step.toDouble());
      await tester.pumpAndSettle();
      DsStageCanvas forest() => tester.widget(key('traversal-forest'));
      expect(forest().scene.nodes.length, 5);
      expect(find.textContaining('队列（队首在左）　V3 → V4 → V5'), findsOneWidget);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(forest().scene.nodes.length, 4);
      vm.last();
      await tester.pumpAndSettle();
      expect(forest().scene.edges.length, 7);
      await tap(key('traversal-presets'));
      await tap(find.textContaining('非连通与孤立点'));
      await tap(key('traversal-source'));
      await tap(find.widgetWithText(DropdownMenuItem<String>, 'V9').last);
      vm.nextMilestone();
      await tester.pumpAndSettle();
      expect(forest().scene.nodes.single.id, 'V9');
      vm.last();
      await tester.pumpAndSettle();
      expect(forest().scene.nodes.length, 9);
      expect(forest().scene.edges.length, 6);
      if (width > 320) {
        await tap(key('graph-tool'));
        await tap(find.text('删除点边').last);
        final inputCanvas = find.byType(DsStageCanvas).first;
        await tap(
          find.descendant(of: inputCanvas, matching: key('scene-node-V9')),
        );
        expect(container.read(playbackProvider).frameIndex, 0);
        vm.last();
        await tester.pumpAndSettle();
        expect(forest().scene.nodes.length, 8);
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
