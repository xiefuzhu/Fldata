import 'dart:math' as math;
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

enum SearchMethod {
  sequential('顺序查找'),
  sentinel('监视哨'),
  binary('折半查找'),
  block('分块查找');

  const SearchMethod(this.label);
  final String label;
}

const _ordered = [
  [5, 16, 20, 27, 30, 36, 44, 55, 60, 67, 71],
];
const textbookSearchBlocks = [
  [22, 12, 13, 8, 9, 20],
  [33, 42, 44, 38, 24, 48],
  [60, 58, 74, 49, 86, 53],
];

class SearchInput {
  const SearchInput({
    this.method = SearchMethod.binary,
    this.groups = _ordered,
    this.key = 27,
    this.binaryIndex = false,
  });
  final SearchMethod method;
  final List<List<int>> groups;
  final int key;
  final bool binaryIndex;
  List<int> get values => groups.expand((b) => b).toList();
  SearchInput change({
    SearchMethod? method,
    List<List<int>>? groups,
    int? key,
    bool? binaryIndex,
  }) => SearchInput(
    method: method ?? this.method,
    groups: groups ?? this.groups,
    key: key ?? this.key,
    binaryIndex: binaryIndex ?? this.binaryIndex,
  );
  String? get problem {
    if (method == SearchMethod.binary) {
      final a = values;
      for (var i = 1; i < a.length; i++) {
        if (a[i] < a[i - 1]) return '折半查找需要按关键字非递减排列的记录表。';
      }
    }
    if (method == SearchMethod.block) {
      int? last;
      for (final block in groups) {
        if (block.isEmpty) return '每个索引项需要一个非空块。';
        if (last != null && block.reduce(math.min) <= last) {
          return '后一块的每个关键字都须大于前一块的最大关键字。';
        }
        last = block.reduce(math.max);
      }
    }
    return null;
  }

  static ValidationResult<SearchInput> parse(
    String records,
    String target,
    SearchMethod method,
    bool binaryIndex,
  ) {
    final key = int.tryParse(target.trim());
    if (key == null) return const ValidationResult.failure('请输入整数关键字。');
    final groups = <List<int>>[];
    if (records.trim().isNotEmpty) {
      for (final block in records.trim().split(RegExp('[|｜]'))) {
        final tokens = block.trim().split(RegExp(r'[\s,，]+'));
        final values = tokens.map(int.tryParse).toList();
        if (values.any((v) => v == null)) {
          return const ValidationResult.failure('记录须为整数，分块可用 | 分隔。');
        }
        groups.add(values.cast<int>());
      }
    }
    final input = SearchInput(
      method: method,
      groups: groups,
      key: key,
      binaryIndex: binaryIndex,
    );
    final error = input.problem;
    return error == null
        ? ValidationResult.success(input)
        : ValidationResult.failure(error);
  }
}

