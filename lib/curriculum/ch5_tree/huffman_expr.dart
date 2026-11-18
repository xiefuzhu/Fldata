import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../ch3_stack_queue/cases_expr_dance.dart';
import 'huffman_tree.dart';

part 'expression_tree.dart';
part 'huffman_source.dart';

enum TreeApplication { construction, decode, expression }

class ApplicationInput {
  const ApplicationInput({
    this.mode = TreeApplication.construction,
    this.weights = textbookWeights,
    this.message = 'abcdefgh',
    this.expression = '3*(7-2)#',
  });
  final TreeApplication mode;
  final Map<String, int> weights;
  final String message, expression;
  ApplicationInput withMode(
    TreeApplication mode, {
    String? message,
    String? expression,
    Map<String, int>? weights,
  }) => ApplicationInput(
    mode: mode,
    weights: weights ?? this.weights,
    message: message ?? this.message,
    expression: expression ?? this.expression,
  );
}

Map<String, int> parseWeights(String input) {
  final weights = <String, int>{};
  for (final item in input.trim().split(RegExp(r'[\s,，]+'))) {
    final parts = item.split(':');
    final w = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (w == null || w <= 0 || parts[0].runes.length != 1) {
      throw const FormatException('请按 a:5 b:29 的形式填写字符和正整数权值。');
    }
    if (weights.containsKey(parts[0])) {
      throw FormatException('字符「${parts[0]}」出现了两次。');
    }
    weights[parts[0]] = w;
  }
  if (weights.length < 2) throw const FormatException('至少需要两个字符。');
  return weights;
}

class HuffmanExprModule implements AlgorithmModule<ApplicationInput> {
  const HuffmanExprModule();
  @override
  String get id => 'ch5_huffman_expr';
  @override
  List<AlgorithmPreset<ApplicationInput>> get presets => const [
    AlgorithmPreset(
      id: 'book',
      name: '例 5.2 · 八个权值',
      input: ApplicationInput(),
    ),
    AlgorithmPreset(
      id: 'ties',
      name: '四个等权字符',
      input: ApplicationInput(
        weights: {'a': 1, 'b': 1, 'c': 1, 'd': 1},
        message: 'abcd',
      ),
    ),
    AlgorithmPreset(
      id: 'expr',
      name: '表达式树 · 3*(7-2)#',
      input: ApplicationInput(mode: TreeApplication.expression),
    ),
  ];
  @override
  ValidationResult<ApplicationInput> validateInput(String raw) {
    try {
      return ValidationResult.success(
        ApplicationInput(weights: parseWeights(raw), message: ''),
      );
    } on FormatException catch (e) {
      return ValidationResult.failure(e.message);
    }
  }

