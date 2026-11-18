import 'shortest_path_module.dart';
export 'shortest_path_module.dart' show shortestPathPresets;
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';

/// Reconstruct indices in source-to-target order. An infinite entry has no route.
List<int> dijkstraRoute(int end, List<int> predecessor, List<int?> distance) {
  if (distance[end] == null) return [];
  final reversed = <int>[];
  for (var i = end; i != -1; i = predecessor[i]) {
    reversed.add(i);
  }
  return reversed.reversed.toList();
}

class DijkstraModule extends ShortestPathModule {
  const DijkstraModule({this.source});
  final String? source;
  @override
  TraceTimeline generateTrace(GraphInputModel input) {
    final ids = input.vertices.map((n) => n.id).toList(), n = ids.length;
    final start = ids.indexOf(source ?? '');
    final s = start < 0 ? 0 : start;
    final origin = n == 0 ? '∅' : ids[s];
    final storage = GraphStorage(input, input.arcs.length),
        original = graphScene(input, storage);
    final distance = List<int?>.filled(n, null),
        pred = List<int>.filled(n, -1),
        settled = <int>{};
    final rounds = <List<String>>[];
    final b = TraceBuilder(
      moduleId: id,
      inputSummary: 'Dijkstra · 源点 $origin · $n 个顶点',
      codeLines: _dijkstraSource,
    );
    final negative = input.arcs
        .where((e) => e.weight < 0)
        .map((e) => e.id)
        .toSet();
    String d(int? value) => value?.toString() ?? '∞';
    String members() => '{${settled.map((i) => ids[i]).join('、')}}';
    void recordRound(int round, int? chosen) {
      rounds.add([
        '$round',
        chosen == null ? '无' : ids[chosen],
        chosen == null ? '∞' : d(distance[chosen]),
        members(),
        for (var i = 0; i < n; i++) '${d(distance[i])}, ${pred[i]}',
      ]);
    }

    void emit(
      int line,
      String title,
      String explanation, {
      int? via,
      int? target,
      String? formula,
      bool milestone = false,
      bool done = false,
      bool invalid = false,
      int compares = 0,
    }) {
      final route = via == null ? <int>[] : dijkstraRoute(via, pred, distance);
      final prefix = <String>{
        for (var i = 1; i < route.length; i++)
          storage.cells[(ids[route[i - 1]], ids[route[i]])]!.id,
      };
      final arc = via != null && target != null
          ? storage.cells[(ids[via], ids[target])]
          : null;
      b.step(
        title: title,
        explain: explanation,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        milestone: milestone,
        error: invalid,
        deltaCompare: compares,
        vars: {
          '源点': origin,
          'S': members(),
          '轮次': '${rounds.length}',
          'v': ?(via == null ? null : ids[via]),
          'w': ?(target == null ? null : ids[target]),
          '松弛算式': ?formula,
          '阶段': invalid
              ? '输入错误'
              : done
              ? '完成'
              : '推演',
        },
        scene: original.copyWith(
          nodes: [
            for (final (i, node) in original.nodes.indexed)
              node.copyWith(
                visualState: i == target
                    ? NodeVisualState.comparing
                    : i == via
                    ? NodeVisualState.active
                    : settled.contains(i)
                    ? NodeVisualState.sorted
                    : NodeVisualState.normal,
              ),
          ],
          edges: [
            for (final e in original.edges)
              e.copyWith(
                visualState: negative.contains(e.id)
                    ? NodeVisualState.error
                    : e.id == arc?.id
                    ? NodeVisualState.comparing
                    : prefix.contains(e.id)
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'single',
              title: '实时 S、D、Path',
              columns: ['顶点', 'S', 'D', 'Path'],
              rows: [
                for (var i = 0; i < n; i++)
                  [
                    ids[i],
                    settled.contains(i) ? 'true' : 'false',
                    d(distance[i]),
                    '${pred[i]}',
                  ],
              ],
              highlightedRows: {?target, ?via},
            ),
            AuxTableSnapshot(
              id: 'rounds',
              title: '表 6.4 · 各轮选点',
              columns: ['轮', '终点', '长度', 'S', ...ids],
              rows: [...rounds],
              highlightedRows: {if (rounds.isNotEmpty) rounds.length - 1},
            ),
          ],
        ),
      );
    }

    if (negative.isNotEmpty) {
      emit(1, '发现负权边', 'Dijkstra 要求边权非负。删除红色边并用非负权值重新连边，即可继续。', invalid: true);
      return b.build();
    }
    if (n == 0) {
      emit(7, '空图', '添加顶点后可选择源点。', done: true);
      return b.build();
    }
    settled.add(s);
    for (var j = 0; j < n; j++) {
      final arc = storage.cells[(origin, ids[j])];
      if (j == s) {
        distance[j] = 0;
      } else if (arc != null) {
        distance[j] = arc.weight;
        pred[j] = s;
      }
    }
    emit(
      2,
      '初始化 S、D、Path',
      '源点距离为 0。直达顶点的前驱取源点下标，其余距离为 ∞，前驱为 −1。',
      via: s,
      milestone: true,
    );
    for (var round = 1; round < n; round++) {
      int? v;
      for (var i = 0; i < n; i++) {
        if (!settled.contains(i) &&
            distance[i] != null &&
            (v == null || distance[i]! < distance[v]!)) {
          v = i;
        }
      }
      if (v == null) {
        recordRound(round, null);
        emit(3, '剩余顶点不可达', 'S 外的距离均为 ∞，本轮没有终点可选。', milestone: true);
        break;
      }
      settled.add(v);
      recordRound(round, v);
      emit(
        4,
        '第 $round 轮 · 确定 ${ids[v]}',
        '当前最小暂定距离为 ${distance[v]}。表中保存选点时的距离和前驱。',
        via: v,
        milestone: true,
      );
      for (var w = 0; w < n; w++) {
        if (settled.contains(w)) continue;
        final arc = storage.cells[(ids[v], ids[w])], old = distance[w];
        final candidate = arc == null ? null : distance[v]! + arc.weight;
        final better = candidate != null && (old == null || candidate < old);
        final formula =
            'D[${ids[v]}](${distance[v]}) + arcs[$v][$w](${d(arc?.weight)}) = ${d(candidate)} < ${d(old)}　${better ? '成立' : '不成立'}';
        emit(
          5,
          '检查 ${ids[v]} → ${ids[w]}',
          arc == null
              ? '没有这条弧，保留原距离。'
              : better
              ? '候选距离更短，下一步写回 D 和 Path。'
              : '当前路径更短或等长，保留原前驱。',
          via: v,
          target: w,
          formula: formula,
          compares: 1,
        );
        if (better) {
          distance[w] = candidate;
          pred[w] = v;
          emit(
            6,
            '更新 ${ids[w]}',
            'D[$w] = $candidate，Path[$w] = $v。',
            via: v,
            target: w,
            formula: formula,
          );
        }
      }
    }
    emit(
      7,
      '单源最短路径完成',
      '已确定 ${settled.length} 个顶点。点击实时表中的终点可沿前驱回溯路径。',
      done: true,
      milestone: true,
    );
    return b.build();
  }
}

