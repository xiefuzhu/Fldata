import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch2_linear_list/cases_polyn_book.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = CasesPolynBookModule();
  List<SceneNode> chain(SceneSnapshot scene, String head) {
    final out = <SceneNode>[];
    var p = scene.edges.singleWhere((e) => e.fromNodeId == head).toNodeId;
    while (p != nullNodeId) {
      expect(out.any((n) => n.id == p), false);
      final n = scene.nodes.singleWhere((n) => n.id == p);
      expect(n.isDeleted, false);
      out.add(n);
      p = scene.edges.singleWhere((e) => e.fromNodeId == p).toNodeId;
    }
    return out;
  }

  List<String> books(TraceTimeline t) => t.frames.last.scene.auxTables
      .singleWhere((a) => a.id == 'books')
      .rows
      .map((r) => r[0])
      .toList();
  test('textbook polynomial gives four terms and destroys both x8 nodes', () {
    final t = module.generateTrace(const CasesInput()), last = t.frames.last;
    expect(last.scene.auxTables.first.rows.first[1], '7 + 11x + 22x^7 + 5x^17');
    expect(chain(last.scene, 'a-head').map((n) => n.id), [
      'a-0',
      'a-1',
      'b-1',
      'a-3',
    ]);
    expect(
      last.scene.nodes.where((n) => n.isDeleted).map((n) => n.id).toSet(),
      {'a-2', 'b-0', 'b-2', 'b-head'},
    );
    final a = t.frames.indexWhere((f) => f.phaseTitle == '同指数相消 · 释放 A 节点');
    final b = t.frames.indexWhere((f) => f.phaseTitle == '同指数相消 · 释放 B 节点');
    expect(b, greaterThan(a));
    expect(
      t.frames[a].scene.nodes.singleWhere((n) => n.id == 'a-2').isDeleted,
      true,
    );
    expect(
      t.frames[a].scene.nodes.singleWhere((n) => n.id == 'b-2').isDeleted,
      false,
    );
    expect(
      t.frames[b].scene.nodes.singleWhere((n) => n.id == 'b-2').isDeleted,
      true,
    );
    expect(
      t.frames[a].scene.pointers.singleWhere((p) => p.id == 'p1').targetNodeId,
      'a-3',
    );
    expect(
      t.frames[b].scene.pointers.singleWhere((p) => p.id == 'p2').targetNodeId,
      nullNodeId,
    );
    expect(
      last.scene.auxTables.singleWhere((a) => a.id == 'density').rows.first,
      ['18', '4', '14'],
    );
    expect(last.metrics.allocations, 0);
    expect(last.scene.auxTables.first.rows.first[3], '0');
  });
  test(
    'sparse addition matches coefficient map including empty and zero sums',
    () {
      final random = Random(208);
      for (var m = 0; m <= 6; m++) {
        for (var n = 0; n <= 6; n++) {
          List<PolyTerm> make(int count) {
            final exps = List.generate(10, (i) => i)..shuffle(random);
            final chosen = exps.take(count).toList()..sort();
            return [
              for (final e in chosen)
                PolyTerm(
                  (random.nextBool() ? 1 : -1) *
                      (1 + random.nextInt(3)).toDouble(),
                  e,
                ),
            ];
          }

          final a = make(m), b = make(n), expected = <int, double>{};
          for (final v in [...a, ...b]) {
            expected.update(
              v.exponent,
              (c) => c + v.coefficient,
              ifAbsent: () => v.coefficient,
            );
          }
          expected.removeWhere((k, v) => v == 0);
          final t = module.generateTrace(CasesInput(a: a, b: b)),
              last = t.frames.last;
          final order = chain(last.scene, 'a-head');
          final actual = <int, double>{};
          final heap = last.scene.auxTables
              .singleWhere((a) => a.id == 'heap')
              .rows;
          for (final node in order) {
            final row = heap.singleWhere((r) => r[0] == node.id);
            actual[int.parse(row[3])] = double.parse(row[2]);
          }
          expect(actual, expected);
          expect(actual.keys.toList(), expected.keys.toList()..sort());
          expect(
            t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
            false,
          );
          expect(last.scene.nodes.length, m + n + 2);
          expect(last.metrics.allocations, 0);
          for (final node in last.scene.nodes) {
            expect(
              node.memoryAddress,
              t.frames.first.scene.nodes
                  .singleWhere((n) => n.id == node.id)
                  .memoryAddress,
            );
          }
        }
      }
    },
  );
  test(
    'CreatePolyn inserts unsorted input into ascending chain with stable identities',
    () {
      for (var n = 0; n <= 6; n++) {
        final input = [
          for (var k = n - 1; k >= 0; k--) PolyTerm(k + 1.0, k * 3),
        ];
        final t = module.generateTrace(
          CasesInput(operation: CaseOperation.create, a: input),
        );
        expect(chain(t.frames.last.scene, 'a-head').map((n) => n.label), [
          for (var k = 0; k < n; k++) '${k + 1}\nx^${k * 3}',
        ]);
        expect(t.frames.last.metrics.allocations, n + 1);
        expect(
          t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
          false,
        );
      }
    },
  );
  test(
    'book insert/delete all legal positions preserve order and report copying costs',
    () {
      for (final linked in [true, false]) {
        for (var n = 0; n <= 5; n++) {
          final input = [
            for (var k = 0; k < n; k++) BookRecord('B$k', '图书$k', k + 1.0),
          ];
          for (var i = 1; i <= n + 1; i++) {
            final t = module.generateTrace(
              CasesInput(
                operation: CaseOperation.bookInsert,
                linked: linked,
                books: input,
                position: i,
              ),
            );
            final expected = input.map((b) => b.isbn).toList()
              ..insert(i - 1, 'DS04');
            expect(books(t), expected);
            expect(t.frames.last.metrics.moves, linked ? 0 : n - i + 1);
            expect(t.frames.last.metrics.allocations, linked ? 1 : 0);
            expect(
              t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
              false,
            );
          }
          for (var i = 1; i <= n; i++) {
            final t = module.generateTrace(
              CasesInput(
                operation: CaseOperation.bookDelete,
                linked: linked,
                books: input,
                position: i,
              ),
            );
            final expected = input.map((b) => b.isbn).toList()..removeAt(i - 1);
            expect(books(t), expected);
            expect(t.frames.last.metrics.moves, linked ? 0 : n - i);
            expect(
              t.frames.last.scene.auxTables.first.rows.first[1],
              input[i - 1].raw,
            );
            expect(
              t.frames.expand((f) => f.scene.nodes).any((n) => n.isOrphanLeak),
              false,
            );
            if (linked) {
              expect(
                t.frames.last.scene.nodes.where((n) => n.isDeleted).length,
                1,
              );
            }
          }
        }
      }
    },
  );
  test(
    'book lookup, invalid positions, duplicate and capacity leave records unchanged',
    () {
      for (final linked in [true, false]) {
        final found = module.generateTrace(
          CasesInput(operation: CaseOperation.bookFind, linked: linked),
        );
        expect(found.frames.last.scene.auxTables.first.rows.first[0], 'FOUND');
        expect(found.frames.last.metrics.comparisons, 2);
        final miss = module.generateTrace(
          CasesInput(
            operation: CaseOperation.bookFind,
            linked: linked,
            query: 'NONE',
          ),
        );
        expect(
          miss.frames.last.scene.auxTables.first.rows.first[0],
          'NOT_FOUND',
        );
        expect(miss.frames.last.metrics.comparisons, 3);
        for (final op in [CaseOperation.bookInsert, CaseOperation.bookDelete]) {
          for (final pos in [0, 6]) {
            final t = module.generateTrace(
              CasesInput(operation: op, linked: linked, position: pos),
            );
            expect(t.frames.last.isErrorState, true);
            expect(books(t), ['DS01', 'DS02', 'DS03']);
            expect(t.frames.last.metrics.writes, 0);
          }
        }
        final duplicate = module.generateTrace(
          CasesInput(
            operation: CaseOperation.bookInsert,
            linked: linked,
            book: const BookRecord('DS02', '重号', 1),
          ),
        );
        expect(
          duplicate.frames.last.scene.auxTables.first.rows.first[0],
          'DUPLICATE',
        );
        expect(duplicate.frames.last.metrics.writes, 0);
        final full = [for (var k = 0; k < 8; k++) BookRecord('B$k', '图书$k', 1)];
        final t = module.generateTrace(
          CasesInput(
            operation: CaseOperation.bookInsert,
            linked: linked,
            books: full,
          ),
        );
        expect(t.frames.last.isErrorState, true);
        expect(books(t), full.map((b) => b.isbn));
        expect(t.frames.last.metrics.writes, 0);
      }
    },
  );
  test('validation and deterministic JSON presets', () {
    for (final preset in module.presets) {
      expect(module.validateInput(preset.input.raw).isValid, true);
      final t = module.generateTrace(preset.input);
      expect(module.generateTrace(preset.input), t);
      expect(
        TraceTimeline.fromJson(
          jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>,
        ),
        t,
      );
    }
    expect(
      module.validateInput(const CasesInput(a: [PolyTerm(0, 0)]).raw).isValid,
      false,
    );
    expect(
      module
          .validateInput(
            const CasesInput(a: [PolyTerm(1, 2), PolyTerm(2, 1)]).raw,
          )
          .isValid,
      false,
    );
    expect(
      module
          .validateInput(
            const CasesInput(
              operation: CaseOperation.create,
              a: [PolyTerm(1, 2), PolyTerm(2, 1)],
            ).raw,
          )
          .isValid,
      true,
    );
    expect(
      module
          .validateInput(
            const CasesInput(a: [PolyTerm(1, 2), PolyTerm(2, 2)]).raw,
          )
          .isValid,
      false,
    );
    final t = module.generateTrace(
      const CasesInput(a: [PolyTerm(.1, 0)], b: [PolyTerm(-.1, 0)]),
    );
    expect(t.frames.last.scene.auxTables.first.rows.first[1], '0');
  });
}
