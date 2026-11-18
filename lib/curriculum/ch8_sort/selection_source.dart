part of 'selection_sort.dart';

Map<CodeLang, List<String>> selectionSource(SelectionMethod method) {
  final rows = switch (method) {
    SelectionMethod.simple => const [
      (
        '在顺序表中选择最小记录',
        'void SelectSort(Rec r[], int n) {',
        'void selectSort(List<Rec> r) { final n=r.length-1;',
      ),
      (
        '第 i 趟先取 k=i',
        ' for(int i=1;i<n;i++){ int k=i;',
        ' for(var i=1;i<n;i++){ var k=i;',
      ),
      (
        '扫描 i+1..n，比较候选',
        '  for(int j=i+1;j<=n;j++) if(r[j].key<r[k].key)',
        '  for(var j=i+1;j<=n;j++){ if(r[j].key<r[k].key)',
      ),
      ('记录最小键的位置', '    k=j;', '    k=j; }'),
      (
        '不在同槽时交换',
        '  if(i!=k){Rec t=r[i]; r[i]=r[k]; r[k]=t;}',
        '  if(i!=k){final t=r[i]; r[i]=r[k]; r[k]=t;}',
      ),
      ('有序前缀延长一项', ' }}', ' }}'),
    ],
    SelectionMethod.heap => const [
      (
        '算法 8.7、8.8、8.9 使用同一顺序表',
        'void HeapAdjust(Rec r[], int s, int m);',
        '// r[1..n]',
      ),
      (
        'CreatHeap 从最后的非叶向根调整',
        'void CreatHeap(Rec r[],int n){for(int s=n/2;s>=1;s--) HeapAdjust(r,s,n);}',
        'void creatHeap(List<Rec> r,int n){for(var s=n~/2;s>=1;s--) heapAdjust(r,s,n);}',
      ),
      (
        'HeapAdjust 暂存父记录，向下筛选',
        'void HeapAdjust(Rec r[],int s,int m){Rec rc=r[s]; for(int j=2*s;j<=m;j*=2){',
        'void heapAdjust(List<Rec> r,int s,int m){final rc=r[s]; for(var j=2*s;j<=m;j*=2){',
      ),
      (
        '若右孩子更大则改选右孩子',
        ' if(j<m && r[j].key<r[j+1].key) ++j;',
        ' if(j<m && r[j].key<r[j+1].key) ++j;',
      ),
      (
        '暂存键足够大时停止下筛',
        ' if(rc.key>=r[j].key) break;',
        ' if(rc.key>=r[j].key) break;',
      ),
      ('孩子上移，空位移到 j', ' r[s]=r[j]; s=j; }', ' r[s]=r[j]; s=j; }'),
      ('rc 写入最后的空位', ' r[s]=rc; }', ' r[s]=rc; }'),
      (
        'HeapSort 先建初始大根堆',
        'void HeapSort(Rec r[],int n){ CreatHeap(r,n);',
        'void heapSort(List<Rec> r,int n){creatHeap(r,n);',
      ),
      (
        '堆顶与末项交换',
        ' for(int i=n;i>1;i--){Rec x=r[1]; r[1]=r[i]; r[i]=x;',
        ' for(var i=n;i>1;i--){final x=r[1]; r[1]=r[i]; r[i]=x;',
      ),
      ('缩小堆的有效区间', '  int m=i-1;', '  final m=i-1;'),
      ('对剩余区间自根调整', '  HeapAdjust(r,1,m);', '  heapAdjust(r,1,m);'),
      ('有序序列留在原表', ' }}', ' }}'),
    ],
    SelectionMethod.tournament => const [
      (
        '把记录放入叶子，空叶代表 ∞',
        '/* w stores original record indices; 0 represents infinity. */',
        '// w 存原始记录下标，0 表示无穷。',
      ),
      (
        '从最下层比赛起，自底向上建树',
        '/* For leaf base L, w[L+i-1]=i for i in 1..n; pad with 0. */',
        '// 叶基址 L，前 n 片叶存 1..n，其余填 0。',
      ),
      (
        '两侧有效时比较关键字，同键时左侧胜出',
        'void match(int p){int a=w[2*p],b=w[2*p+1]; w[p]=!a?b:(!b||key[a]<=key[b]?a:b);}',
        'void match(int p){final a=w[2*p],b=w[2*p+1]; w[p]=a==0?b:b==0||key[a]<=key[b]?a:b;}',
      ),
      (
        '输出根指向的原始记录',
        'void selectTree(void){for(int p=L-1;p>0;--p)match(p); for(int i=1;i<=n;++i){int k=w[1];out[i]=in[k];',
        'void selectTree(){for(var p=L-1;p>0;--p){match(p);} for(var i=1;i<=n;++i){final k=w[1];out[i]=records[k];',
      ),
      (
        '尚需输出时，胜者原叶改为无穷',
        ' if(i<n){int p=L+k-1; w[p]=0;',
        ' if(i<n){var p=L+k-1; w[p]=0;',
      ),
      (
        '沿该叶到根逐层重赛',
        ' while(p>1){p/=2; match(p);} }',
        ' while(p>1){p=p~/2; match(p);} }',
      ),
      ('所有记录均已输出', ' }}', ' }}'),
    ],
  };
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
