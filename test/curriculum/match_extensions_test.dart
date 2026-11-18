import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/bf_kmp.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = BfKmpModule();
  test('microscope shows only computed cells and matching border segments', () {
    for (final (pattern, optimized, expected) in [
      ('abaabcac', false, [0, 1, 1, 2, 2, 3, 1, 2]),
      ('abaabcac', true, [0, 1, 0, 2, 1, 3, 0, 2]),
      ('aaaab', false, [0, 1, 2, 3, 4]),
      ('aaaab', true, [0, 0, 0, 0, 4]),
    ]) {
      final frames = module
          .generateTrace(
            MatchInput(
              mode: MatchMode.prefix,
              pattern: pattern,
              optimized: optimized,
            ),
          )
          .frames;
      for (final f in frames) {
        final known = int.parse(f.inlineVars['已写入']!);
        final list = f.scene.auxTables.single.rows.map((r) => r.last).toList();
        expect(list.take(known), expected.take(known).map((x) => '$x'));
        expect(list.skip(known).every((x) => x == '·'), isTrue);
        final left = f.scene.nodes.where(
          (n) =>
              n.id.startsWith('前缀-') && n.visualState == NodeVisualState.sorted,
        );
        final right = f.scene.nodes.where(
          (n) =>
              n.id.startsWith('后缀-') && n.visualState == NodeVisualState.active,
        );
        expect(left.map((n) => n.label), right.map((n) => n.label));
      }
      expect(frames.last.inlineVars['已写入'], '${pattern.length}');
      if (optimized && pattern == 'aaaab') {
        expect(frames.where((f) => f.phaseTitle == '跳过相同字符').length, 3);
      }
    }
  });
  test('rotations preserve cyclic order and run KMP on each window', () {
    for (final (text, pattern) in [
      ('ccaabcc', 'baa'),
      ('baa', 'baa'),
      ('aba', 'baa'),
      ('xxx', 'baa'),
      ('aaaaa', 'aaa'),
      ('', 'a'),
      ('', ''),
    ]) {
      final frames = module
          .generateTrace(
            MatchInput(mode: MatchMode.rotations, text: text, pattern: pattern),
          )
          .frames;
      expect(frames.first.scene.nodes.length, pattern.length);
      expect(
        frames[2].scene.nodes.map((n) => n.label).join(),
        pattern + pattern,
      );
      final rows = frames.last.scene.auxTables.single.rows;
      expect(rows.length, pattern.length);
      for (var i = 0; i < pattern.length; i++) {
        final word = pattern.substring(i) + pattern.substring(0, i);
        expect(rows[i], ['${i + 1}', word, '${text.indexOf(word) + 1}']);
      }
      expect(frames.first.scene.auxTables.single.rows, isEmpty);
    }
  });
}
