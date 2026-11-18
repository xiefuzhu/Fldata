import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

// Adjacency chains retain the neighbor order given in each exercise fixture.
const _graphC = r'''
#include <stdbool.h>
#include <stddef.h>
enum { MAXV = 128 };
typedef struct Arc { int to; struct Arc *next; } Arc;
typedef struct { int n; Arc *out[MAXV]; } Graph;
''';

const _adjacencyDart = r'''
List<List<int>> adjacency(Map<String,dynamic> data) {
  final out = List.generate(data['n'] as int, (_) => <int>[]);
  for (final pair in data['edges'] as List) {
    final u = pair[0] as int, v = pair[1] as int;
    out[u].add(v);
    if (data['directed'] == false && u != v) out[v].add(u);
  }
  return out;
}
''';

const _editC = r'''
#include <stdbool.h>
#include <stdlib.h>
enum { MAXV = 128 };
// Vertex labels are stable integer slots. Both graphs start zero-initialized.
// Calls receive labels in [0,MAXV); deleting an absent element is a no-op.
typedef struct { bool live[MAXV], a[MAXV][MAXV], directed; } Matrix;
void MInsertVex(Matrix *g,int v) { g->live[v]=true; }
void MInsertArc(Matrix *g,int v,int w) {
    if (!g->live[v] || !g->live[w]) return;
    g->a[v][w]=true;
    if (!g->directed) g->a[w][v]=true;
}
void MDeleteArc(Matrix *g,int v,int w) {
    g->a[v][w]=false;
    if (!g->directed) g->a[w][v]=false;
}
void MDeleteVex(Matrix *g,int v) {
    for (int i=0;i<MAXV;i++) { g->a[v][i]=false; /*BLANK_1*/ }
    g->live[v]=false;
}
typedef struct Link { int to; struct Link *next; } Link;
typedef struct { bool live[MAXV], directed; Link *out[MAXV]; } AdjList;
void LInsertVex(AdjList *g,int v) { g->live[v]=true; }
static void link_one(Link **p,int w) {
    while (*p && (*p)->to<w) p=&(*p)->next;
    if (*p && (*p)->to==w) return;
    Link *q=malloc(sizeof *q); if (!q) abort();
    q->to=w; q->next=*p; *p=q;
}
static void unlink_one(Link **p,int w) {
    while (*p && (*p)->to!=w) p=&(*p)->next;
    if (*p) { Link *old=*p; /*BLANK_2*/ free(old); }
}
void LInsertArc(AdjList *g,int v,int w) {
    if (!g->live[v] || !g->live[w]) return;
    link_one(&g->out[v],w);
    if (!g->directed && v!=w) link_one(&g->out[w],v);
}
void LDeleteArc(AdjList *g,int v,int w) {
    unlink_one(&g->out[v],w);
    if (!g->directed && v!=w) unlink_one(&g->out[w],v);
}
void LDeleteVex(AdjList *g,int v) {
    while (g->out[v]) { Link *old=g->out[v]; g->out[v]=old->next; free(old); }
    for (int i=0;i<MAXV;i++) /*BLANK_3*/
    g->live[v]=false;
}
''';

const _editDart = r'''
Object solve(Map<String,dynamic> data) {
  final directed=data['directed'] as bool, cap=data['capacity'] as int;
  final live=<int>{}, a=List.generate(cap,(_)=>List.filled(cap,false));
  final out=<int,Set<int>>{};
  for(final op in data['ops'] as List) {
    final v=op[1] as int;
    switch(op[0]) {
      case '+v':
        live.add(v); out.putIfAbsent(v,()=> <int>{}); break;
      case '-v':
        live.remove(v); out.remove(v);
        for(var i=0;i<cap;i++){ a[i][v]=false; a[v][i]=false; }
        for(final links in out.values){ links.remove(v); }
        break;
      default:
        final w=op[2] as int;
        if(!live.contains(v)||!live.contains(w)) continue;
        final add=op[0]=='+e';
        a[v][w]=add;
        if(!directed)a[w][v]=add;
        if(add){out[v]!.add(w);if(!directed)out[w]!.add(v);}
        else{out[v]!.remove(w);if(!directed)out[w]!.remove(v);}
    }
  }
  final vertices=live.toList()..sort();
  return {'vertices':vertices,'matrix':[for(final v in vertices)[for(final w in vertices)a[v][w]?1:0]],
    'adjacency':[for(final v in vertices)out[v]!.toList()..sort()]};
}
''';

