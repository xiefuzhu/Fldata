import '../../models/trace_model.dart';
import '../../engine/vm/trace_builder.dart';
import 'cases_polyn_book.dart';
import 'cases_source.dart';

class _BookCell {
  _BookCell(this.id, this.book, this.address, this.x, this.y);
  final String id, address;
  final BookRecord? book;
  double x, y;
  String next = nullNodeId;
  bool deleted = false;
}

TraceTimeline generateBookTrace(CasesInput input) {
  final linked = input.linked,
      op = input.operation,
      ins = op == CaseOperation.bookInsert,
      find = op == CaseOperation.bookFind;
  final source = bookSource(op, linked),
      cells = <_BookCell>[],
      roots = <String, String>{},
      vars = <String, String>{if (!find) 'i': '${input.position}'};
  final slots = <BookRecord?>[
    ...input.books,
    for (var k = input.books.length; k < 8; k++) null,
  ];
  var length = input.books.length, status = '待执行', changed = '';
  BookRecord? selected;
  _BookCell cell(String id) => cells.firstWhere((c) => c.id == id);
  String addr(String id) => id == nullNodeId ? 'NULL' : cell(id).address;
  _BookCell alloc(String id, BookRecord? book, double x, double y) {
    final c = _BookCell(
      id,
      book,
      '0x${(0xc000 + cells.length * 128).toRadixString(16)}',
      x,
      y,
    );
    cells.add(c);
    return c;
  }

  if (linked) {
    final chain = [
      alloc('head', null, 32, 170),
      for (var i = 0; i < input.books.length; i++)
        alloc('book-$i', input.books[i], 168 + i * 136.0, 170),
    ];
    for (var i = 0; i < chain.length - 1; i++) {
      chain[i].next = chain[i + 1].id;
    }
    roots['L'] = 'head';
  }
  List<String> order() {
    final out = <String>[];
    var p = cell('head').next;
    while (p != nullNodeId) {
      out.add(p);
      p = cell(p).next;
    }
    return out;
  }

  List<BookRecord> records() => linked
      ? order().map((id) => cell(id).book!).toList()
      : slots.take(length).cast<BookRecord>().toList();
  void arrange() {
    var i = 1;
    for (final id in order()) {
      cell(id).x = 32 + i++ * 136.0;
      cell(id).y = 170;
    }
  }

  SceneSnapshot snapshot() => SceneSnapshot(
    layoutMode: linked
        ? SceneLayoutMode.freeCanvas
        : SceneLayoutMode.linearMemory,
    nodes: linked
        ? [
            for (final c in cells)
              SceneNode(
                id: c.id,
                label: c.book?.label ?? 'L',
                x: c.x,
                y: c.y,
                width: 104,
                height: 82,
                shape: NodeShape.linkedCell,
                memoryAddress: c.address,
                logicBadge: c.deleted
                    ? '已释放'
                    : c.book == null
                    ? '头结点'
                    : null,
                isDeleted: c.deleted,
                opacity: c.deleted ? .2 : 1,
                visualState: c.book == null
                    ? NodeVisualState.sentinel
                    : roots.values.contains(c.id)
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ]
        : [
            for (var k = 0; k < 8; k++)
              SceneNode(
                id: 'slot-$k',
                label: slots[k]?.label ?? '空槽',
                x: 32 + k * 120.0,
                y: 170,
                width: 104,
                height: 82,
                shape: NodeShape.arraySlot,
                indexBadge: '[$k]',
                memoryAddress: '0x${(0xd000 + k * 96).toRadixString(16)}',
                logicBadge: k >= length ? '有效区外' : null,
                opacity: k >= length ? .35 : 1,
                visualState: changed == 'slot-$k'
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ],
    edges: linked
        ? [
            for (final c in cells.where((c) => !c.deleted))
              SceneEdge(
                id: '${c.id}-next',
                fromNodeId: c.id,
                toNodeId: c.next,
                fromPort: EdgePort.next,
                curvature:
                    c.next != nullNodeId &&
                        (cell(c.next).y != c.y ||
                            (cell(c.next).x - c.x).abs() > 150)
                    ? 65
                    : 0,
                visualState: changed == c.id
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ]
        : [],
    pointers: linked
        ? [
            for (final e in roots.entries)
              PointerBadge(
                id: e.key,
                label: e.key,
                targetNodeId: e.value,
                dy:
                    -30 -
                    roots.keys
                            .where((k) => roots[k] == e.value)
                            .toList()
                            .indexOf(e.key) *
                        22.0,
              ),
          ]
        : [
            if (int.tryParse(vars['k'] ?? '') case final int k
                when k >= 0 && k < 8)
              PointerBadge(
                id: 'k',
                label: 'k',
                targetNodeId: 'slot-$k',
                dy: -52,
              ),
          ],
    auxTables: [
      AuxTableSnapshot(
        id: 'result',
        title: '图书操作',
        columns: const ['状态', '选中记录', '有效长度'],
        rows: [
          [status, selected?.raw ?? '—', '$length'],
        ],
      ),
      AuxTableSnapshot(
        id: 'books',
        title: '当前有效书库',
        columns: const ['编号', '书名', '价格'],
        rows: [
          for (final b in records())
            [b.isbn, b.title, b.price.toStringAsFixed(2)],
        ],
      ),
      AuxTableSnapshot(
        id: 'heap',
        title: '模拟存储',
        columns: const ['ID', '地址', '编号', '书名', '价格', 'next'],
        rows: linked
            ? [
                for (final c in cells)
                  [
                    c.id,
                    c.address,
                    c.book?.isbn ?? '—',
                    c.book?.title ?? '头结点',
                    c.book?.price.toStringAsFixed(2) ?? '—',
                    c.deleted ? '已释放' : addr(c.next),
                  ],
              ]
            : [
                for (var k = 0; k < 8; k++)
                  [
                    'slot-$k',
                    '0x${(0xd000 + k * 96).toRadixString(16)}',
                    slots[k]?.isbn ?? '—',
                    slots[k]?.title ?? '空槽',
                    slots[k]?.price.toStringAsFixed(2) ?? '—',
                    '—',
                  ],
              ],
      ),
    ],
  );
  final builder = TraceBuilder(
    moduleId: 'ch2_cases_polyn_book',
    inputSummary:
        '${CasesPolynBookModule.names[op.index]} · ${linked ? '链式' : '顺序'}',
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
    int move = 0,
    int allocate = 0,
    bool error = false,
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
          id: 'book',
          functionName: find
              ? 'FindBook'
              : ins
              ? 'InsertBook'
              : 'DeleteBook',
          arguments: {
            if (find) 'id': input.query,
            if (!find) 'i': '${input.position}',
            if (ins) 'e': input.book.raw,
          },
          locals: {
            ...vars,
            for (final e in roots.entries) e.key: addr(e.value),
          },
          returnLocation: '书库工作台',
        ),
      ],
      deltaCompare: compare,
      deltaRead: read,
      deltaWrite: write,
      deltaMove: move,
      deltaAllocate: allocate,
      error: error,
      milestone: milestone,
    );
  }

  frame(
    'entry',
    '进入 · ${CasesPolynBookModule.names[op.index]}',
    '${linked ? '带头结点链表' : '容量 8 的顺序表'}，编号唯一。画面价格为教学记录，非商品报价。',
  );
  status = '执行中';
  if (find) {
    if (linked) {
      roots['p'] = cell('head').next;
    } else {
      vars['k'] = '0';
    }
    frame('init', '从首本开始查找', '编号查找采用线性扫描。', read: linked ? 1 : 0);
    for (var k = 0; k < input.books.length; k++) {
      if (!linked) vars['k'] = '$k';
      final b = input.books[k], found = b.isbn == input.query;
      if (found) {
        selected = b;
        status = 'FOUND';
      }
      frame(
        'compare',
        '比较编号 · ${b.isbn}',
        found ? '找到目标，显示整条图书记录。' : '编号不相等，继续。',
        compare: 1,
        read: 1,
        milestone: found,
      );
      if (found) return builder.build();
      if (linked) {
        roots['p'] = cell(roots['p']!).next;
      } else {
        vars['k'] = '${k + 1}';
      }
      frame('walk', '前进到下一本', '不修改原书库。', read: linked ? 1 : 0);
    }
    status = 'NOT_FOUND';
    frame('return', '查找未命中', '扫描结束，没有相同编号；不是结构错误。', milestone: true);
    return builder.build();
  }
  if (ins && linked) {
    frame('capacity', '检查会话展示上限', '本实验最多 8 本；这不是链表物理容量限制。', read: length);
    if (length >= 8) {
      status = 'LIMIT';
      frame('capacity', '达到 8 本展示上限', '可先删除一本或编辑数据。', error: true);
      return builder.build();
    }
  }
  if (ins) {
    for (var k = 0; k < input.books.length; k++) {
      if (linked) {
        roots['q'] = 'book-$k';
      } else {
        vars['k'] = '$k';
      }
      final duplicate = input.books[k].isbn == input.book.isbn;
      if (duplicate) status = 'DUPLICATE';
      frame(
        'unique',
        '检查编号唯一性 · ${input.books[k].isbn}',
        duplicate ? '该编号已存在，整次插入不修改书库。' : '编号不同。',
        compare: 1,
        read: 1,
        error: duplicate,
      );
      if (duplicate) return builder.build();
    }
    roots.remove('q');
    vars.remove('k');
  }
  if (linked) {
    var p = 'head', j = 0;
    roots['p'] = p;
    vars['j'] = '0';
    frame('init', '从头结点定位前驱', '前驱位序为 i−1，首位操作统一从 L 开始。');
    while (p != nullNodeId && j < input.position - 1) {
      p = cell(p).next;
      j++;
      roots['p'] = p;
      vars['j'] = '$j';
      frame('walk', '定位前驱 · j=$j', '沿 next 前进。', read: 1);
    }
    final valid =
        input.position >= 1 &&
        p != nullNodeId &&
        (ins || cell(p).next != nullNodeId);
    if (!valid) {
      status = 'ERROR';
      frame('bounds', '非法位序', '插入范围 1..n+1，删除范围 1..n；书库保持不变。', error: true);
      return builder.build();
    }
    frame('bounds', '位序有效', '已找到操作前驱。');
    if (ins) {
      final node = alloc('new', input.book, cell(p).x + 136, 380);
      roots['s'] = node.id;
      frame('new', '分配新图书节点', '新记录包含编号、书名和价格。', allocate: 1);
      node.next = cell(p).next;
      changed = node.id;
      frame(
        'snext',
        '先连后继 · s->next=p->next',
        '保存原后继，尾插时为 NULL。',
        read: 1,
        write: 1,
        milestone: true,
      );
      cell(p).next = node.id;
      changed = p;
      length++;
      arrange();
      frame(
        'write',
        '再连前驱 · p->next=s',
        '原有图书数据不搬移，只改 next。',
        write: 1,
        milestone: true,
      );
      roots.remove('s');
    } else {
      final q = cell(p).next;
      roots['q'] = q;
      selected = cell(q).book;
      frame('read', '保存待删记录 q', 'q 持有待删节点，先展示将删除的图书。', read: 1);
      cell(p).next = cell(q).next;
      changed = p;
      length--;
      frame(
        'write',
        '绕过 q · p->next=q->next',
        'q 在释放前仍由局部指针持有。',
        read: 1,
        write: 1,
        milestone: true,
      );
      cell(q).deleted = true;
      roots.remove('q');
      changed = '';
      arrange();
      frame('free', '释放图书节点 q', '只有待删节点释放，其余节点地址保持。', milestone: true);
    }
    roots
      ..clear()
      ..addAll({'L': 'head'});
  } else {
    final valid =
        input.position >= 1 &&
        input.position <= (ins ? length + 1 : length) &&
        (!ins || length < 8);
    if (!valid) {
      status = ins && length == 8 ? 'OVERFLOW' : 'ERROR';
      frame(
        'bounds',
        '$status · 操作未执行',
        '容量为 8；插入位序 1..n+1，删除位序 1..n。',
        error: true,
      );
      return builder.build();
    }
    frame('bounds', '位序与容量有效', '位序 i 对应数组下标 i−1。');
    if (ins) {
      frame('reserve', '使用预留空槽', '按 C99 记录有效长度；Dart List.add 预先扩长以完成等价搬移。');
      for (var k = length; k >= input.position; k--) {
        vars['k'] = '$k';
        slots[k] = slots[k - 1];
        changed = 'slot-$k';
        frame(
          'shift',
          '后移 · [${k - 1}] → [$k]',
          '复制整条图书记录，从后往前避免覆盖。',
          read: 1,
          write: 1,
          move: 1,
        );
      }
      slots[input.position - 1] = input.book;
      changed = 'slot-${input.position - 1}';
      frame('write', '写入新图书', '将编号、书名和价格整体写入目标槽。', write: 1, milestone: true);
      length++;
      frame('length', 'length++', '新槽进入有效区。');
    } else {
      selected = slots[input.position - 1];
      for (var k = input.position; k < length; k++) {
        vars['k'] = '$k';
        slots[k - 1] = slots[k];
        changed = 'slot-${k - 1}';
        frame(
          'shift',
          '前移 · [$k] → [${k - 1}]',
          '覆盖待删位置，保持其余记录顺序。',
          read: 1,
          write: 1,
          move: 1,
        );
      }
      length--;
      frame('length', 'length--', '有效区缩短；末槽旧值保留但不再属于书库。', milestone: true);
    }
  }
  vars.clear();
  changed = '';
  status = 'OK';
  frame(
    'return',
    '操作完成 · 可续用结果',
    '点击“将结果作为当前书库”可继续增删查；这是本课会话数据，学习进度单独保存。',
    milestone: true,
  );
  return builder.build();
}