class StaticSearchModule implements AlgorithmModule<SearchInput> {
  const StaticSearchModule();
  @override
  String get id => 'ch7_linear_bin_block';
  @override
  List<AlgorithmPreset<SearchInput>> get presets => const [
    AlgorithmPreset(id: 'bin27', name: '例 7.1 · 折半查 27', input: SearchInput()),
    AlgorithmPreset(
      id: 'bin65',
      name: '例 7.1 · 折半查 65',
      input: SearchInput(key: 65),
    ),
    AlgorithmPreset(
      id: 'sent65',
      name: '算法 7.2 · 监视哨查 65',
      input: SearchInput(method: SearchMethod.sentinel, key: 65),
    ),
    AlgorithmPreset(
      id: 'block38',
      name: '图 7.4 · 分块查 38',
      input: SearchInput(
        method: SearchMethod.block,
        groups: textbookSearchBlocks,
        key: 38,
      ),
    ),
    AlgorithmPreset(
      id: 'block29',
      name: '图 7.4 · 分块查 29',
      input: SearchInput(
        method: SearchMethod.block,
        groups: textbookSearchBlocks,
        key: 29,
      ),
    ),
  ];
  @override
  ValidationResult<SearchInput> validateInput(String raw) {
    final p = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择查找预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(SearchInput input) {
    final run = _SearchRun(input, id);
    run.record();
    return run.b.build();
  }
}

class _DecisionTree {
  _DecisionTree(List<int> values) {
    final n = values.length;
    final nodes = <SceneNode>[], edges = <SceneEdge>[];
    String build(int lo, int hi, int depth) {
      final leaf = lo > hi,
          mid = (lo + hi) ~/ 2,
          id = leaf ? 'gap$lo' : 'mid$mid';
      final counts = leaf ? failed : successful,
          cost = leaf ? depth - 1 : depth;
      // The keys just outside this interval bound every query reaching it.
      // Equal adjacent keys have no failure interval between them.
      final reachable = leaf
          ? lo == 1 || lo == n + 1 || values[lo - 2] < values[lo - 1]
          : (lo == 1 || values[mid - 1] > values[lo - 2]) &&
                (hi == n || values[mid - 1] < values[hi]);
      if (reachable) {
        counts.update(cost, (v) => v + 1, ifAbsent: () => 1);
      }
      nodes.add(
        SceneNode(
          id: id,
          label: leaf ? '□' : '$mid',
          x: 0,
          y: 0,
          width: leaf ? 32 : 40,
          height: leaf ? 32 : 40,
          shape: leaf ? NodeShape.arraySlot : NodeShape.circle,
          logicBadge: leaf
              ? (n == 0
                    ? '空表'
                    : lo == 1
                    ? '～1'
                    : lo == n + 1
                    ? '$n～'
                    : '${lo - 1}～$lo')
              : null,
        ),
      );
      if (!leaf) {
        final left = build(lo, mid - 1, depth + 1),
            right = build(mid + 1, hi, depth + 1);
        for (final (child, port) in [
          (left, EdgePort.lchild),
          (right, EdgePort.rchild),
        ]) {
          edges.add(
            SceneEdge(
              id: '$id-$child',
              fromNodeId: id,
              toNodeId: child,
              fromPort: port,
            ),
          );
        }
      }
      return id;
    }

    build(1, n, 1);
    scene = TreeReingoldLayout.arrange(
      SceneSnapshot(nodes: nodes, edges: edges),
      levelGap: 28,
    );
  }
  final successful = <int, int>{}, failed = <int, int>{};
  late final SceneSnapshot scene;
  static String mean(Map<int, int> counts) {
    if (counts.isEmpty) return '无成功记录';
    final depths = counts.keys.toList()..sort();
    final sum = depths.fold<int>(0, (s, d) => s + d * counts[d]!);
    final n = counts.values.reduce((a, b) => a + b);
    final exact = '$sum/$n';
    return '(${depths.map((d) => "${counts[d]}×$d").join(" + ")}) / $n = $exact ≈ ${(sum / n).toStringAsFixed(3)}';
  }
}

class _SearchRun {
  _SearchRun(this.input, String id)
    : b = TraceBuilder(
        moduleId: id,
        inputSummary: '${input.method.label} · key = ${input.key}',
        codeLines: _code(input.method, input.binaryIndex),
      );
  final SearchInput input;
  final TraceBuilder b;
  late final a = input.values;
  late final tree = _DecisionTree(a);
  final visited = <String>{};
  String? current;
  int? result, lo, hi, mid, cursor, chosen, indexProbe, indexLo, indexHi;
  int keys = 0, bounds = 0, decrements = 0, indexChecks = 0, scanChecks = 0;
  bool wrote = false;
  final starts = <int>[], maxima = <int>[];

