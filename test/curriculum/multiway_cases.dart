import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch7_search/btree.dart';
import 'package:fldata/models/trace_model.dart';

void multiwayCases() {
  const module = MultiwayModule();
  List<TraceFrame> preset(String id) =>
      module.generateTrace(module.validateInput(id).value!).frames;
  List<int> keys(String s) =>
      s.isEmpty ? [] : s.split(' ').map(int.parse).toList();
  List<String> pages(TraceFrame f) => [
    for (final row in f.scene.auxTables.single.rows) row[3],
  ];
  test('图 7.22 的返回三元组、图 7.25 级联分裂和图 7.26 借位合并', () {
    final search = preset('search'),
        initial = search.firstWhere((f) => f.inlineVars['阶段'] == '操作结束');
    expect(pages(initial), [
      '35',
      '18',
      '43 78',
      '11',
      '27',
      '39',
      '47 53 64',
      '99',
    ]);
    final returned = search.where((f) => f.inlineVars['阶段'] == '返回').toList();
    expect(returned.first.explanation, contains('i=1, tag=1'));
    expect(returned.last.explanation, contains('i=0, tag=0'));
    final ins = preset('insert');
    expect(pages(ins.first), [
      '45',
      '24',
      '53 90',
      '3 12',
      '37',
      '50',
      '61 70',
      '100',
    ]);
    final splits = ins.where(
      (f) => f.inlineVars['阶段'] == '分裂' && f.inlineVars['操作'] == '+7',
    );
    expect(splits.map((f) => f.inlineVars['键']), ['7', '24', '45']);
    expect(pages(ins.last), [
      '45',
      '24',
      '70',
      '7',
      '30',
      '53',
      '90',
      '3',
      '12',
      '26',
      '37',
      '50',
      '61',
      '85',
      '100',
    ]);
    final del = preset('delete');
    expect(
      del.where((f) => f.inlineVars['阶段'] == '借位').single.explanation,
      contains('父键 53 下沉，兄弟键 61 上升'),
    );
    final done = del.where((f) => f.inlineVars['阶段'] == '操作结束').toList();
    expect(pages(done[2]), ['45', '24', '90', '3', '37', '61 70', '100']);
    expect(pages(done[3]), ['45 90', '3 24', '61 70', '100']);
    expect(del.where((f) => f.inlineVars['阶段'] == '降高'), hasLength(1));
  });
  test('3、4、5 阶逐次插删维护占用率、父指针、键区间与等叶深', () {
    final branches = <String>{};
    for (final m in [3, 4, 5]) {
      final rng = Random(726 + m),
          seq = List.generate(32, (i) => i - 16)..shuffle(rng);
      final deletes = [...seq]..shuffle(rng);
      final tokens = [
        for (final k in seq) '+$k',
        '+0',
        '?0',
        '-99',
        for (final k in deletes) '-$k',
      ];
      final frames = module
          .generateTrace(
            MultiwayInput(order: m, initial: [], operations: tokens.join(' ')),
          )
          .frames;
      final expected = <int>{};
      for (final f in frames) {
        if (f.inlineVars['阶段'] == '借位') branches.add(f.phaseTitle);
        if (f.inlineVars['阶段'] == '后继') branches.add('后继');
        if (f.inlineVars['阶段'] != '操作结束') continue;
        final op = f.inlineVars['操作']!, k = int.parse(op.substring(1));
        if (op.startsWith('+')) expected.add(k);
        if (op.startsWith('-')) expected.remove(k);
        final rows = {for (final r in f.scene.auxTables.single.rows) r[0]: r},
            seen = <String>{},
            all = <int>[],
            depths = <int>{};
        void walk(String id, String parent, int depth, int? lower, int? upper) {
          expect(seen.add(id), isTrue);
          final row = rows[id]!,
              ks = keys(row[3]),
              children = row[4].isEmpty ? <String>[] : row[4].split(' ');
          expect(row[1], parent);
          expect(
            ks.length,
            inInclusiveRange(parent == 'NULL' ? 1 : (m + 1) ~/ 2 - 1, m - 1),
          );
          expect(ks, [...ks]..sort());
          for (final v in ks) {
            expect(lower == null || v > lower, isTrue);
            expect(upper == null || v < upper, isTrue);
          }
          all.addAll(ks);
          if (children.isEmpty) {
            depths.add(depth);
            return;
          }
          expect(children, hasLength(ks.length + 1));
          for (var i = 0; i < children.length; i++) {
            walk(
              children[i],
              id,
              depth + 1,
              i == 0 ? lower : ks[i - 1],
              i == ks.length ? upper : ks[i],
            );
          }
        }

        if (expected.isEmpty) {
          expect(f.inlineVars['根'], 'NULL');
        } else {
          walk(f.inlineVars['根']!, 'NULL', 1, null, null);
          expect(depths, hasLength(1));
        }
        expect(seen, rows.keys.toSet());
        expect(all..sort(), expected.toList()..sort());
      }
    }
    expect(branches, containsAll(['向左兄弟借位', '向右兄弟借位', '后继']));
  });
  test('图 7.27 的最大键索引、真实记录指针及跨页闭区间', () {
    final fig = preset('range');
    expect(pages(fig.first), [
      '59 97',
      '15 44 59',
      '72 97',
      '10 15',
      '21 37 44',
      '51 59',
      '63 72',
      '85 91 97',
    ]);
    expect(fig.last.inlineVars['结果'], '37 44 51 59 63 72');
    expect(fig.where((f) => f.inlineVars['阶段'] == '叶链'), hasLength(3));
    for (final m in [3, 4, 5]) {
      for (final bounds in [
        (-9, -1),
        (15, 15),
        (16, 20),
        (0, 120),
        (98, 100),
      ]) {
        final input = module.validateInput('range').value!;
        final frames = module
            .generateTrace(
              MultiwayInput(
                order: m,
                plus: true,
                initial: [...input.initial, 59],
                low: bounds.$1,
                high: bounds.$2,
              ),
            )
            .frames;
        final rows = {
              for (final r in frames.first.scene.auxTables.single.rows) r[0]: r,
            },
            leaves = <List<String>>[];
        void verify(String id) {
          final r = rows[id]!, ks = keys(r[3]);
          if (r[2] == '记录') {
            expect(r[6].split(' '), ks.map((k) => 'R($k)'));
            leaves.add(r);
            return;
          }
          expect(r[6], isEmpty);
          final children = r[4].split(' ');
          expect(ks, children.map((c) => keys(rows[c]![3]).last));
          for (final c in children) {
            verify(c);
          }
        }

        verify(frames.first.inlineVars['根']!);
        for (var i = 0; i < leaves.length; i++) {
          expect(
            leaves[i][5],
            i + 1 < leaves.length ? leaves[i + 1][0] : 'NULL',
          );
        }
        final selected =
            input.initial
                .where((k) => k >= bounds.$1 && k <= bounds.$2)
                .toList()
              ..sort();
        expect(keys(frames.last.inlineVars['记录']!), selected);
        final visited = frames
            .where((f) => f.inlineVars['阶段'] == '叶页')
            .map((f) => f.inlineVars['页'])
            .toList();
        for (var i = 1; i < visited.length; i++) {
          expect(rows[visited[i - 1]]![5], visited[i]);
        }
      }
    }
    expect(
      module
          .generateTrace(const MultiwayInput(initial: [], plus: true))
          .frames
          .last
          .inlineVars['结果'],
      '∅',
    );
  });
}
