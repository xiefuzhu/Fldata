import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch3_stack_queue/stack_sq_link.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = StackSqLinkModule();
  List<String> state(TraceTimeline t) =>
      t.frames.last.scene.auxTables.first.rows.first;
  List<String> order(TraceTimeline t) =>
      t.frames.last.scene.auxTables[1].rows.first;
  test(
    'sequential top is next empty, one-past capacity is not a storage slot',
    () {
      for (var cap = 1; cap <= 10; cap++) {
        for (var n = 0; n <= cap; n++) {
          final values = List.generate(n, (i) => i + 1);
          for (final op in StackOperation.values) {
            final t = module.generateTrace(
              StackInput(capacity: cap, a: values, operation: op),
            );
            final invalid =
                op == StackOperation.push && n == cap ||
                (op == StackOperation.pop || op == StackOperation.peek) &&
                    n == 0;
            expect(t.frames.last.isErrorState, invalid);
            if (invalid) {
              expect(order(t)[0], values.join(' → '));
              expect(t.frames.last.metrics.writes, 0);
              continue;
            }
            final expected = op == StackOperation.init
                ? <int>[]
                : op == StackOperation.push
                ? [...values, 99]
                : op == StackOperation.pop
                ? values.take(n - 1).toList()
                : values;
            expect(order(t)[0], expected.join(' → '));
            expect(state(t)[2], '${expected.length}');
            expect(
              t.frames.last.scene.nodes
                  .where((n) => n.id.startsWith('slot-'))
                  .length,
              cap,
            );
            final top = t.frames.last.scene.pointers.singleWhere(
              (p) => p.id == 'top',
            );
            expect(
              top.targetNodeId,
              expected.length == cap ? 'end' : 'slot-${expected.length}',
            );
            if (expected.length == cap) {
              expect(
                t.frames.last.scene.nodes
                    .singleWhere((n) => n.id == 'end')
                    .groupTag,
                'address-anchor',
              );
            }
            if (op == StackOperation.pop || op == StackOperation.peek) {
              expect(state(t)[1], '${values.last}');
            }
          }
        }
      }
    },
  );
  test(
    'array push and pop assignment microsteps preserve exact memory and output order',
    () {
      final push = module.generateTrace(
        const StackInput(a: [1, 2], capacity: 3),
      );
      final write = push.frames.singleWhere(
        (f) => f.phaseTitle == '① *top = e',
      );
      expect(write.scene.auxTables.first.rows.first[2], '2');
      expect(
        write.scene.nodes.singleWhere((n) => n.id == 'slot-2').label,
        '99',
      );
      expect(write.scene.auxTables[1].rows.first[0], '1 → 2');
      final pop = module.generateTrace(
        const StackInput(operation: StackOperation.pop, a: [1, 2], capacity: 3),
      );
      final move = pop.frames.singleWhere((f) => f.phaseTitle == '① --top');
      expect(move.scene.auxTables.first.rows.first[2], '1');
      expect(move.scene.auxTables.first.rows.first[1], '—');
      final read = pop.frames.singleWhere((f) => f.phaseTitle == '② e = *top');
      expect(read.scene.auxTables.first.rows.first[1], '2');
      expect(read.scene.nodes.singleWhere((n) => n.id == 'slot-1').label, '2');
      expect(
        read.scene.nodes.singleWhere((n) => n.id == 'slot-1').opacity,
        lessThan(1),
      );
      expect(
        pop.frames.first.scene.nodes
            .singleWhere((n) => n.id == 'slot-1')
            .opacity,
        1,
      );
    },
  );
  test(
    'headless linked stack uses S root, safe pop ownership, LIFO and no head allocation',
    () {
      for (var n = 0; n <= 6; n++) {
        for (final op in StackOperation.values) {
          final values = List.generate(n, (i) => i + 1),
              t = module.generateTrace(
                StackInput(kind: StackKind.linked, operation: op, a: values),
              );
          expect(
            t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
            false,
          );
          expect(
            t.frames.last.scene.nodes.any(
              (n) => n.visualState == NodeVisualState.sentinel,
            ),
            false,
          );
          if (op == StackOperation.init) {
            expect(t.frames.last.metrics.allocations, 0);
            expect(t.frames.last.scene.nodes, isEmpty);
            expect(
              t.frames.last.scene.pointers.single.targetNodeId,
              nullNodeId,
            );
            continue;
          }
          if (n == 0 &&
              (op == StackOperation.pop || op == StackOperation.peek)) {
            expect(t.frames.last.isErrorState, true);
            continue;
          }
          final expected = op == StackOperation.push
              ? [...values, 99]
              : op == StackOperation.pop
              ? values.take(n - 1).toList()
              : values;
          expect(order(t)[0], expected.join(' → '));
          expect(
            t.frames.last.metrics.allocations,
            op == StackOperation.push ? 1 : 0,
          );
          expect(
            t.frames.last.scene.nodes.where((n) => n.isDeleted).length,
            op == StackOperation.pop ? 1 : 0,
          );
          if (op != StackOperation.push) expect(state(t)[1], '${values.last}');
          if (expected.isEmpty) {
            expect(
              t.frames.last.scene.pointers
                  .singleWhere((p) => p.id == 'S')
                  .targetNodeId,
              nullNodeId,
            );
          }
        }
      }
    },
  );
  test(
    'shared stacks use all free space, enforce collision and distinguish each empty stack',
    () {
      for (var cap = 1; cap <= 6; cap++) {
        for (var m = 0; m <= cap; m++) {
          for (var n = 0; n <= cap - m; n++) {
            for (final side in [0, 1]) {
              for (final op in [
                StackOperation.push,
                StackOperation.pop,
                StackOperation.peek,
              ]) {
                final a = List.generate(m, (i) => i + 1),
                    b = List.generate(n, (i) => 10 + i);
                final t = module.generateTrace(
                  StackInput(
                    kind: StackKind.shared,
                    capacity: cap,
                    a: a,
                    b: b,
                    stack: side,
                    operation: op,
                  ),
                );
                final selected = side == 0 ? a : b;
                final invalid = op == StackOperation.push
                    ? m + n == cap
                    : selected.isEmpty;
                expect(t.frames.last.isErrorState, invalid);
                if (invalid) {
                  expect(order(t), [a.join(' → '), b.join(' → ')]);
                  expect(t.frames.last.metrics.writes, 0);
                  continue;
                }
                final expected = op == StackOperation.push
                    ? [...selected, 99]
                    : op == StackOperation.pop
                    ? selected.take(selected.length - 1).toList()
                    : selected;
                final aa = side == 0 ? expected : a,
                    bb = side == 1 ? expected : b;
                expect(order(t), [aa.join(' → '), bb.join(' → ')]);
                expect(state(t)[2], '${aa.length - 1}');
                expect(state(t)[3], '${cap - bb.length}');
                expect(state(t)[4], '${cap - aa.length - bb.length}');
                if (op != StackOperation.push) {
                  expect(state(t)[1], '${selected.last}');
                }
                if (aa.length + bb.length == cap) {
                  expect(
                    t.frames.last.scene.zones.any((z) => z.id == 'stack-full'),
                    true,
                  );
                }
              }
            }
          }
        }
      }
    },
  );
  test(
    'all modes initialize empty; source presets are reversible JSON snapshots',
    () {
      for (final kind in StackKind.values) {
        final t = module.generateTrace(
          StackInput(kind: kind, operation: StackOperation.init),
        );
        expect(order(t)[0], '');
        if (kind == StackKind.shared) {
          expect(order(t)[1], '');
          expect(state(t)[2], '-1');
          expect(state(t)[3], '6');
        }
      }
      for (final preset in module.presets) {
        final t = module.generateTrace(preset.input);
        expect(module.generateTrace(preset.input), t);
        expect(
          TraceTimeline.fromJson(
            jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>,
          ),
          t,
        );
      }
      expect(module.validateInput('shared|push|3|1|5|1,2|3,4').isValid, false);
      expect(module.validateInput('linked|push|1|0|5|1,2,3|').isValid, true);
    },
  );
}
