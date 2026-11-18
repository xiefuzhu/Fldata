import 'dart:math' as math;
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

part 'matrix_transpose.dart';

enum MatrixMode { address, symmetric, lower, band, transpose }

typedef Triple = (int, int, int);

class MatrixInput {
  const MatrixInput({
    this.mode = MatrixMode.address,
    this.rows = 3,
    this.cols = 4,
    this.layers = 1,
    this.base = 4096,
    this.bytes = 4,
    this.columnMajor = false,
    this.i = 1,
    this.j = 2,
    this.z = 0,
    this.constant = 0,
    this.triples = const [(1, 2, 8), (2, 1, -3), (2, 4, 4), (3, 2, 7)],
  });
  final MatrixMode mode;
  final int rows, cols, layers, base, bytes, i, j, z, constant;
  final bool columnMajor;
  final List<Triple> triples;
  MatrixInput select(int layer, int row, int col, {bool? columns}) =>
      MatrixInput(
        mode: mode,
        rows: rows,
        cols: cols,
        layers: layers,
        base: base,
        bytes: bytes,
        columnMajor: columns ?? columnMajor,
        i: row,
        j: col,
        z: layer,
        constant: constant,
        triples: triples,
      );
  bool get compressed =>
      mode == MatrixMode.symmetric ||
      mode == MatrixMode.lower ||
      mode == MatrixMode.band;
  int get slots => switch (mode) {
    MatrixMode.symmetric => rows * (rows + 1) ~/ 2,
    MatrixMode.lower => rows * (rows + 1) ~/ 2 + 1,
    MatrixMode.band =>
      3 * rows - 1, // 3n−2 band entries, followed by the shared zero.
    _ => layers * rows * cols,
  };
  int slot(int d, int r, int c) {
    switch (mode) {
      case MatrixMode.address:
        return columnMajor
            ? (c * rows + r) * layers + d
            : (d * rows + r) * cols + c;
      case MatrixMode.symmetric:
        final a = math.max(r, c), b = math.min(r, c);
        return a * (a + 1) ~/ 2 + b;
      case MatrixMode.lower:
        return r < c ? slots - 1 : r * (r + 1) ~/ 2 + c;
      case MatrixMode.band:
        return (r - c).abs() > 1 ? slots - 1 : 2 * r + c;
      case MatrixMode.transpose:
        throw StateError('Sparse matrix uses triples');
    }
  }

  String valueAt(int k) {
    if (mode == MatrixMode.lower && k == slots - 1) return '$constant';
    if (mode == MatrixMode.band && k == slots - 1) return '0';
    return '${k + 1}';
  }

  String get parameters => '$rows $cols $layers $base $bytes $constant';
  String get entries =>
      triples.map((t) => '${t.$1},${t.$2},${t.$3}').join('; ');
}

class ArrayMatrixModule implements AlgorithmModule<MatrixInput> {
  const ArrayMatrixModule();
  @override
  String get id => 'ch4_array_matrix';
  static const names = ['数组寻址', '对称矩阵', '下三角矩阵', '三对角矩阵', '快速转置'];
  static MatrixInput example(MatrixMode mode) => switch (mode) {
    MatrixMode.address => const MatrixInput(),
    MatrixMode.transpose => const MatrixInput(mode: MatrixMode.transpose),
    _ => MatrixInput(mode: mode, rows: 4, cols: 4, i: 0, j: 3, constant: 7),
  };
  @override
  List<AlgorithmPreset<MatrixInput>> get presets => [
    for (final mode in MatrixMode.values)
      AlgorithmPreset(
        id: mode.name,
        name: names[mode.index],
        input: example(mode),
      ),
    const AlgorithmPreset(
      id: 'cube',
      name: '三维 · 两个切片',
      input: MatrixInput(layers: 2, z: 1),
    ),
    const AlgorithmPreset(
      id: 'empty',
      name: '全零稀疏矩阵',
      input: MatrixInput(mode: MatrixMode.transpose, triples: []),
    ),
  ];
  // Dialog format: mode | rows cols layers base bytes constant | triples.
  @override
  ValidationResult<MatrixInput> validateInput(String raw) {
    final parts = raw.split('|');
    if (parts.length != 3) return const ValidationResult.failure('矩阵参数不完整。');
    final mode = MatrixMode.values.where((m) => m.name == parts[0]).firstOrNull;
    final dims = parts[1]
        .trim()
        .split(RegExp(r'\s+'))
        .map(int.tryParse)
        .toList();
    if (mode == null || dims.length != 6 || dims.any((x) => x == null)) {
      return const ValidationResult.failure('请输入六个整数参数。');
    }
    final [r, c, d, b, l, constant] = dims.cast<int>();
    if (r < 1 ||
        r > 5 ||
        c < 1 ||
        c > 5 ||
        d < 1 ||
        d > 3 ||
        b < 0 ||
        b > 0xfffffff ||
        l < 1 ||
        l > 16) {
      return const ValidationResult.failure(
        '行列为 1～5，层数为 1～3，基址为 0～0xfffffff，元素占 1～16 字节。',
      );
    }
    if (mode != MatrixMode.address && d != 1) {
      return const ValidationResult.failure('矩阵模式使用单层。');
    }
    if (mode != MatrixMode.address && mode != MatrixMode.transpose && r != c) {
      return const ValidationResult.failure('压缩矩阵的行数与列数须相等。');
    }
    final triples = <Triple>[];
    if (mode == MatrixMode.transpose && parts[2].trim().isNotEmpty) {
      var last = -1;
      for (final entry in parts[2].split(';')) {
        final n = entry
            .trim()
            .split(',')
            .map((x) => int.tryParse(x.trim()))
            .toList();
        if (n.length != 3 || n.any((v) => v == null)) {
          return const ValidationResult.failure('三元组格式为 行,列,值，以分号分隔。');
        }
        final [row, col, value] = n.cast<int>();
        if (row < 1 ||
            row > r ||
            col < 1 ||
            col > c ||
            value == 0 ||
            (row - 1) * c + col <= last) {
          return const ValidationResult.failure(
            '三元组从 1 编号，按行、列递增，每个位置只写一个非零值。',
          );
        }
        last = (row - 1) * c + col;
        triples.add((row, col, value));
      }
    }
    return ValidationResult.success(
      MatrixInput(
        mode: mode,
        rows: r,
        cols: c,
        layers: d,
        base: b,
        bytes: l,
        constant: constant,
        i: 0,
        j: 0,
        triples: List.unmodifiable(triples),
      ),
    );
  }

