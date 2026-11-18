import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/bf_kmp.dart';

void main() {
  const module = BfKmpModule();
  test('textbook example aligns both tracks at position six', () {
    final trace = module.generateTrace(const MatchInput());
    final last = trace.frames.last;
    expect(last.inlineVars['BF.result'], '6');
    expect(last.inlineVars['KMP.result'], '6');
    expect(
      trace.frames.first.scene.nodes.where((n) => n.isZeroSentinelSlot).length,
      4,
    );
    expect(
      trace.frames.expand((f) => f.scene.edges).any((e) => e.id == 'bf-shift'),
      isTrue,
    );
    var previous = 1;
    for (final frame in trace.frames) {
      final i = int.parse(frame.inlineVars['KMP.i']!);
      expect(i, greaterThanOrEqualTo(previous));
      if (frame.scene.auxTables.last.rows.last.last.startsWith('锁定')) {
        expect(i, previous);
      }
      previous = i;
    }
  });
  test('lookup tables and sentinel jumps agree with one-based examples', () {
    expect(failureLinks(SString('abaabcac'), optimized: false).skip(1), [
      0,
      1,
      1,
      2,
      2,
      3,
      1,
      2,
    ]);
    expect(failureLinks(SString('abaabcac'), optimized: true).skip(1), [
      0,
      1,
      0,
      2,
      1,
      3,
      0,
      2,
    ]);
    expect(failureLinks(SString('aaaab'), optimized: true).skip(1), [
      0,
      0,
      0,
      0,
      4,
    ]);
  });
  test('both variants report the first occurrence on short binary strings', () {
    final words = ['', 'a', 'b', 'aa', 'ab', 'ba', 'bb', 'aba', 'bab', 'aaa'];
    for (final text in words) {
      for (final pattern in words) {
        for (final optimized in [false, true]) {
          final trace = module.generateTrace(
            MatchInput(text: text, pattern: pattern, optimized: optimized),
          );
          final expected = (text.indexOf(pattern) + 1).toString();
          expect(trace.frames.last.inlineVars['BF.result'], expected);
          expect(trace.frames.last.inlineVars['KMP.result'], expected);
        }
      }
    }
  });
}
