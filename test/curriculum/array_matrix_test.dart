import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/array_matrix.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = ArrayMatrixModule();
  test(
    'enumerated 3D storage order agrees with scanned and connected cells',
    () {
      for (final columns in [false, true]) {
        final a = MatrixInput(
          rows: 2,
          cols: 3,
          layers: 2,
          columnMajor: columns,
          base: 512,
          bytes: 8,
        );
        final order = columns
            ? [
                for (var c = 0; c < 3; c++)
                  for (var r = 0; r < 2; r++)
                    for (var z = 0; z < 2; z++) (z, r, c),
              ]
            : [
                for (var z = 0; z < 2; z++)
                  for (var r = 0; r < 2; r++)
                    for (var c = 0; c < 3; c++) (z, r, c),
              ];
        for (var idx = 0; idx < order.length; idx++) {
          final (z, r, c) = order[idx];
          final frames = module.generateTrace(a.select(z, r, c)).frames;
          final visited = frames
              .take(frames.length - 2)
              .expand(
                (f) => f.scene.nodes.where(
                  (n) =>
                      n.id.startsWith('cell-') &&
                      n.visualState == NodeVisualState.moving,
                ),
              )
              .map((n) => n.id);
          expect(
            visited,
            order.take(idx).map((p) => 'cell-${p.$1}-${p.$2}-${p.$3}'),
          );
          final last = frames.last;
          expect(last.inlineVars['LOC'], '${512 + idx * 8}');
          final edge = last.scene.edges.single;
          expect(edge.toNodeId, 'slot-$idx');
          final node = last.scene.nodes.firstWhere(
            (n) => n.id == edge.toNodeId,
          );
          expect(
            node.label,
            last.scene.nodes.firstWhere((n) => n.id == edge.fromNodeId).label,
          );
        }
      }
    },
  );
  test(
    'compressed cells map to exactly the stored triangle, band or shared constant',
    () {
      for (final mode in [
        MatrixMode.symmetric,
        MatrixMode.lower,
        MatrixMode.band,
      ]) {
        for (var n = 1; n <= 5; n++) {
          final stored = [
            for (var r = 0; r < n; r++)
              for (var c = 0; c < n; c++)
                if (mode == MatrixMode.band ? (r - c).abs() <= 1 : c <= r)
                  (r, c),
          ];
          for (var r = 0; r < n; r++) {
            for (var c = 0; c < n; c++) {
              final a = MatrixInput(
                mode: mode,
                rows: n,
                cols: n,
                i: r,
                j: c,
                constant: 42,
              );
              final mirrored = mode == MatrixMode.symmetric && c > r;
              final index = stored.indexOf(mirrored ? (c, r) : (r, c));
              final frame = module.generateTrace(a).frames.last;
              expect(
                frame.inlineVars['k'],
                '${index < 0 ? stored.length : index}',
              );
              expect(frame.scene.edges.any((e) => e.id == 'mirror'), mirrored);
              if (index < 0) {
                expect(
                  frame.scene.nodes.last.label,
                  mode == MatrixMode.lower ? '42' : '0',
                );
              }
            }
          }
        }
      }
    },
  );
  test(
    'count, start, cursor and stable output handle empty columns and empty matrices',
    () {
      for (final triples in [
        <Triple>[],
        [(1, 2, 6), (1, 4, 3), (2, 2, -9), (3, 4, 8)],
      ]) {
        final a = MatrixInput(mode: MatrixMode.transpose, triples: triples);
        final frames = module.generateTrace(a).frames;
        final last = frames.last;
        final sorted = [
          for (var col = 1; col <= 4; col++)
            for (final t in triples)
              if (t.$2 == col) '($col,${t.$1},${t.$3})',
        ];
        expect(last.scene.auxTables.last.rows.map((r) => r.last), sorted);
        var pos = 1;
        for (final row in last.scene.auxTables.first.rows) {
          final count = triples.where((t) => '${t.$2}' == row[0]).length;
          expect(row.sublist(1), ['$count', '$pos', '${pos + count}']);
          pos += count;
        }
        expect(last.metrics.reads, 2 * triples.length);
        expect(last.metrics.writes, triples.length);
        expect(
          frames.first.scene.auxTables.last.rows.every((r) => r.last == '·'),
          isTrue,
        );
      }
    },
  );
  test(
    'editor rejects duplicate or unsorted triples and accepts a hex base',
    () {
      expect(
        module.validateInput('transpose|3 4 1 0x1000 4 0|1,3,1;1,3,2').isValid,
        isFalse,
      );
      expect(
        module.validateInput('transpose|3 4 1 0x1000 4 0|2,1,1;1,3,2').isValid,
        isFalse,
      );
      expect(
        module.validateInput('address|3 4 2 0x1000 4 0|').value!.base,
        4096,
      );
    },
  );
}
