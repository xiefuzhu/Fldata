import '../../enum/ds_enums.dart';

Map<CodeLang, List<String>> bstSource(String operation) {
  switch (operation) {
    case 'search':
      return const {
        CodeLang.cLike: [
          '若 T 为空，返回 NULL',
          '若 key = T.data.key，返回 T',
          'key 较小则递归查找左子树',
          'key 较大则递归查找右子树',
          '把子调用返回的地址传给调用方',
        ],
        CodeLang.c99: [
          'Node *search(Node *t,int key){ if(!t) return NULL;',
          '  if(key==t->data.key) return t;',
          '  if(key<t->data.key) return search(t->left,key);',
          '  return search(t->right,key);',
          '}',
        ],
        CodeLang.dart: [
          'Node? search(Node? t,int key){ if(t==null) return null;',
          '  if(key==t.key) return t;',
          '  if(key<t.key) return search(t.left,key);',
          '  return search(t.right,key);',
          '}',
        ],
      };
    case 'insert':
      return const {
        CodeLang.cLike: [
          '检测 T 是否指向空树',
          '相等时保留树中原记录',
          '小于当前关键字则向左递归',
          '大于当前关键字则向右递归',
          '在空链处写入一个左右孩子均空的新结点',
          '返回本层根',
        ],
        CodeLang.c99: [
          'Node *insert(Node *t,int key){ if(t){',
          '  if(t->data.key==key) return t;',
          '  if(key<t->data.key) t->left=insert(t->left,key);',
          '  else t->right=insert(t->right,key);',
          '} else t=new_leaf(key);',
          'return t; }',
        ],
        CodeLang.dart: [
          'Node insert(Node? t,int key){ if(t!=null){',
          '  if(t.key==key) return t;',
          '  if(key<t.key) t.left=insert(t.left,key);',
          '  else t.right=insert(t.right,key);',
          '} else {t=Node(key);}',
          'return t; }',
        ],
      };
    case 'avl':
      return const {
        CodeLang.cLike: [
          '初始化空树 T，逐项读入 key',
          '沿查找路径记录祖先，遇到相等键则跳过',
          '把 key 挂到空链处，形成新叶子',
          '从下向上取祖先 A，若 |BF(A)| < 2，继续回溯',
          '锁定第一个失衡的 A，按两层路径识别 LL、RR、LR 或 RL',
          'LR 时对 A.left 左旋，RL 时对 A.right 右旋',
          '双旋的中间态已转成 LL 或 RR',
          'LL/LR 对 A 右旋，RR/RL 对 A 左旋，接回原双亲',
          '结束本次调整，继续处理下一个键',
        ],
        CodeLang.c99: [
          'Node *t=NULL; for(int i=0;i<n;i++){ int key=keys[i];',
          '  Path p=find_path(&t,key); if(p.found) continue;',
          '  *p.slot=new_leaf(key);',
          '  while(p.depth){ Node **slot=pop_slot(&p), *a=*slot; int bf=balance(a); if(abs(bf)<2) continue;',
          '    Rotation r=classify(a,bf,key);',
          '    if(r==LR) a->left=left_rotate(a->left); else if(r==RL) a->right=right_rotate(a->right);',
          '    /* Inner rotation complete for LR and RL. */',
          '    *slot=bf>0 ? right_rotate(a) : left_rotate(a);',
          '    break; } }',
        ],
        CodeLang.dart: [
          'Node? root; for(final key in keys){',
          '  final p=findPath(root,key); if(p.found) continue;',
          '  root=attachLeaf(root,p,Node(key));',
          '  for(final a in p.ancestors.reversed){ final bf=balance(a); if(bf.abs()<2) continue;',
          '    final r=classify(a,bf,key);',
          '    if(r==lr){a.left=rotateLeft(a.left!);} else if(r==rl){a.right=rotateRight(a.right!);}',
          '    // Inner rotation complete for LR and RL.',
          '    root=replaceSubtree(root,p.parentOf(a),a,bf>0 ? rotateRight(a) : rotateLeft(a));',
          '    break; } }',
        ],
      };
    case 'build':
      return const {
        CodeLang.cLike: [
          '初始化 T 为空树',
          '逐个读入关键字并调用 InsertBST(T,key)，遇相等键跳过',
          '读完序列，返回 T',
        ],
        CodeLang.c99: [
          'Node *create(int keys[],int n){ Node *t=NULL;',
          '  for(int i=0;i<n;++i) t=insert(t,keys[i]);',
          '  return t; }',
        ],
        CodeLang.dart: [
          'Node? create(List<int> keys){ Node? t;',
          '  for(final key in keys){t=insert(t,key);}',
          '  return t; }',
        ],
      };
    default:
      return const {
        CodeLang.cLike: [
          'p 从根向下查找，f 始终为它的双亲',
          '若 p 为空，结束',
          '若 p 有两个孩子，令 q=p, s=p.lchild',
          '沿右链移动 q、s 至 s.rchild 为空',
          '复制 s.data 到 p.data',
          'q=p 时接 q.lchild，否则接 q.rchild，均指向 s.lchild',
          '若 p 至多有一棵子树，取其孩子或 NULL',
          '把根指针或 f 原来指向 p 的链接改指向孩子',
          '释放从树中摘下的结点',
        ],
        CodeLang.c99: [
          'Node *p=*root,*f=NULL; while(p && p->data.key!=key){f=p;p=key<p->data.key?p->left:p->right;}',
          'if(!p) return; Node *dead=p;',
          'if(p->left && p->right){Node *q=p,*s=p->left;',
          '  while(s->right){q=s;s=s->right;}',
          '  p->data=s->data;',
          '  if(q==p) q->left=s->left; else q->right=s->left; dead=s;',
          '}else{ Node *child=p->left?p->left:p->right;',
          '  if(!f)*root=child; else if(f->left==p)f->left=child; else f->right=child;}',
          'free(dead);',
        ],
        CodeLang.dart: [
          'var p=root; Node? f; while(p!=null && p.key!=key){f=p;p=key<p.key?p.left:p.right;}',
          'if(p==null) return;',
          'if(p.left!=null && p.right!=null){var q=p,s=p.left!;',
          '  while(s.right!=null){q=s;s=s.right!;}',
          '  p.key=s.key;',
          '  if(q==p){q.left=s.left;}else{q.right=s.left;}',
          '}else{final child=p.left??p.right;',
          '  if(f==null){root=child;}else if(f.left==p){f.left=child;}else{f.right=child;}}',
          '// 摘下的结点由 GC 回收',
        ],
      };
  }
}
