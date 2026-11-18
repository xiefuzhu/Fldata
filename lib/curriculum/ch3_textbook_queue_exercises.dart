part of 'ch3_textbook_code.dart';

CodeQuestion _tailQueue() {
  final sample = _randomValues(306, 128);
  AlgorithmTestCase run(
    String name,
    List<List<Object>> ops,
    List<Object> events,
    List<int> values,
  ) => _example(name, {'ops': ops}, {'events': events, 'values': values});
  return _design(
    6,
    title: "仅设尾指针的带头循环链队",
    topic: "tail-only-queue",
    prompt:
        r'''假设以带头结点的循环链表表示队列，并且只设一个指针指向队尾元素结点（注意：不设头指针），试编写相应的置空队列、判断队列是否为空、入队和出队等算法。''',
    explanation:
        r'''队列只保存 rear，rear->next 始终是头结点。置空时保留头结点并释放数据结点，删去最后一项后 rear 回到头结点。判空、入队、出队均为 O(1)。''',
    template: r'''#include <stdlib.h>
#include <stdbool.h>
typedef struct QNode { int data; struct QNode *next; } QNode;
QNode *InitQueue(void) {
    QNode *h = malloc(sizeof *h);
    if (h) h->next = h;
    return h;
}
bool Empty(QNode *rear) { return /*BLANK_1*/; }
bool Enqueue(QNode **rear, int x) {
    QNode *p = malloc(sizeof *p);
    if (!p) return false;
    p->data = x; p->next = (*rear)->next;
    (*rear)->next = p; *rear = p;
    return true;
}
bool Dequeue(QNode **rear, int *x) {
    if (Empty(*rear)) return false;
    QNode *head = (*rear)->next, *p = head->next;
    *x = p->data;
    head->next = p->next;
    if (/*BLANK_2*/) /*BLANK_3*/;
    free(p);
    return true;
}
void ClearQueue(QNode **rear) {
    int ignored;
    while (Dequeue(rear, &ignored)) {}
}''',
    answers: [
      r'''rear->next == rear''',
      r'''p == *rear''',
      r'''*rear = head''',
    ],
    dart: r'''class Node {
  Node(this.value);
  final int value;
  late Node next;
}

Object solve(Map<String, dynamic> input) {
  var rear = Node(0);
  rear.next = rear;
  final events = <Object>[];
  int pop() {
    final head = rear.next, first = head.next;
    head.next = first.next;
    if (first == rear) rear = head;
    return first.value;
  }

  for (final op in input['ops'] as List) {
    switch (op[0]) {
      case 'empty':
        events.add(rear.next == rear);
      case 'clear':
        while (rear.next != rear) {
          pop();
        }
      case 'push':
        final p = Node(op[1] as int)..next = rear.next;
        rear.next = p;
        rear = p;
      case 'pop':
        events.add(rear.next == rear ? 'EMPTY' : pop());
    }
  }
  final head = rear.next, values = <int>[];
  for (var p = head.next; p != head; p = p.next) {
    values.add(p.value);
  }
  return {'events': events, 'values': values};
}''',
    cases: [
      run(
        '入队出队',
        [
          ['push', 2],
          ['push', 5],
          ['pop'],
        ],
        [2],
        [5],
      ),
      run(
        '空表置空',
        [
          ['clear'],
          ['empty'],
          ['pop'],
        ],
        [true, 'EMPTY'],
        [],
      ),
      run(
        '删除唯一结点再入队',
        [
          ['push', 4],
          ['pop'],
          ['empty'],
          ['push', 6],
        ],
        [4, true],
        [6],
      ),
      run(
        '相同元素',
        [
          ['push', 3],
          ['push', 3],
          ['pop'],
          ['pop'],
        ],
        [3, 3],
        [],
      ),
      run(
        '非空置空后复用',
        [
          ['push', 1],
          ['push', 2],
          ['clear'],
          ['push', 3],
          ['pop'],
          ['empty'],
        ],
        [3, true],
        [],
      ),
      run(
        '固定种子 FIFO',
        [
          for (final x in sample) ['push', x],
          for (final _ in sample) ['pop'],
        ],
        sample,
        [],
      ),
    ],
  );
}

