import '../../enum/ds_enums.dart';
import 'linklist_ops.dart';

/// Aligned semantic lines for the three teaching implementations.
class LinkListSource {
  LinkListSource(LinkListInput input) {
    final op = input.operation, head = input.hasHead;
    void add(String tag, String pseudo, String c, String dart) {
      tags[tag] = lines[CodeLang.cLike]!.length + 1;
      lines[CodeLang.cLike]!.add(pseudo);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(dart);
    }

    add(
      'include',
      '// ElemType 为单字符；示例分配成功',
      '#include <stdlib.h>',
      '// 单字符数据；Node 由 Dart GC 管理',
    );
    add(
      'type',
      'LNode { ElemType data; LNode *next; }',
      'typedef struct LNode { char data; struct LNode *next; } LNode;',
      'class Node { Node(this.data); String data; Node? next; }',
    );
    add(
      'helper',
      '// NewNode(e) 初始化 data=e、next=NULL',
      'static LNode *newNode(char e) { LNode *s=malloc(sizeof *s); if(s){s->data=e;s->next=NULL;} return s; }',
      'class Link { Node? first; } // 可写回根指针 L',
    );
    add(
      'status',
      '// OK=1, ERROR=0, OVERFLOW=-1',
      'enum { OK=1, ERROR=0, OVERFLOW=-1 };',
      'const OK=1, ERROR=0, OVERFLOW=-1;',
    );
    final name = LinkListModule.names[op.index];
    final build =
        op == LinkListOperation.createHead ||
        op == LinkListOperation.createTail;
    final locate = op == LinkListOperation.locate;
    final init = op == LinkListOperation.init;
    final output =
        op == LinkListOperation.get || op == LinkListOperation.delete;
    add(
      'entry',
      init
          ? '$name(L) {'
          : build
          ? '$name(L, a, n) {'
          : locate
          ? '$name(L, e) {'
          : '$name(L, i, e) {',
      init
          ? 'int $name(LNode **L) {'
          : build
          ? 'int $name(LNode **L, const char a[], int n) {'
          : locate
          ? 'LNode *$name(LNode **L, char e) {'
          : output
          ? 'int $name(LNode **L, int i, char *out) {'
          : 'int $name(LNode **L, int i, char e) {',
      init
          ? 'int $name(Link L) {'
          : build
          ? 'int $name(Link L, List<String> a) {'
          : locate
          ? 'Node? $name(Link L, String e) {'
          : output
          ? 'int $name(Link L, int i, List<String> out) {'
          : 'int $name(Link L, int i, String e) {',
    );
    if (build || op == LinkListOperation.init) {
      add(
        'init',
        head ? '  L=NewNode(空);' : '  L=NULL;',
        head ? "  *L=newNode(0); if(!*L) return OVERFLOW;" : '  *L=NULL;',
        head ? "  L.first=Node('');" : '  L.first=null;',
      );
      if (build) {
        if (op == LinkListOperation.createTail) {
          add('tail', '  r=L;', '  LNode *r=*L;', '  Node? r=L.first;');
        }
        add(
          'loop',
          '  for (k=0; k<n; k++) {',
          '  for (int k=0;k<n;k++) {',
          '  for (var k=0;k<a.length;k++) {',
        );
        add(
          'allocate',
          '    s=NewNode(a[k]);',
          '    LNode *s=newNode(a[k]); if(!s) return OVERFLOW;',
          '    final s=Node(a[k]);',
        );
        if (op == LinkListOperation.createHead) {
          add(
            'first',
            head ? '    s->next=L->next;' : '    s->next=L;',
            head ? '    s->next=(*L)->next;' : '    s->next=*L;',
            head ? '    s.next=L.first!.next;' : '    s.next=L.first;',
          );
          add(
            'second',
            head ? '    L->next=s;' : '    L=s;',
            head ? '    (*L)->next=s;' : '    *L=s;',
            head ? '    L.first!.next=s;' : '    L.first=s;',
          );
        } else {
          add(
            'append',
            head ? '    r->next=s;' : '    if(r) r->next=s; else L=s;',
            head ? '    r->next=s;' : '    if(r) r->next=s; else *L=s;',
            head
                ? '    r!.next=s;'
                : '    if(r!=null) {r.next=s;} else {L.first=s;}',
          );
          add('advanceTail', '    r=s;', '    r=s;', '    r=s;');
        }
        add('endLoop', '  }', '  }', '  }');
      }
      add('return', '  return OK;', '  return OK;', '  return OK;');
    } else if (op == LinkListOperation.get || locate) {
      add(
        'cursor',
        head ? '  p=L->next; j=1;' : '  p=L; j=1;',
        head ? '  LNode *p=(*L)->next; int j=1;' : '  LNode *p=*L; int j=1;',
        head
            ? '  Node? p=L.first!.next; var j=1;'
            : '  Node? p=L.first; var j=1;',
      );
      add(
        'loop',
        locate ? '  while(p) {' : '  while(p && j<i) {',
        locate ? '  while(p) {' : '  while(p && j<i) {',
        locate ? '  while(p!=null) {' : '  while(p!=null && j<i) {',
      );
      if (locate) {
        add(
          'compare',
          '    if(p->data==e)',
          '    if(p->data==e)',
          '    if(p.data==e)',
        );
        add('found', '      return p;', '      return p;', '      return p;');
      }
      add(
        'walk',
        '    p=p->next; j++;',
        '    p=p->next; j++;',
        '    p=p.next; j++;',
      );
      add('endLoop', '  }', '  }', '  }');
      if (locate) {
        add('missing', '  return NULL;', '  return NULL;', '  return null;');
      } else {
        add(
          'bounds',
          '  if(i<1 || !p) return ERROR;',
          '  if(i<1 || !p) return ERROR;',
          '  if(i<1 || p==null) return ERROR;',
        );
        add(
          'read',
          '  e=p->data; // 输出',
          '  *out=p->data;',
          '  out[0]=p.data;',
        );
        add('return', '  return OK;', '  return OK;', '  return OK;');
      }
    } else {
      add(
        'cursor',
        head ? '  p=L; j=0;' : '  first=(i==1); p=first?NULL:L; j=1;',
        head
            ? '  LNode *p=*L; int j=0;'
            : '  int first=(i==1); LNode *p=first?NULL:*L; int j=1;',
        head
            ? '  Node? p=L.first; var j=0;'
            : '  final first=i==1; Node? p=first?null:L.first; var j=1;',
      );
      add(
        'walk',
        head
            ? '  while(p && j<i-1) {p=p->next; j++;}'
            : '  while(!first && p && j<i-1) {p=p->next; j++;}',
        head
            ? '  while(p && j<i-1) {p=p->next; j++;}'
            : '  while(!first && p && j<i-1) {p=p->next; j++;}',
        head
            ? '  while(p!=null && j<i-1) {p=p.next; j++;}'
            : '  while(!first && p!=null && j<i-1) {p=p.next; j++;}',
      );
      final del = op == LinkListOperation.delete;
      add(
        'bounds',
        head
            ? '  if(i<1 || !p || j>i-1${del ? ' || !p->next' : ''}) return ERROR;'
            : '  if(i<1 || (!first && (!p || j>i-1))${del ? ' || !(first?L:p->next)' : ''}) return ERROR;',
        head
            ? '  if(i<1 || !p || j>i-1${del ? ' || !p->next' : ''}) return ERROR;'
            : '  if(i<1 || (!first && (!p || j>i-1))${del ? ' || !(first?*L:p->next)' : ''}) return ERROR;',
        head
            ? '  if(i<1 || p==null || j>i-1${del ? ' || p.next==null' : ''}) return ERROR;'
            : '  if(i<1 || (!first && (p==null || j>i-1))${del ? ' || (first?L.first:p!.next)==null' : ''}) return ERROR;',
      );
      if (!del) {
        add(
          'allocate',
          '  s=NewNode(e);',
          '  LNode *s=newNode(e); if(!s) return OVERFLOW;',
          '  final s=Node(e);',
        );
        void first() => add(
          'first',
          head ? '  s->next=p->next;' : '  s->next=first?L:p->next;',
          head ? '  s->next=p->next;' : '  s->next=first?*L:p->next;',
          head ? '  s.next=p.next;' : '  s.next=first?L.first:p!.next;',
        );
        void second() => add(
          'second',
          head ? '  p->next=s;' : '  if(first) L=s; else p->next=s;',
          head ? '  p->next=s;' : '  if(first) *L=s; else p->next=s;',
          head ? '  p.next=s;' : '  if(first) {L.first=s;} else {p!.next=s;}',
        );
        if (input.wrongOrder) {
          add(
            'warning',
            '  // 反例：故意颠倒两次赋值',
            '  /* WRONG: loses suffix; creates self-cycle */',
            '  // 反例：失联 + 自环；不要作为正确实现使用',
          );
          second();
          first();
        } else {
          first();
          second();
        }
      } else {
        add(
          'save',
          head ? '  q=p->next;' : '  q=first?L:p->next;',
          head ? '  LNode *q=p->next;' : '  LNode *q=first?*L:p->next;',
          head ? '  Node? q=p.next!;' : '  Node? q=(first?L.first:p!.next)!;',
        );
        add(
          'unlink',
          head
              ? '  p->next=q->next;'
              : '  if(first) L=q->next; else p->next=q->next;',
          head
              ? '  p->next=q->next;'
              : '  if(first) *L=q->next; else p->next=q->next;',
          head
              ? '  p.next=q.next;'
              : '  if(first) {L.first=q.next;} else {p!.next=q.next;}',
        );
        add(
          'read',
          '  e=q->data; // 输出',
          '  *out=q->data;',
          '  out[0]=q.data;',
        );
        add(
          'free',
          '  delete q; q=NULL;',
          '  free(q); q=NULL;',
          '  q=null; // 交给 GC，不保证立即回收',
        );
      }
      add('return', '  return OK;', '  return OK;', '  return OK;');
    }
    add('end', '}', '}', '}');
    if (locate) {
      for (final source in lines.values) {
        for (var i = 0; i < source.length; i++) {
          source[i] = source[i]
              .replaceAll(' int j=1;', '')
              .replaceAll(' var j=1;', '')
              .replaceAll(' j=1;', '')
              .replaceAll(' j++;', '');
        }
      }
    }
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
}
