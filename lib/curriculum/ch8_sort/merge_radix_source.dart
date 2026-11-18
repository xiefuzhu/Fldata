part of 'merge_radix.dart';

const _passSource = {
  CodeLang.cLike: [
    '令 S=r，D=TR',
    '段长 h 从 1 起每趟翻倍',
    '依次将两段稳定归并到 D；尾部单段直接复制',
    '完成本趟，交换 S、D',
    '若 S 与 r 不同，将结果写回 r',
  ],
  CodeLang.c99: [
    'Record *s=r, *d=tr, *tmp;',
    'for (int h=1; h<n; h*=2) {',
    '  for (int l=1; l<=n; l+=2*h) Merge(s,d,l,min(l+h-1,n),min(l+2*h-1,n));',
    '  tmp=s; s=d; d=tmp; }',
    'if (s != r) for(int i=1;i<=n;i++) r[i]=s[i];',
  ],
  CodeLang.dart: [
    'var s=r, d=tr;',
    'for (var h=1; h<n; h*=2) {',
    '  for (var l=1; l<=n; l+=2*h) { merge(s,d,l,min(l+h-1,n),min(l+2*h-1,n)); }',
    '  (s,d)=(d,s); }',
    'if (!identical(s,r)) r.setRange(1,n+1,s,1);',
  ],
};

Map<CodeLang, List<String>> _source(bool radix) {
  final rows = radix
      ? const [
          (
            'r[0].next 串联原始记录，队尾游标为 0',
            'for(int p=0;p<n;p++) r[p].next=p+1; r[n].next=0;',
            'for(var p=0;p<n;p++){next[p]=p+1;} next[n]=0;',
          ),
          (
            '按最低位优先逐趟清空十个队列',
            'for(int i=0;i<digits;i++){for(int d=0;d<10;d++)f[d]=e[d]=0;',
            'for(var i=0;i<digits;i++){for(var d=0;d<10;d++){f[d]=e[d]=0;}',
          ),
          (
            'Distribute 沿旧链取当前位',
            ' for(int p=r[0].next;p;p=r[p].next){int d=digit(r[p],i);',
            ' for(var p=next[0];p!=0;p=next[p]){final d=digit(r[p],i);',
          ),
          (
            '空桶写头，否则链接旧尾，然后更新尾指针',
            '  if(!f[d]) f[d]=p; else r[e[d]].next=p; e[d]=p;}',
            '  if(f[d]==0){f[d]=p;}else{next[e[d]]=p;} e[d]=p;}',
          ),
          (
            'Collect 从头结点接入首个非空桶',
            ' int t=0; for(int d=0;d<10;d++) if(f[d]){',
            ' var t=0; for(var d=0;d<10;d++){if(f[d]!=0){',
          ),
          (
            '上一个尾结点接到下个桶头',
            '  r[t].next=f[d]; t=e[d]; }',
            '  next[t]=f[d]; t=e[d]; }}',
          ),
          ('最后一个尾结点指向 0', ' r[t].next=0;', ' next[t]=0;'),
          ('从头结点沿 next 读取结果', '}', '}'),
        ]
      : const [
          (
            'MSort 的根调用以 r 为目标，TR 为工作数组',
            '/* MSort(r,TR,1,n) when n>0; initial records reside in r */',
            '// 非空表调用 msort(r,tr,1,n)，r 保存原始记录',
          ),
          (
            '递归闭区间，T 为目标，S 为另一个缓冲区',
            'void MSort(Rec T[],Rec S[],int lo,int hi){',
            'void msort(List<Rec?> t,List<Rec?> s,int lo,int hi){',
          ),
          (
            '单记录复制原始记录到目标',
            ' if(lo==hi){T[lo]=r[lo];return;}',
            ' if(lo==hi){t[lo]=r[lo];return;}',
          ),
          (
            '左右半段递归写入 S',
            ' int m=(lo+hi)/2; MSort(S,T,lo,m); MSort(S,T,m+1,hi);',
            ' final m=(lo+hi)~/2; msort(s,t,lo,m); msort(s,t,m+1,hi);',
          ),
          (
            'Merge 初始化两段读指针和目标写指针',
            ' int i=lo,j=m+1,k=lo;',
            ' var i=lo,j=m+1,k=lo;',
          ),
          (
            '两段均未耗尽时比较，等键取左侧',
            ' while(i<=m && j<=hi){int left=S[i].key<=S[j].key;',
            ' while(i<=m && j<=hi){final left=s[i]!.key<=s[j]!.key;',
          ),
          (
            '较小记录写入 T[k] 并移动对应指针',
            '  T[k++]=left?S[i++]:S[j++];}',
            '  t[k++]=left?s[i++]:s[j++];}',
          ),
          (
            '复制左段剩余记录',
            ' while(i<=m) T[k++]=S[i++];',
            ' while(i<=m){t[k++]=s[i++];}',
          ),
          (
            '复制右段剩余记录',
            ' while(j<=hi) T[k++]=S[j++];',
            ' while(j<=hi){t[k++]=s[j++];}',
          ),
          ('目标区间已完成，返回', '}', '}'),
        ];
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
