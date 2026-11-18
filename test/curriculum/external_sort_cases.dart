import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/external_sort.dart';
import 'package:fldata/models/trace_model.dart';

void externalSortCases() {
  const module = ExternalModule();
  List<TraceFrame> run(ExternalInput input) =>
      module.generateTrace(input).frames;
  List<String> losers(TraceFrame f) =>
      f.scene.auxTables.first.rows.map((r) => r[1]).toList();
  List<List<int>> output(TraceFrame f) => [
    for (final row in f.scene.auxTables.last.rows)
      row[2].split(' ').map(int.parse).toList(),
  ];
  test('图 8.18 对照两棵败者树，读写与逐层重赛一致', () {
    final frames = run(const ExternalInput.merge());
    expect(
      frames.first.scene.nodes.firstWhere((n) => n.id == 'buf3').label,
      '待读',
    );
    final built = frames.indexWhere((f) => f.inlineVars['阶段'] == '建树完成');
    expect(losers(frames[built]), ['3', '1', '0', '2', '4']);
    final second = frames
        .skip(built + 1)
        .takeWhile((f) => f.inlineVars['阶段'] != '冠军')
        .toList();
    expect(
      second
          .where((f) => f.inlineVars['阶段'] == '比赛')
          .map((f) => f.inlineVars['t']),
      ['4', '2', '1'],
    );
    expect(losers(frames[built + 1 + second.length]), [
      '1',
      '0',
      '4',
      '2',
      '3',
    ]);
    final result = frames.last;
    expect(output(result).single, [
      6,
      9,
      10,
      12,
      15,
      15,
      16,
      18,
      20,
      20,
      22,
      25,
      37,
      40,
      48,
    ]);
    expect((result.metrics.reads, result.metrics.writes), (15, 15));
    final extremes = run(
      const ExternalInput.merge([
        [],
        [-9223372036854775808, 9223372036854775807],
        [0, 0],
        [],
      ]),
    ).last;
    expect(output(extremes).single, [
      -9223372036854775808,
      0,
      0,
      9223372036854775807,
    ]);
    expect(output(run(const ExternalInput.merge([[], []])).last), isEmpty);
    expect(
      () => ExternalInput.parse(ExternalMethod.merge, '3 2; 4', ''),
      throwsFormatException,
    );
  });
  test('表 8.1 逐槽补读与冻结，保留三条完整输出顺串', () {
    final frames = run(const ExternalInput.replacement()),
        built = frames.firstWhere((f) => f.inlineVars['阶段'] == '建树完成');
    expect(losers(built).first, '0');
    expect(built.scene.auxTables[1].rows.map((r) => r[1]), [
      '29',
      '38',
      '46',
      '39',
      '49',
      '51',
    ]);
    final frozen = frames.firstWhere((f) => f.inlineVars['阶段'] == '冻结');
    expect(frozen.scene.auxTables[1].rows[0], ['0', '14', '冻结 · RUN 2']);
    expect(frozen.inlineVars['MINIMAX'], '29');
    final last = frames.last;
    expect(output(last), [
      [29, 38, 39, 46, 49, 51, 61],
      [1, 3, 14, 15, 27, 30, 48, 52, 63, 89],
      [4, 13, 24, 33, 46, 58, 76],
    ]);
    expect((last.metrics.reads, last.metrics.writes), (24, 24));
    expect(output(run(const ExternalInput.replacement([2, 2, 2], 1)).last), [
      [2, 2, 2],
    ]);
    expect(output(run(const ExternalInput.replacement([3, 2, 1], 1)).last), [
      [3],
      [2],
      [1],
    ]);
    expect(output(run(const ExternalInput.replacement([], 6)).last), isEmpty);
    expect(sampledRunLength(6), inInclusiveRange(11.0, 13.0));
  });
  test('最佳归并树以叶深复算 WPL，覆盖图 8.22、8.23 和六段四路', () {
    for (final (input, u, io) in [
      (const ExternalInput.optimal(), 0, 446),
      (const ExternalInput.optimal([9, 12, 18, 3, 17, 2, 6, 24], 3), 1, 326),
      (const ExternalInput.optimal([2, 3, 6, 9, 12, 17], 4), 1, 120),
      (const ExternalInput.optimal([2, 4], 5), 3, 12),
      (const ExternalInput.optimal([3], 4), 0, 0),
      (const ExternalInput.optimal([], 3), 0, 0),
    ]) {
      final frames = run(input), last = frames.last;
      expect(last.inlineVars['读写次数'], '$io');
      expect(
        frames.where((f) => f.inlineVars['阶段'] == '补虚段'),
        hasLength(u > 0 ? 1 : 0),
      );
      expect(
        last.scene.nodes.where((n) => n.groupTag == 'virtual'),
        hasLength(u),
      );
      final parents = {
        for (final e in last.scene.edges) e.toNodeId: e.fromNodeId,
      };
      var wpl = 0;
      for (var i = 0; i < input.keys.length; i++) {
        var depth = 0, id = 'seg$i';
        while (parents.containsKey(id)) {
          depth++;
          id = parents[id]!;
        }
        wpl += input.keys[i] * depth;
      }
      expect(wpl * 2, io);
      for (final parent in parents.values.toSet()) {
        expect(parents.values.where((v) => v == parent).length, input.width);
      }
    }
    expect(
      run(
        const ExternalInput.optimal([9223372036854775807, 1], 2),
      ).last.inlineVars['读写次数'],
      '18446744073709551616',
    );
  });
  test('多种工作区容量的输出覆盖全部输入，各段非降序，顺串可直接归并', () {
    final random = Random(818);
    for (final w in [1, 3, 5, 6, 9]) {
      final keys = List.generate(27, (_) => random.nextInt(13) - 6);
      final runs = output(run(ExternalInput.replacement(keys, w)).last);
      for (final r in runs) {
        expect(r, [...r]..sort());
      }
      expect(
        output(
          run(
            ExternalInput.merge(runs.length == 1 ? [...runs, []] : runs),
          ).last,
        ).single,
        [...keys]..sort(),
      );
    }
  });
}
