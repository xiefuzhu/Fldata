import '../../enum/ds_enums.dart';

Map<CodeLang, List<String>> exchangeSource(bool bubble) {
  final rows = bubble
      ? const [
          (
            '右端从 n−1 开始收缩',
            'void bubble(Rec r[],int n,int early){',
            'void bubble(List<Rec> r,bool early){',
          ),
          (
            '每趟将 flag 清零',
            ' for(int m=n-1;m>0;--m){ int flag=0;',
            ' for(var m=r.length-2;m>0;--m){ var flag=false;',
          ),
          (
            '顺次比较 j 与 j+1',
            '  for(int j=1;j<=m;++j) if(r[j].key>r[j+1].key){',
            '  for(var j=1;j<=m;++j){ if(r[j].key>r[j+1].key){',
          ),
          (
            '以临时记录 t 交换，置 flag 为 1',
            '   Rec t=r[j]; r[j]=r[j+1]; r[j+1]=t; flag=1; }',
            '   final t=r[j]; r[j]=r[j+1]; r[j+1]=t; flag=true; }}',
          ),
          (
            '本趟最大键落到 m+1',
            '  /* r[m+1] is settled */',
            '  // r[m+1] is settled',
          ),
          (
            '开启提前终止时，整趟无交换即退出',
            '  if(early && !flag) break;',
            '  if(early && !flag) break;',
          ),
          ('结束循环', ' }}', ' }}'),
        ]
      : const [
          (
            'Partition 划分闭区间 [low, high]',
            'int partition(Rec r[],int low,int high){',
            'int partition(List<Rec> r,int low,int high){',
          ),
          (
            '暂存区间首项，记下枢轴键',
            ' r[0]=r[low]; int pivotkey=r[low].key;',
            ' r[0]=r[low]; final pivotkey=r[low].key;',
          ),
          (
            'high 跳过大于或等于枢轴的记录',
            ' while(low<high){ while(low<high && r[high].key>=pivotkey) --high;',
            ' while(low<high){ while(low<high && r[high].key>=pivotkey){ --high; }',
          ),
          (
            '将 high 记录写到 low，坑移到 high',
            '  r[low]=r[high];',
            '  r[low]=r[high];',
          ),
          (
            'low 跳过小于或等于枢轴的记录',
            '  while(low<high && r[low].key<=pivotkey) ++low;',
            '  while(low<high && r[low].key<=pivotkey){ ++low; }',
          ),
          (
            '将 low 记录写到 high，坑移到 low',
            '  r[high]=r[low]; }',
            '  r[high]=r[low]; }',
          ),
          (
            '相遇处回填枢轴并返回其位序',
            ' r[low]=r[0]; return low; }',
            ' r[low]=r[0]; return low; }',
          ),
          (
            'QSort 递归排序闭区间',
            'void qsort_range(Rec r[],int lo,int hi){',
            'void qsortRange(List<Rec> r,int lo,int hi){',
          ),
          (
            '区间至少有两个记录才执行划分',
            ' if(lo<hi){int p=partition(r,lo,hi);',
            ' if(lo<hi){final p=partition(r,lo,hi);',
          ),
          ('先递归左区间', '  qsort_range(r,lo,p-1);', '  qsortRange(r,lo,p-1);'),
          ('再递归右区间', '  qsort_range(r,p+1,hi); }', '  qsortRange(r,p+1,hi); }'),
          ('返回调用方', '}', '}'),
        ];
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
