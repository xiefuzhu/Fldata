import '../../models/trace_model.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../engine/vm/memory_leaks.dart';
import 'linklist_source.dart';

enum LinkListOperation {
  init,
  get,
  locate,
  insert,
  delete,
  createHead,
  createTail,
}

class LinkListInput {
  const LinkListInput({
    this.operation = LinkListOperation.insert,
    this.values = const ['A', 'B', 'C', 'D'],
    this.position = 2,
    this.value = 'X',
    this.hasHead = true,
    this.wrongOrder = false,
  });
  final LinkListOperation operation;
  final List<String> values;
  final int position;
  final String value;
  final bool hasHead, wrongOrder;
  LinkListInput copyWith({
    LinkListOperation? operation,
    bool? hasHead,
    bool? wrongOrder,
  }) => LinkListInput(
    operation: operation ?? this.operation,
    values: values,
    position: position,
    value: value,
    hasHead: hasHead ?? this.hasHead,
    wrongOrder: wrongOrder ?? this.wrongOrder,
  );
}

class _Cell {
  _Cell(this.id, this.data, this.address, this.x, this.y);
  final String id, data, address;
  String next = nullNodeId;
  double x, y;
  bool deleted = false;
}

class LinkListModule implements AlgorithmModule<LinkListInput> {
  const LinkListModule();
  @override
  String get id => 'ch2_linklist_ops';
  static const names = [
    'InitList_L',
    'GetElem_L',
    'LocateElem_L',
    'ListInsert_L',
    'ListDelete_L',
    'CreateList_H',
    'CreateList_R',
  ];
  @override
  List<AlgorithmPreset<LinkListInput>> get presets => const [
    AlgorithmPreset(
      id: 'insert',
      name: '重建示例 · 在 B 前插入 X',
      input: LinkListInput(),
    ),
    AlgorithmPreset(
      id: 'first',
      name: '对比 · 首元前插入',
      input: LinkListInput(position: 1),
    ),
    AlgorithmPreset(
      id: 'delete',
      name: '对比 · 删除首元',
      input: LinkListInput(operation: LinkListOperation.delete, position: 1),
    ),
    AlgorithmPreset(
      id: 'head',
      name: '建表 · 前插 A B C D',
      input: LinkListInput(operation: LinkListOperation.createHead),
    ),
    AlgorithmPreset(
      id: 'tail',
      name: '建表 · 后插 A B C D',
      input: LinkListInput(operation: LinkListOperation.createTail),
    ),
    AlgorithmPreset(
      id: 'get',
      name: '正常 · 读取第 3 项',
      input: LinkListInput(operation: LinkListOperation.get, position: 3),
    ),
    AlgorithmPreset(
      id: 'locate',
      name: '正常 · 查找 C',
      input: LinkListInput(operation: LinkListOperation.locate, value: 'C'),
    ),
    AlgorithmPreset(
      id: 'wrong',
      name: '反例 · 误序断链与自环',
      input: LinkListInput(wrongOrder: true),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '边界 · 空表删除',
      input: LinkListInput(
        operation: LinkListOperation.delete,
        values: [],
        position: 1,
      ),
    ),
    AlgorithmPreset(
      id: 'bounds',
      name: '边界 · 插入 i=0',
      input: LinkListInput(position: 0),
    ),
  ];
  @override
  ValidationResult<LinkListInput> validateInput(String raw) {
    final p = raw.split('|').map((s) => s.trim()).toList();
    if (p.length != 6) {
      return const ValidationResult.failure('格式：操作|有头(1/0)|误序(1/0)|位序|值|元素');
    }
    final op = LinkListOperation.values
        .where((o) => o.name == p[0])
        .firstOrNull;
    final position = int.tryParse(p[3]);
    final values = p[5].isEmpty ? <String>[] : p[5].split(RegExp(r'[,，\s]+'));
    final char = RegExp(r'^[A-Za-z0-9]$');
    if (op == null ||
        !['0', '1'].contains(p[1]) ||
        !['0', '1'].contains(p[2]) ||
        position == null ||
        position < -1 ||
        position > 10 ||
        values.length > 8 ||
        !char.hasMatch(p[4]) ||
        values.any((v) => !char.hasMatch(v))) {
      return const ValidationResult.failure(
        '最多 8 个单字符元素（英文字母/数字）；位序 −1～10，可演示越界。',
      );
    }
    return ValidationResult.success(
      LinkListInput(
        operation: op,
        hasHead: p[1] == '1',
        wrongOrder: p[2] == '1',
        position: position,
        value: p[4],
        values: values,
      ),
    );
  }