AlgorithmTestCase _editCase(
  String name,
  int capacity,
  bool directed,
  List<List<Object>> ops,
  List<int> vertices,
  List<List<int>> expectedEdges,
) {
  final pairs = {
    for (final e in expectedEdges) (e[0], e[1]),
    if (!directed)
      for (final e in expectedEdges) (e[1], e[0]),
  };
  return AlgorithmTestCase(
    name: name,
    input: {'capacity': capacity, 'directed': directed, 'ops': ops},
    expected: {
      'vertices': vertices,
      'matrix': [
        for (final a in vertices)
          [for (final b in vertices) pairs.contains((a, b)) ? 1 : 0],
      ],
      'adjacency': [
        for (final a in vertices)
          [
            for (final b in vertices)
              if (pairs.contains((a, b))) b,
          ],
      ],
    },
  );
}

List<List<int>> _randomTree(int size) {
  var state = 20261118;
  return [
    for (var i = 1; i < size; i++)
      [(state = (1664525 * state + 1013904223) & 0xffffffff) % i, i],
  ];
}

final _tree = _randomTree(48);
final _edits = [
  _editCase(
    '点边增删',
    4,
    true,
    [
      ['+v', 0],
      ['+v', 1],
      ['+v', 2],
      ['+e', 0, 1],
      ['+e', 2, 1],
      ['+e', 1, 0],
      ['-v', 1],
      ['+v', 3],
      ['+e', 3, 0],
    ],
    [0, 2, 3],
    [
      [3, 0],
    ],
  ),
  _editCase('空图', 0, false, [], [], []),
  _editCase(
    '单点自环',
    1,
    true,
    [
      ['+v', 0],
      ['+e', 0, 0],
    ],
    [0],
    [
      [0, 0],
    ],
  ),
  _editCase(
    '重复插入与删除',
    2,
    false,
    [
      ['+v', 0],
      ['+v', 0],
      ['+v', 1],
      ['+e', 0, 1],
      ['+e', 1, 0],
      ['-e', 1, 0],
      ['-e', 0, 1],
      ['+e', 1, 0],
    ],
    [0, 1],
    [
      [0, 1],
    ],
  ),
  _editCase(
    '删除首尾再插入',
    3,
    false,
    [
      ['+v', 0],
      ['+v', 1],
      ['+v', 2],
      ['+e', 0, 1],
      ['+e', 2, 1],
      ['+e', 0, 2],
      ['-v', 0],
      ['-v', 2],
      ['+v', 0],
      ['+e', 0, 1],
    ],
    [0, 1],
    [
      [0, 1],
    ],
  ),
  _editCase(
    '固定种子树删去偶数顶点',
    48,
    false,
    [
      for (var i = 0; i < 48; i++) ['+v', i],
      for (final e in _tree) ['+e', ...e],
      for (var i = 0; i < 48; i += 2) ['-v', i],
    ],
    [for (var i = 1; i < 48; i += 2) i],
    [
      for (final e in _tree)
        if (e.every((v) => v.isOdd)) e,
    ],
  ),
];

AlgorithmTestCase _graphCase(
  String name,
  int n,
  List<List<int>> edges,
  int start,
  Object expected, {
  bool directed = false,
  int? target,
  int? k,
}) => AlgorithmTestCase(
  name: name,
  input: {
    'n': n,
    'edges': edges,
    'start': start,
    'directed': directed,
    'target': ?target,
    'k': ?k,
  },
  expected: expected,
);
const _fig631 = [
  [0, 1],
  [0, 2],
  [0, 3],
  [1, 2],
  [2, 3],
];
const _diamond = [
  [0, 1],
  [0, 2],
  [1, 3],
  [2, 3],
];