CodeQuestion _tagQueue() {
  final sample = _randomValues(307, 128);
  AlgorithmTestCase run(
    String name,
    int m,
    List<List<Object>> ops,
    List<Object> events,
    int f,
    int r,
    int tag,
  ) => _example(
    name,
    {'capacity': m, 'ops': ops},
    {'events': events, 'front': f, 'rear': r, 'tag': tag},
  );
  return _design(
    7,
    title: "用 tag 区分队空与队满",
    topic: "tagged-circular-queue",
    prompt:
        r'''假设以数组Q[m]存放循环队列中的元素，同时设置一个标志tag，以tag==0和tag==1来区别在队头指针（front）和队尾指针（rear）相等时，队列状态为“空”还是“满”。试编写与此结构相应的插入（enqueue）和删除（dequeue）算法。''',
    explanation:
        r'''front 指向队头，rear 指向下一写入槽。成功插入后令 tag=1，成功删除后令 tag=0；仅在两指针重合时读取 tag 来区分满与空。容量 m 为正时，全部 m 个槽都可使用。''',
    template: r'''#include <stdbool.h>
typedef struct { int *data, m, front, rear, tag; } Queue;
void Init(Queue *q, int cells[], int m) {
    q->data = cells; q->m = m; q->front = q->rear = q->tag = 0;
}
bool enqueue(Queue *q, int x) {
    if (/*BLANK_1*/) return false;
    q->data[q->rear] = x;
    q->rear = (q->rear + 1) % q->m;
    q->tag = 1; return true;
}
bool dequeue(Queue *q, int *x) {
    if (/*BLANK_2*/) return false;
    *x = q->data[q->front];
    q->front = (q->front + 1) % q->m;
    q->tag = 0; return true;
}''',
    answers: [
      r'''q->front == q->rear && q->tag == 1''',
      r'''q->front == q->rear && q->tag == 0''',
    ],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final m = input['capacity'] as int,
      data = List<int>.filled(m, 0),
      events = <Object>[];
  var front = 0, rear = 0, tag = 0;
  for (final op in input['ops'] as List) {
    if (op[0] == 'push') {
      final full = front == rear && tag == 1;
      events.add(!full);
      if (!full) {
        data[rear] = op[1] as int;
        rear = (rear + 1) % m;
        tag = 1;
      }
    } else if (front == rear && tag == 0) {
      events.add('EMPTY');
    } else {
      events.add(data[front]);
      front = (front + 1) % m;
      tag = 0;
    }
  }
  return {'events': events, 'front': front, 'rear': rear, 'tag': tag};
}''',
    cases: [
      run(
        '满后回绕',
        3,
        [
          ['push', 4],
          ['push', 6],
          ['push', 8],
          ['pop'],
          ['push', 9],
        ],
        [true, true, true, 4, true],
        1,
        1,
        1,
      ),
      run(
        '空队删除',
        2,
        [
          ['pop'],
        ],
        ['EMPTY'],
        0,
        0,
        0,
      ),
      run(
        '单槽满与空',
        1,
        [
          ['push', 4],
          ['push', 8],
          ['pop'],
          ['pop'],
        ],
        [true, false, 4, 'EMPTY'],
        0,
        0,
        0,
      ),
      run(
        '重复值占满',
        2,
        [
          ['push', 3],
          ['push', 3],
        ],
        [true, true],
        0,
        0,
        1,
      ),
      run(
        '尾端回到首端',
        2,
        [
          ['push', 1],
          ['pop'],
          ['push', 2],
          ['pop'],
        ],
        [true, 1, true, 2],
        0,
        0,
        0,
      ),
      run(
        '固定种子多轮回绕',
        7,
        [
          for (final v in sample) ...[
            ['push', v],
            ['pop'],
          ],
        ],
        [
          for (final v in sample) ...[true, v],
        ],
        sample.length % 7,
        sample.length % 7,
        0,
      ),
    ],
  );
}

CodeQuestion _deque() {
  final sample = _randomValues(308, 128);
  AlgorithmTestCase run(
    String name,
    int m,
    List<List<Object>> ops,
    List<Object> events,
    List<int> values,
  ) => _example(
    name,
    {'capacity': m, 'ops': ops},
    {'events': events, 'values': values},
  );
  return _design(
    8,
    title: "循环双端队列",
    topic: "circular-deque",
    prompt: r'''如果允许在循环队列的两端都可以进行插入和删除操作。要求：
① 写出循环队列的类型定义；
② 写出“从队尾删除”和“从队头插入”的算法。''',
    explanation:
        r'''front 指向首元素，rear 指向队尾后一个槽，用 count 区分空满。队头插入先将 front 循环前移，再写入；队尾删除先将 rear 循环前移，再读出。C 代码同时给出两个常规端点操作，以便从任意队列状态演示这两个新操作。''',
    template: r'''#include <stdbool.h>
typedef struct { int *data, m, front, rear, count; } Deque;
void Init(Deque *d, int cells[], int m) {
    d->data = cells; d->m = m; d->front = d->rear = d->count = 0;
}
bool PushFront(Deque *d, int x) {
    if (d->count == d->m) return false;
    d->front = /*BLANK_1*/;
    d->data[d->front] = x; ++d->count; return true;
}
bool PopBack(Deque *d, int *x) {
    if (d->count == 0) return false;
    d->rear = /*BLANK_2*/;
    *x = d->data[d->rear]; --d->count; return true;
}
bool PushBack(Deque *d, int x) {
    if (d->count == d->m) return false;
    d->data[d->rear] = x; d->rear = (d->rear + 1) % d->m;
    ++d->count; return true;
}
bool PopFront(Deque *d, int *x) {
    if (!d->count) return false;
    *x = d->data[d->front]; d->front = (d->front + 1) % d->m;
    --d->count; return true;
}''',
    answers: [
      r'''d->front == 0 ? d->m - 1 : d->front - 1''',
      r'''d->rear == 0 ? d->m - 1 : d->rear - 1''',
    ],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final m = input['capacity'] as int,
      data = List<int>.filled(m, 0),
      out = <Object>[];
  var f = 0, r = 0, count = 0;
  for (final op in input['ops'] as List) {
    final cmd = op[0] as String;
    if (cmd == 'pushFront' || cmd == 'pushBack') {
      out.add(count < m);
      if (count == m) continue;
      if (cmd == 'pushFront') {
        f = (f - 1) % m;
        data[f] = op[1] as int;
      } else {
        data[r] = op[1] as int;
        r = (r + 1) % m;
      }
      count++;
    } else if (count == 0) {
      out.add('EMPTY');
    } else {
      if (cmd == 'popBack') {
        r = (r - 1) % m;
        out.add(data[r]);
      } else {
        out.add(data[f]);
        f = (f + 1) % m;
      }
      count--;
    }
  }
  return {
    'events': out,
    'values': [for (var i = 0; i < count; i++) data[(f + i) % m]],
  };
}''',
    cases: [
      run(
        '两端混合',
        3,
        [
          ['pushBack', 2],
          ['pushFront', 1],
          ['pushBack', 3],
          ['popBack'],
          ['popFront'],
        ],
        [true, true, true, 3, 1],
        [2],
      ),
      run(
        '空队两端删除',
        2,
        [
          ['popBack'],
          ['popFront'],
        ],
        ['EMPTY', 'EMPTY'],
        [],
      ),
      run(
        '单槽队',
        1,
        [
          ['pushFront', 7],
          ['pushFront', 9],
          ['popBack'],
        ],
        [true, false, 7],
        [],
      ),
      run(
        '全重复',
        3,
        [
          ['pushFront', 2],
          ['pushFront', 2],
          ['popBack'],
        ],
        [true, true, 2],
        [2],
      ),
      run(
        '跨过零下标',
        2,
        [
          ['pushFront', 3],
          ['popBack'],
          ['pushBack', 6],
          ['pushFront', 5],
        ],
        [true, 3, true, true],
        [5, 6],
      ),
      run(
        '固定种子从两端通过',
        5,
        [
          for (final v in sample) ...[
            ['pushFront', v],
            ['popBack'],
          ],
        ],
        [
          for (final v in sample) ...[true, v],
        ],
        [],
      ),
    ],
  );
}
