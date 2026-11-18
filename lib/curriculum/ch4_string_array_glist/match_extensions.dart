part of 'bf_kmp.dart';

// All three source listings share semantic line positions for playback.
const _prefixSources = {
  CodeLang.cLike: [
    '求表(T, 优化)',
    '  j ← 1, k ← 0, 表[1] ← 0（若非空）',
    '  当 j < m',
    '    若 k = 0 或 T[j] = T[k]',
    '      j++, k++',
    '      若优化且 T[j] = T[k]，表[j] ← 表[k]',
    '      否则 表[j] ← k',
    '    否则 k ← 表[k]',
    '  返回 表',
  ],
  CodeLang.c99: [
    'void build(SString T, int optimized, int link[]) {',
    '  int j=1, k=0; if (T.ch[0]) link[1]=0;',
    '  while (j < T.ch[0]) {',
    '    if (!k || T.ch[j]==T.ch[k]) {',
    '      ++j; ++k;',
    '      if (optimized && T.ch[j]==T.ch[k]) link[j]=link[k];',
    '      else link[j]=k;',
    '    } else k=link[k];',
    '  } }',
  ],
  CodeLang.dart: [
    'List<int> build(SString t, bool optimized) {',
    '  var j=1, k=0; final link=List.filled(t.length+1,0);',
    '  while (j<t.length) {',
    '    if (k==0 || t[j]==t[k]) {',
    '      j++; k++;',
    '      if (optimized && t[j]==t[k]) { link[j]=link[k]; }',
    '      else { link[j]=k; }',
    '    } else { k=link[k]; }',
    '  } return link; }',
  ],
};

TraceTimeline _prefixTrace(MatchInput input) {
  final t = SString(input.pattern);
  final name = input.optimized ? 'nextval' : 'next';
  final builder = TraceBuilder(
    moduleId: 'ch4_bf_kmp_lab',
    inputSummary: 'T=${input.pattern} · $name',
    codeLines: _prefixSources,
  );
  var known = t.length == 0 ? 0 : 1;
  void record(int j, int k, List<int> links, _LinkEvent event, int previousK) {
    final updated = event == _LinkEvent.store || event == _LinkEvent.inherit;
    if (updated) known = j;
    final length = math.max(0, k - 1);
    final start = j - length;
    final (line, title, explanation) = switch (event) {
      _LinkEvent.start => (
        2,
        '初始化 $name',
        t.length == 0 ? '空模式没有数据槽。' : '第一个字符失配时跳至哨兵，表[1] = 0。',
      ),
      _LinkEvent.compare => (
        4,
        '比较候选边界',
        k == 0 ? 'k=0，下一步从首字符重新开始。' : '比较 T[$j] 与 T[$k]，判断能否延长当前边界。',
      ),
      _LinkEvent.advance => (5, '延长边界', 'j=$j，k=$k。相同的前缀与后缀长度为 $length。'),
      _LinkEvent.inherit => (
        6,
        '跳过相同字符',
        'T[$j] 与 T[$k] 相同，再比一次仍会失配。继承 $name[$k] = ${links[k]}。',
      ),
      _LinkEvent.store => (7, '写入 $name[$j]', '失配时可以从第 $k 位继续比较。'),
      _LinkEvent.retreat => (
        8,
        '退到更短的边界',
        'j 保持 $j。k 从 $previousK 回退到 $name[$previousK] = $k。',
      ),
      _LinkEvent.finish => (9, '递推完成', '$name = [${links.skip(1).join(', ')}]'),
    };
    SceneNode cell(
      String id,
      String label,
      int col,
      double y,
      NodeVisualState color,
    ) => SceneNode(
      id: id,
      label: label,
      x: 100 + col * 60.0,
      y: y,
      width: 55,
      height: 42,
      indexBadge: '[$col]',
      visualState: color,
    );
    builder.step(
      title: title,
      explain: explanation,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      milestone:
          updated || event == _LinkEvent.retreat || event == _LinkEvent.finish,
      vars: {'j': '$j', 'k': '$k', '已写入': '$known'},
      scene: SceneSnapshot(
        nodes: [
          for (final (row, y) in [
            ('前缀', 65.0),
            ('后缀', 155.0),
            (name, 245.0),
          ]) ...[
            SceneNode(id: row, label: row, x: 12, y: y, width: 76, height: 42),
            for (var i = 1; i <= t.length; i++)
              cell(
                '$row-$i',
                row == name
                    ? (i <= known ? '${links[i]}' : '·')
                    : input.pattern[i - 1],
                i,
                y,
                row == '前缀' && i <= length
                    ? NodeVisualState.sorted
                    : row == '后缀' && i >= start && i < j
                    ? NodeVisualState.active
                    : row == name && i == known
                    ? NodeVisualState.comparing
                    : row == name &&
                          input.optimized &&
                          i <= known &&
                          links[i] == 0
                    ? NodeVisualState.sorted
                    : NodeVisualState.normal,
              ),
          ],
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'prefix',
            title: name,
            columns: ['j', 'T[j]', name],
            rows: [
              for (var i = 1; i <= t.length; i++)
                ['$i', input.pattern[i - 1], i <= known ? '${links[i]}' : '·'],
            ],
          ),
        ],
      ),
    );
  }

  _buildLinks(t, input.optimized, record);
  return builder.build();
}

