import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';

part 'mst_source.dart';

enum MstMethod {
  prim('Prim'),
  kruskal('Kruskal');

  const MstMethod(this.label);
  final String label;
}

final _g5 = graphPresets.singleWhere((p) => p.id == 'g5');
final mstPresets = [
  _g5,
  AlgorithmPreset(
    id: 'separate',
    name: 'G₅ 变体 · 另一个分量',
    input: _g5.input
        .addVertex(const Vec2(x: .02, y: .02))
        .addVertex(const Vec2(x: .21, y: .03))
        .connect('V7', 'V8', weight: 3),
  ),
];

class MinimumSpanningTreeModule implements AlgorithmModule<GraphInputModel> {
  const MinimumSpanningTreeModule({this.method = MstMethod.prim, this.source});
  final MstMethod method;
  final String? source;
  @override
  String get id => 'ch6_mst_prim_kruskal';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => mstPresets;
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final p = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择无向网预设')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(GraphInputModel input) {
    if (input.kind != GraphKind.udn) throw ArgumentError('最小生成树实验需要无向网');
    final run = _MstRun(this, input);
    return method == MstMethod.prim ? run.prim() : run.kruskal();
  }
}

class _MstRun {
  _MstRun(this.module, this.graph);
  final MinimumSpanningTreeModule module;
  final GraphInputModel graph;
  late final ids = [for (final v in graph.vertices) v.id];
  late final storage = GraphStorage(graph, graph.arcs.length);
  late final original = graphScene(graph, storage);
  late final b = TraceBuilder(
    moduleId: module.id,
    inputSummary:
        '${module.method.label} · ${ids.length} 点 / ${graph.arcs.length} 边',
    codeLines: module.method == MstMethod.prim ? _primCode : _kruskalCode,
  );
  final selected = <String>{}, rejected = <String>{}, inside = <String>{};
  final predecessor = <String, String>{}, cost = <String, int>{};
  final components = <String, int>{};
  late final sorted = graph.arcs.indexed.toList()
    ..sort((a, b) {
      final byWeight = a.$2.weight.compareTo(b.$2.weight);
      return byWeight == 0 ? a.$1.compareTo(b.$1) : byWeight;
    });
  int total = 0;
  bool get isPrim => module.method == MstMethod.prim;
  void take(GraphArc edge) {
    selected.add(edge.id);
    total += edge.weight;
  }