  void emit(
    int line,
    String title,
    String why, {
    bool mark = false,
    bool error = false,
    int comparisons = 0,
    int writes = 0,
    Map<String, int> counts = const {},
  }) {
    final binary = input.method == SearchMethod.binary,
        block = input.method == SearchMethod.block;
    final seq = !binary && !block;
    final showTree = binary && !error;
    final slots = <List<String>>[];
    final blockHeads = {
      for (final (i, start) in starts.indexed) start: '块 ${i + 1}',
    };
    void slot(
      int i,
      String value, {
      bool sentinel = false,
      bool outside = false,
    }) {
      final pointers = [
        if (i == lo && binary) 'low',
        if (i == mid && binary) 'mid',
        if (i == hi && binary) 'high',
        if (i == cursor) 'i',
      ];
      final active =
          (!binary || lo == null || i >= lo! && i <= hi!) &&
          (!block ||
              chosen == null ||
              i >= starts[chosen!] &&
                  i < starts[chosen!] + input.groups[chosen!].length);
      slots.add([
        '$i',
        value,
        pointers.join(' / '),
        sentinel
            ? '哨兵'
            : outside
            ? '边界'
            : result == i
            ? '命中'
            : i == cursor || i == mid
            ? '比较'
            : active
            ? '有效'
            : '排除',
        if (block) blockHeads[i] ?? '',
      ]);
    }

    if (seq) {
      slot(
        0,
        input.method == SearchMethod.sentinel && wrote ? '${input.key}' : '—',
        sentinel: input.method == SearchMethod.sentinel,
        outside: true,
      );
    }
    if (binary && hi == 0) {
      slot(0, '—', outside: true);
    }
    for (var i = 1; i <= a.length; i++) {
      slot(i, '${a[i - 1]}');
    }
    if (binary && lo == a.length + 1) {
      slot(lo!, '—', outside: true);
    }
    final tables = [
      AuxTableSnapshot(
        id: 'records',
        title: '记录表 R',
        columns: ['位序', '关键字', '指针', '状态', if (block) '块首'],
        rows: slots,
      ),
      if (seq)
        AuxTableSnapshot(
          id: 'frequency',
          title: '同一查找进度的语句频度',
          columns: ['语句', '7.1', '7.2'],
          rows: [
            ['判断 i ≥ 1', '$bounds', '0'],
            ['比较关键字', '$keys', '$bounds'],
            ['i 减 1', '$decrements', '$decrements'],
            ['写入 R[0]', '0', wrote ? '1' : '0'],
          ],
        ),
      if (showTree)
        AuxTableSnapshot(
          id: 'asl',
          title: '等概率平均查找长度',
          columns: ['类型', '计算过程'],
          rows: [
            ['成功', _DecisionTree.mean(tree.successful)],
            ['失败', _DecisionTree.mean(tree.failed)],
          ],
        ),
      if (block)
        AuxTableSnapshot(
          id: 'index',
          title: '索引表',
          columns: ['块号', '最大关键字', '起始位序'],
          rows: [
            for (var i = 0; i < starts.length; i++)
              ['${i + 1}', '${maxima[i]}', '${starts[i]}'],
          ],
          highlightedRows: {?indexProbe},
        ),
    ];
    final scene = showTree
        ? tree.scene.copyWith(
            nodes: [
              for (final n in tree.scene.nodes)
                n.copyWith(
                  visualState: n.id == current
                      ? NodeVisualState.active
                      : visited.contains(n.id)
                      ? NodeVisualState.sorted
                      : NodeVisualState.normal,
                ),
            ],
            edges: [
              for (final e in tree.scene.edges)
                e.copyWith(
                  visualState:
                      visited.contains(e.fromNodeId) &&
                          visited.contains(e.toNodeId)
                      ? NodeVisualState.active
                      : NodeVisualState.normal,
                ),
            ],
            auxTables: tables,
          )
        : SceneSnapshot(auxTables: tables);
    b.step(
      title: title,
      explain: why,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      milestone: mark,
      error: error,
      deltaCompare: comparisons,
      deltaWrite: writes,
      statementCounts: counts,
      scene: scene,
      vars: {
        'key': '${input.key}',
        '返回': result?.toString() ?? '—',
        if (cursor != null) 'i': '$cursor',
        if (lo != null) 'low': '$lo',
        if (mid != null) 'mid': '$mid',
        if (hi != null) 'high': '$hi',
        '判定结点': ?current,
        if (chosen != null) '选定块': '${chosen! + 1}',
        if (indexLo != null) '索引范围': '${indexLo! + 1}～${indexHi! + 1}',
        if (block) '索引比较': '$indexChecks',
        if (block) '块内比较': '$scanChecks',
      },
    );
  }

  void record() {
    final problem = input.problem;
    if (problem != null) {
      emit(1, '输入条件未满足', problem, error: true);
      return;
    }
    switch (input.method) {
      case SearchMethod.binary:
        binary();
      case SearchMethod.block:
        blocked();
      case SearchMethod.sentinel || SearchMethod.sequential:
        sequential();
    }
  }

