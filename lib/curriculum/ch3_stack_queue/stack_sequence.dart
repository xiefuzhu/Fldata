import 'dart:convert';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'stack_sq_link.dart';

/// Textbook sequences contain distinct keys. Push only as far as the requested
/// key, so the first buried key pinpoints the impossible pop.
class StackSequence {
  const StackSequence(this.pushOrder, this.popOrder);
  factory StackSequence.fromPreset(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return StackSequence(
      List<int>.from(data['push']),
      List<int>.from(data['pop']),
    );
  }
  final List<int> pushOrder, popOrder;
  StackInput get initial => StackInput(
    operation: StackOperation.init,
    capacity: pushOrder.length,
    a: const [],
    b: const [],
  );

  TraceTimeline trace() {
    const module = StackSqLinkModule();
    final builder = TraceBuilder(
      moduleId: module.id,
      inputSummary: '入栈 ${pushOrder.join(" ")} · 请求出栈 ${popOrder.join(" ")}',
      codeLines: const {
        CodeLang.cLike: [
          '初始化空栈 S',
          '依次读取目标 x',
          '若 x 尚未入过栈，将输入压入直到 x',
          '若栈顶不是 x，返回非法',
          '弹出 x',
          '返回合法',
        ],
        CodeLang.c99: [
          'int s[N], top=0, i=0;',
          'for (int j=0; j<n; ++j) { int x=out[j];',
          '  while (i<=position[x]) s[top++]=in[i++];',
          '  if (!top || s[top-1]!=x) return 0;',
          '  --top; }',
          'return 1;',
        ],
        CodeLang.dart: [
          'final stack=<int>[]; var i=0;',
          'for (final x in output) {',
          '  while (i<=position[x]!) { stack.add(input[i++]); }',
          '  if (stack.isEmpty || stack.last!=x) return false;',
          '  stack.removeLast(); }',
          'return true;',
        ],
      },
    );
    final positions = {for (final (i, key) in pushOrder.indexed) key: i};
    final stack = <int>[], popped = <int>[];
    var next = 0;
    var scene = module.generateTrace(initial).frames.last.scene;
    void step(
      int line,
      String title,
      String why, {
      bool error = false,
      int? target,
    }) {
      builder.step(
        title: title,
        explain: why,
        scene: scene,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: {
          '已弹出': popped.join(' '),
          '待入栈': pushOrder.skip(next).join(' '),
          if (target != null) '请求': '$target',
        },
        deltaRead: line == 4 || line == 5 ? 1 : 0,
        deltaWrite: line == 3 || line == 5 ? 1 : 0,
        milestone: true,
        error: error,
      );
    }

    step(
      1,
      '从空栈开始',
      '入栈次序为 ${pushOrder.join("、")}，请求依次弹出 ${popOrder.join("、")}。',
    );
    for (final key in popOrder) {
      while (next <= positions[key]!) {
        final value = pushOrder[next++];
        scene = module
            .generateTrace(
              StackInput(
                capacity: pushOrder.length,
                a: [...stack],
                value: value,
              ),
            )
            .frames
            .last
            .scene;
        stack.add(value);
        step(3, '压入 $value', '为弹出 $key，将 $value 压入栈顶。', target: key);
      }
      if (stack.isEmpty || stack.last != key) {
        final status = scene.auxTables.first;
        scene = scene.copyWith(
          nodes: [
            for (final node in scene.nodes)
              node.id == 'slot-${stack.length - 1}'
                  ? node.copyWith(visualState: NodeVisualState.error)
                  : node,
          ],
          auxTables: [
            status.copyWith(
              rows: [
                ['非法出栈', '—', ...status.rows.first.skip(2)],
              ],
            ),
            ...scene.auxTables.skip(1),
          ],
        );
        step(
          4,
          '非法出栈 · 请求 $key',
          '栈顶为 ${stack.last}，$key 已被压在下面，无法按指定次序弹出。',
          error: true,
          target: key,
        );
        return builder.build();
      }
      scene = module
          .generateTrace(
            StackInput(
              capacity: pushOrder.length,
              operation: StackOperation.pop,
              a: [...stack],
            ),
          )
          .frames
          .last
          .scene;
      popped.add(stack.removeLast());
      step(5, '弹出 $key', '栈顶与请求一致，已弹出 ${popped.join("、")}。', target: key);
    }
    step(6, '出栈序列合法', '所有请求都已按顺序弹出。');
    return builder.build();
  }
}
