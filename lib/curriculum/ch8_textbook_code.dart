import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

final ch8TextbookCode = List<CodeQuestion>.unmodifiable([
  textbookDesign(
    ChapterId.ch8,
    3,
    1,
    page: 271,
    title: "单链表简单选择排序",
    topic: "单链表简单选择排序",
    prompt: "试以单链表为存储结构，实现简单选择排序算法。",
    explanation: "每趟沿 next 扫描剩余链，找到最小记录并与本趟首结点交换记录内容。链接始终保持原顺序。",
    template: r'''
typedef struct Node { int key; struct Node *next; } Node;
void select_sort(Node *first) {
    for (Node *p = first; p; p = p->next) {
        Node *min = p;
        for (Node *q = p->next; q; q = q->next)
            if (/*BLANK_1*/) min = q;
        int saved = p->key;
        p->key = /*BLANK_2*/;
        min->key = saved;
    }
}
''',
    answers: ["q->key < min->key", "min->key"],
    dart: r'''
class Node {
  Node(this.key, this.next);
  int key;
  Node? next;
}
Object solve(Map<String,dynamic> data) {
  Node? first;
  for (final k in (data['keys'] as List).reversed) {
    first = Node(k as int, first);
  }
  for (var p = first; p != null; p = p.next) {
    var min = p;
    for (var q = p.next; q != null; q = q.next) {
      if (q.key < min.key) min = q;
    }
    final saved = p.key;
    p.key = min.key;
    min.key = saved;
  }
  return [for (var p = first; p != null; p = p.next) p.key];
}
''',
    cases: const [
      AlgorithmTestCase(name: "空表", input: {"keys": []}, expected: []),
      AlgorithmTestCase(
        name: "单项",
        input: {
          "keys": [5],
        },
        expected: [5],
      ),
      AlgorithmTestCase(
        name: "正序",
        input: {
          "keys": [1, 2, 3],
        },
        expected: [1, 2, 3],
      ),
      AlgorithmTestCase(
        name: "逆序",
        input: {
          "keys": [4, 3, 2, 1],
        },
        expected: [1, 2, 3, 4],
      ),
      AlgorithmTestCase(
        name: "重复键",
        input: {
          "keys": [3, 1, 3, 2],
        },
        expected: [1, 2, 3, 3],
      ),
      AlgorithmTestCase(
        name: "正负混合",
        input: {
          "keys": [-2, 4, -5, 0, 9, -1],
        },
        expected: [-5, -2, -1, 0, 4, 9],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch8,
    3,
    2,
    page: 271,
    title: "带头双链表双向冒泡",
    topic: "带头双链表双向冒泡",
    prompt: "有 n 个记录存储在带头结点的双向链表中，现用双向冒泡排序法对其按升序进行排序，请写出这种排序的算法。相邻两趟排序向相反方向冒泡。",
    explanation:
        "使用带头结点的双向循环链表。向右扫描将最大值送到右界，向左扫描将最小值送到左界，每趟收缩相应边界。严格大于才交换，保留等键次序。",
    template: r'''
typedef struct Node { int key; struct Node *prev, *next; } Node;
static void compare_pair(Node *a, Node *b) {
    if (a->key > b->key) {
        int saved = a->key; a->key = b->key; b->key = saved;
    }
}
void bubble(Node *head) {
    Node *left = head->next, *right = head->prev;
    while (left != right) {
        for (Node *p = left; p != right; p = p->next)
            compare_pair(p, p->next);
        right = /*BLANK_1*/;
        if (left == right) break;
        for (Node *p = right; p != left; p = p->prev)
            compare_pair(/*BLANK_2*/, p);
        left = left->next;
    }
}
''',
    answers: ["right->prev", "p->prev"],
    dart: r'''
class Node {
  Node(this.key);
  int key;
  late Node prev, next;
}
Object solve(Map<String,dynamic> data) {
  final head = Node(0);
  head.next = head.prev = head;
  for (final k in data['keys']) {
    final p = Node(k as int);
    p.prev = head.prev;
    p.next = head;
    head.prev.next = p;
    head.prev = p;
  }
  void compare(Node a, Node b) {
    if (a.key > b.key) { final saved = a.key; a.key = b.key; b.key = saved; }
  }
  var left = head.next, right = head.prev;
  while (left != right) {
    for (var p = left; p != right; p = p.next) { compare(p, p.next); }
    right = right.prev;
    if (left == right) break;
    for (var p = right; p != left; p = p.prev) { compare(p.prev, p); }
    left = left.next;
  }
  return [
    [for (var p = head.next; p != head; p=p.next) p.key],
    [for (var p = head.prev; p != head; p=p.prev) p.key],
  ];
}
''',
    cases: const [
      AlgorithmTestCase(name: "空表", input: {"keys": []}, expected: [[], []]),
      AlgorithmTestCase(
        name: "单项",
        input: {
          "keys": [5],
        },
        expected: [
          [5],
          [5],
        ],
      ),
      AlgorithmTestCase(
        name: "正序",
        input: {
          "keys": [1, 2, 3],
        },
        expected: [
          [1, 2, 3],
          [3, 2, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "逆序",
        input: {
          "keys": [4, 3, 2, 1],
        },
        expected: [
          [1, 2, 3, 4],
          [4, 3, 2, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "重复键",
        input: {
          "keys": [3, 1, 3, 2],
        },
        expected: [
          [1, 2, 3, 3],
          [3, 3, 2, 1],
        ],
      ),
      AlgorithmTestCase(
        name: "正负混合",
        input: {
          "keys": [-2, 4, -5, 0, 9, -1],
        },
        expected: [
          [-5, -2, -1, 0, 4, 9],
          [9, 4, 0, -1, -2, -5],
        ],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch8,
    3,
    3,
    page: 271,
    title: "红白蓝砾石一次分类",
    topic: "红白蓝砾石一次分类",
    prompt:
        "顺序放置的 n 个桶中各有一粒红、白或蓝色砾石。重新安排，使红色在前、白色居中、蓝色在后。每粒砾石的颜色只能看一次，只允许用交换调整位置。",
    explanation:
        "以 0、1、2 表示红、白、蓝。scan 到 last 是尚未查看的区间。每步恰好读取一粒颜色；蓝石与右界交换后，留在原位检查换来的未知石。",
    template: r'''
static void swap(int *a, int *b) {
    int tmp = *a; *a = *b; *b = tmp;
}
int arrange(int stones[], int n) {
    int red = 0, scan = 0, last = n - 1, views = 0;
    while (scan <= last) {
        ++views;
        switch (stones[scan]) {
        case 0: swap(&stones[red++], &stones[scan++]); break;
        case 1: /*BLANK_1*/; break;
        case 2: swap(&stones[scan], &stones[/*BLANK_2*/]); break;
        }
    }
    return views;
}
''',
    answers: ["++scan", "last--"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final a = List<int>.from(data['keys']);
  void swap(int i,int j) { final t=a[i]; a[i]=a[j]; a[j]=t; }
  var red=0, scan=0, last=a.length-1, views=0;
  while (scan<=last) {
    views++;
    switch (a[scan]) {
      case 0: swap(red++,scan++); break;
      case 1: scan++; break;
      case 2: swap(scan,last--); break;
    }
  }
  return [a,views];
}
''',
    cases: const [
      AlgorithmTestCase(name: "空桶", input: {"keys": []}, expected: [[], 0]),
      AlgorithmTestCase(
        name: "单蓝",
        input: {
          "keys": [2],
        },
        expected: [
          [2],
          1,
        ],
      ),
      AlgorithmTestCase(
        name: "全白",
        input: {
          "keys": [1, 1, 1],
        },
        expected: [
          [1, 1, 1],
          3,
        ],
      ),
      AlgorithmTestCase(
        name: "连续蓝",
        input: {
          "keys": [2, 2, 0, 0],
        },
        expected: [
          [0, 0, 2, 2],
          4,
        ],
      ),
      AlgorithmTestCase(
        name: "已分区",
        input: {
          "keys": [0, 1, 2],
        },
        expected: [
          [0, 1, 2],
          3,
        ],
      ),
      AlgorithmTestCase(
        name: "混合",
        input: {
          "keys": [1, 2, 0, 2, 1, 0, 1],
        },
        expected: [
          [0, 0, 1, 1, 1, 2, 2],
          7,
        ],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch8,
    3,
    4,
    page: 271,
    title: "负键记录前移",
    topic: "负键记录前移",
    prompt:
        "整理 n 个整数关键字的记录，使所有负键记录排在非负键记录之前。① 采用顺序存储结构，至多使用一个记录的辅助存储空间；② 时间复杂度为 O(n)。",
    explanation:
        "left 总指向负键区后第一个位置。顺序扫描时把遇到的负记录与该位置交换，以一个暂存记录完成交换。每项读取一次，零属于非负区。",
    template: r'''
typedef struct { int key; } Record;
void partition_sign(Record a[], int n) {
    int left = 0;
    for (int i = 0; i < n; ++i) {
        if (/*BLANK_1*/) {
            Record saved = a[left];
            a[left] = a[i]; a[i] = saved;
            /*BLANK_2*/;
        }
    }
}
''',
    answers: ["a[i].key < 0", "++left"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final a=List<int>.from(data['keys']);
  var left=0;
  for (var i=0;i<a.length;i++) {
    if (a[i]<0) { final saved=a[left]; a[left]=a[i]; a[i]=saved; left++; }
  }
  return a;
}
''',
    cases: const [
      AlgorithmTestCase(name: "空表", input: {"keys": []}, expected: []),
      AlgorithmTestCase(
        name: "零",
        input: {
          "keys": [0],
        },
        expected: [0],
      ),
      AlgorithmTestCase(
        name: "全负",
        input: {
          "keys": [-1, -3],
        },
        expected: [-1, -3],
      ),
      AlgorithmTestCase(
        name: "全非负",
        input: {
          "keys": [4, 0, 7],
        },
        expected: [4, 0, 7],
      ),
      AlgorithmTestCase(
        name: "混合",
        input: {
          "keys": [3, -1, 0, -4],
        },
        expected: [-1, -4, 0, 3],
      ),
      AlgorithmTestCase(
        name: "重复负键",
        input: {
          "keys": [0, -5, 2, -1, -5, 3],
        },
        expected: [-5, -1, -5, 0, 2, 3],
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch8,
    3,
    5,
    page: 271,
    title: "用快速划分查找 key",
    topic: "用快速划分查找 key",
    prompt:
        "借助快速排序的思想，在无序数组 r[1..n] 中查找关键字 key。成功时输出记录在 r 数组中的位置及其值，失败时显示“not find”。简要说明算法思想并编写算法。",
    explanation:
        "以区间首记录为枢轴，划分后直接判断枢轴是否命中，只继续可能含 key 的一侧。返回划分后数组中的 1 起算位置。平均线性时间，首枢轴遇不良输入时可达平方时间。",
    template: r'''
#include <stdio.h>
int find_key(int r[], int n, int key) {
    int low = 1, high = n;
    while (low <= high) {
        int i = low, j = high, pivot = r[i];
        while (i < j) {
            while (i < j && r[j] >= pivot) --j;
            r[i] = r[j];
            while (i < j && r[i] <= pivot) ++i;
            r[j] = r[i];
        }
        r[i] = pivot;
        if (key == pivot) return i;
        if (key < pivot) high = /*BLANK_1*/;
        else low = /*BLANK_2*/;
    }
    return 0;
}
void show(int r[], int n, int key) {
    int pos = find_key(r, n, key);
    if (pos) printf("%d %d", pos, r[pos]); else puts("not find");
}
''',
    answers: ["i - 1", "i + 1"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final r=[0,...List<int>.from(data['keys'])], key=data['key'] as int;
  var low=1,high=r.length-1;
  while(low<=high) {
    var i=low,j=high;
    final pivot=r[i];
    while(i<j) {
      while(i<j && r[j]>=pivot) { j--; }
      r[i]=r[j];
      while(i<j && r[i]<=pivot) { i++; }
      r[j]=r[i];
    }
    r[i]=pivot;
    if(key==pivot) return [i,r[i]];
    if(key<pivot) { high=i-1; } else { low=i+1; }
  }
  return 'not find';
}
''',
    cases: const [
      AlgorithmTestCase(
        name: "空表",
        input: {"keys": [], "key": 1},
        expected: "not find",
      ),
      AlgorithmTestCase(
        name: "单项",
        input: {
          "keys": [3],
          "key": 3,
        },
        expected: [1, 3],
      ),
      AlgorithmTestCase(
        name: "首枢轴",
        input: {
          "keys": [4, 1, 9, 2, 6],
          "key": 4,
        },
        expected: [3, 4],
      ),
      AlgorithmTestCase(
        name: "左侧",
        input: {
          "keys": [4, 1, 9, 2, 6],
          "key": 1,
        },
        expected: [1, 1],
      ),
      AlgorithmTestCase(
        name: "右侧",
        input: {
          "keys": [4, 1, 9, 2, 6],
          "key": 9,
        },
        expected: [5, 9],
      ),
      AlgorithmTestCase(
        name: "等键未中",
        input: {
          "keys": [2, 2, 2],
          "key": 3,
        },
        expected: "not find",
      ),
    ],
  ),
  textbookDesign(
    ChapterId.ch8,
    3,
    6,
    page: 271,
    title: "互异键的计数排序",
    topic: "互异键的计数排序",
    prompt:
        "给定关键字互异的记录表。对每条记录扫描待排序表，统计比它小的记录数 c，将它放在新有序表下标 c。① 给出顺序表定义；② 实现计数排序；③ 求 n 条记录时的关键字比较次数；④ 与简单选择排序比较，这种方法是否更好？为什么？",
    explanation:
        "新表下标从 0 起算。因键互异，秩从 0 到 n−1 各出现一次。跳过自身时恰有 n(n−1) 次关键字比较，若与自身也比则为 n² 次。简单选择排序只需 n(n−1)/2 次比较且原地完成，计数法需另备 n 个记录空间。",
    template: r'''
typedef struct { int key; } Record;
typedef struct { Record *data; int length; } Table;
/* out->data 已分配 in.length 个记录空间，与输入分开。 */
long long count_sort(Table in, Table *out) {
    long long comparisons = 0;
    out->length = in.length;
    for (int i = 0; i < in.length; ++i) {
        int c = 0;
        for (int j = 0; j < in.length; ++j) {
            if (j == i) continue;
            ++comparisons;
            if (/*BLANK_1*/) ++c;
        }
        out->data[/*BLANK_2*/] = in.data[i];
    }
    return comparisons;
}
''',
    answers: ["in.data[j].key < in.data[i].key", "c"],
    dart: r'''
Object solve(Map<String,dynamic> data) {
  final a=List<int>.from(data['keys']), out=List<int>.filled(a.length,0);
  var comparisons=0;
  for (var i=0;i<a.length;i++) {
    var rank=0;
    for (var j=0;j<a.length;j++) {
      if(i==j) continue;
      comparisons++;
      if(a[j]<a[i]) rank++;
    }
    out[rank]=a[i];
  }
  return [out,comparisons];
}
''',
    cases: const [
      AlgorithmTestCase(name: "空表", input: {"keys": []}, expected: [[], 0]),
      AlgorithmTestCase(
        name: "单项",
        input: {
          "keys": [5],
        },
        expected: [
          [5],
          0,
        ],
      ),
      AlgorithmTestCase(
        name: "两项",
        input: {
          "keys": [3, 1],
        },
        expected: [
          [1, 3],
          2,
        ],
      ),
      AlgorithmTestCase(
        name: "有序",
        input: {
          "keys": [1, 3, 5],
        },
        expected: [
          [1, 3, 5],
          6,
        ],
      ),
      AlgorithmTestCase(
        name: "逆序",
        input: {
          "keys": [5, 4, 3, 2, 1],
        },
        expected: [
          [1, 2, 3, 4, 5],
          20,
        ],
      ),
      AlgorithmTestCase(
        name: "正负混合",
        input: {
          "keys": [-8, 0, 9, -1, 3, 14],
        },
        expected: [
          [-8, -1, 0, 3, 9, 14],
          30,
        ],
      ),
    ],
  ),
]);
