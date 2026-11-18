import '../../enum/ds_enums.dart';
import 'queue_sq_link.dart';

class QueueSource {
  QueueSource(QueueKind kind) {
    final linked = kind == QueueKind.linked, ring = kind == QueueKind.circular;
    void row(String tag, String c, String dart) {
      tags[tag] = lines[CodeLang.dart]!.length + 1;
      for (final lang in CodeLang.values) {
        lines[lang]!.add(lang == CodeLang.dart ? dart : c);
      }
    }

    row(
      'intro',
      '// 教学重建；OK=1，ERROR=0，OVERFLOW=-1',
      '// 教学重建；OK=1，ERROR=0，OVERFLOW=-1',
    );
    row('header', '#include <stdlib.h>', '// 数组下标模拟指针；GC 回收不保证立即发生');
    row(
      'status',
      'enum {OK=1,ERROR=0,OVERFLOW=-1};',
      'const OK=1,ERROR=0,OVERFLOW=-1;',
    );
    row(
      'type',
      linked
          ? 'typedef struct Node {int data;struct Node *next;} Node;'
          : 'typedef struct {int *base;int front,rear,M;} Queue;',
      linked
          ? 'class Node {Node(this.data,[this.next]);int data;Node? next;}'
          : 'class Queue {List<int?> base=[];int front=0,rear=0,M=0;}',
    );
    if (linked) {
      row(
        'queue',
        'typedef struct {Node *front,*rear;} Queue;',
        'class Queue {Node? front,rear;}',
      );
    }
    row(
      'init-entry',
      'int InitQueue(Queue *Q,int M) {',
      'int InitQueue(Queue Q,int M) {',
    );
    row(
      'init-alloc',
      linked
          ? '  Q->front=Q->rear=malloc(sizeof(Node));'
          : '  Q->base=malloc(M*sizeof(int)); Q->M=M;',
      linked
          ? '  Q.front=Q.rear=Node(0);'
          : '  Q.base=List<int?>.filled(M,null); Q.M=M;',
    );
    row(
      'init-set',
      linked ? '  Q->front->next=NULL;' : '  Q->front=Q->rear=0;',
      linked ? '  Q.front!.next=null;' : '  Q.front=Q.rear=0;',
    );
    row('init-return', '  return OK; }', '  return OK; }');
    row(
      'enq-entry',
      'int EnQueue(Queue *Q,int e) {',
      'int EnQueue(Queue Q,int e) {',
    );
    if (linked) {
      row(
        'enq-alloc',
        '  Node *p=malloc(sizeof(Node)); p->data=e; p->next=NULL;',
        '  final p=Node(e);',
      );
      row('enq-link', '  Q->rear->next=p;', '  Q.rear!.next=p;');
      row('enq-move', '  Q->rear=p;', '  Q.rear=p;');
    } else {
      row(
        'enq-check',
        ring
            ? '  if((Q->rear+1)%Q->M==Q->front)return OVERFLOW;'
            : '  if(Q->rear==Q->M)return OVERFLOW;',
        ring
            ? '  if((Q.rear+1)%Q.M==Q.front)return OVERFLOW;'
            : '  if(Q.rear==Q.M)return OVERFLOW;',
      );
      row('enq-write', '  Q->base[Q->rear]=e;', '  Q.base[Q.rear]=e;');
      row(
        'enq-move',
        ring ? '  Q->rear=(Q->rear+1)%Q->M;' : '  Q->rear++;',
        ring ? '  Q.rear=(Q.rear+1)%Q.M;' : '  Q.rear++;',
      );
    }
    row('enq-return', '  return OK; }', '  return OK; }');
    row(
      'deq-entry',
      'int DeQueue(Queue *Q,int *out) {',
      '(int,int?) DeQueue(Queue Q) {',
    );
    row(
      'deq-check',
      '  if(Q->front==Q->rear)return ERROR;',
      '  if(Q.front==Q.rear)return (ERROR,null);',
    );
    if (linked) {
      row('deq-save', '  Node *p=Q->front->next;', '  final p=Q.front!.next!;');
      row('deq-read', '  *out=p->data;', '  final out=p.data;');
      row('deq-link', '  Q->front->next=p->next;', '  Q.front!.next=p.next;');
      row('deq-tailcheck', '  if(Q->rear==p) {', '  if(Q.rear==p) {');
      row('deq-move', '    Q->rear=Q->front;', '    Q.rear=Q.front;');
      row('deq-close', '  }', '  }');
      row('deq-free', '  free(p);', '  // p 离开作用域后由 GC 回收');
    } else {
      row(
        'deq-read',
        '  *out=Q->base[Q->front];',
        '  final out=Q.base[Q.front];',
      );
      row(
        'deq-move',
        ring ? '  Q->front=(Q->front+1)%Q->M;' : '  Q->front++;',
        ring ? '  Q.front=(Q.front+1)%Q.M;' : '  Q.front++;',
      );
    }
    row('deq-return', '  return OK; }', '  return (OK,out); }');
    row(
      'peek-entry',
      'int GetHead(Queue *Q,int *out) {',
      '(int,int?) GetHead(Queue Q) {',
    );
    row(
      'peek-check',
      '  if(Q->front==Q->rear)return ERROR;',
      '  if(Q.front==Q.rear)return (ERROR,null);',
    );
    row(
      'peek-read',
      linked ? '  *out=Q->front->next->data;' : '  *out=Q->base[Q->front];',
      linked
          ? '  final out=Q.front!.next!.data;'
          : '  final out=Q.base[Q.front];',
    );
    row('peek-return', '  return OK; }', '  return (OK,out); }');
    row(
      'length-entry',
      'int QueueLength(Queue *Q) {',
      'int QueueLength(Queue Q) {',
    );
    if (linked) {
      row(
        'length-init',
        '  int n=0; Node *p=Q->front->next;',
        '  int n=0; Node? p=Q.front!.next;',
      );
      row(
        'length-loop',
        '  while(p){n++;p=p->next;}',
        '  while(p!=null){n++;p=p.next;}',
      );
      row('length-return', '  return n; }', '  return n; }');
    } else {
      row(
        'length-return',
        ring
            ? '  return (Q->rear-Q->front+Q->M)%Q->M; }'
            : '  return Q->rear-Q->front; }',
        ring
            ? '  return (Q.rear-Q.front+Q.M)%Q.M; }'
            : '  return Q.rear-Q.front; }',
      );
    }
    if (!linked) {
      row('demo-entry', 'Queue Demo(void) {', 'Queue Demo() {');
      row(
        'demo-init',
        '  Queue Q; int out; InitQueue(&Q,5);',
        '  final Q=Queue(); InitQueue(Q,5);',
      );
      row(
        'demo-fill',
        '  for(int e=1;e<=4;e++) EnQueue(&Q,e);',
        '  for(int e=1;e<=4;e++) {EnQueue(Q,e);}',
      );
      row(
        'demo-pop',
        '  for(int i=0;i<3;i++) DeQueue(&Q,&out);',
        '  for(int i=0;i<3;i++) {DeQueue(Q);}',
      );
      row(
        'demo-push',
        '  for(int e=9;e<=11;e++) EnQueue(&Q,e);',
        '  for(int e=9;e<=11;e++) {EnQueue(Q,e);}',
      );
      row('demo-end', '  return Q; }', '  return Q; }');
    }
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
}
