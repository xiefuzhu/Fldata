import 'dart:math' as math;
import 'package:collection/collection.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';

GraphInputModel _example(
  GraphKind kind,
  int first,
  List<(double, double)> points,
  List<(int, int, int)> arcs,
) {
  var g = GraphInputModel.empty(kind, vertexPrefix: 'v', firstVertex: first);
  for (final (x, y) in points) {
    g = g.addVertex(Vec2(x: x, y: y));
  }
  for (final (i, j, w) in arcs) {
    g = g.connect('v$i', 'v$j', weight: w);
  }
  return g;
}

final _aov = _example(
  GraphKind.dg,
  1,
  [(.2, .08), (.80, .08), (.8, .50), (.2, .50), (.8, .92), (.2, .92)],
  [
    (1, 4, 1),
    (1, 3, 1),
    (1, 2, 1),
    (3, 2, 1),
    (3, 5, 1),
    (4, 5, 1),
    (6, 4, 1),
    (6, 5, 1),
  ],
);
final topoPresets = [
  AlgorithmPreset(id: 'aov', name: 'AOV · 图 6.27', input: _aov),
  AlgorithmPreset(
    id: 'aoe',
    name: 'AOE · 图 6.28 / 表 6.7',
    input: _example(
      GraphKind.dn,
      0,
      [
        (.02, .45),
        (.23, .07),
        (.23, .54),
        (.23, .93),
        (.49, .36),
        (.49, .93),
        (.75, .08),
        (.75, .60),
        (.98, .36),
      ],
      [
        (0, 1, 6),
        (0, 2, 4),
        (0, 3, 5),
        (1, 4, 1),
        (2, 4, 1),
        (3, 5, 2),
        (4, 6, 9),
        (4, 7, 7),
        (5, 7, 4),
        (6, 8, 2),
        (7, 8, 4),
      ],
    ),
  ),
  AlgorithmPreset(
    id: 'cycle',
    name: '含死锁环路有向图',
    input: _aov.removeEdge(_aov.edge('v1', 'v2')!.id).connect('v2', 'v1'),
  ),
];

enum TopoMethod {
  topological('拓扑排序'),
  critical('关键路径');

  const TopoMethod(this.label);
  final String label;
}

class TopoCriticalModule implements AlgorithmModule<GraphInputModel> {
  const TopoCriticalModule([this.method = TopoMethod.topological]);
  final TopoMethod method;
  @override
  String get id => 'ch6_topo_critical';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => topoPresets;
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final p = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择拓扑或工程预设')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(GraphInputModel input) {
    final run = _TopoRun(input, method, id);
    run.record();
    return run.builder.build();
  }
}