  @override
  TraceTimeline generateTrace(ApplicationInput input) {
    if (input.mode == TreeApplication.expression) {
      return _expressionTrace(input.expression);
    }
    final building = input.mode == TreeApplication.construction;
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: building
          ? '哈夫曼树 · ${input.weights.length} 个字符'
          : input.message,
      codeLines: building ? _buildSource : _decodeSource,
    );
    void frame(
      HuffmanTree tree,
      int line,
      String title,
      String explanation, {
      Set<int> candidates = const {},
      Set<int> active = const {},
      int leaf = 0,
      String path = '',
      Map<String, String> extra = const {},
      int? from,
      int? to,
    }) {
      final ht = tree.table;
      final occupied = ht.length - 1;
      final nodes = [
        for (var i = 1; i <= occupied; i++)
          SceneNode(
            id: 'h$i',
            label: ht[i].symbol == null
                ? '${ht[i].weight}'
                : '${ht[i].symbol} · ${ht[i].weight}',
            indexBadge: '$i',
            x: 0,
            y: 0,
            width: 78,
            height: 44,
            visualState: active.contains(i)
                ? NodeVisualState.active
                : candidates.contains(i)
                ? NodeVisualState.comparing
                : NodeVisualState.normal,
          ),
      ];
      final edges = <SceneEdge>[];
      for (var i = tree.count + 1; i <= occupied; i++) {
        for (final (c, right) in [(ht[i].left, false), (ht[i].right, true)]) {
          edges.add(
            SceneEdge(
              id: 'h$i-$c',
              fromNodeId: 'h$i',
              toNodeId: 'h$c',
              fromPort: right ? EdgePort.rchild : EdgePort.lchild,
              weightLabel: right ? '1' : '0',
              visualState: (from == i && to == c)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
          );
        }
      }
      final tables = [
        AuxTableSnapshot(
          id: 'ht',
          title: 'HT[1..${2 * tree.count - 1}]',
          columns: const ['i', 'weight', 'parent', 'lchild', 'rchild'],
          rows: [
            for (var i = 1; i < 2 * tree.count; i++)
              i <= occupied
                  ? [
                      '$i',
                      '${ht[i].weight}',
                      '${ht[i].parent}',
                      '${ht[i].left}',
                      '${ht[i].right}',
                    ]
                  : ['$i', '—', '0', '0', '0'],
          ],
          highlightedRows: {for (final i in candidates) i - 1},
        ),
        AuxTableSnapshot(
          id: 'hc',
          title: 'HC · 前缀编码表',
          columns: const ['i', '字符', '编码'],
          rows: [
            for (var i = 1; i <= tree.count; i++)
              [
                '$i',
                ht[i].symbol!,
                tree.codes[ht[i].symbol] ?? (leaf == i ? path : ''),
              ],
          ],
          highlightedRows: leaf == 0 ? {} : {leaf - 1},
        ),
      ];
      builder.step(
        title: title,
        explain: explanation,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        scene: TreeReingoldLayout.arrange(
          SceneSnapshot(nodes: nodes, edges: edges, auxTables: tables),
        ),
        vars: {
          'WPL': '${tree.wpl}',
          if (tree.codes.length == tree.count) '树高': '${tree.height}',
          ...extra,
        },
        milestone: true,
      );
    }

    if (building) {
      HuffmanTree.build(
        input.weights,
        initialized: (t) =>
            frame(t, 1, '初始化 HT', '前 n 行存放叶结点，后 n−1 行留给合并产生的双亲。'),
        selected: (t, c, a, b) => frame(
          t,
          2,
          '选择两个最小根',
          '琥珀色行均为已占用且 parent 为 0 的候选。选取权值最小的两个根，将下标较小者放在左边。',
          candidates: c,
          active: {a, b},
          extra: {'s1': '$a', 's2': '$b'},
        ),
        merged: (t, p) => frame(
          t,
          3,
          '合并至 HT[$p]',
          '两个孩子写入双亲下标。新根权重 ${t.table[p].weight} 加入 WPL。',
          active: {p},
          extra: {'i': '$p'},
        ),
        ascended: (t, l, c, p, s) => frame(
          t,
          4,
          '从叶子回溯编码',
          'HT[$c] 是 HT[$p] 的${t.table[p].left == c ? "左" : "右"}孩子；从码字左端补入 ${s[0]}。',
          active: {c, p},
          leaf: l,
          path: s,
          from: p,
          to: c,
          extra: {'片段': s},
        ),
        coded: (t, l) => frame(
          t,
          5,
          '写入 HC[$l]',
          '字符 ${t.table[l].symbol} 的码字为 ${t.codes[t.table[l].symbol]}。',
          active: {l},
          leaf: l,
        ),
      );
    } else {
      final t = HuffmanTree.build(input.weights),
          bits = t.encode(input.message);
      frame(
        t,
        1,
        '从根开始译码',
        '读取一位就沿一条边移动。抵达叶子时输出字符，并从根继续。',
        active: {t.root},
        extra: {'位序': '0', '输出': '', '比特流': bits},
      );
      final output = t.decode(
        bits,
        step: (i, p, c, out) => frame(
          t,
          2,
          t.table[c].symbol == null
              ? '沿 ${bits[i]} 走树'
              : '抵达叶子 ${t.table[c].symbol}',
          '第 ${i + 1} 位为 ${bits[i]}，从 HT[$p] 走到 HT[$c]。${t.table[c].symbol == null ? "" : "输出叶子字符，下一位从根出发。"}',
          active: {c},
          from: p,
          to: c,
          extra: {'位序': '${i + 1}', '输出': out, '比特流': bits},
        ),
      );
      frame(
        t,
        3,
        '译码结束',
        '所有码字已读完，游标回到根。',
        active: {t.root},
        extra: {'位序': '${bits.length}', '输出': output, '比特流': bits},
      );
    }
    return builder.build();
  }
}
