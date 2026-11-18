import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch1_intro/adt_complex.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/views/lab/complex_stage.dart';

void main() {
  const module = AdtComplexModule();
  List<String> c(TraceFrame f) =>
      f.scene.auxTables.singleWhere((t) => t.id == 'complex-memory').rows[2];
  test(
    'all operations compute expected values and write caller C in two separate steps',
    () {
      final expected = <ComplexOperation, List<double>>{
        ComplexOperation.creat: [3, 4],
        ComplexOperation.add: [4, 2],
        ComplexOperation.sub: [2, 6],
        ComplexOperation.multiply: [11, -2],
        ComplexOperation.divide: [-1, 2],
      };
      for (final op in ComplexOperation.values) {
        final trace = module.generateTrace(
          ComplexInput(
            operation: op,
            a: const ComplexValue(3, 4),
            b: const ComplexValue(1, -2),
          ),
        );
        expect(
          TraceTimeline.fromJson(jsonDecode(jsonEncode(trace.toJson()))),
          trace,
        );
        expect(
          module.generateTrace(
            ComplexInput(
              operation: op,
              a: const ComplexValue(3, 4),
              b: const ComplexValue(1, -2),
            ),
          ),
          trace,
        );
        for (final f in trace.frames) {
          expect(
            f.scene.auxTables
                .singleWhere((t) => t.id == 'complex-memory')
                .rows
                .take(2)
                .toList(),
            [
              ['A', '0x3000', '3', '4'],
              ['B', '0x3010', '1', '-2'],
            ],
          );
          for (final p in f.scene.pointers) {
            expect(p.targetNodeId, 'memory-C');
          }
        }
        if (expected.containsKey(op)) {
          final firstWrite = trace.frames.firstWhere(
            (f) => f.phaseTitle == '写回 C.realpart',
          );
          expect(
            double.parse(c(firstWrite)[2]),
            closeTo(expected[op]![0], 1e-5),
          );
          expect(c(firstWrite)[3], '-9');
          expect(firstWrite.metrics.writes, 1);
          expect(c(trace.frames[2]).skip(2).toList(), ['9', '-9']);
          expect(
            c(trace.frames.last).skip(2).map(double.parse).toList(),
            expected[op],
          );
          expect(trace.frames.last.metrics.writes, 2);
          expect(firstWrite.callStack.last.arguments['C'], '&0x3020');
          expect(trace.frames.last.scene.pointers, isEmpty);
          // Earlier snapshots retain the old value after both writes were recorded.
          expect(c(trace.frames.first).skip(2).toList(), ['9', '-9']);
        } else {
          expect(
            trace.frames.last.inlineVars['返回值'],
            op == ComplexOperation.getReal ? '3' : '4',
          );
          expect(c(trace.frames.last).skip(2).toList(), ['9', '-9']);
          expect(trace.frames.last.metrics.writes, 0);
        }
        expect(trace.frames.last.callStack.map((s) => s.id), ['caller']);
      }
    },
  );

  test(
    'division by zero records error without touching output or producing NaN',
    () {
      final trace = module.generateTrace(
        const ComplexInput(
          operation: ComplexOperation.divide,
          b: ComplexValue(0, 0),
        ),
      );
      expect(trace.frames.last.isErrorState, isTrue);
      expect(trace.frames.last.metrics.writes, 0);
      expect(c(trace.frames.last).skip(2).toList(), ['9', '-9']);
      for (final f in trace.frames) {
        for (final n in f.scene.nodes) {
          expect(n.x.isFinite && n.y.isFinite, isTrue);
        }
      }
      expect(trace.frames.first.isErrorState, isFalse);
    },
  );
  test(
    'geometry interpolates multiplication along angle and modulus, not a chord',
    () {
      final trace = module.generateTrace(
        const ComplexInput(
          operation: ComplexOperation.multiply,
          a: ComplexValue(2, 0),
          b: ComplexValue(0, 1),
        ),
      );
      final middle = ComplexPlaneGeometry(
        trace.frames[1],
        trace.frames[2],
        .5,
        ComplexOperation.multiply,
      );
      expect(middle.result.dx, closeTo(math.sqrt(2), 1e-9));
      expect(middle.result.dy, closeTo(math.sqrt(2), 1e-9));
      final add = module.generateTrace(const ComplexInput());
      final translated = ComplexPlaneGeometry(
        add.frames[1],
        add.frames[2],
        .5,
        ComplexOperation.add,
      );
      expect(translated.result.dx, 2);
      expect(translated.result.dy, 2.5);
      final zero = module.generateTrace(
        const ComplexInput(
          operation: ComplexOperation.multiply,
          a: ComplexValue(0, 0),
        ),
      );
      expect(
        ComplexPlaneGeometry(
          zero.frames[1],
          zero.frames[2],
          .5,
          ComplexOperation.multiply,
        ).result.distance,
        0,
      );
    },
  );
  test(
    'input bounds, fractional output and all built-in presets remain executable',
    () {
      for (final raw in [
        'add NaN 1 2 3',
        'add Infinity 1 2 3',
        'add 21 1 2 3',
        'add .001 0 1 0',
        'bad 1 2 3 4',
      ]) {
        expect(module.validateInput(raw).isValid, isFalse);
      }
      expect(module.validateInput('divide 1 0 0 0').isValid, isTrue);
      for (final p in module.presets) {
        expect(module.generateTrace(p.input).frames, isNotEmpty);
      }
      final trace = module.generateTrace(
        const ComplexInput(
          operation: ComplexOperation.divide,
          a: ComplexValue(.01, .01),
          b: ComplexValue(20, 20),
        ),
      );
      expect(double.parse(c(trace.frames.last)[2]), closeTo(.0005, 1e-9));
      expect(c(trace.frames.last)[3], '0');
      expect(ComplexValue.number(10), '10');
      expect(ComplexValue.number(.00000001), '1.0000e-8');
    },
  );
}
