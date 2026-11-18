import 'dart:math' as math;
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';

enum ComplexityMode {
  growth,
  matrix,
  constant,
  linear,
  square,
  triangle,
  logarithmic,
  search,
  reverse,
}

enum SearchScenario { best, middle, worst, absent }

class ComplexityInput {
  const ComplexityInput({
    this.mode = ComplexityMode.growth,
    this.n = 5,
    this.search = SearchScenario.middle,
  });
  final ComplexityMode mode;
  final int n;
  final SearchScenario search;
  ComplexityInput copyWith({
    ComplexityMode? mode,
    int? n,
    SearchScenario? search,
  }) => ComplexityInput(
    mode: mode ?? this.mode,
    n: n ?? this.n,
    search: search ?? this.search,
  );
}

Map<String, double> growthValues(int n) => {
  '1': 1,
  'log₂n': math.log(n) / math.ln2,
  'n': n.toDouble(),
  'n·log₂n': n * math.log(n) / math.ln2,
  'n²': (n * n).toDouble(),
  'n³': (n * n * n).toDouble(),
  '2ⁿ': math.pow(2, n).toDouble(),
};

class ComplexityLabModule implements AlgorithmModule<ComplexityInput> {
  const ComplexityLabModule();
  static const names = [
    '增长曲线',
    '矩阵乘法 · 例1.4',
    '常数阶',
    '线性阶',
    '平方阶',
    '三角循环',
    '对数阶',
    '顺序查找 · 例1.10',
    '逆序空间 · 例1.11',
  ];
  static int maxN(ComplexityMode mode) =>
      mode == ComplexityMode.matrix ? 8 : 32;
  @override
  String get id => 'ch1_complexity_lab';
  @override
  List<AlgorithmPreset<ComplexityInput>> get presets => const [
    AlgorithmPreset(
      id: 'growth20',
      name: '增长爆炸 · n=20',
      input: ComplexityInput(n: 20),
    ),
    AlgorithmPreset(
      id: 'matrix3',
      name: '矩阵频度 · n=3',
      input: ComplexityInput(mode: ComplexityMode.matrix, n: 3),
    ),
    AlgorithmPreset(
      id: 'log32',
      name: '翻倍循环 · n=32',
      input: ComplexityInput(mode: ComplexityMode.logarithmic, n: 32),
    ),
    AlgorithmPreset(
      id: 'reverse7',
      name: '奇数长度逆序 · n=7',
      input: ComplexityInput(mode: ComplexityMode.reverse, n: 7),
    ),
  ];
  @override
  ValidationResult<ComplexityInput> validateInput(String raw) {
    final p = raw.trim().split(RegExp(r'\s+'));
    if (p.length != 3) return const ValidationResult.failure('输入格式：模式 n 查找情形');
    final mode = ComplexityMode.values.where((m) => m.name == p[0]).firstOrNull;
    final n = int.tryParse(p[1]);
    final search = SearchScenario.values
        .where((s) => s.name == p[2])
        .firstOrNull;
    if (mode == null ||
        n == null ||
        n < 1 ||
        n > maxN(mode) ||
        search == null) {
      return const ValidationResult.failure(
        '一般规模 1～32；矩阵逐步演示 1～8；请选择有效模式/查找情形',
      );
    }
    return ValidationResult.success(
      ComplexityInput(mode: mode, n: n, search: search),
    );
  }

