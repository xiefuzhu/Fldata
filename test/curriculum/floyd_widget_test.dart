import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('Floyd 双矩阵 · 路段、写回、撤步与点选 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_shortest_path',
      );
      final vm = container.read(playbackProvider.notifier);
      DsStageCanvas canvas() => tester.widget(find.byType(DsStageCanvas));
      Finder key(String value) => find.byKey(ValueKey(value));
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tap(key('shortest-method'));
      await tap(find.text('Floyd').last);
      final frames = container.read(playbackProvider).timeline!.frames;
      vm.seek(
        frames
            .indexWhere(
              (f) =>
                  f.inlineVars['阶段'] == '比较' &&
                  f.inlineVars['i'] == '0' &&
                  f.inlineVars['j'] == '5' &&
                  f.inlineVars['k'] == '4',
            )
            .toDouble(),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('floyd-formula')).data,
        contains('= 60 < 70'),
      );
      for (final operand in ['floyd-dist-0-4', 'floyd-dist-4-5']) {
        final tile = tester.widget<Container>(
          find
              .descendant(of: key(operand), matching: find.byType(Container))
              .first,
        );
        expect(
          (tile.decoration as BoxDecoration).color,
          Colors.orange.shade200,
        );
      }
      final edges = canvas().scene.edges;
      expect(
        edges
            .where((e) => e.visualState == NodeVisualState.active)
            .map((e) => (e.fromNodeId, e.toNodeId)),
        [('v0', 'v4')],
      );
      expect(
        edges
            .where((e) => e.visualState == NodeVisualState.comparing)
            .map((e) => (e.fromNodeId, e.toNodeId)),
        unorderedEquals([('v4', 'v3'), ('v3', 'v5')]),
      );
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[0][6], '60');
      expect(canvas().scene.auxTables.last.rows[0][6], '3');
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.auxTables.first.rows[0][6], '70');
      vm.last();
      await tester.pumpAndSettle();
      await tap(key('floyd-dist-0-5'));
      expect(
        tester.widget<Text>(key('floyd-path')).data,
        'v0 → v4 → v3 → v5　长度 60',
      );
      expect(
        canvas().scene.edges
            .where((e) => e.visualState == NodeVisualState.active)
            .length,
        3,
      );
      await tap(key('floyd-pred-0-1'));
      expect(tester.widget<Text>(key('floyd-path')).data, 'v0 → v1：不可达');
      await tap(key('floyd-pred-1-1'));
      expect(tester.widget<Text>(key('floyd-path')).data, 'v1　长度 0');
      await tap(key('shortest-preset'));
      await tap(find.text('G₇ · 图 6.24 / 表 6.5').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(key('floyd-path'), findsNothing);
      await tap(key('floyd-pred-3-1'));
      expect(
        tester.widget<Text>(key('floyd-path')).data,
        '3 → 2 → 0 → 1　长度 10',
      );
      await tap(key('shortest-method'));
      await tap(find.text('Dijkstra').last);
      expect(canvas().scene.nodes.map((v) => v.id), ['0', '1', '2', '3']);
      expect(key('shortest-source'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
