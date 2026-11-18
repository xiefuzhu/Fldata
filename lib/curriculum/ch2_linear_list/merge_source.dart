import '../../enum/ds_enums.dart';
import 'merge_compare.dart';

class MergeSource {
  MergeSource(MergeOperation op) {
    void add(String tag, String pseudo, String c, String dart) {
      tags[tag] = lines[CodeLang.cLike]!.length + 1;
      lines[CodeLang.cLike]!.add(pseudo);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(dart);
    }

    add(
      'include',
      '// 输入按模式满足集合或非递减约束',
      '#include <stdlib.h>',
      '// 输入按模式满足集合或非递减约束',
    );
    if (op == MergeOperation.linked) {
      add(
        'type',
        'LNode { int data; LNode *next; }',
        'typedef struct Node { int data; struct Node *next; } Node;',
        'class Node { Node(this.data); int data; Node? next; }',
      );
      add(
        'entry',
        'MergeList_L(LA,LB) {',
        'Node *MergeList_L(Node *LA,Node *LB) {',
        'Node MergeList_L(Node LA,Node LB) {',
      );
      add(
        'init',
        '  pa=LA->next; pb=LB->next; pc=LA; LC=LA;',
        '  Node *pa=LA->next,*pb=LB->next,*pc=LA,*LC=LA;',
        '  Node? pa=LA.next,pb=LB.next; Node pc=LA,LC=LA;',
      );
      add(
        'loop',
        '  while(pa && pb) {',
        '  while(pa && pb) {',
        '  while(pa!=null && pb!=null) {',
      );
      add(
        'compare',
        '    if(pa->data<=pb->data) {',
        '    if(pa->data<=pb->data) {',
        '    if(pa.data<=pb.data) {',
      );
      add(
        'attachA',
        '      pc->next=pa;',
        '      pc->next=pa;',
        '      pc.next=pa;',
      );
      add(
        'advanceA',
        '      pa=pa->next;',
        '      pa=pa->next;',
        '      pa=pa.next;',
      );
      add('else', '    } else {', '    } else {', '    } else {');
      add(
        'attachB',
        '      pc->next=pb;',
        '      pc->next=pb;',
        '      pc.next=pb;',
      );
      add(
        'advanceB',
        '      pb=pb->next;',
        '      pb=pb->next;',
        '      pb=pb.next;',
      );
      add('endBranch', '    }', '    }', '    }');
      add(
        'advanceC',
        '    pc=pc->next;',
        '    pc=pc->next;',
        '    pc=pc.next!;',
      );
      add('endLoop', '  }', '  }', '  }');
      add(
        'tail',
        '  pc->next=pa?pa:pb;',
        '  pc->next=pa?pa:pb;',
        '  pc.next=pa ?? pb;',
      );
      add(
        'free',
        '  delete LB;',
        '  free(LB);',
        '  // C99 释放 LB 头结点；Dart 在调用结束后可由 GC 回收',
      );
      add('return', '  return LC;', '  return LC;', '  return LC;');
    } else if (op == MergeOperation.sequential) {
      add(
        'entry',
        'MergeList_Sq(A,m,B,n) {',
        'int *MergeList_Sq(const int *A,int m,const int *B,int n) {',
        'List<int> MergeList_Sq(List<int> A,List<int> B) {',
      );
      add(
        'allocate',
        '  LC=new int[m+n];',
        '  int *LC=malloc((size_t)(m+n)*sizeof *LC); if(m+n && !LC) return NULL;',
        '  final m=A.length,n=B.length,LC=List<int>.filled(A.length+B.length,0);',
      );
      add(
        'init',
        '  i=0; j=0; k=0;',
        '  int i=0,j=0,k=0;',
        '  var i=0,j=0,k=0;',
      );
      add(
        'loop',
        '  while(i<m && j<n) {',
        '  while(i<m && j<n) {',
        '  while(i<m && j<n) {',
      );
      add(
        'compare',
        '    if(A[i]<=B[j]) {',
        '    if(A[i]<=B[j]) {',
        '    if(A[i]<=B[j]) {',
      );
      add(
        'copyA',
        '      LC[k]=A[i];',
        '      LC[k]=A[i];',
        '      LC[k]=A[i];',
      );
      add('advanceA', '      i++;', '      i++;', '      i++;');
      add('else', '    } else {', '    } else {', '    } else {');
      add(
        'copyB',
        '      LC[k]=B[j];',
        '      LC[k]=B[j];',
        '      LC[k]=B[j];',
      );
      add('advanceB', '      j++;', '      j++;', '      j++;');
      add('endBranch', '    }', '    }', '    }');
      add('advanceC', '    k++;', '    k++;', '    k++;');
      add('endLoop', '  }', '  }', '  }');
      add(
        'tailA',
        '  while(i<m) LC[k++]=A[i++];',
        '  while(i<m) LC[k++]=A[i++];',
        '  while(i<m) LC[k++]=A[i++];',
      );
      add(
        'tailB',
        '  while(j<n) LC[k++]=B[j++];',
        '  while(j<n) LC[k++]=B[j++];',
        '  while(j<n) LC[k++]=B[j++];',
      );
      add('return', '  return LC;', '  return LC;', '  return LC;');
    } else {
      add(
        'contract',
        '// A/B 内部无重复，A 容量至少 m+n；仅查找原 A 前缀',
        '/* A/B are sets; A capacity >= m+n; search original A prefix */',
        '// A/B 内部无重复；查找原 A 前缀，避免重复扫描已追加的 B 元素',
      );
      add(
        'entry',
        'MergeList(A,m,B,n) {',
        'int MergeList(int *A,int m,const int *B,int n) {',
        'List<int> MergeList(List<int> A,List<int> B) {',
      );
      add('init', '  length=m;', '  int length=m;', '  final m=A.length;');
      add(
        'loop',
        '  for(j=0;j<n;j++) {',
        '  for(int j=0;j<n;j++) {',
        '  for(var j=0;j<B.length;j++) {',
      );
      add(
        'read',
        '    e=B[j]; i=0;',
        '    int e=B[j],i=0;',
        '    final e=B[j]; var i=0;',
      );
      add(
        'compare',
        '    while(i<m && A[i]!=e) i++;',
        '    while(i<m && A[i]!=e) i++;',
        '    while(i<m && A[i]!=e) { i++; }',
      );
      add(
        'append',
        '    if(i==m) A[length++]=e;',
        '    if(i==m) A[length++]=e;',
        '    if(i==m) { A.add(e); }',
      );
      add('endLoop', '  }', '  }', '  }');
      add('return', '  return A;', '  return length;', '  return A;');
    }
    add('end', '}', '}', '}');
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final l in CodeLang.values) l: [],
  };
}
