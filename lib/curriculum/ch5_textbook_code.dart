import 'dart:math';
import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

// Null slots in the fixture are absent children. Child indices are 2i+1 and 2i+2.
const _treeC = r'''
#include <stddef.h>
typedef struct Node {
    int data;
    struct Node *left, *right;
} Node;
''';
const _treeDart = r'''
class Node {
  Node(this.value, this.left, this.right);
  final int value;
  Node? left, right;
}

Node? tree(List slots, [int i = 0]) {
  if (i >= slots.length || slots[i] == null) return null;
  return Node(slots[i] as int, tree(slots, 2 * i + 1), tree(slots, 2 * i + 2));
}
''';

final _rng = Random(503);
final _trees = <List<int?>>[
  [1, 2, 3, null, 4, 5],
  [],
  [9],
  [7, 7, 7],
  [1, null, 2, null, null, 3],
  List.generate(127, (_) => _rng.nextInt(101) - 50),
];
const _names = ['左右稀疏树', '空树', '只有根', '全重复值', '只有一侧子树', '固定种子七层树'];
List<AlgorithmTestCase> _fixtures(Object Function(List<int?> a) expected) => [
  for (final (i, a) in _trees.indexed)
    AlgorithmTestCase(
      name: _names[i],
      input: {'tree': a},
      expected: expected(a),
    ),
];
bool _present(List<int?> a, int i) => i < a.length && a[i] != null;
Iterable<int> _leaves(List<int?> a) => [
  for (var i = 0; i < a.length; i++)
    if (_present(a, i) && !_present(a, 2 * i + 1) && !_present(a, 2 * i + 2)) i,
];
List<int> _path(List<int?> a, int i) {
  final out = [a[i]!];
  while (i > 0) {
    i = (i - 1) ~/ 2;
    out.add(a[i]!);
  }
  return out;
}

// Lexicographic binary positions (left before right) give DFS leaf order.
List<int> _leftFirstLeaves(List<int?> a) => _leaves(a).toList()
  ..sort(
    (x, y) => (x + 1).toRadixString(2).compareTo((y + 1).toRadixString(2)),
  );
Object _longest(List<int?> a) {
  if (a.isEmpty) return {'edges': 0, 'path': []};
  final deepest = _leaves(a).map((i) => (i + 1).bitLength).reduce(max);
  final first = _leaves(a).firstWhere((i) => (i + 1).bitLength == deepest);
  return {'edges': deepest - 1, 'path': _path(a, first).reversed.toList()};
}

List<int?> _mirrored(List<int?> a) {
  final out = <int?>[];
  for (var i = 0; i < a.length; i++) {
    if (a[i] == null) continue;
    final start = (1 << ((i + 1).bitLength - 1)) - 1;
    final j = start * 3 - i;
    while (out.length <= j) {
      out.add(null);
    }
    out[j] = a[i];
  }
  return out;
}

int _width(List<int?> a) {
  final counts = <int, int>{};
  for (var i = 0; i < a.length; i++) {
    if (a[i] != null) {
      counts.update((i + 1).bitLength, (x) => x + 1, ifAbsent: () => 1);
    }
  }
  return counts.values.fold(0, max);
}

List<int> _doubleOrder(List<int?> a) {
  // Read the two visits from an explicit event stack, independently of the recursive reference.
  final events = <int>[], pending = <int>[1];
  while (pending.isNotEmpty) {
    final ticket = pending.removeLast(), i = ticket.abs() - 1;
    if (!_present(a, i)) continue;
    events.add(a[i]!);
    if (ticket > 0) {
      pending.addAll([-(i + 1), 2 * i + 2]);
    } else {
      pending.add(2 * i + 3);
    }
  }
  return events;
}

AlgorithmTestCase _pair(
  String name,
  List<int?> a,
  List<int?> b,
  bool expected,
) => AlgorithmTestCase(
  name: name,
  input: {'tree': a, 'other': b},
  expected: expected,
);

