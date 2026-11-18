import '../engine/vm/algorithm_module.dart';
import 'ch1_intro/adt_complex.dart';
import 'ch1_intro/complexity_lab.dart';
import 'ch1_intro/struct_mapping.dart';
import 'ch2_linear_list/cases_polyn_book.dart' as polyn;
import 'ch2_linear_list/circular_dulink.dart';
import 'ch2_linear_list/linklist_ops.dart';
import 'ch2_linear_list/merge_compare.dart';
import 'ch2_linear_list/sqlist_ops.dart';
import 'ch3_stack_queue/cases_expr_dance.dart' as dance;
import 'ch3_stack_queue/queue_sq_link.dart';
import 'ch3_stack_queue/recursion_hanoi.dart';
import 'ch3_stack_queue/stack_sq_link.dart';
import 'ch4_string_array_glist/array_matrix.dart';
import 'ch4_string_array_glist/bf_kmp.dart';
import 'ch4_string_array_glist/glist_explorer.dart';
import 'ch5_tree/bitree_traverse.dart';
import 'ch5_tree/forest_conversion.dart';
import 'ch5_tree/huffman_expr.dart';
import 'ch5_tree/threaded_tree.dart';
import 'ch6_graph/graph_storage_module.dart';
import 'ch6_graph/graph_traversal.dart';
import 'ch6_graph/minimum_spanning_tree.dart';
import 'ch6_graph/dijkstra.dart';
import 'ch6_graph/topo_critical.dart';
import 'ch7_search/bst.dart';
import 'ch7_search/btree.dart';
import 'ch7_search/hash_table.dart';
import 'ch7_search/static_search.dart';
import 'ch8_sort/exchange_sort.dart';
import 'ch8_sort/external_sort.dart';
import 'ch8_sort/insertion_sort.dart';
import 'ch8_sort/merge_radix.dart';
import 'ch8_sort/selection_sort.dart';
import 'ch6_graph/graph_input.dart';
import 'ch6_graph/six_degrees.dart';
import 'ch8_sort/sort_records.dart';

final datasetModules = {
  for (final module in const <AlgorithmModule<Object>>[
    AdtComplexModule(),
    ComplexityLabModule(),
    StructMappingModule(),
    polyn.CasesPolynBookModule(),
    CircularDulinkModule(),
    LinkListModule(),
    MergeCompareModule(),
    SqListModule(),
    dance.CasesExprDanceModule(),
    QueueSqLinkModule(),
    RecursionHanoiModule(),
    StackSqLinkModule(),
    ArrayMatrixModule(),
    BfKmpModule(),
    GListModule(),
    BiTreeModule(),
    ForestModule(),
    HuffmanExprModule(),
    ThreadedTreeModule(),
    GraphStorageModule(),
    GraphTraversalModule(),
    MinimumSpanningTreeModule(),
    TopoCriticalModule(),
    BstModule(),
    MultiwayModule(),
    HashModule(),
    StaticSearchModule(),
    ExchangeModule(),
    ExternalModule(),
    InsertionModule(),
    MergeRadixModule(),
    SelectionModule(),
    DijkstraModule(),
  ])
    module.id: module,
};

List<AlgorithmPreset<Object>> datasetPresets(String id) {
  final module = datasetModules[id];
  if (module == null) return [];
  final presets = module.presets;
  if (module is GraphTraversalModule) {
    final ids = presets.map((p) => p.id).toSet();
    return [
      ...presets,
      ...const SixDegreeModule().presets.where((p) => !ids.contains(p.id)),
    ];
  }
  return presets;
}

String datasetText(Object input) => switch (input) {
  MappingInput v => '${v.logical.name} ${v.storage.name} ${v.count} ${v.seed}',
  ComplexInput v =>
    '${v.operation.name} ${v.a.real} ${v.a.imag} ${v.b.real} ${v.b.imag}',
  ComplexityInput v => '${v.mode.name} ${v.n} ${v.search.name}',
  SqListInput v =>
    '${v.operation.name}|${v.capacity}|${v.position}|${v.value}|${v.values.join(',')}',
  LinkListInput v =>
    '${v.operation.name}|${v.hasHead ? 1 : 0}|${v.wrongOrder ? 1 : 0}|${v.position}|${v.value}|${v.values.join(',')}',
  CircularInput v =>
    '${v.operation.name}|${v.position}|${v.value}|${v.a.join(',')}|${v.b.join(',')}',
  MergeInput v => '${v.operation.name}|${v.a.join(',')}|${v.b.join(',')}',
  polyn.CasesInput v => v.raw,
  dance.CasesInput v => v.raw,
  StackInput v => v.raw,
  QueueInput v => v.raw,
  RecursionInput v => v.raw,
  MatchInput v => '${v.text}|${v.pattern}',
  MatrixInput v => '${v.mode.name}|${v.parameters}|${v.entries}',
  GListInput v => v.expression,
  TreeInput v => v.sequence,
  ApplicationInput v => switch (v.mode) {
    TreeApplication.expression => v.expression,
    TreeApplication.decode => v.message,
    _ => v.weights.entries.map((e) => '${e.key}:${e.value}').join(' '),
  },
  GraphInputModel v =>
    v.arcs.map((e) => '${e.tail} ${e.head} ${e.weight}').join('\n'),
  SearchInput v => v.groups.map((g) => g.join(' ')).join(' | '),
  BstInput v => v.values.join(' '),
  MultiwayInput v => v.initial.join(' '),
  HashInput v => v.initial.join(' '),
  ExchangeInput v => v.keys.join(' '),
  SelectionInput v => v.keys.join(' '),
  InsertionInput v => v.keys.join(' '),
  MergeRadixInput v => v.keys.join(' '),
  ExternalInput v =>
    v.method == ExternalMethod.merge
        ? v.runs.map((g) => g.join(' ')).join('\n')
        : v.keys.join(' '),
  _ => throw UnsupportedError('未知课程数据类型 ${input.runtimeType}'),
};

