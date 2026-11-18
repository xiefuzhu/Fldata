import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('Dijkstra 工作台 · 松弛、回退和回溯 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_shortest_path',
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

      expect(find.text('表 6.4 · 各轮选点'), findsOneWidget);
      final frames = container.read(playbackProvider).timeline!.frames;
      final index = frames.indexWhere((f) => f.phaseTitle == '检查 v4 → v3');
      vm.seek(index.toDouble());
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: key('relax-formula'),
          matching: find.textContaining('= 50 < 60'),
        ),
        findsOneWidget,
      );
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.active)
            .single
            .fromNodeId,
        'v0',
      );
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.comparing)
            .single
            .fromNodeId,
        'v4',
      );
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[3][2], '50');
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[3][2], '60');
      final updateV5 = frames.lastIndexWhere((f) => f.phaseTitle == '更新 v5');
      vm.seek(updateV5.toDouble());
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[5].sublist(2), ['60', '3']);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[5].sublist(2), ['90', '4']);
      vm.last();
      await tester.pumpAndSettle();
      await tap(key('route-to-v5'));
      expect(find.text('v0 → v4 → v3 → v5　长度 60'), findsOneWidget);
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.active)
            .length,
        3,
      );
      await tap(key('route-to-v1'));
      expect(find.textContaining('v0 → v1：不可达'), findsOneWidget);
      await tap(key('shortest-source'));
      await tap(find.widgetWithText(DropdownMenuItem<String>, 'v1').last);
      vm.last();
      await tester.pumpAndSettle();
      await tap(key('route-to-v5'));
      expect(find.text('v1 → v2 → v3 → v5　长度 65'), findsOneWidget);
      if (width > 320) {
        await tap(key('graph-tool'));
        await tap(find.text('连边').last);
        await tap(key('scene-node-v1'));
        await tap(key('scene-node-v4'));
        await tester.enterText(find.byType(TextFormField), '-2');
        await tap(find.widgetWithText(FilledButton, '连边'));
        expect(
          container.read(playbackProvider).currentFrame!.isErrorState,
          true,
        );
        expect(canvas().scene.edges.last.visualState, NodeVisualState.error);
        await tap(key('graph-tool'));
        await tap(find.text('删除点边').last);
        await tap(key('scene-node-v4'));
        expect(
          container.read(playbackProvider).currentFrame!.isErrorState,
          false,
        );
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