class _TopoRun {
  _TopoRun(this.input, this.method, String id)
    : builder = TraceBuilder(
        moduleId: id,
        inputSummary:
            '${method.label} · ${input.vertices.length} 个顶点 · ${input.arcs.length} 条弧',
        codeLines: method == TopoMethod.critical ? _criticalCode : _topoCode,
      );
  final GraphInputModel input;
  final TopoMethod method;
  final TraceBuilder builder;
  late final graph = GraphStorage(input, input.arcs.length);
  late final scene = graphScene(input, graph);
  late final degree = {
    for (final v in input.vertices) v.id: graph.incoming[v.id]!.length,
  };
  final stack = <String>[],
      order = <String>[],
      popped = <String>{},
      removed = <String>{};
  final ve = <String, int>{}, vl = <String, int>{};
  final activities = <String, List<String>>{},
      critical = <String>{},
      cycle = <String>{};
  int? duration;
  bool timing = false;
  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    String? vertex,
    GraphArc? arc,
    bool error = false,
    bool milestone = false,
    int writes = 0,
  }) {
    final at = method == TopoMethod.critical && !timing ? 1 : line;
    final done = phase == '关键活动', deadlock = phase == '有环';
    builder.step(
      title: title,
      explain: detail,
      cLikeLines: [at],
      c99Lines: [at],
      dartLines: [at],
      error: error,
      milestone: milestone,
      deltaWrite: writes,
      vars: {
        '阶段': phase,
        'S': stack.join(' → '),
        'topo': order.join(' → '),
        'm': '${order.length}',
        if (duration != null) '工期': '$duration',
        if (arc != null) '弧': arc.id,
      },
      scene: scene.copyWith(
        nodes: [
          for (final n in scene.nodes)
            n.copyWith(
              groupTag: timing ? 've/vl' : '入度',
              logicBadge: timing
                  ? '${ve[n.id] ?? '—'} / ${vl[n.id] ?? '—'}'
                  : null,
              visualState: deadlock && !popped.contains(n.id)
                  ? NodeVisualState.error
                  : n.id == vertex
                  ? NodeVisualState.active
                  : !timing && popped.contains(n.id)
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final e in scene.edges)
            e.copyWith(
              opacity: !timing && removed.contains(e.id) ? 0 : 1,
              visualState: cycle.contains(e.id) || error && e.id == arc?.id
                  ? NodeVisualState.error
                  : done && critical.contains(e.id)
                  ? NodeVisualState.sorted
                  : e.id == arc?.id
                  ? NodeVisualState.comparing
                  : NodeVisualState.normal,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'events',
            title: timing ? '事件发生时间' : '入度表',
            columns: timing ? ['事件', 've', 'vl'] : ['顶点', 'indegree'],
            rows: [
              for (final v in input.vertices)
                timing
                    ? [v.id, '${ve[v.id] ?? '—'}', '${vl[v.id] ?? '—'}']
                    : [v.id, '${degree[v.id]}'],
            ],
            highlightedRows: {
              if (vertex != null)
                input.vertices.indexWhere((v) => v.id == vertex),
            },
          ),
          if (activities.isNotEmpty)
            AuxTableSnapshot(
              id: 'activities',
              title: '活动开始时间与余量',
              columns: ['活动', '弧', '工期', 'e', 'l', 'l − e'],
              rows: [
                for (final e in input.arcs)
                  if (activities.containsKey(e.id)) activities[e.id]!,
              ],
              highlightedRows: {
                for (final (i, e)
                    in input.arcs
                        .where((e) => activities.containsKey(e.id))
                        .indexed)
                  if (done ? critical.contains(e.id) : arc?.id == e.id) i,
              },
            ),
        ],
      ),
    );
  }

  void record() {
    if (!input.kind.directed) {
      emit(1, '输入', '需要有向图', '每条弧的方向表示活动之间的先后依赖。', error: true);
      return;
    }
    stack.addAll(degree.keys.where((id) => degree[id] == 0));
    emit(1, '建栈', '统计入度，建立零入度栈', '按顶点表顺序入栈，最右侧为栈顶。', milestone: true);
    while (stack.isNotEmpty) {
      final u = stack.removeLast();
      order.add(u);
      popped.add(u);
      emit(
        2,
        '出栈',
        '$u 出栈并输出',
        '沿 $u 的邻接表逐条移去出弧。',
        vertex: u,
        milestone: true,
        writes: 1,
      );
      for (final item in graph.chain(u)) {
        final v = item.vertex;
        final n = degree[v]! - 1;
        degree[v] = n;
        removed.add(item.arc.id);
        emit(
          3,
          '减入度',
          '移去 $u → $v',
          'indegree[$v] 从 ${n + 1} 减至 $n。',
          vertex: v,
          arc: item.arc,
          writes: 1,
        );
        if (n == 0) {
          stack.add(v);
          emit(4, '入栈', '$v 入栈', '所有前驱已输出，$v 成为新的栈顶。', vertex: v, writes: 1);
        }
      }
    }
    if (order.length != degree.length) {
      final rest = {
        for (final v in degree.keys)
          if (!popped.contains(v)) v,
      };
      final components = stronglyConnectedComponents({
        for (final v in rest)
          v: graph.chain(v).map((a) => a.vertex).where(rest.contains),
      });
      final component = {
        for (final (i, s) in components.indexed)
          for (final v in s) v: i,
      };
      cycle.addAll(
        input.arcs
            .where(
              (e) =>
                  rest.contains(e.tail) &&
                  component[e.tail] == component[e.head],
            )
            .map((e) => e.id),
      );
      emit(
        5,
        '有环',
        '拓扑排序失败：图中存在有向环！',
        '仅输出 ${order.length} / ${degree.length} 个顶点。红色顶点仍在等待，红色弧位于闭合回路上。',
        error: true,
        milestone: true,
      );
      return;
    }
    emit(5, '拓扑完成', '拓扑排序完成', '已输出全部 ${order.length} 个顶点。', milestone: true);
    if (method != TopoMethod.critical || degree.isEmpty) return;
    final negative = input.arcs.where((e) => e.weight < 0).firstOrNull;
    timing = true;
    if (negative != null) {
      emit(
        2,
        '工期无效',
        '活动持续时间不能为负',
        '请修改 ${negative.tail} → ${negative.head} 的持续时间。',
        arc: negative,
        error: true,
      );
      return;
    }
    for (final v in order) {
      ve[v] = 0;
    }
    emit(2, '正推', '正推事件最早时间', '从所有源点的时间 0 开始，按拓扑序取最长到达时间。', milestone: true);
    for (final u in order) {
      for (final item in graph.chain(u)) {
        final e = item.arc,
            v = item.vertex,
            old = ve[v]!,
            candidate = ve[u]! + e.weight;
        ve[v] = math.max(old, candidate);
        emit(
          3,
          '正推',
          '正推 $u → $v',
          've[$v] = max($old, ${ve[u]} + ${e.weight}) = ${ve[v]}',
          vertex: v,
          arc: e,
          writes: ve[v] == old ? 0 : 1,
        );
      }
    }
    duration = ve.values.reduce(math.max);
    for (final v in order) {
      vl[v] = duration!;
    }
    emit(
      4,
      '逆推',
      '按总工期初始化最迟时间',
      '所有汇点均须在 $duration 以内完工。按逆拓扑序收紧各事件的期限。',
      milestone: true,
    );
    for (final u in order.reversed) {
      for (final item in graph.chain(u)) {
        final e = item.arc,
            v = item.vertex,
            old = vl[u]!,
            candidate = vl[v]! - e.weight;
        vl[u] = math.min(old, candidate);
        emit(
          5,
          '逆推',
          '逆推 $u → $v',
          'vl[$u] = min($old, ${vl[v]} − ${e.weight}) = ${vl[u]}',
          vertex: u,
          arc: e,
          writes: vl[u] == old ? 0 : 1,
        );
      }
    }
    for (final arc in input.arcs) {
      final early = ve[arc.tail]!,
          late = vl[arc.head]! - arc.weight,
          slack = late - early;
      final label = 'a${arc.id.substring(1)}';
      activities[arc.id] = [
        label,
        '${arc.tail} → ${arc.head}',
        '${arc.weight}',
        '$early',
        '$late',
        '$slack',
      ];
      if (slack == 0) critical.add(arc.id);
      emit(
        6,
        '活动余量',
        '计算 $label 的余量',
        'e = $early，l = ${vl[arc.head]} − ${arc.weight} = $late，余量 = $slack。',
        arc: arc,
        writes: 2,
      );
    }
    emit(
      7,
      '关键活动',
      '工程总工期 $duration',
      '红色粗线连接全部零余量活动。单独缩短非关键活动不能提前完工。若存在并行关键路径，需缩短它们的共通活动，或分别缩短每条关键路径。',
      milestone: true,
    );
  }
}

