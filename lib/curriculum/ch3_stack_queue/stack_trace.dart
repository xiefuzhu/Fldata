import '../../models/trace_model.dart';
import '../../engine/vm/trace_builder.dart';
import '../../engine/layout/linear_memory_layout.dart';
import 'stack_sq_link.dart';
import 'stack_source.dart';

class _StackNode {
  _StackNode(this.id, this.value, this.address, this.x, this.y);
  final String id, address;
  final int value;
  String next = nullNodeId;
  double x, y;
  bool deleted = false;
}

TraceTimeline generateStackTrace(StackInput input) {
  final kind = input.kind,
      op = input.operation,
      init = op == StackOperation.init,
      push = op == StackOperation.push,
      pop = op == StackOperation.pop,
      linked = kind == StackKind.linked,
      shared = kind == StackKind.shared;
  final source = StackSource(kind, op),
      cells = <_StackNode>[],
      roots = <String, String>{};
  final values = List<int?>.filled(input.capacity, null);
  final a = init ? <int>[] : input.a, b = init || !shared ? <int>[] : input.b;
  var top = a.length, left = a.length - 1, right = input.capacity - b.length;
  var allocated = !init,
      initialized = !init,
      status = '待执行',
      changed = '',
      pendingLabel = '';
  int? output, pending;
  _StackNode node(String id) => cells.firstWhere((n) => n.id == id);
  _StackNode allocate(String id, int value, double x, double y) {
    final c = _StackNode(
      id,
      value,
      '0x${(0xe000 + cells.length * 32).toRadixString(16)}',
      x,
      y,
    );
    cells.add(c);
    return c;
  }

  if (linked) {
    for (var i = 0; i < a.length; i++) {
      final c = allocate('node-$i', a[i], 48 + (a.length - 1 - i) * 112.0, 210);
      if (i > 0) c.next = 'node-${i - 1}';
    }
    if (!init) roots['S'] = a.isEmpty ? nullNodeId : 'node-${a.length - 1}';
  } else {
    for (var i = 0; i < a.length; i++) {
      values[i] = a[i];
    }
    for (var i = 0; i < b.length; i++) {
      values[input.capacity - 1 - i] = b[i];
    }
  }
  List<_StackNode> chain() {
    final list = <_StackNode>[];
    var p = roots['S'] ?? nullNodeId;
    while (p != nullNodeId) {
      list.add(node(p));
      p = node(p).next;
    }
    return list;
  }

  void arrange() {
    var i = 0;
    for (final c in chain()) {
      c.x = 48 + i++ * 112.0;
      c.y = 210;
    }
  }

  String valueText(int? v) => v == null ? '·' : '$v';
  List<String> orderA() => linked
      ? chain().reversed.map((n) => '${n.value}').toList()
      : [
          for (var i = 0; i < (shared ? left + 1 : top); i++)
            valueText(values[i]),
        ];
  List<String> orderB() => [
    for (var i = input.capacity - 1; i >= right; i--) valueText(values[i]),
  ];
  SceneSnapshot snapshot() {
    var nodes = <SceneNode>[],
        edges = <SceneEdge>[],
        pointers = <PointerBadge>[],
        zones = <SceneZoneOverlay>[];
    if (linked) {
      nodes = [
        for (final c in cells)
          SceneNode(
            id: c.id,
            label: '${c.value}',
            x: c.x,
            y: c.y,
            width: 80,
            height: 54,
            shape: NodeShape.linkedCell,
            memoryAddress: c.address,
            logicBadge: c.deleted
                ? '已释放'
                : roots['S'] == c.id
                ? '栈顶'
                : roots['p'] == c.id
                ? '局部 p'
                : null,
            isDeleted: c.deleted,
            opacity: c.deleted ? .2 : 1,
            visualState: roots.values.contains(c.id)
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
      ];
      edges = [
        for (final c in cells.where((c) => !c.deleted))
          SceneEdge(
            id: '${c.id}-next',
            fromNodeId: c.id,
            toNodeId: c.next,
            fromPort: EdgePort.next,
            curvature: c.next != nullNodeId && node(c.next).y != c.y ? 70 : 0,
            visualState: changed == c.id
                ? NodeVisualState.active
                : NodeVisualState.normal,
          ),
      ];
      pointers = [
        for (final e in roots.entries)
          PointerBadge(
            id: e.key,
            label: e.key,
            targetNodeId: e.value,
            dy:
                -32 -
                roots.keys
                        .where((k) => roots[k] == e.value)
                        .toList()
                        .indexOf(e.key) *
                    22.0,
          ),
      ];
    } else if (allocated) {
      final slots = [
        for (var i = 0; i < input.capacity; i++)
          SceneNode(
            id: 'slot-$i',
            label: valueText(values[i]),
            x: 0,
            y: 0,
            memoryAddress: '0x${(0xf000 + i * 4).toRadixString(16)}',
          ),
      ];
      if (shared) {
        final layout = LinearMemoryLayout.sharedStacks(
          slots,
          topLeft: left,
          topRight: right,
          origin: const Vec2(x: 130, y: 210),
        );
        nodes = [
          for (var i = 0; i < input.capacity; i++)
            layout.nodes[i].copyWith(
              logicBadge: pending == i
                  ? pendingLabel
                  : i <= left
                  ? '左栈'
                  : i >= right
                  ? '右栈'
                  : '空闲',
              opacity: i <= left || i >= right || pending == i ? 1 : .4,
            ),
          const SceneNode(
            id: 'before',
            label: '−1',
            x: 32,
            y: 210,
            width: 64,
            height: 48,
            logicBadge: '空左栈边界',
            opacity: .4,
            groupTag: 'address-anchor',
          ),
          SceneNode(
            id: 'after',
            label: '${input.capacity}',
            x: 154 + input.capacity * 64.0,
            y: 210,
            width: 64,
            height: 48,
            logicBadge: '空右栈边界',
            opacity: .4,
            groupTag: 'address-anchor',
          ),
        ];
        zones = layout.zones;
        if (initialized) {
          pointers = [
            layout.pointers[0].copyWith(
              targetNodeId: left < 0 ? 'before' : 'slot-$left',
              dy: -48,
            ),
            layout.pointers[1].copyWith(
              targetNodeId: right == input.capacity ? 'after' : 'slot-$right',
            ),
          ];
        }
      } else {
        final bottom = 140 + input.capacity * 88.0;
        nodes = [
          for (var i = 0; i < input.capacity; i++)
            slots[i].copyWith(
              x: 220,
              y: bottom - i * 88,
              width: 92,
              height: 48,
              shape: NodeShape.arraySlot,
              logicBadge:
                  '[$i] ${pending == i
                      ? pendingLabel
                      : i < top
                      ? '有效'
                      : values[i] == null
                      ? '空闲'
                      : '栈外旧值'}',
              opacity: i < top || pending == i ? 1 : .35,
              visualState: changed == 'slot-$i'
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
          SceneNode(
            id: 'end',
            label: '单越界地址',
            x: 210,
            y: bottom - input.capacity * 88,
            width: 112,
            height: 48,
            memoryAddress:
                '0x${(0xf000 + input.capacity * 4).toRadixString(16)}',
            logicBadge: '非存储槽 · 不可解引用',
            opacity: .4,
            groupTag: 'address-anchor',
          ),
        ];
        pointers = [
          const PointerBadge(
            id: 'base',
            label: 'base',
            targetNodeId: 'slot-0',
            dx: -110,
            dy: 12,
          ),
          PointerBadge(
            id: 'top',
            label: 'top = base + $top',
            targetNodeId: initialized
                ? (top == input.capacity ? 'end' : 'slot-$top')
                : nullNodeId,
            dx: 110,
            dy: 12,
          ),
        ];
      }
    }
    return SceneSnapshot(
      layoutMode: linked || !shared
          ? SceneLayoutMode.freeCanvas
          : SceneLayoutMode.linearMemory,
      nodes: nodes,
      edges: edges,
      pointers: pointers,
      zones: zones,
      auxTables: [
        AuxTableSnapshot(
          id: 'state',
          title: '栈状态',
          columns: const ['状态', '输出 e', 'top / top[0]', 'top[1]', '剩余容量'],
          rows: [
            [
              status,
              output == null ? '—' : '$output',
              linked
                  ? roots['S'] ?? '未初始化'
                  : !initialized
                  ? '未初始化'
                  : '${shared ? left : top}',
              shared && initialized ? '$right' : '—',
              linked
                  ? '按节点分配'
                  : '${shared ? right - left - 1 : input.capacity - top}',
            ],
          ],
        ),
        AuxTableSnapshot(
          id: 'stacks',
          title: '有效栈序（栈底 → 栈顶）',
          columns: const ['A / 左栈', '右栈'],
          rows: [
            [orderA().join(' → '), shared ? orderB().join(' → ') : '—'],
          ],
        ),
        AuxTableSnapshot(
          id: 'memory',
          title: linked ? '节点与 next' : '数据槽与地址边界（模拟地址）',
          columns: const ['ID', '地址', '值', '状态 / next'],
          rows: linked
              ? [
                  for (final c in cells)
                    [
                      c.id,
                      c.address,
                      '${c.value}',
                      c.deleted
                          ? '已释放'
                          : c.next == nullNodeId
                          ? 'NULL'
                          : node(c.next).address,
                    ],
                ]
              : [
                  for (final n in nodes)
                    [
                      n.id,
                      n.memoryAddress ?? '—',
                      n.label,
                      n.groupTag == 'address-anchor'
                          ? '地址边界，不是数据槽'
                          : n.logicBadge ?? '',
                    ],
                ],
        ),
      ],
    );
  }

  final builder = TraceBuilder(
    moduleId: 'ch3_stack_sq_link',
    inputSummary:
        '${StackSqLinkModule.kindNames[kind.index]} · ${StackSqLinkModule.operationNames[op.index]}',
    codeLines: source.lines,
    trackLinkedOwnership: linked,
  );
  void frame(
    String tag,
    String title,
    String explain, {
    int compare = 0,
    int read = 0,
    int write = 0,
    int allocate = 0,
    bool milestone = false,
    bool error = false,
  }) {
    final line = source.tags[tag]!;
    final vars = <String, String>{
      if (!linked) 'capacity': '${input.capacity}',
      if (shared) 'which': '${input.stack}',
      if (push) 'e': '${input.value}',
      if (output != null) 'out': '$output',
      if (!linked && initialized) 'top': shared ? '[$left,$right]' : '$top',
      for (final e in roots.entries)
        e.key: e.value == nullNodeId ? 'NULL' : node(e.value).address,
    };
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: vars,
      scene: snapshot(),
      callStack: [
        StackActivationRecord(
          id: 'stack',
          functionName: op == StackOperation.init
              ? 'InitStack'
              : op == StackOperation.push
              ? 'Push'
              : op == StackOperation.pop
              ? 'Pop'
              : 'GetTop',
          arguments: {
            if (init && !linked) 'capacity': '${input.capacity}',
            if (shared && !init) 'which': '${input.stack}',
            if (push) 'e': '${input.value}',
          },
          locals: vars,
          returnLocation: '栈实验工作台',
        ),
      ],
      deltaCompare: compare,
      deltaRead: read,
      deltaWrite: write,
      deltaAllocate: allocate,
      milestone: milestone,
      error: error,
    );
  }

  frame(
    'entry',
    '进入 · ${StackSqLinkModule.kindNames[kind.index]}',
    init
        ? '初始化一份新栈，不销毁已有栈；输入预设值不参与 Init。'
        : linked
        ? 'S 直接指向首元，空栈为 NULL；没有头结点。'
        : shared
        ? 'top[0]/top[1] 都指向各自最后一个有效元素；两端向中间增长。'
        : 'base 指底部；top 指向下一空位置，top−base 为有效长度。满栈时 top 是合法单越界地址，不能解引用。',
  );
  status = '执行中';
  if (init) {
    if (linked) {
      roots['S'] = nullNodeId;
      frame(
        'init',
        'S = NULL · 无头结点',
        '不分配哨兵或头结点，链栈初始化 O(1)。',
        write: 1,
        milestone: true,
      );
    } else {
      allocated = true;
      frame(
        'allocate',
        shared ? '建立共享容量' : '分配 capacity 个槽',
        shared
            ? 'C99 使用结构体内预留数组，Dart 建立等价 List；两种语言的分配方式不同。'
            : 'base 获得数据区，top 尚未完成初始化。',
        allocate: shared ? 0 : 1,
        milestone: true,
      );
      initialized = true;
      top = 0;
      left = -1;
      right = input.capacity;
      frame(
        'init',
        shared ? 'top[0]=−1；top[1]=capacity' : 'top = base',
        '两个栈均为空，所有数据槽均未占用。',
        write: shared ? 2 : 1,
        milestone: true,
      );
    }
  } else if (linked) {
    if (push) {
      final p = allocate('new', input.value, 48, 410);
      roots['p'] = p.id;
      frame('allocate', '分配新节点 p', '新节点由局部 p 持有。', allocate: 1, write: 1);
      p.next = roots['S']!;
      changed = p.id;
      frame(
        'connect',
        '① p->next = S',
        '先接到原栈顶，原链保持可达。',
        write: 1,
        milestone: true,
      );
      changed = '';
      roots['S'] = p.id;
      arrange();
      frame(
        'move',
        '② S = p',
        '新节点成为最左侧栈顶；节点地址不随动画位置改变。',
        write: 1,
        milestone: true,
      );
      roots.remove('p');
    } else {
      final empty = roots['S'] == nullNodeId;
      frame(
        'check',
        '检查 S 是否为空',
        empty ? '空栈不能出栈或读取栈顶。' : '当前栈非空。',
        compare: 1,
      );
      if (empty) {
        status = 'ERROR';
        frame('check', 'ERROR · 空链栈', '没有节点被释放，也不写输出。', error: true);
        return builder.build();
      }
      output = node(roots['S']!).value;
      frame(
        'read',
        pop ? '读出栈顶值' : 'GetTop · 只读首元',
        'e = $output。',
        read: 1,
        milestone: true,
      );
      if (pop) {
        final p = roots['S']!;
        roots['p'] = p;
        frame('save', '保存 p = S', 'p 持有待释放节点。');
        roots['S'] = node(p).next;
        frame(
          'move',
          'S = S->next',
          '先把栈顶移到后继；唯一节点出栈后 S 为 NULL。',
          read: 1,
          write: 1,
          milestone: true,
        );
        node(p).deleted = true;
        node(p).y = 410;
        roots.remove('p');
        arrange();
        frame('free', '释放 p', '仅释放原栈顶，剩余节点仍由 S 持有。', milestone: true);
      }
    }
  } else {
    final full = shared ? left + 1 == right : top == input.capacity,
        empty = shared
            ? (input.stack == 0 ? left == -1 : right == input.capacity)
            : top == 0;
    frame(
      'check',
      push ? '检查满栈' : '检查选中栈是否为空',
      push ? (full ? '没有空槽。' : '仍有空槽。') : (empty ? '没有可读栈顶。' : '可执行操作。'),
      compare: 1,
    );
    if (push ? full : empty) {
      status = push ? 'OVERFLOW' : 'ERROR';
      frame(
        'check',
        '$status · ${push ? '栈满' : '栈空'}',
        '拒绝操作，栈内容、栈顶和输出均保持。',
        error: true,
      );
      return builder.build();
    }
    if (shared) {
      int index() => input.stack == 0 ? left : right;
      if (push) {
        if (input.stack == 0) {
          left++;
        } else {
          right--;
        }
        pending = index();
        pendingLabel = '占位 · 待写';
        frame(
          'move',
          '① top[${input.stack}] ${input.stack == 0 ? '++' : '--'}',
          '共享栈 top 指有效槽，先向中间占一槽；新槽尚未写入。',
          write: 1,
          milestone: true,
        );
        values[index()] = input.value;
        changed = 'slot-${index()}';
        pending = null;
        frame(
          'write',
          '② data[top] = e',
          '写入 ${input.value}；两栈不能跨过对方栈顶。',
          write: 1,
          milestone: true,
        );
      } else {
        output = values[index()];
        frame(
          'read',
          '读取 data[top[${input.stack}]]',
          '输出 $output。${pop ? '随后退回栈顶。' : '两个栈顶保持不变。'}',
          read: 1,
          milestone: true,
        );
        if (pop) {
          if (input.stack == 0) {
            left--;
          } else {
            right++;
          }
          frame(
            'move',
            '退回 top[${input.stack}]',
            '退出的槽可供任意一栈下次使用；旧位值不必清零。',
            write: 1,
            milestone: true,
          );
        }
      }
    } else {
      if (push) {
        values[top] = input.value;
        changed = 'slot-$top';
        pending = top;
        pendingLabel = '已写 · 待 top++';
        frame(
          'write',
          '① *top = e',
          '写入下一空槽；top 尚未前进，有效长度暂未增加。',
          write: 1,
          milestone: true,
        );
        top++;
        pending = null;
        changed = '';
        frame(
          'move',
          '② top++',
          'top 上移到下一空位置。若填满，它现在是单越界地址，不是额外槽。',
          write: 1,
          milestone: true,
        );
      } else if (pop) {
        top--;
        pending = top;
        pendingLabel = '已退出 · 待读';
        frame(
          'move',
          '① --top',
          'top 先下移回原栈顶槽，长度已减一。',
          write: 1,
          milestone: true,
        );
        output = values[top];
        pending = null;
        frame(
          'read',
          '② e = *top',
          '输出 $output。槽位保留旧值但已不在有效栈内。',
          read: 1,
          milestone: true,
        );
      } else {
        output = values[top - 1];
        frame(
          'read',
          'GetTop · *(top−1)',
          '读取 $output，top 不动；直接读 *top 会访问空槽或越界。',
          read: 1,
          milestone: true,
        );
      }
    }
  }
  status = 'OK';
  changed = '';
  frame(
    'return',
    '返回 OK',
    'Push/Pop/GetTop 为 O(1)。初始化的分配/清零成本依语言实现；本轨迹的场景排布和快照成本不计入算法操作。',
    milestone: true,
  );
  return builder.build();
}