  void emit(
    int line,
    String title,
    String detail, {
    String? vertex,
    String? checked,
    GraphArc? edge,
    bool milestone = false,
    int compares = 0,
    int writes = 0,
    Map<String, String> vars = const {},
  }) {
    final highlighted = checked ?? vertex;
    final table = isPrim
        ? [
            AuxTableSnapshot(
              id: 'closedge',
              title: 'closedge',
              columns: ['顶点', 'adjvex', 'lowcost', '集合'],
              rows: [
                for (final id in ids)
                  [
                    id,
                    inside.contains(id) ? '—' : predecessor[id] ?? '—',
                    inside.contains(id) ? '0' : cost[id]?.toString() ?? '∞',
                    inside.contains(id) ? 'U' : 'V−U',
                  ],
              ],
              highlightedRows: {
                if (highlighted != null) ids.indexOf(highlighted),
              },
            ),
          ]
        : [
            AuxTableSnapshot(
              id: 'edges',
              title: 'Edge · 按权值排序',
              columns: ['边', '端点', '权值', '状态'],
              rows: [
                for (final (_, e) in sorted)
                  [
                    e.id,
                    '${e.tail} — ${e.head}',
                    '${e.weight}',
                    selected.contains(e.id)
                        ? '采用'
                        : rejected.contains(e.id)
                        ? '舍弃'
                        : edge?.id == e.id
                        ? '试探'
                        : '待查',
                  ],
              ],
              highlightedRows: {
                if (edge != null) sorted.indexWhere((e) => e.$2.id == edge.id),
              },
            ),
            AuxTableSnapshot(
              id: 'vexset',
              title: 'Vexset · 连通分量',
              columns: ['顶点', '分量'],
              rows: [
                for (final id in ids) [id, '${components[id]}'],
              ],
              highlightedRows: {
                if (edge != null) ...[
                  ids.indexOf(edge.tail),
                  ids.indexOf(edge.head),
                ],
              },
            ),
          ];
    b.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      deltaCompare: compares,
      deltaWrite: writes,
      milestone: milestone,
      vars: {
        '算法': module.method.label,
        '已选边': '${selected.length}',
        '权值和': '$total',
        '分量数': '${ids.length - selected.length}',
        if (isPrim) 'U': inside.join('、'),
        '当前边': ?edge?.id,
        ...vars,
      },
      scene: original.copyWith(
        auxTables: table,
        nodes: [
          for (final n in original.nodes)
            n.copyWith(
              groupTag: isPrim
                  ? (inside.contains(n.id) ? 'U' : null)
                  : components[n.id].toString(),
              visualState: n.id == highlighted
                  ? NodeVisualState.active
                  : inside.contains(n.id)
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final e in original.edges)
            e.copyWith(
              visualState: selected.contains(e.id)
                  ? NodeVisualState.sorted
                  : rejected.contains(e.id)
                  ? (edge?.id == e.id
                        ? NodeVisualState.error
                        : NodeVisualState.sentinel)
                  : isPrim &&
                        inside.contains(e.fromNodeId) !=
                            inside.contains(e.toNodeId)
                  ? NodeVisualState.comparing
                  : edge?.id == e.id
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
      ),
    );
  }

  TraceTimeline finish(int line) {
    final parts = ids.length - selected.length;
    final title = ids.isEmpty
        ? '空网'
        : parts == 1
        ? '最小生成树完成'
        : '最小生成森林完成';
    emit(
      line,
      title,
      ids.isEmpty
          ? '空网没有生成树。'
          : parts == 1
          ? '${ids.length} 个顶点，${selected.length} 条树边，总权值 $total。'
          : '有 $parts 个连通分量，无法生成单一生成树。森林含 ${selected.length} 条边，权值和 $total。',
      milestone: true,
    );
    return b.build();
  }

  TraceTimeline prim() {
    final source = ids.contains(module.source)
        ? module.source
        : ids.firstOrNull;
    final roots = [
      ?source,
      for (final id in ids)
        if (id != source) id,
    ];
    for (final root in roots) {
      if (inside.contains(root)) continue;
      final first = inside.isEmpty;
      inside.add(root);
      for (final id in ids.where((id) => !inside.contains(id))) {
        predecessor[id] = root;
        final edge = storage.cells[(root, id)];
        if (edge != null) cost[id] = edge.weight;
      }
      emit(
        1,
        first ? '从 $root 初始化割集' : '从 $root 开始另一棵树',
        first ? '用 $root 的矩阵行初始化 closedge，无边处为 ∞。' : '上一分量没有跨割边，从未并入顶点开始另一棵树。',
        vertex: root,
        milestone: true,
      );
      while (inside.length < ids.length) {
        String? k;
        for (final j in ids) {
          if (inside.contains(j) || !cost.containsKey(j)) continue;
          if (k == null || cost[j]! < cost[k]!) k = j;
        }
        if (k == null) {
          emit(2, '当前割上没有边', '余下 lowcost 全为 ∞，当前连通分量已经完成。');
          break;
        }
        final from = predecessor[k]!, edge = storage.cells[(from, k)]!;
        emit(
          2,
          '最小跨割边 $from — $k',
          '$k 的 lowcost = ${edge.weight}，同权时取顶点表中靠前者。',
          vertex: k,
          edge: edge,
        );
        take(edge);
        inside.add(k);
        emit(
          3,
          '并入 $k',
          '采用 $from — $k，closedge[$k].lowcost 置 0。',
          vertex: k,
          edge: edge,
          milestone: true,
        );
        for (final j in ids.where((id) => !inside.contains(id))) {
          final candidate = storage.cells[(k, j)], previous = cost[j];
          final smaller =
              candidate != null &&
              (previous == null || candidate.weight < previous);
          final relation = '${candidate?.weight ?? '∞'} < ${previous ?? '∞'}';
          emit(
            4,
            '检查 $k — $j',
            '比较矩阵单元与当前 lowcost：$relation ${smaller ? '成立。' : '不成立，保留原值。'}',
            vertex: k,
            checked: j,
            edge: candidate,
            compares: 1,
            vars: {'j': j, '比较': relation},
          );
          if (smaller) {
            predecessor[j] = k;
            cost[j] = candidate.weight;
            emit(
              5,
              '更新 closedge[$j]',
              '以 $k 为邻接点，将 lowcost 更新为 ${candidate.weight}。',
              vertex: k,
              checked: j,
              edge: candidate,
              writes: 1,
              vars: {'j': j},
            );
          }
        }
      }
    }
    return finish(6);
  }

  TraceTimeline kruskal() {
    for (final (i, id) in ids.indexed) {
      components[id] = i;
    }
    emit(1, '排序并初始化 Vexset', '按权值升序排列，同权保留输入顺序。每个顶点自成一个分量。', milestone: true);
    for (final (_, edge) in sorted) {
      final a = components[edge.tail]!, c = components[edge.head]!;
      final pair = {'vs1': '$a', 'vs2': '$c'};
      emit(
        2,
        '试探 ${edge.tail} — ${edge.head}',
        '读取两个端点的分量号 $a、$c。',
        edge: edge,
        vars: pair,
        compares: 1,
      );
      if (a == c) {
        rejected.add(edge.id);
        emit(
          3,
          '该边构成回路，舍弃',
          '两端同属分量 $a，继续检查下一条边。',
          edge: edge,
          vars: pair,
          milestone: true,
        );
      } else {
        take(edge);
        var changed = 0;
        for (final id in ids) {
          if (components[id] == c) {
            components[id] = a;
            changed++;
          }
        }
        emit(
          4,
          '采用 ${edge.tail} — ${edge.head}',
          '将分量 $c 的 $changed 个顶点并入分量 $a。',
          edge: edge,
          vars: pair,
          writes: changed,
          milestone: true,
        );
      }
    }
    return finish(5);
  }
}
