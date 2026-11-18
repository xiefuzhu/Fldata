import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch3_stack_queue/queue_sq_link.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = QueueSqLinkModule();
  List<String> state(TraceFrame f) => f.scene.auxTables.first.rows.first;
  test(
    'circular queue all positions and occupancies preserve FIFO and reserved capacity',
    () {
      for (var cap = 2; cap <= 6; cap++) {
        for (var front = 0; front < cap; front++) {
          for (var n = 0; n < cap; n++) {
            for (final op in [
              QueueOperation.enqueue,
              QueueOperation.dequeue,
              QueueOperation.peek,
              QueueOperation.length,
            ]) {
              final input = QueueInput(
                    capacity: cap,
                    front: front,
                    values: [for (var i = 1; i <= n; i++) i],
                    operation: op,
                    value: 99,
                  ),
                  t = module.generateTrace(input),
                  last = t.frames.last;
              final error = op == QueueOperation.enqueue
                  ? n == cap - 1
                  : (op == QueueOperation.dequeue ||
                            op == QueueOperation.peek) &&
                        n == 0;
              expect(last.isErrorState, error);
              final expected = [...input.values];
              if (!error && op == QueueOperation.enqueue) expected.add(99);
              if (!error && op == QueueOperation.dequeue) expected.removeAt(0);
              expect(state(last)[5], expected.join(' → '));
              expect(state(last)[4], '${expected.length}');
              expect(last.scene.nodes.length, cap);
              final endFront = op == QueueOperation.dequeue && !error
                      ? (front + 1) % cap
                      : front,
                  endRear =
                      (front +
                          n +
                          (op == QueueOperation.enqueue && !error ? 1 : 0)) %
                      cap;
              expect(state(last)[2], '$endFront');
              expect(state(last)[3], '$endRear');
              expect(
                last.scene.zones.any((z) => z.id == 'queue-reserved'),
                expected.length == cap - 1,
              );
              if (error) expect(last.metrics.writes, 0);
              if (op == QueueOperation.length) expect(state(last)[1], '$n');
              if (!error &&
                  (op == QueueOperation.peek || op == QueueOperation.dequeue)) {
                expect(state(last)[1], '1');
              }
            }
          }
        }
      }
      final full = module.generateTrace(
        const QueueInput(capacity: 10, values: [1, 2, 3, 4, 5, 6, 7, 8, 9]),
      );
      expect(full.frames.last.isErrorState, true);
    },
  );
  test(
    'write before rear, read before front, modulo pointer shortest clockwise interpolation',
    () {
      for (final input in [
        const QueueInput(front: 2, values: [10, 20]),
        const QueueInput(
          front: 4,
          values: [8, 9],
          operation: QueueOperation.dequeue,
        ),
      ]) {
        final t = module.generateTrace(input),
            id = input.operation == QueueOperation.enqueue ? 'rear' : 'front';
        final index = t.frames.indexWhere(
          (f) => f.phaseTitle.contains(id == 'rear' ? '② rear =' : 'front ='),
        );
        final a = t.frames[index - 1],
            b = t.frames[index],
            pa = a.scene.pointers.singleWhere((p) => p.id == id),
            pb = b.scene.pointers.singleWhere((p) => p.id == id);
        expect(pa.targetNodeId, 'slot-4');
        expect(pb.targetNodeId, 'slot-0');
        final mid = SceneInterpolator.lerp(
          a.scene,
          b.scene,
          .5,
        ).pointers.singleWhere((p) => p.id == id);
        expect(mid.orbit!.angle - pa.orbit!.angle, closeTo(math.pi / 5, 1e-9));
        if (id == 'rear') {
          expect(state(a)[4], '2');
          expect(a.scene.nodes[4].label, '99');
          expect(state(b)[4], '3');
        } else {
          expect(state(a)[1], '8');
          expect(state(a)[4], '2');
          expect(state(b)[4], '1');
          expect(b.scene.nodes[4].label, '8');
          expect(b.scene.nodes[4].opacity, lessThan(1));
        }
        expect(SceneInterpolator.lerp(a.scene, b.scene, 0), a.scene);
        expect(SceneInterpolator.lerp(a.scene, b.scene, 1), b.scene);
      }
    },
  );
  test(
    'same operation sequence demonstrates linear false overflow versus circular reuse',
    () {
      for (final kind in [QueueKind.linear, QueueKind.circular]) {
        final t = module.generateTrace(
              QueueInput(kind: kind, operation: QueueOperation.demo),
            ),
            last = t.frames.last,
            h = last.scene.auxTables[1].rows;
        expect(h.map((r) => r[0]).toList(), [
          'Init',
          'EnQueue(1)',
          'EnQueue(2)',
          'EnQueue(3)',
          'EnQueue(4)',
          'DeQueue',
          'DeQueue',
          'DeQueue',
          'EnQueue(9)',
          'EnQueue(10)',
          'EnQueue(11)',
        ]);
        expect(h.where((r) => r[0] == 'DeQueue').map((r) => r[2]).toList(), [
          '1',
          '2',
          '3',
        ]);
        expect(
          t.frames.where((f) => f.isErrorState).length,
          kind == QueueKind.linear ? 2 : 0,
        );
        expect(
          state(last)[5],
          kind == QueueKind.linear ? '4 → 9' : '4 → 9 → 10 → 11',
        );
        expect(state(last)[2], '3');
        expect(state(last)[3], kind == QueueKind.linear ? '5' : '2');
        if (kind == QueueKind.linear) {
          expect(
            last.scene.nodes.singleWhere((n) => n.id == 'end').groupTag,
            'address-anchor',
          );
        }
      }
      final emptyAtEnd = module.generateTrace(
        const QueueInput(kind: QueueKind.linear, front: 5, values: []),
      );
      expect(emptyAtEnd.frames.last.isErrorState, true);
      expect(state(emptyAtEnd.frames.last)[4], '0');
    },
  );
  test(
    'linked FIFO keeps head, resets rear before free and retains reachability at every microstep',
    () {
      for (var n = 0; n <= 6; n++) {
        for (final op in QueueOperation.values.where(
          (o) => o != QueueOperation.demo,
        )) {
          final t = module.generateTrace(
                QueueInput(
                  kind: QueueKind.linked,
                  operation: op,
                  values: [for (var i = 1; i <= n; i++) i],
                ),
              ),
              last = t.frames.last;
          expect(
            last.scene.nodes.singleWhere((n) => n.id == 'head').isDeleted,
            false,
          );
          for (final f in t.frames) {
            expect(f.scene.nodes.any((n) => n.isOrphanLeak), false);
          }
          final expected = op == QueueOperation.init
              ? <int>[]
              : [for (var i = 1; i <= n; i++) i];
          if (op == QueueOperation.enqueue) expected.add(99);
          if (op == QueueOperation.dequeue && n > 0) expected.removeAt(0);
          expect(state(last)[5], expected.join(' → '));
          expect(
            last.isErrorState,
            (op == QueueOperation.peek || op == QueueOperation.dequeue) &&
                n == 0,
          );
          if (op == QueueOperation.length) expect(state(last)[1], '$n');
          if (op == QueueOperation.init) expect(last.metrics.allocations, 1);
          if (op == QueueOperation.dequeue && n == 1) {
            final unlink = t.frames.firstWhere(
                  (f) => f.phaseTitle == 'front->next = p->next',
                ),
                reset = t.frames.firstWhere(
                  (f) => f.phaseTitle.startsWith('rear = front'),
                ),
                free = t.frames.firstWhere((f) => f.phaseTitle == '释放 p');
            expect(
              unlink.scene.edges
                  .singleWhere((e) => e.fromNodeId == 'head')
                  .toNodeId,
              nullNodeId,
            );
            expect(
              unlink.scene.pointers
                  .singleWhere((p) => p.id == 'rear')
                  .targetNodeId,
              'node-0',
            );
            expect(reset.stepIndex, lessThan(free.stepIndex));
            expect(
              reset.scene.pointers
                  .singleWhere((p) => p.id == 'rear')
                  .targetNodeId,
              'head',
            );
            expect(
              free.scene.nodes.singleWhere((n) => n.id == 'node-0').isDeleted,
              true,
            );
            expect(last.scene.pointers.map((p) => p.targetNodeId).toSet(), {
              'head',
            });
          }
        }
      }
    },
  );
  test(
    'init hides uninitialized numeric pointers, all presets are deterministic immutable JSON and bounds checked',
    () {
      final t = module.generateTrace(
        const QueueInput(operation: QueueOperation.init),
      );
      expect(t.frames[1].scene.pointers, isEmpty);
      expect(state(t.frames[1])[2], '未初始化');
      expect(state(t.frames.last)[4], '0');
      for (final p in module.presets) {
        final trace = module.generateTrace(p.input);
        expect(
          TraceTimeline.fromJson(jsonDecode(jsonEncode(trace.toJson()))),
          trace,
        );
        expect(module.generateTrace(p.input), trace);
      }
      for (final raw in [
        'circular|enqueue|5|0|9|1,2,3,4,5',
        'circular|peek|5|5|9|',
        'linear|dequeue|5|4|9|1,2',
        'linked|demo|5|0|9|',
        'circular|init|1|0|9|',
      ]) {
        expect(module.validateInput(raw).isValid, false);
      }
    },
  );
}
