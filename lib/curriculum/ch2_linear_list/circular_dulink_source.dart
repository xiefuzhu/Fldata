import '../../enum/ds_enums.dart';
import 'circular_dulink.dart';

class CircularDulinkSource {
  CircularDulinkSource(CircularOperation op) {
    final merge = op == CircularOperation.merge,
        del = op == CircularOperation.delete,
        wrong = op == CircularOperation.wrongInsert;
    void add(String tag, String pseudo, String c, String dart) {
      tags[tag] = lines[CodeLang.cLike]!.length + 1;
      lines[CodeLang.cLike]!.add(pseudo);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(dart);
    }

    add(
      'include',
      '// 带头结点的循环链；输入结构已正确建立',
      '#include <stdlib.h>',
      '// 快照展示 C99 生命周期；Dart 由 GC 回收',
    );
    add(
      'type',
      merge
          ? 'LNode { ElemType data; LNode *next; }'
          : 'DuLNode { ElemType data; DuLNode *prior,*next; }',
      merge
          ? 'typedef struct Node { char data; struct Node *next; } Node;'
          : 'typedef struct Node { char data; struct Node *prior,*next; } Node;',
      merge
          ? 'class Node { Node(this.data); String data; Node? next; }'
          : 'class Node { Node(this.data); String data; Node? prior,next; }',
    );
    add(
      'status',
      '// OK=1, ERROR=0, OVERFLOW=-1',
      'enum { OK=1, ERROR=0, OVERFLOW=-1 };',
      'const OK=1, ERROR=0, OVERFLOW=-1;',
    );
    if (merge) {
      add(
        'entry',
        'Concat(Ta,Tb) {',
        'Node *Concat(Node *Ta, Node *Tb) {',
        'Node Concat(Node Ta, Node Tb) {',
      );
      add(
        'empty',
        '  if (Tb->next==Tb) {',
        '  if (Tb->next==Tb) {',
        '  if (identical(Tb.next,Tb)) {',
      );
      add(
        'emptyReturn',
        '    delete Tb;',
        '    free(Tb);',
        '    // 不再返回或保留 Tb，离开调用后由 GC 回收',
      );
      add('returnA', '    return Ta;', '    return Ta;', '    return Ta;');
      add('endEmpty', '  }', '  }', '  }');
      add(
        'save',
        '  p=Ta->next;',
        '  Node *p=Ta->next;',
        '  final p=Ta.next!;',
      );
      add(
        'connect',
        '  Ta->next=Tb->next->next;',
        '  Ta->next=Tb->next->next;',
        '  Ta.next=Tb.next!.next;',
      );
      add(
        'free',
        '  delete Tb->next;',
        '  free(Tb->next);',
        '  // C99 在此释放 HB；Dart 在下一行解除引用',
      );
      add('close', '  Tb->next=p;', '  Tb->next=p;', '  Tb.next=p;');
      add('return', '  return Tb;', '  return Tb;', '  return Tb;');
    } else {
      add(
        'entry',
        del ? 'ListDelete_DuL(L,i,e) {' : 'ListInsert_DuL(L,i,e) {',
        del
            ? 'int ListDelete_DuL(Node *L,int i,char *out) {'
            : 'int ListInsert_DuL(Node *L,int i,char e) {',
        del
            ? 'int ListDelete_DuL(Node L,int i,List<String> out) {'
            : 'int ListInsert_DuL(Node L,int i,String e) {',
      );
      add(
        'cursor',
        '  p=L->next; j=1;',
        '  Node *p=L->next; int j=1;',
        '  Node p=L.next!; var j=1;',
      );
      add(
        'walk',
        '  while(p!=L && j<i) {p=p->next; j++;}',
        '  while(p!=L && j<i) {p=p->next; j++;}',
        '  while(!identical(p,L) && j<i) {p=p.next!; j++;}',
      );
      add(
        'bounds',
        del
            ? '  if(i<1 || j!=i || p==L) return ERROR;'
            : '  if(i<1 || j!=i) return ERROR;',
        del
            ? '  if(i<1 || j!=i || p==L) return ERROR;'
            : '  if(i<1 || j!=i) return ERROR;',
        del
            ? '  if(i<1 || j!=i || identical(p,L)) return ERROR;'
            : '  if(i<1 || j!=i) return ERROR;',
      );
      if (del) {
        add('read', '  e=p->data;', '  *out=p->data;', '  out[0]=p.data;');
        add(
          'deleteNext',
          '  p->prior->next=p->next;',
          '  p->prior->next=p->next;',
          '  p.prior!.next=p.next;',
        );
        add(
          'deletePrior',
          '  p->next->prior=p->prior;',
          '  p->next->prior=p->prior;',
          '  p.next!.prior=p.prior;',
        );
        add(
          'free',
          '  delete p; p=NULL;',
          '  free(p); p=NULL;',
          '  // p 离开作用域后由 GC 回收',
        );
      } else {
        add(
          'allocate',
          '  s=NewNode(e);',
          '  Node *s=malloc(sizeof *s); if(!s) return OVERFLOW; s->data=e; s->next=s->prior=NULL;',
          '  final s=Node(e);',
        );
        add(
          'first',
          '  s->prior=p->prior; // ①',
          '  s->prior=p->prior; /* 1 */',
          '  s.prior=p.prior; // ①',
        );
        void second() => add(
          'second',
          '  p->prior->next=s; // ②',
          '  p->prior->next=s; /* 2 */',
          '  p.prior!.next=s; // ②',
        );
        void third() => add(
          'third',
          '  s->next=p; // ③',
          '  s->next=p; /* 3 */',
          '  s.next=p; // ③',
        );
        void fourth() => add(
          'fourth',
          '  p->prior=s; // ④',
          '  p->prior=s; /* 4 */',
          '  p.prior=s; // ④',
        );
        if (wrong) {
          add(
            'warning',
            '  // 错误反例：④ 提前，② 写错对象',
            '  /* WRONG: 4 before 2 */',
            '  // 错误反例：不要作为正确实现使用',
          );
          fourth();
          third();
          second();
        } else {
          second();
          third();
          fourth();
        }
      }
      add('return', '  return OK;', '  return OK;', '  return OK;');
    }
    add('end', '}', '}', '}');
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
}
