import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/edge_geometry.dart';
import 'package:fldata/curriculum/ch2_linear_list/circular_dulink.dart';
import 'package:fldata/engine/vm/memory_leaks.dart';
import 'package:fldata/models/trace_model.dart';

List<String> ring(TraceFrame frame, {bool reverse = false}) {
  final nodes = {for (final n in frame.scene.nodes) n.id: n};
  final edges = {
    for (final e in frame.scene.edges.where(
      (e) => e.fromPort == (reverse ? EdgePort.prior : EdgePort.next),
    ))
      e.fromNodeId: e.toNodeId,
  };
  final data = <String>[], seen = <String>{'a-head'};
  var p = edges['a-head']!;
  while (p != 'a-head') {
    expect(p, isNot(nullNodeId));
    expect(seen.add(p), isTrue, reason: 'cycle bypasses header');
    expect(nodes[p]!.isDeleted, isFalse);
    data.add(nodes[p]!.label);
    p = edges[p]!;
  }
  return data;
}

void main() {
  const module = CircularDulinkModule();
  test(
    'tail merge handles all empty/nonempty pairs, preserves a single ring with constant work',
    () {
      for (var n = 0; n <= 5; n++) {
        for (var m = 0; m <= 5; m++) {
          final a = List.generate(n, (k) => String.fromCharCode(65 + k)),
              b = List.generate(m, (k) => String.fromCharCode(75 + k));
          final t = module.generateTrace(CircularInput(a: a, b: b));
          final f = t.frames.last;
          expect(ring(f), [...a, ...b]);
          expect(
            f.scene.nodes.singleWhere((n) => n.id == 'b-head').isDeleted,
            isTrue,
          );
          expect(f.scene.nodes.where((n) => !n.isDeleted).length, n + m + 1);
          expect(f.scene.pointers.single.label, 'T');
          expect(
            f.scene.pointers.single.targetNodeId,
            m > 0
                ? 'b-${m - 1}'
                : n > 0
                ? 'a-${n - 1}'
                : 'a-head',
          );
          expect(f.metrics.writes, m > 0 ? 2 : 0);
          expect(f.metrics.reads, m > 0 ? 4 : 1);
          expect(f.metrics.allocations, 0);
          expect(t.frames.length, m > 0 ? 7 : 4);
          for (final frame in t.frames) {
            expect(
              detectMemoryLeaks(frame.scene),
              isEmpty,
              reason: frame.phaseTitle,
            );
          }
        }
      }
    },
  );
  test(
    'four-step merge preserves temporary dangling edge only between free and close',
    () {
      final t = module.generateTrace(const CircularInput());
      final free = t.frames.firstWhere(
        (f) => f.phaseTitle == '③ delete Tb->next',
      );
      expect(
        free.scene.edges.singleWhere((e) => e.id == 'b-1-next').toNodeId,
        'b-head',
      );
      expect(
        free.scene.edges.singleWhere((e) => e.id == 'b-1-next').visualState,
        NodeVisualState.error,
      );
      expect(free.scene.auxTables.first.rows.first[3], '1');
      final close = t.frames[free.stepIndex + 1];
      expect(
        close.scene.edges.singleWhere((e) => e.id == 'b-1-next').toNodeId,
        'a-head',
      );
      expect(close.scene.auxTables.first.rows.first[3], '0');
      expect(t.frames.first.scene.nodes.every((n) => !n.isDeleted), isTrue);
    },
  );
  test(
    'dual insert/delete all positions preserve forward and reverse circular invariants',
    () {
      for (var n = 0; n <= 5; n++) {
        final a = List.generate(n, (k) => String.fromCharCode(65 + k));
        for (var i = 1; i <= n + 1; i++) {
          final t = module.generateTrace(
            CircularInput(
              operation: CircularOperation.insert,
              a: a,
              position: i,
            ),
          );
          final expected = [...a]..insert(i - 1, 'X');
          expect(ring(t.frames.last), expected);
          expect(
            ring(t.frames.last, reverse: true),
            expected.reversed.toList(),
          );
          expect(t.frames.last.scene.auxTables.first.rows.first[2], '0');
          expect(t.frames.last.metrics.writes, 4);
          for (final f in t.frames) {
            expect(detectMemoryLeaks(f.scene), isEmpty);
          }
        }
        for (var i = 1; i <= n; i++) {
          final t = module.generateTrace(
            CircularInput(
              operation: CircularOperation.delete,
              a: a,
              position: i,
            ),
          );
          final expected = [...a]..removeAt(i - 1);
          expect(ring(t.frames.last), expected);
          expect(
            ring(t.frames.last, reverse: true),
            expected.reversed.toList(),
          );
          expect(t.frames.last.inlineVars['out'], a[i - 1]);
          expect(t.frames.last.metrics.writes, 2);
          expect(t.frames.last.scene.auxTables.first.rows.first[2], '0');
          for (final f in t.frames) {
            expect(detectMemoryLeaks(f.scene), isEmpty);
          }
        }
      }
    },
  );
  test(
    'four assignments target exact fields and distinguish transient mismatch from wrong order',
    () {
      final normal = module.generateTrace(
        const CircularInput(operation: CircularOperation.insert),
      );
      final stages = normal.frames
          .where((f) => RegExp(r'^[①②③④]').hasMatch(f.phaseTitle))
          .toList();
      String target(TraceFrame f, String id) =>
          f.scene.edges.singleWhere((e) => e.id == id).toNodeId;
      expect(stages.length, 4);
      expect(target(stages[0], 'new-prior'), 'a-0');
      expect(target(stages[0], 'a-0-next'), 'a-1');
      expect(target(stages[1], 'a-0-next'), 'new');
      expect(target(stages[1], 'a-1-prior'), 'a-0');
      expect(target(stages[2], 'new-next'), 'a-1');
      expect(target(stages[2], 'a-1-prior'), 'a-0');
      expect(target(stages[3], 'a-1-prior'), 'new');
      expect(stages[3].scene.auxTables.first.rows.first[2], '0');
      expect(normal.frames.any((f) => f.isErrorState), isFalse);
      final wrong = module.generateTrace(
        const CircularInput(operation: CircularOperation.wrongInsert),
      );
      expect(wrong.frames.where((f) => f.isErrorState).length, 2);
      expect(target(wrong.frames.last, 'new-next'), 'new');
      expect(target(wrong.frames.last, 'a-0-next'), 'a-1');
      expect(wrong.frames.last.scene.auxTables.first.rows.first[2], isNot('0'));
      expect(
        detectMemoryLeaks(wrong.frames.last.scene),
        isEmpty,
        reason: 'local s still owns new node',
      );
    },
  );
  test(
    'invalid positions keep links untouched, empty delete fails and snapshots roundtrip',
    () {
      for (final op in [CircularOperation.insert, CircularOperation.delete]) {
        for (final a in [
          <String>[],
          ['A', 'B'],
        ]) {
          for (final i in [
            0,
            a.length + (op == CircularOperation.insert ? 2 : 1),
          ]) {
            final t = module.generateTrace(
              CircularInput(operation: op, a: a, position: i),
            );
            expect(t.frames.last.isErrorState, isTrue);
            expect(t.frames.last.metrics.writes, 0);
            expect(ring(t.frames.last), a);
          }
        }
      }
      for (final p in module.presets) {
        final t = module.generateTrace(p.input);
        expect(TraceTimeline.fromJson(jsonDecode(jsonEncode(t.toJson()))), t);
        expect(module.generateTrace(p.input), t);
      }
      expect(module.validateInput('merge|1|X||').isValid, isTrue);
      expect(module.validateInput('merge|1|X|A B C D E F|').isValid, isFalse);
    },
  );
  test('empty dual ring has distinct left prior and right next self-loops', () {
    final frame = module
        .generateTrace(
          const CircularInput(
            operation: CircularOperation.delete,
            a: ['A'],
            position: 1,
          ),
        )
        .frames
        .last;
    final nodes = {for (final n in frame.scene.nodes) n.id: n};
    final next = frame.scene.edges.singleWhere((e) => e.id == 'a-head-next');
    final prior = frame.scene.edges.singleWhere((e) => e.id == 'a-head-prior');
    final a = edgeGeometry(frame.scene, next, nodes)!,
        b = edgeGeometry(frame.scene, prior, nodes)!;
    expect(a.$2.dx, greaterThan(nodes['a-head']!.x + nodes['a-head']!.width));
    expect(b.$2.dx, lessThan(nodes['a-head']!.x));
    expect(a.$1.dx, greaterThan(b.$1.dx));
  });
  test('singleton ring closing edges arc outside the cells', () {
    final frame = module
        .generateTrace(
          const CircularInput(
            operation: CircularOperation.delete,
            a: ['A'],
            position: 1,
          ),
        )
        .frames
        .first;
    final nodes = {for (final n in frame.scene.nodes) n.id: n};
    final back = frame.scene.edges.singleWhere((e) => e.id == 'a-0-next');
    final prior = frame.scene.edges.singleWhere((e) => e.id == 'a-head-prior');
    expect(
      curvePoint(edgeGeometry(frame.scene, back, nodes)!, .5).dy,
      lessThan(nodes['a-head']!.y),
    );
    expect(
      curvePoint(edgeGeometry(frame.scene, prior, nodes)!, .5).dy,
      greaterThan(nodes['a-head']!.y + nodes['a-head']!.height),
    );
  });
}
