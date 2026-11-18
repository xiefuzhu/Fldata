import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('catalog to graph storage · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_graph_storage',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      DsStageCanvas canvas() => tester.widget(find.byType(DsStageCanvas));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      Future<void> tool(String name) async {
        await tap(key('graph-tool'));
        await tap(find.text(name).last);
      }

      expect(canvas().scene.edges.length, 6);
      expect(
        find.descendant(of: key('matrix-V1-V1'), matching: find.text('0')),
        findsOneWidget,
      );
      await tap(key('AMLGraph'));
      expect(find.text('6 个共享边结点 · 邻接表需 12 个边结点'), findsOneWidget);
      await tap(key('graph-preset'));
      await tap(find.textContaining('N · 有向网'));
      await tap(key('OLGraph'));
      expect(find.text('hlink'), findsOneWidget);
      await tap(key('ALGraph'));
      await tap(find.text('逆邻接表'));
      expect(find.textContaining('入度 2'), findsWidgets);
      await tap(key('AMGraph'));
      expect(
        find.descendant(of: key('matrix-V1-V1'), matching: find.text('∞')),
        findsOneWidget,
      );
      vm.first();
      await tester.pumpAndSettle();
      expect(canvas().scene.edges, isEmpty);
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(canvas().scene.edges.length, 1);
      vm.last();
      await tester.pumpAndSettle();
      if (width > 320) {
        final cell = key('matrix-V1-V2');
        await tester.ensureVisible(cell);
        await tester.pumpAndSettle();
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(cell));
        await tester.pumpAndSettle();
        expect(canvas().pulseEdgeId, 'e1');
        await mouse.removePointer();
        await tester.pumpAndSettle();
        final node = key('scene-node-V1');
        final before = canvas().scene.nodes.first;
        await tester.drag(node, const Offset(32, 28));
        await tester.pumpAndSettle();
        expect(canvas().pinnedIds, contains('V1'));
        expect(canvas().scene.nodes.first.x, isNot(before.x));
        await tool('连边');
        await tap(node);
        await tap(key('scene-node-V5'));
        await tester.enterText(find.byType(TextFormField), '32767');
        await tap(find.widgetWithText(FilledButton, '连边'));
        expect(find.text('请输入小于 32767 的整数'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), '0');
        await tap(find.widgetWithText(FilledButton, '连边'));
        expect(canvas().scene.edges.last.weightLabel, '0');
        await tool('删除点边');
        final edgePoint =
            (tester.getCenter(node) + tester.getCenter(key('scene-node-V5'))) /
            2;
        await tester.tapAt(edgePoint);
        await tester.pumpAndSettle();
        expect(canvas().scene.edges.length, 10);
        await tap(key('scene-node-V2'));
        expect(canvas().scene.nodes.length, 5);
        await tool('加点');
        await tester.tapAt(tester.getCenter(key('canvas-viewport')));
        await tester.pumpAndSettle();
        expect(canvas().scene.nodes.last.id, 'V7');
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