  @override
  TraceTimeline generateTrace(ComplexityInput input) {
    if (input.n < 1 || input.n > maxN(input.mode)) {
      throw ArgumentError('Invalid n');
    }
    final n = input.n, mode = input.mode;
    if (mode == ComplexityMode.reverse) return _reverse(input);
    List<String> source(CodeLang lang) {
      final dart = lang == CodeLang.dart;
      if (mode == ComplexityMode.matrix) {
        return [
          dart
              ? 'void matrix(List<List<int>> A, List<List<int>> B, List<List<int>> C, int n) {'
              : 'void matrix(int n, int A[n][n], int B[n][n], int C[n][n]) {',
          '  for (int i=0; i<n; i++) {',
          '    for (int j=0; j<n; j++) {',
          '      C[i][j]=0;',
          '      for (int k=0; k<n; k++) {',
          '        C[i][j] += A[i][k] * B[k][j];',
          '      }',
          '    }',
          '  }',
          '}',
        ];
      }
      if (mode == ComplexityMode.search) {
        return [
          dart
              ? 'int search(List<int> a, int n, int key) {'
              : 'int search(int a[], int n, int key) {',
          '  for (int i=0; i<n; i++) {',
          '    if (a[i] == key) return i;',
          '  }',
          '  return -1;',
          '}',
        ];
      }
      if (mode == ComplexityMode.growth) {
        return [
          '// 1, log2(n), n, n*log2(n), n*n, n*n*n, 2^n',
          '// Growth functions are reference scales, not measured instruction counts.',
        ];
      }
      return [
        'int demo(int n) {',
        '  int s=0;',
        ...switch (mode) {
          ComplexityMode.constant => ['  s=1;'],
          ComplexityMode.linear => [
            '  for (int i=0; i<n; i++) {',
            '    s++;',
            '  }',
          ],
          ComplexityMode.square => [
            '  for (int i=0; i<n; i++) {',
            '    for (int j=0; j<n; j++) {',
            '      s++;',
            '    }',
            '  }',
          ],
          ComplexityMode.triangle => [
            '  for (int i=0; i<n; i++) {',
            '    for (int j=0; j<=i; j++) {',
            '      s++;',
            '    }',
            '  }',
          ],
          ComplexityMode.logarithmic => [
            '  int i=1;',
            '  while (i<n) {',
            '    i=i*2;',
            '    s++;',
            '  }',
          ],
          _ => <String>[],
        },
        '  return s;',
        '}',
      ];
    }

    final code = {for (final lang in CodeLang.values) lang: source(lang)};
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: '${names[mode.index]} · n=$n',
      codeLines: code,
    );
    final counts = <String, int>{};
    final vars = <String, String>{'n': '$n'};
    final matrix = List.generate(n, (_) => List<int?>.filled(n, null));
    void emit(
      String title,
      List<int> lines, {
      String explanation = '',
      Map<int, int> increments = const {},
      int compares = 0,
      int reads = 0,
      int writes = 0,
      bool milestone = false,
      List<SceneNode> nodes = const [],
      List<AuxTableSnapshot> tables = const [],
    }) {
      for (final e in increments.entries) {
        counts.update(
          'line-${e.key}',
          (v) => v + e.value,
          ifAbsent: () => e.value,
        );
      }
      builder.step(
        title: title,
        explain:
            '$explanation\n计数口径：循环行统计进入循环体次数，其他标注行统计语句执行次数。例 1.5～1.9 的代码按附件给出的阶数类别重建，不是教材原文。',
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        vars: Map.of(vars),
        statementCounts: {
          for (final e in increments.entries) 'line-${e.key}': e.value,
        },
        deltaCompare: compares,
        deltaRead: reads,
        deltaWrite: writes,
        milestone: milestone,
        scene: SceneSnapshot(
          nodes: nodes,
          auxTables: [
            ...tables,
            AuxTableSnapshot(
              id: 'frequency',
              title: '逐行累计频度',
              columns: const ['行号', '次数'],
              rows: [
                for (final e in counts.entries)
                  [e.key.substring(5), '${e.value}'],
              ],
            ),
          ],
        ),
      );
    }

