import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch5_tree/bitree_traverse.dart';
import 'package:fldata/views/lab/bitree_stage.dart';

void main() {
  const module = BiTreeModule();
  test(
    'three visits per node share a closed contour in all traversal orders',
    () {
      final orders = {
        TreeLesson.preorder: 'ABCDEGF',
        TreeLesson.inorder: 'CBEGDFA',
        TreeLesson.postorder: 'CGEFDBA',
      };
      for (final entry in orders.entries) {
        final frames = module
            .generateTrace(TreeInput(lesson: entry.key))
            .frames;
        final taps = frames.sublist(1, frames.length - 1);
        expect(taps.length, 21);
        final contour = EulerContour(taps.first.scene);
        expect(contour.segments.length, taps.length);
        for (var i = 0; i < taps.length; i++) {
          final vars = taps[i].inlineVars;
          final node = taps[i].scene.nodes.singleWhere(
            (n) => n.id == vars['节点'],
          );
          final side = contour.sides[i];
          expect(['左', '底', '右'][side], vars['切点']);
          expect(
            contour.points[i].dx,
            node.x + node.width / 2 + [-35, 0, 35][side],
          );
          expect(
            contour.points[i].dy,
            node.y + node.height / 2 + [0, 35, 0][side],
          );
          expect(contour.sample(i, 1), contour.points[(i + 1) % taps.length]);
          expect(
            (contour.sample(i, .5) - contour.points[i]).distance,
            greaterThan(0),
          );
        }
        expect(
          taps
              .map((f) => (f.inlineVars['节点'], f.inlineVars['切点']))
              .toSet()
              .length,
          21,
        );
        expect(frames.last.inlineVars['输出'], entry.value);
        expect(frames.last.callStack, isEmpty);
      }
    },
  );
  test(
    'pointer stack agrees with recursive inorder including sparse trees and repeated labels',
    () {
      for (final seq in [
        '#',
        'A##',
        'A#B#C##',
        'AA##A##',
        const TreeInput().sequence,
      ]) {
        final frames = module
            .generateTrace(TreeInput(sequence: seq, lesson: TreeLesson.stack))
            .frames;
        final expected = module
            .generateTrace(TreeInput(sequence: seq, lesson: TreeLesson.inorder))
            .frames
            .last;
        expect(frames.last.inlineVars['输出'], expected.inlineVars['输出']);
        final ids = <String>[];
        for (final frame in frames) {
          final vars = frame.inlineVars;
          if (frame.phaseTitle.startsWith('Push(')) ids.add(vars['p']!);
          if (frame.phaseTitle.startsWith('Pop →')) {
            expect(ids.removeLast(), vars['q']);
          }
          expect(frame.scene.auxTables.single.rows.map((r) => r[1]), ids);
        }
        expect(ids, isEmpty);
      }
    },
  );
  test('complete-tree numbering and incomplete and empty cases', () {
    for (final entry in {
      'ABD##E##CF###': '从 1 到 6 连续',
      'A#B##': '位置编号有缺口',
      '#': '无节点',
    }.entries) {
      final frames = module
          .generateTrace(
            TreeInput(sequence: entry.key, lesson: TreeLesson.properties),
          )
          .frames;
      expect(frames.last.scene.auxTables.single.rows.last.last, entry.value);
      if (entry.key == 'ABD##E##CF###') {
        expect(
          frames.last.scene.auxTables.single.rows,
          contains(equals(['叶子与二度节点', '3 = 2 + 1'])),
        );
        expect(frames.where((f) => f.phaseTitle.startsWith('检查编号')).length, 6);
      }
    }
    for (final seq in ['', 'A#', 'A###']) {
      expect(module.validateInput(seq).isValid, isFalse);
    }
  });
}
