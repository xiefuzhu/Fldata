import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/selection_sort.dart';
import 'package:fldata/models/trace_model.dart';

void selectionSortCases() {
  const module = SelectionModule();
  List<TraceFrame> run(SelectionInput input) =>
      module.generateTrace(input).frames;
  String row(TraceFrame f) =>
      f.scene.auxTables.single.rows.skip(1).map((r) => r[1]).join(' ');
  test('例 8.5 的七趟及造成 49* 提前的第一次交换', () {
    final frames = run(
      module.presets.singleWhere((p) => p.id == 'simple').input,
    );
    expect(frames.where((f) => f.inlineVars['阶段'] == '整趟').map(row), [
      '13 38 65 97 49* 49 27 76',
      '13 27 65 97 49* 49 38 76',
      '13 27 38 97 49* 49 65 76',
      '13 27 38 49* 97 49 65 76',
      '13 27 38 49* 49 97 65 76',
      '13 27 38 49* 49 65 97 76',
      '13 27 38 49* 49 65 76 97',
    ]);
    final last = frames.last;
    expect((last.metrics.comparisons, last.metrics.moves), (28, 21));
    expect(
      frames[int.parse(last.inlineVars['逆序帧']!)].inlineVars,
      containsPair('目标', '6'),
    );
    final sorted = run(
      const SelectionInput(keys: [1, 2, 3], method: SelectionMethod.simple),
    ).last;
    expect((sorted.metrics.comparisons, sorted.metrics.moves), (3, 0));
  });
  test('图 8.8 保留原叶，只有被替换为 ∞ 的叶到根重赛', () {
    final frames = run(
      module.presets.singleWhere((p) => p.id == 'tournament').input,
    );
    final outputs = frames.where((f) => f.inlineVars['阶段'] == '输出').toList();
    expect(
      outputs.map(
        (f) => f.scene.nodes.firstWhere((n) => n.id == 'tree1').label,
      ),
      ['13', '27', '38', '49', '49*', '65', '76', '97'],
    );
    final rounds = frames.sublist(
      outputs[0].stepIndex + 1,
      outputs[1].stepIndex,
    );
    expect(rounds.map((f) => f.inlineVars['比赛结点']), ['13', '6', '3', '1']);
    expect(
      rounds.first.scene.nodes.firstWhere((n) => n.id == 'tree13').label,
      '∞',
    );
    expect(
      (frames.last.metrics.peakAuxiliarySpace, frames.last.metrics.moves),
      (15, 8),
    );
  });
  test('图 8.11、8.12 验证建堆顺序、每次缩堆与两种表示逐槽同步', () {
    final frames = run(const SelectionInput());
    expect(
      frames
          .where((f) => f.inlineVars['阶段'] == '建堆入口')
          .map((f) => f.inlineVars['s']),
      ['4', '3', '2', '1'],
    );
    expect(
      row(frames.singleWhere((f) => f.inlineVars['阶段'] == '建堆完成')),
      '97 76 65 49* 49 13 27 38',
    );
    expect(frames.where((f) => f.inlineVars['阶段'] == '恢复堆').map(row), [
      '76 49* 65 38 49 13 27 97',
      '65 49* 27 38 49 13 76 97',
      '49* 49 27 38 13 65 76 97',
      '49 38 27 13 49* 65 76 97',
      '38 13 27 49 49* 65 76 97',
      '27 13 38 49 49* 65 76 97',
      '13 27 38 49 49* 65 76 97',
    ]);
    for (final f in frames) {
      final size = int.parse(f.inlineVars['堆规模']!);
      final tree = f.scene.nodes.where((n) => n.id.startsWith('tree')).toList();
      expect(tree, hasLength(size));
      for (var i = 1; i <= size; i++) {
        expect(tree[i - 1].label, f.scene.nodes[i].label);
        expect(tree[i - 1].y, lessThan(f.scene.nodes[i].y));
      }
      final s = int.tryParse(f.inlineVars['s'] ?? '');
      if (s != null) {
        expect(
          f.scene.edges
              .where((e) => e.visualState == NodeVisualState.comparing)
              .map((e) => e.toNodeId),
          [
            for (final j in [2 * s, 2 * s + 1])
              if (j <= size) 'tree$j',
          ],
        );
      }
    }
    expect(
      (frames.last.metrics.comparisons, frames.last.metrics.moves),
      (27, 55),
    );
    expect(frames.last.inlineVars['逆序帧'], isNull);
  });
  test('非满树、逆序、空表及重复键的记录身份和跨位帧', () {
    final random = Random(86);
    for (final keys in <List<int>>[
      [],
      [7],
      [2, 2],
      [2, 2, 1],
      [5, 4, 3, 2, 1],
      for (var n = 2; n <= 9; n++)
        for (var i = 0; i < 4; i++)
          List.generate(n, (_) => random.nextInt(5) - 2),
    ]) {
      for (final method in SelectionMethod.values) {
        final frames = run(SelectionInput(keys: keys, method: method));
        final origins = frames.last.scene.auxTables.single.rows
            .skip(1)
            .map((r) => int.parse(r[2]) - 1)
            .toList();
        expect(origins.toSet().length, keys.length);
        expect(origins.map((i) => keys[i]), [...keys]..sort());
        final inverted = origins.indexed.any(
          (e) =>
              e.$1 > 0 &&
              keys[origins[e.$1 - 1]] == keys[e.$2] &&
              origins[e.$1 - 1] > e.$2,
        );
        if (method == SelectionMethod.tournament) expect(inverted, false);
        final witness = frames.last.inlineVars['逆序帧'];
        expect(witness != null, inverted, reason: '$method $keys → $origins');
        if (witness != null) {
          expect(frames[int.parse(witness)].inlineVars['跨位'], isNotEmpty);
        }
      }
    }
  });
}
