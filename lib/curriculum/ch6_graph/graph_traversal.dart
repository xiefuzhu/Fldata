import 'dart:collection';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_input.dart';
import 'graph_examples.dart';

part 'graph_traversal_source.dart';

enum TraversalMode {
  matrix('DFS_AM'),
  list('DFS_AL'),
  breadth('BFS');

  const TraversalMode(this.label);
  final String label;
}

final textbookG4 = graphExample(
  GraphKind.udg,
  [
    (.50, .04),
    (.23, .30),
    (.77, .30),
    (.06, .60),
    (.39, .60),
    (.62, .60),
    (.94, .60),
    (.49, .96),
  ],
  // Head insertion in this order yields the ascending neighbors of figure 6.17.
  [
    (6, 7, 1),
    (5, 8, 1),
    (4, 8, 1),
    (3, 7, 1),
    (3, 6, 1),
    (2, 5, 1),
    (2, 4, 1),
    (1, 3, 1),
    (1, 2, 1),
  ],
);
final traversalPresets = [
  AlgorithmPreset(id: 'g4', name: 'G₄ · 图 6.17', input: textbookG4),
  AlgorithmPreset(
    id: 'forest',
    name: 'G₄ 变体 · 非连通与孤立点',
    input: textbookG4
        .removeEdge(textbookG4.edge('V1', 'V3')!.id)
        .addVertex(const Vec2(x: .86, y: .92)),
  ),
  ...graphPresets,
];

class GraphTraversalModule implements AlgorithmModule<GraphInputModel> {
  const GraphTraversalModule({this.mode = TraversalMode.matrix, this.source});
  final TraversalMode mode;
  final String? source;
  @override
  String get id => 'ch6_dfs_bfs_sixdeg';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => traversalPresets;
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final p = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择遍历图预设')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(GraphInputModel input) =>
      _Traversal(this, input).run();
}

typedef _Neighbor = ({String vertex, GraphArc? arc});

class _Traversal {
  _Traversal(this.module, this.graph)
    : storage = GraphStorage(graph, graph.arcs.length);
  final GraphTraversalModule module;
  final GraphInputModel graph;
  final GraphStorage storage;
  late final original = graphScene(graph, storage);
  late final builder = TraceBuilder(
    moduleId: module.id,
    inputSummary:
        '${mode.label} · ${graph.kind.label} · ${graph.vertices.length} 点 / ${graph.arcs.length} 边',
    codeLines: _traversalCode(mode),
  );
  TraversalMode get mode => module.mode;
  bool get bfs => mode == TraversalMode.breadth;
  final visited = <String>{}, treeEdges = <String>{}, otherEdges = <String>{};
  final parents = <String, String?>{}, levels = <String, int>{};
  final stack = <String>[], roots = <String>[];
  final queue = Queue<String>();
  int probes = 0;
  Iterable<_Neighbor> neighbors(String v) => mode == TraversalMode.matrix
      ? graph.vertices.map((w) => (vertex: w.id, arc: storage.cells[(v, w.id)]))
      : storage.chain(v);

  void emit(
    int line,
    String title,
    String description, {
    String? v,
    String? w,
    String? arcId,
    int? slot,
    bool read = false,
    bool milestone = false,
  }) {
    if (read) probes++;
    final scan = v == null ? <_Neighbor>[] : neighbors(v).toList();
    final edgeRole = treeEdges.contains(arcId)
        ? '树边'
        : otherEdges.contains(arcId)
        ? '非树边'
        : null;
    final vars = <String, String>{
      '方式': mode.label,
      '检查次数': '$probes',
      '访问序列': visited.join(' → '),
      '森林根': roots.join('、'),
      if (bfs) '队列': queue.join(' → '),
      if (!bfs) '递归路径': stack.join(' → '),
      'v': ?v,
      'w': ?w,
      if (slot != null && mode == TraversalMode.matrix) '列下标': '$slot',
      if (slot != null && mode != TraversalMode.matrix) 'p': arcId ?? '∅',
    };
    builder.step(
      title: title,
      explain: description,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      deltaRead: read ? 1 : 0,
      milestone: milestone,
      vars: vars,
      callStack: [
        for (final (i, id) in stack.indexed)
          StackActivationRecord(
            id: 'dfs-$id',
            functionName: mode.label,
            arguments: {'v': id},
            locals: {if (id == v && w != null) 'w': w},
            returnLocation: i == 0 ? '外层顶点循环' : '${stack[i - 1]} · 下一邻接点',
            parentCallId: i == 0 ? null : 'dfs-${stack[i - 1]}',
          ),
      ],
      scene: original.copyWith(
        nodes: [
          for (final n in original.nodes)
            n.copyWith(
              visualState: n.id == v
                  ? NodeVisualState.active
                  : visited.contains(n.id)
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final e in original.edges)
            e.copyWith(
              weightLabel: e.id == arcId && edgeRole != null
                  ? [
                      if (e.weightLabel != null) e.weightLabel!,
                      edgeRole,
                    ].join(' · ')
                  : e.weightLabel,
              visualState: treeEdges.contains(e.id)
                  ? NodeVisualState.sorted
                  : otherEdges.contains(e.id)
                  ? NodeVisualState.sentinel
                  : e.id == arcId
                  ? NodeVisualState.comparing
                  : NodeVisualState.normal,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'scan',
            title: mode == TraversalMode.matrix
                ? '矩阵行 ${v ?? ''}'
                : '邻接链 ${v ?? ''}',
            columns: ['邻接点', mode == TraversalMode.matrix ? '单元值' : '边结点'],
            rows: [
              for (final entry in scan)
                [
                  entry.vertex,
                  mode == TraversalMode.matrix
                      ? entry.arc?.weight.toString() ??
                            (graph.kind.weighted ? '∞' : '0')
                      : entry.arc!.id,
                ],
            ],
            highlightedRows: {?slot},
          ),
          AuxTableSnapshot(
            id: 'forest',
            title: '生成森林',
            columns: ['顶点', '双亲', '层数'],
            rows: [
              for (final id in visited)
                [id, parents[id] ?? '∅', '${levels[id]}'],
            ],
          ),
        ],
      ),
    );
  }

