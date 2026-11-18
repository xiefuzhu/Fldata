import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch2_linear_list/merge_compare.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = MergeCompareModule();
  List<String> ids(SceneSnapshot scene) {
    final out = <String>[];
    var p = scene.edges.singleWhere((e) => e.fromNodeId == 'a-head').toNodeId;
    while (p != nullNodeId) {
      expect(out, isNot(contains(p)), reason: 'cycle');
      out.add(p);
      p = scene.edges.singleWhere((e) => e.fromNodeId == p).toNodeId;
    }
    return out;
  }

  test(
    'linked merge preserves every data node/address, stable ties, all small lengths',
    () {
      for (var m = 0; m <= 6; m++) {
        for (var n = 0; n <= 6; n++) {
          final a = List.generate(m, (i) => i ~/ 2),
              b = List.generate(n, (i) => i ~/ 2);
          final t = module.generateTrace(MergeInput(a: a, b: b));
          final first = t.frames.first.scene, last = t.frames.last;
          final expected =
              [
                for (var i = 0; i < m; i++) ('a-$i', a[i], 0, i),
                for (var i = 0; i < n; i++) ('b-$i', b[i], 1, i),
              ]..sort((a, b) {
                final c = a.$2.compareTo(b.$2);
                if (c != 0) return c;
                final side = a.$3.compareTo(b.$3);
                return side != 0 ? side : a.$4.compareTo(b.$4);
              });
          expect(ids(last.scene), expected.map((e) => e.$1).toList());
          expect(last.scene.nodes.length, m + n + 2);
          expect(last.scene.nodes.where((v) => v.isDeleted).map((v) => v.id), [
            'b-head',
          ]);
          for (final node in last.scene.nodes) {
            expect(
              node.memoryAddress,
              first.nodes.singleWhere((n) => n.id == node.id).memoryAddress,
            );
          }
          expect(last.metrics.allocations, 0);
          expect(last.metrics.moves, 0);
          expect(
            last.metrics.comparisons,
            lessThanOrEqualTo(m + n == 0 ? 0 : m + n - 1),
          );
          expect(last.scene.pointers.map((p) => p.label), ['LC']);
          expect(
            t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
            false,
          );
        }
      }
    },
  );
  test('coincident head pointers have separate badge positions', () {
    final scene = module.generateTrace(const MergeInput()).frames[1].scene;
    final badges = scene.pointers
        .where((p) => p.targetNodeId == 'a-head')
        .toList();
    expect(badges.map((p) => p.dy).toSet().length, badges.length);
  });
  test(
    'link assignment, cursor moves, one write for whole remainder and only HB freed',
    () {
      final t = module.generateTrace(const MergeInput(a: [1], b: [2, 4, 6]));
      final attach = t.frames.indexWhere((f) => f.phaseTitle.startsWith('穿接'));
      expect(
        t.frames[attach].scene.pointers
            .singleWhere((p) => p.id == 'pa')
            .targetNodeId,
        'a-0',
      );
      expect(
        t.frames[attach + 1].scene.pointers
            .singleWhere((p) => p.id == 'pa')
            .targetNodeId,
        nullNodeId,
      );
      expect(
        t.frames[attach + 2].scene.pointers
            .singleWhere((p) => p.id == 'pc')
            .targetNodeId,
        'a-0',
      );
      final k = t.frames.indexWhere((f) => f.phaseTitle.startsWith('整串挂接'));
      expect(t.frames[k].metrics.writes - t.frames[k - 1].metrics.writes, 1);
      expect(ids(t.frames[k].scene), ['a-0', 'b-0', 'b-1', 'b-2']);
      expect(t.frames[k].scene.nodes.any((n) => n.isDeleted), false);
      expect(
        t.frames[k + 1].scene.nodes.where((n) => n.isDeleted).map((n) => n.id),
        ['b-head'],
      );
      expect(t.frames.last.metrics.comparisons, 1);
    },
  );
  test(
    'sequential merge copies m+n slots with isolated result and intact inputs',
    () {
      for (var m = 0; m <= 6; m++) {
        for (var n = 0; n <= 6; n++) {
          final a = List.generate(m, (i) => i * 2),
              b = List.generate(n, (i) => i * 2 + 1);
          final t = module.generateTrace(
            MergeInput(operation: MergeOperation.sequential, a: a, b: b),
          );
          final last = t.frames.last;
          final expected = [...a, ...b]..sort();
          expect(
            last.scene.auxTables.first.rows.first[1],
            expected.join(' → '),
          );
          expect(last.metrics.moves, m + n);
          expect(last.metrics.writes, m + n);
          expect(last.metrics.auxiliarySpace, m + n);
          expect(last.metrics.allocations, m + n == 0 ? 0 : 1);
          for (final node in t.frames.first.scene.nodes) {
            expect(last.scene.nodes.singleWhere((n) => n.id == node.id), node);
          }
          expect(
            last.scene.nodes.where((n) => n.id.startsWith('C-')).length,
            m + n,
          );
        }
      }
    },
  );
  test(
    'union scans original set, retains order, rejects repeated and unsorted mode input',
    () {
      final cases = [
        const MergeInput(
          operation: MergeOperation.union,
          a: [5, 1, 3],
          b: [3, 2, 5, 7],
        ),
        const MergeInput(operation: MergeOperation.union, a: [], b: [3, 1]),
        const MergeInput(operation: MergeOperation.union, a: [2], b: []),
      ];
      for (final input in cases) {
        final t = module.generateTrace(input), last = t.frames.last;
        final expected = [
          ...input.a,
          ...input.b.where((v) => !input.a.contains(v)),
        ];
        expect(last.scene.auxTables.first.rows.first[1], expected.join(' → '));
        expect(
          last.metrics.comparisons,
          lessThanOrEqualTo(input.a.length * input.b.length),
        );
        expect(last.metrics.allocations, 0);
      }
      expect(module.validateInput('union|1,1|2').isValid, false);
      expect(module.validateInput('linked|3,1|2').isValid, false);
      expect(module.validateInput('sequential|1,1|2,2').isValid, true);
      expect(module.validateInput('linked||').isValid, true);
    },
  );
  test(
    'all presets deterministic, serialized snapshots preserve historical links',
    () {
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
      final t = module.generateTrace(const MergeInput());
      expect(ids(t.frames.first.scene), ['a-0', 'a-1', 'a-2']);
      expect(ids(t.frames.last.scene), [
        'a-0',
        'b-0',
        'a-1',
        'b-1',
        'a-2',
        'b-2',
      ]);
      expect(() => t.frames.first.scene.nodes.clear(), throwsUnsupportedError);
    },
  );
}
