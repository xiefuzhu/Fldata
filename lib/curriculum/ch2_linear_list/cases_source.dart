import '../../enum/ds_enums.dart';
import 'cases_polyn_book.dart';

class CaseSource {
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final l in CodeLang.values) l: [],
  };
  void add(String tag, String pseudo, String c, String dart) {
    tags[tag] = lines[CodeLang.cLike]!.length + 1;
    lines[CodeLang.cLike]!.add(pseudo);
    lines[CodeLang.c99]!.add(c);
    lines[CodeLang.dart]!.add(dart);
  }
}

CaseSource polynomialSource(bool create) {
  final s = CaseSource();
  void a(String tag, String p, String c, String d) => s.add(tag, p, c, d);
  a(
    'include',
    '// 输入无零系数、指数不重复',
    '#include <stdlib.h>',
    '// 输入无零系数、指数不重复；Dart 由 GC 回收',
  );
  a(
    'type',
    'PNode { double coef; int expn; PNode *next; }',
    'typedef struct Node { double coef; int expn; struct Node *next; } Node;',
    'class Node { Node(this.coef,this.expn); double coef; int expn; Node? next; }',
  );
  if (create) {
    a(
      'entry',
      'CreatePolyn(terms,n) {',
      'Node *CreatePolyn(const Node terms[],int n) {',
      'Node CreatePolyn(List<Node> terms) {',
    );
    a(
      'head',
      '  H=NewHead();',
      '  Node *H=calloc(1,sizeof *H); if(!H) return NULL;',
      '  final H=Node(0,-1);',
    );
    a(
      'loop',
      '  for(k=0;k<n;k++) {',
      '  for(int k=0;k<n;k++) {',
      '  for(var k=0;k<terms.length;k++) {',
    );
    a(
      'new',
      '    s=NewNode(terms[k]);',
      '    Node *s=malloc(sizeof *s); if(!s) {while(H){Node *q=H;H=H->next;free(q);}return NULL;} *s=terms[k];s->next=NULL;',
      '    final s=Node(terms[k].coef,terms[k].expn);',
    );
    a(
      'seek',
      '    p=H; q=H->next;',
      '    Node *p=H,*q=H->next;',
      '    Node p=H; Node? q=H.next;',
    );
    a(
      'compare',
      '    while(q && q->expn<s->expn) {',
      '    while(q && q->expn<s->expn) {',
      '    while(q!=null && q.expn<s.expn) {',
    );
    a(
      'walk',
      '      p=q; q=q->next;',
      '      p=q; q=q->next;',
      '      p=q; q=q.next;',
    );
    a('endWalk', '    }', '    }', '    }');
    a('snext', '    s->next=q;', '    s->next=q;', '    s.next=q;');
    a('pnext', '    p->next=s;', '    p->next=s;', '    p.next=s;');
    a('endLoop', '  }', '  }', '  }');
    a('return', '  return H;', '  return H;', '  return H;');
  } else {
    a(
      'entry',
      'AddPolyn(PA,PB) {',
      'Node *AddPolyn(Node *PA,Node *PB) {',
      'Node AddPolyn(Node PA,Node PB) {',
    );
    a(
      'init',
      '  p1=PA->next; p2=PB->next; p3=PA;',
      '  Node *p1=PA->next,*p2=PB->next,*p3=PA,*r; double sum;',
      '  Node? p1=PA.next,p2=PB.next,r; Node p3=PA; double sum;',
    );
    a(
      'loop',
      '  while(p1 && p2) {',
      '  while(p1 && p2) {',
      '  while(p1!=null && p2!=null) {',
    );
    a(
      'compare',
      '    if(p1->expn<p2->expn) {',
      '    if(p1->expn<p2->expn) {',
      '    if(p1.expn<p2.expn) {',
    );
    a(
      'takeA',
      '      p3->next=p1; p3=p1; p1=p1->next;',
      '      p3->next=p1;p3=p1;p1=p1->next;',
      '      p3.next=p1;p3=p1;p1=p1.next;',
    );
    a(
      'greater',
      '    } else if(p1->expn>p2->expn) {',
      '    } else if(p1->expn>p2->expn) {',
      '    } else if(p1.expn>p2.expn) {',
    );
    a(
      'takeB',
      '      p3->next=p2; p3=p2; p2=p2->next;',
      '      p3->next=p2;p3=p2;p2=p2->next;',
      '      p3.next=p2;p3=p2;p2=p2.next;',
    );
    a('else', '    } else {', '    } else {', '    } else {');
    a(
      'sum',
      '      sum=p1->coef+p2->coef;',
      '      sum=p1->coef+p2->coef;',
      '      sum=p1.coef+p2.coef;',
    );
    a(
      'nonzero',
      '      if(sum!=0) {',
      '      if(sum!=0) {',
      '      if(sum!=0) {',
    );
    a(
      'write',
      '        p1->coef=sum;',
      '        p1->coef=sum;',
      '        p1.coef=sum;',
    );
    a(
      'keep',
      '        p3->next=p1; p3=p1; p1=p1->next;',
      '        p3->next=p1;p3=p1;p1=p1->next;',
      '        p3.next=p1;p3=p1;p1=p1.next;',
    );
    a('zero', '      } else {', '      } else {', '      } else {');
    a(
      'saveA',
      '        r=p1; p1=p1->next;',
      '        r=p1;p1=p1->next;',
      '        r=p1;p1=r.next;',
    );
    a(
      'freeA',
      '        delete r;',
      '        free(r);r=NULL;',
      '        r=null; // C99 此处 free；Dart 不承诺即时回收',
    );
    a('endZero', '      }', '      }', '      }');
    a(
      'saveB',
      '      r=p2; p2=p2->next;',
      '      r=p2;p2=p2->next;',
      '      r=p2;p2=r.next;',
    );
    a(
      'freeB',
      '      delete r;',
      '      free(r);r=NULL;',
      '      r=null; // 相等指数的 B 结点不再保留',
    );
    a('endEqual', '    }', '    }', '    }');
    a('endLoop', '  }', '  }', '  }');
    a(
      'tail',
      '  p3->next=p1?p1:p2;',
      '  p3->next=p1?p1:p2;',
      '  p3.next=p1 ?? p2;',
    );
    a(
      'freeHead',
      '  delete PB;',
      '  free(PB);',
      '  // 调用结束后不再使用 PB；C99 在这里释放头结点',
    );
    a('return', '  return PA;', '  return PA;', '  return PA;');
  }
  a('end', '}', '}', '}');
  return s;
}

