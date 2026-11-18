import 'dart:convert';
import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'cases_trace.dart';

enum CaseKind { conversion, brackets, expression, dance }

class CasesInput {
  const CasesInput({
    this.kind = CaseKind.expression,
    this.number = 1348,
    this.radix = 8,
    this.text = '3*(7-2)#',
    this.male = const ['阿明', '小林', '阿杰', '小周'],
    this.female = const ['小雨', '小岚', '小夏'],
    this.rounds = 2,
  });
  final CaseKind kind;
  final int number, radix, rounds;
  final String text;
  final List<String> male, female;
  String get raw => jsonEncode({
    'kind': kind.name,
    'number': number,
    'radix': radix,
    'text': text,
    'male': male,
    'female': female,
    'rounds': rounds,
  });
}

abstract final class OperatorPrecedence {
  static const operators = ['+', '-', '*', '/', '(', ')', '#'];
  static const rows = [
    ['>', '>', '<', '<', '<', '>', '>'],
    ['>', '>', '<', '<', '<', '>', '>'],
    ['>', '>', '>', '>', '<', '>', '>'],
    ['>', '>', '>', '>', '<', '>', '>'],
    ['<', '<', '<', '<', '<', '=', '!'],
    ['>', '>', '>', '>', '!', '>', '>'],
    ['<', '<', '<', '<', '<', '!', '='],
  ];
  static String compare(String top, String current) =>
      rows[operators.indexOf(top)][operators.indexOf(current)];
}

class CasesExprDanceModule implements AlgorithmModule<CasesInput> {
  const CasesExprDanceModule();
  @override
  String get id => 'ch3_cases_expr_dance';
  static const kindNames = ['数制转换', '括号匹配', '算符优先求值', '舞伴配对'];
  static CasesInput initial(CaseKind kind) => switch (kind) {
    CaseKind.conversion => const CasesInput(kind: CaseKind.conversion),
    CaseKind.brackets => const CasesInput(
      kind: CaseKind.brackets,
      text: '[() [() []]]',
    ),
    CaseKind.expression => const CasesInput(),
    CaseKind.dance => const CasesInput(kind: CaseKind.dance),
  };
  @override
  List<AlgorithmPreset<CasesInput>> get presets => const [
    AlgorithmPreset(
      id: 'classic',
      name: '表达式 · 3*(7-2)=15',
      input: CasesInput(),
    ),
    AlgorithmPreset(
      id: 'multi',
      name: '表达式 · 多位数与优先级',
      input: CasesInput(text: '4+2*3-10/5#'),
    ),
    AlgorithmPreset(
      id: 'division-zero',
      name: '表达式 · 零除',
      input: CasesInput(text: '8/(3-3)#'),
    ),
    AlgorithmPreset(
      id: 'octal',
      name: '数制 · 1348 转八进制',
      input: CasesInput(kind: CaseKind.conversion),
    ),
    AlgorithmPreset(
      id: 'hex',
      name: '数制 · 255 转十六进制',
      input: CasesInput(kind: CaseKind.conversion, number: 255, radix: 16),
    ),
    AlgorithmPreset(
      id: 'zero',
      name: '数制 · 零也输出一位',
      input: CasesInput(kind: CaseKind.conversion, number: 0, radix: 2),
    ),
    AlgorithmPreset(
      id: 'balanced',
      name: '括号 · 完全匹配',
      input: CasesInput(kind: CaseKind.brackets, text: '[() [() []]]'),
    ),
    AlgorithmPreset(
      id: 'left',
      name: '括号 · 左括号冗余',
      input: CasesInput(kind: CaseKind.brackets, text: '([]'),
    ),
    AlgorithmPreset(
      id: 'right',
      name: '括号 · 右括号冗余',
      input: CasesInput(kind: CaseKind.brackets, text: '()]'),
    ),
    AlgorithmPreset(
      id: 'mismatch',
      name: '括号 · 类型不符',
      input: CasesInput(kind: CaseKind.brackets, text: '([)]'),
    ),
    AlgorithmPreset(
      id: 'dance',
      name: '舞伴 · 等待者优先',
      input: CasesInput(kind: CaseKind.dance),
    ),
    AlgorithmPreset(
      id: 'dance-empty',
      name: '舞伴 · 一侧无人',
      input: CasesInput(kind: CaseKind.dance, male: [], rounds: 1),
    ),
  ];
  @override
  ValidationResult<CasesInput> validateInput(String raw) {
    try {
      final p = jsonDecode(raw) as Map<String, dynamic>;
      final kind = CaseKind.values.byName(p['kind'] as String);
      final input = CasesInput(
        kind: kind,
        number: p['number'] as int,
        radix: p['radix'] as int,
        text: p['text'] as String,
        male: List<String>.from(p['male'] as List),
        female: List<String>.from(p['female'] as List),
        rounds: p['rounds'] as int,
      );
      switch (kind) {
        case CaseKind.conversion:
          if (input.number < 0 ||
              input.number > 65535 ||
              ![2, 8, 16].contains(input.radix)) {
            return const ValidationResult.failure(
              'N 为 0～65535 整数；进制选择 2、8 或 16。',
            );
          }
        case CaseKind.brackets:
          if (input.text.length > 32 ||
              !RegExp(r'^[()\[\]{}\s]*$').hasMatch(input.text)) {
            return const ValidationResult.failure('最多 32 字符，只接受三类括号和空白。');
          }
        case CaseKind.expression:
          final s = input.text.replaceAll(RegExp(r'\s'), '');
          if (s.length < 2 ||
              s.length > 32 ||
              !RegExp(r'^[0-9+*/()\-]+#$').hasMatch(s) ||
              RegExp(r'\d+').allMatches(s).any((m) => int.parse(m[0]!) > 999)) {
            return const ValidationResult.failure(
              '2～32 字符，以 # 结束；支持 0～999 整数、二元 + − * / 与圆括号，不支持一元负号。',
            );
          }
        case CaseKind.dance:
          final names = [...input.male, ...input.female];
          if (input.rounds < 1 ||
              input.rounds > 4 ||
              input.male.length > 6 ||
              input.female.length > 6 ||
              names.any((n) => n.trim().isEmpty || n.length > 8)) {
            return const ValidationResult.failure(
              '每队最多 6 人，姓名 1～8 字符；曲目 1～4 轮。',
            );
          }
      }
      return ValidationResult.success(input);
    } catch (_) {
      return const ValidationResult.failure('输入字段或数字格式不正确。');
    }
  }

  @override
  TraceTimeline generateTrace(CasesInput input) {
    if (!validateInput(input.raw).isValid) {
      throw ArgumentError('Invalid cases input');
    }
    return generateCasesTrace(input);
  }
}
