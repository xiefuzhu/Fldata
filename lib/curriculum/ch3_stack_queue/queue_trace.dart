import '../../models/trace_model.dart';
import '../../engine/vm/trace_builder.dart';
import '../../engine/layout/circular_queue_layout.dart';
import '../../engine/layout/linear_memory_layout.dart';
import 'queue_sq_link.dart';
import 'queue_source.dart';

class _QueueNode {
  _QueueNode(this.id, this.value, this.address);
  final String id, address;
  final int? value;
  String next = nullNodeId;
  bool deleted = false;
  double x = 0, y = 210;
}

TraceTimeline generateQueueTrace(QueueInput input) {
  final linked = input.kind == QueueKind.linked,
      ring = input.kind == QueueKind.circular,
      demo = input.operation == QueueOperation.demo;
  final cap = demo ? 5 : input.capacity,
      source = QueueSource(input.kind),
      nodes = <_QueueNode>[],
      roots = <String, String>{},
      history = <List<String>>[];
  final values = List<int?>.filled(cap, null);
  var front = demo || input.operation == QueueOperation.init ? 0 : input.front,
      rear = 0,
      allocated = !demo && input.operation != QueueOperation.init;
  var initialized = allocated;
  var status = '待执行',
      changed = '',
      pending = '',
      function = '',
      seq = 0,
      rejects = 0;
  int? output;
  _QueueNode node(String id) => nodes.firstWhere((n) => n.id == id);
  _QueueNode alloc(String id, int? value) {
    final n = _QueueNode(
      id,
      value,
      '0x${(0xb000 + nodes.length * 32).toRadixString(16)}',
    );
    nodes.add(n);
    return n;
  }

  List<_QueueNode> chain() {
    final result = <_QueueNode>[];
    var p = roots['front'] == null ? nullNodeId : node(roots['front']!).next;
    while (p != nullNodeId) {
      result.add(node(p));
      p = node(p).next;
    }
    return result;
  }

  void arrange() {
    if (roots['front'] == null) return;
    node(roots['front']!).x = 40;
    var i = 1;
    for (final n in chain()) {
      n.x = 40 + i++ * 112.0;
      n.y = 210;
    }
  }

  int length() => linked
      ? chain().length
      : ring
      ? (rear - front + cap) % cap
      : rear - front;
  List<int?> order() => linked
      ? chain().map((n) => n.value).toList()
      : [
          for (var i = 0; i < length(); i++)
            values[ring ? (front + i) % cap : front + i],
        ];
  if (allocated) {
    if (linked) {
      final head = alloc('head', null);
      roots['front'] = head.id;
      var tail = head;
      for (var i = 0; i < input.values.length; i++) {
        final n = alloc('node-$i', input.values[i]);
        tail.next = n.id;
        tail = n;
      }
      roots['rear'] = tail.id;
      arrange();
    } else {
      for (var i = 0; i < input.values.length; i++) {
        values[ring ? (front + i) % cap : front + i] = input.values[i];
      }
      rear = ring
          ? (front + input.values.length) % cap
          : front + input.values.length;
    }
  }
  SceneSnapshot snapshot() {
    var scene = const SceneSnapshot();
    if (linked) {
      scene = SceneSnapshot(
        nodes: [
          for (final n in nodes)
            SceneNode(
              id: n.id,
              label: n.value == null ? '头结点' : '${n.value}',
              x: n.x,
              y: n.y,
              width: 80,
              height: 54,
              shape: NodeShape.linkedCell,
              memoryAddress: n.address,
              isZeroSentinelSlot: n.value == null,
              isDeleted: n.deleted,
              opacity: n.deleted ? .2 : 1,
              logicBadge: n.deleted
                  ? '已释放'
                  : n.value == null
                  ? '不存数据'
                  : pending == n.id
                  ? '待接入'
                  : null,
              visualState: changed == n.id
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        edges: [
          for (final n in nodes.where((n) => !n.deleted))
            SceneEdge(
              id: '${n.id}-next',
              fromNodeId: n.id,
              toNodeId: n.next,
              fromPort: EdgePort.next,
              curvature: n.next != nullNodeId && node(n.next).y != n.y ? 65 : 0,
              visualState: changed == n.id
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        pointers: [
          for (final r in roots.entries)
            PointerBadge(
              id: r.key,
              label: r.key,
              targetNodeId: r.value,
              dy: r.key == 'rear'
                  ? 80
                  : r.key == 'p'
                  ? -52
                  : -28,
            ),
        ],
      );
    } else if (allocated) {
      final slots = [
        for (var i = 0; i < cap; i++)
          SceneNode(
            id: 'slot-$i',
            label: values[i] == null ? '·' : '${values[i]}',
            x: 0,
            y: 0,
            memoryAddress: '0x${(0xc000 + i * 4).toRadixString(16)}',
          ),
      ];
      scene = ring
          ? CircularQueueLayout.arrange(
              slots,
              front: front,
              rear: rear,
              center: const Vec2(x: 300, y: 260),
              radius: 136,
            )
          : LinearMemoryLayout.arrange(
              slots,
              origin: const Vec2(x: 60, y: 190),
            );
      scene = scene.copyWith(
        nodes: [
          for (var i = 0; i < cap; i++)
            scene.nodes[i].copyWith(
              logicBadge: pending == 'slot-$i'
                  ? '已写待 rear'
                  : (ring
                        ? (i - front + cap) % cap < length()
                        : i >= front && i < rear)
                  ? '有效'
                  : values[i] == null
                  ? '空闲'
                  : '队外旧值',
              opacity:
                  (ring
                          ? (i - front + cap) % cap < length()
                          : i >= front && i < rear) ||
                      pending == 'slot-$i'
                  ? 1
                  : .4,
              visualState: changed == 'slot-$i'
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
          if (!ring)
            SceneNode(
              id: 'end',
              label: '地址边界',
              x: 80 + cap * 64.0,
              y: 190,
              width: 80,
              height: 48,
              logicBadge: '不是数据槽',
              opacity: .4,
              groupTag: 'address-anchor',
            ),
        ],
        pointers: !initialized
            ? []
            : ring
            ? [
                for (final pointer in scene.pointers)
                  pointer.copyWith(
                    orbit: pointer.orbit!.copyWith(
                      radius: pointer.id == 'front' ? 202 : 230,
                    ),
                  ),
              ]
            : [
                PointerBadge(
                  id: 'front',
                  label: 'front=$front',
                  targetNodeId: front == cap ? 'end' : 'slot-$front',
                  dy: -38,
                ),
                PointerBadge(
                  id: 'rear',
                  label: 'rear=$rear',
                  targetNodeId: rear == cap ? 'end' : 'slot-$rear',
                  dy: 80,
                ),
              ],
        zones: [
          ...scene.zones,
          if (!ring && front > 0)
            SceneZoneOverlay(
              id: 'wasted-front',
              label: '已出队前端空槽：线性模式不能绕回',
              x: 56,
              y: 182,
              width: front * 64.0,
              height: 64,
              pattern: ZonePattern.hatched,
            ),
        ],
      );
    }
    return scene.copyWith(
      auxTables: [
        AuxTableSnapshot(
          id: 'state',
          title: '队列状态',
          columns: const ['状态', '输出', 'front', 'rear', '有效长度', '有效队序'],
          rows: [
            [
              status,
              output == null ? '—' : '$output',
              linked
                  ? roots['front'] ?? '未初始化'
                  : initialized
                  ? '$front'
                  : '未初始化',
              linked
                  ? roots['rear'] ?? '未初始化'
                  : initialized
                  ? '$rear'
                  : '未初始化',
              '${length()}',
              order().map((v) => v == null ? '·' : '$v').join(' → '),
            ],
          ],
        ),
        AuxTableSnapshot(
          id: 'history',
          title: '操作历史',
          columns: const ['操作', '结果', '输出'],
          rows: history,
        ),
        AuxTableSnapshot(
          id: 'memory',
          title: '模拟内存',
          columns: const ['ID', '地址', '值', 'next / 有效性'],
          rows: linked
              ? [
                  for (final n in nodes)
                    [
                      n.id,
                      n.address,
                      n.value == null ? '头结点' : '${n.value}',
                      n.deleted ? '已释放' : n.next,
                    ],
                ]
              : [
                  for (final n in scene.nodes)
                    [n.id, n.memoryAddress ?? '—', n.label, n.logicBadge ?? ''],
                ],
        ),
      ],
    );
  }

  final builder = TraceBuilder(
    moduleId: 'ch3_queue_sq_link',
    inputSummary:
        '${QueueSqLinkModule.kindNames[input.kind.index]} · ${QueueSqLinkModule.operationNames[input.operation.index]}',
    codeLines: source.lines,
    trackLinkedOwnership: linked,
  );
  void frame(
    String tag,
    String title,
    String explanation, {
    int write = 0,
    int read = 0,
    int compare = 0,
    int allocate = 0,
    bool milestone = false,
    bool error = false,
    Map<String, String> vars = const {},
  }) {
    final line = source.tags[tag]!;
    final local = <String, String>{
      if (!linked) 'front': '$front',
      if (!linked) 'rear': '$rear',
      if (!linked) 'M': '$cap',
      if (output != null) 'out': '$output',
      for (final r in roots.entries)
        r.key: r.value == nullNodeId ? 'NULL' : node(r.value).address,
      ...vars,
    };
    builder.step(
      title: title,
      explain: explanation,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: local,
      scene: snapshot(),
      callStack: [
        if (demo)
          const StackActivationRecord(
            id: 'demo',
            functionName: 'Demo',
            returnLocation: '队列工作台',
          ),
        if (function != 'Demo')
          StackActivationRecord(
            id: 'op-$seq',
            functionName: function,
            arguments: vars,
            locals: local,
            returnLocation: demo ? 'Demo 下一操作' : '队列工作台',
            parentCallId: demo ? 'demo' : null,
          ),
      ],
      deltaWrite: write,
      deltaRead: read,
      deltaCompare: compare,
      deltaAllocate: allocate,
      milestone: milestone,
      error: error,
    );
  }

  void start(String name, String tag, {int? value}) {
    seq++;
    function = name;
    status = '执行中';
    output = null;
    changed = '';
    pending = '';
    frame(
      tag,
      '进入 $name',
      demo
          ? '固定对照序列：入队 1～4，出队三次，再入队 9、10、11。'
          : linked
          ? 'front 指头结点；rear 指最后一个节点；空队时两者均指头结点。'
          : 'front 指队首；rear 指下一空槽。',
      vars: value == null ? const {} : {'e': '$value'},
    );
  }

  void done(String tag, String op) {
    status = 'OK';
    changed = '';
    pending = '';
    history.add([op, status, output == null ? '—' : '$output']);
    frame(tag, '返回 OK', '本次操作完成；有效队序遵循 FIFO。', milestone: true);
  }

  void fail(String tag, String op, bool full) {
    status = full ? 'OVERFLOW' : 'ERROR';
    rejects++;
    history.add([op, status, '—']);
    frame(
      tag,
      full && !ring && front > 0
          ? 'OVERFLOW · 假溢出'
          : full
          ? 'OVERFLOW · 队满'
          : 'ERROR · 队空',
      full && !ring && front > 0
          ? 'rear 已到 M，前端仍有 $front 个空槽；线性队列不能复用，切换循环模式重放同一序列。'
          : '拒绝操作；不改变队列内容或指针，也不输出值。',
      error: true,
    );
  }

  void init() {
    start('InitQueue', 'init-entry');
    allocated = true;
    if (linked) {
      final h = alloc('head', null);
      roots['front'] = h.id;
      roots['rear'] = h.id;
      initialized = true;
      arrange();
    } else {
      front = 0;
      rear = 0;
    }
    frame(
      'init-alloc',
      linked ? '分配头结点，front=rear' : '分配 M 个数据槽',
      linked ? '头结点不存队列元素；空队仍保留头结点。' : '初始化一份新队列；不用于销毁已有队列。',
      allocate: 1,
      write: linked ? 2 : 1,
    );
    initialized = true;
    frame(
      'init-set',
      linked ? 'head.next = NULL' : 'front = rear = 0',
      linked ? '两端同指头结点，next 为空。' : 'front==rear 表示空队；循环模式容量为 M−1。',
      write: linked ? 1 : 2,
      milestone: true,
    );
    done('init-return', 'Init');
  }

  void enqueue(int value) {
    start('EnQueue', 'enq-entry', value: value);
    if (linked) {
      final p = alloc('node-${nodes.length}', value);
      p.x = 40 + chain().length * 112.0;
      p.y = 390;
      roots['p'] = p.id;
      pending = p.id;
      frame(
        'enq-alloc',
        '分配 p 并写入数据',
        'p.next=NULL，局部指针 p 持有新节点。',
        allocate: 1,
        write: 2,
        vars: {'e': '$value'},
      );
      node(roots['rear']!).next = p.id;
      changed = roots['rear']!;
      pending = '';
      frame(
        'enq-link',
        '① rear->next = p',
        '先把新节点接到旧队尾；空队时通过头结点接入。',
        write: 1,
        milestone: true,
      );
      roots['rear'] = p.id;
      arrange();
      changed = '';
      frame(
        'enq-move',
        '② rear = p',
        '尾指针移向新节点，front 仍指头结点。',
        write: 1,
        milestone: true,
      );
      roots.remove('p');
    } else {
      final full = ring ? (rear + 1) % cap == front : rear == cap;
      frame(
        'enq-check',
        '检查队满',
        ring ? '(rear+1)%M == front，留一空位区分队满与队空。' : 'rear==M 便拒绝，即便前面已有空槽。',
        compare: 1,
      );
      if (full) {
        fail('enq-check', 'EnQueue($value)', true);
        return;
      }
      values[rear] = value;
      pending = 'slot-$rear';
      changed = pending;
      frame(
        'enq-write',
        '① base[rear] = e',
        '先写下一空槽，rear 尚未前进，有效长度未增加。',
        write: 1,
        vars: {'e': '$value'},
        milestone: true,
      );
      rear = ring ? (rear + 1) % cap : rear + 1;
      pending = '';
      changed = '';
      frame(
        'enq-move',
        ring ? '② rear = (rear+1)%M' : '② rear++',
        ring ? '顺时针前进一槽；M−1 到 0 沿跨零点短弧。' : '线性下标只增不绕回。',
        write: 1,
        milestone: true,
      );
    }
    done('enq-return', 'EnQueue($value)');
  }

  void readOrRemove(bool remove) {
    final prefix = remove ? 'deq' : 'peek';
    start(remove ? 'DeQueue' : 'GetHead', '$prefix-entry');
    final empty = linked ? roots['front'] == roots['rear'] : front == rear;
    frame('$prefix-check', '检查队空', 'front==rear 为队空。', compare: 1);
    if (empty) {
      fail('$prefix-check', remove ? 'DeQueue' : 'GetHead', false);
      return;
    }
    if (linked) {
      final p = node(roots['front']!).next;
      if (remove) {
        roots['p'] = p;
        frame('deq-save', '保存 p = front->next', 'p 指首元数据节点，不是头结点。', read: 1);
      }
      output = node(p).value;
      frame(
        '$prefix-read',
        '读取首元数据',
        '输出 $output；头结点不参与输出。',
        read: 1,
        milestone: true,
      );
      if (remove) {
        node(roots['front']!).next = node(p).next;
        changed = roots['front']!;
        frame(
          'deq-link',
          'front->next = p->next',
          roots['rear'] == p
              ? '头结点 next 已空，但 rear 仍指待释放 p，必须先复位 rear。'
              : '首元摘下；局部 p 仍持有待释放节点。',
          read: 1,
          write: 1,
          milestone: true,
        );
        frame(
          'deq-tailcheck',
          '检查 rear == p',
          roots['rear'] == p
              ? '删除的是唯一元素，需要 rear=front。'
              : '还有其他数据节点，rear 无需改变。',
          compare: 1,
        );
        if (roots['rear'] == p) {
          roots['rear'] = roots['front']!;
          frame(
            'deq-move',
            'rear = front · 先复位尾指针',
            '现在两端同指头结点，释放 p 后不会产生悬空 rear。',
            write: 1,
            milestone: true,
          );
        }
        node(p).deleted = true;
        node(p).y = 390;
        roots.remove('p');
        changed = '';
        arrange();
        frame('deq-free', '释放 p', '仅释放数据节点，头结点一直保留。', milestone: true);
      }
    } else {
      output = values[front];
      frame(
        '$prefix-read',
        '读取 base[front]',
        '输出 $output；${remove ? '随后前移 front。' : '两个下标都不移动。'}',
        read: 1,
        milestone: true,
      );
      if (remove) {
        front = ring ? (front + 1) % cap : front + 1;
        frame(
          'deq-move',
          ring ? 'front = (front+1)%M' : 'front++',
          '旧位值保留，但不再属于有效队列。',
          write: 1,
          milestone: true,
        );
      }
    }
    done('$prefix-return', remove ? 'DeQueue' : 'GetHead');
  }

  void getLength() {
    start('QueueLength', 'length-entry');
    if (linked) {
      var n = 0;
      roots['p'] = node(roots['front']!).next;
      frame('length-init', 'n=0，p=front->next', '链队未额外保存长度字段，需逐节点计数。', read: 1);
      while (roots['p'] != nullNodeId) {
        n++;
        roots['p'] = node(roots['p']!).next;
        frame(
          'length-loop',
          '计数 n=$n',
          '沿 next 前进。',
          read: 1,
          compare: 1,
          vars: {'n': '$n'},
        );
      }
      roots.remove('p');
      output = n;
    } else {
      output = length();
    }
    done('length-return', 'Length');
  }

  if (demo) {
    function = 'Demo';
    frame('demo-entry', '开始假溢出对照', '两种模式执行完全相同的入队/出队序列。');
    init();
    for (var v = 1; v <= 4; v++) {
      enqueue(v);
    }
    for (var i = 0; i < 3; i++) {
      readOrRemove(true);
    }
    for (var v = 9; v <= 11; v++) {
      enqueue(v);
    }
    function = 'Demo';
    status = '完成对照';
    output = null;
    frame(
      'demo-end',
      '对照结束 · $rejects 次拒绝',
      ring ? '前端空槽已复用，最后有效序列为 4→9→10→11。' : '前端三个空槽仍闲置，10 和 11 被假溢出拒绝。',
      milestone: true,
    );
  } else {
    switch (input.operation) {
      case QueueOperation.init:
        init();
      case QueueOperation.length:
        getLength();
      case QueueOperation.enqueue:
        enqueue(input.value);
      case QueueOperation.dequeue:
        readOrRemove(true);
      case QueueOperation.peek:
        readOrRemove(false);
      case QueueOperation.demo:
        break;
    }
  }
  return builder.build();
}