final ch6TextbookCode = List<CodeQuestion>.unmodifiable([
  textbookDesign(
    ChapterId.ch6,
    3,
    1,
    page: 190,
    title: '两种存储下增删顶点与边',
    topic: '图的基本操作',
    prompt:
        '分别以邻接矩阵和邻接表作为存储结构，实现以下图的基本操作：\n① 增加一个新顶点 v，InsertVex(G, v)；\n② 删除顶点 v 及其相关的边，DeleteVex(G, v)；\n③ 增加一条边 ⟨v,w⟩，InsertArc(G, v, w)；\n④ 删除一条边 ⟨v,w⟩，DeleteArc(G, v, w)。',
    explanation:
        '矩阵用稳定顶点槽位表示，删除顶点清除整行整列。邻接表删除出链并摘除所有指向该点的入弧。无向边在两端对称维护。两种表示均保持顶点标识，重复操作按简单图语义处理。',
    template: _editC,
    answers: [
      'g->a[i][v]=false;',
      '*p=old->next;',
      'unlink_one(&g->out[i],v);',
    ],
    dart: _editDart,
    cases: _edits,
  ),
  textbookDesign(
    ChapterId.ch6,
    3,
    2,
    page: 190,
    title: "邻接表的非递归 DFS",
    topic: "邻接表的非递归 DFS",
    prompt: "一个连通图采用邻接表作为存储结构，设计一个算法，实现从顶点 v 出发的深度优先遍历的非递归过程。",
    explanation: "栈中每层保留下一条待扫描的弧，先推进当前游标再深入。按输入邻接次序得到与递归 DFS 相同的访问序列。空图输出空序列。",
    template:
        _graphC +
        r'''
int dfs_order(const Graph *g,int start,int order[]) {
    if (start<0 || start>=g->n) return 0;
    bool seen[MAXV]={false};
    const Arc *stack[MAXV];
    int depth=0,n=0;
    seen[start]=true; order[n++]=start; stack[depth++]=g->out[start];
    while (depth) {
        const Arc *p=stack[depth-1];
        if (!p) { --depth; continue; }
        /*BLANK_1*/
        if (seen[p->to]) continue;
        seen[p->to]=true; order[n++]=p->to;
        /*BLANK_2*/
    }
    return n;
}
''',
    answers: ["stack[depth-1]=p->next;", "stack[depth++]=g->out[p->to];"],
    dart:
        _adjacencyDart +
        r'''
Object solve(Map<String,dynamic> data) {
  final out=adjacency(data), s=data['start'] as int;
  if(s<0 || s>=out.length)return <int>[];
  final order=[s], seen={s}, stack=[out[s].iterator];
  while(stack.isNotEmpty){
    final top=stack.last;
    if(!top.moveNext()){stack.removeLast();continue;}
    final v=top.current;
    if(seen.add(v)){ order.add(v); stack.add(out[v].iterator); }
  }
  return order;
}
''',
    cases: [
      _graphCase('图 6.31', 4, _fig631, 0, [0, 1, 2, 3]),
      _graphCase('空图', 0, [], -1, []),
      _graphCase('单顶点', 1, [], 0, [0]),
      _graphCase('菱形共享邻点', 4, _diamond, 0, [0, 1, 3, 2]),
      _graphCase('末顶点出发', 4, _fig631, 3, [3, 0, 1, 2]),
      _graphCase('固定种子树', 48, _tree, 0, [
        0,
        1,
        7,
        9,
        11,
        41,
        23,
        29,
        31,
        33,
        2,
        4,
        5,
        6,
        8,
        39,
        10,
        12,
        15,
        17,
        25,
        27,
        20,
        22,
        36,
        40,
        42,
        26,
        30,
        32,
        37,
        34,
        24,
        28,
        46,
        47,
        14,
        16,
        18,
        38,
        35,
        44,
        3,
        13,
        19,
        21,
        43,
        45,
      ]),
    ],
  ),
  textbookDesign(
    ChapterId.ch6,
    3,
    3,
    page: 190,
    title: "求最短路径最长的顶点",
    topic: "求最短路径最长的顶点",
    prompt: "设计一个算法，求图 G 中距离顶点 v 的最短路径长度最大的一个顶点，设 v 可达其余各个顶点。",
    explanation:
        "按无权图的边数计距离。BFS 首次发现顶点时记录层号；选择层号最大的顶点。并列时本例选下标最小者，单顶点返回自身，空图返回 −1。",
    template:
        _graphC +
        r'''
int farthest(const Graph *g,int start) {
    if (start<0 || start>=g->n) return -1;
    int d[MAXV],q[MAXV],head=0,tail=0;
    for(int i=0;i<g->n;i++) d[i]=-1;
    d[start]=0; q[tail++]=start;
    while (head<tail) {
        int u=q[head++];
        for(const Arc *p=g->out[u];p;p=p->next) if(d[p->to]<0) {
            /*BLANK_1*/ q[tail++]=p->to;
        }
    }
    int best=0;
    for(int i=1;i<g->n;i++) if(/*BLANK_2*/) best=i;
    return best;
}
''',
    answers: ["d[p->to]=d[u]+1;", "d[i]>d[best]"],
    dart:
        _adjacencyDart +
        r'''
Object solve(Map<String,dynamic> data) {
  final out=adjacency(data),s=data['start'] as int;
  if(s<0 || s>=out.length)return -1;
  final d=List.filled(out.length,-1), q=[s];d[s]=0;
  for(var i=0;i<q.length;i++){final u=q[i];
    for(final v in out[u]){if(d[v]<0){d[v]=d[u]+1;q.add(v);}}
  }
  var best=0;
  for(var i=1;i<d.length;i++){if(d[i]>d[best])best=i;}
  return best;
}
''',
    cases: [
      _graphCase('图 6.31', 4, _fig631, 1, 3),
      _graphCase('空图', 0, [], -1, -1),
      _graphCase('单顶点', 1, [], 0, 0),
      _graphCase(
        '并列最远点',
        4,
        [
          [0, 3],
          [0, 2],
          [0, 1],
        ],
        0,
        1,
      ),
      _graphCase(
        '末顶点出发',
        4,
        [
          [0, 1],
          [1, 2],
          [2, 3],
        ],
        3,
        0,
      ),
      _graphCase('固定种子树', 48, _tree, 0, 37),
    ],
  ),
  textbookDesign(
    ChapterId.ch6,
    3,
    4,
    page: 190,
    title: "有向图的两点可达性",
    topic: "有向图的两点可达性",
    prompt: "试基于图的深度优先搜索策略写一算法，判别以邻接表方式存储的有向图中是否存在由顶点 vᵢ 到顶点 vⱼ 的路径（i≠j）。",
    explanation: "只沿出弧搜索，访问标记在整个搜索中保留。发现终点即返回。题目要求不同端点，缺少有效点对时返回假。",
    template:
        _graphC +
        r'''
static bool reach(const Graph *g,int u,int target,bool seen[]) {
    if(u==target) return true;
    /*BLANK_1*/
    for(const Arc *p=g->out[u];p;p=p->next)
        if(!seen[p->to] && /*BLANK_2*/) return true;
    return false;
}
bool reachable(const Graph *g,int s,int t) {
    bool seen[MAXV]={false};
    return s>=0 && t>=0 && s<g->n && t<g->n && s!=t && reach(g,s,t,seen);
}
''',
    answers: ["seen[u]=true;", "reach(g,p->to,target,seen)"],
    dart:
        _adjacencyDart +
        r'''
Object solve(Map<String,dynamic> data) {
  final out=adjacency(data),s=data['start'] as int,t=data['target'] as int;
  if(s<0||t<0||s>=out.length||t>=out.length||s==t)return false;
  final seen=<int>{};
  bool visit(int u){
    if(u==t)return true;
    seen.add(u);
    return out[u].any((v)=>!seen.contains(v)&&visit(v));
  }
  return visit(s);
}
''',
    cases: [
      _graphCase(
        '链式依赖',
        4,
        [
          [0, 1],
          [1, 3],
          [2, 0],
        ],
        2,
        true,
        directed: true,
        target: 3,
      ),
      _graphCase('空图', 0, [], -1, false, directed: true, target: -1),
      _graphCase('单点无不同端点', 1, [], 0, false, directed: true, target: 0),
      _graphCase(
        '环内无法抵达孤点',
        4,
        [
          [0, 1],
          [1, 2],
          [2, 0],
        ],
        1,
        false,
        directed: true,
        target: 3,
      ),
      _graphCase(
        '反向不通',
        3,
        [
          [0, 1],
          [1, 2],
        ],
        2,
        false,
        directed: true,
        target: 0,
      ),
      _graphCase('固定种子有向树', 48, _tree, 0, true, directed: true, target: 47),
    ],
  ),
  textbookDesign(
    ChapterId.ch6,
    3,
    5,
    page: 190,
    title: "指定长度的简单路径",
    topic: "指定长度的简单路径",
    prompt: "采用邻接表存储结构，编写一个算法，判别无向图中任意给定的两个顶点之间是否存在一条长度为 k 的简单路径。",
    explanation:
        "长度按边数计算。访问标记只覆盖当前路径；撤回一步时释放标记，使另一分支能重新尝试该顶点。同一点到自身的简单路径长度按 0 计。",
    template:
        _graphC +
        r'''
static bool walk(const Graph *g,int u,int t,int left,bool used[]) {
    if(u==t || left==0) return /*BLANK_1*/;
    used[u]=true;
    for(const Arc *p=g->out[u];p;p=p->next)
        if(!used[p->to] && walk(g,p->to,t,left-1,used)) {
            used[u]=false; return true;
        }
    /*BLANK_2*/
    return false;
}
bool exact_path(const Graph *g,int s,int t,int k) {
    bool used[MAXV]={false};
    return s>=0 && t>=0 && s<g->n && t<g->n && k>=0 && k<g->n && walk(g,s,t,k,used);
}
''',
    answers: ["u==t && left==0", "used[u]=false;"],
    dart:
        _adjacencyDart +
        r'''
Object solve(Map<String,dynamic> data) {
  final out=adjacency(data),s=data['start'] as int,t=data['target'] as int,k=data['k'] as int;
  if(s<0||t<0||s>=out.length||t>=out.length||k<0||k>=out.length)return false;
  final used=<int>{};
  bool visit(int u,int left){
    if(u==t || left==0)return u==t && left==0;
    used.add(u);
    final found=out[u].any((v)=>!used.contains(v)&&visit(v,left-1));
    used.remove(u);return found;
  }
  return visit(s,k);
}
''',
    cases: [
      _graphCase(
        '回溯后复用顶点',
        5,
        [
          [0, 1],
          [1, 3],
          [0, 2],
          [2, 4],
          [4, 1],
        ],
        0,
        true,
        target: 3,
        k: 4,
      ),
      _graphCase('空图', 0, [], -1, false, target: -1, k: 0),
      _graphCase('单顶点零边', 1, [], 0, true, target: 0, k: 0),
      _graphCase(
        '绕环重复顶点无效',
        5,
        [
          [0, 1],
          [1, 2],
          [2, 0],
          [0, 3],
        ],
        0,
        false,
        target: 3,
        k: 4,
      ),
      _graphCase('长度超过上界', 4, _diamond, 0, false, target: 3, k: 4),
      _graphCase('固定种子树指定深度', 48, _tree, 0, true, target: 47, k: 3),
    ],
  ),
]);
