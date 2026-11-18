part of 'external_sort.dart';

Map<CodeLang, List<String>> _source(ExternalMethod mode) {
  const match = (
    '从 t=(s+k)/2 上行；败者留在 ls[t]，胜者继续',
    'void adjust(int s){for(int t=(s+k)/2;t>0;t/=2){if(cmp(s,ls[t])>0){int q=ls[t];ls[t]=s;s=q;}}',
    'void adjust(int s){for(var t=(s+k)~/2;t>0;t~/=2){if(cmp(s,ls[t])>0){final q=ls[t];ls[t]=s;s=q;}}',
  );
  const champion = ('写入最终胜者的槽号', ' ls[0]=s; }', ' ls[0]=s; }');
  final lines = switch (mode) {
    ExternalMethod.merge => const [
      (
        '将 k 个 ls 槽初始化为 MINKEY 的下标 k',
        'void init(void){for(int t=0;t<k;t++)ls[t]=k;}',
        'void init(){ls.fillRange(0,k,k);}',
      ),
      (
        '每路初读一个外结点，文件结束用 MAXKEY',
        'void load(int s){b[s]=read_or_max(s);}',
        'void load(int s){b[s]=readOrMax(s);}',
      ),
      match,
      champion,
      (
        '倒序建树，然后把冠军记录写入输出段',
        'void merge(void){init(); for(int s=0;s<k;s++)load(s); for(int s=k-1;s>=0;s--)adjust(s); while(live(ls[0])){int s=ls[0];write_key(b[s]);',
        'void merge(){init();for(var s=0;s<k;s++){load(s);}for(var s=k-1;s>=0;s--){adjust(s);}while(live(ls[0])){final s=ls[0];writeKey(b[s]);',
      ),
      ('只在冠军所在路补读并重赛', ' load(s);adjust(s);}', ' load(s);adjust(s);}'),
      ('冠军为结束标记，归并完成', '}', '}'),
    ],
    ExternalMethod.replacement => const [
      (
        '初始工作区为空，段号从 1 开始',
        '/* cmp compares (run,key,slot); exhausted slots sort last. */',
        '// cmp 按段号、键和槽号比较，空槽最后。',
      ),
      (
        '从高槽向低槽初装，逐槽建败者树',
        'void load_wa(void){init();for(int s=k-1;s>=0;s--){read_into(s,1);adjust(s);}}',
        'void loadWA(){init();for(var s=k-1;s>=0;s--){readInto(s,1);adjust(s);}}',
      ),
      match,
      champion,
      (
        '切换到胜者段号后写出 MINIMAX',
        'void select_runs(void){load_wa();while(live(ls[0])){int s=ls[0];switch_run(run[s]);int minimax=key[s];write_key(minimax);',
        'void selectRuns(){loadWA();while(live(ls[0])){final s=ls[0];switchRun(run[s]);final minimax=key[s];writeKey(minimax);',
      ),
      (
        '新键小于 MINIMAX 时，冻结到下一段',
        ' if(read_next(s))run[s]=current+(key[s]<minimax);adjust(s);}}',
        ' if(readNext(s)){run[s]=current+(key[s]<minimax?1:0);}adjust(s);}}',
      ),
      (
        '胜者段号变化，封闭旧段并开启新段',
        'void switch_run(int r){if(r!=current){end_run();current=r;}}',
        'void switchRun(int r){if(r!=current){endRun();current=r;}}',
      ),
      ('所有工作区槽耗尽，关闭输出', '/* close final output run */', '// 写完末段，关闭输出'),
    ],
    ExternalMethod.optimal => const [
      (
        '将原始段长度加入最小优先队列',
        'for(int i=0;i<m;i++)push(weights[i]);',
        'for(final w in weights){queue.add(w);}',
      ),
      (
        '补 u 个零，使 (m+u−1) mod (k−1)=0',
        'int u=m<2?0:(k-1-(m-1)%(k-1))%(k-1);while(u-->0)push(0);',
        'final u=m<2?0:(k-1-(m-1)%(k-1))%(k-1);for(var i=0;i<u;i++){queue.add(BigInt.zero);}',
      ),
      (
        '取当前 k 个最小权值为孩子',
        'while(count()>1){Weight sum=0;for(int j=0;j<k;j++)sum+=pop_min();',
        'while(queue.length>1){var sum=BigInt.zero;for(var j=0;j<k;j++){sum+=queue.removeFirst();}',
      ),
      (
        '合并权值重新入队，累加 WPL',
        ' push(sum);wpl+=sum;}',
        ' queue.add(sum);wpl+=sum;}',
      ),
      ('每次归并各读、写一次', 'Weight io=2*wpl;', 'final io=BigInt.two*wpl;'),
    ],
  };
  return {
    CodeLang.cLike: [for (final r in lines) r.$1],
    CodeLang.c99: [for (final r in lines) r.$2],
    CodeLang.dart: [for (final r in lines) r.$3],
  };
}
