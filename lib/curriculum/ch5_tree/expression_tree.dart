part of 'huffman_expr.dart';

class _ExpNode {
  const _ExpNode(this.id, this.token, [this.left, this.right]);
  final String id, token;
  final _ExpNode? left, right;
}

TraceTimeline _expressionTrace(String raw) {
  final builder = TraceBuilder(
    moduleId: 'ch5_huffman_expr',
    inputSummary: raw,
    codeLines: _exprSource,
  );
  final optr = ['#'],
      expt = <_ExpNode>[],
      nodes = <_ExpNode>[],
      stack = <StackActivationRecord>[];
  final source = raw.replaceAll(RegExp(r'\s+'), '');
  final tokens = RegExp(
    r'\d+|.',
    unicode: true,
  ).allMatches(source).map((m) => m[0]!).toList();
  final order = <String>[];
  int cursor = 0;
  void frame(
    int line,
    String title,
    String explanation, {
    _ExpNode? active,
    bool error = false,
    Map<String, String> extra = const {},
  }) {
    final scene = TreeReingoldLayout.arrange(
      SceneSnapshot(
        nodes: [
          for (final n in nodes)
            SceneNode(
              id: n.id,
              label: n.token,
              indexBadge: n.id,
              x: 0,
              y: 0,
              width: 68,
              height: 48,
              visualState: n == active
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final n in nodes)
            for (final (c, right) in [(n.left, false), (n.right, true)])
              if (c != null)
                SceneEdge(
                  id: '${n.id}-${c.id}',
                  fromNodeId: n.id,
                  toNodeId: c.id,
                  fromPort: right ? EdgePort.rchild : EdgePort.lchild,
                ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'optr',
            title: 'OPTR · 算符栈',
            columns: const ['栈底 → 栈顶'],
            rows: [
              for (final op in optr) [op],
            ],
          ),
          AuxTableSnapshot(
            id: 'expt',
            title: 'EXPT · 子树根栈',
            columns: const ['结点', '根值'],
            rows: [
              for (final n in expt) [n.id, n.token],
            ],
          ),
        ],
      ),
    );
    builder.step(
      title: title,
      explain: explanation,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      scene: scene,
      callStack: stack,
      error: error,
      milestone: true,
      vars: {
        '当前输入': cursor < tokens.length ? tokens[cursor] : '结束',
        'OPTR': optr.join(' '),
        'EXPT': expt.map((n) => n.id).join(' '),
        '后序': order.join(' '),
        ...extra,
      },
    );
  }

  frame(1, '初始化两栈', 'OPTR 的栈底放 #。EXPT 保存已建成子树的根。');
  try {
    if (tokens.isEmpty ||
        tokens.last != '#' ||
        tokens.take(tokens.length - 1).contains('#')) {
      throw const FormatException('表达式末尾需要唯一的 #。');
    }
    bool needOperand = true;
    while (true) {
      final token = tokens[cursor];
      if (RegExp(r'^\d+$').hasMatch(token)) {
        if (!needOperand) throw const FormatException('相邻操作数之间缺少算符。');
        final n = _ExpNode('e${nodes.length + 1}', token);
        nodes.add(n);
        expt.add(n);
        frame(2, '叶子 $token 入 EXPT', '为操作数创建叶结点，并将根 ${n.id} 压入子树栈。', active: n);
        cursor++;
        needOperand = false;
        continue;
      }
      if (!OperatorPrecedence.operators.contains(token)) {
        throw FormatException('不支持的字符「$token」。');
      }
      if (needOperand != (token == '(')) {
        throw const FormatException('此处缺少操作数或算符。');
      }
      final top = optr.last, relation = OperatorPrecedence.compare(top, token);
      frame(
        3,
        '比较 $top 与 $token',
        '查教材表 3.1，栈顶与当前算符的关系为 $relation。',
        extra: {'关系': relation},
      );
      if (relation == '!') throw const FormatException('左右括号不匹配。');
      if (top == '#' && token == '#') break;
      if (relation == '<') {
        optr.add(token);
        frame(4, '算符 $token 入 OPTR', '等待右侧子树。');
        cursor++;
        needOperand = true;
      } else if (relation == '=') {
        optr.removeLast();
        frame(5, '括号配对', '配对括号出栈，子树根仍留在 EXPT。');
        cursor++;
        needOperand = false;
      } else {
        final op = optr.removeLast(),
            right = expt.removeLast(),
            left = expt.removeLast();
        final n = _ExpNode('e${nodes.length + 1}', op, left, right);
        nodes.add(n);
        expt.add(n);
        frame(
          6,
          '用 $op 连接两棵子树',
          '先弹出的 ${right.id} 为右子树，再弹出的 ${left.id} 为左子树。新根 ${n.id} 压回 EXPT。',
          active: n,
        );
      }
    }
    final root = expt.single;
    frame(7, '表达式树已建成', '两个 # 相遇，EXPT 中唯一的根为 ${root.id}。', active: root);
    BigInt evaluate(_ExpNode n) {
      stack.add(
        StackActivationRecord(
          id: n.id,
          functionName: 'EvaluateExpTree',
          arguments: {'T': n.id},
          returnLocation: stack.isEmpty ? '主程序' : stack.last.id,
          parentCallId: stack.lastOrNull?.id,
        ),
      );
      frame(8, '求值 ${n.id}', '先计算左右子树，再计算根。', active: n);
      late final BigInt value;
      if (n.left == null) {
        value = BigInt.parse(n.token);
      } else {
        final a = evaluate(n.left!), b = evaluate(n.right!);
        if (n.token == '/' && b == BigInt.zero) {
          throw const FormatException('除数为零，表达式没有数值结果。');
        }
        value = switch (n.token) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          '/' => a ~/ b,
          _ => throw StateError(n.token),
        };
      }
      order.add(n.token);
      frame(
        n.left == null ? 9 : 10,
        '${n.id} 返回 $value',
        n.left == null ? '操作数叶子返回自己的值。' : '左右子树的值按原操作数顺序参与整数运算。',
        active: n,
        extra: {'返回值': '$value'},
      );
      stack.removeLast();
      return value;
    }

    final value = evaluate(root);
    frame(11, '表达式值为 $value', '后序求值完成。', active: root, extra: {'结果': '$value'});
  } on FormatException catch (e) {
    frame(12, '表达式错误', e.message, error: true);
  }
  return builder.build();
}
