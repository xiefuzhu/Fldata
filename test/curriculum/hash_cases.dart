import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch7_search/hash_table.dart';
import 'package:fldata/models/trace_model.dart';

void hashCases() {
  const module = HashModule();
  HashInput data(String id) => module.validateInput(id).value!;
  List<TraceFrame> trace(HashInput input) => module.generateTrace(input).frames;
  test('表 7.4 与图 7.30 的逐键比较数、逐入口失败次数及链尾 NULL', () {
    final input = data('linear73'), frames = trace(input);
    final ht = HashStorage.fromScene(input, frames.last.scene);
    expect(
      [for (var i = 0; i < 16; i++) ht.cells[i]?.first],
      [null, 14, 1, 68, 27, 55, 19, 20, 84, 79, 23, 11, 10, null, null, null],
    );
    final stats = ht.analyze();
    expect(
      [stats.successSum, stats.success.length, stats.failureSum, stats.entries],
      [30, 12, 91, 13],
    );
    expect(stats.success.map((r) => r.$3), [
      1,
      2,
      1,
      4,
      3,
      1,
      1,
      3,
      9,
      1,
      1,
      3,
    ]);
    expect(List.generate(13, stats.failureAt), [
      1,
      13,
      12,
      11,
      10,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    final chain = data('chain72'), cf = trace(chain);
    final ch = HashStorage.fromScene(chain, cf.last.scene);
    expect(ch.cells[1], [14, 1, 27, 79]);
    final ca = ch.analyze();
    expect(
      [ca.successSum, ca.success.length, ca.failureSum, ca.entries],
      [21, 12, 25, 13],
    );
    expect(List.generate(13, ca.failureAt), [
      1,
      5,
      1,
      3,
      1,
      1,
      3,
      2,
      1,
      1,
      3,
      2,
      1,
    ]);
    final removed = trace(chain.change(operations: '-1 ?79 -14 -27 -79 ?1'));
    final found = removed.singleWhere(
      (f) => f.inlineVars['阶段'] == '结果' && f.inlineVars['操作'] == '?79',
    );
    expect(found.inlineVars['路径'], '14 → 27 → 79');
    expect(removed.last.inlineVars['路径'], 'NULL');
  });
  test('图 7.29 三种偏移各自复现；未覆盖的二次探测序列能停止', () {
    for (final (id, addr, path) in [
      ('linear38', '8', '5 → 6 → 7 → 8'),
      ('quadratic38', '4', '5 → 6 → 4'),
      ('random38', '3', '5 → 3'),
    ]) {
      final input = data(id), end = trace(input).last;
      expect(end.inlineVars['地址'], addr);
      expect(end.inlineVars['路径'], path);
      expect(end.inlineVars['结果'], '已插入 38');
    }
    // +1²,-1²,+2² in a four-slot table cannot reach offset 2.
    final few = trace(
      const HashInput(
        m: 4,
        p: 1,
        collision: HashCollision.quadratic,
        initial: [0, 1, 2],
        operations: '+3 ?3',
      ),
    );
    final stop = few.singleWhere(
      (f) => f.inlineVars['操作'] == '+3' && f.inlineVars['阶段'] == '结果',
    );
    expect(stop.inlineVars['结果'], '探测序列耗尽');
    expect(stop.inlineVars['路径'], '0 → 1 → 3 → 0');
    expect(few.last.inlineVars['探测次数'], '4');
    final input = data('random38').change(
      m: 17,
      p: 1,
      initial: List.generate(17, (i) => i),
      operations: '?99',
    );
    final a = trace(input).last, b = trace(input).last;
    expect(a.inlineVars['路径'], b.inlineVars['路径']);
    expect(a.inlineVars['路径']!.split(' → ').toSet(), hasLength(17));
  });
  test('墓碑之后仍找得到同义词，排除重复后才复用，满表也可回收', () {
    final input = data('tombstone'), frames = trace(input);
    TraceFrame end(String op) => frames.lastWhere(
      (f) => f.inlineVars['操作'] == op && f.inlineVars['阶段'] == '结果',
    );
    final deleted = HashStorage.fromScene(input, end('-6').scene);
    expect(deleted.cells[2], isEmpty);
    expect(deleted.analyze().failureAt(1), 4);
    expect(end('?11').inlineVars['路径'], '1 → 2 → 3');
    expect(end('+11').inlineVars['结果'], '重复键 11');
    expect(HashStorage.fromScene(input, end('+11').scene).cells[2], isEmpty);
    expect(end('+16').inlineVars['路径'], '1 → 2 → 3 → 4');
    expect(HashStorage.fromScene(input, end('+16').scene).cells[2], [16]);
    final full = trace(
      const HashInput(
        m: 3,
        p: 1,
        initial: [0, -2, 1],
        operations: '+2 --2 +2 ?1',
      ),
    );
    final statuses = full.where((f) => f.inlineVars['阶段'] == '结果').toList();
    expect(statuses[3].inlineVars['结果'], '表已满');
    expect(statuses[5].inlineVars['地址'], '1');
    expect(statuses.last.inlineVars['结果'], '命中 1');
  });
  test('表 7.2 平方取中、图 7.28 两种折叠、直接地址边界与十进制选位', () {
    final sq = data('square');
    expect(sq.initial.map((k) => sq.hash(k).home), [426, 252, 516, 372]);
    final fold = data('fold');
    expect(fold.hash(45387765213).home, 995);
    expect(fold.change(boundaryFold: true).hash(45387765213).home, 914);
    final direct = data('direct');
    expect(direct.hash(100).home, 0);
    expect(direct.hash(112).home, 12);
    expect(direct.hash(99).home, isNull);
    expect(
      trace(
        direct.change(initial: [], operations: '+113'),
      ).last.inlineVars['结果'],
      '超出直接定址范围',
    );
    expect(data('digits').hash(81346532).home, 46);
    expect(const HashInput().hash(-1).home, 12);
    expect(
      const HashInput(initial: [], operations: '').validate,
      returnsNormally,
    );
    expect(const HashInput(m: 3, p: 4).validate, throwsFormatException);
  });
}
