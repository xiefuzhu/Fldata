import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'recursion_hanoi.dart';
import 'recursion_source.dart';

class _Call {
  _Call(this.id, this.name, this.args, this.ret, this.parent);
  final String id, name, ret;
  final String? parent;
  final Map<String, String> args;
  final locals = <String, String>{};
  StackActivationRecord get record => StackActivationRecord(
    id: id,
    functionName: name,
    arguments: args,
    locals: locals,
    returnLocation: ret,
    parentCallId: parent,
  );
}

TraceTimeline generateRecursionTrace(RecursionInput input) {
  final source = RecursionSource(input.kind),
      stack = <_Call>[],
      printed = <int>[];
  final pegs = <String, List<int>>{
    'A': [for (var i = input.n; i >= 1; i--) i],
    'B': [],
    'C': [],
  };
  var calls = 0,
      moves = 0,
      returnId = '',
      returnTo = '',
      returnValue = '',
      result = '—';
  final builder = TraceBuilder(
    moduleId: 'ch3_recursion_hanoi',
    inputSummary:
        '${RecursionHanoiModule.names[input.kind.index]} · ${input.kind == RecursionKind.traverse ? input.values.join(',') : input.n}',
    codeLines: source.lines,
  );
  SceneSnapshot snapshot() {
    final active = stack.lastOrNull;
    return SceneSnapshot(
      nodes: [
        if (input.kind == RecursionKind.hanoi)
          for (var p = 0; p < 3; p++)
            for (var j = 0; j < pegs['ABC'[p]]!.length; j++)
              SceneNode(
                id: 'disk-${pegs['ABC'[p]]![j]}',
                label: '${pegs['ABC'[p]]![j]}',
                x: 110 + p * 220 - (48 + 20 * pegs['ABC'[p]]![j]) / 2,
                y: 280 - (j + 1) * 24.0,
                width: 48 + 20.0 * pegs['ABC'[p]]![j],
                height: 22,
                groupTag: 'ABC'[p],
              ),
        if (input.kind == RecursionKind.traverse)
          for (var i = 0; i < input.values.length; i++)
            SceneNode(
              id: 'node-$i',
              label: '${input.values[i]}',
              x: 40 + i * 112.0,
              y: 100,
              width: 80,
              height: 54,
              shape: NodeShape.linkedCell,
              memoryAddress: '0x${(0xa000 + i * 32).toRadixString(16)}',
              visualState: active?.args['index'] == '$i'
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
      ],
      edges: [
        if (input.kind == RecursionKind.traverse)
          for (var i = 0; i < input.values.length; i++)
            SceneEdge(
              id: 'next-$i',
              fromNodeId: 'node-$i',
              toNodeId: i + 1 < input.values.length
                  ? 'node-${i + 1}'
                  : nullNodeId,
              fromPort: EdgePort.next,
            ),
      ],
      pointers: [
        if (input.kind == RecursionKind.traverse && active != null)
          PointerBadge(
            id: 'p',
            label: 'p',
            targetNodeId: int.parse(active.args['index']!) < input.values.length
                ? 'node-${active.args['index']}'
                : nullNodeId,
          ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'status',
          title: '执行状态',
          columns: const ['调用次数', '移动次数', '结果', '输出序列'],
          rows: [
            ['$calls', '$moves', result, printed.join(' → ')],
          ],
        ),
        AuxTableSnapshot(
          id: 'return',
          title: '本帧返回事件',
          columns: const ['已弹出调用', '跳回地址', '返回值'],
          rows: [
            [returnId, returnTo, returnValue],
          ],
        ),
        if (input.kind == RecursionKind.hanoi)
          AuxTableSnapshot(
            id: 'pegs',
            title: '三柱（底 → 顶）',
            columns: const ['柱', '盘号'],
            rows: [
              for (final p in pegs.entries) [p.key, p.value.join(',')],
            ],
          ),
      ],
    );
  }

  void frame(
    String tag,
    String title,
    String explain, {
    int move = 0,
    int read = 0,
    int compare = 0,
    int space = 0,
    bool milestone = false,
  }) {
    final line = source.tags[tag]!;
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {
        if (stack.isNotEmpty) ...stack.last.args,
        if (stack.isNotEmpty) ...stack.last.locals,
      },
      scene: snapshot(),
      callStack: [for (final c in stack) c.record],
      deltaMove: move,
      deltaRead: read,
      deltaCompare: compare,
      deltaSpace: space,
      statementCounts: move > 0 ? {'move': move} : const {},
      milestone: milestone,
    );
    returnId = '';
    returnTo = '';
    returnValue = '';
  }

  _Call enter(String name, Map<String, String> args, String ret) {
    final c = _Call('call-${calls++}', name, args, ret, stack.lastOrNull?.id);
    c.locals['PC'] = '入口';
    stack.add(c);
    frame(
      'entry',
      '压栈 · $name',
      '新活动记录保存实参、局部和返回地址 $ret；此时栈深 ${stack.length}。',
      space: 1,
    );
    return c;
  }

  void finish(_Call c, String tag, {int? value}) {
    c.locals['PC'] = '准备返回';
    if (value != null) c.locals['return'] = '$value';
    frame(
      tag,
      '返回准备 · ${c.name}',
      value == null ? '执行完成，准备弹出当前活动记录。' : '本层结果 $value；尚未弹栈。',
    );
    stack.removeLast();
    returnId = c.id;
    returnTo = c.ret;
    returnValue = value == null ? 'void' : '$value';
    final parent = stack.lastOrNull;
    if (parent != null) {
      parent.locals['PC'] = c.ret;
      if (value != null) {
        parent.locals[c.ret == 'RetLoc1' ? 'a' : 'b'] = '$value';
      }
    } else {
      result = value == null
          ? (input.kind == RecursionKind.hanoi
                ? '$moves 次移动'
                : printed.join(' → '))
          : '$value';
    }
    frame(
      parent == null
          ? tag
          : c.ret == 'RetLoc1'
          ? 'ret1'
          : 'ret2',
      '弹栈 → ${c.ret}',
      parent == null
          ? '根调用返回 Main，活动栈为空。'
          : input.kind == RecursionKind.hanoi
          ? (c.ret == 'RetLoc1'
                ? '第一次递归已完成，恢复上层参数，接下来移动上层的大盘。'
                : '第二次递归已完成，恢复上层，接下来返回其调用者。')
          : '恢复上层记录并从 ${c.ret} 继续；子调用结果已写回上层局部。',
      space: -1,
      milestone: false,
    );
  }

  void moveDisk(_Call c, int disk, String from, String to, String tag) {
    c.locals['PC'] = 'move($from,$disk,$to)';
    frame(tag, '准备搬移盘 $disk', '从 $from 的栈顶取盘，目标为 $to；下一帧记录落柱后的状态。');
    if (pegs[from]!.last != disk ||
        (pegs[to]!.isNotEmpty && pegs[to]!.last < disk)) {
      throw StateError('Illegal Hanoi move');
    }
    pegs[from]!.removeLast();
    pegs[to]!.add(disk);
    moves++;
    frame(
      tag,
      '搬移 $moves · 盘 $disk：$from → $to',
      '仅移动柱顶圆盘；盘号越大尺寸越大，目标上方没有更小的盘。',
      move: 1,
      milestone: true,
    );
  }

  void hanoi(int n, String a, String b, String c, String ret) {
    final call = enter('Hanoi', {'n': '$n', 'A': a, 'B': b, 'C': c}, ret);
    call.locals['PC'] = '判断 n==1';
    frame(
      'check',
      '判断基例 n=$n',
      n == 1 ? '只需移动一个盘。' : '先把 n−1 个小盘从 A 搬到 B（借助 C）。',
      compare: 1,
    );
    if (n == 1) {
      moveDisk(call, 1, a, c, 'base');
      finish(call, 'baseReturn');
      return;
    }
    call.locals['PC'] = '等待 RetLoc1';
    frame('call1', '调用第一支', 'Hanoi(${n - 1}, $a, $c, $b)，子记录保存返回地址 RetLoc1。');
    hanoi(n - 1, a, c, b, 'RetLoc1');
    moveDisk(call, n, a, c, 'move');
    call.locals['PC'] = '等待 RetLoc2';
    frame('call2', '调用第二支', 'Hanoi(${n - 1}, $b, $a, $c)，子记录保存返回地址 RetLoc2。');
    hanoi(n - 1, b, a, c, 'RetLoc2');
    finish(call, 'return');
  }

  int number(int n, String ret) {
    final fib = input.kind == RecursionKind.fibonacci,
        call = enter(input.kind == RecursionKind.factorial ? 'Fact' : 'Fib', {
          'n': '$n',
        }, ret);
    final base = n <= (fib ? 2 : 1);
    call.locals['PC'] = '判断基例';
    frame(
      'check',
      '判断基例 n=$n',
      fib ? 'Fib(1)=Fib(2)=1；本课采用从 1 开始的编号。' : '0!=1，1!=1，其余返回 n×Fact(n−1)。',
      compare: 1,
    );
    if (base) {
      finish(call, 'check', value: 1);
      return 1;
    }
    call.locals['PC'] = '等待 RetLoc1';
    frame('call1', '递归求 a', '保存本层 n，进入 n−1 子问题。');
    final a = number(n - 1, 'RetLoc1');
    var value = n * a;
    if (fib) {
      call.locals['PC'] = '等待 RetLoc2';
      frame('call2', '递归求 b', 'a=$a 保留在本层，继续计算 Fib(n−2)，没有记忆化。');
      final b = number(n - 2, 'RetLoc2');
      value = a + b;
    }
    finish(call, 'return', value: value);
    return value;
  }

  void traverse(int i, String ret) {
    final c = enter('TraverseList', {
      'p': i < input.values.length
          ? '0x${(0xa000 + i * 32).toRadixString(16)}'
          : 'NULL',
      'index': '$i',
    }, ret);
    c.locals['PC'] = '判断 p';
    frame(
      'check',
      '检查 p 是否为 NULL',
      i == input.values.length ? '遇到链尾 NULL，停止递归。' : '先输出当前节点，再递归后继。',
      compare: 1,
    );
    if (i == input.values.length) {
      finish(c, 'check');
      return;
    }
    printed.add(input.values[i]);
    c.locals['PC'] = '输出 data';
    frame(
      'print',
      '输出 ${input.values[i]}',
      '输出序列按链表正向增长；返回阶段不重复输出。',
      read: 1,
      milestone: true,
    );
    c.locals['PC'] = '等待 RetLoc1';
    frame('call1', '递归到 next', '原 p 保留在上层活动记录中。', read: 1);
    traverse(i + 1, 'RetLoc1');
    finish(c, 'return');
  }

  switch (input.kind) {
    case RecursionKind.hanoi:
      hanoi(input.n, 'A', 'B', 'C', 'Main');
    case RecursionKind.factorial:
    case RecursionKind.fibonacci:
      number(input.n, 'Main');
    case RecursionKind.traverse:
      traverse(0, 'Main');
  }
  return builder.build();
}

/// Only the disk whose peg changes flies; metadata stays at the source frame.
/// The same function is sampled while seeking and playing in either direction.
SceneSnapshot interpolateHanoi(SceneSnapshot from, SceneSnapshot to, double t) {
  final next = {for (final n in to.nodes) n.id: n};
  return from.copyWith(
    nodes: [
      for (final n in from.nodes)
        if (next[n.id] case final SceneNode b when n.groupTag != b.groupTag)
          n.copyWith(
            x: n.x + (b.x - n.x) * t,
            y: n.y + (b.y - n.y) * t - 4 * ((n.y + b.y) / 2 - 36) * t * (1 - t),
            visualState: NodeVisualState.moving,
          )
        else
          n,
    ],
  );
}
