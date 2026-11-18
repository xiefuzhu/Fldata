import 'package:fldata/curriculum/ch7_search/bst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch7_search/static_search.dart';
import 'package:fldata/models/trace_model.dart';

import 'multiway_cases.dart';
import 'ch7_ch8_quiz_cases.dart';
import 'hash_cases.dart';
import 'insertion_sort_cases.dart';
import 'exchange_sort_cases.dart';
import 'selection_sort_cases.dart';
import 'merge_radix_cases.dart';
import 'external_sort_cases.dart';

void main() {
  ch7Ch8QuizCases();
  multiwayCases();
  hashCases();
  insertionSortCases();
  exchangeSortCases();
  selectionSortCases();
  mergeRadixCases();
  externalSortCases();
  const module = StaticSearchModule();
  test('7.1 / 7.2 从尾部查找，区分边界判断、哨兵写入和关键字比较', () {
    for (final m in [SearchMethod.sequential, SearchMethod.sentinel]) {
      for (final (a, key, index) in <(List<int>, int, int)>[
        ([], 8, 0),
        ([8], 8, 1),
        ([8, 1, 8, 2], 8, 3),
        ([1, 2, 3], 8, 0),
      ]) {
        final frames = module
            .generateTrace(SearchInput(method: m, groups: [a], key: key))
            .frames;
        final f = frames.last,
            steps = f.metrics.statementCounts,
            s = m == SearchMethod.sentinel;
        final decrements = a.length - index;
        expect(f.inlineVars['返回'], '$index');
        expect(f.inlineVars['i'], '$index');
        expect(steps['i 减 1'] ?? 0, decrements);
        expect(steps['边界判断'] ?? 0, s ? 0 : decrements + 1);
        expect(steps['关键字比较'] ?? 0, decrements + (index != 0 || s ? 1 : 0));
        expect(steps['写入监视哨'] ?? 0, s ? 1 : 0);
        expect(frames.first.scene.auxTables.first.rows.first[1], '—');
        expect(f.scene.auxTables.first.rows.first[1], s ? '$key' : '—');
        final freq = f.scene.auxTables.last.rows;
        expect(freq[0].skip(1), ['${decrements + 1}', '0']);
        expect(freq[1].skip(1), [
          '${decrements + (index != 0 ? 1 : 0)}',
          '${decrements + 1}',
        ]);
      }
    }
  });

  test('例 7.1 同步数组边界、判定树路径和图 7.3 失败间隙', () {
    for (final (key, indices, bounds, result) in [
      (27, [6, 3, 4], [(1, 11), (1, 5), (4, 5)], 4),
      (65, [6, 9, 10], [(1, 11), (7, 11), (10, 11)], 0),
    ]) {
      final frames = module.generateTrace(SearchInput(key: key)).frames;
      final probes = frames
          .where((f) => f.phaseTitle.startsWith('比较 R'))
          .toList();
      expect(probes.map((f) => int.parse(f.inlineVars['mid']!)), indices);
      for (final (i, f) in probes.indexed) {
        expect((
          int.parse(f.inlineVars['low']!),
          int.parse(f.inlineVars['high']!),
        ), bounds[i]);
        final rows = f.scene.auxTables.first.rows;
        expect(rows.where((r) => r[3] == '比较').single.first, '${indices[i]}');
        expect(
          f.scene.nodes
              .singleWhere((n) => n.visualState == NodeVisualState.active)
              .id,
          'mid${indices[i]}',
        );
      }
      final f = frames.last;
      expect(f.inlineVars['返回'], '$result');
      expect(
        f.scene.nodes.where((n) => n.shape == NodeShape.circle).length,
        11,
      );
      expect(f.scene.nodes.where((n) => n.id.startsWith('gap')).length, 12);
      expect(f.inlineVars['判定结点'], key == 27 ? 'mid4' : 'gap10');
      expect(f.metrics.comparisons, 3);
      final rows = f.scene.auxTables.last.rows;
      expect(rows[0][1], contains('33/11'));
      expect(rows[1][1], contains('44/12'));
      expect(
        f.scene.edges
            .where((e) => e.visualState == NodeVisualState.active)
            .length,
        key == 27 ? 2 : 3,
      );
    }
  });

  test('折半树按下中位切分，所有成功和失败的实际比较总和与 ASL 相符', () {
    for (final n in [0, 1, 2, 4, 11]) {
      final a = [for (var i = 1; i <= n; i++) 2 * i];
      TraceFrame lookup(int key) =>
          module.generateTrace(SearchInput(groups: [a], key: key)).frames.last;
      int success = 0, failed = 0;
      for (var i = 0; i < n; i++) {
        final f = lookup(a[i]);
        expect(f.inlineVars['返回'], '${i + 1}');
        success += f.metrics.comparisons;
      }
      for (var i = 0; i <= n; i++) {
        final f = lookup(2 * i + 1);
        expect(f.inlineVars['返回'], '0');
        expect(f.inlineVars['判定结点'], 'gap${i + 1}');
        failed += f.metrics.comparisons;
      }
      final first = module.generateTrace(SearchInput(groups: [a])).frames.first;
      final asl = first.scene.auxTables.last.rows;
      expect(asl[0][1], contains(n == 0 ? '无成功记录' : '$success/$n'));
      expect(asl[1][1], contains('$failed/${n + 1}'));
      if (n > 0) {
        final root = first.scene.nodes.singleWhere(
          (v) => !first.scene.edges.any((e) => e.toNodeId == v.id),
        );
        expect(root.id, 'mid${(1 + n) ~/ 2}');
      }
    }
  });
  test('图 7.4 的两个索引策略与块内无序扫描', () {
    for (final binary in [false, true]) {
      for (final (key, answer, block, checks) in [
        (38, 10, 2, 4),
        (29, 0, 2, 6),
        (22, 1, 1, 1),
        (86, 17, 3, 5),
        (99, 0, 0, 0),
      ]) {
        final f = module
            .generateTrace(
              SearchInput(
                groups: textbookSearchBlocks,
                method: SearchMethod.block,
                binaryIndex: binary,
                key: key,
              ),
            )
            .frames
            .last;
        expect(f.inlineVars['返回'], '$answer');
        expect(f.inlineVars['选定块'], block == 0 ? null : '$block');
        expect(f.inlineVars['块内比较'], '$checks');
        expect(f.scene.auxTables.last.rows, [
          ['1', '22', '1'],
          ['2', '48', '7'],
          ['3', '86', '13'],
        ]);
        expect(
          f.metrics.comparisons,
          int.parse(f.inlineVars['索引比较']!) + checks,
        );
      }
    }
    final empty = SearchInput.parse('', '-4', SearchMethod.block, true).value!;
    expect(module.generateTrace(empty).frames.last.inlineVars['返回'], '0');
    expect(
      SearchInput.parse('3 1 | 2 9', '2', SearchMethod.block, true).isValid,
      false,
    );
    expect(
      SearchInput.parse('-3,-5｜0，2', '-5', SearchMethod.block, false).isValid,
      true,
    );
  });

  test('重复关键字首个相等中点与可达间隙的平均比较数', () {
    const a = [2, 2, 2, 6];
    TraceFrame run(int key) =>
        module.generateTrace(SearchInput(groups: [a], key: key)).frames.last;
    expect(run(2).inlineVars['返回'], '2');
    expect(run(6).inlineVars['返回'], '4');
    final rows = run(5).scene.auxTables.last.rows;
    final success = [
      2,
      6,
    ].map((key) => run(key).metrics.comparisons).reduce((a, b) => a + b);
    final failure = [
      1,
      4,
      7,
    ].map((key) => run(key).metrics.comparisons).reduce((a, b) => a + b);
    expect(rows.first[1], contains('$success/2'));
    expect(rows.last[1], contains('$failure/3'));
    expect(
      SearchInput.parse('4 2', '2', SearchMethod.binary, false).isValid,
      false,
    );
  });

  group('AVL 平衡与旋转', () {
    const bst = BstModule();
    List<TraceFrame> preset(String id) =>
        bst.generateTrace(bst.validateInput(id).value!).frames;
    test('教材四种旋转，逐帧从孩子指针重算 BF、中序和树高', () {
      for (final (id, type, rootKey, pivot, direction, transfer) in [
        ('avl-ll', 'LL', 25, 31, 2, 28),
        ('avl-rr', 'RR', 47, 31, 3, 40),
        ('avl-lr', 'LR', 28, 25, 3, 26),
        ('avl-rl', 'RL', 40, 47, 2, 43),
      ]) {
        final frames = preset(id);
        final locked = frames.singleWhere((f) => f.inlineVars['阶段'] == '失衡');
        expect(locked.inlineVars['旋转类型'], type);
        expect(locked.scene.zones.single.pattern, ZonePattern.dashed);
        expect(locked.scene.zones.single.label, contains(type));
        final rotations = frames
            .where((f) => f.inlineVars['阶段'] == '旋转')
            .toList();
        final doubleRotation = type == 'LR' || type == 'RL';
        expect(rotations.length, doubleRotation ? 2 : 1);
        if (doubleRotation) {
          final middle = frames[rotations.first.stepIndex + 1];
          expect(middle.inlineVars['阶段'], '中间态');
          expect(middle.scene.edges, rotations.first.scene.edges);
          expect(rotations.last.stepIndex, middle.stepIndex + 1);
        }
        for (final frame in frames) {
          final rows = {
            for (final r in frame.scene.auxTables.last.rows) r[0]: r,
          };
          final reached = <String>{}, inorder = <int>[];
          int height(String id) {
            if (id == 'NULL') return 0;
            expect(reached.add(id), isTrue);
            final r = rows[id]!;
            final left = height(r[2]);
            inorder.add(int.parse(r[1]));
            final right = height(r[3]), bf = left - right;
            expect(int.parse(r.last), bf);
            if (['平衡', '完成'].contains(frame.inlineVars['阶段'])) {
              expect(bf.abs(), lessThanOrEqualTo(1));
              expect(r[r.length - 2], r.last);
            }
            return 1 + (left > right ? left : right);
          }

          expect(
            height(frame.inlineVars['根']!).toString(),
            frame.scene.auxTables.first.rows.single[2],
          );
          expect(reached, rows.keys.toSet());
          expect(inorder, [...inorder]..sort());
        }
        final last = frames.last, rows = last.scene.auxTables.last.rows;
        expect(
          rows.singleWhere((r) => r[0] == last.inlineVars['根'])[1],
          '$rootKey',
        );
        expect(
          rows.singleWhere((r) => r[1] == '$pivot')[direction],
          rows.singleWhere((r) => r[1] == '$transfer')[0],
        );
      }
    });

    test('递增五键在最深失衡点旋转，图 7.12 保留非根双旋的父链接', () {
      final frames = preset('avl-chain'),
          locked = frames.where((f) => f.inlineVars['阶段'] == '失衡').toList();
      expect(locked.map((f) => (f.inlineVars['旋转类型'], f.inlineVars['A'])), [
        ('RR', 'n1'),
        ('RR', 'n3'),
      ]);
      expect(frames.last.scene.auxTables.first.rows.single.sublist(1, 3), [
        '5',
        '3',
      ]);
      expect(
        bst
            .generateTrace(
              const BstInput(
                values: [10, 20, 30, 40, 50],
                operation: BstOperation.build,
              ),
            )
            .frames
            .last
            .scene
            .auxTables
            .first
            .rows
            .single[2],
        '5',
      );
      final fig = preset('avl-fig712');
      expect(
        fig
            .where((f) => f.inlineVars['阶段'] == '失衡')
            .map((f) => f.inlineVars['旋转类型']),
        ['RR', 'RL'],
      );
      final f = fig.last;
      expect(f.inlineVars['根'], 'n2');
      expect(
        f.scene.auxTables.last.rows.singleWhere((r) => r.first == 'n2')[3],
        'n5',
      );
      final subtree = locked.last.scene.zones.single;
      final ancestor = locked.last.scene.nodes.singleWhere((n) => n.id == 'n2');
      expect(ancestor.y + ancestor.height, lessThan(subtree.y));
      for (final values in <List<int>>[
        [],
        [0, 0],
        [-1, 0, -2, -1],
      ]) {
        final last = bst
            .generateTrace(
              BstInput(operation: BstOperation.avl, values: values),
            )
            .frames
            .last;
        expect(last.metrics.allocations, values.toSet().length);
        expect(last.scene.nodes.length, values.toSet().length);
      }
    });
  });

  group('二叉排序树 · 算法 7.4～7.7', () {
    const bst = BstModule();
    List<TraceFrame> preset(String id) =>
        bst.generateTrace(bst.validateInput(id).value!).frames;
    Map<String, List<String>> links(TraceFrame f) => {
      for (final row in f.scene.auxTables.last.rows) row[0]: row,
    };
    test('图 7.5 的递归调用轨迹及图 7.7 叶子插入', () {
      for (final (id, keys, returnId) in [
        ('find100', ['45', '53', '100'], 'n6'),
        ('find40', ['45', '12', '37'], 'NULL'),
      ]) {
        final frames = preset(id);
        final comparisons = frames
            .where((f) => f.inlineVars['阶段'] == '比较')
            .toList();
        expect(
          comparisons.map(
            (f) => f.scene.nodes
                .singleWhere((n) => n.visualState == NodeVisualState.active)
                .label,
          ),
          keys,
        );
        expect(comparisons.map((f) => f.callStack.length), [1, 2, 3]);
        expect(frames.last.inlineVars['结果'], '返回 $returnId');
        expect(frames.last.callStack, isEmpty);
        expect(frames.last.metrics.comparisons, 3);
      }
      final insert = preset('ins55').last, rows = links(insert);
      final parent = rows.values.singleWhere((r) => r[1] == '61');
      expect(rows[parent[2]]!.sublist(1, 4), ['55', 'NULL', 'NULL']);
      expect(insert.metrics.allocations, 1);
      final empty = bst
          .generateTrace(
            const BstInput(values: [], operation: BstOperation.insert, key: 3),
          )
          .frames
          .last;
      expect(empty.inlineVars['根'], 'n1');
      final duplicate = bst
          .generateTrace(
            const BstInput(values: [3], operation: BstOperation.insert, key: 3),
          )
          .frames
          .last;
      expect(duplicate.metrics.allocations, 0);
      expect(links(duplicate).keys, ['n1']);
    });
    test('图 7.6 建树 ASL、计划重复键和图 7.8 原序列', () {
      final f = preset('fig76').last;
      expect(f.scene.auxTables.first.rows, [
        ['A', '6', '3', '14/6', '12 24 37 45 53 93'],
        ['B', '6', '6', '21/6', '12 24 37 45 53 93'],
      ]);
      final chain = f.scene.nodes.where((n) => n.groupTag == 'b').toList();
      for (var i = 1; i < chain.length; i++) {
        expect(chain[i].x, greaterThan(chain[i - 1].x));
        expect(chain[i].y, greaterThan(chain[i - 1].y));
      }
      final steps = preset(
        'star',
      ).where((f) => f.inlineVars['阶段'] == '读入').toList();
      expect(steps.map((f) => f.scene.auxTables.first.rows.first[1]), [
        '1',
        '2',
        '3',
        '3',
        '4',
        '4',
      ]);
      expect(steps.last.scene.auxTables.first.rows.last[3], '15/5');
      expect(
        preset('fig78').last.scene.auxTables.first.rows.single.last,
        '12 24 45 53 90',
      );
    });
    test('叶子、单孩子和根链接的摘除与释放', () {
      for (final (id, deleted, parent, side, child) in [
        ('leaf', '24', '37', 2, 'NULL'),
        ('left', '45', '17', 3, '23'),
        ('right', '78', '53', 3, '94'),
      ]) {
        final frames = preset(id),
            initial = links(frames.first),
            end = links(frames.last);
        final old = initial.values.singleWhere((r) => r[1] == deleted)[0];
        final owner = initial.values.singleWhere((r) => r[1] == parent)[0];
        expect(initial[owner]![side], old);
        expect(end.containsKey(old), false);
        expect(
          end[owner]![side],
          child == 'NULL'
              ? 'NULL'
              : initial.values.singleWhere((r) => r[1] == child)[0],
        );
        expect(links(frames[frames.length - 2])[old]!.last, '待释放');
        if (child != 'NULL') {
          expect(
            frames.any(
              (f) =>
                  f.scene.edges.any((e) => e.id == 'graft' && e.curvature != 0),
            ),
            true,
          );
        }
      }
      for (final values in <List<int>>[
        [7],
        [7, 3],
        [7, 9],
        [],
      ]) {
        final f = bst
            .generateTrace(BstInput(values: values, key: 7))
            .frames
            .last;
        expect(f.inlineVars['根'], values.length == 2 ? 'n2' : 'NULL');
      }
      final miss = bst
          .generateTrace(const BstInput(values: [8, 2], key: 10))
          .frames;
      expect(links(miss.first), links(miss.last));
    });
    test('双孩子时保留 p 的地址，涵盖 q==p 与 q!=p 的非空左孩子', () {
      for (final (values, parentId, field, sId, childId) in [
        ([50, 30, 80, 20], 'n1', 2, 'n2', 'n4'),
        ([50, 30, 80, 45, 40], 'n2', 3, 'n4', 'n5'),
      ]) {
        final frames = bst
            .generateTrace(BstInput(values: values, key: 50))
            .frames;
        final before = links(frames.first);
        final copy = frames.singleWhere((f) => f.inlineVars['阶段'] == '复制');
        final copied = links(copy);
        expect(copy.inlineVars['p'], 'n1');
        expect(copy.inlineVars['q'], parentId);
        expect(copy.inlineVars['s'], sId);
        expect(copied['n1']![1], before[sId]![1]);
        expect(copied[sId], before[sId]);
        expect(copied[parentId]![field], sId);
        final rewire = links(frames[frames.length - 2]);
        expect(rewire[parentId]![field], childId);
        expect(rewire[sId]!.last, '待释放');
        final end = links(frames.last);
        expect(end.containsKey(sId), false);
        expect(end['n1']![1], before[sId]![1]);
        expect(end[parentId]![field], childId);
        expect(before['n1']![1], '50');
      }
      final end = preset('del78').last;
      expect(
        end.scene.auxTables.first.rows.single.last,
        '9 17 23 45 53 60 70 75 88 94',
      );
    });
    test('接续操作保留地址和历史结果，释放后的地址不复用', () {
      final original = const BstInput(values: [5, 3, 7], key: 5);
      final second = original.operate(
        BstOperation.insert,
        5,
        continueResult: true,
      );
      final third = second.operate(
        BstOperation.search,
        5,
        continueResult: true,
      );
      final deletion = bst.generateTrace(original).frames.last,
          insert = bst.generateTrace(second).frames,
          search = bst.generateTrace(third).frames;
      expect(links(insert.first), links(deletion));
      expect(links(search.first), links(insert.last));
      expect(search.last.inlineVars['结果'], '返回 n4');
      expect(links(search.last)['n1']![1], '3');
    });
  });
}
