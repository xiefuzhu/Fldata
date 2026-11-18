import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/merge_radix.dart';
import 'package:fldata/curriculum/ch8_sort/sort_race.dart';
import 'package:fldata/models/trace_model.dart';

void mergeRadixCases() {
  const module = MergeRadixModule();
  test('例 8.8 的递归分段、辅助数组、余段复制和等键左优先', () {
    final frames = module.generateTrace(const MergeRadixInput()).frames,
        last = frames.last;
    expect(
      frames
          .where((f) => f.inlineVars['阶段'] == '开始归并')
          .map((f) => f.callStack.last.id),
      ['m1:2', 'm3:4', 'm1:4', 'm5:6', 'm5:7', 'm1:7'],
    );
    expect(
      frames
          .where((f) => f.callStack.length == 1 && f.inlineVars['阶段'] == '写入')
          .map((f) => f.inlineVars['目标表']),
      everyElement('r'),
    );
    expect(last.scene.auxTables.single.rows.map((r) => r[1]), [
      '13',
      '27',
      '38',
      '49',
      '65',
      '76',
      '97',
    ]);
    expect(
      (last.metrics.comparisons, last.metrics.moves, last.metrics.maxCallDepth),
      (13, 27, 4),
    );
    final same = module
        .generateTrace(const MergeRadixInput(keys: [2, 1, 2, 1, 2]))
        .frames
        .last;
    expect(same.scene.auxTables.single.rows.map((r) => r[2]), [
      '2',
      '4',
      '1',
      '3',
      '5',
    ]);
  });
  test('图 8.15 三趟次序、稳定入桶、首尾游标和原槽不动', () {
    final frames = module
        .generateTrace(
          const MergeRadixInput(
            method: MergeRadixMethod.radix,
            keys: radixFigure815,
          ),
        )
        .frames;
    List<String> order(TraceFrame f) => f.inlineVars['链序']!
        .split(',')
        .map((s) => f.scene.nodes[int.parse(s)].label)
        .toList();
    final passes = frames.where((f) => f.inlineVars['阶段'] == '整趟').toList();
    expect(passes.map((f) => order(f).join(' ')), [
      '930 063 083 184 505 278 008 109 589 269',
      '505 008 109 930 063 269 278 083 184 589',
      '008 063 083 109 184 269 278 505 589 930',
    ]);
    final distributed = frames.lastWhere(
      (f) => f.inlineVars['阶段'] == '分配' && f.inlineVars['位次'] == '1',
    );
    expect(distributed.scene.auxTables.last.rows[9], [
      '9',
      '2',
      '8',
      '109 589 269',
    ]);
    for (final f in passes) {
      final rows = f.scene.auxTables.first.rows;
      var p = int.parse(rows[0][2]);
      final result = <String>[];
      while (p != 0 && result.length <= 10) {
        result.add(rows[p][1]);
        p = int.parse(rows[p][2]);
      }
      expect(result, order(f));
      expect(p, 0);
      expect(rows.skip(1).map((r) => int.parse(r[1])), radixFigure815);
    }
    expect(
      (frames.last.metrics.comparisons, frames.last.metrics.moves),
      (0, 0),
    );
    expect(frames.last.metrics.writes, greaterThan(100));
    final duplicate = module
        .generateTrace(
          const MergeRadixInput(
            method: MergeRadixMethod.radix,
            keys: [10, 0, 10, 0],
          ),
        )
        .frames
        .last;
    expect(duplicate.inlineVars['链序'], '2,4,1,3');
    for (final method in MergeRadixMethod.values) {
      for (final keys in <List<int>>[
        [],
        [0],
      ]) {
        final f = module
            .generateTrace(MergeRadixInput(method: method, keys: keys))
            .frames
            .last;
        expect(f.inlineVars['阶段'], '完成');
        expect(f.metrics.comparisons, 0);
      }
    }
    expect(
      () => module.generateTrace(
        const MergeRadixInput(method: MergeRadixMethod.radix, keys: [-1]),
      ),
      throwsFormatException,
    );
  });
  test('十算法用同一输入竞速，完成拍与各自实际记录的计数一致', () {
    const keys = [9, 5, 7, 5, 1, 2, 0, 5];
    for (final group in [
      [
        RaceAlgorithm.direct,
        RaceAlgorithm.binary,
        RaceAlgorithm.shell,
        RaceAlgorithm.tournament,
      ],
      [
        RaceAlgorithm.quick,
        RaceAlgorithm.heap,
        RaceAlgorithm.simple,
        RaceAlgorithm.bubble,
      ],
      [RaceAlgorithm.merge, RaceAlgorithm.radix],
    ]) {
      final lanes = buildRace(RaceRequest(keys, group));
      for (final lane in lanes) {
        final first = lane.at(0),
            last = lane.beats.last,
            f = lane.algorithm.trace(keys).frames.last;
        expect(first.labels, ['9', '5', '7', '5*', '1', '2', '0', '5*3']);
        expect(last.labels.map((s) => int.parse(s.split('*').first)), [
          0,
          1,
          2,
          5,
          5,
          5,
          7,
          9,
        ]);
        expect(
          last.tick,
          f.metrics.comparisons +
              f.metrics.moves +
              (lane.algorithm == RaceAlgorithm.radix ? f.metrics.writes : 0),
        );
        expect(
          (last.comparisons, last.moves),
          (f.metrics.comparisons, f.metrics.moves),
        );
        final equalOrder = last.labels
            .where((s) => s.startsWith('5'))
            .join(',');
        expect(lane.inverted, equalOrder != '5,5*,5*3');
        for (var i = 1; i < lane.beats.length; i++) {
          expect(lane.at(lane.beats[i].tick - 1), same(lane.beats[i - 1]));
        }
      }
    }
    expect(
      RaceSample.ascending.generate(10, 2),
      [...RaceSample.random.generate(10, 2)]..sort(),
    );
    expect(
      RaceSample.duplicates.generate(32, 2).toSet().length,
      lessThanOrEqualTo(4),
    );
    expect(
      () => buildRace(const RaceRequest(keys, [RaceAlgorithm.quick])),
      throwsArgumentError,
    );
  });
}
