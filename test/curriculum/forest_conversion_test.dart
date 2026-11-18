import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch5_tree/bitree_traverse.dart';
import 'package:fldata/curriculum/ch5_tree/forest_conversion.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = ForestModule();
  test(
    'textbook forest: three beats, stable nodes, storage and independent orders',
    () {
      final frames = module.generateTrace(module.presets.first.input).frames;
      final [forest, added, trimmed, binary] = frames
          .map((f) => f.scene)
          .toList();
      final byId = {for (final n in forest.nodes) n.id: n.label};
      String link(SceneEdge e) => '${byId[e.fromNodeId]}${byId[e.toNodeId]}';
      final groups = {'BC', 'CD', 'AE', 'EG', 'HI'};
      final firsts = {'AB', 'EF', 'GH', 'IJ'};
      expect(forest.edges.map(link).toSet(), {
        'AB',
        'AC',
        'AD',
        'EF',
        'GH',
        'GI',
        'IJ',
      });
      expect(
        added.edges
            .where((e) => e.fromPort == EdgePort.rchild)
            .map(link)
            .toSet(),
        groups,
      );
      expect(trimmed.edges.map(link).toSet(), {...groups, ...firsts});
      expect(binary.edges, trimmed.edges);
      expect(added.nodes, forest.nodes);
      expect(trimmed.nodes, forest.nodes);
      for (final edge in binary.edges) {
        final a = binary.nodes.singleWhere((n) => n.id == edge.fromNodeId),
            b = binary.nodes.singleWhere((n) => n.id == edge.toNodeId);
        expect(b.y, greaterThan(a.y));
        expect(
          b.x,
          edge.fromPort == EdgePort.lchild ? lessThan(a.x) : greaterThan(a.x),
        );
      }
      final growth = SceneInterpolator.lerp(forest, added, .4);
      expect(
        growth.edges
            .where((e) => groups.contains(link(e)))
            .every((e) => e.drawProgress == .4),
        isTrue,
      );
      final fade = SceneInterpolator.lerp(added, trimmed, .4);
      expect(
        fade.edges.singleWhere((e) => link(e) == 'AC').opacity,
        closeTo(.6, 1e-6),
      );
      final rotation = SceneInterpolator.lerp(trimmed, binary, .4);
      expect(rotation.nodes, isNot(trimmed.nodes));
      expect(rotation.nodes, isNot(binary.nodes));
      expect(frames.last.inlineVars['森林先序'], 'ABCDEFGHIJ');
      expect(frames.last.inlineVars['二叉先序'], 'ABCDEFGHIJ');
      expect(frames.last.inlineVars['森林中序'], 'BCDAFEHJIG');
      expect(frames.last.inlineVars['二叉中序'], 'BCDAFEHJIG');
      final [parent, children, siblings] = forest.auxTables;
      expect(parent.rows.take(3).map((r) => r.last), ['-1', '-1', '-1']);
      expect(children.rows.first, ['0', 'A', '3 → 4 → 5 → ∅']);
      expect(siblings.rows.first, ['0', 'A', '3', '1']);
    },
  );
  test(
    'left-child right-sibling encoding and inverse preserve root order, child order and repeated labels',
    () {
      for (final raw in [
        ...module.presets.map((p) => p.input.sequence),
        'A(A,A),A',
        '甲(子),乙',
        'A(B(C(D)))',
        'Z',
      ]) {
        final forest = parseForest(raw);
        final sequence = forestBinarySequence(forest);
        final decoded = forestFromBinary(readPreorder(sequence));
        expect(
          decoded.map((n) => n.expression),
          forest.map((n) => n.expression),
        );
        final vars = module
            .generateTrace(TreeInput(sequence: raw))
            .frames
            .last
            .inlineVars;
        expect(vars['森林先序'], vars['二叉先序']);
        expect(vars['森林中序'], vars['二叉中序']);
      }
      for (final raw in ['A(,B)', 'A(B', 'A(B,)', 'A B', 'A,', 'A()']) {
        expect(module.validateInput(raw).isValid, isFalse);
      }
      expect(forestBinarySequence(parseForest('A(B,C),D')), 'AB#C##D##');
      expect(
        forestFromBinary(readPreorder('AB#C##D##')).map((n) => n.expression),
        ['A(B,C)', 'D'],
      );
    },
  );
}
