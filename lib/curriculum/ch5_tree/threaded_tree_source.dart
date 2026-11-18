part of 'threaded_tree.dart';

List<String> _threadSource(bool traverse, CodeLang lang) {
  final rows = traverse
      ? [
          (
            '算法 5.9　遍历已线索化的树',
            'void InOrderTraverse_Thr(BiThrNode *T) {',
            'void traverse(Node head) {',
          ),
          (
            'p ← 头结点的左指针',
            '  BiThrNode *p = T->lchild;',
            '  var p = head.left!;',
          ),
          ('当 p 不是头结点', '  while (p != T) {', '  while (p != head) {'),
          (
            '沿左孩子下降到子树的首结点',
            '    while (!p->LTag) p = p->lchild;',
            '    while (!p.lTag) { p = p.left!; }',
          ),
          ('访问 p', '    visit(p->data);', '    visit(p.data);'),
          (
            '右指针为线索且后继不是头结点时',
            '    while (p->RTag && p->rchild != T) {',
            '    while (p.rTag && p.right != head) {',
          ),
          ('沿线索到后继', '      p = p->rchild;', '      p = p.right!;'),
          ('访问后继', '      visit(p->data);', '      visit(p.data);'),
          ('继续检查右线索', '    }', '    }'),
          ('沿右指针转入子树或回到头结点', '    p = p->rchild;', '    p = p.right!;'),
          ('遇头结点，结束', '  } }', '  } }'),
        ]
      : [
          (
            '算法 5.8　建立头结点',
            'BiThrNode *Thrt, *pre; void InThreading(BiThrNode *p); void InOrderThreading(BiThrNode *T) {',
            'late Node head, pre; void threadTree(Node? root) {',
          ),
          (
            'Thrt 的标志为 0、1，右指针先指向自己',
            '  Thrt = calloc(1, sizeof *Thrt); Thrt->RTag = 1; Thrt->rchild = Thrt;',
            "  head = Node('Thrt'); head.lTag = false; head.rTag = true; head.right = head;",
          ),
          (
            '空树两端均指回 Thrt',
            '  if (!T) { Thrt->lchild = Thrt; return; }',
            '  if (root == null) { head.left = head; return; }',
          ),
          (
            '左指针指根，pre 指头结点',
            '  Thrt->lchild = T; pre = Thrt;',
            '  head.left = root; pre = head;',
          ),
          ('调用算法 5.7', '  InThreading(T);', '  inThreading(root);'),
          (
            '末结点右线索指回 Thrt',
            '  pre->rchild = Thrt; pre->RTag = 1;',
            '  pre.right = head; pre.rTag = true;',
          ),
          ('Thrt 的右线索指向末结点', '  Thrt->rchild = pre;', '  head.right = pre;'),
          ('返回已线索化的树', '}', '}'),
          (
            '算法 5.7　处理非空子树 p',
            'void InThreading(BiThrNode *p) { if (!p) return;',
            'void inThreading(Node? p) { if (p == null) return;',
          ),
          ('先线索化左子树', '  InThreading(p->lchild);', '  inThreading(p.left);'),
          (
            '左域为空则以 pre 为前驱',
            '  if (!p->lchild) { p->LTag = 1; p->lchild = pre; }',
            '  if (p.left == null) { p.lTag = true; p.left = pre; }',
          ),
          (
            '前驱的右域为空则以 p 为后继',
            '  if (pre != Thrt && !pre->rchild) { pre->RTag = 1; pre->rchild = p; }',
            '  if (pre != head && pre.right == null) { pre.rTag = true; pre.right = p; }',
          ),
          ('更新全局前驱 pre', '  pre = p;', '  pre = p;'),
          (
            '最后线索化右子树',
            '  InThreading(p->rchild); }',
            '  inThreading(p.right); }',
          ),
        ];
  return [
    for (final r in rows)
      switch (lang) {
        CodeLang.cLike => r.$1,
        CodeLang.c99 => r.$2,
        CodeLang.dart => r.$3,
      },
  ];
}
