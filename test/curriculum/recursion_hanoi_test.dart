import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch3_stack_queue/recursion_hanoi.dart';
import 'package:fldata/curriculum/ch3_stack_queue/recursion_trace.dart';
import 'package:fldata/engine/debugger/call_tree_projection.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = RecursionHanoiModule();
  List<List<int>> pegs(TraceFrame f) => [
    for (final r in f.scene.auxTables.singleWhere((t) => t.id == 'pegs').rows)
      r[1].isEmpty ? [] : r[1].split(',').map(int.parse).toList(),
  ];
  test(
    'Hanoi 1..6 legal top moves, exact 2^n-1 milestones and O(n) active stack',
    () {
      for (var n = 1; n <= 6; n++) {
        final trace = module.generateTrace(RecursionInput(n: n));
        var previous = pegs(trace.frames.first), count = 0;
        for (final f in trace.frames) {
          final current = pegs(f);
          expect(current.expand((x) => x).toList()..sort(), [
            for (var i = 1; i <= n; i++) i,
          ]);
          for (final peg in current) {
            for (var i = 1; i < peg.length; i++) {
              expect(peg[i - 1], greaterThan(peg[i]));
            }
          }
          if (f.metrics.moves > count) {
            expect(f.metrics.moves, count + 1);
            expect(f.isKeyMilestone, true);
            final from = [
              for (var i = 0; i < 3; i++)
                if (current[i].length < previous[i].length) i,
            ].single;
            final to = [
              for (var i = 0; i < 3; i++)
                if (current[i].length > previous[i].length) i,
            ].single;
            expect(current[to].last, previous[from].last);
            expect(
              current[from],
              previous[from].sublist(0, previous[from].length - 1),
            );
            count++;
          } else {
            expect(current, previous);
          }
          expect(f.metrics.callDepth, f.callStack.length);
          expect(f.metrics.auxiliarySpace, f.callStack.length);
          previous = current;
        }
        expect(count, (1 << n) - 1);
        expect(trace.frames.where((f) => f.isKeyMilestone).length, count);
        expect(previous, [
          [],
          [],
          [for (var i = n; i > 0; i--) i],
        ]);
        expect(trace.frames.last.callStack, isEmpty);
        expect(trace.frames.last.metrics.maxCallDepth, n);
        expect(
          trace.frames.first.scene.auxTables.last.rows.first[1],
          [for (var i = n; i > 0; i--) i].join(','),
        );
      }
    },
  );
  test(
    'return pops exactly one activation and resumes parent at correct RetLoc with restored args',
    () {
      final trace = module.generateTrace(const RecursionInput());
      final destinations = <String>{};
      for (var i = 1; i < trace.frames.length; i++) {
        final f = trace.frames[i],
            prev = trace.frames[i - 1],
            event = f.scene.auxTables[1].rows.single;
        if (event[0].isEmpty) continue;
        final popped = prev.callStack.last;
        expect(event[0], popped.id);
        expect(event[1], popped.returnLocation);
        expect(f.callStack.length, prev.callStack.length - 1);
        destinations.add(event[1]);
        if (f.callStack.isNotEmpty) {
          expect(f.callStack.last.id, popped.parentCallId);
          expect(f.callStack.last.locals['PC'], event[1]);
          expect(
            f.callStack.last.arguments,
            prev.callStack[prev.callStack.length - 2].arguments,
          );
          final next = trace.frames[i + 1];
          if (event[1] == 'RetLoc1') {
            expect(next.phaseTitle, startsWith('准备搬移'));
          } else {
            expect(next.phaseTitle, startsWith('返回准备'));
          }
        } else {
          expect(event[1], 'Main');
        }
      }
      expect(destinations, {'Main', 'RetLoc1', 'RetLoc2'});
      expect(
        CallTreeProjection(trace, trace.frames.length - 1).records.length,
        7,
      );
      expect(CallTreeProjection(trace, 0).records.length, 1);
      expect(
        CallTreeProjection(trace, trace.frames.length - 1).activeIds,
        isEmpty,
      );
    },
  );
  test(
    'parabolic disk interpolation is deterministic, reversible and preserves other disks',
    () {
      final trace = module.generateTrace(const RecursionInput(n: 6));
      for (var i = 1; i < trace.frames.length; i++) {
        final from = trace.frames[i - 1], to = trace.frames[i];
        if (to.metrics.moves == from.metrics.moves) continue;
        final before = {for (final n in from.scene.nodes) n.id: n},
            after = {for (final n in to.scene.nodes) n.id: n};
        final moving = before.keys.singleWhere(
          (id) => before[id]!.groupTag != after[id]!.groupTag,
        );
        final mid = interpolateHanoi(from.scene, to.scene, .5);
        for (final node in mid.nodes) {
          final a = before[node.id]!, b = after[node.id]!;
          if (node.id == moving) {
            expect(node.x, (a.x + b.x) / 2);
            expect(node.y, lessThan(82 - node.height));
            expect(node.y, greaterThanOrEqualTo(0));
          } else {
            expect(node, a);
          }
        }
        expect(interpolateHanoi(from.scene, to.scene, .5), mid);
        final first = interpolateHanoi(from.scene, to.scene, 0),
            last = interpolateHanoi(from.scene, to.scene, 1);
        for (final node in first.nodes) {
          expect(node.x, before[node.id]!.x);
          expect(node.y, before[node.id]!.y);
        }
        for (final node in last.nodes) {
          expect(node.x, after[node.id]!.x);
          expect(node.y, after[node.id]!.y);
        }
      }
    },
  );
  test(
    'Fact, naive Fib and forward recursive traversal preserve returned locals and base cases',
    () {
      var fact = 1;
      for (var n = 0; n <= 10; n++) {
        if (n > 0) fact *= n;
        final t = module.generateTrace(
          RecursionInput(kind: RecursionKind.factorial, n: n),
        );
        expect(t.frames.last.scene.auxTables.first.rows.first[2], '$fact');
        expect(t.frames.last.metrics.maxCallDepth, n < 1 ? 1 : n);
      }
      var a = 0, b = 1;
      for (var n = 1; n <= 10; n++) {
        final expected = a + b;
        a = b;
        b = expected;
        final t = module.generateTrace(
          RecursionInput(kind: RecursionKind.fibonacci, n: n),
        );
        expect(t.frames.last.scene.auxTables.first.rows.first[2], '$a');
        for (final f in t.frames.where((f) => f.phaseTitle == '弹栈 → RetLoc2')) {
          expect(f.callStack.last.locals.keys, containsAll(['a', 'b']));
        }
        if (n == 5) {
          expect(CallTreeProjection(t, t.frames.length - 1).records.length, 9);
        }
      }
      for (var n = 0; n <= 8; n++) {
        final values = [for (var i = 0; i < n; i++) i * 3 - 5],
            t = module.generateTrace(
              RecursionInput(kind: RecursionKind.traverse, values: values),
            );
        expect(
          t.frames.last.scene.auxTables.first.rows.first[3],
          values.join(' → '),
        );
        expect(t.frames.where((f) => f.isKeyMilestone).length, n);
        expect(t.frames.last.metrics.maxCallDepth, n + 1);
        expect(t.frames.last.scene.nodes.length, n);
      }
    },
  );
  test('presets snapshot JSON round trip and input bounds', () {
    for (final p in module.presets) {
      expect(module.validateInput(p.input.raw).isValid, true);
      final t = module.generateTrace(p.input);
      expect(TraceTimeline.fromJson(jsonDecode(jsonEncode(t.toJson()))), t);
      expect(module.generateTrace(p.input), t);
    }
    for (final raw in [
      'hanoi|0|',
      'hanoi|7|',
      'fibonacci|0|',
      'factorial|11|',
      'traverse|3|1000',
      'traverse|3|1,2,3,4,5,6,7,8,9',
    ]) {
      expect(module.validateInput(raw).isValid, false);
    }
  });
}
