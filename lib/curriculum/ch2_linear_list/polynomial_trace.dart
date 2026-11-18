import '../../models/trace_model.dart';
import '../../engine/vm/trace_builder.dart';
import 'cases_polyn_book.dart';
import 'cases_source.dart';

class _PolyCell {
  _PolyCell(
    this.id,
    this.coef,
    this.exp,
    this.address,
    this.x,
    this.y, {
    this.head = false,
  });
  final String id, address;
  double coef, x, y;
  final int exp;
  final bool head;
  String next = nullNodeId;
  bool deleted = false;
}

String polynomialText(Iterable<PolyTerm> terms) {
  final items = terms.toList();
  if (items.isEmpty) return '0';
  final out = StringBuffer();
  for (final t in items) {
    final negative = t.coefficient < 0, c = t.coefficient.abs();
    if (out.isNotEmpty) {
      out.write(negative ? ' − ' : ' + ');
    } else if (negative) {
      out.write('−');
    }
    if (t.exponent == 0 || c != 1) out.write(numberText(c));
    if (t.exponent > 0) {
      out.write('x');
      if (t.exponent > 1) out.write('^${t.exponent}');
    }
  }
  return out.toString();
}

TraceTimeline generatePolynomialTrace(CasesInput input) {
  final create = input.operation == CaseOperation.create,
      source = polynomialSource(input.operation == CaseOperation.create);
  final builder = TraceBuilder(
    moduleId: 'ch2_cases_polyn_book',
    inputSummary:
        '${CasesPolynBookModule.names[input.operation.index]} · ${polynomialText(input.a)}',
    codeLines: source.lines,
    trackLinkedOwnership: true,
  );
  final cells = <_PolyCell>[],
      roots = <String, String>{},
      vars = <String, String>{},
      accepted = <String>[];
  var changed = '', status = '待执行';
  _PolyCell cell(String id) => cells.firstWhere((c) => c.id == id);
  String addr(String id) => id == nullNodeId ? 'NULL' : cell(id).address;
  _PolyCell allocate(String id, PolyTerm? term, double x, double y) {
    final c = _PolyCell(
      id,
      term?.coefficient ?? 0,
      term?.exponent ?? -1,
      '0x${(0xb000 + cells.length * 48).toRadixString(16)}',
      x,
      y,
      head: term == null,
    );
    cells.add(c);
    return c;
  }

  void list(String prefix, List<PolyTerm> data, double y) {
    final chain = [
      allocate('$prefix-head', null, 32, y),
      for (var i = 0; i < data.length; i++)
        allocate('$prefix-$i', data[i], 32 + (i + 1) * 130.0, y),
    ];
    for (var i = 0; i < chain.length - 1; i++) {
      chain[i].next = chain[i + 1].id;
    }
  }

  if (!create) {
    list('a', input.a, 125);
    list('b', input.b, 315);
    roots.addAll({'PA': 'a-head', 'PB': 'b-head'});
  }
  List<String> walk(String head) {
    final out = <String>[], seen = <String>{};
    var p = cell(head).next;
    while (p != nullNodeId && seen.add(p) && !cell(p).deleted) {
      out.add(p);
      p = cell(p).next;
    }
    return out;
  }

  String text(Iterable<String> ids) =>
      polynomialText(ids.map((id) => PolyTerm(cell(id).coef, cell(id).exp)));
  void place(Iterable<String> ids) {
    cell('a-head').x = 32;
    cell('a-head').y = 515;
    var i = 1;
    for (final id in ids) {
      cell(id).x = 32 + i++ * 130.0;
      cell(id).y = 515;
    }
  }

  SceneSnapshot snapshot() {
    final dangling = cells
        .where(
          (c) => !c.deleted && c.next != nullNodeId && cell(c.next).deleted,
        )
        .length;
    final terms = create && cells.isNotEmpty ? walk('a-head') : accepted;
    final maxExp = input.a.isEmpty
            ? 0
            : input.a.map((t) => t.exponent).reduce((a, b) => a > b ? a : b),
        slots = input.a.isEmpty ? 0 : maxExp + 1;
    return SceneSnapshot(
      nodes: [
        for (final c in cells)
          SceneNode(
            id: c.id,
            label: c.head
                ? (c.id == 'a-head' ? 'HA' : 'HB')
                : '${numberText(c.coef)}\nx^${c.exp}',
            x: c.x,
            y: c.y,
            width: 96,
            height: 64,
            shape: NodeShape.linkedCell,
            memoryAddress: c.address,
            indexBadge: c.head ? null : 'exp=${c.exp}',
            logicBadge: c.deleted
                ? '已释放'
                : c.head
                ? '头结点'
                : c.id.startsWith('a')
                ? '来自 A'
                : '来自 B',
            isDeleted: c.deleted,
            opacity: c.deleted ? .2 : 1,
            visualState: c.head
                ? NodeVisualState.sentinel
                : roots.values.contains(c.id)
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
      ],
      edges: [
        for (final c in cells.where((c) => !c.deleted))
          SceneEdge(
            id: '${c.id}-next',
            fromNodeId: c.id,
            toNodeId: c.next,
            fromPort: EdgePort.next,
            curvature:
                c.next != nullNodeId &&
                    (cell(c.next).y != c.y ||
                        (cell(c.next).x - c.x).abs() > 145)
                ? 70
                : 0,
            visualState: c.next != nullNodeId && cell(c.next).deleted
                ? NodeVisualState.error
                : changed == c.id
                ? NodeVisualState.active
                : NodeVisualState.normal,
            weightLabel: changed == c.id ? 'next' : null,
          ),
      ],
      pointers: [
        for (final e in roots.entries)
          PointerBadge(
            id: e.key,
            label: e.key,
            targetNodeId: e.value,
            dy:
                -48 -
                roots.keys
                        .where((key) => roots[key] == e.value)
                        .toList()
                        .indexOf(e.key) *
                    22.0,
          ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'result',
          title: '多项式状态',
          columns: const ['状态', '已确定结果', '释放数据节点', '暂存悬空 next'],
          rows: [
            [
              status,
              text(terms),
              '${cells.where((c) => c.deleted && !c.head).length}',
              '$dangling',
            ],
          ],
        ),
        AuxTableSnapshot(
          id: 'density',
          title: 'A 的稠密与稀疏表示',
          columns: const ['稠密系数槽', '非零项', '零系数槽'],
          rows: [
            ['$slots', '${input.a.length}', '${slots - input.a.length}'],
          ],
        ),
        AuxTableSnapshot(
          id: 'dense',
          title: 'A 的稠密系数数组（指数为下标）',
          columns: const ['指数', '系数'],
          rows: [
            for (var e = 0; e < slots; e++)
              [
                '$e',
                numberText(
                  input.a
                          .where((t) => t.exponent == e)
                          .firstOrNull
                          ?.coefficient ??
                      0,
                ),
              ],
          ],
        ),
        AuxTableSnapshot(
          id: 'heap',
          title: '稀疏链节点（模拟地址）',
          columns: const ['ID', '地址', 'coef', 'expn', 'next'],
          rows: [
            for (final c in cells)
              [
                c.id,
                c.address,
                numberText(c.coef),
                '${c.exp}',
                c.deleted ? '已释放' : addr(c.next),
              ],
          ],
        ),
      ],
    );
  }

  void frame(
    String tag,
    String title,
    String explain, {
    int compare = 0,
    int read = 0,
    int write = 0,
    int allocate = 0,
    bool milestone = false,
  }) {
    final line = source.tags[tag]!;
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {...vars, for (final e in roots.entries) e.key: addr(e.value)},
      scene: snapshot(),
      callStack: [
        StackActivationRecord(
          id: 'poly',
          functionName: create ? 'CreatePolyn' : 'AddPolyn',
          arguments: {
            'A': polynomialText(input.a),
            if (!create) 'B': polynomialText(input.b),
          },
          locals: {
            ...vars,
            for (final e in roots.entries) e.key: addr(e.value),
          },
          returnLocation: '调用方',
        ),
      ],
      deltaCompare: compare,
      deltaRead: read,
      deltaWrite: write,
      deltaAllocate: allocate,
      milestone: milestone,
    );
  }

  frame(
    'entry',
    create ? '进入 · CreatePolyn' : '进入 · AddPolyn',
    create
        ? '按用户给出的次序逐项插入；输出按指数升序。指数唯一且系数非零。'
        : 'PA/PB 均按指数升序。输入链由本操作消费，输出继续使用 PA 的头结点。',
  );
  status = '执行中';
  if (create) {
    allocate('a-head', null, 32, 515);
    roots['H'] = 'a-head';
    frame('head', '分配头结点 H', '头结点不存储多项式项。', allocate: 1);
    for (var k = 0; k < input.a.length; k++) {
      final id = 'a-$k', term = input.a[k];
      allocate(id, term, 162, 280);
      roots['s'] = id;
      vars['k'] = '$k';
      frame(
        'new',
        '新项 · ${term.label}',
        's 持有待插入节点，未接链时不会误判为内存泄漏。',
        allocate: 1,
        read: 1,
      );
      var p = 'a-head', q = cell(p).next;
      roots.addAll({'p': p, 'q': q});
      frame('seek', '寻找指数插入位置', 'p 为前驱，q 为候选后继。', read: 1);
      while (q != nullNodeId) {
        final before = cell(q).exp < term.exponent;
        frame(
          'compare',
          '比较指数 · ${cell(q).exp} < ${term.exponent}',
          before ? '继续向后寻找。' : '在 q 前插入。',
          compare: 1,
          read: 1,
        );
        if (!before) break;
        p = q;
        q = cell(q).next;
        roots.addAll({'p': p, 'q': q});
        frame('walk', '前进 p / q', '沿 next 移动，已建部分仍保持指数有序。', read: 1);
      }
      cell(id).next = q;
      changed = id;
      frame(
        'snext',
        '先接后继 · s->next = q',
        '先保存原后继，避免断开已建链。',
        write: 1,
        milestone: true,
      );
      cell(p).next = id;
      changed = p;
      place(walk('a-head'));
      frame(
        'pnext',
        '再接前驱 · p->next = s',
        '新项进入升序链；已有节点地址不变。',
        write: 1,
        milestone: true,
      );
      changed = '';
      roots.remove('s');
      roots.remove('p');
      roots.remove('q');
    }
    vars.clear();
    status = '完成';
    frame(
      'return',
      '返回升序多项式',
      '逐项有序插入最坏 O(n²)，保存 n 个非零项与一个头结点。',
      milestone: true,
    );
  } else {
    roots.addAll({
      'p1': cell('a-head').next,
      'p2': cell('b-head').next,
      'p3': 'a-head',
    });
    place([]);
    frame('init', '初始化 p1 / p2 / p3', 'p1/p2 是候选，p3 为已确定结果的尾部。', read: 2);
    void take(String key, String tag) {
      final id = roots[key]!, tail = roots['p3']!;
      cell(tail).next = id;
      changed = tail;
      accepted.add(id);
      place(accepted);
      frame(
        tag,
        '接入 · ${cell(id).exp} 次项',
        'p3.next 指向候选，复用节点。',
        write: 1,
        milestone: true,
      );
      changed = '';
      roots['p3'] = id;
      roots[key] = cell(id).next;
      frame(tag, '前进 · $key 与 p3', '沿原后继保留未处理链。', read: 1);
    }

    void release(String key, String saveTag, String freeTag, bool zero) {
      final id = roots[key]!;
      roots['r'] = id;
      roots[key] = cell(id).next;
      frame(saveTag, '保存后继 · $key', '先让 $key 前进，再释放 r 指向的旧节点。', read: 1);
      cell(id).deleted = true;
      roots.remove('r');
      frame(
        freeTag,
        zero ? '同指数相消 · 释放 ${key == 'p1' ? 'A' : 'B'} 节点' : '合并系数 · 释放 B 冗余节点',
        zero
            ? 'sum == 0，两个同指数节点都不进入结果；本帧释放 $id。'
            : '该指数的系数已写回 A 节点，B 的同指数节点可释放。',
        milestone: true,
      );
    }

    while (roots['p1'] != nullNodeId && roots['p2'] != nullNodeId) {
      final x = cell(roots['p1']!), y = cell(roots['p2']!);
      vars.remove('sum');
      frame(
        'compare',
        '比较指数 · ${x.exp} 与 ${y.exp}',
        '先判断 A 指数是否更小。',
        compare: 1,
        read: 2,
      );
      if (x.exp < y.exp) {
        take('p1', 'takeA');
        continue;
      }
      frame(
        'greater',
        '比较指数 · ${x.exp} > ${y.exp}',
        x.exp > y.exp ? '取 B 的较低次项。' : '指数相等，合并系数。',
        compare: 1,
      );
      if (x.exp > y.exp) {
        take('p2', 'takeB');
        continue;
      }
      final sum = x.coef + y.coef;
      vars['sum'] = numberText(sum);
      frame(
        'sum',
        '系数相加 · ${numberText(x.coef)} + (${numberText(y.coef)})',
        '同指数合并：sum = ${numberText(sum)}。',
        read: 2,
      );
      frame(
        'nonzero',
        sum == 0 ? 'sum == 0 · 两项均需删除' : 'sum != 0 · 保留 A 节点',
        sum == 0 ? '不能在稀疏结果中保留零系数占位项。' : '结果系数写回 A 节点，只释放 B 同指数节点。',
        compare: 1,
      );
      if (sum != 0) {
        x.coef = sum;
        frame(
          'write',
          '写回系数 · ${numberText(sum)}',
          '只修改 A 的 coef，expn 与地址保持。',
          write: 1,
        );
        take('p1', 'keep');
      } else {
        release('p1', 'saveA', 'freeA', true);
      }
      release('p2', 'saveB', 'freeB', sum == 0);
    }
    final rest = roots['p1'] != nullNodeId ? roots['p1']! : roots['p2']!;
    changed = roots['p3']!;
    cell(changed).next = rest;
    var p = rest;
    while (p != nullNodeId) {
      accepted.add(p);
      p = cell(p).next;
    }
    place(accepted);
    frame(
      'tail',
      '挂接剩余链',
      '一次 next 写入连接剩余项；临时指向已释放项的结果边也在这里或此前接链时覆盖。',
      write: 1,
      milestone: true,
    );
    changed = '';
    cell('b-head').deleted = true;
    roots.remove('PB');
    frame(
      'freeHead',
      '释放 PB 头结点',
      '数据节点已复用或释放；不再把 PB 作为独立多项式。',
      milestone: true,
    );
    roots
      ..clear()
      ..addAll({'PA': 'a-head'});
    vars.clear();
    status = '完成';
    frame(
      'return',
      '返回相加结果',
      '结果指数严格升序且无零系数。时间 O(m+n)，固定指针辅助空间 O(1)。快照与排布不计入算法成本。',
      milestone: true,
    );
  }
  return builder.build();
}
