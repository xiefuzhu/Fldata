import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fldata/engine/examples/layout_trace_demo.dart';
import 'package:fldata/engine/layout/linear_memory_layout.dart';
import 'package:fldata/engine/layout/circular_queue_layout.dart';
import 'package:fldata/engine/layout/swap_trajectory.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/engine/vm/trace_validation.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';

List<SceneNode> slots(int count) =>
    List.generate(count, (i) => SceneNode(id: 'n$i', label: '$i', x: 0, y: 0));
void main() {
  test(
    'linear slots distinguish storage index, logical order and sentinel isolation',
    () {
      final data = slots(4);
      final normal = LinearMemoryLayout.arrange(data);
      final sentinel = LinearMemoryLayout.arrange(data, hasSentinelZero: true);
      expect(normal.nodes.map((n) => n.x), [32, 96, 160, 224]);
      expect(normal.nodes.first.indexBadge, '[0]');
      expect(normal.nodes.first.logicBadge, '位序 1');
      expect(sentinel.nodes.map((n) => n.x), [32, 112, 176, 240]);
      expect(sentinel.nodes.first.isZeroSentinelSlot, isTrue);
      expect(sentinel.nodes.first.visualState, NodeVisualState.sentinel);
      expect(sentinel.nodes[1].indexBadge, '[1]');
      expect(sentinel.nodes[1].logicBadge, '位序 1');
      expect(
        sentinel.nodes[1].x - sentinel.nodes[0].x - sentinel.nodes[0].width,
        24,
      );
      expect(sentinel.zones.single.pattern, ZonePattern.dashed);
      expect(data.first.x, 0);
      expect(data.first.isZeroSentinelSlot, isFalse);
      expect(LinearMemoryLayout.arrange([]).nodes, isEmpty);
      expect(
        () => LinearMemoryLayout.arrange([], hasSentinelZero: true),
        throwsArgumentError,
      );
      expect(
        LinearMemoryLayout.arrange(slots(1), hasSentinelZero: true).nodes,
        hasLength(1),
      );
    },
  );
  test(
    'shared stack empty, single-sided full and meeting tops retain exact capacity',
    () {
      final data = slots(4);
      final empty = LinearMemoryLayout.sharedStacks(data);
      expect(empty.pointers.every((p) => p.targetNodeId == nullNodeId), isTrue);
      expect(empty.auxTables.single.rows.single, ['-1', '4', '4']);
      for (var split = 0; split <= 4; split++) {
        final full = LinearMemoryLayout.sharedStacks(
          data,
          topLeft: split - 1,
          topRight: split,
        );
        expect(full.zones.single.visualState, NodeVisualState.error);
        expect(
          full.nodes.where((n) => n.groupTag == 'left-stack'),
          hasLength(split),
        );
        expect(
          full.nodes.where((n) => n.groupTag == 'right-stack'),
          hasLength(4 - split),
        );
        expect(full.auxTables.single.rows.single.last, '0');
        validateScene(full);
      }
      expect(
        () => LinearMemoryLayout.sharedStacks(data, topLeft: 2, topRight: 2),
        throwsArgumentError,
      );
      expect(
        () => LinearMemoryLayout.sharedStacks(data, topLeft: -2),
        throwsArgumentError,
      );
    },
  );
  test(
    'queue occupancy and reserved slot cover every front/rear arrangement',
    () {
      for (var capacity = 2; capacity <= 10; capacity++) {
        for (var front = 0; front < capacity; front++) {
          for (var rear = 0; rear < capacity; rear++) {
            final scene = CircularQueueLayout.arrange(
              slots(capacity),
              front: front,
              rear: rear,
            );
            final count = (rear - front + capacity) % capacity;
            expect(
              scene.nodes.where((n) => n.visualState == NodeVisualState.active),
              hasLength(count),
            );
            expect(scene.zones.length, count == capacity - 1 ? 1 : 0);
            if (scene.zones.isNotEmpty) {
              expect(scene.zones.single.pattern, ZonePattern.hatched);
              expect(scene.zones.single.x, scene.nodes[rear].x - 4);
              expect(scene.nodes[rear].visualState, NodeVisualState.normal);
            }
          }
        }
      }
      final empty = CircularQueueLayout.arrange(slots(8), front: 0, rear: 0);
      expect(
        empty.pointers[0].orbit!.radius,
        isNot(empty.pointers[1].orbit!.radius),
      );
      expect(
        () => CircularQueueLayout.arrange(slots(1), front: 0, rear: 0),
        throwsArgumentError,
      );
      expect(
        () => CircularQueueLayout.arrange(slots(8), front: 8, rear: 0),
        throwsArgumentError,
      );
      expect(
        () => CircularQueueLayout.arrange(
          slots(8),
          front: 0,
          rear: 0,
          radius: double.nan,
        ),
        throwsArgumentError,
      );
    },
  );
  test('clockwise wrap keeps radius and avoids the reverse long arc', () {
    final before = CircularQueueLayout.arrange(slots(8), front: 6, rear: 7);
    final after = CircularQueueLayout.arrange(slots(8), front: 6, rear: 0);
    final old = before.pointers.last.orbit!;
    final end = after.pointers.last.orbit!;
    expect(
      CircularQueueLayout.clockwiseDelta(old.angle, end.angle),
      closeTo(math.pi / 4, 1e-10),
    );
    double lastAngle = old.angle;
    for (var i = 0; i < 100; i++) {
      final scene = SceneInterpolator.lerp(
        before,
        after,
        i / 100,
        spatialProgress: 1.03,
      );
      expect(scene.pointers, hasLength(2)); // No duplicate/fading rear badge.
      final orbit = scene.pointers.last.orbit!;
      expect(orbit.angle, greaterThanOrEqualTo(lastAngle));
      lastAngle = orbit.angle;
      final point = CircularQueueLayout.position(orbit);
      expect(
        math.sqrt(
          math.pow(point.x - orbit.center.x, 2) +
              math.pow(point.y - orbit.center.y, 2),
        ),
        closeTo(old.radius, 1e-8),
      );
      validateScene(scene);
    }
    expect(SceneInterpolator.lerp(before, after, 1), after);
    expect(
      CircularQueueLayout.clockwiseDelta(0, -math.pi / 2),
      closeTo(3 * math.pi / 2, 1e-10),
    );
    expect(CircularQueueLayout.clockwiseDelta(0, 0), 0);
  });
  test(
    'actual player reverse and seek retrace the same wrapped queue path',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(playbackProvider, (_, _) {});
      final vm = container.read(playbackProvider.notifier);
      final trace = const LayoutTraceDemo().generateTrace(
        LayoutDemoInput.queueWrap,
      );
      vm.load(trace);
      SceneSnapshot rendered() {
        final s = container.read(playbackProvider);
        return SceneInterpolator.lerp(
          trace.frames[0].scene,
          trace.frames[1].scene,
          s.position,
        );
      }

      vm.seek(.5);
      final middle = rendered();
      vm.last();
      vm.play(direction: PlaybackDirection.reverse);
      vm.advance(const Duration(milliseconds: 350));
      expect(rendered(), middle);
      var angle = middle.pointers.last.orbit!.angle;
      for (var i = 4; i >= 0; i--) {
        vm.seek(i / 10);
        final next = rendered().pointers.last.orbit!.angle;
        expect(next, lessThanOrEqualTo(angle));
        angle = next;
      }
      expect(rendered(), trace.frames.first.scene);
    },
  );
  test(
    'opposing swaps follow separated arcs, exact endpoints and no source mutation',
    () {
      final from = LinearMemoryLayout.arrange(slots(2));
      final to = LinearMemoryLayout.arrange(slots(2).reversed.toList());
      final mid = SceneInterpolator.lerp(from, to, .5);
      expect(mid.nodes[0].x, mid.nodes[1].x);
      expect(mid.nodes[0].y, lessThan(from.nodes[0].y));
      expect(mid.nodes[1].y, greaterThan(from.nodes[1].y));
      expect(
        mid.nodes[1].y - mid.nodes[0].y,
        greaterThan(from.nodes[0].height),
      );
      expect(mid.nodes.map((n) => n.id).toSet(), {'n0', 'n1'});
      expect(SceneInterpolator.lerp(from, to, 0), from);
      expect(SceneInterpolator.lerp(from, to, 1), to);
      expect(from.nodes.first.x, 32);
      expect(
        SceneInterpolator.lerp(
          from,
          to,
          .5,
          spatialProgress: 1.04,
        ).nodes.first.x,
        to.nodes.last.x,
      );
      expect(
        () => SceneInterpolator.lerp(from, to, .5, spatialProgress: double.nan),
        throwsArgumentError,
      );
    },
  );
  test('long insertion uses arcs only for declared linear movement', () {
    final trace = const LayoutTraceDemo().generateTrace(LayoutDemoInput.insert);
    final from = trace.frames[0].scene, to = trace.frames[1].scene;
    final mid = SceneInterpolator.lerp(from, to, .5);
    expect(mid.nodes.last.y, greaterThan(from.nodes.last.y));
    expect(mid.nodes.first.y, lessThan(from.nodes.first.y));
    final plain = SceneInterpolator.lerp(
      from.copyWith(layoutMode: SceneLayoutMode.freeCanvas),
      to.copyWith(layoutMode: SceneLayoutMode.freeCanvas),
      .5,
    );
    expect(plain.nodes.map((n) => n.y).toSet(), {120});
    expect(
      SwapTrajectory.position(
        const Vec2(x: 0, y: 0),
        const Vec2(x: 0, y: 100),
        .5,
      ),
      const Vec2(x: 0, y: 50),
    );
  });
  test('layout fixtures and orbit/zone metadata round-trip through JSON', () {
    const demo = LayoutTraceDemo();
    for (final p in demo.presets) {
      final trace = demo.generateTrace(p.input);
      validateTimeline(trace);
      for (final frame in trace.frames.where(
        (f) => f.scene.layoutMode == SceneLayoutMode.circularQueue,
      )) {
        for (final n in frame.scene.nodes) {
          expect(n.label == '·', n.visualState != NodeVisualState.active);
        }
      }
      expect(demo.generateTrace(p.input), trace);
      expect(
        TraceTimeline.fromJson(
          jsonDecode(jsonEncode(trace.toJson())) as Map<String, dynamic>,
        ),
        trace,
      );
    }
    final broken = CircularQueueLayout.arrange(slots(8), front: 0, rear: 1);
    expect(
      () => validateScene(
        broken.copyWith(
          pointers: [
            broken.pointers.first.copyWith(
              orbit: const PointerOrbit(
                center: Vec2(x: 0, y: 0),
                radius: 0,
                angle: 0,
              ),
            ),
          ],
        ),
      ),
      throwsArgumentError,
    );
  });
}