  void visit(String v, {String? parent, GraphArc? edge, int? slot}) {
    if (parent == null) roots.add(v);
    visited.add(v);
    parents[v] = parent;
    levels[v] = parent == null ? 0 : levels[parent]! + 1;
    if (edge != null) treeEdges.add(edge.id);
    if (bfs) {
      queue.addLast(v);
    } else {
      stack.add(v);
    }
    emit(
      parent == null ? 3 : 6,
      parent == null ? '从 $v 开始新树' : '树边 $parent → $v',
      parent == null
          ? '将 $v 标记为已访问，作为本棵树的根。'
          : '首次发现 $v，记录双亲 $parent。${bfs ? '标记后立即入队。' : '递归进入新顶点。'}',
      v: bfs ? parent ?? v : v,
      w: bfs && parent != null ? v : null,
      slot: bfs ? slot : null,
      arcId: edge?.id,
      milestone: true,
    );
  }

  void expand(String v) {
    for (final (slot, n) in neighbors(v).indexed) {
      final e = n.arc, w = n.vertex;
      final known = visited.contains(w);
      if (e != null && known && !treeEdges.contains(e.id)) otherEdges.add(e.id);
      final title = e == null
          ? '空槽 $v / $w'
          : known
          ? (treeEdges.contains(e.id) ? '重遇树边' : '非树边')
          : '发现未访问邻接点';
      emit(
        5,
        title,
        e == null
            ? '检查这一列后继续扫描。'
            : known
            ? '$w 已访问，保留原来的双亲，继续检查下一邻接点。'
            : '$v 与 $w 相邻，准备将 $w 加入森林。',
        v: v,
        w: w,
        arcId: e?.id,
        slot: slot,
        read: true,
      );
      if (e == null || known) continue;
      visit(w, parent: v, edge: e, slot: slot);
      if (!bfs) depth(w);
    }
  }

  void depth(String v) {
    emit(
      4,
      '开始扫描 $v',
      mode == TraversalMode.matrix
          ? '按列下标依次检查整行。'
          : '从 firstarc 开始，沿 nextarc 依次检查邻接点。',
      v: v,
    );
    expand(v);
    stack.removeLast();
    emit(
      7,
      '从 $v 返回',
      stack.isEmpty ? '根的邻接点全部检查完毕。' : '回到 ${stack.last}，继续上次的扫描。',
      v: stack.lastOrNull,
    );
  }

  TraceTimeline run() {
    emit(1, '初始化 visited', '所有顶点初始均未访问。');
    final ids = graph.vertices.map((v) => v.id).toList();
    final source = module.source;
    if (source != null && ids.remove(source)) ids.insert(0, source);
    for (final v in ids) {
      if (visited.contains(v)) continue;
      emit(2, '外层选择 $v', '按外层次序检查，选择未访问顶点 $v 作为根。');
      visit(v);
      if (bfs) {
        while (queue.isNotEmpty) {
          final head = queue.removeFirst();
          emit(4, '出队 $head', '从队首取出 $head，准备扫描其邻接链。', v: head);
          expand(head);
        }
      } else {
        depth(v);
      }
    }
    emit(
      8,
      '遍历完成',
      '访问 ${visited.length} 个顶点，生成 ${roots.length} 棵树，接入 ${treeEdges.length} 条树边。',
      milestone: true,
    );
    return builder.build();
  }
}