Object datasetInput(
  AlgorithmModule<Object> module,
  Map<String, dynamic> payload,
) {
  final preset = datasetPresets(
    module.id,
  ).where((p) => p.id == payload['preset']).firstOrNull;
  if (preset == null) throw const FormatException('此数据集缺少有效的课程示例。');
  final text = payload['input'];
  if (text is! String) throw const FormatException('缺少输入文本。');
  final base = preset.input;
  if (text == datasetText(base)) return base;
  Object validated(ValidationResult<Object> result) =>
      result.value ?? (throw FormatException(result.error!));
  switch (base) {
    case GraphInputModel():
      var graph = base;
      for (final arc in base.arcs) {
        graph = graph.removeEdge(arc.id);
      }
      for (final line in text.split('\n').where((s) => s.trim().isNotEmpty)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length != 3) throw const FormatException('每行填写起点、终点和整数权值。');
        final weight = int.tryParse(parts[2]);
        if (weight == null) throw const FormatException('边权须为整数。');
        graph = graph.connect(parts[0], parts[1], weight: weight);
      }
      return graph;
    case SearchInput():
      return validated(
        SearchInput.parse(
          text,
          base.key.toString(),
          base.method,
          base.binaryIndex,
        ),
      );
    case BstInput():
      return BstInput(
        values: parseSortIntegers(text),
        comparison: base.comparison,
        history: base.history,
        operation: base.operation,
        key: base.key,
      );
    case MultiwayInput():
      return MultiwayInput(
        initial: parseSortIntegers(text),
        order: base.order,
        operations: base.operations,
        plus: base.plus,
        low: base.low,
        high: base.high,
      );
    case HashInput():
      return HashInput(
        initial: parseSortIntegers(text),
        function: base.function,
        collision: base.collision,
        m: base.m,
        p: base.p,
        base: base.base,
        seed: base.seed,
        digits: base.digits,
        boundaryFold: base.boundaryFold,
        operations: base.operations,
      )..validate();
    case ExternalInput():
      return ExternalInput.parse(base.method, text, base.parameter.toString());
    case InsertionInput():
      return base.change(keys: parseSortIntegers(text))..validate();
    case ExchangeInput():
      return base.change(keys: parseSortIntegers(text));
    case SelectionInput():
      return SelectionInput(keys: parseSortIntegers(text), method: base.method);
    case MergeRadixInput():
      final keys = parseSortIntegers(text);
      if (base.method == MergeRadixMethod.radix && keys.any((k) => k < 0)) {
        throw const FormatException('基数排序要求非负整数。');
      }
      return MergeRadixInput(
        keys: keys,
        method: base.method,
        bottomUp: base.bottomUp,
      );
    case ApplicationInput():
      return switch (base.mode) {
        TreeApplication.expression => base.withMode(
          base.mode,
          expression: text,
        ),
        TreeApplication.decode => base.withMode(base.mode, message: text),
        _ => base.withMode(base.mode, weights: parseWeights(text)),
      };
  }
  final parsed = validated(module.validateInput(text));
  if (base is MatchInput && parsed is MatchInput) {
    return MatchInput(
      text: parsed.text,
      pattern: parsed.pattern,
      mode: base.mode,
      optimized: base.optimized,
    );
  }
  if (base is GListInput && parsed is GListInput) {
    return GListInput(
      expression: parsed.expression,
      mode: base.mode,
      path: base.path,
    );
  }
  if (base is TreeInput && parsed is TreeInput) {
    return TreeInput(sequence: parsed.sequence, lesson: base.lesson);
  }
  if (base is MatrixInput && parsed is MatrixInput) {
    return parsed.select(
      base.z.clamp(0, parsed.layers - 1),
      base.i.clamp(0, parsed.rows - 1),
      base.j.clamp(0, parsed.cols - 1),
      columns: base.columnMajor,
    );
  }
  return parsed;
}