    if (mode == ComplexityMode.growth) {
      emit(
        '七种增长量级',
        [1],
        explanation:
            'n=$n。参考函数不是具体程序的精确指令次数；log₂n 与 n·log₂n 可为非整数。等概率成功顺序查找平均比较次数为 (n+1)/2。',
        milestone: true,
        tables: [
          AuxTableSnapshot(
            id: 'growth',
            title: '增长函数值',
            columns: const ['函数', '值'],
            rows: [
              for (final e in growthValues(n).entries) [e.key, '${e.value}'],
            ],
          ),
        ],
      );
      return builder.build();
    }
    emit('准备规模 n=$n', [1], milestone: true);
    if (mode == ComplexityMode.matrix) {
      // A[i][k]=i+k+1, B[k][j]=(k+1)*(j+1) are generated teaching data.
      List<AuxTableSnapshot> table(int row) => [
        AuxTableSnapshot(
          id: 'matrix-C',
          title: 'C · 已完成/进行中的矩阵元素',
          columns: [for (var j = 0; j < n; j++) 'j=$j'],
          rows: [
            for (final r in matrix) [for (final v in r) v?.toString() ?? '·'],
          ],
          highlightedRows: {if (row >= 0) row},
        ),
      ];
      for (var i = 0; i < n; i++) {
        vars['i'] = '$i';
        emit('进入第 ${i + 1} 行', [2], increments: {2: 1}, tables: table(i));
        for (var j = 0; j < n; j++) {
          vars['j'] = '$j';
          emit('进入 C[$i][$j]', [3], increments: {3: 1}, tables: table(i));
          matrix[i][j] = 0;
          vars['C[i][j]'] = '0';
          emit(
            '初始化 C[$i][$j]',
            [4],
            increments: {4: 1},
            writes: 1,
            tables: table(i),
          );
          for (var k = 0; k < n; k++) {
            final a = i + k + 1, b = (k + 1) * (j + 1);
            vars.addAll({'k': '$k', 'A[i][k]': '$a', 'B[k][j]': '$b'});
            emit('进入内层 k=$k', [5], increments: {5: 1}, tables: table(i));
            matrix[i][j] = matrix[i][j]! + a * b;
            vars['C[i][j]'] = '${matrix[i][j]}';
            emit(
              '乘加 C[$i][$j] += $a × $b',
              [6],
              increments: {6: 1},
              reads: 3,
              writes: 1,
              tables: table(i),
            );
          }
        }
      }
      emit(
        'n³ 次核心乘加',
        [6],
        explanation:
            '外层进入 n=$n 次，中层 n²=${n * n} 次，内层与乘加 n³=${n * n * n} 次。初始化 C 执行 n² 次。A[i][k]=i+k+1，B[k][j]=(k+1)(j+1) 为教学数据。',
        milestone: true,
        tables: table(-1),
      );
      return builder.build();
    }
    if (mode == ComplexityMode.search) {
      final target = switch (input.search) {
        SearchScenario.best => 1,
        SearchScenario.middle => (n + 1) ~/ 2,
        SearchScenario.worst => n,
        SearchScenario.absent => n + 1,
      };
      vars['key'] = '$target';
      List<SceneNode> nodes(int current) => [
        for (var i = 0; i < n; i++)
          SceneNode(
            id: 'search-$i',
            label: '${i + 1}',
            x: 24 + i * 56.0,
            y: 60,
            width: 48,
            height: 40,
            indexBadge: '[$i]',
            visualState: i == current
                ? NodeVisualState.comparing
                : NodeVisualState.normal,
          ),
      ];
      for (var i = 0; i < n; i++) {
        vars['i'] = '$i';
        emit('进入第 ${i + 1} 个元素', [2], increments: {2: 1}, nodes: nodes(i));
        final found = i + 1 == target;
        if (found) vars['返回值'] = '$i';
        emit(
          found ? '找到目标，下标 $i' : '比较 ${i + 1} 与 $target',
          [3],
          increments: {3: 1},
          compares: 1,
          reads: 1,
          nodes: nodes(i),
        );
        if (found) break;
      }
      if (input.search == SearchScenario.absent) {
        vars['返回值'] = '-1';
        emit('未找到，返回 −1', [5], increments: {5: 1}, nodes: nodes(-1));
      }
      emit(
        '最好 / 最坏 / 平均对照',
        [input.search == SearchScenario.absent ? 5 : 3],
        explanation:
            '成功查找最好 1 次、最坏 n=$n 次；若每个位置等概率成功，平均 (n+1)/2=${(n + 1) / 2} 次。失败查找需要 n 次。这里只统计元素与 key 的比较。',
        milestone: true,
        nodes: nodes(-1),
      );
      return builder.build();
    }
    var total = 0;
    vars['s'] = '0';
    emit('初始化 s', [2], increments: {2: 1}, writes: 1);
    void body(int line) {
      total++;
      vars['s'] = '$total';
      emit('核心语句累计 $total 次', [line], increments: {line: 1}, writes: 1);
    }