const _dijkstraSource = {
  CodeLang.cLike: [
    '检查输入网的边权均非负',
    'S ← {s}；D ← arcs[s]；D[s] ← 0；直达点的 Path 取 s，其余取 −1',
    '每轮在 S 外选取 D 最小的有限顶点 v，无则结束',
    '将 v 并入 S，记录本轮终点、距离与前驱',
    '对 S 外顶点 w，若有弧且 D[v] + arcs[v][w] < D[w]',
    '  D[w] ← D[v] + arcs[v][w]；Path[w] ← v',
    '返回 D 和 Path',
  ],
  CodeLang.c99: [
    'if (has_negative_edge(G)) return ERROR;',
    'init_dist_pred(G,s,D,Path); D[s]=0; Path[s]=-1; S[s]=true;',
    'for(int i=1;i<n;i++){ int v=min_unsettled(S,D); if(v<0) break;',
    '  S[v]=true;',
    '  for(int w=0;w<n;w++) if(!S[w] && has_arc(v,w) && D[v]+arcs[v][w]<D[w]) {',
    '    D[w]=D[v]+arcs[v][w]; Path[w]=v; } }',
    'return OK;',
  ],
  CodeLang.dart: [
    'checkNonnegative(graph);',
    'init(source, dist, pred); dist[source]=0; pred[source]=-1; seen.add(source);',
    'while(true){ final v=minUnsettled(dist,seen); if(v==null) break;',
    '  seen.add(v);',
    '  for(final w in vertices){ final a=weight(v,w); if(!seen.contains(w) && a!=null && (dist[w]==null || dist[v]!+a<dist[w]!)){',
    '    dist[w]=dist[v]!+a; pred[w]=v; } } }',
    'return (dist,pred);',
  ],
};
