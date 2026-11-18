import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fldata/engine/debugger/call_tree_projection.dart';
import 'package:fldata/engine/debugger/call_stack_inspector.dart';
import 'package:fldata/engine/debugger/memory_table_inspector.dart';
import 'package:fldata/engine/debugger/playback_transport_bar.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/engine/examples/recursion_trace_demo.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/ui/managers/playback_actions.dart';

void main() {
  final timeline = const RecursionTraceDemo().generateTrace(3);
  test(
    'recursive history is prefix-only, retains returned calls and rewinds exactly',
    () {
      final first = CallTreeProjection(timeline, 0);
      expect(first.records.keys, ['call-3']);
      expect(first.parents['call-3'], isNull);
      final deepest = CallTreeProjection(timeline, 3);
      expect(deepest.records.length, 4);
      expect(deepest.topId, 'call-0');
      expect(deepest.records['call-0']!.locals, isEmpty);
      expect(timeline.frames[3].inlineVars.containsKey('child'), isFalse);
      expect(deepest.parents['call-0'], 'call-1');
      final returned = CallTreeProjection(timeline, 4);
      expect(returned.records.length, 4);
      expect(returned.activeIds.contains('call-0'), isFalse);
      expect(returned.topId, 'call-1');
      expect(returned.records['call-1']!.locals['child'], '0');
      final end = CallTreeProjection(timeline, timeline.frames.length - 1);
      expect(end.records.length, 4);
      expect(end.activeIds, isEmpty);
      expect(end.scene.edges.length, 3);
      expect(timeline.frames.last.inlineVars['result'], '6');
      expect(CallTreeProjection(timeline, 0).scene, first.scene);
      expect(
        TraceTimeline.fromJson(
          jsonDecode(jsonEncode(timeline)) as Map<String, dynamic>,
        ),
        timeline,
      );
      expect(
        const RecursionTraceDemo()
            .generateTrace(0)
            .frames
            .last
            .inlineVars['result'],
        '0',
      );
    },
  );
  test(
    'sibling invocations of the same function retain separate IDs after return',
    () {
      final parent = timeline.frames.first.callStack.first;
      final left = parent.copyWith(
        id: 'left',
        parentCallId: parent.id,
        returnLocation: 'RetLoc1',
      );
      final right = left.copyWith(id: 'right', returnLocation: 'RetLoc2');
      final stacks = [
        [parent],
        [parent, left],
        [parent],
        [parent, right],
        [parent],
        <StackActivationRecord>[],
      ];
      final branch = timeline.copyWith(
        frames: [
          for (var i = 0; i < stacks.length; i++)
            timeline.frames.first.copyWith(stepIndex: i, callStack: stacks[i]),
        ],
      );
      expect(CallTreeProjection(branch, 2).records.keys, [parent.id, 'left']);
      final both = CallTreeProjection(branch, 3);
      expect(both.scene.edges.map((e) => e.toNodeId), ['left', 'right']);
      expect(both.activeIds.contains('left'), isFalse);
      expect(both.topId, 'right');
      expect(both.records['left']!.returnLocation, 'RetLoc1');
      expect(both.records['right']!.returnLocation, 'RetLoc2');
    },
  );
  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double width = 600,
    double height = 520,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, height: height, child: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'stack grows upward and selection links to recursive tree and RetLoc',
    (tester) async {
      await mount(
        tester,
        CallStackInspector(timeline: timeline, frameIndex: 3),
        height: 700,
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('call-card-call-0'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('call-card-call-3'))).dy,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('call-card-call-2')));
      await tester.pump();
      await tester.tap(find.text('递归树'));
      await tester.pumpAndSettle();
      final canvas = tester.widget<DsStageCanvas>(find.byType(DsStageCanvas));
      expect(canvas.selectedNodeId, 'call-2');
      expect(find.text('RetLoc：RetLoc1'), findsOneWidget);
      await mount(
        tester,
        CallStackInspector(timeline: timeline, frameIndex: 0),
        height: 700,
      );
      expect(find.byKey(const ValueKey('scene-node-call-0')), findsNothing);
      expect(find.text('RetLoc：Main'), findsOneWidget);
      await mount(
        tester,
        CallStackInspector(timeline: timeline, frameIndex: 7),
        height: 700,
      );
      await tester.tap(find.text('调用栈'));
      await tester.pumpAndSettle();
      expect(find.text('调用栈：已返回'), findsOneWidget);
    },
  );
  testWidgets(
    'memory auxiliary rows and highlighted snapshot rewind without stale values',
    (tester) async {
      await mount(
        tester,
        MemoryTableInspector(scene: timeline.frames[3].scene),
        width: 320,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('辅助表'));
      await tester.pumpAndSettle();
      DataTable table() => tester.widget<DataTable>(
        find.byKey(const ValueKey('memory-table-activation-records')),
      );
      expect(table().rows.length, 4);
      expect(table().rows.last.color, isNotNull);
      await mount(
        tester,
        MemoryTableInspector(scene: timeline.frames[4].scene),
        width: 320,
      );
      expect(table().rows.length, 3);
      expect(
        (table().rows.last.cells[2].child as ConstrainedBox).child,
        isA<Text>(),
      );
      expect(find.text('0'), findsOneWidget);
      await mount(
        tester,
        MemoryTableInspector(scene: timeline.frames[7].scene),
        width: 320,
      );
      expect(find.text('暂无记录'), findsOneWidget);
      await mount(
        tester,
        MemoryTableInspector(scene: timeline.frames[3].scene),
        width: 320,
      );
      expect(table().rows.length, 4);
    },
  );
  testWidgets('memory exposes deleted, leak, sentinel and NULL values', (
    tester,
  ) async {
    const scene = SceneSnapshot(
      nodes: [
        SceneNode(id: 'gone', label: '7', x: 0, y: 0, isDeleted: true),
        SceneNode(id: 'lost', label: '8', x: 0, y: 0, isOrphanLeak: true),
        SceneNode(
          id: 'slot0',
          label: '9',
          x: 0,
          y: 0,
          isZeroSentinelSlot: true,
        ),
      ],
      pointers: [PointerBadge(id: 'p', label: 'p', targetNodeId: nullNodeId)],
    );
    await mount(tester, const MemoryTableInspector(scene: scene), height: 700);
    expect(find.text('已释放'), findsOneWidget);
    expect(find.text('不可达 / 泄漏'), findsOneWidget);
    expect(find.text('哨兵 / 暂存'), findsOneWidget);
    expect(find.text('NULL'), findsOneWidget);
  });
  testWidgets(
    'transport step, milestone click, speed, reverse and follow use the real VM',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var follow = false;
      late PlaybackController vm;
      void command(PlaybackCommand c) {
        switch (c) {
          case PlaybackCommand.first:
            vm.first();
          case PlaybackCommand.last:
            vm.last();
          case PlaybackCommand.stepBack:
            vm.stepBack();
          case PlaybackCommand.stepInto:
            vm.stepInto();
          case PlaybackCommand.toggle:
            vm.toggle();
          case PlaybackCommand.nextMilestone:
            vm.nextMilestone();
        }
      }

      await mount(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(playbackProvider);
              vm = ref.read(playbackProvider.notifier);
              return PlaybackTransportBar(
                state: state,
                onCommand: command,
                onSeek: vm.seek,
                onSpeed: vm.setSpeed,
                onDirection: vm.setDirection,
                followCamera: follow,
                onFollowCamera: (v) => follow = v,
              );
            },
          ),
        ),
        width: 340,
      );
      vm.load(timeline);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('transport-stepInto')));
      await tester.pump();
      expect(container.read(playbackProvider).position, 1);
      await tester.tap(find.byKey(const ValueKey('transport-nextMilestone')));
      await tester.pump();
      expect(container.read(playbackProvider).position, 3);
      final track = tester.getRect(
        find.byKey(const ValueKey('milestone-track')),
      );
      await tester.tapAt(Offset(track.right - 24, track.center.dy));
      await tester.pump();
      expect(container.read(playbackProvider).position, 7);
      await tester.tap(find.byKey(const ValueKey('play-direction')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('倒放').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('play-speed')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2.0×').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('camera-follow')));
      await tester.pump();
      expect(follow, isTrue);
      await tester.tap(find.byKey(const ValueKey('play-toggle')));
      await tester.pump();
      vm.advance(const Duration(milliseconds: 350));
      await tester.pump();
      expect(container.read(playbackProvider).position, 6);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('empty and single-frame transport remain finite and disabled', (
    tester,
  ) async {
    Widget bar(PlaybackState state) => PlaybackTransportBar(
      state: state,
      onCommand: (_) {},
      onSeek: (_) {},
      onSpeed: (_) {},
      onDirection: (_) {},
      followCamera: false,
      onFollowCamera: (_) {},
    );
    await mount(tester, bar(const PlaybackState()), width: 280);
    expect(find.text('暂无播放轨迹'), findsOneWidget);
    final one = timeline.copyWith(
      frames: [timeline.frames.first.copyWith(isKeyMilestone: true)],
    );
    await mount(tester, bar(PlaybackState(timeline: one)), width: 280);
    expect(
      tester.widget<Slider>(find.byKey(const ValueKey('trace-seek'))).onChanged,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'camera follow keeps active nodes visible and manual control releases it',
    (tester) async {
      var follow = false;
      var x = 100.0;
      late StateSetter update;
      await mount(
        tester,
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return DsStageCanvas(
              scene: SceneSnapshot(
                nodes: [
                  SceneNode(
                    id: 'active',
                    label: 'A',
                    x: x,
                    y: 200,
                    visualState: NodeVisualState.active,
                  ),
                ],
              ),
              sceneSize: const Size(1000, 600),
              followCamera: follow,
              onCameraInteraction: () => set(() => follow = false),
            );
          },
        ),
        width: 500,
        height: 348,
      );
      TransformationController camera() => tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!;
      camera().value = Matrix4.identity();
      await tester.pump();
      update(() {
        follow = true;
        x = 850;
      });
      await tester.pumpAndSettle();
      final node = MatrixUtils.transformRect(
        camera().value,
        Rect.fromLTWH(x, 200, 56, 48),
      );
      expect(node.right, lessThanOrEqualTo(476.001));
      expect(node.left, greaterThanOrEqualTo(23.999));
      await tester.tap(find.byKey(const ValueKey('canvas-zoom-in')));
      await tester.pumpAndSettle();
      expect(follow, isFalse);
      final manual = camera().value.clone();
      update(() => x = 10);
      await tester.pumpAndSettle();
      expect(camera().value, manual);
      update(() => follow = true);
      await tester.pumpAndSettle();
      expect(
        MatrixUtils.transformPoint(camera().value, const Offset(10, 200)).dx,
        greaterThanOrEqualTo(23.999),
      );
    },
  );
}
