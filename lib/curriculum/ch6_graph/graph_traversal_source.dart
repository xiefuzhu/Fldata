part of 'graph_traversal.dart';

// Matching line numbers keep the three debugger tabs on the same operation.
Map<CodeLang, List<String>> _traversalCode(TraversalMode mode) {
  if (mode == TraversalMode.breadth) {
    return const {
      CodeLang.cLike: [
        'visited ← false；初始化空队列 Q',
        '依起点优先次序，对每个未访问根 r：',
        '  visit(r)；visited[r] ← true；EnQueue(Q, r)',
        '  while Q 非空：v ← DeQueue(Q)',
        '    依次取 v 的每个邻接点 w，检查 visited[w]',
        '      若未访问：parent[w] ← v；visit(w)；置标记并入队',
        '    当前链结束，继续处理队首',
        '返回访问序列与生成森林',
      ],
      CodeLang.c99: [
        'bool seen[MAXV] = {0}; Queue q = empty_queue();',
        'for (int k=0; k<n; ++k) { int r=order[k]; if (seen[r]) continue;',
        '  seen[r]=true; visit(r); enqueue(&q,r);',
        '  while (!empty(&q)) { int v=dequeue(&q);',
        '    for (Arc *p=first[v]; p; p=p->next) { int w=p->adjvex;',
        '      if (!seen[w]) { parent[w]=v; seen[w]=true; visit(w); enqueue(&q,w); }',
        '    } }',
        '} /* all reachable trees recorded */',
      ],
      CodeLang.dart: [
        'final seen = <int>{}, q = Queue<int>();',
        'for (final r in order) { if (seen.contains(r)) continue;',
        '  seen.add(r); visit(r); q.addLast(r);',
        '  while (q.isNotEmpty) { final v = q.removeFirst();',
        '    for (final w in neighbors(v)) {',
        '      if (seen.add(w)) { parent[w]=v; visit(w); q.addLast(w); }',
        '    } }',
        '} // traversal complete',
      ],
    };
  }
  final matrix = mode == TraversalMode.matrix;
  return {
    CodeLang.cLike: [
      '初始化 visited；以 DFS(v) 实现算法 6.3',
      '算法 6.4：对起点及其余各点 r，未访问则调用 DFS(r)',
      'DFS(v)：visit(v)；visited[v] ← true',
      matrix ? '  从第 0 列开始扫描' : '  p ← vertices[v].firstarc',
      matrix
          ? '  对每一列 w：检查 arcs[v][w] 是否有边及 visited[w]'
          : '  沿 p → nextarc 扫描：w ← p.adjvex，检查 visited[w]',
      '    若有边且 w 未访问：保存树边 (v,w)，递归 DFS(w)',
      '  当前邻接点耗尽，返回上一层',
      '所有根处理完毕，返回生成森林',
    ],
    CodeLang.c99: [
      'bool seen[MAXV] = {0}; void dfs(int);',
      'void traverse(void){ for(int k=0;k<n;k++) if(!seen[order[k]]) dfs(order[k]); }',
      'void dfs(int v){ seen[v]=true; visit(v);',
      matrix
          ? '  for(int w=0; w<n; ++w){'
          : '  for(Arc *p=first[v]; p; p=p->nextarc){',
      matrix
          ? '    if(!has_edge(arcs[v][w]) || seen[w]) continue;'
          : '    int w=p->adjvex; if(seen[w]) continue;',
      '    parent[w]=v; dfs(w); }',
      '  return; }',
      '/* traverse has returned; parent stores the forest */',
    ],
    CodeLang.dart: [
      'final seen = <int>{};',
      'void traverse() { for(final r in order) { if(!seen.contains(r)) dfs(r); } }',
      'void dfs(int v) { seen.add(v); visit(v);',
      matrix
          ? '  for(var w=0; w<n; w++){'
          : '  for(var p=first[v]; p!=null; p=p.nextarc){',
      matrix
          ? '    if(!hasEdge(arcs[v][w]) || seen.contains(w)) continue;'
          : '    final w=p.adjvex; if(seen.contains(w)) continue;',
      '    parent[w]=v; dfs(w); }',
      '  return; }',
      'traverse();',
    ],
  };
}