  @override
  TraceTimeline generateTrace(LinkListInput input) {
    if (!validateInput(
      '${input.operation.name}|${input.hasHead ? 1 : 0}|${input.wrongOrder ? 1 : 0}|${input.position}|${input.value}|${input.values.join(',')}',
    ).isValid) {
      throw ArgumentError('Invalid linked list input');
    }
    final op = input.operation, name = names[op.index];
    final creating =
        op == LinkListOperation.init ||
        op == LinkListOperation.createHead ||
        op == LinkListOperation.createTail;
    final code = LinkListSource(input);
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary:
          '$name · ${input.hasHead ? '带头结点' : '无头结点'} · i=${input.position}${input.wrongOrder && op == LinkListOperation.insert ? ' · 误序反例' : ''}',
      codeLines: code.lines,
      trackLinkedOwnership: true,
    );
    final cells = <_Cell>[];
    final roots = <String, String>{'L': nullNodeId};
    final arguments = <String, String>{
      if (op == LinkListOperation.createHead ||
          op == LinkListOperation.createTail) ...{
        'a': input.values.join(', '),
        'n': '${input.values.length}',
      },
      if (!creating && op != LinkListOperation.locate) 'i': '${input.position}',
      if (op == LinkListOperation.insert || op == LinkListOperation.locate)
        'e': input.value,
    };
    final vars = Map<String, String>.of(arguments);
    String result = '待执行';
    String? output;
    _Cell cell(String id) => cells.firstWhere((c) => c.id == id);
    String next(String id) => id == nullNodeId ? nullNodeId : cell(id).next;
    _Cell allocate(String id, String data, {double? x, double y = 145}) {
      final c = _Cell(
        id,
        data,
        '0x${(0x5000 + cells.length * 48).toRadixString(16)}',
        x ?? (40 + cells.length * 112.0),
        y,
      );
      cells.add(c);
      return c;
    }

    List<String> chain() {
      final order = <String>[], seen = <String>{};
      var p = roots['L']!;
      while (p != nullNodeId && seen.add(p) && !cell(p).deleted) {
        order.add(p);
        p = next(p);
      }
      return order;
    }

    void arrange() {
      final order = chain();
      for (var k = 0; k < order.length; k++) {
        cell(order[k]).x = 40 + k * 112.0;
        cell(order[k]).y = 145;
      }
    }

