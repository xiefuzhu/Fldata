import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch5_tree/bitree_traverse.dart';
import 'package:fldata/curriculum/ch5_tree/threaded_tree.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const build = ThreadedTreeModule(),
      walk = ThreadedTreeModule(traversalOnly: true);
  test(
    'child links survive threading; all empty fields lead to the inorder neighbour or head',
    () {
      for (final input in [
        ...build.presets.map((p) => p.input),
        const TreeInput(sequence: 'AA##A##'),
        const TreeInput(sequence: 'ABC####'),
      ]) {
        final tree = readPreorder(input.sequence), ordered = <BinaryNode>[];
        void visit(BinaryNode? n) {
          if (n == null) return;
          visit(n.left);
          ordered.add(n);
          visit(n.right);
        }

        visit(tree);
        final trace = build.generateTrace(input), last = trace.frames.last;
        final rows = {
          for (final r in last.scene.auxTables.single.rows) r.first: r,
        };
        expect(rows['Thrt'], [
          'Thrt',
          '0',
          tree?.id ?? 'Thrt',
          'Thrt',
          ordered.lastOrNull?.id ?? 'Thrt',
          '1',
        ]);
        for (final (i, n) in ordered.indexed) {
          expect(rows[n.id], [
            n.id,
            n.left == null ? '1' : '0',
            n.left?.id ?? (i == 0 ? 'Thrt' : ordered[i - 1].id),
            n.label,
            n.right?.id ??
                (i == ordered.length - 1 ? 'Thrt' : ordered[i + 1].id),
            n.right == null ? '1' : '0',
          ]);
        }
        expect(last.scene.edges.length, rows.length * 2);
        for (final e in last.scene.edges) {
          final row = rows[e.fromNodeId]!,
              right = e.fromPort == EdgePort.rchild;
          expect(e.toNodeId, row[right ? 4 : 2]);
          final thread = row[right ? 5 : 1] == '1';
          expect(
            e.style,
            thread ? EdgeStyle.dashedThread : EdgeStyle.solidArrow,
          );
          if (thread) expect(e.curvature, isNot(0));
        }
        expect(last.callStack, isEmpty);
        expect(
          trace.frames.first.scene.edges.every(
            (e) => e.style == EdgeStyle.solidArrow,
          ),
          isTrue,
        );
        for (final f in trace.frames.where(
          (f) => f.phaseTitle == '建立左线索' || f.phaseTitle == '建立前驱的右线索',
        )) {
          final p = f.inlineVars['p'], pre = f.inlineVars['pre'];
          final e = f.scene.edges.singleWhere(
            (e) => e.visualState == NodeVisualState.active,
          );
          expect((
            e.fromNodeId,
            e.toNodeId,
          ), f.phaseTitle == '建立左线索' ? (p, pre) : (pre, p));
        }
        final traversal = walk.generateTrace(input);
        expect(
          traversal.frames.first.scene.auxTables.single.rows,
          last.scene.auxTables.single.rows,
        );
        expect(
          traversal.frames.last.inlineVars['输出'],
          ordered.map((n) => n.label).join(),
        );
        expect(traversal.frames.last.inlineVars['p'], 'Thrt');
        expect(
          traversal.frames.every(
            (f) => f.callStack.isEmpty && f.metrics.maxCallDepth == 0,
          ),
          isTrue,
        );
        expect(
          traversal.frames
              .where((f) => f.phaseTitle.startsWith('访问 '))
              .map((f) => f.inlineVars['p']),
          ordered.map((n) => n.id),
        );
        for (final f in traversal.frames.where(
          (f) => f.phaseTitle == '沿右线索找后继',
        )) {
          final link = f.scene.edges.singleWhere(
            (e) => e.visualState == NodeVisualState.active,
          );
          expect(link.style, EdgeStyle.dashedThread);
          expect(link.toNodeId, f.inlineVars['p']);
        }
      }
    },
  );
  test('sample from the chapter accepts the textbook sequence', () {
    final f = walk.generateTrace(const TreeInput()).frames.last;
    expect(f.inlineVars['输出'], 'CBEGDFA');
    expect(f.metrics.writes, 7);
  });
}
