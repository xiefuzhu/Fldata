import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_examples.dart';
import 'graph_input.dart';
import 'shortest_path_module.dart';

/// Path stores the immediate predecessor of the destination in the source row.
List<int> floydRoute(int from, int to, List<int> row) {
  if (from != to && row[to] < 0) return [];
  final result = <int>[];
  void append(int v) {
    if (v != from) append(row[v]);
    result.add(v);
  }

  append(to);
  return result;
}

class FloydModule extends ShortestPathModule {
  const FloydModule();
  @override
  TraceTimeline generateTrace(GraphInputModel input) {
    final ids = input.vertices.map((v) => v.id).toList(), n = ids.length;
    final graph = GraphStorage(input, input.arcs.length),
        scene = graphScene(input, graph);
    final dist = List.generate(
      n,
      (i) => List<int?>.generate(n, (j) {
        final weight = graph.cells[(ids[i], ids[j])]?.weight;
        return i == j && (weight == null || weight >= 0) ? 0 : weight;
      }),
    );
    final path = List.generate(
      n,
      (i) => List.generate(n, (j) => dist[i][j] != null && i != j ? i : -1),
    );
    final b = TraceBuilder(
      moduleId: id,
      inputSummary: 'Floyd · $n 个顶点 · ${input.arcs.length} 条边',
      codeLines: _code,
    );
    String d(int? x) => x?.toString() ?? '∞';
    Set<String> edges(List<int> route) => {
      for (var p = 1; p < route.length; p++)
        graph.cells[(ids[route[p - 1]], ids[route[p]])]!.id,
    };
    void emit(
      int line,
      String title,
      String detail, {
      required String phase,
      int k = -1,
      int? i,
      int? j,
      List<int> left = const [],
      List<int> right = const [],
      String? formula,
      bool milestone = false,
      bool error = false,
      int compares = 0,
    }) {
      final first = edges(left), second = edges(right);
      final heading = ['i / j', ...ids];
      b.step(
        title: title,
        explain: detail,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        error: error,
        milestone: milestone,
        deltaCompare: compares,
        deltaWrite: phase == '写回' ? 2 : 0,
        vars: {
          '阶段': phase,
          'k': '$k',
          if (i != null) 'i': '$i',
          if (j != null) 'j': '$j',
          '算式': ?formula,
          if (left.isNotEmpty && right.isNotEmpty)
            '拼接': [...left, ...right.skip(1)].map((v) => ids[v]).join(' → '),
        },
        scene: scene.copyWith(
          nodes: [
            for (final (v, node) in scene.nodes.indexed)
              node.copyWith(
                visualState: error && v == i
                    ? NodeVisualState.error
                    : v == k
                    ? NodeVisualState.active
                    : v == i || v == j
                    ? NodeVisualState.comparing
                    : NodeVisualState.normal,
              ),
          ],
          edges: [
            for (final e in scene.edges)
              e.copyWith(
                visualState:
                    error && (first.contains(e.id) || second.contains(e.id))
                    ? NodeVisualState.error
                    : second.contains(e.id)
                    ? NodeVisualState.comparing
                    : first.contains(e.id)
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'dist',
              title: '距离 D',
              columns: heading,
              rows: [
                for (var v = 0; v < n; v++) [ids[v], ...dist[v].map(d)],
              ],
            ),
            AuxTableSnapshot(
              id: 'pred',
              title: '前驱 Path',
              columns: heading,
              rows: [
                for (var v = 0; v < n; v++)
                  [ids[v], for (final p in path[v]) '$p'],
              ],
            ),
          ],
        ),
      );
    }

    for (var v = 0; v < n; v++) {
      if (dist[v][v]! < 0) {
        emit(
          1,
          '检测到负权自环',
          '${ids[v]} 可经自环反复降低路径长度，无法生成完整的最短距离矩阵。',
          phase: '负环',
          i: v,
          j: v,
          left: [v, v],
          error: true,
        );
        return b.build();
      }
    }
    emit(
      1,
      '初始化双矩阵',
      '直接弧写入边权与起点下标。自身距离为 0，没有前驱的单元为 −1。',
      phase: '初始化',
      milestone: true,
    );
    for (var k = 0; k < n; k++) {
      final before = [for (final row in path) List<int>.of(row)];
      int changed = 0, pending = 0;
      emit(
        2,
        '允许经过 ${ids[k]}',
        '本轮尝试拼接 i → ${ids[k]} 和 ${ids[k]} → j。',
        phase: '轮首',
        k: k,
      );
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          pending++;
          final a = dist[i][k], c = dist[k][j], old = dist[i][j];
          if (a == null || c == null) continue;
          final sum = a + c;
          if (old != null && sum >= old) continue;
          final left = floydRoute(i, k, before[i]),
              right = floydRoute(k, j, before[k]);
          final formula = 'D[$i][$k]($a) + D[$k][$j]($c) = $sum < ${d(old)}';
          emit(
            3,
            '比较 ${ids[i]} → ${ids[j]}',
            '候选路径更短，橙色单元为两段距离。',
            phase: '比较',
            k: k,
            i: i,
            j: j,
            left: left,
            right: right,
            formula: formula,
            compares: pending,
          );
          pending = 0;
          dist[i][j] = sum;
          path[i][j] = before[k][j];
          if (i == j) {
            emit(
              5,
              '检测到负权回路',
              '${ids[i]} 回到自身的距离已为 $sum，经过该回路的路径可以继续缩短。',
              phase: '负环',
              k: k,
              i: i,
              j: j,
              left: left,
              right: right,
              formula: formula,
              error: true,
            );
            return b.build();
          }
          changed++;
          emit(
            4,
            '写回 D[$i][$j] 与 Path[$i][$j]',
            '直接前驱取 Path[$k][$j] = ${path[i][j]}。',
            phase: '写回',
            k: k,
            i: i,
            j: j,
            left: left,
            right: right,
            formula: formula,
          );
        }
      }
      emit(
        5,
        '第 ${k + 1} 轮完成',
        '允许中转到 ${ids[k]}，本轮缩短了 $changed 对顶点的距离。',
        phase: '轮末',
        k: k,
        compares: pending,
        milestone: true,
      );
    }
    emit(
      6,
      n == 0 ? '空图' : '所有顶点对计算完成',
      n == 0 ? '可在画布上添加顶点。' : '点击 D 或 Path 矩阵中的单元，沿该行前驱回溯所选起点到终点的路径。',
      phase: '完成',
      k: n - 1,
      milestone: true,
    );
    return b.build();
  }
}

