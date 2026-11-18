import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch3_stack_queue/cases_expr_dance.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = CasesExprDanceModule();
  List<String> status(TraceFrame f) => f.scene.auxTables[0].rows.first;
  List<String> values(TraceFrame f, int table) =>
      f.scene.auxTables[table].rows.map((r) => r[1]).toList();
  test('conversion uses reversed remainders, zero and all three radices', () {
    for (final n in [0, 1, 2, 7, 8, 15, 16, 255, 1348, 65535]) {
      for (final d in [2, 8, 16]) {
        final trace = module.generateTrace(
          CasesInput(kind: CaseKind.conversion, number: n, radix: d),
        );
        expect(status(trace.frames.last)[1], n.toRadixString(d).toUpperCase());
        expect(values(trace.frames.last, 2), isEmpty);
        expect(
          trace.frames.where((f) => f.phaseTitle.startsWith('输出 ')).length,
          n.toRadixString(d).length,
        );
      }
    }
  });
  test('bracket matching distinguishes left, right and type mismatch', () {
    for (final entry in {
      '': 'OK',
      '[() [() []]]': 'OK',
      '{[()]}': 'OK',
      '([]': '左括号冗余',
      '()]': '右括号冗余',
      '([)]': '左右类型不符',
    }.entries) {
      final t = module.generateTrace(
        CasesInput(kind: CaseKind.brackets, text: entry.key),
      );
      expect(status(t.frames.last)[0], entry.value);
      expect(t.frames.last.isErrorState, entry.value != 'OK');
      if (entry.value == '左右类型不符') {
        expect(t.frames.last.metrics.comparisons, 1);
        expect(
          t.frames.last.scene.nodes.last.visualState,
          NodeVisualState.error,
        );
      }
      if (entry.value == 'OK') expect(values(t.frames.last, 2), isEmpty);
    }
  });
  test(
    'expression precedence, multi-digit, associativity and division retain precision',
    () {
      for (final entry in {
        '3*(7-2)#': 15,
        '4+2*3-10/5#': 8,
        '20-8-3#': 9,
        '24/4/2#': 3,
        '2*(12+3)#': 30,
        '1/3*3#': 1,
        '1/(3/7)#': 7 / 3,
        '0#': 0,
        '((12))#': 12,
        '8/(1-3)#': -4,
      }.entries) {
        final t = module.generateTrace(CasesInput(text: entry.key));
        expect(status(t.frames.last)[0], 'OK', reason: entry.key);
        expect(
          double.parse(status(t.frames.last)[1]),
          closeTo(entry.value, 1e-7),
        );
        expect(values(t.frames.last, 2), ['#']);
        expect(values(t.frames.last, 3).length, 1);
      }
      expect(OperatorPrecedence.compare('(', ')'), '=');
      expect(OperatorPrecedence.compare('#', '#'), '=');
      expect(OperatorPrecedence.compare('(', '#'), '!');
      expect(OperatorPrecedence.compare('#', ')'), '!');
      expect(OperatorPrecedence.compare('+', '*'), '<');
      expect(OperatorPrecedence.compare('/', '*'), '>');
    },
  );
  test(
    'expression reductions separate b, a, theta, compute and push; errors stop',
    () {
      final t = module.generateTrace(const CasesInput(text: '20-8#'));
      final i = t.frames.indexWhere((f) => f.phaseTitle.startsWith('①'));
      expect(values(t.frames[i], 3), ['20']);
      expect(t.frames[i].inlineVars['b'], '8');
      expect(values(t.frames[i + 1], 3), isEmpty);
      expect(t.frames[i + 1].inlineVars['a'], '20');
      expect(values(t.frames[i + 2], 2), ['#']);
      expect(t.frames[i + 2].inlineVars['theta'], '-');
      expect(t.frames[i + 3].inlineVars['result'], '12');
      expect(values(t.frames[i + 4], 3), ['12.0']);
      for (var j = 0; j < 5; j++) {
        expect(status(t.frames[i + j])[2], '#');
      }
      for (final entry in {
        '8/(3-3)#': '除数为零',
        '(1#': '括号不匹配',
        '1)#': '括号不匹配',
        '1++2#': '缺少操作数或运算符',
        '1 2#': '缺少运算符',
        '2(3)#': '缺少操作数或运算符',
      }.entries) {
        final error = module
            .generateTrace(CasesInput(text: entry.key))
            .frames
            .last;
        expect(error.isErrorState, isTrue, reason: entry.key);
        expect(status(error)[0], entry.value);
        expect(status(error)[1], isEmpty);
      }
    },
  );
  test(
    'dance preserves FIFO, waiting priority and identity across rounds and empty sides',
    () {
      final t = module.generateTrace(const CasesInput(kind: CaseKind.dance));
      expect(t.frames.last.scene.auxTables[4].rows, [
        ['1', '阿明 + 小雨'],
        ['1', '小林 + 小岚'],
        ['1', '阿杰 + 小夏'],
        ['2', '小周 + 小雨'],
        ['2', '阿明 + 小岚'],
        ['2', '小林 + 小夏'],
      ]);
      expect(values(t.frames.last, 2), ['阿杰', '小周', '阿明', '小林']);
      for (var m = 0; m <= 6; m++) {
        for (var f = 0; f <= 6; f++) {
          final input = CasesInput(
            kind: CaseKind.dance,
            male: List.generate(m, (i) => 'M$i'),
            female: List.generate(f, (i) => 'F$i'),
            rounds: 3,
          );
          final trace = module.generateTrace(input), last = trace.frames.last;
          expect(last.scene.auxTables[4].rows.length, 3 * (m < f ? m : f));
          expect(values(last, 2), unorderedEquals(input.male));
          expect(values(last, 3), unorderedEquals(input.female));
          final ids = trace.frames[1].scene.nodes.map((n) => n.id).toSet();
          for (final frame in trace.frames.skip(1)) {
            expect(frame.scene.nodes.map((n) => n.id).toSet(), ids);
          }
        }
      }
    },
  );
  test('presets deterministic, serializable and input limits meaningful', () {
    for (final preset in module.presets) {
      expect(module.validateInput(preset.input.raw).isValid, isTrue);
      final t = module.generateTrace(preset.input);
      expect(t, module.generateTrace(preset.input));
      expect(
        TraceTimeline.fromJson(
          jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>,
        ),
        t,
      );
      expect(
        () => t.frames.first.scene.nodes.add(
          const SceneNode(id: 'x', label: 'x', x: 0, y: 0),
        ),
        throwsUnsupportedError,
      );
    }
    for (final input in [
      const CasesInput(text: '-2#'),
      const CasesInput(text: '2.5#'),
    ]) {
      // Unary minus is a trace-level syntax error; decimal literals are not in the input grammar.
      if (input.text == '-2#') {
        expect(module.generateTrace(input).frames.last.isErrorState, isTrue);
      } else {
        expect(module.validateInput(input.raw).isValid, isFalse);
      }
    }
    expect(
      module
          .validateInput(
            const CasesInput(kind: CaseKind.conversion, number: -1).raw,
          )
          .isValid,
      isFalse,
    );
    expect(
      module
          .validateInput(
            const CasesInput(kind: CaseKind.brackets, text: 'abc').raw,
          )
          .isValid,
      isFalse,
    );
  });
}