  void sequential() {
    final sent = input.method == SearchMethod.sentinel;
    emit(1, '准备顺序表', '从最后一条记录向前查找。两列按同一输入同步统计。');
    wrote = true;
    emit(
      1,
      sent ? '写入 R[0] 监视哨' : '算法 7.1 保留空闲零号槽',
      sent ? '把 key 写入紫色槽位。' : '对照列中的算法 7.2 此时会写入监视哨。',
      writes: sent ? 1 : 0,
      counts: {if (sent) '写入监视哨': 1},
    );
    cursor = a.length;
    while (true) {
      final i = cursor!, hasRecord = i > 0;
      bounds++;
      if (hasRecord) keys++;
      final hit = hasRecord && a[i - 1] == input.key;
      emit(
        2,
        hasRecord
            ? '检查 R[$i]'
            : sent
            ? '与监视哨相等'
            : '边界条件为假',
        hasRecord
            ? 'R[$i] = ${a[i - 1]}，key = ${input.key}。'
            : sent
            ? '到达 R[0]，比较相等，循环停止。'
            : 'i = 0 时停止，无需读取关键字。',
        comparisons: sent ? 1 : 1 + (hasRecord ? 1 : 0),
        counts: {if (!sent) '边界判断': 1, if (sent || hasRecord) '关键字比较': 1},
      );
      if (hit || !hasRecord) {
        result = i;
        emit(
          4,
          '返回 $i',
          i == 0 ? '没有匹配的记录。' : '从表尾遇到的第一条相等记录位于 $i。',
          mark: true,
        );
        return;
      }
      cursor = i - 1;
      decrements++;
      emit(3, '向前移动 i', '下一次检查位序 $cursor。', counts: {'i 减 1': 1});
    }
  }

  void binary() {
    lo = 1;
    hi = a.length;
    emit(1, '建立折半查找区间', '记录从 1 编号，判定树圆内为位序，方形结点为失败区间。', mark: true);
    while (lo! <= hi!) {
      mid = (lo! + hi!) ~/ 2;
      current = 'mid$mid';
      visited.add(current!);
      final x = a[mid! - 1];
      emit(
        2,
        '比较 R[$mid]',
        'mid = ⌊($lo + $hi) / 2⌋ = $mid，比较关键字 $x 与 ${input.key}。',
        comparisons: 1,
        mark: true,
        counts: {'探测记录': 1},
      );
      if (x == input.key) {
        result = mid;
        emit(3, '返回 $result', '成功路径经过 ${visited.length} 个内部结点。', mark: true);
        return;
      }
      final left = input.key < x;
      if (left) {
        hi = mid! - 1;
      } else {
        lo = mid! + 1;
      }
      mid = null;
      emit(left ? 4 : 5, left ? '缩小上界' : '提高下界', '下一候选区间为 [$lo, $hi]。');
    }
    current = 'gap$lo';
    visited.add(current!);
    result = 0;
    emit(6, '返回 0', 'low > high，终止于失败区间；比较次数为路径上的内部结点数。', mark: true);
  }

