import '../../enum/ds_enums.dart';
import 'stack_sq_link.dart';

class StackSource {
  StackSource(StackKind kind, StackOperation op) {
    void a(String tag, String p, String c, String d) {
      tags[tag] = lines[CodeLang.cLike]!.length + 1;
      lines[CodeLang.cLike]!.add(p);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(d);
    }

    final init = op == StackOperation.init,
        push = op == StackOperation.push,
        pop = op == StackOperation.pop;
    final name = init
        ? 'InitStack'
        : push
        ? 'Push'
        : pop
        ? 'Pop'
        : 'GetTop';
    a(
      'include',
      '// 由模式决定栈顶约定',
      '#include <stdlib.h>',
      '// C 指针用数组下标 / 对象引用表示',
    );
    a(
      'status',
      '// OK=1, ERROR=0, OVERFLOW=-1',
      'enum {OK=1,ERROR=0,OVERFLOW=-1};',
      'const OK=1,ERROR=0,OVERFLOW=-1;',
    );
    if (kind == StackKind.array) {
      a(
        'type',
        'SqStack { ElemType *base,*top; int stacksize; }',
        'typedef struct {int *base,*top;int stacksize;} Stack;',
        'class Stack { List<int?> data=[]; int top=0; }',
      );
      a(
        'entry',
        '$name(S${init
            ? ',capacity'
            : push
            ? ',e'
            : ',out'}) {',
        'int $name(Stack *S${init
            ? ',int capacity'
            : push
            ? ',int e'
            : ',int *out'}) {',
        'int $name(Stack S${init
            ? ',int capacity'
            : push
            ? ',int e'
            : ',List<int> out'}) {',
      );
      if (init) {
        a(
          'allocate',
          '  S.base=new ElemType[capacity];',
          '  S->base=malloc((size_t)capacity*sizeof *S->base);if(!S->base)return OVERFLOW;',
          '  S.data=List<int?>.filled(capacity,null);',
        );
        a(
          'init',
          '  S.top=S.base; S.stacksize=capacity;',
          '  S->top=S->base;S->stacksize=capacity;',
          '  S.top=0;',
        );
      } else {
        a(
          'check',
          push
              ? '  if(S.top-S.base==S.stacksize) return OVERFLOW;'
              : '  if(S.top==S.base) return ERROR;',
          push
              ? '  if(S->top-S->base==S->stacksize)return OVERFLOW;'
              : '  if(S->top==S->base)return ERROR;',
          push
              ? '  if(S.top==S.data.length)return OVERFLOW;'
              : '  if(S.top==0)return ERROR;',
        );
        if (push) {
          a('write', '  *S.top=e;', '  *S->top=e;', '  S.data[S.top]=e;');
          a('move', '  S.top++;', '  S->top++;', '  S.top++;');
        } else if (pop) {
          a('move', '  --S.top;', '  --S->top;', '  --S.top;');
          a(
            'read',
            '  out=*S.top;',
            '  *out=*S->top;',
            '  out[0]=S.data[S.top]!;',
          );
        } else {
          a(
            'read',
            '  out=*(S.top-1);',
            '  *out=*(S->top-1);',
            '  out[0]=S.data[S.top-1]!;',
          );
        }
      }
    } else if (kind == StackKind.linked) {
      a(
        'node',
        'Node { int data; Node *next; }',
        'typedef struct Node {int data;struct Node *next;} Node;',
        'class Node { Node(this.data);int data;Node? next; }',
      );
      a(
        'type',
        '// S 直接指首元，无头结点',
        '/* Stack is a Node*; updates use Node** */',
        'class Stack { Node? top; }',
      );
      a(
        'entry',
        '$name(S${init
            ? ''
            : push
            ? ',e'
            : ',out'}) {',
        'int $name(Node **S${init
            ? ''
            : push
            ? ',int e'
            : ',int *out'}) {',
        'int $name(Stack S${init
            ? ''
            : push
            ? ',int e'
            : ',List<int> out'}) {',
      );
      if (init) {
        a('init', '  S=NULL;', '  *S=NULL;', '  S.top=null;');
      } else if (push) {
        a(
          'allocate',
          '  p=NewNode(e);',
          '  Node *p=malloc(sizeof *p);if(!p)return OVERFLOW;p->data=e;p->next=NULL;',
          '  final p=Node(e);',
        );
        a('connect', '  p->next=S;', '  p->next=*S;', '  p.next=S.top;');
        a('move', '  S=p;', '  *S=p;', '  S.top=p;');
      } else {
        a(
          'check',
          '  if(!S) return ERROR;',
          '  if(!*S)return ERROR;',
          '  if(S.top==null)return ERROR;',
        );
        a(
          'read',
          '  out=S->data;',
          '  *out=(*S)->data;',
          '  out[0]=S.top!.data;',
        );
        if (pop) {
          a('save', '  p=S;', '  Node *p=*S;', '  final p=S.top!;');
          a('move', '  S=S->next;', '  *S=(*S)->next;', '  S.top=p.next;');
          a(
            'free',
            '  delete p;',
            '  free(p);',
            '  // C99 此处 free；Dart 由 GC 回收',
          );
        }
      }
    } else {
      a(
        'type',
        'DblStack { data[MAX]; top[2]; capacity; }',
        'typedef struct {int data[10],top[2],capacity;} Stack;',
        'class Stack { List<int?> data=[];List<int> top=[-1,0]; }',
      );
      a(
        'entry',
        '$name(S${init
            ? ',capacity'
            : push
            ? ',which,e'
            : ',which,out'}) {',
        'int $name(Stack *S${init
            ? ',int capacity'
            : push
            ? ',int which,int e'
            : ',int which,int *out'}) {',
        'int $name(Stack S${init
            ? ',int capacity'
            : push
            ? ',int which,int e'
            : ',int which,List<int> out'}) {',
      );
      if (init) {
        a(
          'allocate',
          '  // 建立 capacity 槽共享区',
          '  S->capacity=capacity;',
          '  S.data=List<int?>.filled(capacity,null);',
        );
        a(
          'init',
          '  S.top[0]=-1; S.top[1]=capacity;',
          '  S->top[0]=-1;S->top[1]=capacity;',
          '  S.top[0]=-1;S.top[1]=capacity;',
        );
      } else {
        a(
          'check',
          push
              ? '  if(S.top[0]+1==S.top[1])return OVERFLOW;'
              : '  if((which==0 && S.top[0]==-1)||(which==1 && S.top[1]==S.capacity))return ERROR;',
          push
              ? '  if(S->top[0]+1==S->top[1])return OVERFLOW;'
              : '  if((which==0&&S->top[0]==-1)||(which==1&&S->top[1]==S->capacity))return ERROR;',
          push
              ? '  if(S.top[0]+1==S.top[1])return OVERFLOW;'
              : '  if((which==0&&S.top[0]==-1)||(which==1&&S.top[1]==S.data.length))return ERROR;',
        );
        if (push) {
          a(
            'move',
            '  S.top[which] += (which==0 ? 1 : -1);',
            '  S->top[which]+=(which==0?1:-1);',
            '  S.top[which]+=(which==0?1:-1);',
          );
          a(
            'write',
            '  S.data[S.top[which]]=e;',
            '  S->data[S->top[which]]=e;',
            '  S.data[S.top[which]]=e;',
          );
        } else {
          a(
            'read',
            '  out=S.data[S.top[which]];',
            '  *out=S->data[S->top[which]];',
            '  out[0]=S.data[S.top[which]]!;',
          );
          if (pop) {
            a(
              'move',
              '  S.top[which] += (which==0 ? -1 : 1);',
              '  S->top[which]+=(which==0?-1:1);',
              '  S.top[which]+=(which==0?-1:1);',
            );
          }
        }
      }
    }
    a('return', '  return OK;', '  return OK;', '  return OK;');
    a('end', '}', '}', '}');
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final l in CodeLang.values) l: [],
  };
}