CaseSource bookSource(CaseOperation op, bool linked) {
  final s = CaseSource();
  void a(String tag, String p, String c, String d) => s.add(tag, p, c, d);
  a(
    'include',
    '// 编号唯一；演示按编号查找、按位序插删',
    '#include <stdlib.h>\n#include <string.h>',
    '// 演示会话书库；记录不等于学习进度数据库',
  );
  // Every language uses one logical source line per tag, including includes.
  s.lines[CodeLang.c99]![0] = '#include <stdlib.h>';
  a('cstring', '// 字符串比较', '#include <string.h>', '// String == 按内容比较');
  a(
    'book',
    'Book { id,title,price }',
    'typedef struct { char id[17],title[65]; double price; } Book;',
    'class Book { const Book(this.id,this.title,this.price); final String id,title; final double price; }',
  );
  if (linked) {
    a(
      'node',
      'Node { Book book; Node *next; }',
      'typedef struct Node { Book book; struct Node *next; } Node;',
      'class Node { Node(this.book); Book book; Node? next; }',
    );
  } else {
    a(
      'array',
      'SqBooks { Book a[8]; int length; }',
      'typedef struct { Book a[8];int length; } Books;',
      'class Books { Books(this.a); List<Book> a; }',
    );
  }
  if (op == CaseOperation.bookFind) {
    a(
      'entry',
      'FindBook(L,id) {',
      linked
          ? 'Node *FindBook(Node *L,const char *id) {'
          : 'int FindBook(const Books *L,const char *id) {',
      linked
          ? 'Book? FindBook(Node L,String id) {'
          : 'Book? FindBook(Books L,String id) {',
    );
    a(
      'init',
      linked ? '  p=L->next;' : '  k=0;',
      linked ? '  Node *p=L->next;' : '  int k=0;',
      linked ? '  Node? p=L.next;' : '  var k=0;',
    );
    a(
      'loop',
      linked ? '  while(p) {' : '  while(k<L.length) {',
      linked ? '  while(p) {' : '  while(k<L->length) {',
      linked ? '  while(p!=null) {' : '  while(k<L.a.length) {',
    );
    a(
      'compare',
      linked
          ? '    if(p->book.id==id) return p;'
          : '    if(L.a[k].id==id) return k+1;',
      linked
          ? '    if(strcmp(p->book.id,id)==0) return p;'
          : '    if(strcmp(L->a[k].id,id)==0) return k+1;',
      linked
          ? '    if(p.book.id==id) return p.book;'
          : '    if(L.a[k].id==id) return L.a[k];',
    );
    a(
      'walk',
      linked ? '    p=p->next;' : '    k++;',
      linked ? '    p=p->next;' : '    k++;',
      linked ? '    p=p.next;' : '    k++;',
    );
    a('endLoop', '  }', '  }', '  }');
    a(
      'return',
      '  return NOT_FOUND;',
      linked ? '  return NULL;' : '  return 0;',
      '  return null;',
    );
  } else {
    final ins = op == CaseOperation.bookInsert;
    a(
      'entry',
      ins ? 'InsertBook(L,i,e) {' : 'DeleteBook(L,i) {',
      linked
          ? (ins
                ? 'int InsertBook(Node *L,int i,Book e) {'
                : 'int DeleteBook(Node *L,int i) {')
          : (ins
                ? 'int InsertBook(Books *L,int i,Book e) {'
                : 'int DeleteBook(Books *L,int i) {'),
      linked
          ? (ins
                ? 'bool InsertBook(Node L,int i,Book e) {'
                : 'bool DeleteBook(Node L,int i) {')
          : (ins
                ? 'bool InsertBook(Books L,int i,Book e) {'
                : 'bool DeleteBook(Books L,int i) {'),
    );
    if (ins && linked) {
      a(
        'capacity',
        '  if(BookCount(L)>=8) return LIMIT; // 教学会话上限',
        '  int count=0;for(Node *q=L->next;q;q=q->next)count++;if(count>=8)return 0;',
        '  var count=0;for(Node? q=L.next;q!=null;q=q.next){count++;}if(count>=8)return false; // 教学会话上限',
      );
    }
    if (ins) {
      a(
        'unique',
        linked
            ? '  if(containsId(L,e.id)) return ERROR;'
            : '  if(containsId(L,e.id)) return ERROR;',
        linked
            ? '  for(Node *q=L->next;q;q=q->next) if(strcmp(q->book.id,e.id)==0) return 0;'
            : '  for(int k=0;k<L->length;k++) if(strcmp(L->a[k].id,e.id)==0) return 0;',
        linked
            ? '  for(Node? q=L.next;q!=null;q=q.next) {if(q.book.id==e.id) return false;}'
            : '  if(L.a.any((b)=>b.id==e.id)) return false;',
      );
    }
    if (linked) {
      a('init', '  p=L; j=0;', '  Node *p=L;int j=0;', '  Node? p=L;var j=0;');
      a(
        'walk',
        '  while(p && j<i-1) {p=p->next;j++;}',
        '  while(p && j<i-1) {p=p->next;j++;}',
        '  while(p!=null && j<i-1) {p=p.next;j++;}',
      );
      a(
        'bounds',
        ins
            ? '  if(i<1 || !p) return ERROR;'
            : '  if(i<1 || !p || !p->next) return ERROR;',
        ins
            ? '  if(i<1 || !p) return 0;'
            : '  if(i<1 || !p || !p->next) return 0;',
        ins
            ? '  if(i<1 || p==null) return false;'
            : '  if(i<1 || p==null || p.next==null) return false;',
      );
      if (ins) {
        a(
          'new',
          '  s=NewNode(e);',
          '  Node *s=malloc(sizeof *s);if(!s)return 0;s->book=e;s->next=NULL;',
          '  final s=Node(e);',
        );
        a(
          'snext',
          '  s->next=p->next;',
          '  s->next=p->next;',
          '  s.next=p.next;',
        );
        a('write', '  p->next=s;', '  p->next=s;', '  p.next=s;');
      } else {
        a('read', '  q=p->next;', '  Node *q=p->next;', '  final q=p.next!;');
        a(
          'write',
          '  p->next=q->next;',
          '  p->next=q->next;',
          '  p.next=q.next;',
        );
        a('free', '  delete q;', '  free(q);', '  // q 离开作用域后由 GC 回收');
      }
    } else {
      a(
        'bounds',
        ins
            ? '  if(i<1 || i>L.length+1 || L.length==8) return ERROR;'
            : '  if(i<1 || i>L.length) return ERROR;',
        ins
            ? '  if(i<1 || i>L->length+1 || L->length==8) return 0;'
            : '  if(i<1 || i>L->length) return 0;',
        ins
            ? '  if(i<1 || i>L.a.length+1 || L.a.length==8) return false;'
            : '  if(i<1 || i>L.a.length) return false;',
      );
      if (ins) {
        a(
          'reserve',
          '  // 使用预留槽',
          '  /* preallocated slot */',
          '  L.a.add(e); // 先扩长，随后的搬移覆盖这个临时末槽',
        );
        a(
          'shift',
          '  for(k=L.length;k>=i;k--) L.a[k]=L.a[k-1];',
          '  for(int k=L->length;k>=i;k--) L->a[k]=L->a[k-1];',
          '  for(var k=L.a.length-1;k>=i;k--) {L.a[k]=L.a[k-1];}',
        );
        a('write', '  L.a[i-1]=e;', '  L->a[i-1]=e;', '  L.a[i-1]=e;');
        a(
          'length',
          '  L.length++;',
          '  L->length++;',
          '  // List 长度已在 reserve 行更新',
        );
      } else {
        a(
          'shift',
          '  for(k=i;k<L.length;k++) L.a[k-1]=L.a[k];',
          '  for(int k=i;k<L->length;k++) L->a[k-1]=L->a[k];',
          '  for(var k=i;k<L.a.length;k++) {L.a[k-1]=L.a[k];}',
        );
        a('length', '  L.length--;', '  L->length--;', '  L.a.removeLast();');
      }
    }
    a('return', '  return OK;', '  return 1;', '  return true;');
  }
  a('end', '}', '}', '}');
  return s;
}
