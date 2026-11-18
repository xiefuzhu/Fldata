import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch6_graph/graph_input.dart';
import 'package:fldata/curriculum/ch6_graph/six_degrees.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  test('社区全部 30 个起点的六跳层数与全源最短距离一致', () {
    final graph = communityNetwork,
        ids = graph.vertices.map((n) => n.id).toList(),
        n = ids.length;
    expect(n, 30);
    final d = List.generate(
      n,
      (i) => List.generate(n, (j) => i == j ? 0 : 1000),
    );
    for (final e in graph.arcs) {
      final i = ids.indexOf(e.tail), j = ids.indexOf(e.head);
      d[i][j] = d[j][i] = 1;
    }
    for (var k = 0; k < n; k++) {
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          final through = d[i][k] + d[k][j];
          if (through < d[i][j]) d[i][j] = through;
        }
      }
    }
    for (final (i, id) in ids.indexed) {
      final frames = SixDegreeModule(source: id).generateTrace(graph).frames;
      final last = frames.last,
          expected = {
            for (var j = 0; j < n; j++)
              if (d[i][j] <= 6) ids[j]: d[i][j],
          };
      expect(
        {
          for (final r in last.scene.auxTables.single.rows)
            r.first: int.parse(r[1]),
        },
        expected,
        reason: id,
      );
      expect(last.inlineVars['已达其他人'], '${expected.length - 1}');
      expect(
        last.inlineVars['占比'],
        '${(100 * (expected.length - 1) / n).toStringAsFixed(1)}%',
      );
      if (id == 'V1') {
        expect(last.inlineVars['占比'], '96.7%');
        expect(
          [
            for (var k = 1; k <= 6; k++)
              expected.values.where((v) => v == k).length,
          ],
          [3, 8, 6, 5, 4, 3],
        );
        for (final frame in frames) {
          final rows = frame.scene.auxTables.single.rows;
          expect(rows.map((r) => r.first).toSet().length, rows.length);
          expect(frame.inlineVars['已达其他人'], '${rows.length - 1}');
        }
      }
    }
  });

  test('直链的第七跳、印刷循环七次出队及整型输出', () {
    var g = GraphInputModel.empty(GraphKind.udg);
    for (var i = 0; i < 9; i++) {
      g = g.addVertex(const Vec2(x: .5, y: .5));
    }
    for (var i = 1; i < 9; i++) {
      g = g.connect('V$i', 'V${i + 1}');
    }
    final six = const SixDegreeModule().generateTrace(g).frames.last;
    expect(six.inlineVars['队列'], 'V7');
    expect(six.inlineVars['已达其他人'], '6');
    expect(six.inlineVars['占比'], '66.7%');
    expect(six.scene.nodes[7].groupTag, isNull);
    final book = const SixDegreeModule(
      rule: SixDegreeRule.printed,
    ).generateTrace(g).frames.last;
    expect(book.inlineVars['出队次数'], '7');
    expect(book.inlineVars['队列'], 'V8');
    expect(book.inlineVars['最远层'], '7');
    expect(book.inlineVars['整型输出'], '77%');
    final branch = const SixDegreeModule(
      rule: SixDegreeRule.printed,
    ).generateTrace(communityNetwork).frames.last;
    expect(branch.inlineVars['出队次数'], '7');
    expect(branch.inlineVars['最远层'], '3');
    expect(branch.inlineVars['已达其他人'], '13');
    expect(branch.inlineVars['整型输出'], '43%');
  });

  test('孤立点、空图和有向自环保持源点与分母口径', () {
    final empty = GraphInputModel.empty(GraphKind.dg);
    expect(
      const SixDegreeModule().generateTrace(empty).frames.last.inlineVars['占比'],
      '—',
    );
    final isolated = empty.addVertex(const Vec2(x: 0, y: 0));
    expect(
      const SixDegreeModule()
          .generateTrace(isolated)
          .frames
          .last
          .inlineVars['占比'],
      '0.0%',
    );
    final g = isolated
        .addVertex(const Vec2(x: 1, y: 1))
        .connect('V1', 'V1')
        .connect('V1', 'V2');
    for (final rule in SixDegreeRule.values) {
      expect(
        SixDegreeModule(
          rule: rule,
        ).generateTrace(g).frames.last.inlineVars['已达其他人'],
        '1',
      );
      expect(
        SixDegreeModule(
          source: 'V2',
          rule: rule,
        ).generateTrace(g).frames.last.inlineVars['已达其他人'],
        '0',
      );
    }
  });
}
