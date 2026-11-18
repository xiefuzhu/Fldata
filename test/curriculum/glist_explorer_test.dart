import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch4_string_array_glist/glist_explorer.dart';
import 'package:fldata/models/trace_model.dart';

String decode(SceneSnapshot scene, GListViewMode mode) {
  final nodes = {for (final n in scene.nodes) n.id: n};
  String follow(String id, String name) => scene.edges
      .singleWhere((e) => e.fromNodeId == id && e.weightLabel == name)
      .toNodeId;
  String value(String id) {
    if (id == nullNodeId) return '()';
    final node = nodes[id]!;
    if (node.logicBadge == 'tag=0') return node.label;
    final values = <String>[];
    if (mode == GListViewMode.headTail) {
      var cons = id;
      while (cons != nullNodeId) {
        values.add(value(follow(cons, 'hp')));
        cons = follow(cons, 'tp');
      }
    } else {
      var child = follow(id, 'hp');
      while (child != nullNodeId) {
        values.add(value(child));
        child = follow(child, 'tp');
      }
    }
    return '(${values.join(', ')})';
  }

  return value(scene.pointers.single.targetNodeId);
}

void main() {
  const module = GListModule();
  test('nested list length, depth and syntax child order', () {
    final frames = module.generateTrace(const GListInput()).frames;
    final last = frames.last;
    expect(last.inlineVars['当前值'], '(E, (a), (b, (c, d)))');
    expect(last.inlineVars['长度'], '3');
    expect(last.inlineVars['深度'], '3');
    final root = last.scene.pointers.single.targetNodeId;
    expect(
      last.scene.edges
          .where((e) => e.fromNodeId == root)
          .map((e) => e.weightLabel),
      ['1', '2', '3'],
    );
    final leaves = frames.where((f) => f.phaseTitle.contains('深度为 0'));
    expect(
      leaves.map(
        (f) => f.scene.nodes
            .singleWhere((n) => n.visualState == NodeVisualState.active)
            .label,
      ),
      ['E', 'a', 'b', 'c', 'd'],
    );
  });
  test(
    'both storage graphs independently reconstruct the result of each peel',
    () {
      for (final mode in [GListViewMode.headTail, GListViewMode.extended]) {
        for (final (expr, path, values) in [
          ('((), (()), x)', [Peel.head], ['((), (()), x)', '()']),
          (
            '((x), y, y)',
            [Peel.tail, Peel.tail, Peel.head],
            ['((x), y, y)', '(y, y)', '(y)', 'y'],
          ),
          ('(a)', [Peel.tail], ['(a)', '()']),
          (
            'D = (E, (a), (b, (c, d)))',
            [Peel.tail, Peel.tail, Peel.head, Peel.tail, Peel.head],
            [
              '(E, (a), (b, (c, d)))',
              '((a), (b, (c, d)))',
              '((b, (c, d)))',
              '(b, (c, d))',
              '((c, d))',
              '(c, d)',
            ],
          ),
        ]) {
          final frames = module
              .generateTrace(
                GListInput(expression: expr, mode: mode, path: path),
              )
              .frames;
          for (final frame in frames) {
            final n = int.parse(frame.inlineVars['操作数']!);
            expect(decode(frame.scene, mode), values[n]);
            expect(frame.inlineVars['当前值'], values[n]);
          }
        }
      }
    },
  );
  test('empty list, atomic head and malformed input are distinct', () {
    for (final (expr, length, depth) in [
      ('()', '0', '1'),
      (' ( ( ) ) ', '1', '2'),
      ('名 = 原子', '无定义', '0'),
    ]) {
      final frame = module
          .generateTrace(GListInput(expression: expr))
          .frames
          .last;
      expect(frame.inlineVars['长度'], length);
      expect(frame.inlineVars['深度'], depth);
    }
    for (final bad in [
      '',
      '(',
      '(a,)',
      '(,a)',
      '(a b)',
      'a = ',
      'a=b=c',
      '() x',
      'a)',
      '((a)',
    ]) {
      expect(module.validateInput(bad).isValid, isFalse, reason: bad);
    }
    for (final expr in ['()', 'a']) {
      expect(
        () => module.generateTrace(
          GListInput(expression: expr, path: const [Peel.tail]),
        ),
        throwsArgumentError,
      );
    }
  });
}