    String address(String id) => id == nullNodeId ? 'NULL' : cell(id).address;
    SceneSnapshot snapshot() {
      final order = chain();
      final scene = SceneSnapshot(
        nodes: [
          for (final c in cells)
            SceneNode(
              id: c.id,
              label: c.id == 'head' ? '头' : c.data,
              x: c.x,
              y: c.y,
              width: 80,
              height: 52,
              shape: NodeShape.linkedCell,
              memoryAddress: c.address,
              logicBadge: c.deleted
                  ? '已释放'
                  : c.id == 'head'
                  ? '非数据结点'
                  : order.contains(c.id)
                  ? '位序 ${order.indexOf(c.id) + (input.hasHead ? 0 : 1)}'
                  : '待接入',
              visualState: c.id == 'head'
                  ? NodeVisualState.sentinel
                  : roots.values.contains(c.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
              isDeleted: c.deleted,
              opacity: c.deleted ? .2 : 1,
            ),
        ],
        edges: [
          for (final c in cells.where((c) => !c.deleted))
            SceneEdge(
              id: 'next-${c.id}',
              fromNodeId: c.id,
              toNodeId: c.next,
              fromPort: EdgePort.next,
              visualState: c.next == c.id
                  ? NodeVisualState.error
                  : roots['s'] == c.id
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
              curvature: c.next == c.id
                  ? 90
                  : roots['s'] == c.id && c.next != nullNodeId
                  ? -60
                  : c.next != nullNodeId && cell(c.next).x < c.x
                  ? -65
                  : 0,
            ),
        ],
        pointers: [
          for (final entry in roots.entries)
            PointerBadge(
              id: entry.key,
              label: entry.key,
              targetNodeId: entry.value,
              dy: -32 - roots.keys.toList().indexOf(entry.key) * 22.0,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'list-state',
            title: '根指针与逻辑链',
            columns: const ['L', '数据链', '返回', '输出 e'],
            rows: [
              [
                address(roots['L']!),
                order
                    .where((id) => id != 'head')
                    .map((id) => cell(id).data)
                    .join(' → '),
                result,
                output ?? '—',
              ],
            ],
          ),
          AuxTableSnapshot(
            id: 'heap',
            title: '模拟堆（next 为地址）',
            columns: const ['ID', '地址', 'data', 'next', '存活'],
            rows: [
              for (final c in cells)
                [
                  c.id,
                  c.address,
                  c.id == 'head' ? '—' : c.data,
                  address(c.next),
                  c.deleted ? '已释放' : '是',
                ],
            ],
          ),
        ],
      );
      final lost = detectMemoryLeaks(scene);
      return scene.copyWith(
        nodes: [
          for (final n in scene.nodes)
            lost.contains(n.id) ? n.copyWith(logicBadge: '失联') : n,
        ],
        zones: [
          for (final n in scene.nodes.where((n) => lost.contains(n.id)))
            SceneZoneOverlay(
              id: 'leak-${n.id}',
              label: '失联',
              x: n.x - 5,
              y: n.y - 5,
              width: n.width + 10,
              height: n.height + 10,
              visualState: NodeVisualState.error,
              pattern: ZonePattern.dashed,
            ),
        ],
      );
    }

    void record(
      String tag,
      String title,
      String explain, {
      bool error = false,
      bool milestone = false,
      int reads = 0,
      int writes = 0,
      int allocations = 0,
      int comparisons = 0,
    }) {
      final line = code.tags[tag]!;
      builder.step(
        title: title,
        explain: explain,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: {
          ...vars,
          ...roots.map((k, v) => MapEntry(k, address(v))),
          'result': result,
          'out': ?output,
        },
        scene: snapshot(),
        error: error,
        milestone: milestone,
        deltaRead: reads,
        deltaWrite: writes,
        deltaAllocate: allocations,
        deltaCompare: comparisons,
        callStack: [
          StackActivationRecord(
            id: 'linked-call',
            functionName: name,
            arguments: arguments,
            locals: {...vars, ...roots.map((k, v) => MapEntry(k, address(v)))},
            returnLocation: 'Main',
          ),
        ],
      );
    }

    if (!creating) {
      if (input.hasHead) {
        roots['L'] = allocate('head', '').id;
      }
      for (var k = 0; k < input.values.length; k++) {
        final c = allocate('node-$k', input.values[k]);
        if (cells.length == 1) {
          roots['L'] = c.id;
        } else {
          cells[cells.length - 2].next = c.id;
        }
      }
    }
    record(
      'entry',
      '准备 $name',
      creating
          ? '即将初始化新表，当前 L=NULL；建表输入按给定顺序读取。'
          : input.hasHead
          ? 'L 指向不存数据的头结点；首元为 L->next。'
          : 'L 直接指向首元；空表时 L=NULL。',
      milestone: true,
    );
    if (creating) {
      if (input.hasHead) {
        roots['L'] = allocate('head', '').id;
      }
      record(
        'init',
        '初始化空链',
        input.hasHead ? '分配头结点并令 next=NULL。' : '无头结点空表只需令 L=NULL，不分配结点。',
        allocations: input.hasHead ? 1 : 0,
        writes: 1,
      );
      if (op != LinkListOperation.init) {
        if (op == LinkListOperation.createTail) {
          roots['r'] = roots['L']!;
          record('tail', 'r 指向当前尾部', '带头结点时 r 初始为头结点；无头空表时 r=NULL。');
        }
        for (var k = 0; k < input.values.length; k++) {
          vars['k'] = '$k';
          final s = allocate(
            'node-$k',
            input.values[k],
            x: 40 + (k + (input.hasHead ? 1 : 0)) * 112.0,
            y: 300,
          );
          roots['s'] = s.id;
          record(
            'allocate',
            '分配 ${s.data}',
            '新结点由 s 持有，data 已写入，next 初始为 NULL。',
            allocations: 1,
          );
          if (op == LinkListOperation.createHead) {
            s.next = input.hasHead ? next(roots['L']!) : roots['L']!;
            record('first', '① 新结点连接原首元', '先保存后续链，避免覆盖入口。', writes: 1);
            if (input.hasHead) {
              cell(roots['L']!).next = s.id;
            } else {
              roots['L'] = s.id;
            }
            arrange();
            record('second', '② 更新首元入口', '每次插在表头之后，最终次序与输入相反。', writes: 1);
          } else {
            if (roots['r'] == nullNodeId) {
              roots['L'] = s.id;
            } else {
              cell(roots['r']!).next = s.id;
            }
            arrange();
            record(
              'append',
              '① 尾结点 next = s',
              '无头空表首个结点需更新 L；否则从尾部接入。',
              writes: 1,
            );
            roots['r'] = s.id;
            record('advanceTail', '② r = s', '尾指针跟进，保持输入次序。');
          }
          roots.remove('s');
        }
        vars.remove('k');
        roots.remove('r');
      }
      result = 'OK';
      record(
        'return',
        '$name 完成',
        '${chain().where((id) => id != 'head').map((id) => cell(id).data).join(' → ')}${input.values.isEmpty || op == LinkListOperation.init ? '空表' : ''}；可回退观察每次接链。',
        milestone: true,
      );
      return builder.build();
    }
    if (op == LinkListOperation.get || op == LinkListOperation.locate) {
      roots['p'] = input.hasHead ? next(roots['L']!) : roots['L']!;
      var j = 1;
      if (op == LinkListOperation.get) {
        vars['j'] = '1';
      }
      record('cursor', 'p 指向首元', '不能通过地址偏移直接读取第 i 项，必须沿 next 寻址。');
      while (roots['p'] != nullNodeId) {
        if (op == LinkListOperation.get) {
          if (j >= input.position) break;
        } else {
          final matched = cell(roots['p']!).data == input.value;
          record(
            'compare',
            '比较 ${cell(roots['p']!).data} 与 ${input.value}',
            matched ? '首次命中。' : '不匹配，继续沿 next。',
            reads: 1,
            comparisons: 1,
          );
          if (matched) {
            result = address(roots['p']!);
            record(
              'found',
              '返回首个匹配结点',
              'LocateElem_L 返回结点指针；不是物理下标。',
              milestone: true,
            );
            return builder.build();
          }
        }
        roots['p'] = next(roots['p']!);
        j++;
        if (op == LinkListOperation.get) {
          vars['j'] = '$j';
        }
        record('walk', 'p = p->next', '沿一条 next 边前进。', reads: 1);
      }
      if (op == LinkListOperation.locate) {
        result = 'NULL';
        record('missing', '未找到，返回 NULL', '遍历完毕或输入为空。', milestone: true);
      } else if (input.position < 1 || roots['p'] == nullNodeId) {
        result = 'ERROR';
        record(
          'bounds',
          'ERROR · 位序越界',
          '有效位序为 1～元素个数；空表无合法读取位序。',
          error: true,
        );
      } else {
        output = cell(roots['p']!).data;
        record('read', '读取 p->data', '找到第 $j 项，输出 e=$output。', reads: 1);
        result = 'OK';
        record('return', '读取完成', '按位序查找时间 O(n)，辅助空间 O(1)。', milestone: true);
      }
      return builder.build();
    }
    final rootCase = !input.hasHead && input.position == 1;
    roots['p'] = rootCase ? nullNodeId : roots['L']!;
    var j = input.hasHead ? 0 : 1;
    vars['j'] = '$j';
    record(
      'cursor',
      rootCase ? '首元特例 · 修改 L' : '从 L 寻找前驱',
      rootCase
          ? '无头结点的 i=1 不能使用前驱 p->next，必须单独更新 L。'
          : '带头结点时 p 从 L、j=0 出发，首元操作也统一处理。',
    );
    while (!rootCase && roots['p'] != nullNodeId && j < input.position - 1) {
      roots['p'] = next(roots['p']!);
      j++;
      vars['j'] = '$j';
      record('walk', '寻找前驱 · p = p->next', '前驱位序目标为 i−1。', reads: 1);
    }
    final invalid =
        input.position < 1 ||
        (!rootCase && (roots['p'] == nullNodeId || j > input.position - 1));
    final successor = rootCase ? roots['L']! : next(roots['p']!);
    if (invalid ||
        (op == LinkListOperation.delete && successor == nullNodeId)) {
      result = 'ERROR';
      record(
        'bounds',
        'ERROR · 位序越界',
        '插入范围 1～n+1，删除范围 1～n。未修改任何 next。',
        error: true,
      );
      return builder.build();
    }
    record('bounds', '前驱定位成功', '接下来只修改局部链接；定位前驱本身仍需 O(n)。');
    if (op == LinkListOperation.insert) {
      final s = allocate(
        'new',
        input.value,
        x: rootCase ? 40 : cell(roots['p']!).x + 56,
        y: 300,
      );
      roots['s'] = s.id;
      record(
        'allocate',
        '分配新结点 s',
        'data=${input.value}，next=NULL；s 保持分配对象可达。',
        allocations: 1,
      );
      void linkEntry() {
        if (rootCase) {
          roots['L'] = s.id;
        } else {
          cell(roots['p']!).next = s.id;
        }
      }

      if (input.wrongOrder) {
        linkEntry();
        final lost = detectMemoryLeaks(snapshot()).length;
        result = '错误反例';
        record(
          'second',
          '错误① · 先覆盖入口',
          lost > 0
              ? '严重错误：${rootCase ? 'L' : 'p->next'} 已被覆盖，原后续链表永久失联导致内存泄漏，下一步 s->next = ${rootCase ? 'L' : 'p->next'} 将形成自环！失联 $lost 个结点。'
              : '尾后插入没有后续结点可丢失，但下一步仍会把 s->next 指向 s 自身。',
          error: true,
          writes: 1,
          milestone: true,
        );
        s.next = rootCase ? roots['L']! : next(roots['p']!);
        record(
          'first',
          '错误② · s->next 指向自身',
          '形成 s→s 自环。错误帧自动暂停，可单步继续或倒放恢复原入口；普通遍历会陷入死循环。',
          error: true,
          writes: 1,
          milestone: true,
        );
        return builder.build();
      }
      s.next = successor;
      record(
        'first',
        '① s->next = 原后继',
        '先连接后半段，所有分配对象仍可从 L 或 s 到达。',
        writes: 1,
      );
      linkEntry();
      record(
        'second',
        rootCase ? '② L = s' : '② p->next = s',
        '再更新入口；两步顺序不可颠倒。',
        writes: 1,
      );
      roots.remove('s');
    } else {
      roots['q'] = successor;
      record('save', 'q 保存待删结点', '先保留 q，断开后仍可访问 data 并释放，避免泄漏。');
      if (rootCase) {
        roots['L'] = next(successor);
      } else {
        cell(roots['p']!).next = next(successor);
      }
      record(
        'unlink',
        rootCase ? 'L = q->next' : 'p->next = q->next',
        '将链跨过 q；q 指针仍持有被移出的结点。',
        writes: 1,
      );
      output = cell(successor).data;
      record('read', '输出被删除值', 'e=q->data=$output。', reads: 1);
      cell(successor).deleted = true;
      roots.remove('q');
      record('free', '释放 q', 'C99 free(q) 后不得解引用；Dart 解除引用由 GC 回收，不保证立刻回收。');
    }
    roots.remove('p');
    vars.remove('j');
    arrange();
    result = 'OK';
    record(
      'return',
      '$name 完成',
      '链表顺序由 next 决定，不要求地址连续；辅助空间 O(1)。',
      milestone: true,
    );
    return builder.build();
  }
}
