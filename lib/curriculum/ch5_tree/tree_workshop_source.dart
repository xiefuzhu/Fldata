part of 'bitree_traverse.dart';

List<String> _workshopListing(TreeLesson mode, CodeLang lang) {
  // Each row is one playback stop in pseudocode, C99 and Dart respectively.
  final List<(String, String, String)> rows;
  if (mode == TreeLesson.levelOrder) {
    rows = [
      (
        '建立空队列 Q',
        'void level(Node *t) { Queue q = emptyQueue();',
        'void level(Node? t) { final q = Queue<Node>();',
      ),
      ('根非空则入队', '  if (t) enqueue(&q,t);', '  if (t != null) q.add(t);'),
      (
        '取出队头结点 p',
        '  while (!empty(&q)) { Node *p = dequeue(&q);',
        '  while (q.isNotEmpty) { final p = q.removeFirst();',
      ),
      ('访问 p', '    visit(p->data);', '    visit(p.label);'),
      (
        '左孩子非空则入队',
        '    if (p->left) enqueue(&q,p->left);',
        '    if (p.left != null) q.add(p.left!);',
      ),
      (
        '右孩子非空则入队',
        '    if (p->right) enqueue(&q,p->right);',
        '    if (p.right != null) q.add(p.right!);',
      ),
      ('队列为空，结束', '  } }', '  } }'),
    ];
  } else if (mode == TreeLesson.create) {
    rows = [
      (
        '读取下一个字符 ch',
        'Node *create(void) { int ch = nextToken();',
        'Node? create() { final ch = nextToken();',
      ),
      (
        '若 ch 为 #，返回空树',
        "  if (ch == '#') return NULL;",
        "  if (ch == '#') return null;",
      ),
      ('申请结点并填入 ch', '  Node *p = newNode(ch);', '  final p = Node(ch);'),
      ('建左子树', '  p->left = create();', '  p.left = create();'),
      ('建右子树', '  p->right = create();', '  p.right = create();'),
      ('返回 p', '  return p; }', '  return p; }'),
    ];
  } else if (mode.isReconstruction) {
    final post = mode == TreeLesson.postIn, shift = post ? 'a' : 'a+1';
    rows = [
      (
        '处理遍历区间与中序区间',
        'Node *build(int a, int b, int n) {',
        'Node? build(int a, int b, int n) {',
      ),
      ('空区间返回空树', '  if (!n) return NULL;', '  if (n == 0) return null;'),
      (
        '根据根值选择中序可行分割点 k',
        '  int k = split(a,b,n), left = k-b;',
        '  final k = split(a,b,n), left = k-b;',
      ),
      (
        post ? '根取后序末项' : '根取先序首项',
        '  Node *p = newNode(order[${post ? "a+n-1" : "a"}]);',
        '  final p = Node(order[${post ? "a+n-1" : "a"}]);',
      ),
      (
        '递归重构左区间',
        '  p->left = build($shift,b,left);',
        '  p.left = build($shift,b,left);',
      ),
      (
        '递归重构右区间',
        '  p->right = build($shift+left,k+1,n-left-1);',
        '  p.right = build($shift+left,k+1,n-left-1);',
      ),
      ('返回当前子树', '  return p; }', '  return p; }'),
    ];
  } else if (mode == TreeLesson.copy) {
    rows = [
      ('复制以 t 为根的子树', 'Node *copy(const Node *t) {', 'Node? copy(Node? t) {'),
      ('空树返回空指针', '  if (!t) return NULL;', '  if (t == null) return null;'),
      (
        '申请独立结点并复制数据',
        '  Node *p = newNode(t->data);',
        '  final p = Node(t.label);',
      ),
      ('复制左子树', '  p->left = copy(t->left);', '  p.left = copy(t.left);'),
      ('复制右子树', '  p->right = copy(t->right);', '  p.right = copy(t.right);'),
      ('返回副本根', '  return p; }', '  return p; }'),
    ];
  } else {
    final depth = mode == TreeLesson.depth, fn = depth ? 'depth' : 'count';
    rows = [
      ('进入子树', 'int $fn(const Node *t) {', 'int $fn(Node? t) {'),
      ('空树返回 0', '  if (!t) return 0;', '  if (t == null) return 0;'),
      ('求左子树返回值', '  int l = $fn(t->left);', '  final l = $fn(t.left);'),
      ('求右子树返回值', '  int r = $fn(t->right);', '  final r = $fn(t.right);'),
      (
        depth ? '较大深度加 1' : '左右个数相加再加 1',
        depth ? '  return 1 + (l > r ? l : r);' : '  return 1 + l + r;',
        depth ? '  return 1 + max(l,r);' : '  return 1 + l + r;',
      ),
      ('结束', '}', '}'),
    ];
  }
  return [
    for (final row in rows)
      switch (lang) {
        CodeLang.cLike => row.$1,
        CodeLang.c99 => row.$2,
        CodeLang.dart => row.$3,
      },
  ];
}