const _rotationSources = {
  CodeLang.cLike: [
    '环串查找(S,T)',
    '  展开环 T',
    '  D ← T + T',
    '  对 r 从 0 到 m−1',
    '    W ← D[r..r+m)',
    '    pos ← Index_KMP(S,W)',
    '    记录 W 与 pos',
    '  返回各旋转的首个位置',
  ],
  CodeLang.c99: [
    'void rotations(SString S, SString T, int pos[]) {',
    '  int m=T.ch[0];',
    '  char d[24]; for(int i=0;i<2*m;i++) d[i]=T.ch[1+i%m];',
    '  for(int r=0;r<m;r++) {',
    '    SString w={0}; w.ch[0]=m; for(int j=1;j<=m;j++) w.ch[j]=d[r+j-1];',
    '    int next[13]; build(w,0,next); int p=Index_KMP(S,w,next);',
    '    pos[r]=p;',
    '  } }',
  ],
  CodeLang.dart: [
    'List<int> rotations(SString s,String t) {',
    '  final m=t.length, positions=<int>[];',
    '  final doubled=t+t;',
    '  for(var r=0;r<m;r++) {',
    '    final w=SString(doubled.substring(r,r+m));',
    '    final p=Index_KMP(s,w,build(w,false));',
    '    positions.add(p);',
    '  } return positions; }',
  ],
};
TraceTimeline _rotationTrace(MatchInput input) {
  final s = SString(input.text), raw = input.pattern, m = raw.length;
  final doubled = raw + raw;
  final builder = TraceBuilder(
    moduleId: 'ch4_bf_kmp_lab',
    inputSummary: 'S=${input.text}，环 T=$raw',
    codeLines: _rotationSources,
  );
  final history = <List<String>>[];
  var rotation = 0, position = 0, matches = 0;
  void record(
    int line,
    String title,
    String explain, {
    _Track? track,
    bool circle = false,
    bool copy = false,
    bool window = false,
    bool milestone = false,
  }) {
    final count = circle || !copy ? m : 2 * m;
    final radius = math.max(65.0, m * 11.0);
    final nodes = <SceneNode>[];
    for (var i = 0; i < count; i++) {
      final angle = 2 * math.pi * i / math.max(1, m) - math.pi / 2;
      nodes.add(
        SceneNode(
          id: 'ring-$i',
          label: doubled[i],
          indexBadge: '[${i + 1}]',
          x: circle ? radius + 30 + radius * math.cos(angle) : 20 + 55.0 * i,
          y: circle ? radius + 30 + radius * math.sin(angle) : 65,
          width: 45,
          height: 40,
          visualState:
              window &&
                  track != null &&
                  track.j > 0 &&
                  track.j <= m &&
                  i == rotation + track.j - 1
              ? NodeVisualState.comparing
              : window && i >= rotation && i < rotation + m
              ? NodeVisualState.sorted
              : NodeVisualState.normal,
        ),
      );
    }
    if (window) {
      for (var i = 1; i <= s.length; i++) {
        nodes.add(
          SceneNode(
            id: 'host-$i',
            label: input.text[i - 1],
            indexBadge: '[$i]',
            x: 20 + (i - 1) * 55.0,
            y: 175,
            width: 45,
            height: 40,
            visualState: i == track?.i
                ? NodeVisualState.comparing
                : NodeVisualState.normal,
          ),
        );
      }
    }
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      milestone: milestone,
      deltaCompare: track != null && track.compared ? 1 : 0,
      vars: {
        '旋转': '${m == 0 ? 0 : rotation + 1}/$m',
        '位置': '$position',
        '命中数': '$matches',
        if (line == 8) '感染': matches > 0 ? 'YES' : 'NO',
        if (track != null) ...{'i': '${track.i}', 'j': '${track.j}'},
      },
      scene: SceneSnapshot(
        nodes: nodes,
        edges: [
          if (circle && m > 1)
            for (var i = 0; i < m; i++)
              SceneEdge(
                id: 'link-$i',
                fromNodeId: 'ring-$i',
                toNodeId: 'ring-${(i + 1) % m}',
                curvature: m == 2 ? 26 : 0,
              ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'rotations',
            title: '已检查的旋转',
            columns: ['起点', '窗口', '主串首个位置'],
            rows: history,
          ),
        ],
      ),
    );
  }

  record(1, '首尾相接', '从每个环上起点都可以读出一个长度为 $m 的窗口。', circle: true, milestone: true);
  record(2, '切开环串', '沿第一个字符起展开为 $raw。');
  record(3, '复制并拼接', '$raw + $raw = $doubled。', copy: true);
  for (rotation = 0; rotation < m; rotation++) {
    final word = doubled.substring(rotation, rotation + m), t = SString(word);
    final links = failureLinks(t, optimized: false), track = _Track('KMP');
    position = 0;
    record(
      5,
      '取窗口 ${rotation + 1}：$word',
      '取倍增串中从第 ${rotation + 1} 位开始的 $m 个字符。',
      copy: true,
      window: true,
      milestone: true,
    );
    while (track.result == null) {
      track.advance(s, t, links, kmp: true);
      position = track.result ?? 0;
      record(
        6,
        'KMP · $word',
        track.action,
        track: track,
        copy: true,
        window: true,
      );
    }
    position = track.result!;
    if (position > 0) matches++;
    history.add(['${rotation + 1}', word, '$position']);
    record(
      7,
      '$word → $position',
      position == 0 ? '本窗口未命中。' : '在主串第 $position 位找到本窗口。',
      copy: true,
      window: true,
      milestone: true,
    );
  }
  rotation = math.max(0, m - 1);
  record(
    8,
    '旋转匹配完成',
    '$m 个旋转中有 $matches 个能在主串中找到，感染判定为 ${matches > 0 ? "YES" : "NO"}。',
    copy: true,
    milestone: true,
  );
  return builder.build();
}
