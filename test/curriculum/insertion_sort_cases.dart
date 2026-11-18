import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/insertion_sort.dart';
import 'package:fldata/curriculum/ch8_sort/sort_records.dart';
import 'package:fldata/models/trace_model.dart';

void insertionSortCases() {
  const module = InsertionModule();
  List<TraceFrame> trace(InsertionInput input) =>
      module.generateTrace(input).frames;
  String order(TraceFrame f) =>
      f.scene.nodes.skip(1).map((n) => n.label).join(' ');
  test('图 8.1 各趟、监视哨自身比较，以及三种输入下的 KCN/RMN', () {
    final frames = trace(const InsertionInput());
    expect(frames.where((f) => f.inlineVars['阶段'] == '整趟').map(order), [
      '38 49 65 97 76 13 27 49*',
      '38 49 65 97 76 13 27 49*',
      '38 49 65 97 76 13 27 49*',
      '38 49 65 76 97 13 27 49*',
      '13 38 49 65 76 97 27 49*',
      '13 27 38 49 65 76 97 49*',
      '13 27 38 49 49* 65 76 97',
    ]);
    expect(frames.any((f) => f.phaseTitle == '比较 r[0] 与 r[0]'), isTrue);
    expect(frames.last.scene.auxTables.last.rows, [
      ['直接插入', '22', '15', '10', '25'],
      ['折半插入', '16', '15', '14', '29'],
    ]);
    final sorted = trace(const InsertionInput(keys: [1, 2, 3, 4, 5])).last;
    expect(sorted.scene.auxTables.last.rows, [
      ['直接插入', '4', '0', '0', '0'],
      ['折半插入', '8', '0', '8', '8'],
    ]);
    final reverse = trace(const InsertionInput(keys: [5, 4, 3, 2, 1])).last;
    expect(reverse.scene.auxTables.last.rows, [
      ['直接插入', '14', '10', '8', '18'],
      ['折半插入', '6', '10', '8', '18'],
    ]);
    final bin = trace(const InsertionInput(method: InsertionMethod.binary));
    final equal = bin.firstWhere(
      (f) =>
          f.inlineVars['阶段'] == '比较' &&
          f.scene.nodes.first.label == '49*' &&
          f.scene.nodes[int.parse(f.inlineVars['mid']!)].label == '49',
    );
    final after = bin[equal.stepIndex + 1];
    expect(
      int.parse(after.inlineVars['low']!),
      int.parse(equal.inlineVars['mid']!) + 1,
    );
    expect(bin.last.inlineVars.containsKey('逆序帧'), false);
  });
  test('图 8.2 三趟带标记序列与跨位见证，r[0] 不参与希尔的 j>0 比较', () {
    final frames = trace(
      const InsertionInput(method: InsertionMethod.shell, keys: sortExample82),
    );
    expect(frames.where((f) => f.inlineVars['阶段'] == '整趟').map(order), [
      '13 27 49* 55 4 49 38 65 97 76',
      '13 4 49* 38 27 49 55 65 97 76',
      '4 13 27 38 49* 49 55 65 76 97',
    ]);
    expect(
      frames
          .where((f) => f.inlineVars['阶段'] == '分组')
          .map((f) => f.scene.edges.length),
      [5, 7, 9],
    );
    final end = frames.last;
    expect((end.metrics.comparisons, end.metrics.moves), (37, 34));
    expect(frames.any((f) => f.phaseTitle == '比较 r[0] 与 r[0]'), false);
    final keyframe = frames[int.parse(end.inlineVars['逆序帧']!)];
    expect(keyframe.inlineVars['跨位'], contains('49*'));
    expect(
      keyframe.scene.nodes[int.parse(keyframe.inlineVars['目标']!)].label,
      '49*',
    );
    expect(keyframe.isKeyMilestone, true);
  });
  test('负数、随机多重重复键、空表与自定义增量的最终顺序和稳定性', () {
    final rng = Random(803);
    final samples = <List<int>>[
      [],
      [-2],
      [7, 7, 7],
      sortExample81,
      [1, 0, -1, -2],
      for (var i = 0; i < 8; i++) List.generate(12, (_) => rng.nextInt(5) - 2),
    ];
    for (final input in samples) {
      for (final m in InsertionMethod.values) {
        final frames = trace(
              InsertionInput(keys: input, method: m, gaps: [4, 2, 1]),
            ),
            end = frames.last;
        final rows = end.scene.auxTables.first.rows.skip(1),
            ids = rows.map((r) => int.parse(r[2]) - 1).toList();
        expect(ids.toSet().length, input.length);
        expect(ids.map((id) => input[id]), [...input]..sort());
        final inverted = [
          for (var i = 1; i < ids.length; i++)
            if (input[ids[i - 1]] == input[ids[i]] && ids[i - 1] > ids[i]) i,
        ];
        if (m != InsertionMethod.shell) expect(inverted, isEmpty);
        expect(end.inlineVars.containsKey('逆序帧'), inverted.isNotEmpty);
        if (inverted.isNotEmpty) {
          expect(
            frames[int.parse(end.inlineVars['逆序帧']!)].inlineVars.containsKey(
              '跨位',
            ),
            true,
          );
        }
        expect(
          end.metrics.moves,
          frames.where((f) => f.inlineVars.containsKey('来源')).length,
        );
        expect(
          end.metrics.comparisons,
          frames.where((f) => f.inlineVars['阶段'] == '比较').length,
        );
      }
    }
    expect(InsertionInput.parse('[49，-3, 49*]', tagged: true), [49, -3, 49]);
    expect(
      const InsertionInput(
        method: InsertionMethod.shell,
        gaps: [3, 3, 1],
      ).validate,
      throwsFormatException,
    );
    expect(
      const InsertionInput(
        method: InsertionMethod.shell,
        gaps: [5, 2],
      ).validate,
      throwsFormatException,
    );
  });
}
