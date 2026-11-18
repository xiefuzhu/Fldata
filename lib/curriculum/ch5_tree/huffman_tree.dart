/// Indices 1..n are leaves. Index 0 is the textbook's null link.
class HTNode {
  HTNode(this.weight, {this.symbol, this.left = 0, this.right = 0});
  final BigInt weight;
  final int left, right;
  final String? symbol;
  int parent = 0;
}

const textbookWeights = {
  'a': 5,
  'b': 29,
  'c': 7,
  'd': 8,
  'e': 14,
  'f': 23,
  'g': 3,
  'h': 11,
};

class HuffmanTree {
  HuffmanTree._(this.count, this.table);
  final int count;
  final List<HTNode> table;
  final codes = <String, String>{};
  BigInt wpl = BigInt.zero;
  int get root => table.length - 1;
  int get height =>
      1 + codes.values.fold(0, (m, c) => c.length > m ? c.length : m);
  int get fixedWidth => (count - 1).bitLength;

  static HuffmanTree build(
    Map<String, int> weights, {
    void Function(HuffmanTree tree)? initialized,
    void Function(HuffmanTree tree, Set<int> candidates, int left, int right)?
    selected,
    void Function(HuffmanTree tree, int parent)? merged,
    void Function(
      HuffmanTree tree,
      int leaf,
      int child,
      int parent,
      String prefix,
    )?
    ascended,
    void Function(HuffmanTree tree, int leaf)? coded,
  }) {
    if (weights.length < 2 ||
        weights.entries.any((e) => e.key.runes.length != 1 || e.value <= 0)) {
      throw const FormatException('需要至少两个不同的字符，每个字符配一个正整数权值。');
    }
    final tree = HuffmanTree._(weights.length, [
      HTNode(BigInt.zero),
      for (final e in weights.entries)
        HTNode(BigInt.from(e.value), symbol: e.key),
    ]);
    final ht = tree.table;
    initialized?.call(tree);
    // Scan once per merge. Stable selection breaks equal weights by index.
    while (ht.length < 2 * weights.length) {
      var s1 = 0, s2 = 0;
      final candidates = <int>{};
      for (var i = 1; i < ht.length; i++) {
        if (ht[i].parent != 0) continue;
        candidates.add(i);
        if (s1 == 0 || ht[i].weight < ht[s1].weight) {
          s2 = s1;
          s1 = i;
        } else if (s2 == 0 || ht[i].weight < ht[s2].weight) {
          s2 = i;
        }
      }
      // Table 5.2 places the smaller selected index on the left.
      if (s2 < s1) {
        final temp = s1;
        s1 = s2;
        s2 = temp;
      }
      selected?.call(tree, candidates, s1, s2);
      final parent = ht.length;
      final weight = ht[s1].weight + ht[s2].weight;
      ht[s1].parent = ht[s2].parent = parent;
      ht.add(HTNode(weight, left: s1, right: s2));
      tree.wpl += weight;
      merged?.call(tree, parent);
    }
    for (var leaf = 1; leaf <= weights.length; leaf++) {
      var code = '';
      for (var c = leaf; ht[c].parent != 0;) {
        final p = ht[c].parent;
        code = (ht[p].left == c ? '0' : '1') + code;
        ascended?.call(tree, leaf, c, p, code);
        c = p;
      }
      tree.codes[ht[leaf].symbol!] = code;
      coded?.call(tree, leaf);
    }
    return tree;
  }

  String encode(String plain) {
    final bits = StringBuffer();
    for (final char in plain.runes) {
      final symbol = String.fromCharCode(char), code = codes[symbol];
      if (code == null) throw FormatException('字符「$symbol」不在当前编码表中。');
      bits.write(code);
    }
    return bits.toString();
  }

  String decode(
    String bits, {
    void Function(int pos, int parent, int child, String output)? step,
  }) {
    final output = StringBuffer();
    var current = root;
    for (var i = 0; i < bits.length; i++) {
      final bit = bits[i], p = current;
      if (bit != '0' && bit != '1') {
        throw FormatException('第 ${i + 1} 位需要 0 或 1。');
      }
      current = bit == '0' ? table[p].left : table[p].right;
      final symbol = table[current].symbol;
      if (symbol != null) output.write(symbol);
      step?.call(i, p, current, output.toString());
      if (symbol != null) current = root;
    }
    if (current != root) throw const FormatException('比特流在一个码字中途结束。');
    return output.toString();
  }
}