    switch (mode) {
      case ComplexityMode.constant:
        body(3);
      case ComplexityMode.linear:
        for (var i = 0; i < n; i++) {
          vars['i'] = '$i';
          emit('进入循环 i=$i', [3], increments: {3: 1});
          body(4);
        }
      case ComplexityMode.square || ComplexityMode.triangle:
        for (var i = 0; i < n; i++) {
          vars['i'] = '$i';
          emit('进入外层 i=$i', [3], increments: {3: 1});
          for (
            var j = 0;
            j < (mode == ComplexityMode.square ? n : i + 1);
            j++
          ) {
            vars['j'] = '$j';
            emit('进入内层 j=$j', [4], increments: {4: 1});
            body(5);
          }
        }
      case ComplexityMode.logarithmic:
        var i = 1;
        vars['i'] = '1';
        emit('初始化 i=1', [3], increments: {3: 1}, writes: 1);
        while (i < n) {
          emit('进入 while，i=$i', [4], increments: {4: 1});
          i *= 2;
          vars['i'] = '$i';
          emit('i 翻倍至 $i', [5], increments: {5: 1}, writes: 1);
          body(6);
        }
      default:
        throw StateError('Unsupported frequency mode');
    }
    final formula = switch (mode) {
      ComplexityMode.constant => '1',
      ComplexityMode.linear => 'n',
      ComplexityMode.square => 'n²',
      ComplexityMode.triangle => 'n(n+1)/2',
      ComplexityMode.logarithmic => 'ceil(log₂n)',
      _ => '',
    };
    emit(
      '核心频度 $formula = $total',
      [code[CodeLang.cLike]!.length - 1],
      increments: {code[CodeLang.cLike]!.length - 1: 1},
      explanation:
          '该示例的核心语句执行 $total 次。对数例使用 i=1、i<n、i*=2；n=1 时执行 0 次，n 为 2 的幂时为 log₂n 次。',
      milestone: true,
    );
    return builder.build();
  }

  TraceTimeline _reverse(ComplexityInput input) {
    final n = input.n,
        a = List.generate(input.n, (i) => i + 1),
        original = List.generate(input.n, (i) => i + 1),
        b = List<int?>.filled(input.n, null);
    List<String> code(CodeLang lang) {
      final dart = lang == CodeLang.dart;
      return [
        dart
            ? 'void reverseInPlace(List<int> a, int n) {'
            : 'void reverseInPlace(int a[], int n) {',
        '  int t=0;',
        '  for (int i=0,j=n-1; i<j; i++,j--) {',
        '    t=a[i];',
        '    a[i]=a[j];',
        '    a[j]=t;',
        '  }',
        '}',
        dart
            ? 'List<int> reverseCopy(List<int> source, int n) {'
            : 'void reverseCopy(int source[], int n) {',
        dart ? '  final b=List<int>.filled(n,0);' : '  int b[n];',
        '  for (int k=0; k<n; k++) {',
        '    b[k]=source[n-1-k];',
        '  }',
        dart
            ? '  return b;'
            : '  // b holds the reversed output; consume it before returning.',
        '}',
      ];
    }

    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: '原地与副本逆序 · n=$n',
      codeLines: {for (final l in CodeLang.values) l: code(l)},
    );
    int? t;
    var allocated = false, stepsA = 0, stepsB = 0;
    var i = 0, j = n - 1;
    void emit(
      String title,
      List<int> lines, {
      Map<int, int> counts = const {},
      int writes = 0,
      int reads = 0,
      bool milestone = false,
      int activeA = -1,
      int activeB = -1,
      int space = 0,
    }) {
      builder.step(
        title: title,
        explain:
            '上方修改 a，只用一个临时元素 t；下方从只读 source 写入 b[n]。输出分别是 a 和 b。并排每拍推进各自一个动作，不代表两程序耗时相同。空间按额外元素槽计，不含输入、循环索引与可视化快照。写次数只计逆序数据搬移，不含初始化；· 表示尚未填入逆序结果（Dart 的 b 初值为 0）。',
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        vars: {
          'n': '$n',
          'i': '$i',
          'j': '$j',
          't': t?.toString() ?? '未写入',
          '原地写次数': '$stepsA',
          '副本写次数': '$stepsB',
        },
        statementCounts: {
          for (final e in counts.entries) 'line-${e.key}': e.value,
        },
        deltaWrite: writes,
        deltaRead: reads,
        deltaSpace: space,
        deltaAllocate: space > 0 ? 2 : 0,
        milestone: milestone,
        scene: SceneSnapshot(
          layoutMode: SceneLayoutMode.linearMemory,
          nodes: [
            if (allocated)
              SceneNode(
                id: 'temp',
                indexBadge: 't',
                label: t?.toString() ?? 't',
                x: 24,
                y: 10,
                width: 48,
                height: 40,
                visualState: NodeVisualState.sentinel,
                groupTag: 'temp',
              ),
            for (var k = 0; k < n; k++)
              SceneNode(
                id: 'a-$k',
                label: '${a[k]}',
                x: 24 + k * 56.0,
                y: 86,
                width: 48,
                height: 40,
                indexBadge: '[$k]',
                groupTag: 'inplace',
                visualState: k == activeA
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
            for (var k = 0; k < n; k++)
              SceneNode(
                id: 'source-$k',
                label: '${original[k]}',
                x: 24 + k * 56.0,
                y: 174,
                width: 48,
                height: 40,
                indexBadge: '[$k]',
                groupTag: 'source',
              ),
            if (allocated)
              for (var k = 0; k < n; k++)
                SceneNode(
                  id: 'b-$k',
                  label: b[k]?.toString() ?? '·',
                  x: 24 + k * 56.0,
                  y: 260,
                  width: 48,
                  height: 40,
                  indexBadge: '[$k]',
                  groupTag: 'copy',
                  visualState: k == activeB
                      ? NodeVisualState.active
                      : NodeVisualState.normal,
                ),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'space',
              title: '额外元素槽（两程序分别计数）',
              columns: const ['算法', '当前槽数', '渐近辅助空间', '写次数'],
              rows: [
                ['原地', allocated ? '1' : '0', 'O(1)', '$stepsA'],
                ['副本', allocated ? '$n' : '0', 'O(n)', '$stepsB'],
              ],
            ),
          ],
        ),
      );
    }

    emit('同一输入，两种逆序', [1, 9], milestone: true);
    allocated = true;
    t = 0;
    emit(
      '申请 t 与 b[n]',
      [2, 10],
      counts: {2: 1, 10: 1},
      space: n + 1,
      milestone: true,
    );
    final actions = math.max(3 * (n ~/ 2), n);
    for (var step = 0; step < actions; step++) {
      final lines = <int>[], counts = <int, int>{};
      var writes = 0, reads = 0, activeA = -1;
      if (step < 3 * (n ~/ 2)) {
        i = step ~/ 3;
        j = n - 1 - i;
        final part = step % 3;
        if (part == 0) {
          t = a[i];
          lines.addAll([3, 4]);
          counts.addAll({3: 1, 4: 1});
          activeA = i;
        }
        if (part == 1) {
          a[i] = a[j];
          lines.add(5);
          counts[5] = 1;
          activeA = i;
        }
        if (part == 2) {
          a[j] = t!;
          lines.add(6);
          counts[6] = 1;
          activeA = j;
        }
        stepsA++;
        writes++;
        reads++;
      }
      if (step < n) {
        b[step] = original[n - 1 - step];
        lines.addAll([11, 12]);
        counts.addAll({11: 1, 12: 1});
        stepsB++;
        writes++;
        reads++;
      }
      emit(
        '并排动作 ${step + 1}',
        lines,
        counts: counts,
        writes: writes,
        reads: reads,
        activeA: activeA,
        activeB: step < n ? step : -1,
      );
    }
    emit('逆序完成：额外空间 1 对 n', [8, 14], milestone: true);
    return builder.build();
  }
}
