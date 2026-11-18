import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/engine/canvas/animated_node_layer.dart';
import 'package:fldata/engine/canvas/stage_hit_test.dart';
import 'package:fldata/engine/canvas/edge_geometry.dart';
import 'package:fldata/engine/canvas/pointer_edge_painter.dart';
import 'package:fldata/models/trace_model.dart';

const small = SceneSnapshot(
  nodes: [
    SceneNode(id: 'a', label: '7', x: 400, y: 200, width: 20, height: 20),
  ],
);
void main() {
  Future<void> mount(
    WidgetTester tester, {
    SceneSnapshot scene = small,
    ValueChanged<String>? onSelect,
    void Function(String, Vec2)? onStart,
    void Function(String, Vec2)? onDrag,
    bool sorting = false,
    String dataset = 'a',
    ScrollController? scroll,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: scroll,
            children: [
              SizedBox(
                height: 348,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 500,
                    child: DsStageCanvas(
                      key: ValueKey(dataset),
                      scene: scene,
                      sceneSize: const Size(1000, 600),
                      onSelect: onSelect,
                      onDragStart: onStart,
                      onDrag: onDrag,
                      sortingRace: sorting,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  TransformationController camera(WidgetTester tester) => tester
      .widget<InteractiveViewer>(find.byType(InteractiveViewer))
      .transformationController!;
  Offset origin(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(const ValueKey('canvas-viewport')));
  test(
    '48dp hit bounds, visible footprint priority and hidden node exclusion',
    () {
      final matrix = Matrix4.identity()..scaleByDouble(.25, .25, 1, 1);
      expect(
        hitTestStageNode(small, matrix, const Offset(102.5 + 23, 52.5)),
        'a',
      );
      expect(
        hitTestStageNode(small, matrix, const Offset(102.5 + 25, 52.5)),
        isNull,
      );
      final scene = small.copyWith(
        nodes: [
          small.nodes.first,
          small.nodes.first.copyWith(id: 'near', x: 460),
          small.nodes.first.copyWith(id: 'hidden', opacity: 0),
          small.nodes.first.copyWith(id: 'deleted', isDeleted: true),
        ],
      );
      expect(
        hitTestStageNode(scene, matrix, const Offset(117.5, 52.5)),
        'near',
      );
      expect(hitTestStageNode(scene, matrix, const Offset(102.5, 52.5)), 'a');
    },
  );
  testWidgets('touch selects outside tiny visual bounds after fitting', (
    tester,
  ) async {
    String? selected;
    await mount(tester, onSelect: (id) => selected = id);
    expect(camera(tester).value.getMaxScaleOnAxis(), .5);
    final center = tester.getCenter(find.byKey(const ValueKey('scene-node-a')));
    await tester.tapAt(center + const Offset(22, 0));
    await tester.pump();
    expect(selected, 'a');
    expect(find.text('7 · a'), findsOneWidget);
  });
  testWidgets(
    'mouse wheel preserves focal scene point, clamps zoom and consumes parent scroll',
    (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await mount(tester, scroll: scroll);
      final c = camera(tester);
      final local = const Offset(170, 140);
      final point = c.toScene(local);
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: origin(tester) + local,
          scrollDelta: const Offset(0, -100),
        ),
      );
      await tester.pump();
      expect(c.value.getMaxScaleOnAxis(), greaterThan(.5));
      expect((c.toScene(local) - point).distance, lessThan(.0001));
      expect(scroll.offset, 0);
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: origin(tester) + local,
          scrollDelta: const Offset(0, -5000),
        ),
      );
      await tester.pump();
      expect(c.value.getMaxScaleOnAxis(), closeTo(8, .0001));
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: origin(tester) + local,
          scrollDelta: const Offset(0, 5000),
        ),
      );
      await tester.pump();
      expect(c.value.getMaxScaleOnAxis(), closeTo(.1, .0001));
      await tester.tap(find.byKey(const ValueKey('canvas-fit')));
      await tester.pumpAndSettle();
      expect(c.value.getMaxScaleOnAxis(), .5);
      expect(c.value.getTranslation().x, 0);
    },
  );
  testWidgets(
    'native PointerPanZoom pans and pinches exactly once without pinning graph nodes',
    (tester) async {
      var drags = 0;
      await mount(
        tester,
        scene: small.copyWith(layoutMode: SceneLayoutMode.graph),
        onDrag: (id, p) => drags++,
      );
      final c = camera(tester);
      final local = const Offset(200, 100);
      final focal = origin(tester) + local;
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(focal);
      await tester.pump();
      await gesture.panZoomUpdate(focal, pan: const Offset(80, 0));
      await tester.pump();
      final before = c.value.clone();
      await gesture.panZoomUpdate(focal, pan: const Offset(120, 20));
      await tester.pump();
      expect(
        c.value.getTranslation().x - before.getTranslation().x,
        closeTo(40, .001),
      );
      expect(
        c.value.getTranslation().y - before.getTranslation().y,
        closeTo(20, .001),
      );
      await gesture.panZoomUpdate(focal, pan: const Offset(120, 20), scale: 2);
      await tester.pump();
      expect(c.value.getMaxScaleOnAxis(), closeTo(1, .001));
      expect(drags, 0);
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();
    },
  );
  testWidgets('native vertical trackpad pan is not captured by the page', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await mount(tester, scroll: scroll);
    final c = camera(tester);
    final p = origin(tester) + const Offset(300, 180);
    final g = await tester.createGesture(kind: PointerDeviceKind.trackpad);
    await g.panZoomStart(p);
    await tester.pump();
    for (var i = 1; i <= 8; i++) {
      await g.panZoomUpdate(p, pan: Offset(0, -10.0 * i));
      await tester.pump();
    }
    expect(c.value.getTranslation().y, lessThan(0));
    expect(scroll.offset, 0);
    await g.panZoomEnd();
    await tester.pumpAndSettle();
  });
  testWidgets(
    'trackpad scroll fallback pans without zooming or scrolling the page',
    (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await mount(tester, scroll: scroll);
      final c = camera(tester);
      await tester.sendEventToBinding(
        PointerScrollEvent(
          kind: PointerDeviceKind.trackpad,
          position: origin(tester) + const Offset(200, 100),
          scrollDelta: const Offset(30, 20),
        ),
      );
      await tester.pump();
      expect(c.value.getTranslation().x, closeTo(-30, .001));
      expect(c.value.getTranslation().y, closeTo(-20, .001));
      expect(c.value.getMaxScaleOnAxis(), .5);
      expect(scroll.offset, 0);
    },
  );
  testWidgets(
    'graph drag uses inverse camera coordinates and leaves camera fixed',
    (tester) async {
      Vec2? start, last;
      await mount(
        tester,
        scene: small.copyWith(layoutMode: SceneLayoutMode.graph),
        onStart: (id, p) => start = p,
        onDrag: (id, p) => last = p,
      );
      final c = camera(tester);
      c.value = Matrix4.identity()
        ..translateByDouble(-60, -30, 0, 1)
        ..scaleByDouble(.75, .75, .75, 1);
      await tester.pump();
      final before = c.value.clone();
      final down =
          tester.getCenter(find.byKey(const ValueKey('scene-node-a'))) +
          const Offset(22, 0);
      final g = await tester.startGesture(down);
      await tester.pump();
      await g.moveBy(const Offset(30, 10));
      await tester.pump();
      await g.moveBy(const Offset(30, 20));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
      expect(start, isNotNull);
      expect(last, isNotNull);
      expect(last!.x - start!.x, closeTo(60 / .75, .001));
      expect(last!.y - start!.y, closeTo(30 / .75, .001));
      expect(c.value, before);
    },
  );
  testWidgets(
    'two fingers starting on a graph node zoom instead of moving the node',
    (tester) async {
      var drags = 0;
      await mount(
        tester,
        scene: small.copyWith(layoutMode: SceneLayoutMode.graph),
        onDrag: (id, p) => drags++,
      );
      final c = camera(tester);
      final p = tester.getCenter(find.byKey(const ValueKey('scene-node-a')));
      final a = await tester.startGesture(p, pointer: 1);
      await tester.pump();
      final b = await tester.startGesture(p + const Offset(80, 0), pointer: 2);
      await tester.pump();
      await a.moveBy(const Offset(-30, 0));
      await b.moveBy(const Offset(30, 0));
      await tester.pump();
      await a.moveBy(const Offset(-20, 0));
      await b.moveBy(const Offset(20, 0));
      await tester.pump();
      expect(c.value.getMaxScaleOnAxis(), greaterThan(.5));
      expect(drags, 0);
      await a.up();
      await b.up();
      await tester.pumpAndSettle();
    },
  );
  testWidgets('slow vertical touch pan stays on the stage', (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await mount(tester, scroll: scroll);
    final c = camera(tester);
    final g = await tester.startGesture(
      origin(tester) + const Offset(300, 180),
    );
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await g.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    expect(c.value.getTranslation().y, lessThan(0));
    expect(scroll.offset, 0);
    await g.up();
    await tester.pumpAndSettle();
  });
  testWidgets(
    'blank pan and camera survive frame updates; dataset change resets fit',
    (tester) async {
      await mount(tester);
      final c = camera(tester);
      await tester.dragFrom(
        origin(tester) + const Offset(80, 180),
        const Offset(60, 30),
      );
      await tester.pumpAndSettle();
      expect(c.value.getTranslation().x, greaterThan(0));
      final moved = c.value.clone();
      await mount(
        tester,
        scene: small.copyWith(nodes: [small.nodes.first.copyWith(x: 460)]),
      );
      expect(camera(tester).value, moved);
      await mount(tester, dataset: 'b');
      expect(camera(tester).value.getMaxScaleOnAxis(), .5);
      expect(camera(tester).value.getTranslation().x, 0);
    },
  );
  testWidgets(
    'sorting alone switches at 25, keeps IDs and allows bar selection',
    (tester) async {
      SceneSnapshot data(int count) => SceneSnapshot(
        layoutMode: SceneLayoutMode.linearMemory,
        nodes: [
          for (var i = 0; i < count; i++)
            SceneNode(
              id: 'n$i',
              label: (i + 1).toString(),
              x: 32 + i * 64,
              y: 120,
            ),
        ],
      );
      await mount(tester, scene: data(24), sorting: true);
      expect(
        tester
            .widget<AnimatedNodeLayer>(find.byType(AnimatedNodeLayer))
            .barMode,
        isFalse,
      );
      await mount(tester, scene: data(25), sorting: true);
      final layer = tester.widget<AnimatedNodeLayer>(
        find.byType(AnimatedNodeLayer),
      );
      expect(layer.barMode, isTrue);
      expect(
        layer.scene.nodes.map((n) => n.id),
        data(25).nodes.map((n) => n.id),
      );
      expect(
        layer.scene.nodes.every(
          (n) =>
              n.x >= 0 &&
              n.x + n.width <= 1000 &&
              n.y >= 0 &&
              n.y + n.height <= 600,
        ),
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('scene-node-n24')));
      await tester.pump();
      expect(find.text('25 · n24'), findsOneWidget);
      await mount(tester, scene: data(25));
      expect(
        tester
            .widget<AnimatedNodeLayer>(find.byType(AnimatedNodeLayer))
            .barMode,
        isFalse,
      );
    },
  );
  test(
    'port endpoints, dashed painter, null/dangling edges and repaint identity',
    () {
      const a = SceneNode(id: 'a', label: 'a', x: 100, y: 100);
      const b = SceneNode(id: 'b', label: 'b', x: 0, y: 100);
      const scene = SceneSnapshot(nodes: [a, b]);
      final nodes = {'a': a, 'b': b};
      const prior = SceneEdge(
        id: 'p',
        fromNodeId: 'a',
        toNodeId: 'b',
        fromPort: EdgePort.prior,
        style: EdgeStyle.dashedThread,
      );
      final (from, _, to) = edgeGeometry(scene, prior, nodes)!;
      expect(from, const Offset(100, 124));
      expect(to, const Offset(56, 124));
      expect(
        edgeGeometry(scene, prior.copyWith(toNodeId: 'missing'), nodes),
        isNull,
      );
      expect(
        edgeGeometry(scene, prior.copyWith(toNodeId: nullNodeId), nodes)!.$3,
        const Offset(76, 124),
      );
      final painter = PointerEdgePainter(scene, Colors.black);
      expect(
        painter.shouldRepaint(PointerEdgePainter(scene, Colors.black)),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          PointerEdgePainter(scene.copyWith(edges: [prior]), Colors.black),
        ),
        isTrue,
      );
    },
  );
}