const _topoCode = {
  CodeLang.cLike: [
    '统计入度并按下标将零入度顶点压入 S',
    '反复弹出栈顶 u 并追加到 topo',
    '沿 u 的每条出弧将终点 v 的入度减一',
    '若入度为零，立即压入 S',
    '输出数 m 小于顶点数则返回 ERROR，否则返回 topo',
  ],
  CodeLang.c99: [
    'FindInDegree(G,indegree); PushZeroVertices(G,indegree,&S);',
    'while (!Empty(S)) { Pop(&S,&u); topo[m++]=u;',
    '  for (p=G.vertices[u].firstarc;p;p=p->nextarc) { v=p->adjvex; --indegree[v];',
    '    if (!indegree[v]) Push(&S,v); } }',
    'return m<G.vexnum ? ERROR : OK;',
  ],
  CodeLang.dart: [
    'final stack = vertices.where((v) => degree[v] == 0).toList();',
    'while(stack.isNotEmpty){ final u=stack.removeLast(); topo.add(u);',
    '  for(final v in neighbors(u)){ degree[v]=degree[v]!-1;',
    '    if(degree[v]==0) stack.add(v); } }',
    'return topo.length==vertices.length ? topo : null;',
  ],
};
const _criticalCode = {
  CodeLang.cLike: [
    '拓扑排序；遇环停止',
    '初始化所有事件的 ve 为 0，活动持续时间非负',
    '按拓扑序沿弧 u→v 取 ve[v] = max(ve[v],ve[u]+w)',
    '取汇点最早完成时间的最大值 T，初始化 vl 为 T',
    '逆拓扑序沿弧取 vl[u] = min(vl[u],vl[v]−w)',
    '对每个活动计算 e = ve[u]，l = vl[v]−w 及 l−e',
    '标出 e = l 的全部关键活动',
  ],
  CodeLang.c99: [
    'if (!TopologicalSort(G,topo)) return ERROR;',
    'InitEarliest(ve,n,0);',
    'FOR_TOPO_ARC(u,v,w) ve[v]=max(ve[v],ve[u]+w);',
    'T=MaxEventTime(ve,n); InitLatest(vl,n,T);',
    'FOR_REVERSE_TOPO_ARC(u,v,w) vl[u]=min(vl[u],vl[v]-w);',
    'FOR_ACTIVITY(u,v,w) { e=ve[u]; l=vl[v]-w; Record(u,v,e,l,l-e); }',
    'MarkZeroSlackActivities(G);',
  ],
  CodeLang.dart: [
    'final topo=topologicalSort(graph); if(topo==null) return;',
    'final ve={for(final v in topo) v:0};',
    'for(final u in topo){ for(final a in out(u)){ve[a.v]=max(ve[a.v]!,ve[u]!+a.w);} }',
    'final t=ve.values.reduce(max), vl={for(final v in topo) v:t};',
    'for(final u in topo.reversed){ for(final a in out(u)){vl[u]=min(vl[u]!,vl[a.v]!-a.w);} }',
    'for(final a in arcs){ final e=ve[a.u]!, l=vl[a.v]!-a.w; record(a,e,l,l-e); }',
    'highlight(activities.where((a)=>a.slack==0));',
  ],
};
