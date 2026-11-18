import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/exchange_sort.dart';
import 'package:fldata/models/trace_model.dart';

void exchangeSortCases() {
  List<TraceFrame> run(ExchangeInput input) =>
      const ExchangeModule().generateTrace(input).frames;
  String row(TraceFrame f) =>
      f.scene.nodes.skip(1).map((n) => n.label).join(' ');
  test('图 8.3 六趟冒泡、三次赋值与 flag 开关', () {
    final frames = run(const ExchangeInput(method: ExchangeMethod.bubble));
    expect(frames.where((f) => f.inlineVars['阶段'] == '整趟').map(row), [
      '38 49 65 76 13 27 49* 97',
      '38 49 65 13 27 49* 76 97',
      '38 49 13 27 49* 65 76 97',
      '38 13 27 49 49* 65 76 97',
      '13 27 38 49 49* 65 76 97',
      '13 27 38 49 49* 65 76 97',
    ]);
    expect(
      (frames.last.metrics.comparisons, frames.last.metrics.moves),
      (27, 45),
    );
    expect(frames.last.inlineVars['逆序帧'], isNull);
    for (final early in [true, false]) {
      final f = run(
        ExchangeInput(
          keys: [1, 2, 3, 4, 5],
          method: ExchangeMethod.bubble,
          earlyStop: early,
        ),
      ).last;
      expect(
        (f.metrics.comparisons, f.metrics.moves, f.inlineVars['趟']),
        (early ? 4 : 10, 0, early ? '1' : '4'),
      );
    }
  });
  test('图 8.4、8.5 挖坑、同槽赋值、枢轴落位及栈深', () {
    final frames = run(const ExchangeInput());
    expect(
      frames
          .takeWhile((f) => f.inlineVars['阶段'] != '枢轴归位')
          .where((f) => f.inlineVars['阶段'] == '填坑')
          .map((f) => (f.inlineVars['来源'], f.inlineVars['目标'])),
      [('7', '1'), ('3', '7'), ('6', '3'), ('4', '6')],
    );
    expect(
      frames
          .where((f) => f.inlineVars['阶段'] == '枢轴归位')
          .map(
            (f) => (
              f.callStack.last.id,
              f.inlineVars['目标'],
              f.callStack.last.locals['pivot'],
            ),
          ),
      [
        ('q1:8', '4', '49'),
        ('q1:3', '2', '27'),
        ('q5:8', '7', '76'),
        ('q5:6', '5', '49*'),
      ],
    );
    final last = frames.last;
    expect(row(last), '13 27 38 49 49* 65 76 97');
    expect(frames.where((f) => f.inlineVars['阶段'] == '同槽赋值'), hasLength(7));
    expect(
      (last.metrics.comparisons, last.metrics.moves, last.metrics.maxCallDepth),
      (22, 24, 4),
    );
    expect(last.callStack, isEmpty);
    final balanced = run(
      const ExchangeInput(keys: [4, 1, 3, 2, 6, 5, 7]),
    ).last.metrics;
    final chain = run(
      const ExchangeInput(keys: [1, 2, 3, 4, 5, 6, 7]),
    ).last.metrics;
    expect((balanced.maxCallDepth, chain.maxCallDepth), (3, 7));
  });
  test('空表、单项和重复键按原始位序核对稳定性回跳', () {
    final random = Random(85);
    for (final keys in <List<int>>[
      [],
      [3],
      [2, 2, 1],
      for (var n = 2; n < 9; n++)
        for (var trial = 0; trial < 8; trial++)
          List.generate(n, (_) => random.nextInt(4) - 1),
    ]) {
      final f = run(ExchangeInput(keys: keys));
      final rows = f.last.scene.auxTables.single.rows.skip(1).toList();
      final origins = rows.map((row) => int.parse(row[2]) - 1).toList();
      expect(origins.toSet().length, keys.length);
      expect(origins.map((i) => keys[i]), [...keys]..sort());
      final inverted = List.generate(origins.length, (i) => i).any(
        (i) =>
            i > 0 &&
            keys[origins[i - 1]] == keys[origins[i]] &&
            origins[i - 1] > origins[i],
      );
      final witness = f.last.inlineVars['逆序帧'];
      expect(witness != null, inverted, reason: '$keys → $origins');
      if (witness != null) {
        final movement = f[int.parse(witness)];
        expect(movement.inlineVars['阶段'], '填坑');
        expect(movement.inlineVars['跨位'], isNotEmpty);
      }
    }
  });
}
