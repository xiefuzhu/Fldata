import '../../enum/ds_enums.dart';
import 'recursion_hanoi.dart';

class RecursionSource {
  RecursionSource(RecursionKind kind) {
    void row(String tag, String c, String dart, {String? like}) {
      tags[tag] = lines[CodeLang.dart]!.length + 1;
      lines[CodeLang.cLike]!.add(like ?? c);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(dart);
    }

    row('intro', '// 教学重建；调用顺序显式展开', '// 教学重建；调用顺序显式展开');
    if (kind == RecursionKind.hanoi) {
      row('header', '#include <stdio.h>', '// A 起点，B 辅助，C 终点');
      row(
        'moveDef',
        'void move(char A,int n,char C){printf("%c %d %c\\n",A,n,C);}',
        r'void move(String A,int n,String C){print("$A $n $C");}',
      );
      row(
        'entry',
        'void Hanoi(int n,char A,char B,char C) {',
        'void Hanoi(int n,String A,String B,String C) {',
      );
      row('check', '  if(n==1) {', '  if(n==1) {');
      row('base', '    move(A,1,C);', '    move(A,1,C);');
      row('baseReturn', '    return;', '    return;');
      row('else', '  }', '  }');
      row('call1', '  Hanoi(n-1,A,C,B);', '  Hanoi(n-1,A,C,B);');
      row('ret1', '  // RetLoc1: 第一次递归返回', '  // RetLoc1: 第一次递归返回');
      row('move', '  move(A,n,C);', '  move(A,n,C);');
      row('call2', '  Hanoi(n-1,B,A,C);', '  Hanoi(n-1,B,A,C);');
      row('ret2', '  // RetLoc2: 第二次递归返回', '  // RetLoc2: 第二次递归返回');
      row('return', '  return;', '  return;');
      row('end', '}', '}');
    } else if (kind == RecursionKind.traverse) {
      row('header', '#include <stdio.h>', '// 无头结点数据链；NULL 终止');
      row(
        'node',
        'typedef struct Node {int data;struct Node *next;} Node;',
        'class Node {Node(this.data,[this.next]);int data;Node? next;}',
      );
      row(
        'entry',
        'void TraverseList(Node *p) {',
        'void TraverseList(Node? p) {',
      );
      row('check', '  if(p==NULL) return;', '  if(p==null) return;');
      row('print', '  printf("%d ",p->data);', '  print(p.data);');
      row('call1', '  TraverseList(p->next);', '  TraverseList(p.next);');
      row('ret1', '  // RetLoc1: 子链返回，继续返回上层', '  // RetLoc1: 子链返回，继续返回上层');
      row('return', '  return;', '  return;');
      row('end', '}', '}');
    } else {
      final fib = kind == RecursionKind.fibonacci, name = fib ? 'Fib' : 'Fact';
      row('entry', 'int $name(int n) {', 'int $name(int n) {');
      row(
        'check',
        '  if(n<=${fib ? 2 : 1}) return 1;',
        '  if(n<=${fib ? 2 : 1}) return 1;',
      );
      row('call1', '  int a=$name(n-1);', '  final a=$name(n-1);');
      row('ret1', '  // RetLoc1: a 已接收子调用结果', '  // RetLoc1: a 已接收子调用结果');
      if (fib) {
        row('call2', '  int b=Fib(n-2);', '  final b=Fib(n-2);');
        row('ret2', '  // RetLoc2: b 已接收子调用结果', '  // RetLoc2: b 已接收子调用结果');
      }
      row(
        'return',
        fib ? '  return a+b;' : '  return n*a;',
        fib ? '  return a+b;' : '  return n*a;',
      );
      row('end', '}', '}');
    }
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
}
