part of 'minimum_spanning_tree.dart';

// The membership bit also distinguishes a queued zero-weight edge from a vertex in U.
const _primCode = {
  CodeLang.cLike: [
    '加入根 u；用 arcs[u][j] 初始化 closedge[j]',
    'k ← U 外 lowcost 最小且有限的顶点；不存在则结束本分量',
    '选取 (adjvex[k], k)，k 加入 U；lowcost[k] ← 0',
    '对每个 j ∉ U，比较 arcs[k][j] 与 lowcost[j]',
    '  严格变小时 closedge[j] ← (k, arcs[k][j])',
    '对尚未并入的分量重复上述过程，输出森林',
  ],
  CodeLang.c99: [
    'for_each_new_root(u) { init_cut(u, closedge, inU);',
    '  while ((k=min_outside(closedge,inU)) >= 0) {',
    '    take(closedge[k].adjvex,k); inU[k]=1; closedge[k].lowcost=0;',
    '    for(int j=0;j<n;j++) if(!inU[j] && arcs[k][j]<closedge[j].lowcost)',
    '      closedge[j]=(CloseEdge){k,arcs[k][j]};',
    '  } }',
  ],
  CodeLang.dart: [
    'for(final u in roots){ if(inU.contains(u)) continue; initCut(u);',
    '  while(true){ final k=minOutside(closedge,inU); if(k==null) break;',
    '    take(closedge[k].adjvex,k); inU.add(k); closedge[k].lowcost=0;',
    '    for(final j in vertices.where((v)=>!inU.contains(v))) { if(arcs[k][j]<closedge[j].lowcost)',
    '      closedge[j]=CloseEdge(k,arcs[k][j]); }',
    '  } }',
  ],
};
const _kruskalCode = {
  CodeLang.cLike: [
    '按权值排序 Edge；Vexset[i] ← i',
    '对每条边 (i,j)：vs1 ← Vexset[i]；vs2 ← Vexset[j]',
    '  若 vs1 = vs2，舍弃构成回路的边',
    '  否则采用此边，将 Vexset 中所有 vs2 改为 vs1',
    '输出已采用的边及总权值',
  ],
  CodeLang.c99: [
    'sort_by_weight(Edge,e); for(int j=0;j<n;j++) Vexset[j]=j;',
    'for(int k=0;k<e;k++){ int a=Vexset[Edge[k].i], b=Vexset[Edge[k].j];',
    '  if(a==b) continue;',
    '  take(Edge[k]); for(int j=0;j<n;j++) if(Vexset[j]==b) Vexset[j]=a;',
    '}',
  ],
  CodeLang.dart: [
    'final edges=stableByWeight(input), vexset=List.generate(n,(i)=>i);',
    'for(final e in edges){ final a=vexset[e.i], b=vexset[e.j];',
    '  if(a==b) continue;',
    '  take(e); for(var j=0;j<n;j++){ if(vexset[j]==b) vexset[j]=a; }',
    '}',
  ],
};