const _code = {
  CodeLang.cLike: [
    'D ← 直接距离，自身取 0 或负自环；直达非自身时 Path[i][j] ← i，其余取 −1',
    '依次允许 k = 0..n−1 作为中转顶点',
    '  对每个 (i,j)，若 D[i][k] 与 D[k][j] 有限且两者之和 < D[i][j]',
    '    D[i][j] ← D[i][k] + D[k][j]；Path[i][j] ← Path[k][j]',
    '  对角线为负表示存在负权回路，否则保存本轮双矩阵',
    '返回 D 和 Path',
  ],
  CodeLang.c99: [
    'init_distance_and_predecessors(G,D,Path); if(negative_diagonal(D)) return ERROR;',
    'for(int k=0;k<n;k++){',
    '  for(int i=0;i<n;i++) for(int j=0;j<n;j++) if(finite_pair(D,i,k,j) && D[i][k]+D[k][j]<D[i][j]) {',
    '    D[i][j]=D[i][k]+D[k][j]; Path[i][j]=Path[k][j];',
    '    if(i==j && D[i][j]<0) return ERROR; } }',
    'return OK;',
  ],
  CodeLang.dart: [
    'initMatrices(graph,d,p); checkDiagonal(d);',
    'for(var k=0;k<n;k++){',
    '  for(var i=0;i<n;i++) for(var j=0;j<n;j++){ final a=d[i][k], b=d[k][j]; if(a!=null && b!=null && (d[i][j]==null || a+b<d[i][j]!)){',
    '    d[i][j]=a+b; p[i][j]=p[k][j];',
    '    if(i==j && d[i][j]!<0) throw NegativeCycle(); } } }',
    'return (d,p);',
  ],
};
