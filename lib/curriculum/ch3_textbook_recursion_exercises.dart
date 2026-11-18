part of 'ch3_textbook_code.dart';

CodeQuestion _ackermann() {
  AlgorithmTestCase run(String name, int m, int n, int value) =>
      _example(name, {'m': m, 'n': n}, [value, value]);
  return _design(
    9,
    title: "Ackermann 递归与非递归计算",
    topic: "ackermann",
    prompt: r'''已知 Ackermann 函数定义如下：

```text
Ack(m,n) = n+1                  当 m=0 时
           Ack(m−1,1)           当 m≠0，n=0 时
           Ack(m−1,Ack(m,n−1))  当 m≠0，n≠0 时
```

① 写出计算 Ack(m,n) 的递归算法，并根据此算法给出 Ack(2,1) 的计算过程。
② 写出计算 Ack(m,n) 的非递归算法。''',
    explanation:
        r'''由基例 Ack(0,n)=n+1 得 Ack(1,0)=Ack(0,1)=2，Ack(1,1)=Ack(0,2)=3，所以 Ack(2,0)=Ack(1,1)=3。继续展开，Ack(1,2)=Ack(0,3)=4，Ack(1,3)=Ack(0,4)=5。于是 Ack(2,1)=Ack(1,Ack(2,0))=Ack(1,3)=5。非递归程序把还要代入内层结果的 m−1 压栈，求出内层后再弹栈。演算采用非负参数及结果可表示的小规模输入。''',
    template: r'''#include <stdbool.h>
#include <stdlib.h>
unsigned Ack(unsigned m, unsigned n) {
    if (m == 0) return n + 1;
    if (n == 0) return Ack(m - 1, 1);
    return /*BLANK_1*/;
}
typedef struct Pending { unsigned m; struct Pending *next; } Pending;
bool AckIter(unsigned m, unsigned n, unsigned *result) {
    Pending *s = NULL;
    for (;;) {
        if (m == 0) {
            ++n;
            if (!s) { *result = n; return true; }
            Pending *p = s; m = p->m; s = p->next; free(p);
        } else if (n == 0) {
            --m; n = 1;
        } else {
            Pending *p = malloc(sizeof *p);
            if (!p) {
                while (s) { p = s; s = s->next; free(p); }
                return false;
            }
            p->m = /*BLANK_2*/; p->next = s; s = p;
            /*BLANK_3*/;
        }
    }
}''',
    answers: [r'''Ack(m - 1, Ack(m, n - 1))''', r'''m - 1''', r'''--n'''],
    dart: r'''int ack(int m, int n) {
  if (m == 0) return n + 1;
  if (n == 0) return ack(m - 1, 1);
  return ack(m - 1, ack(m, n - 1));
}

int iterative(int m, int n) {
  final pending = <int>[];
  while (true) {
    if (m == 0) {
      n++;
      if (pending.isEmpty) return n;
      m = pending.removeLast();
    } else if (n == 0) {
      m--;
      n = 1;
    } else {
      pending.add(m - 1);
      n--;
    }
  }
}

Object solve(Map<String, dynamic> input) {
  final m = input['m'] as int, n = input['n'] as int;
  return [ack(m, n), iterative(m, n)];
}''',
    cases: [
      run('教材指定计算', 2, 1, 5),
      run('两个零', 0, 0, 1),
      run('第二分支', 1, 0, 2),
      run('嵌套调用', 2, 2, 7),
      run('更深一层', 3, 3, 61),
      run('深栈回代', 3, 4, 125),
    ],
  );
}

CodeQuestion _listStatistics() {
  final sample = _randomValues(310, 128);
  AlgorithmTestCase run(String name, List<int> v, int? maximum, double? mean) =>
      _example(
        name,
        {'values': v},
        {'maximum': maximum, 'count': v.length, 'mean': mean},
      );
  return _design(
    10,
    title: "递归求单链表最大值、长度与均值",
    topic: "recursive-list-statistics",
    prompt: r'''已知f为单链表的表头指针，链表中存储的都是整型数据，试写出实现下列运算的递归算法：
① 求链表中的最大整数；
② 求链表的结点个数；
③ 求所有整数的平均值。''',
    explanation:
        r'''参考实现令 f 指向首个数据结点。求最大值时将首元与后缀最大值比较；计数时为空返回 0，否则加 1。求均值时递归累计总和与个数，最后作一次浮点除法。空表没有最大值和算术平均值，两个接口均报告无结果，计数为 0。''',
    template: r'''#include <stdbool.h>
#include <stddef.h>
typedef struct Node { int data; struct Node *next; } Node;
bool Maximum(const Node *f, int *value) {
    if (!f) return false;
    int tail;
    if (!Maximum(f->next, &tail) || f->data > tail) *value = f->data;
    else *value = tail;
    return true;
}
size_t Count(const Node *f) {
    return f ? /*BLANK_1*/ : 0;
}
static void Totals(const Node *f, double *sum, size_t *n) {
    if (!f) return;
    Totals(f->next, sum, n);
    *sum += f->data; ++*n;
}
bool Mean(const Node *f, double *value) {
    double sum = 0; size_t n = 0;
    Totals(f, &sum, &n);
    if (!n) return false;
    *value = /*BLANK_2*/; return true;
}''',
    answers: [r'''1 + Count(f->next)''', r'''sum / n'''],
    dart: r'''class Node {
  Node(this.value, this.next);
  final int value;
  final Node? next;
}

int? maximum(Node? f) {
  if (f == null) return null;
  final tail = maximum(f.next);
  return tail == null || f.value > tail ? f.value : tail;
}

int count(Node? f) => f == null ? 0 : 1 + count(f.next);
(int, int) totals(Node? f) {
  if (f == null) return (0, 0);
  final (sum, n) = totals(f.next);
  return (sum + f.value, n + 1);
}

Object solve(Map<String, dynamic> input) {
  Node? f;
  for (final x in (input['values'] as List).reversed) {
    f = Node(x as int, f);
  }
  final (sum, n) = totals(f);
  return {
    'maximum': maximum(f),
    'count': count(f),
    'mean': n == 0 ? null : sum / n,
  };
}''',
    cases: [
      run('正负混合', [3, -2, 7, 0], 7, 2.0),
      run('空表', [], null, null),
      run('单个负数', [-9], -9, -9.0),
      run('全重复', [4, 4, 4], 4, 4.0),
      run('末尾最大且均值有小数', [-4, -1], -1, -2.5),
      run(
        '固定种子长链',
        sample,
        sample.reduce(max),
        sample.reduce((a, b) => a + b) / sample.length,
      ),
    ],
  );
}
