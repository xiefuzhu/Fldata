import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'bitree_traverse.dart';

const textbookForest = 'A(B,C,D),E(F),G(H,I(J))';

class ForestNode {
  ForestNode(this.label, this.children);
  final String label;
  final List<ForestNode> children;
  String get expression => children.isEmpty
      ? label
      : '$label(${children.map((n) => n.expression).join(",")})';
}

List<ForestNode> parseForest(String raw) {
  final tokens = raw
      .replaceAll(RegExp(r'\s+'), '')
      .runes
      .map(String.fromCharCode)
      .toList();
  if (tokens.isEmpty || (tokens.length == 1 && tokens.first == '#')) return [];
  var at = 0;
  String? peek() => at < tokens.length ? tokens[at] : null;
  List<ForestNode> group() {
    final nodes = <ForestNode>[];
    do {
      final label = peek();
      if (label == null || '(),#'.contains(label)) {
        throw FormatException('第 ${at + 1} 位需要结点名。');
      }
      at++;
      var children = <ForestNode>[];
      if (peek() == '(') {
        at++;
        children = group();
        if (peek() != ')') throw FormatException('第 ${at + 1} 位缺少右括号。');
        at++;
      }
      nodes.add(ForestNode(label, children));
      if (peek() != ',') return nodes;
      at++;
    } while (true);
  }

  final roots = group();
  if (at != tokens.length) throw FormatException('第 ${at + 1} 位需要逗号或表达式结尾。');
  return roots;
}

// A right chain is a group of siblings, including the roots of a forest.
List<ForestNode> forestFromBinary(BinaryNode? first) {
  final siblings = <ForestNode>[];
  for (var n = first; n != null; n = n.right) {
    if ('(),'.contains(n.label)) {
      throw const FormatException('森林表达式保留逗号和括号，请使用其他结点名。');
    }
    siblings.add(ForestNode(n.label, forestFromBinary(n.left)));
  }
  return siblings;
}

String forestBinarySequence(List<ForestNode> forest) {
  final out = StringBuffer();
  void chain(List<ForestNode> group) {
    for (final n in group) {
      out.write(n.label);
      chain(n.children);
    }
    out.write('#');
  }

  chain(forest);
  return out.toString();
}

class ForestModule implements AlgorithmModule<TreeInput> {
  const ForestModule();
  @override
  String get id => 'ch5_tree_forest_conv';
  @override
  List<AlgorithmPreset<TreeInput>> get presets => const [
    AlgorithmPreset(
      id: 'forest',
      name: '图 5.24 · 三棵树的森林',
      input: TreeInput(sequence: textbookForest),
    ),
    AlgorithmPreset(
      id: 'tree',
      name: '图 5.19 · 一棵树',
      input: TreeInput(sequence: 'R(A(D,E),B,C(F(G,H,K)))'),
    ),
    AlgorithmPreset(
      id: 'roots',
      name: '只有根的森林',
      input: TreeInput(sequence: 'A,B,C'),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '空森林',
      input: TreeInput(sequence: '#'),
    ),
  ];
  @override
  ValidationResult<TreeInput> validateInput(String raw) {
    try {
      final forest = parseForest(raw);
      return ValidationResult.success(
        TreeInput(
          sequence: forest.isEmpty
              ? '#'
              : forest.map((n) => n.expression).join(','),
        ),
      );
    } on FormatException catch (e) {
      return ValidationResult.failure(e.message);
    }
  }

