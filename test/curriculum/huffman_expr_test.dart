import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch5_tree/huffman_expr.dart';
import 'package:fldata/curriculum/ch5_tree/huffman_tree.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = HuffmanExprModule();
  test(
    'example 5.2 reproduces each row of HT, figure 5.29 and leaf depths',
    () {
      final tree = HuffmanTree.build(textbookWeights);
      expect(tree.table.skip(1).map((n) => n.parent), [
        9,
        14,
        10,
        10,
        12,
        13,
        9,
        11,
        11,
        12,
        13,
        14,
        15,
        15,
        0,
      ]);
      expect(
        tree.table.skip(9).map((n) => (n.weight.toInt(), n.left, n.right)),
        [
          (8, 1, 7),
          (15, 3, 4),
          (19, 8, 9),
          (29, 5, 10),
          (42, 6, 11),
          (58, 2, 12),
          (100, 13, 14),
        ],
      );
      expect(tree.codes, {
        'a': '0110',
        'b': '10',
        'c': '1110',
        'd': '1111',
        'e': '110',
        'f': '00',
        'g': '0111',
        'h': '010',
      });
      expect(tree.wpl, BigInt.from(271));
      expect(tree.height, 5);
      for (final a in tree.codes.values) {
        expect(tree.codes.values.where((b) => b.startsWith(a)), [a]);
      }
      expect(
        textbookWeights.entries.fold<int>(
          0,
          (sum, e) => sum + e.value * tree.codes[e.key]!.length,
        ),
        271,
      );
      final trace = module.generateTrace(const ApplicationInput());
      final choices = trace.frames
          .where((f) => f.inlineVars.containsKey('s1'))
          .toList();
      expect(choices.length, 7);
      for (final f in choices) {
        final table = f.scene.auxTables.first;
        expect(table.rows.length, 15);
        expect(table.highlightedRows, {
          for (final (i, r) in table.rows.indexed)
            if (r[1] != '—' && r[2] == '0') i,
        });
      }
      expect(trace.frames.last.inlineVars, {'WPL': '271', '树高': '5'});
      expect(trace.frames.first.scene.nodes.length, 8);
    },
  );
  test('bit paths match the input including root resets, ties and unicode', () {
    final input = const ApplicationInput().withMode(
      TreeApplication.decode,
      message: 'abfhg',
    );
    final tree = HuffmanTree.build(input.weights);
    final bits = tree.encode(input.message),
        trace = module.generateTrace(input);
    expect(trace.frames.length, bits.length + 2);
    var current = tree.root;
    for (var i = 0; i < bits.length; i++) {
      final f = trace.frames[i + 1];
      final e = f.scene.edges.singleWhere(
        (e) => e.visualState == NodeVisualState.active,
      );
      expect(e.fromNodeId, 'h$current');
      current = bits[i] == '0'
          ? tree.table[current].left
          : tree.table[current].right;
      expect(e.toNodeId, 'h$current');
      expect(e.weightLabel, bits[i]);
      if (tree.table[current].symbol != null) current = tree.root;
    }
    expect(trace.frames.last.inlineVars['输出'], input.message);
    final ties = HuffmanTree.build({'甲': 1, '乙': 1, '🌱': 1, '丁': 1});
    expect(ties.codes, {'甲': '00', '乙': '01', '🌱': '10', '丁': '11'});
    expect(ties.decode(ties.encode('🌱甲丁乙🌱')), '🌱甲丁乙🌱');
    expect(ties.decode(''), '');
    expect(() => ties.encode('外'), throwsFormatException);
    expect(() => ties.decode('1'), throwsFormatException);
    expect(() => ties.decode('1x'), throwsFormatException);
  });
  test(
    '5.12 builds ordered subtrees; 5.13 evaluates postorder with integer division',
    () {
      TraceTimeline run(String s) => module.generateTrace(
        ApplicationInput(mode: TreeApplication.expression, expression: s),
      );
      final trace = run('3*(7-2)#'), last = trace.frames.last;
      expect(last.inlineVars['后序'], '3 7 2 - *');
      expect(last.inlineVars['结果'], '15');
      expect(last.scene.nodes.length, 5);
      expect(
        last.scene.edges
            .where((e) => e.fromNodeId == 'e5')
            .map((e) => (e.fromPort, e.toNodeId)),
        [(EdgePort.lchild, 'e1'), (EdgePort.rchild, 'e4')],
      );
      expect(
        trace.frames.any((f) => f.inlineVars['EXPT'] == 'e1 e2 e3'),
        isTrue,
      );
      expect(last.metrics.maxCallDepth, 3);
      expect(last.callStack, isEmpty);
      expect(run('(1-8)/2#').frames.last.inlineVars['结果'], '-3');
      expect(run('12-4-2#').frames.last.inlineVars['结果'], '6');
      for (final s in [
        '8/(2-2)#',
        '3(2)#',
        '1+#',
        '(1#',
        '1)#',
        '#',
        '1#2#',
        'a#',
      ]) {
        expect(run(s).frames.last.isErrorState, isTrue, reason: s);
      }
    },
  );
}
