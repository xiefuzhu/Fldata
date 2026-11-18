import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch5_tree/bitree_traverse.dart';

void main() {
  const module = BiTreeModule();
  test(
    'reconstruction round-trips both traversals, including repeated labels and empty trees',
    () {
      for (final seq in [
        '#',
        'A##',
        const TreeInput().sequence,
        'ABD#G###CE##F##',
        'AAB####',
        '甲#🌲##',
      ]) {
        final root = readPreorder(seq),
            middle = traversalSequence(root, TreeLesson.inorder);
        for (final post in [false, true]) {
          final order = post ? TreeLesson.postorder : TreeLesson.preorder;
          final outer = traversalSequence(root, order);
          final result = readPreorder(
            reconstructSequence(outer, middle, postorder: post),
          );
          expect(traversalSequence(result, order), outer);
          expect(traversalSequence(result, TreeLesson.inorder), middle);
        }
      }
      for (final (a, b) in [
        ('ABC', 'CAB'),
        ('AB', 'AA'),
        ('A', ''),
        ('#', '#'),
      ]) {
        expect(
          () => reconstructSequence(a, b, postorder: false),
          throwsFormatException,
        );
      }
      final deep = String.fromCharCodes(List.generate(70, (i) => 0x4e00 + i));
      final skewed = readPreorder(
        reconstructSequence(deep, deep, postorder: false),
      );
      var last = skewed!;
      while (last.right != null) {
        last = last.right!;
      }
      expect(last.index, (BigInt.one << 70) - BigInt.one);
    },
  );
  test(
    'queue order, growing # and reconstruction trees, independent copies and subtree returns',
    () {
      for (final mode in TreeLesson.values.where((m) => m.isWorkshop)) {
        final trace = module.generateTrace(TreeInput(lesson: mode)),
            frames = trace.frames;
        final first = frames.first, last = frames.last;
        expect(last.callStack, isEmpty);
        if (mode == TreeLesson.levelOrder) {
          expect(last.inlineVars['输出'], 'ABCDEFG');
          for (final f in frames) {
            expect(
              f.metrics.auxiliarySpace,
              f.scene.auxTables.single.rows.length,
            );
          }
          expect(last.scene.auxTables.single.rows, isEmpty);
          expect(
            frames
                .firstWhere((f) => f.phaseTitle == '访问 B')
                .scene
                .auxTables
                .single
                .rows,
            isEmpty,
          );
        } else if (mode == TreeLesson.depth || mode == TreeLesson.count) {
          expect(last.inlineVars['结果'], mode == TreeLesson.depth ? '5' : '7');
          final returned = frames.where((f) => f.inlineVars.containsKey('右返回'));
          expect(returned.length, 7);
          expect(returned.last.inlineVars['返回'], last.inlineVars['结果']);
        } else {
          final copy = mode == TreeLesson.copy;
          expect(first.scene.nodes.length, copy ? 7 : 0);
          expect(last.scene.nodes.length, copy ? 14 : 7);
          expect(last.metrics.allocations, 7);
          expect(
            last.scene.nodes.map((n) => n.id).toSet().length,
            last.scene.nodes.length,
          );
          if (copy) {
            final edgeIds = last.scene.edges
                .map((e) => (e.fromNodeId, e.toNodeId))
                .toSet();
            for (final (a, b) in edgeIds.where(
              (e) => !e.$1.startsWith('copy-'),
            )) {
              expect(edgeIds, contains(('copy-$a', 'copy-$b')));
            }
          } else if (mode == TreeLesson.create) {
            final cursors = [
              for (final f in frames)
                if (f.inlineVars.containsKey('游标'))
                  int.parse(f.inlineVars['游标']!),
            ];
            expect(cursors, orderedEquals([...cursors]..sort()));
            final reads = frames.where((f) => f.phaseTitle.startsWith('进入 '));
            expect(
              reads.map((f) => f.inlineVars['字符']).join(),
              const TreeInput().sequence,
            );
          } else {
            final splits = frames.where((f) => f.phaseTitle.startsWith('定位中序'));
            expect(splits.length, 7);
            for (final f in splits) {
              final v = f.inlineVars;
              expect(v['左区间']! + v['分割根']! + v['右区间']!, v['中序区间']);
            }
          }
        }
        final empty = module
            .generateTrace(TreeInput(sequence: '#', lesson: mode))
            .frames
            .last;
        expect(empty.scene.nodes, isEmpty);
        if (mode == TreeLesson.depth || mode == TreeLesson.count) {
          expect(empty.inlineVars['结果'], '0');
        }
      }
    },
  );
}
