part of 'ch2_textbook_code.dart';

// Expected snapshots are projections of the original input positions.
// They are independent of the linked-list implementations under test.
typedef _Element = ({int value, String id});
List<_Element> _elements(List<int> values, String prefix) => [
  for (final (i, v) in values.indexed) (value: v, id: '$prefix$i'),
];
Map<String, Object> _snapshot(Iterable<_Element> elements) => {
  'values': [for (final e in elements) e.value],
  'ids': [for (final e in elements) e.id],
};

List<int> _sample(int seed, int length) {
  final rng = Random(seed);
  return List.generate(length, (_) => rng.nextInt(513) - 256);
}

List<int> _orderedSample(int seed, int length) =>
    _sample(seed, length).toSet().toList()..sort();

List<AlgorithmTestCase> _setCases(int exercise) {
  AlgorithmTestCase make(String name, List<int> a, List<int> b) {
    final left = _elements(a, 'a'), right = _elements(b, 'b');
    Object expected;
    if (exercise == 1) {
      // Either original node with an equal key can represent the union.
      // The reference implementation keeps the A node.
      final union = {
        for (final e in [...right, ...left]) e.value: e,
      };
      expected = _snapshot(
        union.values.toList()..sort((x, y) => x.value.compareTo(y.value)),
      );
    } else {
      final keys = b.toSet();
      final kept = left
          .where((e) => keys.contains(e.value) == (exercise == 3))
          .toList();
      expected = {
        'result': _snapshot(kept),
        if (exercise == 4) 'count': kept.length,
        'b': _snapshot(right),
      };
    }
    return AlgorithmTestCase(
      name: name,
      input: {'a': a, 'b': b},
      expected: expected,
    );
  }

  return [
    make('交错递增', [-4, 1, 5, 9], [-2, 1, 3, 9, 11]),
    make('两表皆空', [], []),
    make('仅 A 有一个元素', [7], []),
    make('两集合完全重合', [-3, 0, 4], [-3, 0, 4]),
    make('A 为空，B 非空', [], [-9, 12]),
    make('固定种子随机递增序列', _orderedSample(21201, 160), _orderedSample(21202, 128)),
  ];
}

List<AlgorithmTestCase> _splitCases() {
  AlgorithmTestCase make(String name, List<int> a) {
    final elements = _elements(a, 'a');
    return AlgorithmTestCase(
      name: name,
      input: {'a': a},
      expected: {
        'b': _snapshot(elements.where((e) => e.value < 0)),
        'c': _snapshot(elements.where((e) => e.value > 0)),
      },
    );
  }

  return [
    make('正负交错', [3, -2, 5, -7, 3]),
    make('空表', []),
    make('单负数', [-1]),
    make('相同正数', [4, 4, 4]),
    make('负数位于首尾', [-9, 1, 2, -8]),
    make('固定种子非零序列', _sample(21205, 128).where((x) => x != 0).toList()),
  ];
}

List<AlgorithmTestCase> _intervalCases() {
  AlgorithmTestCase make(String name, List<int> a, int low, int high) =>
      AlgorithmTestCase(
        name: name,
        input: {'a': a, 'min': low, 'max': high},
        expected: _snapshot(
          _elements(a, 'a').where((e) => e.value <= low || e.value >= high),
        ),
      );
  return [
    make('两个端点都在表中', [-5, -2, 0, 3, 5, 8], -2, 5),
    make('空表', [], 0, 1),
    make('单元素与相同端点', [4], 4, 4),
    make('区间覆盖全表', [-3, 0, 2], -4, 3),
    make('从中段删至表尾', [-8, -1, 1, 3, 6], -2, 10),
    make('固定种子递增序列', _orderedSample(21208, 160), -90, 96),
  ];
}

List<AlgorithmTestCase> _swapCases() {
  AlgorithmTestCase make(String name, List<int> a, int index) {
    final n = a.length, order = List.generate(n, (i) => i);
    final pos = index - 1;
    if (n > 1) {
      final previous = (pos - 1) % n;
      order[pos] = previous;
      order[previous] = pos;
    }
    final start = order.indexOf(pos);
    return AlgorithmTestCase(
      name: name,
      input: {'a': a, 'index': index},
      expected: {
        'forward': [for (var i = 0; i < n; i++) 'a${order[(start + i) % n]}'],
        'backward': [for (var i = 0; i < n; i++) 'a${order[(start - i) % n]}'],
        'values': a,
      },
    );
  }

  return [
    make('交换中间两个结点', [2, 4, 8, 16], 3),
    make('空环', [], 0),
    make('单结点自环', [7], 1),
    make('双结点同值环', [5, 5], 2),
    make('首个结点与环尾前驱', [1, 2, 3], 1),
    make('固定种子序列的尾结点', _sample(21209, 128), 128),
  ];
}
