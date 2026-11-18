import '../../enum/ds_enums.dart';

Map<CodeLang, List<String>> insertionSource(String method) {
  final rows = switch (method) {
    'direct' => const [
      (
        '从第 2 项开始处理',
        'void insert_sort(Rec r[], int n){ for(int i=2;i<=n;i++){',
        'void insertSort(List<Rec> r){ for(var i=2;i<r.length;i++){',
      ),
      (
        '本项小于前一项时才需移动',
        '  if(r[i].key < r[i-1].key){ int j;',
        '  if(r[i].key < r[i-1].key){ int j;',
      ),
      ('复制待插记录到监视哨', '    r[0]=r[i];', '    r[0]=r[i];'),
      ('直接后移已比较过的第一项', '    r[i]=r[i-1];', '    r[i]=r[i-1];'),
      (
        '从 i−2 向前比较，包括 r[0] 自身',
        '    for(j=i-2;r[0].key<r[j].key;--j)',
        '    for(j=i-2;r[0].key<r[j].key;--j){',
      ),
      ('后移严格大于待插键的记录', '      r[j+1]=r[j];', '      r[j+1]=r[j]; }'),
      ('从监视哨回填到 j+1', '    r[j+1]=r[0]; }', '    r[j+1]=r[0]; }'),
      ('结束本趟，继续处理下一项', '} }', '} }'),
    ],
    'binary' => const [
      (
        '从第 2 项开始处理',
        'void binary_insert(Rec r[], int n){ for(int i=2;i<=n;i++){',
        'void binaryInsert(List<Rec> r){ for(var i=2;i<r.length;i++){',
      ),
      ('每趟都暂存待插记录', '  r[0]=r[i];', '  r[0]=r[i];'),
      ('在有序区 1..i−1 内定位', '  int low=1,high=i-1;', '  var low=1,high=i-1;'),
      (
        '取下中位并比较暂存键与中点键',
        '  while(low<=high){ int mid=(low+high)/2; if(r[0].key<r[mid].key)',
        '  while(low<=high){ final mid=(low+high)~/2; if(r[0].key<r[mid].key){',
      ),
      (
        '较小则收紧右界，相等或较大则向右',
        '    high=mid-1; else low=mid+1; }',
        '    high=mid-1; }else{ low=mid+1; } }',
      ),
      (
        '由右向左后移整个区间 high+1..i−1',
        '  for(int j=i-1;j>=high+1;--j) r[j+1]=r[j];',
        '  for(var j=i-1;j>=high+1;--j){r[j+1]=r[j];}',
      ),
      ('在所有相等键之后回填', '  r[high+1]=r[0];', '  r[high+1]=r[0];'),
      ('本趟结束', '}', '}'),
      ('返回排序结果', '}', '}'),
    ],
    _ => const [
      (
        '依次读取增量',
        'void shell_sort(Rec r[], int n,const int gaps[],int count){',
        'void shellSort(List<Rec> r,List<int> gaps){',
      ),
      (
        '以 dk 为间隔组织子序列',
        'for(int t=0;t<count;t++){ int dk=gaps[t];',
        'for(final dk in gaps){',
      ),
      (
        '逐个处理 r[dk+1..n]，先比较组内前项',
        '  for(int i=dk+1;i<=n;i++){ if(r[i].key<r[i-dk].key){ int j;',
        '  for(var i=dk+1;i<r.length;i++){ if(r[i].key<r[i-dk].key){ int j;',
      ),
      ('r[0] 暂存待插记录', '    r[0]=r[i];', '    r[0]=r[i];'),
      (
        '下标为正时才比较组内关键字',
        '    for(j=i-dk;j>0 && r[0].key<r[j].key;j-=dk)',
        '    for(j=i-dk;j>0 && r[0].key<r[j].key;j-=dk){',
      ),
      ('每次跨 dk 个位置后移', '      r[j+dk]=r[j];', '      r[j+dk]=r[j]; }'),
      ('把暂存记录写回本组', '    r[j+dk]=r[0]; }}', '    r[j+dk]=r[0]; }}'),
      ('本增量的全部组排序完毕', '}', '}'),
      ('最终增量为 1，返回排序结果', '}', '}'),
    ],
  };
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