  @override
  TraceTimeline generateTrace(MatrixInput input) {
    final check = validateInput(
      '${input.mode.name}|${input.parameters}|${input.entries}',
    );
    if (!check.isValid ||
        input.i < 0 ||
        input.i >= input.rows ||
        input.j < 0 ||
        input.j >= input.cols ||
        input.z < 0 ||
        input.z >= input.layers) {
      throw ArgumentError(check.error ?? '选中位置越界');
    }
    if (input.mode == MatrixMode.transpose) return _transposeTrace(input);
    return _storageTrace(input);
  }
}

double matrixMemoryX(MatrixInput a) => 130 + 60.0 * a.cols;
double matrixWidth(MatrixInput a) => matrixMemoryX(a) + 390;
double matrixHeight(MatrixInput a) => math.max(
  220.0,
  math.max(
    a.layers * (a.rows + 1) * 68.0 + 30,
    ((a.slots + 4) ~/ 5) * 68.0 + 95,
  ),
);

TraceTimeline _storageTrace(MatrixInput a) {
  final k = a.slot(a.z, a.i, a.j), address = a.base + k * a.bytes;
  final expression = switch (a.mode) {
    MatrixMode.address when a.layers == 1 => a.columnMajor ? 'j*m+i' : 'i*n+j',
    MatrixMode.address => a.columnMajor ? '(j*m+i)*depth+z' : '(z*m+i)*n+j',
    MatrixMode.symmetric => 'r*(r-1)/2+c-1',
    MatrixMode.lower => 'i<j ? m*(m+1)/2 : i*(i-1)/2+j-1',
    _ => '(i-j>1 || j-i>1) ? 3*m-2 : 2*i+j-3',
  };
  List<String> source(CodeLang lang) {
    final dart = lang == CodeLang.dart;
    final expr = dart ? expression.replaceAll('/2', '~/2') : expression;
    final sym = a.mode == MatrixMode.symmetric;
    if (lang == CodeLang.cLike) {
      return [
        '定位所选元素',
        '读入尺寸、基址与元素长度',
        sym ? 'r ← max(i,j), c ← min(i,j)' : '读取下标',
        'k ← $expression',
        '地址 ← base + k × bytes',
        '返回地址',
      ];
    }
    final type = dart ? 'int' : 'long long';
    return [
      '$type locate(int m,int n,int depth,int z,int i,int j,int base,int bytes) {',
      '  // ${a.compressed ? 'i, j 从 1 开始' : 'z, i, j 从 0 开始'}',
      sym
          ? '  int r=i>j?i:j, c=i<j?i:j;'
          : '  // ${ArrayMatrixModule.names[a.mode.index]}',
      '  int k=$expr;',
      '  return base+k*bytes;',
      '}',
    ];
  }

  final builder = TraceBuilder(
    moduleId: 'ch4_array_matrix',
    inputSummary: ArrayMatrixModule.names[a.mode.index],
    codeLines: {for (final lang in CodeLang.values) lang: source(lang)},
  );
  final selected = 'cell-${a.z}-${a.i}-${a.j}';
  void step(
    int line,
    String title,
    String explain, {
    int scan = -1,
    bool mapped = false,
    bool done = false,
  }) {
    final origin = a.compressed ? 1 : 0;
    final nodes = <SceneNode>[
      SceneNode(
        id: 'memory-label',
        label: '线性内存',
        x: matrixMemoryX(a),
        y: 12,
        width: 105,
        height: 35,
      ),
      for (var d = 0; d < a.layers; d++) ...[
        SceneNode(
          id: 'plane-$d',
          label: a.layers > 1 ? 'z = $d' : '矩阵 A',
          x: 20,
          y: 12 + d * (a.rows + 1) * 68.0,
          width: 90,
          height: 34,
        ),
        for (var r = 0; r < a.rows; r++)
          for (var c = 0; c < a.cols; c++)
            SceneNode(
              id: 'cell-$d-$r-$c',
              label: a.mode == MatrixMode.address
                  ? '${(d * a.rows + r) * a.cols + c + 1}'
                  : a.valueAt(a.slot(d, r, c)),
              x: 20 + c * 60.0,
              y: 62 + (d * (a.rows + 1) + r) * 68.0,
              width: 54,
              height: 43,
              indexBadge: '${r + origin},${c + origin}',
              visualState: d == a.z && r == a.i && c == a.j
                  ? NodeVisualState.active
                  : mapped &&
                        a.mode == MatrixMode.symmetric &&
                        a.i < a.j &&
                        r == a.j &&
                        c == a.i
                  ? NodeVisualState.comparing
                  : scan >= 0 && a.slot(d, r, c) == scan
                  ? NodeVisualState.moving
                  : scan >= 0 && a.slot(d, r, c) < scan
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
            ),
      ],
      for (var slot = 0; slot < a.slots; slot++)
        SceneNode(
          id: 'slot-$slot',
          label: a.mode == MatrixMode.address && a.columnMajor
              ? '${((slot % a.layers) * a.rows + (slot ~/ a.layers) % a.rows) * a.cols + slot ~/ (a.layers * a.rows) + 1}'
              : a.valueAt(slot),
          x: matrixMemoryX(a) + (slot % 5) * 64,
          y: 62 + (slot ~/ 5) * 68.0,
          width: 59,
          height: 43,
          indexBadge: '[$slot]',
          memoryAddress: '0x${(a.base + a.bytes * slot).toRadixString(16)}',
          visualState: done && slot == k
              ? NodeVisualState.active
              : slot == scan
              ? NodeVisualState.moving
              : NodeVisualState.normal,
        ),
    ];
    final lines = [line];
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: lines,
      c99Lines: lines,
      dartLines: lines,
      vars: {
        'i': '${a.i + origin}',
        'j': '${a.j + origin}',
        if (a.layers > 1) 'z': '${a.z}',
        if (mapped) 'k': '$k',
        if (done) 'LOC': '$address',
      },
      scene: SceneSnapshot(
        nodes: nodes,
        edges: [
          if (mapped && a.mode == MatrixMode.symmetric && a.i < a.j)
            SceneEdge(
              id: 'mirror',
              fromNodeId: selected,
              toNodeId: 'cell-0-${a.j}-${a.i}',
              curvature: 26,
            ),
          if (done)
            SceneEdge(
              id: 'address',
              fromNodeId: a.mode == MatrixMode.symmetric && a.i < a.j
                  ? 'cell-0-${a.j}-${a.i}'
                  : selected,
              toNodeId: 'slot-$k',
              curvature: -30,
            ),
        ],
      ),
      milestone: mapped,
    );
  }

  step(2, '选择矩阵元素', '点击左侧单元格可查看其地址。');
  if (a.mode == MatrixMode.address) {
    for (var offset = 0; offset < k; offset++) {
      step(
        3,
        '扫过前置元素 ${offset + 1}/$k',
        '按${a.columnMajor ? "列" : "行"}主序排列，此元素占据槽 $offset。',
        scan: offset,
      );
    }
  }
  final shared =
      (a.mode == MatrixMode.lower && a.i < a.j) ||
      (a.mode == MatrixMode.band && (a.i - a.j).abs() > 1);
  step(
    4,
    '映射到槽 $k',
    shared
        ? '该位置使用公共${a.mode == MatrixMode.band ? "零" : "常数"}槽。'
        : 'k = $expression = $k。',
    mapped: true,
  );
  step(
    5,
    'LOC = $address',
    '基址 ${a.base} + $k × ${a.bytes} 字节 = $address。',
    mapped: true,
    done: true,
  );
  return builder.build();
}
