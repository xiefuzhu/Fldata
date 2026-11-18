import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch2_linear_list/sqlist_ops.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = SqListModule();
  List<int> values(TraceFrame f) {
    final length = int.parse(f.inlineVars['length']!);
    return [
      for (var k = 0; k < length; k++)
        int.parse(f.scene.nodes.firstWhere((n) => n.id == 'slot-$k').label),
    ];
  }

  test(
    'insert/delete all legal positions, empty and singleton, exact moves and retained slots',
    () {
      for (var n = 0; n <= 6; n++) {
        final original = List.generate(n, (k) => 10 + k);
        for (var i = 1; i <= n + 1; i++) {
          final trace = module.generateTrace(
            SqListInput(values: original, capacity: 7, position: i),
          );
          final expected = [...original]..insert(i - 1, 99);
          expect(values(trace.frames.last), expected);
          expect(trace.frames.last.metrics.moves, n - i + 1);
          expect(trace.frames.last.inlineVars.containsKey('j'), isFalse);
          expect(trace.frames.last.metrics.writes, n - i + 2);
          expect(values(trace.frames.first), original);
          for (final f in trace.frames.where(
            (f) => f.phaseTitle.startsWith('elem['),
          )) {
            expect(f.inlineVars['length'], '$n');
            final j = int.parse(f.inlineVars['j']!);
            expect(
              f.scene.nodes.firstWhere((x) => x.id == 'slot-$j').label,
              '${original[j]}',
            );
          }
        }
        for (var i = 1; i <= n; i++) {
          final trace = module.generateTrace(
            SqListInput(
              operation: SqListOperation.delete,
              values: original,
              capacity: 7,
              position: i,
            ),
          );
          final expected = [...original]..removeAt(i - 1);
          expect(values(trace.frames.last), expected);
          expect(trace.frames.last.inlineVars['out'], '${original[i - 1]}');
          expect(trace.frames.last.metrics.moves, n - i);
          expect(trace.frames.last.inlineVars.containsKey('j'), isFalse);
          expect(
            trace.frames.last.scene.nodes
                .firstWhere((x) => x.id == 'slot-${n - 1}')
                .label,
            '${original.last}',
          );
          expect(values(trace.frames.first), original);
        }
      }
    },
  );
  test('bounds precede capacity; ERROR and OVERFLOW never mutate storage', () {
    for (final op in [
      SqListOperation.insert,
      SqListOperation.delete,
      SqListOperation.get,
    ]) {
      for (final i in [0, op == SqListOperation.insert ? 6 : 5]) {
        final trace = module.generateTrace(
          SqListInput(operation: op, position: i),
        );
        expect(trace.frames.last.isErrorState, isTrue);
        expect(trace.frames.last.inlineVars['result'], 'ERROR');
        expect(values(trace.frames.last), values(trace.frames.first));
        expect(trace.frames.last.metrics.writes, 0);
      }
    }
    final full = module.generateTrace(const SqListInput(capacity: 4));
    expect(full.frames.last.inlineVars['result'], 'OVERFLOW');
    expect(full.frames.last.metrics.moves, 0);
    expect(
      module
          .generateTrace(const SqListInput(capacity: 4, position: 0))
          .frames
          .last
          .inlineVars['result'],
      'ERROR',
    );
    expect(
      module
          .generateTrace(
            const SqListInput(operation: SqListOperation.delete, values: []),
          )
          .frames
          .last
          .isErrorState,
      isTrue,
    );
  });
  test(
    'GetElem reads once with exact byte address and Locate returns first match',
    () {
      final get = module.generateTrace(
        const SqListInput(operation: SqListOperation.get, position: 3),
      );
      expect(get.frames.last.inlineVars['out'], '36');
      expect(get.frames.last.metrics.reads, 1);
      expect(get.frames.last.metrics.moves, 0);
      expect(get.frames[get.frames.length - 2].explanation, contains('0x4008'));
      for (final (data, target, result, count) in [
        ([7, 8, 7], 7, '1', 1),
        ([7, 8, 7], 8, '2', 2),
        ([7, 8, 7], 9, '0', 3),
        (<int>[], 7, '0', 0),
      ]) {
        final trace = module.generateTrace(
          SqListInput(
            operation: SqListOperation.locate,
            values: data,
            value: target,
          ),
        );
        expect(trace.frames.last.inlineVars['result'], result);
        expect(trace.frames.last.metrics.comparisons, count);
      }
    },
  );
  test(
    'Init allocates uninitialized slots with length zero and parser allows teachable errors',
    () {
      final trace = module.generateTrace(
        const SqListInput(operation: SqListOperation.init),
      );
      expect(trace.frames.first.scene.nodes, isEmpty);
      expect(trace.frames.last.scene.nodes.length, 6);
      expect(
        trace.frames.last.scene.nodes.every((n) => n.label == '·'),
        isTrue,
      );
      expect(trace.frames.last.inlineVars['length'], '0');
      expect(trace.frames.last.metrics.allocations, 1);
      expect(module.validateInput('insert|4|0|99|1,2').isValid, isTrue);
      expect(module.validateInput('get|4|1|0|').isValid, isTrue);
      expect(module.validateInput('insert|2|1|99|1,2,3').isValid, isFalse);
      expect(module.validateInput('insert|4|1|NaN|1,2').isValid, isFalse);
    },
  );
  test(
    'assignment copy takes reversible arc while source slot stays in place; snapshots roundtrip',
    () {
      final trace = module.generateTrace(const SqListInput());
      final k = trace.frames.indexWhere(
        (f) => f.phaseTitle == '准备复制 [3] → [4]',
      );
      final a = trace.frames[k].scene, b = trace.frames[k + 1].scene;
      final middle = SceneInterpolator.lerp(a, b, .5);
      final ghost = middle.nodes.firstWhere((n) => n.id == 'copy-3-4');
      expect(ghost.x, 32 + 3.5 * 64);
      expect(ghost.y, lessThan(128));
      expect(middle.nodes.firstWhere((n) => n.id == 'slot-3').x, 32 + 3 * 64);
      expect(middle.nodes.firstWhere((n) => n.id == 'slot-4').label, '·');
      expect(b.nodes.firstWhere((n) => n.id == 'slot-4').label, '48');
      expect(SceneInterpolator.lerp(a, b, 0), a);
      expect(SceneInterpolator.lerp(a, b, 1), b);
      expect(
        TraceTimeline.fromJson(jsonDecode(jsonEncode(trace.toJson()))),
        trace,
      );
    },
  );
}
