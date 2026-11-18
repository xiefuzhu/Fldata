import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch6_graph/graph_input.dart';
import 'package:fldata/curriculum/ch6_graph/graph_traversal.dart';
import 'package:fldata/models/trace_model.dart';

List<List<String>> records(TraceFrame frame) =>
    frame.scene.auxTables.singleWhere((t) => t.id == 'forest').rows;

void main() {
  for (final mode in TraversalMode.values) {
    test('图 6.17～6.18 · ${mode.label} 访问、扫描与生成树', () {
      final frames = GraphTraversalModule(
            mode: mode,
          ).generateTrace(textbookG4).frames,
          last = frames.last;
      final bfs = mode == TraversalMode.breadth,
          matrix = mode == TraversalMode.matrix;
      expect(
        records(last).map((r) => r[0]),
        (bfs ? [1, 2, 3, 4, 5, 6, 7, 8] : [1, 2, 4, 8, 5, 3, 6, 7]).map(
          (i) => 'V$i',
        ),
      );
      expect(
        {for (final r in records(last)) r[0]: r[1]},
        {
          'V1': '∅',
          'V2': 'V1',
          'V3': 'V1',
          'V4': 'V2',
          'V5': bfs ? 'V2' : 'V8',
          'V6': 'V3',
          'V7': bfs ? 'V3' : 'V6',
          'V8': 'V4',
        },
      );
      expect(last.metrics.reads, matrix ? 64 : 18);
      expect(
        last.scene.edges
            .where((e) => e.visualState == NodeVisualState.sorted)
            .length,
        7,
      );
      expect(
        last.scene.edges
            .where((e) => e.visualState == NodeVisualState.sentinel)
            .length,
        2,
      );
      final scans = frames.where((f) => f.activeLines.values.first.single == 5);
      expect(scans.length, last.metrics.reads);
      for (final f in scans) {
        final table = f.scene.auxTables.first,
            cursor = table.highlightedRows.single;
        expect(table.rows[cursor][0], f.inlineVars['w']);
        if (!matrix) expect(table.rows[cursor][1], f.inlineVars['p']);
      }
      if (bfs) {
        expect(
          frames
              .where((f) => f.phaseTitle.startsWith('出队'))
              .map((f) => f.inlineVars['v']),
          records(last).map((r) => r[0]),
        );
        final discovery = frames.singleWhere(
          (f) => f.phaseTitle == '树边 V2 → V5',
        );
        expect(discovery.inlineVars['队列'], 'V3 → V4 → V5');
        expect(records(discovery).last, ['V5', 'V2', '2']);
      } else {
        expect(
          frames.map((f) => f.callStack.length).reduce((a, b) => a > b ? a : b),
          5,
        );
        expect(
          frames
              .singleWhere((f) => f.phaseTitle == '从 V5 返回')
              .callStack
              .last
              .arguments['v'],
          'V8',
        );
        expect(last.callStack, isEmpty);
      }
    });
  }
  test('三棵树、定制起点、孤立点与空图', () {
    final g = traversalPresets.singleWhere((p) => p.id == 'forest').input;
    for (final mode in TraversalMode.values) {
      final module = GraphTraversalModule(mode: mode, source: 'V3');
      final f = module.generateTrace(g).frames.last;
      expect(f.inlineVars['森林根'], 'V3、V1、V9');
      expect(records(f).where((r) => r[1] != '∅').length, 6);
      expect(records(f).last, ['V9', '∅', '0']);
      expect(
        records(
          module
              .generateTrace(GraphInputModel.empty(GraphKind.udg))
              .frames
              .last,
        ),
        isEmpty,
      );
    }
  });
  test('有向零权弧、自环，矩阵下标顺序与链首顺序独立', () {
    const point = Vec2(x: .3, y: .4);
    final g = GraphInputModel.empty(GraphKind.dn)
        .addVertex(point)
        .addVertex(point)
        .addVertex(point)
        .connect('V1', 'V2', weight: 0)
        .connect('V1', 'V3', weight: 2)
        .connect('V1', 'V1', weight: 3);
    for (final mode in TraversalMode.values) {
      final f = GraphTraversalModule(mode: mode).generateTrace(g).frames.last;
      expect(
        records(f).map((r) => r.first),
        mode == TraversalMode.matrix ? ['V1', 'V2', 'V3'] : ['V1', 'V3', 'V2'],
      );
      expect(f.metrics.reads, mode == TraversalMode.matrix ? 9 : 3);
      expect(f.scene.edges.last.visualState, NodeVisualState.sentinel);
      final reverse = GraphTraversalModule(
        mode: mode,
        source: 'V2',
      ).generateTrace(g).frames.last;
      expect(reverse.inlineVars['森林根'], 'V2、V1');
    }
  });
}
