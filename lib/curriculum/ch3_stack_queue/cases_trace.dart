import '../../models/trace_model.dart';
import '../../engine/vm/trace_builder.dart';
import 'cases_expr_dance.dart';
import 'cases_source.dart';

class _Item {
  const _Item(this.id, this.label);
  final String id, label;
}

String caseNumber(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsPrecision(8);

TraceTimeline generateCasesTrace(CasesInput input) {
  final source = CasesSource(input.kind),
      builder = TraceBuilder(
        moduleId: const CasesExprDanceModule().id,
        inputSummary: input.raw,
        codeLines: source.lines,
      );
  final first = <_Item>[],
      second = <_Item>[],
      tray = <_Item>[],
      history = <List<String>>[],
      vars = <String, String>{};
  final tokens = input.kind == CaseKind.expression
      ? RegExp(
          r'[0-9]+|[^\s]',
        ).allMatches(input.text).map((m) => m[0]!).toList()
      : input.text.replaceAll(RegExp(r'\s'), '').split('');
  var status = '执行中',
      output = '',
      cursor = -1,
      top = '',
      relation = '',
      round = 0,
      serial = 0,
      previousSpace = 0;
  final active = <String>{};
  String getName() => switch (input.kind) {
    CaseKind.conversion => 'Convert',
    CaseKind.brackets => 'Match',
    CaseKind.expression => 'Evaluate',
    CaseKind.dance => 'Dance',
  };
  _Item item(String label) => _Item('item-${serial++}', label);
  final names = input.kind == CaseKind.expression
      ? ['OPTR', 'OPND']
      : input.kind == CaseKind.dance
      ? ['Mdancers', 'Fdancers']
      : ['S', '输出'];
  SceneSnapshot snapshot() {
    final nodes = <SceneNode>[];
    for (var k = 0; k < 2; k++) {
      final list = k == 0 ? first : second;
      for (var i = 0; i < list.length; i++) {
        final e = list[i];
        nodes.add(
          SceneNode(
            id: e.id,
            label:
                input.kind == CaseKind.expression &&
                    double.tryParse(e.label) != null
                ? caseNumber(double.parse(e.label))
                : e.label,
            x: 48 + (i % 6) * 88.0,
            y: 90 + k * 190 + (i ~/ 6) * 62.0,
            width: 76,
            height: 42,
            indexBadge: '[$i]',
            logicBadge: input.kind == CaseKind.dance
                ? (i == 0 ? '队首' : '')
                : i == list.length - 1
                ? '栈顶'
                : '',
            groupTag: names[k],
            visualState: active.contains(e.id)
                ? (status == '执行中' || status == 'OK'
                      ? NodeVisualState.active
                      : NodeVisualState.error)
                : NodeVisualState.normal,
          ),
        );
      }
    }
    for (var i = 0; i < tray.length; i++) {
      final e = tray[i];
      nodes.add(
        SceneNode(
          id: e.id,
          label: e.label,
          x: 48 + (i % 6) * 88.0,
          y: 470 + (i ~/ 6) * 62.0,
          width: 76,
          height: 42,
          groupTag: '取出/舞池',
          visualState: active.contains(e.id)
              ? (status == '执行中' || status == 'OK'
                    ? NodeVisualState.active
                    : NodeVisualState.error)
              : NodeVisualState.moving,
        ),
      );
    }
    return SceneSnapshot(
      nodes: nodes,
      pointers: [
        for (var k = 0; k < 2; k++)
          if ((k == 0 ? first : second).isNotEmpty)
            PointerBadge(
              id: 'pointer-$k',
              label: input.kind == CaseKind.dance
                  ? 'front · ${names[k]}'
                  : 'top · ${names[k]}',
              targetNodeId:
                  (input.kind == CaseKind.dance
                          ? (k == 0 ? first : second).first
                          : (k == 0 ? first : second).last)
                      .id,
              dy: -44,
            ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'case-status',
          title: '本步状态',
          columns: const ['状态', '输出', '当前输入', '比较栈顶', '优先关系', '曲目'],
          rows: [
            [
              status,
              output,
              cursor >= 0 && cursor < tokens.length ? tokens[cursor] : '',
              top,
              relation,
              '$round',
            ],
          ],
        ),
        AuxTableSnapshot(
          id: 'case-tokens',
          title: '输入（忽略空白）',
          columns: const ['位置', '符号'],
          rows: [
            for (var i = 0; i < tokens.length; i++) ['$i', tokens[i]],
          ],
          highlightedRows: cursor < 0 || cursor >= tokens.length
              ? <int>{}
              : {cursor},
        ),
        AuxTableSnapshot(
          id: 'case-first',
          title: names[0],
          columns: const ['ID', '值'],
          rows: [
            for (final e in first) [e.id, e.label],
          ],
        ),
        AuxTableSnapshot(
          id: 'case-second',
          title: names[1],
          columns: const ['ID', '值'],
          rows: [
            for (final e in second) [e.id, e.label],
          ],
        ),
        AuxTableSnapshot(
          id: 'case-history',
          title: '输出/配对记录',
          columns: const ['步骤/曲目', '结果'],
          rows: history,
        ),
      ],
    );
  }

  void frame(
    String tag,
    String title,
    String explain, {
    int write = 0,
    int read = 0,
    int compare = 0,
    bool milestone = false,
    bool error = false,
  }) {
    final space = first.length + second.length;
    final local = {
      ...vars,
      if (cursor >= 0 && cursor < tokens.length) 'ch': tokens[cursor],
      if (top.isNotEmpty) 'top': top,
      if (relation.isNotEmpty) 'relation': relation,
      if (round > 0) 'round': '$round',
    };
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [source.tags[tag]!],
      c99Lines: [source.tags[tag]!],
      dartLines: [source.tags[tag]!],
      vars: local,
      scene: snapshot(),
      callStack: [
        StackActivationRecord(
          id: 'case',
          functionName: getName(),
          arguments: {
            'input': input.kind == CaseKind.conversion
                ? '${input.number} / ${input.radix}'
                : input.kind == CaseKind.dance
                ? '${input.male.length} / ${input.female.length}'
                : input.text,
          },
          locals: local,
          returnLocation: '案例工作台',
        ),
      ],
      deltaWrite: write,
      deltaRead: read,
      deltaCompare: compare,
      deltaSpace: space - previousSpace,
      milestone: milestone,
      error: error,
    );
    previousSpace = space;
  }

  void fail(String tag, String message, {int compare = 0}) {
    status = message;
    frame(
      tag,
      message,
      '停止本次算法；可回退查看错误发生前的栈、输入与操作数。',
      compare: compare,
      error: true,
      milestone: true,
    );
  }

  void push(List<_Item> list, String value) {
    final e = item(value);
    list.add(e);
    active
      ..clear()
      ..add(e.id);
  }

  frame(
    'entry',
    '进入 ${getName()}',
    '${CasesExprDanceModule.kindNames[input.kind.index]}：每次栈或队列操作单独录制，可正倒放。',
  );
  switch (input.kind) {
    case CaseKind.conversion:
      var n = input.number;
      vars.addAll({'N': '$n', 'd': '${input.radix}'});
      frame('init', '初始化空栈与输出', '低位余数先入栈；最后弹出时得到高位在前的表示。');
      if (n == 0) {
        push(first, '0');
        frame('zero', '零的特例：压入 0', '零也必须输出一位 0。', write: 1, milestone: true);
      }
      while (n > 0) {
        frame('loop', '判断 N > 0', '当前 N=$n。', compare: 1);
        final r = n % input.radix;
        vars['r'] = '$r';
        push(first, '$r');
        frame(
          'push',
          '压入余数 $r',
          '$n % ${input.radix} = $r，先保存当前最低位。',
          write: 1,
          milestone: true,
        );
        n = n ~/ input.radix;
        vars['N'] = '$n';
        active.clear();
        frame('divide', 'N 整除进制', 'N=$n，继续提取更高位。', write: 1);
      }
      while (first.isNotEmpty) {
        final e = first.removeLast();
        tray
          ..clear()
          ..add(e);
        active
          ..clear()
          ..add(e.id);
        vars['r'] = e.label;
        frame('pop', '弹出余数 ${e.label}', '后入先出，依次读到最高位。', read: 1, write: 1);
        final digit = '0123456789ABCDEF'[int.parse(e.label)];
        output += digit;
        history.add(['${history.length + 1}', digit]);
        frame(
          'emit',
          '输出 $digit',
          '当前结果：$output。十六进制 10～15 显示 A～F。',
          write: 1,
          milestone: true,
        );
        tray.clear();
      }
      status = 'OK';
      frame(
        'done',
        '转换完成',
        '${input.number} 的 ${input.radix} 进制表示为 $output。',
        milestone: true,
      );
    case CaseKind.brackets:
      frame('init', '初始化空栈', '左括号入栈；右括号与最近尚未匹配的左括号配对。');
      var failed = false;
      for (cursor = 0; cursor < tokens.length; cursor++) {
        final ch = tokens[cursor];
        tray.clear();
        active.clear();
        frame('read', '读取 $ch', '扫描位置 $cursor（忽略空白）。', read: 1);
        if ('([{'.contains(ch)) {
          push(first, ch);
          frame(
            'push',
            '左括号 $ch 入栈',
            '后遇到的左括号必须先闭合。',
            write: 1,
            milestone: true,
          );
          continue;
        }
        if (first.isEmpty) {
          fail('right', '右括号冗余');
          failed = true;
          break;
        }
        final e = first.removeLast();
        tray.add(e);
        active.add(e.id);
        vars['left'] = e.label;
        frame('pop', '弹出 ${e.label}', '将栈顶与当前右括号 $ch 配对。', read: 1, write: 1);
        final match = '([{'.indexOf(e.label) == ')]}'.indexOf(ch);
        if (!match) {
          fail('match', '左右类型不符', compare: 1);
          failed = true;
          break;
        }
        history.add(['$cursor', '${e.label}$ch']);
        frame(
          'match',
          '配对成功',
          '${e.label} 与 $ch 类型相同。',
          compare: 1,
          milestone: true,
        );
      }
      if (!failed) {
        tray.clear();
        active
          ..clear()
          ..addAll(first.map((e) => e.id));
        if (first.isNotEmpty) {
          fail('left', '左括号冗余');
        } else {
          status = 'OK';
          output = '匹配成功';
          frame('done', '匹配成功', '扫描结束且栈为空。空括号串也匹配。', milestone: true);
        }
      }
    case CaseKind.expression:
      push(first, '#');
      cursor = 0;
      var need = true;
      vars['needOperand'] = 'true';
      frame(
        'init',
        '初始化 OPTR 与 OPND',
        'OPTR 先压入 #；OPND 为空。输入末尾 # 与栈底 # 共同终止求值。',
        write: 1,
      );
      while (true) {
        final ch = tokens[cursor];
        tray.clear();
        active.clear();
        top = '';
        relation = '';
        vars.removeWhere(
          (key, _) => ['a', 'b', 'theta', 'result'].contains(key),
        );
        frame('read', '读取 $ch', '输入位置 $cursor；归约时不推进输入。', read: 1);
        final number = double.tryParse(ch);
        if (number != null) {
          if (!need) {
            fail('number-check', '缺少运算符');
            break;
          }
          push(second, caseNumber(number));
          need = false;
          vars['needOperand'] = 'false';
          frame(
            'number',
            '操作数 $ch 入 OPND',
            '连续数字作为一个操作数。',
            write: 1,
            milestone: true,
          );
          cursor++;
          continue;
        }
        if ((ch == '(' && !need) || (ch != '(' && need)) {
          fail('syntax', '缺少操作数或运算符');
          break;
        }
        top = first.last.label;
        relation = OperatorPrecedence.compare(top, ch);
        active.add(first.last.id);
        frame(
          'compare',
          '查表 Precede($top, $ch) = $relation',
          '行是 OPTR 栈顶，列是当前输入；< 压栈，= 脱括号，> 归约。',
          compare: 1,
          milestone: true,
        );
        if (relation == '!') {
          fail('invalid', '括号不匹配');
          break;
        }
        if (top == '#' && ch == '#') {
          if (second.length != 1) {
            fail('accept', '缺少运算符');
            break;
          }
          status = 'OK';
          output = caseNumber(double.parse(second.single.label));
          active
            ..clear()
            ..add(second.single.id);
          frame(
            'accept',
            '求值完成：$output',
            '两个 # 相遇且 OPND 只剩一个值；结果为 $output。',
            milestone: true,
          );
          break;
        }
        if (relation == '<') {
          push(first, ch);
          need = true;
          vars['needOperand'] = 'true';
          frame(
            'push',
            '算符 $ch 入 OPTR',
            '当前算符优先级较高，保留在栈中等待右操作数。',
            write: 1,
            milestone: true,
          );
          cursor++;
          continue;
        }
        if (relation == '=') {
          final e = first.removeLast();
          tray.add(e);
          active
            ..clear()
            ..add(e.id);
          need = false;
          vars['needOperand'] = 'false';
          frame(
            'equal',
            '脱去一对圆括号',
            '弹出左括号，读入右括号之后的符号；括号本身不参与计算。',
            write: 1,
            read: 1,
            milestone: true,
          );
          cursor++;
          continue;
        }
        if (second.length < 2) {
          fail('operands', '缺少操作数');
          break;
        }
        final eb = second.removeLast();
        tray.add(eb);
        active
          ..clear()
          ..add(eb.id);
        vars['b'] = eb.label;
        frame(
          'pop-b',
          '① 弹出右操作数 b',
          '栈顶先弹出的是右操作数；减法、除法不能交换 a 与 b。',
          read: 1,
          write: 1,
        );
        final ea = second.removeLast();
        tray.add(ea);
        active
          ..clear()
          ..add(ea.id);
        vars['a'] = ea.label;
        frame(
          'pop-a',
          '② 弹出左操作数 a',
          'a=${ea.label}，b=${eb.label}。',
          read: 1,
          write: 1,
        );
        final et = first.removeLast();
        tray.add(et);
        active
          ..clear()
          ..add(et.id);
        vars['theta'] = et.label;
        frame(
          'pop-theta',
          '③ 弹出算符 theta',
          'theta=${et.label}；当前输入 $ch 保持不动。',
          read: 1,
          write: 1,
        );
        final a = double.parse(ea.label), b = double.parse(eb.label);
        if (et.label == '/' && b == 0) {
          fail('zero', '除数为零');
          break;
        }
        final result = switch (et.label) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          _ => a / b,
        };
        vars['result'] = caseNumber(result);
        frame(
          'compute',
          '④ Operate(a, theta, b)',
          '${ea.label} ${et.label} ${eb.label} = ${caseNumber(result)}。',
        );
        // Keep full double precision in the stack; formatting is a display concern.
        push(second, result.toString());
        history.add([
          '${history.length + 1}',
          '${ea.label} ${et.label} ${eb.label} = ${caseNumber(result)}',
        ]);
        frame(
          'result',
          '⑤ 结果压回 OPND',
          '继续用同一个输入 $ch 与新 OPTR 栈顶比较。',
          write: 1,
          milestone: true,
        );
      }
    case CaseKind.dance:
      first.addAll(input.male.map(item));
      second.addAll(input.female.map(item));
      frame('init', '建立男女两个 FIFO 队列', '每轮从两队队首配对；未配对者保持队首，已配对者曲终回到队尾。');
      for (round = 1; round <= input.rounds; round++) {
        tray.clear();
        active.clear();
        frame('round', '第 $round 曲开始', '按当前队序配对，上一曲等待者优先。', milestone: true);
        while (first.isNotEmpty && second.isNotEmpty) {
          final m = first.removeAt(0);
          tray.add(m);
          active
            ..clear()
            ..add(m.id);
          vars['male'] = m.label;
          frame(
            'male',
            '男队出队：${m.label}',
            '取男队队首，保留临时舞者等待另一队出队。',
            read: 1,
            write: 1,
          );
          final f = second.removeAt(0);
          tray.add(f);
          active
            ..clear()
            ..add(f.id);
          vars['female'] = f.label;
          frame(
            'female',
            '女队出队：${f.label}',
            '取女队队首；两端都有人才开始本次配对。',
            read: 1,
            write: 1,
          );
          active.add(m.id);
          history.add(['$round', '${m.label} + ${f.label}']);
          output = '${history.length} 对';
          frame(
            'pair',
            '配对：${m.label} + ${f.label}',
            '本曲舞池中的卡片保留到曲终。',
            milestone: true,
          );
        }
        active
          ..clear()
          ..addAll([
            if (first.isNotEmpty) first.first.id,
            if (second.isNotEmpty) second.first.id,
          ]);
        vars.remove('male');
        vars.remove('female');
        frame(
          'wait',
          '本曲配对结束 · 等待队首',
          '男队等待：${first.isEmpty ? '无' : first.first.label}；女队等待：${second.isEmpty ? '无' : second.first.label}。曲终回队时不插到他们前面。',
          milestone: true,
        );
        while (tray.isNotEmpty) {
          final m = tray.removeAt(0), f = tray.removeAt(0);
          first.add(m);
          second.add(f);
          active
            ..clear()
            ..add(m.id)
            ..add(f.id);
          frame(
            'return',
            '曲终回队：${m.label} / ${f.label}',
            '已配对者按配对顺序回到各自队尾，保持循环公平。',
            write: 2,
          );
        }
      }
      round = input.rounds;
      status = 'OK';
      active
        ..clear()
        ..addAll([
          if (first.isNotEmpty) first.first.id,
          if (second.isNotEmpty) second.first.id,
        ]);
      frame(
        'done',
        '$round 曲完成 · 下一曲队首',
        '男：${first.isEmpty ? '无人' : first.first.label}；女：${second.isEmpty ? '无人' : second.first.label}。',
        milestone: true,
      );
  }
  return builder.build();
}
