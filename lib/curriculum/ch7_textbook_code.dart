import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

final ch7TextbookCode = List<CodeQuestion>.unmodifiable([
  textbookDesign(
    ChapterId.ch7,
    3,
    1,
    page: 232,
    title: "递归折半查找",
    topic: "递归折半查找",
    prompt: "试写出折半查找的递归算法。",
    explanation: "按教材以 1 为首位，未找到返回 0。每次递归丢弃中点及其一侧，空区间是失败出口。",
    template: r'''
int search(const int r[], int low, int high, int key) {
    if (low > high) return 0;
    int mid = low + (high - low) / 2;
    if (r[mid] == key) return mid;
    if (key < r[mid]) return search(r, low, /*BLANK_1*/, key);
    return search(r, /*BLANK_2*/, high, key);
}
''',
    answers: ["mid - 1", "mid + 1"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final r = [0, ...(data['keys'] as List).cast<int>()], key = data['key'] as int;
  int search(int lo, int hi) {
    if (lo > hi) return 0;
    final mid = lo + (hi-lo) ~/ 2;
    if (r[mid] == key) return mid;
    return key < r[mid] ? search(lo,mid-1) : search(mid+1,hi);
  }
  return search(1,r.length-1);
}
''',
    cases: const [
      AlgorithmTestCase(name: "空表", input: {"keys": [], "key": 1}, expected: 0),
      AlgorithmTestCase(
        name: "单项命中",
        input: {
          "keys": [4],
          "key": 4,
        },
        expected: 1,
      ),
      AlgorithmTestCase(
        name: "首位",
        input: {
          "keys": [1, 3, 5, 7],
          "key": 1,
        },
        expected: 1,
      ),
      AlgorithmTestCase(
        name: "末位",
        input: {
          "keys": [1, 3, 5, 7],
          "key": 7,
        },
        expected: 4,
      ),
      AlgorithmTestCase(
        name: "内部缺口",
        input: {
          "keys": [1, 3, 5, 7],
          "key": 4,
        },
        expected: 0,
      ),
      AlgorithmTestCase(
        name: "长表",
        input: {
          "keys": [
            -70,
            -67,
            -64,
            -61,
            -58,
            -55,
            -52,
            -49,
            -46,
            -43,
            -40,
            -37,
            -34,
            -31,
            -28,
            -25,
            -22,
            -19,
            -16,
            -13,
            -10,
            -7,
            -4,
            -1,
            2,
            5,
            8,
            11,
            14,
            17,
            20,
            23,
            26,
            29,
            32,
            35,
            38,
            41,
            44,
            47,
            50,
            53,
            56,
            59,
            62,
            65,
            68,
            71,
          ],
          "key": 29,
        },
        expected: 34,
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch7,
    3,
    2,
    page: 232,
    title: "判定二叉排序树",
    topic: "判定二叉排序树",
    prompt: "试写一个判别给定二叉树是否为二叉排序树的算法。",
    explanation: "按严格递增的中序序列判定。保存前驱结点指针，可检查跨越多层的祖先约束，也可处理空树和最小整数键。",
    template: r'''
#include <stdbool.h>
typedef struct Node { int key; struct Node *left, *right; } Node;
static bool visit(const Node *t, const Node **prev) {
    if (!t) return true;
    if (!visit(t->left, prev)) return false;
    if (*prev && /*BLANK_1*/) return false;
    *prev = t;
    return /*BLANK_2*/;
}
bool is_bst(const Node *root) {
    const Node *prev = 0;
    return visit(root, &prev);
}
''',
    answers: ["(*prev)->key >= t->key", "visit(t->right, prev)"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  int? previous;
  bool visit(dynamic t) {
    if (t == null) return true;
    if (!visit(t[1])) return false;
    final k=t[0] as int;
    if (previous!=null && previous! >= k) return false;
    previous=k;
    return visit(t[2]);
  }
  return visit(data['tree']);
}
''',
    cases: const [
      AlgorithmTestCase(name: "空树", input: {"tree": null}, expected: true),
      AlgorithmTestCase(
        name: "最小整型键",
        input: {
          "tree": [-2147483648, null, null],
        },
        expected: true,
      ),
      AlgorithmTestCase(
        name: "合法树",
        input: {
          "tree": [
            8,
            [
              4,
              [1, null, null],
              [6, null, null],
            ],
            [
              12,
              [10, null, null],
              [15, null, null],
            ],
          ],
        },
        expected: true,
      ),
      AlgorithmTestCase(
        name: "左子树越界",
        input: {
          "tree": [
            10,
            [
              4,
              null,
              [11, null, null],
            ],
            null,
          ],
        },
        expected: false,
      ),
      AlgorithmTestCase(
        name: "重复键",
        input: {
          "tree": [
            3,
            null,
            [3, null, null],
          ],
        },
        expected: false,
      ),
      AlgorithmTestCase(
        name: "右子树越界",
        input: {
          "tree": [
            10,
            null,
            [
              15,
              [8, null, null],
              null,
            ],
          ],
        },
        expected: false,
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch7,
    3,
    3,
    page: 232,
    endPage: 233,
    title: "递增输出不小于 x 的键",
    topic: "递增输出不小于 x 的键",
    prompt:
        "已知二叉排序树采用二叉链表存储结构，根结点的指针为 T，链结点的结构为（lchild，data，rchild）。请写出递归算法，从小到大输出树中所有数据值 ≥ x 的结点的数据。要求先找到第一个满足条件的结点后，再依次输出其他满足条件的结点。",
    explanation: "若根小于 x，整棵左子树可跳过。否则向左寻找下界；回溯时输出根，再中序输出已知全部合格的右子树。",
    template: r'''
typedef struct Node { struct Node *lchild; int data; struct Node *rchild; } Node;
static void inorder(const Node *t, void (*emit)(int)) {
    if (!t) return;
    inorder(t->lchild,emit); emit(t->data); inorder(t->rchild,emit);
}
void range(const Node *t, int x, void (*emit)(int)) {
    if (!t) return;
    if (t->data < x) { range(/*BLANK_1*/,x,emit); return; }
    range(t->lchild,x,emit);
    emit(t->data);
    /*BLANK_2*/
}
''',
    answers: ["t->rchild", "inorder(t->rchild,emit);"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final out=<int>[], x=data['x'] as int;
  void inorder(dynamic t) { if(t!=null){inorder(t[1]);out.add(t[0] as int);inorder(t[2]);} }
  void range(dynamic t) {
    if(t==null)return;
    if((t[0] as int)<x){range(t[2]);return;}
    range(t[1]);out.add(t[0] as int);inorder(t[2]);
  }
  range(data['tree']);return out;
}
''',
    cases: const [
      AlgorithmTestCase(
        name: "空树",
        input: {"tree": null, "x": 0},
        expected: [],
      ),
      AlgorithmTestCase(
        name: "等于阈值",
        input: {
          "tree": [2, null, null],
          "x": 2,
        },
        expected: [2],
      ),
      AlgorithmTestCase(
        name: "阈值在间隙",
        input: {
          "tree": [
            8,
            [
              4,
              [1, null, null],
              [6, null, null],
            ],
            [
              12,
              [10, null, null],
              [15, null, null],
            ],
          ],
          "x": 3,
        },
        expected: [4, 6, 8, 10, 12, 15],
      ),
      AlgorithmTestCase(
        name: "根恰好合格",
        input: {
          "tree": [
            8,
            [
              4,
              [1, null, null],
              [6, null, null],
            ],
            [
              12,
              [10, null, null],
              [15, null, null],
            ],
          ],
          "x": 8,
        },
        expected: [8, 10, 12, 15],
      ),
      AlgorithmTestCase(
        name: "超过最大键",
        input: {
          "tree": [
            8,
            [
              4,
              [1, null, null],
              [6, null, null],
            ],
            [
              12,
              [10, null, null],
              [15, null, null],
            ],
          ],
          "x": 16,
        },
        expected: [],
      ),
      AlgorithmTestCase(
        name: "全部合格",
        input: {
          "tree": [
            8,
            [
              4,
              [1, null, null],
              [6, null, null],
            ],
            [
              12,
              [10, null, null],
              [15, null, null],
            ],
          ],
          "x": -1,
        },
        expected: [1, 4, 6, 8, 10, 12, 15],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch7,
    3,
    4,
    page: 233,
    title: "非递归查找、计数与插入",
    topic: "非递归查找、计数与插入",
    prompt:
        "已知二叉树 T 的结点形式为（llink, data, count, rlink），在树中查找值为 X 的结点，若找到，则计数（count）加 1；否则，作为一个新结点插入树中，插入后仍为二叉排序树，写出其非递归算法。",
    explanation:
        "沿键值对应的孩子指针迭代下降，命中只改计数；遇到空链接时在该位置接入计数为 1 的新结点。用例以带计数的先序序列核对树形。",
    template: r'''
#include <stdlib.h>
typedef struct Node { struct Node *llink; int data,count; struct Node *rlink; } Node;
void record(Node **p,int x) {
    while (*p) {
        if ((*p)->data==x) { /*BLANK_1*/ return; }
        p = x<(*p)->data ? &(*p)->llink : /*BLANK_2*/;
    }
    Node *q=malloc(sizeof *q);
    if (!q) abort();
    *q=(Node){0,x,1,0}; *p=q;
}
''',
    answers: ["++(*p)->count;", "&(*p)->rlink"],
    dart: r'''
class N { N(this.key); int key,count=1; N? left,right; }
Object solve(Map<String,dynamic> data) {
  N? root;
  for(final x in (data['keys'] as List).cast<int>()){
    if(root==null){root=N(x);continue;}
    var p=root;
    while(true){
      if(x==p.key){p.count++;break;}
      final left=x<p.key, child=left?p.left:p.right;
      if(child==null){if(left){p.left=N(x);}else{p.right=N(x);}break;}
      p=child;
    }
  }
  final out=<List<int>>[];
  void preorder(N? p){if(p!=null){out.add([p.key,p.count]);preorder(p.left);preorder(p.right);}}
  preorder(root);return out;
}
''',
    cases: const [
      AlgorithmTestCase(name: "空输入", input: {"keys": []}, expected: []),
      AlgorithmTestCase(
        name: "根插入",
        input: {
          "keys": [4],
        },
        expected: [
          [4, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "重复命中",
        input: {
          "keys": [4, 4, 4],
        },
        expected: [
          [4, 3],
        ],
      ),
      AlgorithmTestCase(
        name: "双侧插入",
        input: {
          "keys": [8, 3, 10, 3, 6],
        },
        expected: [
          [8, 1],
          [3, 2],
          [6, 1],
          [10, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "左斜树",
        input: {
          "keys": [3, 2, 1, 2],
        },
        expected: [
          [3, 1],
          [2, 2],
          [1, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "右斜树",
        input: {
          "keys": [1, 2, 3, 1, 3],
        },
        expected: [
          [1, 2],
          [2, 1],
          [3, 2],
        ],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch7,
    3,
    5,
    page: 233,
    title: "利用平衡因子求树高",
    topic: "利用平衡因子求树高",
    prompt: "假设一棵平衡二叉树的每个结点都标明了平衡因子 b，试设计一个算法，求平衡二叉树的高度。",
    explanation: "以左高减右高为 b，沿较高孩子走到空结点；b=0 时任选一侧。树高按层数计，时间 O(h)。用例结点首项存 b。",
    template: r'''
typedef struct Node { int b; struct Node *left,*right; } Node;
int height(const Node *p) {
    int h=0;
    while (p) {
        /*BLANK_1*/
        p = p->b >= 0 ? p->left : /*BLANK_2*/;
    }
    return h;
}
''',
    answers: ["++h;", "p->right"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  dynamic p=data['tree'];var h=0;
  while(p!=null){h++;p=(p[0] as int)>=0?p[1]:p[2];}
  return h;
}
''',
    cases: const [
      AlgorithmTestCase(name: "空树", input: {"tree": null}, expected: 0),
      AlgorithmTestCase(
        name: "叶",
        input: {
          "tree": [0, null, null],
        },
        expected: 1,
      ),
      AlgorithmTestCase(
        name: "左高",
        input: {
          "tree": [
            1,
            [0, null, null],
            null,
          ],
        },
        expected: 2,
      ),
      AlgorithmTestCase(
        name: "右高",
        input: {
          "tree": [
            -1,
            null,
            [0, null, null],
          ],
        },
        expected: 2,
      ),
      AlgorithmTestCase(
        name: "等高",
        input: {
          "tree": [
            0,
            [0, null, null],
            [0, null, null],
          ],
        },
        expected: 2,
      ),
      AlgorithmTestCase(
        name: "混合分支",
        input: {
          "tree": [
            -1,
            [0, null, null],
            [
              1,
              [0, null, null],
              null,
            ],
          ],
        },
        expected: 3,
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch7,
    3,
    6,
    page: 233,
    title: "链地址表插入与删除",
    topic: "链地址表插入与删除",
    prompt: "分别写出在散列表中插入和删除关键字为 K 的一个记录的算法，设散列函数为 H，解决冲突的方法为链地址法。",
    explanation: "插入时把新记录挂到 H(K) 桶头，删除时摘下第一个匹配结点。重复键代表不同记录，一次删除一条。用例采用非负余数桶号。",
    template: r'''
#include <stdlib.h>
typedef struct Link { int key; struct Link *next; } Link;
void insert(Link *b[],int k,int (*H)(int)) {
    int j=H(k); Link *p=malloc(sizeof *p); if(!p)abort();
    p->key=k; p->next=b[j]; /*BLANK_1*/
}
void erase(Link *b[],int k,int (*H)(int)) {
    Link **p=&b[H(k)];
    while(*p && (*p)->key!=k) p=&(*p)->next;
    if(*p){ Link *old=*p; /*BLANK_2*/ free(old); }
}
''',
    answers: ["b[j]=p;", "*p=old->next;"],
    dart: r'''
class Link { Link(this.key,this.next); int key; Link? next; }
Object solve(Map<String,dynamic> data){
  final b=List<Link?>.filled(data['m'] as int,null);
  for(final op in data['ops'] as List){
    final k=op[1] as int,j=k%b.length;
    if(op[0]=='+'){b[j]=Link(k,b[j]);continue;}
    Link? prev,p=b[j];
    while(p!=null && p.key!=k){prev=p;p=p.next;}
    if(p!=null){if(prev==null){b[j]=p.next;}else{prev.next=p.next;}}
  }
  return [for(final head in b)[for(var p=head;p!=null;p=p.next)p.key]];
}
''',
    cases: const [
      AlgorithmTestCase(
        name: "空桶",
        input: {"m": 3, "ops": []},
        expected: [[], [], []],
      ),
      AlgorithmTestCase(
        name: "插入",
        input: {
          "m": 3,
          "ops": [
            ["+", 1],
          ],
        },
        expected: [
          [],
          [1],
          [],
        ],
      ),
      AlgorithmTestCase(
        name: "删链首",
        input: {
          "m": 3,
          "ops": [
            ["+", 1],
            ["+", 4],
            ["-", 4],
          ],
        },
        expected: [
          [],
          [1],
          [],
        ],
      ),
      AlgorithmTestCase(
        name: "删链中",
        input: {
          "m": 3,
          "ops": [
            ["+", 1],
            ["+", 4],
            ["+", 7],
            ["-", 4],
          ],
        },
        expected: [
          [],
          [7, 1],
          [],
        ],
      ),
      AlgorithmTestCase(
        name: "未命中",
        input: {
          "m": 3,
          "ops": [
            ["+", -1],
            ["-", 8],
          ],
        },
        expected: [
          [],
          [],
          [-1],
        ],
      ),
      AlgorithmTestCase(
        name: "保留一条重键",
        input: {
          "m": 3,
          "ops": [
            ["+", 3],
            ["+", 3],
            ["-", 3],
            ["+", 1],
          ],
        },
        expected: [
          [3],
          [1],
          [],
        ],
      ),
    ],
  ),
]);
