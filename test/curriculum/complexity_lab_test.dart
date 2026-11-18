import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch1_intro/complexity_lab.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = ComplexityLabModule();
  int count(TraceTimeline t, int line) =>
      t.frames.last.metrics.statementCounts['line-$line'] ?? 0;
  test(
    'growth curves expose all seven functions including exponential n=20 and 32',
    () {
      expect(growthValues(1).values.toList(), [1, 0, 1, 0, 1, 1, 2]);
      expect(growthValues(20)['2ⁿ'], 1048576);
      expect(growthValues(32)['2ⁿ'], 4294967296);
      expect(growthValues(8)['log₂n'], closeTo(3, 1e-10));
    },
  );
  test(
    'constant linear square triangular and doubling loop frequencies match executed bodies',
    () {
      for (final n in [1, 3, 8, 32]) {
        for (final mode in [
          ComplexityMode.constant,
          ComplexityMode.linear,
          ComplexityMode.square,
          ComplexityMode.triangle,
          ComplexityMode.logarithmic,
        ]) {
          final trace = module.generateTrace(ComplexityInput(mode: mode, n: n));
          final (line, expected) = switch (mode) {
            ComplexityMode.constant => (3, 1),
            ComplexityMode.linear => (4, n),
            ComplexityMode.square => (5, n * n),
            ComplexityMode.triangle => (5, n * (n + 1) ~/ 2),
            _ => (6, (math.log(n) / math.ln2).ceil()),
          };
          expect(count(trace, line), expected, reason: '$mode n=$n');
          expect(trace.frames.last.inlineVars['s'], '$expected');
          expect(trace.frames.first.metrics.statementCounts, isEmpty);
        }
      }
    },
  );
  test(
    'matrix records every multiply-add and exact cubic count without batching',
    () {
      for (final n in [1, 2, 8]) {
        final trace = module.generateTrace(
          ComplexityInput(mode: ComplexityMode.matrix, n: n),
        );
        expect(count(trace, 2), n);
        expect(count(trace, 3), n * n);
        expect(count(trace, 4), n * n);
        expect(count(trace, 5), n * n * n);
        expect(count(trace, 6), n * n * n);
        expect(trace.frames.last.metrics.reads, 3 * n * n * n);
        expect(trace.frames.last.metrics.writes, n * n + n * n * n);
        final rows = trace.frames.last.scene.auxTables
            .singleWhere((t) => t.id == 'matrix-C')
            .rows;
        for (var i = 0; i < n; i++) {
          for (var j = 0; j < n; j++) {
            final expected = List.generate(
              n,
              (k) => (i + k + 1) * (k + 1) * (j + 1),
            ).reduce((a, b) => a + b);
            expect(rows[i][j], '$expected');
          }
        }
        expect(
          trace.frames.where((f) => f.phaseTitle.startsWith('乘加')).length,
          n * n * n,
        );
      }
    },
  );
  test(
    'search best middle worst and absent compare the actual prefix only',
    () {
      for (final scenario in SearchScenario.values) {
        final t = module.generateTrace(
          ComplexityInput(mode: ComplexityMode.search, n: 5, search: scenario),
        );
        final expected = switch (scenario) {
          SearchScenario.best => 1,
          SearchScenario.middle => 3,
          _ => 5,
        };
        expect(t.frames.last.metrics.comparisons, expected);
        expect(count(t, 3), expected);
        expect(
          t.frames.last.inlineVars['返回值'],
          scenario == SearchScenario.absent ? '-1' : '${expected - 1}',
        );
      }
    },
  );
  test(
    'reverse results agree, use distinct auxiliary spaces and retain earlier snapshots',
    () {
      for (final n in [1, 2, 7, 32]) {
        final trace = module.generateTrace(
          ComplexityInput(mode: ComplexityMode.reverse, n: n),
        );
        List<String> group(TraceFrame f, String tag) => f.scene.nodes
            .where((v) => v.groupTag == tag)
            .map((v) => v.label)
            .toList();
        expect(
          group(trace.frames.last, 'inplace'),
          List.generate(n, (i) => '${n - i}'),
        );
        expect(
          group(trace.frames.last, 'copy'),
          group(trace.frames.last, 'inplace'),
        );
        expect(
          group(trace.frames.first, 'inplace'),
          List.generate(n, (i) => '${i + 1}'),
        );
        expect(group(trace.frames.first, 'temp'), isEmpty);
        expect(group(trace.frames[1], 'temp'), ['0']);
        expect(trace.frames.last.metrics.peakAuxiliarySpace, n + 1);
        final rows = trace.frames.last.scene.auxTables.single.rows;
        expect(rows[0][1], '1');
        expect(rows[1][1], '$n');
        expect(rows[0][3], '${3 * (n ~/ 2)}');
        expect(rows[1][3], '$n');
        expect(
          TraceTimeline.fromJson(jsonDecode(jsonEncode(trace.toJson()))),
          trace,
        );
      }
    },
  );
  test('presets and input limits match the teaching controls', () {
    expect(module.validateInput('matrix 9 middle').isValid, isFalse);
    expect(module.validateInput('growth 32 middle').isValid, isTrue);
    expect(module.validateInput('linear 0 middle').isValid, isFalse);
    for (final p in module.presets) {
      expect(module.generateTrace(p.input).frames, isNotEmpty);
    }
  });
}