  @override
  TraceTimeline generateTrace(TreeInput input) {
    final roots = parseForest(input.sequence);
    final nodes = [...roots], parent = <ForestNode, ForestNode>{};
    for (var i = 0; i < nodes.length; i++) {
      for (final c in nodes[i].children) {
        parent[c] = nodes[i];
        nodes.add(c);
      }
    }
    final index = {for (final (i, n) in nodes.indexed) n: i};
    String address(ForestNode? node) => node == null ? '∅' : '${index[node]}';
    final next = <ForestNode, ForestNode>{};
    for (final group in [roots, ...nodes.map((n) => n.children)]) {
      for (var i = 1; i < group.length; i++) {
        next[group[i - 1]] = group[i];
      }
    }
    final tables = [
      AuxTableSnapshot(
        id: 'parent',
        title: '双亲表示法 · PTree',
        columns: const ['下标', 'data', 'parent'],
        rows: [
          for (final n in nodes)
            [address(n), n.label, '${index[parent[n]] ?? -1}'],
        ],
      ),
      AuxTableSnapshot(
        id: 'children',
        title: '孩子链表',
        columns: const ['下标', 'data', '孩子下标链'],
        rows: [
          for (final n in nodes)
            [
              address(n),
              n.label,
              [...n.children.map(address), '∅'].join(' → '),
            ],
        ],
      ),
      AuxTableSnapshot(
        id: 'siblings',
        title: '孩子兄弟表示法 · CSTree',
        columns: const ['下标', 'data', 'firstchild', 'nextsibling'],
        rows: [
          for (final n in nodes)
            [
              address(n),
              n.label,
              address(n.children.firstOrNull),
              address(next[n]),
            ],
        ],
      ),
    ];
    SceneEdge edge(ForestNode a, ForestNode b, EdgePort port) => SceneEdge(
      id: '${address(a)}>${address(b)}',
      fromNodeId: address(a),
      toNodeId: address(b),
      fromPort: port,
      visualState: port == EdgePort.rchild
          ? NodeVisualState.comparing
          : NodeVisualState.normal,
    );
    final first = [
      for (final n in nodes)
        if (n.children.isNotEmpty) edge(n, n.children.first, EdgePort.lchild),
    ];
    final other = [
      for (final n in nodes)
        for (final c in n.children.skip(1)) edge(n, c, EdgePort.auto),
    ];
    final siblings = [
      for (final e in next.entries) edge(e.key, e.value, EdgePort.rchild),
    ];
    final base = SceneSnapshot(
      nodes: [
        for (final n in nodes)
          SceneNode(
            id: address(n),
            label: n.label,
            indexBadge: address(n),
            x: 0,
            y: 0,
            width: 48,
            height: 48,
            shape: NodeShape.circle,
          ),
      ],
      auxTables: tables,
    );
    // Keep the source order when arranging the original multiway forest.
    final forest = TreeReingoldLayout.arrange(
      base.copyWith(
        edges: [
          for (final n in nodes)
            for (final c in n.children)
              edge(
                n,
                c,
                c == n.children.first ? EdgePort.lchild : EdgePort.auto,
              ),
        ],
      ),
      roots: roots.map(address).toList(),
      levelGap: 36,
    );
    final binary = TreeReingoldLayout.arrange(
      base.copyWith(edges: [...first, ...siblings]),
      levelGap: 36,
      slantSingleChild: true,
    );
    final forestPre = StringBuffer(),
        forestPost = StringBuffer(),
        binaryPre = StringBuffer(),
        binaryIn = StringBuffer();
    void visitTree(ForestNode n) {
      forestPre.write(n.label);
      for (final c in n.children) {
        visitTree(c);
      }
      forestPost.write(n.label);
    }

    void visitBinary(ForestNode? n) {
      if (n == null) return;
      binaryPre.write(n.label);
      visitBinary(n.children.firstOrNull);
      binaryIn.write(n.label);
      visitBinary(next[n]);
    }

    roots.forEach(visitTree);
    visitBinary(roots.firstOrNull);
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: input.sequence,
      codeLines: _conversionSource,
    );
    final scenes = [
      forest,
      forest.copyWith(edges: [...first, ...other, ...siblings]),
      forest.copyWith(edges: [...first, ...siblings]),
      binary,
    ];
    const titles = ['原始森林', '加线 · 连相邻兄弟', '去线 · 保留长子', '旋转 45° · 二叉树'];
    const details = [
      '按从左到右的顺序排列各棵树和每个结点的孩子。',
      '金色连接指向右兄弟，各棵树的根也依次相连。',
      '每个双亲仅保留到第一个孩子的连线，其他孩子可沿兄弟链到达。',
      '左子树表示第一个孩子，右子树表示下一个兄弟。沿根的右链可逐棵还原森林。',
    ];
    for (var i = 0; i < scenes.length; i++) {
      final line = [1, 3, 4, 5][i];
      builder.step(
        title: titles[i],
        explain: details[i],
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        scene: scenes[i],
        milestone: true,
        vars: {
          '根数': '${roots.length}',
          '森林先序': '$forestPre',
          '森林中序': '$forestPost',
          '二叉先序': '$binaryPre',
          '二叉中序': '$binaryIn',
        },
      );
    }
    return builder.build();
  }
}

const _conversionSource = {
  CodeLang.cLike: [
    'ForestToBinary(roots):',
    '  for each group in [roots, each child list]:',
    '    link adjacent nodes with nextsibling; end with NULL',
    '  for each node: set firstchild to its first child, or NULL',
    '  return first root  // left = firstchild, right = nextsibling',
  ],
  CodeLang.c99: [
    'CSNode *convert(List roots, List all[], int n) {',
    '  for (int i = -1; i < n; ++i) { List g = i < 0 ? roots : all[i];',
    '    for (int j=0; j<g.len; ++j) g.v[j]->nextsibling = j+1<g.len ? g.v[j+1] : NULL;',
    '    if (i >= 0) all[i].owner->firstchild = g.len ? g.v[0] : NULL; }',
    '  return roots.len ? roots.v[0] : NULL; }',
  ],
  CodeLang.dart: [
    'Node? convert(List<Node> roots, List<Node> nodes) {',
    '  for (final group in [roots, ...nodes.map((n) => n.children)]) {',
    '    for (var j=0; j<group.length; j++) { group[j].right = j+1<group.length ? group[j+1] : null; } }',
    '  for (final n in nodes) { n.left = n.children.firstOrNull; }',
    '  return roots.firstOrNull; }',
  ],
};