final ch5TextbookCode = List<CodeQuestion>.unmodifiable([
  textbookDesign(
    ChapterId.ch5,
    3,
    1,
    page: 147,
    title: "统计叶子",
    topic: "统计叶子",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

统计二叉树的叶结点个数。''',
    explanation: r'''空树返回 0，没有左右孩子的非空结点贡献 1，其他结点的结果为左右子树之和。时间 O(n)，递归栈 O(h)。''',
    template:
        _treeC +
        r'''size_t leaves(const Node *p) {
    if (!p) return 0;
    if (/*BLANK_1*/) return 1;
    return leaves(p->left) + /*BLANK_2*/;
}''',
    answers: [r'''!p->left && !p->right''', r'''leaves(p->right)'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  int leaves(Node? p) {
    if (p == null) return 0;
    if (p.left == null && p.right == null) return 1;
    return leaves(p.left) + leaves(p.right);
  }

  return leaves(tree(input['tree']));
}''',
    cases: _fixtures((a) => _leaves(a).length),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    2,
    page: 147,
    title: "判断两树相等",
    topic: "判断两树相等",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

判别两棵树是否相等。''',
    explanation:
        r'''结构和对应结点的数据都相等才返回真。两个空位置相等，只有一侧为空时立即返回假。最坏时间 O(n)，递归栈 O(h)。''',
    template:
        _treeC +
        r'''int equal(const Node *a, const Node *b) {
    if (!a || !b) return /*BLANK_1*/;
    return a->data==b->data && equal(a->left,b->left) && /*BLANK_2*/;
}''',
    answers: [r'''a == b''', r'''equal(a->right,b->right)'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  bool equal(Node? a, Node? b) {
    if (a == null || b == null) return a == b;
    return a.value == b.value &&
        equal(a.left, b.left) &&
        equal(a.right, b.right);
  }

  return equal(tree(input['tree']), tree(input['other']));
}''',
    cases: [
      _pair('独立同值同形树', _trees[0], _trees[0], true),
      _pair('两棵空树', [], [], true),
      _pair('仅一边有根', [1], [], false),
      _pair('重复值但分支方向不同', [7, 7], [7, null, 7], false),
      _pair('右端数值不同', [1, null, 2], [1, null, 3], false),
      _pair('固定种子末叶不同', _trees.last, [..._trees.last.take(126), 999], false),
    ],
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    3,
    page: 147,
    title: "原地交换左右子树",
    topic: "原地交换左右子树",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

交换二叉树每个结点的左孩子和右孩子。''',
    explanation:
        r'''在同一结点上交换两个孩子指针，再分别处理交换后的两个分支。结点身份和值保持，反转两次恢复原树。时间 O(n)，栈 O(h)。''',
    template:
        _treeC +
        r'''void mirror(Node *p) {
    if (!p) return;
    Node *saved=p->left;
    p->left=/*BLANK_1*/;
    p->right=/*BLANK_2*/;
    mirror(p->left);
    mirror(p->right);
}''',
    answers: [r'''p->right''', r'''saved'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final root = tree(input['tree']);
  void mirror(Node? p) {
    if (p == null) return;
    final saved = p.left;
    p.left = p.right;
    p.right = saved;
    mirror(p.left);
    mirror(p.right);
  }

  mirror(root);
  final result = <int?>[];
  void emit(Node? n, int i) {
    if (n == null) return;
    while (result.length <= i) {
      result.add(null);
    }
    result[i] = n.value;
    emit(n.left, 2 * i + 1);
    emit(n.right, 2 * i + 2);
  }

  emit(root, 0);
  return result;
}''',
    cases: _fixtures(_mirrored),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    4,
    page: 148,
    title: "双序遍历",
    topic: "双序遍历",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

设计二叉树的双序遍历算法（双序遍历是指对于二叉树的每一个结点来说，先访问这个结点，再按双序遍历它的左子树，然后再一次访问这个结点，接下来按双序遍历它的右子树）。''',
    explanation: r'''同一结点分别在进入和左子树返回时输出一次，叶子也输出两次。时间 O(n)，栈 O(h)。''',
    template:
        _treeC +
        r'''void double_order(const Node *p, void (*visit)(int)) {
    if (!p) return;
    visit(p->data);
    double_order(/*BLANK_1*/,visit);
    /*BLANK_2*/;
    double_order(p->right,visit);
}''',
    answers: [r'''p->left''', r'''visit(p->data)'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final out = <int>[];
  void walk(Node? p) {
    if (p == null) return;
    out.add(p.value);
    walk(p.left);
    out.add(p.value);
    walk(p.right);
  }

  walk(tree(input['tree']));
  return out;
}''',
    cases: _fixtures(_doubleOrder),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    5,
    page: 148,
    title: "二叉树最大宽度",
    topic: "二叉树最大宽度",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

计算二叉树最大的宽度（二叉树的最大宽度是指二叉树所有层中结点个数的最大值）。''',
    explanation:
        r'''按层入队。在处理本层前固定队尾，本层宽度等于尚未出队的结点数。空孩子不入队。C 的调用者提供容纳总结点数的顺序队列。时间 O(n)。''',
    template:
        _treeC +
        r'''size_t width(const Node *root, const Node **queue) {
    if (!root) return 0;
    size_t head=0,tail=0,best=0;
    queue[tail++]=root;
    while (head<tail) {
        size_t end=tail, level=/*BLANK_1*/;
        if (level>best) best=level;
        while (/*BLANK_2*/) {
            const Node *p=queue[head++];
            if (p->left) queue[tail++]=p->left;
            if (p->right) queue[tail++]=p->right;
        }
    }
    return best;
}''',
    answers: [r'''end - head''', r'''head < end'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final root = tree(input['tree']);
  if (root == null) return 0;
  final queue = [root];
  var head = 0, best = 0;
  while (head < queue.length) {
    final end = queue.length, level = end - head;
    if (level > best) best = level;
    while (head < end) {
      final p = queue[head++];
      if (p.left != null) queue.add(p.left!);
      if (p.right != null) queue.add(p.right!);
    }
  }
  return best;
}''',
    cases: _fixtures(_width),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    6,
    page: 148,
    title: "层序统计度为一的结点",
    topic: "层序统计度为一的结点",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

用按层次顺序遍历二叉树的方法，统计树中度为 1 的结点数目。''',
    explanation:
        r'''队列从根开始，只入队实际存在的孩子。左右指针恰有一个为空时计数加一。时间 O(n)，调用者为 C 入口提供容量至少为总结点数的队列。''',
    template:
        _treeC +
        r'''size_t degree_one(const Node *root, const Node **queue) {
    if (!root) return 0;
    size_t head=0,tail=0,total=0;
    queue[tail++]=root;
    while (head<tail) {
        const Node *p=queue[/*BLANK_1*/];
        if (/*BLANK_2*/) ++total;
        if (p->left) queue[tail++]=p->left;
        if (p->right) queue[tail++]=p->right;
    }
    return total;
}''',
    answers: [r'''head++''', r'''(p->left == NULL) != (p->right == NULL)'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final root = tree(input['tree']);
  if (root == null) return 0;
  final queue = [root];
  var total = 0;
  for (var i = 0; i < queue.length; i++) {
    final p = queue[i];
    if ((p.left == null) != (p.right == null)) total++;
    if (p.left != null) queue.add(p.left!);
    if (p.right != null) queue.add(p.right!);
  }
  return total;
}''',
    cases: _fixtures(
      (a) => [
        for (var i = 0; i < a.length; i++)
          if (_present(a, i) &&
              _present(a, 2 * i + 1) != _present(a, 2 * i + 2))
            i,
      ].length,
    ),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    7,
    page: 148,
    title: "第一条最长路径",
    topic: "第一条最长路径",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

求任意二叉树中第一条最长的路径长度，并输出此路径上各结点的值。''',
    explanation:
        r'''按从根至叶、先左后右的顺序解释“第一条”。长度以边数计，单结点树长为 0；空树约定长为 0 且路径为空。先求树高，第二遍先左后右搜索第一个达到该高度的叶子，命中后立即返回。总时间 O(n)，路径缓冲区和递归栈 O(h)。''',
    template:
        _treeC +
        r'''static size_t height(const Node *p) {
    if (!p) return 0;
    size_t l=height(p->left), r=height(p->right);
    return 1+(l>r?l:r);
}
static int first_deep(const Node *p, size_t level, size_t h, int path[]) {
    if (!p) return 0;
    path[level]=p->data;
    if (/*BLANK_1*/) return 1;
    return first_deep(p->left,level+1,h,path) || /*BLANK_2*/;
}
/* path has capacity h; count receives its number of values. */
size_t longest(const Node *root, int path[], size_t *count) {
    *count=height(root);
    if (!*count) return 0;
    first_deep(root,0,*count,path);
    return *count-1;
}''',
    answers: [
      r'''level + 1 == h''',
      r'''first_deep(p->right,level+1,h,path)''',
    ],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final root = tree(input['tree']);
  int height(Node? p) {
    if (p == null) return 0;
    final l = height(p.left), r = height(p.right);
    return 1 + (l > r ? l : r);
  }

  final h = height(root), path = <int>[];
  bool find(Node? p) {
    if (p == null) return false;
    path.add(p.value);
    if (path.length == h || find(p.left) || find(p.right)) return true;
    path.removeLast();
    return false;
  }

  find(root);
  return {'edges': h == 0 ? 0 : h - 1, 'path': path};
}''',
    cases: _fixtures(_longest),
  ),
  textbookDesign(
    ChapterId.ch5,
    3,
    8,
    page: 148,
    title: "从每个叶子输出至根的路径",
    topic: "从每个叶子输出至根的路径",
    prompt: r'''以二叉链表作为二叉树的存储结构，编写以下算法：

输出二叉树中从每个叶子结点到根结点的路径。''',
    explanation:
        r'''按左、右子树顺序深搜，用工作数组保存当前根到访问结点的路径。每到叶子，从当前位置倒序输出至根。时间为 O(n+所有输出的总长度)，辅助空间 O(h)。''',
    template:
        _treeC +
        r'''#include <stdio.h>
void leaf_paths(const Node *p, int path[], size_t depth, FILE *out) {
    if (!p) return;
    path[depth]=p->data;
    if (/*BLANK_1*/) {
        for (size_t j=depth+1; j>0; --j)
            fprintf(out,"%d%c",path[/*BLANK_2*/],j==1?'\n':' ');
    } else {
        leaf_paths(p->left,path,depth+1,out);
        leaf_paths(p->right,path,depth+1,out);
    }
}''',
    answers: [r'''!p->left && !p->right''', r'''j - 1'''],
    dart:
        _treeDart +
        r'''Object solve(Map<String, dynamic> input) {
  final path = <int>[], out = <List<int>>[];
  void walk(Node? p) {
    if (p == null) return;
    path.add(p.value);
    if (p.left == null && p.right == null) {
      out.add(path.reversed.toList());
    } else {
      walk(p.left);
      walk(p.right);
    }
    path.removeLast();
  }

  walk(tree(input['tree']));
  return out;
}''',
    cases: _fixtures(
      (a) => [for (final leaf in _leftFirstLeaves(a)) _path(a, leaf)],
    ),
  ),
]);
