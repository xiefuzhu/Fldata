import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../vm/algorithm_module.dart';
import '../vm/trace_builder.dart';

/// A small Sum(n) inspector fixture; this does not count as a curriculum lesson.
class RecursionTraceDemo implements AlgorithmModule<int> {
  const RecursionTraceDemo();
  @override
  String get id => 'engine.recursion-preview';
  @override
  List<AlgorithmPreset<int>> get presets => const [
    AlgorithmPreset(id: 'recursion', name: '递归工作栈', input: 3),
  ];
  @override
  ValidationResult<int> validateInput(String raw) => raw.trim() == 'recursion'
      ? const ValidationResult.success(3)
      : const ValidationResult.failure('请选择递归工作栈样例');
  @override
  TraceTimeline generateTrace(int input) {
    if (input < 0 || input > 8) throw ArgumentError('Expected 0..8');
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: '递归工作栈',
      codeLines: const {
        CodeLang.cLike: [
          'Sum(n) {',
          '  if (n == 0) return 0;',
          '  child = Sum(n - 1); /* RetLoc1 */',
          '  return n + child;',
          '}',
        ],
        CodeLang.c99: [
          'int sum(int n) {',
          '  if (n == 0) return 0;',
          '  int child = sum(n - 1); /* RetLoc1 */',
          '  return n + child;',
          '}',
        ],
        CodeLang.dart: [
          'int sum(int n) {',
          '  if (n == 0) return 0;',
          '  final child = sum(n - 1); // RetLoc1',
          '  return n + child;',
          '}',
        ],
      },
    );
    final stack = <StackActivationRecord>[];
    void record(int line, String title, {bool milestone = false}) {
      final nodes = [
        for (var i = 0; i < stack.length; i++)
          SceneNode(
            id: stack[i].id,
            label: 'Sum(${stack[i].arguments['n']!})',
            x: 32 + i * 144.0,
            y: 120,
            width: 120,
            visualState: i == stack.length - 1
                ? NodeVisualState.active
                : NodeVisualState.normal,
            memoryAddress: '栈帧 $i',
          ),
      ];
      builder.step(
        title: title,
        explain: '每次调用有独立实参、局部变量和 RetLoc；返回后弹出栈帧，历史调用保留在递归树中。',
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: stack.isEmpty
            ? {'result': (input * (input + 1) ~/ 2).toString()}
            : {...stack.last.arguments, ...stack.last.locals},
        callStack: List.of(stack),
        scene: SceneSnapshot(
          layoutMode: SceneLayoutMode.linearMemory,
          nodes: nodes,
          pointers: [
            if (stack.isNotEmpty)
              PointerBadge(id: 'SP', label: 'SP', targetNodeId: stack.last.id),
          ],
          auxTables: [
            AuxTableSnapshot(
              id: 'activation-records',
              title: '活动记录',
              columns: const ['调用', 'n', 'child', 'RetLoc'],
              rows: [
                for (final r in stack)
                  [
                    r.id,
                    r.arguments['n']!,
                    r.locals['child'] ?? '—',
                    r.returnLocation,
                  ],
              ],
              highlightedRows: {if (stack.isNotEmpty) stack.length - 1},
            ),
          ],
        ),
        milestone: milestone,
      );
    }

    for (var n = input; n >= 0; n--) {
      stack.add(
        StackActivationRecord(
          id: 'call-$n',
          functionName: 'Sum',
          arguments: {'n': n.toString()},
          locals: n == 0 ? const {} : const {'child': '待返回'},
          returnLocation: stack.isEmpty ? 'Main' : 'RetLoc1',
          parentCallId: stack.lastOrNull?.id,
        ),
      );
      record(
        n == 0 ? 2 : 1,
        n == 0 ? '递归基：返回 0' : '进入 Sum($n)',
        milestone: n == 0,
      );
    }
    var result = 0;
    stack.removeLast();
    while (stack.isNotEmpty) {
      final current = stack.last;
      stack[stack.length - 1] = current.copyWith(
        locals: {'child': result.toString()},
      );
      result += int.parse(current.arguments['n']!);
      record(4, '返回到 ${current.returnLocation}', milestone: true);
      stack.removeLast();
    }
    record(5, '全部返回：$result', milestone: true);
    return builder.build();
  }
}
