import 'graph_examples.dart';
export 'graph_examples.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'graph_input.dart';

class GraphStorageModule implements AlgorithmModule<GraphInputModel> {
  const GraphStorageModule();
  @override
  String get id => 'ch6_graph_storage';
  @override
  List<AlgorithmPreset<GraphInputModel>> get presets => graphPresets;
  @override
  ValidationResult<GraphInputModel> validateInput(String raw) {
    final preset = presets
        .where((p) => p.id == raw.trim().toLowerCase())
        .firstOrNull;
    return preset == null
        ? const ValidationResult.failure('请选择 G1、G2、G5 或 N')
        : ValidationResult.success(preset.input);
  }

  @override
  TraceTimeline generateTrace(GraphInputModel input) {
    final kind = input.kind, matrix = kind.weighted;
    final name = 'Create${kind.label}';
    final mirror = !kind.directed;
    final code = <CodeLang, List<String>>{
      CodeLang.cLike: [
        '$name(G): 读入顶点，按输入次序编号',
        matrix ? '将 arcs 的每个单元初始化为 ∞' : '将各顶点的 firstarc 置空',
        '依次读入端点，定位下标 i, j',
        matrix
            ? 'arcs[i][j] ← w${mirror ? '，arcs[j][i] ← w' : ''}'
            : '头插(i, j)${mirror ? '，头插(j, i)' : ''}',
        '返回 G',
      ],
      CodeLang.c99: [
        '/* $name */ read_vertices(&G);',
        matrix ? 'fill_matrix(&G, 32767);' : 'clear_firstarc(&G);',
        'for (int k = 0; k < G.arcnum; ++k) { read_edge(&i, &j, &w);',
        matrix
            ? '  G.arcs[i][j] = w; ${mirror ? 'G.arcs[j][i] = w; ' : ''}}'
            : '  push_front(&G, i, j); ${mirror ? 'push_front(&G, j, i); ' : ''}}',
        'return G;',
      ],
      CodeLang.dart: [
        'final n = input.vertices.length;',
        matrix
            ? 'final a = List.generate(n, (_) => List.filled(n, 32767));'
            : 'final first = List<ArcNode?>.filled(n, null);',
        'for (final (i, j, w) in edges) {',
        matrix
            ? '  a[i][j] = w; ${mirror ? 'a[j][i] = w; ' : ''}}'
            : '  first[i] = ArcNode(j, first[i]); ${mirror ? 'first[j] = ArcNode(i, first[j]); ' : ''}}',
        matrix ? 'return a;' : 'return first;',
      ],
    };
    final b = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${kind.label} · ${input.vertices.length} 个顶点 · ${input.arcs.length} 条边',
      codeLines: code,
    );
    void frame(
      int count,
      List<int> lines,
      String title,
      String explanation, {
      GraphArc? edge,
    }) {
      final storage = GraphStorage(input, count);
      final scene = graphScene(input, storage);
      b.step(
        title: title,
        explain: explanation,
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        vars: {
          '已录入': '$count',
          '图类型': kind.label,
          if (edge != null) ...{
            'i': '${input.vertices.indexWhere((v) => v.id == edge.tail)}',
            'j': '${input.vertices.indexWhere((v) => v.id == edge.head)}',
            if (matrix) 'w': '${edge.weight}',
          },
        },
        scene: scene.copyWith(
          auxTables: [
            AuxTableSnapshot(
              id: 'vertices',
              title: '顶点表',
              columns: ['下标', '顶点', matrix ? '矩阵行' : 'firstarc（邻接点）'],
              rows: [
                for (final (i, v) in input.vertices.indexed)
                  [
                    '$i',
                    v.id,
                    matrix
                        ? [
                            for (final w in input.vertices)
                              storage.cells[(v.id, w.id)]?.weight.toString() ??
                                  '∞',
                          ].join('  ')
                        : storage.chain(v.id).firstOrNull?.vertex ?? '∅',
                  ],
              ],
            ),
          ],
        ),
        milestone: true,
      );
    }

    frame(
      0,
      [1, 2],
      '$name · 初始化',
      matrix ? '无边单元填 ∞，包括没有自环的对角线。' : '每个顶点的 firstarc 从空指针开始。',
    );
    for (final (i, e) in input.arcs.indexed) {
      frame(
        i + 1,
        [3, 4],
        '录入 ${e.tail}${kind.directed ? ' → ' : ' — '}${e.head}',
        matrix
            ? '写入权值 ${e.weight}。${mirror ? '无向网同步写入对称单元。' : ''}'
            : '将邻接点插到链首。${mirror ? '无向边在两个端点各插入一个边结点。' : ''}',
        edge: e,
      );
    }
    frame(input.arcs.length, [5], '$name · 建表完成', '四种表示按同一组顶点和边更新。');
    return b.build();
  }
}
