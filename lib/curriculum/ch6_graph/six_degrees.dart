import 'dart:collection';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';

enum SixDegreeRule {
  distance('六层 BFS'),
  printed('教材七次出队');

  const SixDegreeRule(this.label);
  final String label;
}

// Purpose-built classroom network. The textbook supplies the algorithm, not this dataset.
final communityNetwork = graphExample(
  GraphKind.udg,
  [
    for (var row = 0; row < 5; row++)
      for (var col = 0; col < 6; col++) (.04 + col * .18, .04 + row * .22),
  ],
  [
    (1, 2, 1),
    (1, 3, 1),
    (1, 4, 1),
    (2, 5, 1),
    (2, 6, 1),
    (2, 7, 1),
    (3, 8, 1),
    (3, 9, 1),
    (3, 10, 1),
    (4, 11, 1),
    (4, 12, 1),
    (5, 13, 1),
    (5, 14, 1),
    (8, 15, 1),
    (8, 16, 1),
    (11, 17, 1),
    (11, 18, 1),
    (13, 19, 1),
    (13, 20, 1),
    (15, 21, 1),
    (15, 22, 1),
    (17, 23, 1),
    (19, 24, 1),
    (19, 25, 1),
    (21, 26, 1),
    (23, 27, 1),
    (24, 28, 1),
    (26, 29, 1),
    (27, 30, 1),
    (5, 6, 1),
    (6, 7, 1),
    (7, 5, 1),
    (8, 9, 1),
    (9, 10, 1),
    (10, 8, 1),
    (11, 12, 1),
    (6, 14, 1),
    (9, 16, 1),
    (12, 18, 1),
    (13, 14, 1),
    (15, 16, 1),
    (17, 18, 1),
    (19, 20, 1),
    (21, 22, 1),
    (24, 25, 1),
  ],
);
final _communityPreset = AlgorithmPreset(
  id: 'community30',
  name: '30 人社区 · 教学预设',
  input: communityNetwork,
);

