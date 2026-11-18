part of 'array_matrix.dart';

const _transposeSource = {
  CodeLang.cLike: [
    '快速转置(A)',
    '  num 各列置零',
    '  对每项 t：num[t.col]++',
    '  cpot[1] ← 1',
    '  从第二列起：cpot[c] ← cpot[c−1] + num[c−1]',
    '  依次读取原表 t',
    '    p ← cpot[t.col]',
    '    B[p] ← (t.col,t.row,t.value)',
    '    cpot[t.col]++',
    '  返回 B',
  ],
  CodeLang.c99: [
    'void transpose(Triple A[], int tu,int cols,Triple B[]) {',
    '  int num[6]={0}, cpot[6];',
    '  for(int i=1;i<=tu;i++) ++num[A[i].col];',
    '  cpot[1]=1;',
    '  for(int c=2;c<=cols;c++) cpot[c]=cpot[c-1]+num[c-1];',
    '  for(int i=1;i<=tu;i++){ Triple t=A[i];',
    '    int p=cpot[t.col];',
    '    B[p]=(Triple){t.col,t.row,t.value};',
    '    ++cpot[t.col];',
    '  } }',
  ],
  CodeLang.dart: [
    'List<Triple?> transpose(List<Triple> a,int cols) {',
    '  final num=List.filled(cols+1,0), cpot=List.filled(cols+1,0);',
    r'  for(final t in a) { num[t.$2]++; }',
    '  cpot[1]=1;',
    '  for(var c=2;c<=cols;c++) { cpot[c]=cpot[c-1]+num[c-1]; }',
    '  final b=List<Triple?>.filled(a.length+1,null); for(final t in a) {',
    r'    final p=cpot[t.$2];',
    r'    b[p]=(t.$2,t.$1,t.$3);',
    r'    cpot[t.$2]++;',
    '  } return b; }',
  ],
};

TraceTimeline _transposeTrace(MatrixInput a) {
  final builder = TraceBuilder(
    moduleId: 'ch4_array_matrix',
    inputSummary: '三元组快速转置',
    codeLines: _transposeSource,
  );
  final num = List.filled(a.cols + 1, 0),
      start = List<int?>.filled(a.cols + 1, null),
      cpot = List<int?>.filled(a.cols + 1, null),
      out = List<Triple?>.filled(a.triples.length + 1, null);
  var scans = 0;
  String format(Triple? t) => t == null ? '·' : '(${t.$1},${t.$2},${t.$3})';
  void step(
    int line,
    String title,
    String explanation, {
    int col = 0,
    int src = 0,
    int dest = 0,
    bool wrote = false,
    bool done = false,
  }) {
    final active = NodeVisualState.active;
    final lines = [line];
    builder.step(
      title: title,
      explain: explanation,
      cLikeLines: lines,
      c99Lines: lines,
      dartLines: lines,
      deltaRead: line == 3 || line == 6 ? 1 : 0,
      deltaWrite: wrote ? 1 : 0,
      vars: {
        'tu': '${a.triples.length}',
        '已检查原表项': '$scans',
        '普通转置检查项': '${a.cols * a.triples.length}',
        if (col > 0) 'col': '$col',
        if (dest > 0) 'p': '$dest',
      },
      milestone: line == 4 || wrote || done,
      scene: SceneSnapshot(
        nodes: [
          for (final (prefix, x, title) in [
            ('src', 20.0, '原表 A · ${a.rows}×${a.cols}'),
            ('dst', 290.0, '转置 B · ${a.cols}×${a.rows}'),
          ]) ...[
            SceneNode(
              id: prefix,
              label: title,
              x: x,
              y: 14,
              width: 158,
              height: 36,
            ),
            for (var i = 1; i <= a.triples.length; i++)
              SceneNode(
                id: '$prefix-$i',
                label: format(prefix == 'src' ? a.triples[i - 1] : out[i]),
                indexBadge: '[$i]',
                x: x,
                y: 70 + 60.0 * (i - 1),
                width: 158,
                height: 44,
                visualState: i == (prefix == 'src' ? src : dest)
                    ? active
                    : NodeVisualState.normal,
              ),
          ],
        ],
        edges: [
          if (src > 0 && dest > 0 && wrote)
            SceneEdge(
              id: 'write',
              fromNodeId: 'src-$src',
              toNodeId: 'dst-$dest',
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'columns',
            title: '各列计数与目标位置',
            columns: ['列', 'num', '起始', 'cpot'],
            rows: [
              for (var c = 1; c <= a.cols; c++)
                ['$c', '${num[c]}', '${start[c] ?? "·"}', '${cpot[c] ?? "·"}'],
            ],
            highlightedRows: {if (col > 0) col - 1},
          ),
          AuxTableSnapshot(
            id: 'output',
            title: '转置三元组',
            columns: ['位序', '(行,列,值)'],
            rows: [
              for (var i = 1; i < out.length; i++) ['$i', format(out[i])],
            ],
          ),
        ],
      ),
    );
  }

  step(2, '初始化列计数', '转置前的第 c 列成为转置后的第 c 行。');
  for (var i = 0; i < a.triples.length; i++) {
    final c = a.triples[i].$2;
    num[c]++;
    scans++;
    step(3, '第 $c 列计数为 ${num[c]}', '扫描原表第 ${i + 1} 项。', col: c, src: i + 1);
  }
  start[1] = cpot[1] = 1;
  step(4, 'cpot[1] = 1', '目标表从第 1 项写入。', col: 1);
  for (var c = 2; c <= a.cols; c++) {
    start[c] = cpot[c] = start[c - 1]! + num[c - 1];
    step(5, '第 $c 列起始位置 ${start[c]}', '前一列起点加上该列的项数。空列占零项。', col: c);
  }
  for (var i = 0; i < a.triples.length; i++) {
    final t = a.triples[i], c = t.$2, p = cpot[c]!;
    scans++;
    step(6, '读取 A[${i + 1}]', format(t), col: c, src: i + 1);
    step(7, '定位 B[$p]', '读取 cpot[$c] = $p。', col: c, src: i + 1, dest: p);
    out[p] = (c, t.$1, t.$3);
    step(
      8,
      '写入 B[$p]',
      '交换行列，保持原值 ${t.$3}。',
      col: c,
      src: i + 1,
      dest: p,
      wrote: true,
    );
    cpot[c] = p + 1;
    step(9, '推进 cpot[$c]', '下一个同列元素将写入第 ${p + 1} 项。', col: c, src: i + 1);
  }
  step(
    10,
    '转置完成',
    '逐列查找需检查 ${a.cols * a.triples.length} 次原表项。快速转置两遍共检查 $scans 次，另计算 ${a.cols} 个列起点。',
    done: true,
  );
  return builder.build();
}
