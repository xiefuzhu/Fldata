import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/graph_layout_provider.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/engine/layout/graph_layout_engine.dart';
import 'package:fldata/views/lab/trace_preview.dart';

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester,
    Size size, {
    GraphLayoutRunner? runner,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        if (runner != null) graphLayoutRunnerProvider.overrideWithValue(runner),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: TracePreview())),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> choose(WidgetTester tester, String name) async {
    final picker = find.byKey(const ValueKey('demo-input'));
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    final item = find.text(name).last;
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(390, 844), const Size(1360, 900)]) {
    testWidgets('tree and graph previews fit $size', (tester) async {
      final container = await mount(tester, size);
      for (final name in [
        '二叉树旋转布局',
        '混合宽度森林',
        'B-树分裂布局',
        '表 6.4 图布局',
        '图力导向与固定',
      ]) {
        await choose(tester, name);
        expect(container.read(playbackProvider).timeline!.inputSummary, name);
        expect(tester.takeException(), isNull, reason: name);
        final vm = container.read(playbackProvider.notifier);
        vm.seek(.5);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$name midpoint');
        vm.last();
        await tester.pump();
        vm.first();
        await tester.pump();
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets(
    'drag pins a vertex and background re-layout keeps its exact center',
    (tester) async {
      final pending = Completer<SceneSnapshot>();
      SceneSnapshot? requestScene;
      Map<String, Vec2>? requestedPins;
      final container = await mount(
        tester,
        const Size(1360, 900),
        runner: (scene, pins) {
          requestScene = scene;
          requestedPins = pins;
          return pending.future;
        },
      );
      await choose(tester, '表 6.4 图布局');
      SceneNode vertex() => container
          .read(playbackProvider)
          .currentFrame!
          .scene
          .nodes
          .firstWhere((n) => n.id == 'v0');
      final before = vertex();
      final target = find.byKey(const ValueKey('scene-node-v0'));
      await tester.drag(target, const Offset(80, 50));
      await tester.pumpAndSettle();
      final pinned = vertex();
      expect(pinned.x, greaterThan(before.x));
      expect(pinned.y, greaterThan(before.y));
      expect(find.text('解除固定 (1)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('graph-relayout')));
      await tester.pump();
      expect(find.text('后台排布中…'), findsOneWidget);
      expect(
        requestedPins!['v0'],
        Vec2(x: pinned.x + pinned.width / 2, y: pinned.y + pinned.height / 2),
      );
      expect(() => requestedPins!.clear(), throwsUnsupportedError);
      pending.complete(
        GraphLayoutEngine.forceDirected(requestScene!, pins: requestedPins!),
      );
      await tester.pumpAndSettle();
      expect(vertex().x, pinned.x);
      expect(vertex().y, pinned.y);
      expect(find.text('重新排布'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('graph-unpin')));
      await tester.pumpAndSettle();
      expect(find.text('解除固定 (0)'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('a late graph result cannot overwrite a newly selected tree', (
    tester,
  ) async {
    final pending = Completer<SceneSnapshot>();
    SceneSnapshot? requested;
    final container = await mount(
      tester,
      const Size(1360, 900),
      runner: (scene, pins) {
        requested = scene;
        return pending.future;
      },
    );
    await choose(tester, '表 6.4 图布局');
    await tester.tap(find.byKey(const ValueKey('graph-relayout')));
    await tester.pump();
    await choose(tester, 'B-树分裂布局');
    final tree = container.read(playbackProvider).timeline;
    pending.complete(GraphLayoutEngine.forceDirected(requested!));
    await tester.pumpAndSettle();
    expect(container.read(playbackProvider).timeline, tree);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
