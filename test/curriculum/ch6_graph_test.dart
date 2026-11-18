import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/quiz_question.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch6_graph/dijkstra.dart';
import 'package:fldata/curriculum/ch6_graph/floyd.dart';
import 'package:fldata/curriculum/ch6_graph/topo_critical.dart';
import 'package:fldata/curriculum/ch6_graph/minimum_spanning_tree.dart';
import 'package:fldata/curriculum/ch6_graph/graph_input.dart';
import 'package:fldata/curriculum/ch6_graph/graph_storage_module.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  for (final preset in graphPresets) {
    test(
      '${preset.id}: matrix and incidence chains agree at every input prefix',
      () {
        final g = preset.input;
        final frames = const GraphStorageModule().generateTrace(g).frames;
        for (final f in frames) {
          final s = GraphStorage(g, int.parse(f.inlineVars['已录入']!));
          expect(f.scene.edges.map((e) => e.id), s.arcs.map((e) => e.id));
          expect(s.links.length, s.arcs.length);
          for (final v in g.vertices) {
            final out = s.arcs
                .where((e) => e.tail == v.id || !s.directed && e.head == v.id)
                .toList()
                .reversed;
            final ins = s.arcs.where((e) => e.head == v.id).toList().reversed;
            List<String> walk(String? id, {bool incoming = false}) {
              final visited = <String>[];
              while (id != null) {
                expect(visited, isNot(contains(id)));
                visited.add(id);
                final edge = s.arcs.singleWhere((e) => e.id == id);
                final link = s.links[id]!;
                id = incoming || !s.directed && edge.tail != v.id
                    ? link.right
                    : link.left;
              }
              return visited;
            }

            expect(walk(s.first[v.id]), out.map((e) => e.id));
            expect(s.chain(v.id).map((n) => n.arc.id), out.map((e) => e.id));
            if (s.directed) {
              expect(
                walk(s.firstIn[v.id], incoming: true),
                ins.map((e) => e.id),
              );
              expect(
                s.chain(v.id, reverse: true).map((n) => n.arc.id),
                ins.map((e) => e.id),
              );
            }
            for (final w in g.vertices) {
              final cell = s.cells[(v.id, w.id)];
              expect(
                cell?.id,
                s
                    .chain(v.id)
                    .where((n) => n.vertex == w.id)
                    .firstOrNull
                    ?.arc
                    .id,
              );
            }
          }
        }
      },
    );
  }
  test(
    'textbook head insertion, weighted diagonal, loops and stable IDs after deletion',
    () {
      final g = graphPresets.first.input;
      expect(GraphStorage(g, g.arcs.length).chain('V1').map((n) => n.vertex), [
        'V4',
        'V2',
      ]);
      final net = graphPresets.firstWhere((p) => p.id == 'n').input;
      final n = GraphStorage(net, 10);
      expect(n.cells[('V1', 'V1')], isNull);
      expect(n.cells[('V6', 'V1')]?.weight, 3);
      expect(n.cells[('V1', 'V6')], isNull);
      const pin = Vec2(x: .31, y: .54);
      final edited = net
          .removeVertex('V2')
          .pin('V1', pin)
          .addVertex(pin)
          .connect('V1', 'V1', weight: 0);
      final s = GraphStorage(edited, edited.arcs.length);
      expect(s.cells[('V1', 'V1')]?.weight, 0);
      expect(edited.vertices.last.id, 'V7');
      expect(edited.vertices.first.pinned, true);
      expect(edited.vertices.first.point, pin);
      expect(edited.arcs.any((e) => e.tail == 'V2' || e.head == 'V2'), false);
      expect(
        () => edited.connect('V3', 'V7', weight: 32767),
        throwsFormatException,
      );
      final loop = g.connect('V1', 'V1');
      final undirected = GraphStorage(loop, loop.arcs.length);
      expect(undirected.chain('V1').where((e) => e.vertex == 'V1').length, 2);
      expect(
        undirected.links[loop.arcs.last.id]!.left,
        undirected.links[loop.arcs.last.id]!.right,
      );
      expect(loop.removeEdge(loop.arcs.last.id).arcs, g.arcs);
    },
  );
  test('表 6.1 的每一轮 closedge、割边与选边顺序', () {
    final graph = mstPresets.first.input;
    final frames = const MinimumSpanningTreeModule()
        .generateTrace(graph)
        .frames;
    final minima = frames
        .where((f) => f.phaseTitle.startsWith('最小跨割边'))
        .toList();
    expect(minima.map((f) => f.phaseTitle.split(' ').skip(1).join(' ')), [
      'V1 — V3',
      'V3 — V6',
      'V6 — V4',
      'V3 — V2',
      'V2 — V5',
    ]);
    expect(
      [
        for (final f in [...minima, frames.last])
          f.scene.auxTables.first.rows.map((r) => r[2]).join(','),
      ],
      [
        '0,6,1,5,∞,∞',
        '0,5,0,5,6,4',
        '0,5,0,2,6,0',
        '0,5,0,0,6,0',
        '0,0,0,0,3,0',
        '0,0,0,0,0,0',
      ],
    );
    for (final f in frames) {
      final u = f.scene.nodes
          .where((n) => n.groupTag == 'U')
          .map((n) => n.id)
          .toSet();
      final cut = graph.arcs
          .where((e) => u.contains(e.tail) != u.contains(e.head))
          .map((e) => e.id)
          .toSet();
      expect(
        f.scene.edges
            .where((e) => e.visualState == NodeVisualState.comparing)
            .map((e) => e.id)
            .toSet(),
        cut,
      );
    }
    final tied = frames.singleWhere((f) => f.phaseTitle == '检查 V3 — V4');
    expect(tied.inlineVars['比较'], '5 < 5');
    expect(minima[1].scene.auxTables.first.rows[3][1], 'V1');
  });

  test('Kruskal 逐边比较，拒绝同分量边并按 Vexset 合并', () {
    final graph = mstPresets.first.input;
    final frames = const MinimumSpanningTreeModule(
      method: MstMethod.kruskal,
    ).generateTrace(graph).frames;
    final tried = frames.where((f) => f.phaseTitle.startsWith('试探')).toList();
    expect(
      tried.map(
        (f) =>
            graph.arcs.singleWhere((e) => e.id == f.inlineVars['当前边']).weight,
      ),
      [1, 2, 3, 4, 5, 5, 5, 6, 6, 6],
    );
    for (final f in tried) {
      final next = frames[f.stepIndex + 1], id = f.inlineVars['当前边'];
      final a = f.inlineVars['vs1'], b = f.inlineVars['vs2'];
      final old = f.scene.auxTables.last.rows.map((r) => r[1]).toList();
      final result = next.scene.auxTables.last.rows.map((r) => r[1]).toList();
      expect(result, [for (final c in old) c == b ? a : c]);
      expect(
        next.scene.auxTables.first.rows.singleWhere((r) => r.first == id).last,
        a == b ? '舍弃' : '采用',
      );
      expect(
        next.scene.edges.singleWhere((e) => e.id == id).visualState,
        a == b ? NodeVisualState.error : NodeVisualState.sorted,
      );
    }
    expect(
      frames.last.scene.auxTables.first.rows
          .where((r) => r.last == '舍弃')
          .length,
      5,
    );
  });

  test('两法同权，非连通时返回森林；零权、负权、自环与空网', () {
    final g = mstPresets.first.input;
    for (final vertex in g.vertices) {
      expect(
        MinimumSpanningTreeModule(
          source: vertex.id,
        ).generateTrace(g).frames.last.inlineVars['权值和'],
        '15',
      );
    }
    for (final method in MstMethod.values) {
      final module = MinimumSpanningTreeModule(method: method);
      final connected = module.generateTrace(g).frames.last;
      expect(connected.inlineVars['已选边'], '5');
      expect(connected.inlineVars['权值和'], '15');
      final forest = module.generateTrace(mstPresets.last.input).frames.last;
      expect(forest.inlineVars['已选边'], '6');
      expect(forest.inlineVars['权值和'], '18');
      expect(forest.inlineVars['分量数'], '2');
      expect(forest.explanation, contains('无法生成单一生成树'));
      final empty = GraphInputModel.empty(GraphKind.udn);
      expect(module.generateTrace(empty).frames.last.phaseTitle, '空网');
      const point = Vec2(x: .5, y: .5);
      final signed = empty
          .addVertex(point)
          .addVertex(point)
          .addVertex(point)
          .addVertex(point)
          .connect('V1', 'V1', weight: -9)
          .connect('V1', 'V2', weight: 0)
          .connect('V2', 'V3', weight: -3)
          .connect('V1', 'V3', weight: 2);
      final last = module.generateTrace(signed).frames.last;
      expect(last.inlineVars['权值和'], '-3');
      expect(last.inlineVars['已选边'], '2');
      expect(last.inlineVars['分量数'], '2');
    }
  });
  test('表 6.3 初值、表 6.4 五轮选点和每格距离/前驱', () {
    final g = shortestPathPresets.first.input,
        frames = const DijkstraModule().generateTrace(g).frames;
    final initial = frames.first.scene.auxTables.first.rows;
    expect(initial.map((r) => r[2]), ['0', '∞', '10', '∞', '30', '100']);
    expect(initial.map((r) => r[3]), ['-1', '-1', '0', '-1', '0', '0']);
    final rounds = frames.last.scene.auxTables.last.rows;
    expect(rounds.map((r) => r[1]), ['v2', 'v4', 'v3', 'v5', '无']);
    expect(rounds.map((r) => r[2]), ['10', '30', '50', '60', '∞']);
    expect(
      [for (final row in rounds) row.skip(4).toList()],
      [
        ['0, -1', '∞, -1', '10, 0', '∞, -1', '30, 0', '100, 0'],
        ['0, -1', '∞, -1', '10, 0', '60, 2', '30, 0', '100, 0'],
        ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '90, 4'],
        ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '60, 3'],
        ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '60, 3'],
      ],
    );
    final last = frames.last.scene.auxTables.first.rows;
    expect(last.map((r) => r[2]), ['0', '∞', '10', '50', '30', '60']);
    expect(last[1][1], 'false');
    final before = frames.firstWhere((f) => f.phaseTitle == '检查 v3 → v5'),
        after = frames[before.stepIndex + 1];
    expect(before.scene.auxTables.first.rows.last.sublist(2), ['90', '4']);
    expect(after.scene.auxTables.first.rows.last.sublist(2), ['60', '3']);
    expect(before.inlineVars['松弛算式'], contains('= 60 < 90'));
    final prefix = before.scene.edges
        .where((e) => e.visualState == NodeVisualState.active)
        .map((e) => e.id)
        .toSet();
    expect(prefix, {g.edge('v0', 'v4')!.id, g.edge('v4', 'v3')!.id});
    expect(
      before.scene.edges
          .singleWhere((e) => e.visualState == NodeVisualState.comparing)
          .id,
      g.edge('v3', 'v5')!.id,
    );
    expect(before.scene.auxTables.last.rows, after.scene.auxTables.last.rows);
  });

  test('改源、零权边、等长候选与大于无边哨兵的有限距离', () {
    const p = Vec2(x: .5, y: .5);
    final empty = GraphInputModel.empty(
      GraphKind.dn,
      vertexPrefix: 'v',
      firstVertex: 0,
    );
    expect(
      const DijkstraModule().generateTrace(empty).frames.last.phaseTitle,
      '空图',
    );
    final g = empty
        .addVertex(p)
        .addVertex(p)
        .addVertex(p)
        .addVertex(p)
        .addVertex(p)
        .connect('v0', 'v1', weight: 0)
        .connect('v0', 'v2', weight: 20000)
        .connect('v1', 'v2', weight: 20000)
        .connect('v2', 'v3', weight: 20000)
        .connect('v0', 'v0', weight: 7);
    final rows = const DijkstraModule()
        .generateTrace(g)
        .frames
        .last
        .scene
        .auxTables
        .first
        .rows;
    expect(rows.map((r) => r[2]), ['0', '0', '20000', '40000', '∞']);
    expect(rows.map((r) => r[3]), ['-1', '0', '0', '2', '-1']);
    final edited = g.removeVertex('v0').pin('v1', p).addVertex(p);
    expect(edited.vertices.last.id, 'v5');
    final shifted = const DijkstraModule(
      source: 'v1',
    ).generateTrace(edited).frames.last.scene.auxTables.first.rows;
    expect(shifted[2], ['v3', 'true', '40000', '1']);
    final invalid = g.connect('v4', 'v0', weight: -1);
    final err = const DijkstraModule().generateTrace(invalid).frames.single;
    expect(err.isErrorState, true);
    expect(err.scene.edges.last.visualState, NodeVisualState.error);
    expect(err.scene.auxTables.last.rows, isEmpty);
  });
  test('表 6.5 · 初始与四轮完整距离和直接前驱矩阵', () {
    final graph = shortestPathPresets.singleWhere((p) => p.id == 'g7').input;
    final frames = const FloydModule().generateTrace(graph).frames;
    final stages = frames
        .where((f) => ['初始化', '轮末'].contains(f.inlineVars['阶段']))
        .toList();
    String grid(TraceFrame f, int index) =>
        f.scene.auxTables[index].rows.map((r) => r.skip(1).join(' ')).join('/');
    expect(stages.map((f) => grid(f, 0)), [
      '0 1 ∞ 4/∞ 0 9 2/3 5 0 8/∞ ∞ 6 0',
      '0 1 ∞ 4/∞ 0 9 2/3 4 0 7/∞ ∞ 6 0',
      '0 1 10 3/∞ 0 9 2/3 4 0 6/∞ ∞ 6 0',
      '0 1 10 3/12 0 9 2/3 4 0 6/9 10 6 0',
      '0 1 9 3/11 0 8 2/3 4 0 6/9 10 6 0',
    ]);
    expect(stages.map((f) => grid(f, 1)), [
      '-1 0 -1 0/-1 -1 1 1/2 2 -1 2/-1 -1 3 -1',
      '-1 0 -1 0/-1 -1 1 1/2 0 -1 0/-1 -1 3 -1',
      '-1 0 1 1/-1 -1 1 1/2 0 -1 1/-1 -1 3 -1',
      '-1 0 1 1/2 -1 1 1/2 0 -1 1/2 0 3 -1',
      '-1 0 3 1/2 -1 3 1/2 0 -1 1/2 0 3 -1',
    ]);
    expect(frames.last.metrics.comparisons, 64);
  });

  test('每个非负预设的全部有序点对等于逐源 Dijkstra；还原路径的真实边权之和一致', () {
    for (final p in shortestPathPresets) {
      final g = p.input,
          last = const FloydModule().generateTrace(g).frames.last;
      for (final (i, source) in g.vertices.indexed) {
        final single = DijkstraModule(
          source: source.id,
        ).generateTrace(g).frames.last.scene.auxTables.first;
        final pred = last.scene.auxTables.last.rows[i]
            .skip(1)
            .map(int.parse)
            .toList();
        for (final (j, dest) in g.vertices.indexed) {
          final distance = last.scene.auxTables.first.rows[i][j + 1];
          expect(
            distance,
            single.rows[j][2],
            reason: '${p.id} ${source.id} → ${dest.id}',
          );
          final route = floydRoute(i, j, pred);
          if (distance == '∞') {
            expect(route, isEmpty);
            continue;
          }
          expect(route.first, i);
          expect(route.last, j);
          expect(route.toSet().length, route.length);
          var cost = 0;
          for (var a = 1; a < route.length; a++) {
            cost += g
                .edge(g.vertices[route[a - 1]].id, g.vertices[route[a]].id)!
                .weight;
          }
          expect(cost, int.parse(distance));
        }
      }
    }
  });

  test('Floyd 区分负边、负环、空图和超过 32767 的有限路径', () {
    const p = Vec2(x: .5, y: .5);
    final empty = GraphInputModel.empty(GraphKind.dn);
    expect(
      const FloydModule().generateTrace(empty).frames.last.phaseTitle,
      '空图',
    );
    final g = empty
        .addVertex(p)
        .addVertex(p)
        .addVertex(p)
        .addVertex(p)
        .connect('V1', 'V2', weight: 20000)
        .connect('V2', 'V3', weight: 20000)
        .connect('V3', 'V4', weight: -3);
    final last = const FloydModule().generateTrace(g).frames.last;
    expect(last.scene.auxTables.first.rows.first.skip(1), [
      '0',
      '20000',
      '40000',
      '39997',
    ]);
    expect(last.scene.auxTables.first.rows.last[1], '∞');
    for (final bad in [
      g.connect('V4', 'V3', weight: 2),
      g.connect('V1', 'V1', weight: -1),
    ]) {
      final err = const FloydModule().generateTrace(bad).frames.last;
      expect(err.isErrorState, true);
      expect(err.inlineVars['阶段'], '负环');
      expect(
        err.scene.edges.any((e) => e.visualState == NodeVisualState.error),
        true,
      );
    }
  });

  test('图 6.27 的零入度栈、逐弧删除和输出次序', () {
    final g = topoPresets.first.input;
    final frames = const TopoCriticalModule().generateTrace(g).frames;
    expect(frames.first.inlineVars['S'], 'v1 → v6');
    expect(frames.last.inlineVars['topo'], 'v6 → v1 → v4 → v3 → v2 → v5');
    final seen = <String>{};
    for (final (index, f) in frames.indexed) {
      if (f.inlineVars['阶段'] != '减入度') continue;
      final id = f.inlineVars['弧']!,
          arc = g.arcs.singleWhere((e) => e.id == id);
      expect(seen.add(id), true);
      final before = frames[index - 1];
      String count(TraceFrame f) => f.scene.auxTables.single.rows.singleWhere(
        (r) => r.first == arc.head,
      )[1];
      expect(int.parse(count(before)) - int.parse(count(f)), 1);
      expect(before.scene.edges.singleWhere((e) => e.id == id).opacity, 1);
      expect(
        f.scene.edges.where((e) => e.opacity == 0).map((e) => e.id),
        unorderedEquals(seen),
      );
      if (count(f) == '0') {
        expect(frames[index + 1].inlineVars['S']!.split(' → ').last, arc.head);
      }
    }
    expect(seen.length, g.arcs.length);
  });
  test('含三元环时保留阻塞顶点，只标红闭合环上的弧并终止关键路径', () {
    for (final method in TopoMethod.values) {
      final end = TopoCriticalModule(
        method,
      ).generateTrace(topoPresets.last.input).frames.last;
      expect(end.isErrorState, true);
      expect(end.phaseTitle, '拓扑排序失败：图中存在有向环！');
      expect(end.inlineVars['topo'], 'v6');
      expect(
        end.scene.nodes
            .where((n) => n.visualState == NodeVisualState.error)
            .map((n) => n.id),
        unorderedEquals(['v1', 'v2', 'v3', 'v4', 'v5']),
      );
      expect(
        end.scene.edges
            .where((e) => e.visualState == NodeVisualState.error)
            .map((e) => (e.fromNodeId, e.toNodeId)),
        unorderedEquals([('v1', 'v3'), ('v3', 'v2'), ('v2', 'v1')]),
      );
      expect(end.inlineVars.containsKey('工期'), false);
    }
  });
  test('例 6.4 表 6.7 的九个事件和十一项活动，图 6.29 两条并行关键路径', () {
    final g = topoPresets[1].input;
    final frames = const TopoCriticalModule(
      TopoMethod.critical,
    ).generateTrace(g).frames;
    final end = frames.last;
    expect(end.inlineVars['工期'], '18');
    final events = end.scene.auxTables.first.rows;
    expect(events.map((r) => int.parse(r[1])), [0, 6, 4, 5, 7, 7, 16, 14, 18]);
    expect(events.map((r) => int.parse(r[2])), [0, 6, 6, 8, 7, 10, 16, 14, 18]);
    final activities = end.scene.auxTables.last;
    expect(activities.rows.map((r) => int.parse(r[3])), [
      0,
      0,
      0,
      6,
      4,
      5,
      7,
      7,
      7,
      16,
      14,
    ]);
    expect(activities.rows.map((r) => int.parse(r[4])), [
      0,
      2,
      3,
      6,
      6,
      8,
      7,
      7,
      10,
      16,
      14,
    ]);
    expect(activities.rows.map((r) => int.parse(r[5])), [
      0,
      2,
      3,
      0,
      2,
      3,
      0,
      0,
      3,
      0,
      0,
    ]);
    expect(activities.highlightedRows, {0, 3, 6, 7, 9, 10});
    expect(
      end.scene.edges
          .where((e) => e.visualState == NodeVisualState.sorted)
          .map((e) => (e.fromNodeId, e.toNodeId)),
      unorderedEquals([
        ('v0', 'v1'),
        ('v1', 'v4'),
        ('v4', 'v6'),
        ('v4', 'v7'),
        ('v6', 'v8'),
        ('v7', 'v8'),
      ]),
    );
    expect(
      frames
          .where((f) => f.inlineVars['阶段'] == '活动余量')
          .map((f) => f.scene.auxTables.last.rows.length),
      List.generate(11, (i) => i + 1),
    );
    final zero = g.connect('v0', 'v8', weight: 0);
    final neg = g.connect('v0', 'v8', weight: -1);
    final module = const TopoCriticalModule(TopoMethod.critical);
    expect(module.generateTrace(neg).frames.last.isErrorState, true);
    expect(
      module
          .generateTrace(zero)
          .frames
          .last
          .scene
          .auxTables
          .last
          .rows
          .last
          .last,
      '18',
    );
    final multipleSinks = g.removeEdge('e10').removeEdge('e11');
    expect(
      module.generateTrace(multipleSinks).frames.last.inlineVars['工期'],
      '16',
    );
  });

  test('第六章 25 个原题题号、双空顺序与填表结构', () {
    final seeds = quizQuestions
        .where((q) => q.chapterId == ChapterId.ch6)
        .toList();
    final expected = [
      for (final (section, count) in [(1, 15), (2, 5), (3, 5)])
        for (var i = 1; i <= count; i++)
          'textbook_ch6_${section}_${i.toString().padLeft(2, '0')}',
    ];
    expect(seeds.map((q) => q.id), expected);
    for (final q in seeds) {
      final parts = q.id.split('_'),
          section = int.parse(parts[2]),
          number = int.parse(parts[3]);
      final page = switch (section) {
        1 => number <= 12 ? 187 : 188,
        2 => number <= 2 ? 188 : 189,
        _ => 190,
      };
      expect(
        q.sourceLabel,
        contains('书页$page（PDF第${page + 8}页），第$section题（$number）'),
      );
      expect(questionById(q.id), same(q));
    }
    expect(
      seeds.whereType<ChoiceQuestion>().map((q) => q.correctIndices.single),
      [2, 1, 1, 1, 2, 1, 0, 1, 0, 0, 3, 2, 2, 3, 1],
    );
    expect((seeds[13] as ChoiceQuestion).orderedAnswers, [3, 3]);
    for (final q in seeds.whereType<TraceTableQuestion>()) {
      expect(q.answerRows.length, q.rowLabels.length);
      expect(q.answerRows.every((r) => r.length == q.columns.length), true);
    }
  });
  test('习题 2(4) 表 6.9 全六轮距离、路径和终点集与 Dijkstra 一致', () {
    var graph = GraphInputModel.empty(
      GraphKind.dn,
      firstVertex: 0,
      vertexPrefix: '',
    );
    const letters = 'abcdefg';
    for (var i = 0; i < letters.length; i++) {
      graph = graph.addVertex(const Vec2(x: .5, y: .5));
    }
    for (final (u, v, w) in [
      ('a', 'b', 15),
      ('a', 'c', 2),
      ('a', 'd', 12),
      ('b', 'e', 6),
      ('c', 'e', 8),
      ('c', 'f', 4),
      ('f', 'd', 5),
      ('f', 'g', 10),
      ('d', 'g', 3),
      ('e', 'g', 9),
      ('g', 'b', 4),
    ]) {
      graph = graph.connect(
        '${letters.indexOf(u)}',
        '${letters.indexOf(v)}',
        weight: w,
      );
    }
    final answer =
        (questionById('textbook_ch6_2_04')! as TraceTableQuestion).answerRows;
    final frames = const DijkstraModule()
        .generateTrace(graph)
        .frames
        .where((f) => f.phaseTitle.contains('轮 · 确定'))
        .toList();
    expect(frames.length, 6);
    var settled = 'a';
    for (final (i, f) in frames.indexed) {
      final rows = f.scene.auxTables.first.rows,
          dist = [for (final r in rows) int.tryParse(r[2])],
          pred = [for (final r in rows) int.parse(r[3])];
      for (var v = 1; v < letters.length; v++) {
        final route = dijkstraRoute(
          v,
          pred,
          dist,
        ).map((p) => letters[p]).join('→');
        expect(answer[2 * (v - 1)][i], rows[v][2]);
        expect(answer[2 * (v - 1) + 1][i], route.isEmpty ? '—' : route);
      }
      settled += letters[int.parse(f.inlineVars['v']!)];
      expect(answer.last[i], settled);
    }
  });
  test('习题 2(5) 图 6.36 每个事件、活动及关键路径集合与回放一致', () {
    var graph = GraphInputModel.empty(GraphKind.dn, vertexPrefix: '');
    for (var i = 0; i < 6; i++) {
      graph = graph.addVertex(const Vec2(x: .5, y: .5));
    }
    for (final (u, v, w) in [
      (1, 2, 2),
      (1, 3, 15),
      (3, 2, 4),
      (2, 4, 10),
      (2, 5, 19),
      (3, 5, 11),
      (4, 6, 6),
      (5, 6, 5),
    ]) {
      graph = graph.connect('$u', '$v', weight: w);
    }
    final answer =
        (questionById('textbook_ch6_2_05')! as TraceTableQuestion).answerRows;
    final f = const TopoCriticalModule(
      TopoMethod.critical,
    ).generateTrace(graph).frames.last;
    expect(answer.first.first, f.inlineVars['工期']);
    for (final (i, row) in f.scene.auxTables.first.rows.indexed) {
      expect(answer[i + 1].take(2), row.skip(1));
    }
    for (final (i, row) in f.scene.auxTables.last.rows.indexed) {
      expect(answer[i + 7], [row[3], row[4], row[5] == '0' ? '是' : '否']);
    }
  });
}