  void blocked() {
    var start = 1;
    for (final block in input.groups) {
      starts.add(start);
      maxima.add(block.reduce(math.max));
      start += block.length;
    }
    emit(1, '建立索引表', '索引项由块内最大关键字和第一个记录的位序组成。', mark: true);
    if (input.binaryIndex) {
      var left = 0, right = starts.length;
      while (left < right) {
        final p = (left + right) ~/ 2;
        indexProbe = p;
        indexLo = left;
        indexHi = right - 1;
        indexChecks++;
        emit(
          2,
          '比较第 ${p + 1} 块上界',
          '在索引区间 ${left + 1}～$right 中找第一个最大关键字 ≥ key 的块。',
          comparisons: 1,
          counts: {'索引比较': 1},
        );
        if (maxima[p] < input.key) {
          left = p + 1;
        } else {
          right = p;
        }
      }
      if (left < starts.length) chosen = left;
    } else {
      for (var p = 0; p < starts.length; p++) {
        indexProbe = p;
        indexChecks++;
        emit(
          2,
          '比较第 ${p + 1} 块上界',
          '比较最大关键字 ${maxima[p]} 与 ${input.key}。',
          comparisons: 1,
          counts: {'索引比较': 1},
        );
        if (maxima[p] >= input.key) {
          chosen = p;
          break;
        }
      }
    }
    indexLo = null;
    indexHi = null;
    indexProbe = chosen;
    final p = chosen;
    if (p != null) {
      emit(
        3,
        '选定第 ${p + 1} 块',
        '从位序 ${starts[p]} 起，只在索引指向的块内顺序扫描。',
        mark: true,
      );
      for (var offset = 0; offset < input.groups[p].length; offset++) {
        cursor = starts[p] + offset;
        scanChecks++;
        emit(
          4,
          '块内检查 R[$cursor]',
          '比较 ${a[cursor! - 1]} 与 ${input.key}。',
          comparisons: 1,
          counts: {'块内比较': 1},
        );
        if (a[cursor! - 1] == input.key) {
          result = cursor;
          emit(5, '返回 $result', '命中第 ${p + 1} 块的记录。', mark: true);
          return;
        }
      }
    }
    result = 0;
    emit(6, '返回 0', p == null ? '没有最大关键字达到目标的块。' : '选定块中的记录已全部比较。', mark: true);
  }
}

Map<CodeLang, List<String>> _code(SearchMethod method, bool binaryIndex) {
  final List<String> pseudo, c, dart;
  switch (method) {
    case SearchMethod.sequential:
      pseudo = [
        'i 从 length 开始，R[0] 闲置',
        '判断 i≥1，再比较 R[i] 与 key',
        '不等则 i 减 1',
        '返回命中的 i 或 0',
      ];
      c = [
        'int i=ST.length;',
        'while(i>=1 && ST.R[i].key!=key){',
        '  --i; }',
        'return i;',
      ];
      dart = [
        'var i=r.length-1;',
        'while(i>=1 && r[i]!=key){',
        '  i--; }',
        'return i;',
      ];
    case SearchMethod.sentinel:
      pseudo = [
        'R[0] 写入 key，i 从 length 开始',
        '仅判断 R[i] 是否与 key 不等',
        '不等则 i 减 1',
        '返回 i，0 表示失败',
      ];
      c = [
        'ST.R[0].key=key; int i=ST.length;',
        'while(ST.R[i].key!=key){',
        '  --i; }',
        'return i;',
      ];
      dart = [
        'r[0]=key; var i=r.length-1;',
        'while(r[i]!=key){',
        '  i--; }',
        'return i;',
      ];
    case SearchMethod.binary:
      pseudo = [
        'low=1，high=n',
        '当 low≤high，取下中位数，比较记录',
        '相等则返回 mid',
        '目标较小则 high=mid−1',
        '目标较大则 low=mid+1',
        '区间为空返回 0',
      ];
      c = [
        'int low=1,high=ST.length;',
        'while(low<=high){int mid=(low+high)/2;',
        '  if(key==ST.R[mid].key) return mid;',
        '  if(key<ST.R[mid].key) high=mid-1;',
        '  else low=mid+1; }',
        'return 0;',
      ];
      dart = [
        'var low=1,high=r.length-1;',
        'while(low<=high){final mid=(low+high)~/2;',
        '  if(key==r[mid])return mid;',
        '  if(key<r[mid]) high=mid-1;',
        '  else low=mid+1; }',
        'return 0;',
      ];
    case SearchMethod.block:
      pseudo = [
        '建立按最大关键字排序的索引',
        '${binaryIndex ? "折半" : "顺序"}寻找首个上界 ≥ key 的块',
        '若存在，从该块起始位序出发',
        '在块内逐个比较关键字',
        '相等则返回记录位序',
        '无候选块或扫描完毕返回 0',
      ];
      c = [
        'build_index(blocks,idx);',
        binaryIndex
            ? 'int b=lower_bound_max(idx,count,key);'
            : 'int b=0; while(b<count && idx[b].max<key) ++b;',
        'if(b<count) {',
        '  for(int i=idx[b].start;i<=end[b];i++)',
        '    if(R[i].key==key) return i; }',
        'return 0;',
      ];
      dart = [
        'final index=buildIndex(blocks);',
        binaryIndex
            ? 'final b=lowerBoundMax(index,key);'
            : 'var b=0; while(b<index.length && index[b].max<key){b++;}',
        'if(b<index.length){',
        '  for(var i=index[b].start;i<=end[b];i++){',
        '    if(r[i]==key)return i; }}',
        'return 0;',
      ];
  }
  return {CodeLang.cLike: pseudo, CodeLang.c99: c, CodeLang.dart: dart};
}
