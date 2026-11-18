part of 'ch2_textbook_code.dart';

typedef _Solution = ({
  String template,
  List<String> answers,
  String dart,
  String explanation,
});

const _split = (
  explanation:
      'B 沿用 A 的头结点，C 使用一个空头结点。先保存当前数据结点的后继，再将它尾插到负数链或正数链。每个数据结点只移动一次，时间 O(n)，辅助空间 O(1)。',
  template:
      cListSupport +
      r'''void Split(Node *B, Node *C) {
  Node *p = B->next, *bt = B, *ct = C;
  B->next = C->next = NULL;
  while (p) {
    Node *next = p->next;
    p->next = NULL;
    if (/*BLANK_1*/) {
      /*BLANK_2*/
    } else {
      /*BLANK_3*/
    }
    p = next;
  }
}''',
  answers: ['p->data < 0', 'bt->next = p; bt = p;', 'ct->next = p; ct = p;'],
  dart:
      dartListSupport +
      r'''Object solve(Map<String, dynamic> input) {
  final b = build(input['a'] as List, 'a'), c = Node('CH', 0);
  var bt = b, ct = c;
  var p = b.next;
  b.next = null;
  while (p != null) {
    final next = p.next;
    p.next = null;
    if (p.value < 0) {
      bt.next = p; bt = p;
    } else {
      ct.next = p; ct = p;
    }
    p = next;
  }
  return {'b': snapshot(b), 'c': snapshot(c)};
}''',
);

const _interval = (
  explanation:
      '先跳过值不大于 mink 的前缀，再从第一个大于 mink 的结点起删除，遇到值不小于 maxk 的结点就停止。端点保留；删除段可以延伸到表尾。最坏时间 O(n)，辅助空间 O(1)。',
  template:
      cListSupport +
      r'''void DeleteInterval(Node *L, int mink, int maxk) {
  Node *pre = L;
  while (/*BLANK_1*/) pre = pre->next;
  Node *p = pre->next;
  while (/*BLANK_2*/) {
    Node *next = p->next;
    free(p);
    p = next;
  }
  /*BLANK_3*/
}''',
  answers: [
    'pre->next && pre->next->data <= mink',
    'p && p->data < maxk',
    'pre->next = p;',
  ],
  dart:
      dartListSupport +
      r'''Object solve(Map<String, dynamic> input) {
  final a = build(input['a'] as List, 'a');
  final min = input['min'] as int, max = input['max'] as int;
  var pre = a;
  while (pre.next != null && pre.next!.value <= min) {
    pre = pre.next!;
  }
  var p = pre.next;
  while (p != null && p.value < max) { p = p.next; }
  pre.next = p;
  return snapshot(a);
}''',
);

const _swap = (
  explanation:
      '只给 p，无须寻找表头。令 q=p->prior，先记住 q 前和 p 后的邻居，再把局部链接 a↔q↔p↔b 改成 a↔p↔q↔b。数据域保持原值。参考实现采用无哨兵的环；仅有一或两个结点时，其环形邻接关系在交换前后相同。时间和辅助空间均为 O(1)。',
  template:
      cListSupport +
      r'''void change(Node *p) {
  if (!p || p->prior == p->next) return;
  Node *q = p->prior, *a = q->prior, *b = p->next;
  /*BLANK_1*/
  /*BLANK_2*/
  /*BLANK_3*/
}''',
  answers: [
    'a->next = p; p->prior = a;',
    'p->next = q; q->prior = p;',
    'q->next = b; b->prior = q;',
  ],
  dart:
      dartListSupport +
      r'''void change(Node? p) {
  if (p == null || p.prior == p.next) return;
  final q = p.prior!, a = q.prior!, b = p.next!;
  a.next = p; p.prior = a;
  p.next = q; q.prior = p;
  q.next = b; b.prior = q;
}
Object solve(Map<String, dynamic> input) {
  final values = input['a'] as List;
  final nodes = [for (var i = 0; i < values.length; i++) Node('a$i', values[i] as int)];
  final n = nodes.length;
  for (var i = 0; i < n; i++) {
    nodes[i].next = nodes[(i+1)%n];
    nodes[i].prior = nodes[(i-1)%n];
  }
  final p = n == 0 ? null : nodes[(input['index'] as int)-1];
  change(p);
  // Read both directions from the given node, preserving its identity.
  List<String> traverse(bool forward) {
    final ids = <String>[];
    var cursor = p;
    for (var i=0; i<n; i++) {
      ids.add(cursor!.id);
      cursor = forward ? cursor.next : cursor.prior;
    }
    if (cursor != p) throw StateError('ring did not close');
    return ids;
  }
  return {'forward': traverse(true), 'backward': traverse(false),
    'values': [for (final node in nodes) node.value]};
}''',
);