class SixDegreeModule implements AlgorithmModule<GraphInputModel> {
  const SixDegreeModule({this.source, this.rule = SixDegreeRule.distance});
  final String? source;
  final SixDegreeRule rule;
  @override
  String get id => 'ch6_dfs_bfs_sixdeg';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => [
    _communityPreset,
    ...graphPresets,
  ];
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final p = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择网络预设')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(GraphInputModel graph) {
    final storage = GraphStorage(graph, graph.arcs.length),
        original = graphScene(graph, storage);
    final start = graph.vertices.any((n) => n.id == source)
        ? source
        : graph.vertices.firstOrNull?.id;
    final printed = rule == SixDegreeRule.printed;
    final b = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${rule.label} · ${start ?? '∅'} · ${graph.vertices.length} 人',
      codeLines: _code(printed),
    );
    final distance = <String, int>{},
        queue = Queue<String>(),
        parents = <String, String>{},
        discoveryEdges = <String>{};
    var popped = 0, deepest = 0;
    final n = graph.vertices.length;
    void emit(
      List<int> lines,
      String title,
      String explain, {
      String? u,
      String? w,
      int reads = 0,
      bool milestone = false,
    }) {
      final reached = distance.isEmpty ? 0 : distance.length - 1;
      final percent = n == 0
          ? '—'
          : '${(100 * reached / n).toStringAsFixed(1)}%';
      b.step(
        title: title,
        explain: explain,
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        deltaRead: reads,
        milestone: milestone,
        vars: {
          '源点': start ?? '∅',
          '已达其他人': '$reached',
          '总人数': '$n',
          '占比': percent,
          '最远层': '$deepest',
          '出队次数': '$popped',
          '队列': queue.join(' → '),
          'u': ?u,
          'w': ?w,
          if (printed) '整型输出': n == 0 ? '—' : '${100 * reached ~/ n}%',
        },
        scene: original.copyWith(
          nodes: [
            for (final node in original.nodes)
              node.copyWith(
                groupTag: distance[node.id]?.toString(),
                visualState: node.id == u
                    ? NodeVisualState.active
                    : distance.containsKey(node.id)
                    ? NodeVisualState.sorted
                    : NodeVisualState.normal,
              ),
          ],
          edges: [
            for (final edge in original.edges)
              edge.copyWith(
                visualState: discoveryEdges.contains(edge.id)
                    ? NodeVisualState.sorted
                    : NodeVisualState.normal,
              ),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'degrees',
              title: '首次抵达 · 最短距离',
              columns: ['人物', '距离', '来自'],
              rows: [
                for (final id in distance.keys)
                  [id, '${distance[id]}', parents[id] ?? '∅'],
              ],
            ),
          ],
        ),
      );
    }

    if (start != null) {
      distance[start] = 0;
      queue.add(start);
    }
    emit(
      [1, 2],
      '起点 ${start ?? '∅'}',
      start == null ? '网络为空，可在编辑模式添加人物。' : '源点距离为 0，计入网络总人数。触达其他人数从 0 开始。',
      milestone: true,
    );
    while (queue.isNotEmpty &&
        (printed ? popped < 7 : distance[queue.first]! < 6)) {
      final u = queue.removeFirst();
      popped++;
      emit([3, 4], '第 $popped 次出队 · $u', '从 ${distance[u]} 度的 $u 扫描邻接点。', u: u);
      var reads = 0;
      for (final item in storage.chain(u)) {
        reads++;
        final w = item.vertex;
        if (distance.containsKey(w)) continue;
        final d = distance[u]! + 1, newLayer = d > deepest;
        if (newLayer) deepest = d;
        distance[w] = d;
        parents[w] = u;
        discoveryEdges.add(item.arc.id);
        queue.addLast(w);
        emit(
          [5, 6],
          '$d 度 · 抵达 $w',
          '$w 经 $u 首次入队，最短距离为 $d 条边。',
          u: u,
          w: w,
          reads: reads,
          milestone: newLayer,
        );
        reads = 0;
      }
      if (reads > 0) {
        emit(
          [5],
          '$u 的邻接链结束',
          '其余 $reads 个邻接点均已访问，人数保持不变。',
          u: u,
          reads: reads,
        );
      }
    }
    emit(
      [7],
      printed ? '教材循环结束' : '六度统计完成',
      queue.isEmpty
          ? '队列已空，所有可达人物均已检查。'
          : printed
          ? '已执行七次出队，队列中仍有人。'
          : '队首已达第六层。该层已计数，继续展开会进入第七层。',
      milestone: true,
    );
    return b.build();
  }

  Map<CodeLang, List<String>> _code(bool printed) => {
    CodeLang.cLike: [
      'Vis_Num ← 0；清空 visited 和队列 Q',
      '标记 Start；dist[Start] ← 0；Start 入队',
      printed ? '循环至多七次，若队空则停止' : '当 Q 非空且队首的 dist < 6 时循环',
      'u ← DeQueue(Q)',
      '逐一检查 u 的邻接点 w，跳过已访问者',
      '标记 w；dist[w] ← dist[u]+1；Vis_Num++；w 入队',
      printed ? '输出 100 × Vis_Num / 顶点数（整型）' : '返回 100.0 × Vis_Num / 顶点数',
    ],
    CodeLang.c99: [
      'int count=0; clear_visited(); init_queue(&q);',
      'seen[start]=1; dist[start]=0; enqueue(&q,start);',
      printed
          ? 'for(int len=1; len<=7 && !empty(&q); ++len){'
          : 'while(!empty(&q) && dist[front(&q)]<6){',
      '  int u=dequeue(&q);',
      '  for(Arc *p=first[u]; p; p=p->next){ int w=p->adjvex; if(seen[w]) continue;',
      '    seen[w]=1; dist[w]=dist[u]+1; ++count; enqueue(&q,w); } }',
      printed ? 'return 100*count/n;' : 'return 100.0*count/n;',
    ],
    CodeLang.dart: [
      'var count=0; final q=Queue<int>(), dist=<int,int>{};',
      'dist[start]=0; q.addLast(start);',
      printed
          ? 'for(var len=1; len<=7 && q.isNotEmpty; len++){'
          : 'while(q.isNotEmpty && dist[q.first]!<6){',
      '  final u=q.removeFirst();',
      '  for(final w in neighbors(u)){ if(dist.containsKey(w)) continue;',
      '    dist[w]=dist[u]!+1; count++; q.addLast(w); } }',
      printed ? 'return 100*count ~/ n;' : 'return 100.0*count/n;',
    ],
  };
}
