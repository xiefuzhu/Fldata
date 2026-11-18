import 'dart:math' as math;
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';

enum ComplexOperation { creat, getReal, getImag, add, sub, multiply, divide }

class ComplexValue {
  const ComplexValue(this.real, this.imag);
  final double real, imag;
  double get radius => math.sqrt(real * real + imag * imag);
  double get angle => math.atan2(imag, real);
  String get display =>
      '${number(real)} ${imag < 0 ? '−' : '+'} ${number(imag.abs())}i';
  static String number(double v) {
    if (v == 0) return '0';
    if (v.abs() < .0001 || v.abs() >= 1e5) return v.toStringAsExponential(4);
    return v.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class ComplexInput {
  const ComplexInput({
    this.operation = ComplexOperation.add,
    this.a = const ComplexValue(2, 1),
    this.b = const ComplexValue(1, 2),
  });
  final ComplexOperation operation;
  final ComplexValue a, b;
  ComplexInput copyWith({
    ComplexOperation? operation,
    ComplexValue? a,
    ComplexValue? b,
  }) => ComplexInput(
    operation: operation ?? this.operation,
    a: a ?? this.a,
    b: b ?? this.b,
  );
}

/// Teaching values use double arithmetic, not a particular machine ABI.
class AdtComplexModule implements AlgorithmModule<ComplexInput> {
  const AdtComplexModule();
  static const initialC = ComplexValue(9, -9);
  static const names = [
    'Creat',
    'GetReal',
    'GetImag',
    'Add',
    'Sub',
    'Multiply',
    'Divide',
  ];
  @override
  String get id => 'ch1_adt_complex';
  @override
  List<AlgorithmPreset<ComplexInput>> get presets => const [
    AlgorithmPreset(
      id: 'add',
      name: '向量相加 · (2+i)+(1+2i)',
      input: ComplexInput(),
    ),
    AlgorithmPreset(
      id: 'rotate',
      name: '乘以 i · 逆时针旋转 90°',
      input: ComplexInput(
        operation: ComplexOperation.multiply,
        b: ComplexValue(0, 1),
      ),
    ),
    AlgorithmPreset(
      id: 'divide',
      name: '除法 · (3+4i)/(1−2i)',
      input: ComplexInput(
        operation: ComplexOperation.divide,
        a: ComplexValue(3, 4),
        b: ComplexValue(1, -2),
      ),
    ),
    AlgorithmPreset(
      id: 'zero',
      name: '边界 · 除数为零',
      input: ComplexInput(
        operation: ComplexOperation.divide,
        b: ComplexValue(0, 0),
      ),
    ),
  ];
  @override
  ValidationResult<ComplexInput> validateInput(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) {
      return const ValidationResult.failure('输入格式：操作 A实部 A虚部 B实部 B虚部');
    }
    final op = ComplexOperation.values
        .where((v) => v.name == parts[0])
        .firstOrNull;
    final values = parts.skip(1).map(double.tryParse).toList();
    if (op == null ||
        values.any(
          (v) =>
              v == null ||
              !v.isFinite ||
              v.abs() > 20 ||
              (v != 0 && v.abs() < .01),
        )) {
      return const ValidationResult.failure('各分量须为 −20～20 的有限数；非零分量绝对值至少 0.01');
    }
    return ValidationResult.success(
      ComplexInput(
        operation: op,
        a: ComplexValue(values[0]!, values[1]!),
        b: ComplexValue(values[2]!, values[3]!),
      ),
    );
  }

  @override
  TraceTimeline generateTrace(ComplexInput input) {
    if (!validateInput(
      '${input.operation.name} ${input.a.real} ${input.a.imag} ${input.b.real} ${input.b.imag}',
    ).isValid) {
      throw ArgumentError('Invalid complex input');
    }
    final op = input.operation, a = input.a, b = input.b;
    final name = names[op.index];
    final getter =
        op == ComplexOperation.getReal || op == ComplexOperation.getImag;
    final polar =
        op == ComplexOperation.multiply || op == ComplexOperation.divide;
    final zero = op == ComplexOperation.divide && b.radius == 0;
    final denominator = b.real * b.real + b.imag * b.imag;
    final result = switch (op) {
      ComplexOperation.creat => a,
      ComplexOperation.getReal => ComplexValue(a.real, 0),
      ComplexOperation.getImag => ComplexValue(a.imag, 0),
      ComplexOperation.add => ComplexValue(a.real + b.real, a.imag + b.imag),
      ComplexOperation.sub => ComplexValue(a.real - b.real, a.imag - b.imag),
      ComplexOperation.multiply => ComplexValue(
        a.real * b.real - a.imag * b.imag,
        a.real * b.imag + a.imag * b.real,
      ),
      ComplexOperation.divide =>
        zero
            ? initialC
            : ComplexValue(
                (a.real * b.real + a.imag * b.imag) / denominator,
                (a.imag * b.real - a.real * b.imag) / denominator,
              ),
    };
    final startPlot = polar || getter || op == ComplexOperation.creat
        ? a
        : (op == ComplexOperation.sub ? ComplexValue(-b.real, -b.imag) : b);
    final endPlot = getter || zero ? a : result;
    final endAngle =
        a.angle + (op == ComplexOperation.divide ? -b.angle : b.angle);
    final limit =
        math.max(
          1.0,
          [a.radius, b.radius, zero ? 0.0 : endPlot.radius].reduce(math.max),
        ) *
        1.35;
    final field = op == ComplexOperation.getImag ? 'imagpart' : 'realpart';
    final realExpr = switch (op) {
      ComplexOperation.creat => 'r',
      ComplexOperation.add => 'A.realpart + B.realpart',
      ComplexOperation.sub => 'A.realpart - B.realpart',
      ComplexOperation.multiply =>
        'A.realpart * B.realpart - A.imagpart * B.imagpart',
      ComplexOperation.divide =>
        '(A.realpart * B.realpart + A.imagpart * B.imagpart) / d',
      _ => 'A.$field',
    };
    final imagExpr = switch (op) {
      ComplexOperation.creat => 'i',
      ComplexOperation.add => 'A.imagpart + B.imagpart',
      ComplexOperation.sub => 'A.imagpart - B.imagpart',
      ComplexOperation.multiply =>
        'A.realpart * B.imagpart + A.imagpart * B.realpart',
      ComplexOperation.divide =>
        '(A.imagpart * B.realpart - A.realpart * B.imagpart) / d',
      _ => '0',
    };
    List<String> code(CodeLang lang) {
      final dart = lang == CodeLang.dart, c99 = lang == CodeLang.c99;
      final output = c99 ? 'C->' : 'C.';
      final signature = getter
          ? 'Complex A'
          : op == ComplexOperation.creat
          ? (dart
                ? 'Complex C, double r, double i'
                : '${c99 ? 'Complex *C' : 'Complex &C'}, double r, double i')
          : 'Complex A, Complex B, ${c99
                ? 'Complex *C'
                : dart
                ? 'Complex C'
                : 'Complex &C'}';
      return [
        dart
            ? 'class Complex { double realpart, imagpart; Complex(this.realpart, this.imagpart); }'
            : 'typedef struct { double realpart, imagpart; } Complex;',
        '${getter
            ? 'double'
            : op == ComplexOperation.divide
            ? (c99 ? 'int' : 'bool')
            : 'void'} $name($signature) {',
        if (getter)
          '  return A.$field;'
        else ...[
          if (op == ComplexOperation.divide) ...[
            '  double d = B.realpart*B.realpart + B.imagpart*B.imagpart;',
            '  if (d == 0) return ${c99 ? '0' : 'false'};',
          ],
          '  double re = $realExpr;',
          '  double im = $imagExpr;',
          '  ${output}realpart = re;',
          '  ${output}imagpart = im;',
          '  return${op == ComplexOperation.divide ? (c99 ? ' 1' : ' true') : ''};',
        ],
        '}',
      ];
    }

    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: '$name · A=${a.display} · B=${b.display}',
      codeLines: {for (final lang in CodeLang.values) lang: code(lang)},
    );
    var c = initialC;
    var geometry = 0.0;
    var called = false;
    String? scalar;
    void emit(
      String title,
      String explanation,
      List<int> lines, {
      String? written,
      bool returned = false,
      bool error = false,
      bool milestone = false,
      int reads = 0,
    }) {
      final plot = geometry == 0 ? startPlot : endPlot;
      final vars = <String, String>{
        'A': a.display,
        'B': b.display,
        'C': c.display,
        if (called && !getter) 'C 引用': '调用方 C @ 0x3020',
        '返回值': ?scalar,
        if (error) '状态': 'ERROR：除数为零',
      };
      builder.step(
        title: title,
        explain: explanation,
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        vars: vars,
        scene: SceneSnapshot(
          nodes: [
            for (final entry in {'A': a, 'B': b, 'R': plot}.entries)
              SceneNode(
                id: entry.key,
                label: entry.key,
                x: entry.value.real,
                y: entry.value.imag,
                width: 12,
                height: 12,
                groupTag: 'plane',
              ),
            for (final entry in {'A': a, 'B': b, 'C': c}.entries)
              SceneNode(
                id: 'memory-${entry.key}',
                label: '${entry.key}\n${entry.value.display}',
                x: 24 + {'A': 0, 'B': 1, 'C': 2}[entry.key]! * 160.0,
                y: 40,
                width: 144,
                height: 80,
                memoryAddress: {
                  'A': '0x3000',
                  'B': '0x3010',
                  'C': '0x3020',
                }[entry.key],
                groupTag: 'memory',
                visualState: entry.key == 'C' && written != null
                    ? NodeVisualState.active
                    : error
                    ? NodeVisualState.error
                    : NodeVisualState.normal,
              ),
          ],
          pointers: [
            if (called && !getter && !returned)
              const PointerBadge(
                id: 'C-reference',
                label: '形参 C ≡ 调用方 C',
                targetNodeId: 'memory-C',
              ),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'complex-geometry',
              title: '绘图参数',
              columns: const ['progress', 'limit', 'radius', 'angle'],
              rows: [
                [
                  geometry.toString(),
                  limit.toString(),
                  (geometry == 0 ? startPlot.radius : endPlot.radius)
                      .toString(),
                  (geometry == 0
                          ? startPlot.angle
                          : (polar && a.radius != 0 && !zero
                                ? endAngle
                                : endPlot.angle))
                      .toString(),
                ],
              ],
            ),
            AuxTableSnapshot(
              id: 'complex-memory',
              title: '调用方内存（教学地址）',
              columns: const ['对象', '地址', 'realpart', 'imagpart'],
              rows: [
                [
                  'A',
                  '0x3000',
                  ComplexValue.number(a.real),
                  ComplexValue.number(a.imag),
                ],
                [
                  'B',
                  '0x3010',
                  ComplexValue.number(b.real),
                  ComplexValue.number(b.imag),
                ],
                [
                  'C',
                  '0x3020',
                  ComplexValue.number(c.real),
                  ComplexValue.number(c.imag),
                ],
              ],
              highlightedRows: {if (written != null) 2},
            ),
          ],
        ),
        callStack: [
          const StackActivationRecord(
            id: 'caller',
            functionName: 'Main',
            returnLocation: '结束',
          ),
          if (called && !returned)
            StackActivationRecord(
              id: 'operation',
              parentCallId: 'caller',
              functionName: name,
              arguments: {
                if (op == ComplexOperation.creat) ...{
                  'r': ComplexValue.number(a.real),
                  'i': ComplexValue.number(a.imag),
                } else
                  'A': a.display,
                if (!getter && op != ComplexOperation.creat) 'B': b.display,
                if (!getter) 'C': '&0x3020',
              },
              locals: {
                if (geometry == 1 && !getter && !zero)
                  're': ComplexValue.number(result.real),
                if (geometry == 1 && !getter && !zero)
                  'im': ComplexValue.number(result.imag),
                'return': ?scalar,
              },
              returnLocation: 'Main：读取结果',
            ),
        ],
        deltaRead: reads,
        deltaWrite: written == null ? 0 : 1,
        error: error,
        milestone: milestone,
      );
    }

    emit(
      'ADT Complex = (D, S, P)',
      'D：实数对 (r,i)。S：复数值之间没有固定的前驱/后继结构。P：创建、读取和四则运算。调用者依赖操作契约；realpart/imagpart 是本次选择的内部表示。',
      [1],
      milestone: true,
    );
    called = true;
    emit(
      '调用 $name',
      '${getter ? 'A 按值传入；读取分量不修改 A 或 C。' : '类 C 的 &C、C99 的指针、Dart 的对象引用都使写入落在调用方 C。A/B 为输入，先计算临时 re、im，再写回。'} 教学地址用于说明别名，不代表真实 ABI。',
      [2],
    );
    if (zero) {
      emit(
        '除数为零 · C 保持不变',
        'B.realpart²+B.imagpart²=0，除法未定义，返回失败；不执行两次成员写入。',
        [3, 4],
        error: true,
        milestone: true,
        reads: 2,
      );
      return builder.build();
    }
    if (getter) {
      scalar = ComplexValue.number(
        op == ComplexOperation.getReal ? a.real : a.imag,
      );
      emit(
        '读取 $field',
        '返回实数 $scalar；复平面上的 A 保持原位，调用方 C 不变。',
        [3],
        reads: 1,
        milestone: true,
      );
      emit('返回调用方', '只返回分量值，不修改复数对象。', [3], returned: true, milestone: true);
      return builder.build();
    }
    final offset = op == ComplexOperation.divide ? 2 : 0;
    geometry = 1;
    emit(
      polar ? '模长与极角运算' : '几何构造与分量计算',
      switch (op) {
        ComplexOperation.add => '将 B 平移到 A 端点，平行四边形对角线为 A+B。临时值已计算，C 尚未写入。',
        ComplexOperation.sub => 'A−B=A+(−B)，将反向的 B 平移到 A 端点。C 尚未写入。',
        ComplexOperation.multiply =>
          '|AB|=|A||B|，arg(AB)=arg(A)+arg(B)（模 2π）。动画将 A 旋转 arg(B) 并缩放 |B|。零向量没有定义的极角，结果仍为零。',
        ComplexOperation.divide =>
          '|A/B|=|A|/|B|，arg(A/B)=arg(A)−arg(B)（模 2π）；分母模平方为 ${ComplexValue.number(denominator)}。',
        _ => '用给定的实部 r、虚部 i 创建复数，先保存到临时值。',
      },
      [3 + offset, 4 + offset],
      reads: op == ComplexOperation.creat ? 0 : 4,
      milestone: true,
    );
    c = ComplexValue(result.real, c.imag);
    emit(
      '写回 C.realpart',
      '只写入实部 ${ComplexValue.number(result.real)}；虚部仍是旧值 −9。C 的地址仍为 0x3020。',
      [5 + offset],
      written: 'realpart',
    );
    c = result;
    emit(
      '写回 C.imagpart',
      '再写入虚部 ${ComplexValue.number(result.imag)}，调用方 C 现在是 ${result.display}。没有额外分配一个输出对象。',
      [6 + offset],
      written: 'imagpart',
    );
    emit(
      '返回调用方',
      '输出 C=${result.display}。运算与辅助存储均为 O(1)；数值采用 double，界面显示会舍入。',
      [7 + offset],
      returned: true,
      milestone: true,
    );
    return builder.build();
  }
}
