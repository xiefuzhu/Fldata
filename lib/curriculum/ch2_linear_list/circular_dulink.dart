import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../engine/vm/memory_leaks.dart';
import '../../models/trace_model.dart';
import 'circular_dulink_source.dart';

enum CircularOperation { merge, insert, delete, wrongInsert }

class CircularInput {
  const CircularInput({
    this.operation = CircularOperation.merge,
    this.a = const ['A', 'B', 'C'],
    this.b = const ['D', 'E'],
    this.position = 2,
    this.value = 'X',
  });
  final CircularOperation operation;
  final List<String> a, b;
  final int position;
  final String value;
  CircularInput copyWith({CircularOperation? operation}) => CircularInput(
    operation: operation ?? this.operation,
    a: a,
    b: b,
    position: position,
    value: value,
  );
}

class _Link {
  _Link(this.id, this.data, this.address, this.x, this.y);
  final String id, data, address;
  final double x, y;
  String next = nullNodeId, prior = nullNodeId;
  bool deleted = false;
}

class CircularDulinkModule implements AlgorithmModule<CircularInput> {
  const CircularDulinkModule();
  @override
  String get id => 'ch2_circular_dulink';
  static const names = ['尾指针合并', '双向表插入', '双向表删除', '四指针误序反例'];
  @override
  List<AlgorithmPreset<CircularInput>> get presets => const [
    AlgorithmPreset(
      id: 'merge',
      name: '重建示例 · A B C + D E',
      input: CircularInput(),
    ),
    AlgorithmPreset(
      id: 'empty-a',
      name: '边界 · A 为空',
      input: CircularInput(a: []),
    ),
    AlgorithmPreset(
      id: 'empty-b',
      name: '边界 · B 为空',
      input: CircularInput(b: []),
    ),
    AlgorithmPreset(
      id: 'both-empty',
      name: '边界 · 两表均空',
      input: CircularInput(a: [], b: []),
    ),
    AlgorithmPreset(
      id: 'insert',
      name: '四步 · 在 B 前插入 X',
      input: CircularInput(operation: CircularOperation.insert),
    ),
    AlgorithmPreset(
      id: 'append',
      name: '边界 · 双向表尾插',
      input: CircularInput(operation: CircularOperation.insert, position: 4),
    ),
    AlgorithmPreset(
      id: 'insert-empty',
      name: '边界 · 空双向表插入',
      input: CircularInput(
        operation: CircularOperation.insert,
        a: [],
        position: 1,
      ),
    ),
    AlgorithmPreset(
      id: 'delete',
      name: '两步 · 删除首元 A',
      input: CircularInput(operation: CircularOperation.delete, position: 1),
    ),
    AlgorithmPreset(
      id: 'delete-last',
      name: '边界 · 删除唯一结点',
      input: CircularInput(
        operation: CircularOperation.delete,
        a: ['A'],
        position: 1,
      ),
    ),
    AlgorithmPreset(
      id: 'wrong',
      name: '反例 · ④ 提前于 ②',
      input: CircularInput(operation: CircularOperation.wrongInsert),
    ),
    AlgorithmPreset(
      id: 'invalid',
      name: '边界 · 删除 i=0',
      input: CircularInput(operation: CircularOperation.delete, position: 0),
    ),
  ];
  @override
  ValidationResult<CircularInput> validateInput(String raw) {
    final parts = raw.split('|').map((s) => s.trim()).toList();
    if (parts.length != 5) {
      return const ValidationResult.failure('格式：操作|位序|新值|A 元素|B 元素');
    }
    final op = CircularOperation.values
        .where((o) => o.name == parts[0])
        .firstOrNull;
    final position = int.tryParse(parts[1]);
    List<String> parse(String s) =>
        s.isEmpty ? [] : s.split(RegExp(r'[,，\s]+'));
    final a = parse(parts[3]), b = parse(parts[4]);
    final char = RegExp(r'^[A-Za-z0-9]$');
    if (op == null ||
        position == null ||
        position < -1 ||
        position > 8 ||
        a.length > 5 ||
        b.length > 5 ||
        !char.hasMatch(parts[2]) ||
        [...a, ...b].any((s) => !char.hasMatch(s))) {
      return const ValidationResult.failure(
        '每表最多 5 个单字符（英文字母/数字），位序 −1～8；B 仅用于合并。',
      );
    }
    return ValidationResult.success(
      CircularInput(
        operation: op,
        position: position,
        value: parts[2],
        a: a,
        b: b,
      ),
    );
  }

  @override
  TraceTimeline generateTrace(CircularInput input) {
    if (!validateInput(
      '${input.operation.name}|${input.position}|${input.value}|${input.a.join(',')}|${input.b.join(',')}',
    ).isValid) {
      throw ArgumentError('Invalid circular input');
    }
    final op = input.operation,
        merge = op == CircularOperation.merge,
        wrong = op == CircularOperation.wrongInsert;
    final source = CircularDulinkSource(op);
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${names[op.index]} · A=${input.a.join(',')}${merge ? ' · B=${input.b.join(',')}' : ' · i=${input.position}'}',
      codeLines: source.lines,
      trackLinkedOwnership: true,
    );
    final cells = <_Link>[];
    final roots = <String, String>{};
    final vars = <String, String>{
      if (!merge) 'i': '${input.position}',
      if (op != CircularOperation.delete && !merge) 'e': input.value,
    };
    var status = '待执行';
    String? output;
    String? changed;
    _Link cell(String id) => cells.firstWhere((c) => c.id == id);
    String address(String id) => id == nullNodeId ? 'NULL' : cell(id).address;
    _Link allocate(String id, String data, double x, double y) {
      final c = _Link(
        id,
        data,
        '0x${(0x6000 + cells.length * 48).toRadixString(16)}',
        x,
        y,
      );
      cells.add(c);
      return c;
    }

    String makeRing(
      String prefix,
      List<String> data,
      double y, {
      bool dual = false,
    }) {
      final head = allocate('$prefix-head', '', 40, y);
      final ring = [head];
      for (var k = 0; k < data.length; k++) {
        ring.add(allocate('$prefix-$k', data[k], 152 + k * 112.0, y));
      }
      for (var k = 0; k < ring.length; k++) {
        ring[k].next = ring[(k + 1) % ring.length].id;
        if (dual) ring[k].prior = ring[(k + ring.length - 1) % ring.length].id;
      }
      return ring.last.id;
    }

    final ta = makeRing('a', input.a, 150, dual: !merge);
    if (merge) {
      roots['Ta'] = ta;
      roots['Tb'] = makeRing('b', input.b, 350);
    } else {
      roots['L'] = 'a-head';
    }
    final initialTb = roots['Tb'];
    List<String> order(String head, {bool reverse = false}) {
      final result = <String>[], seen = <String>{head};
      var p = reverse ? cell(head).prior : cell(head).next;
      while (p != nullNodeId && seen.add(p) && !cell(p).deleted) {
        if (!p.endsWith('head')) result.add(cell(p).data);
        p = reverse ? cell(p).prior : cell(p).next;
      }
      return result;
    }

    SceneSnapshot snapshot() {
      var mismatches = 0;
      if (!merge) {
        for (final c in cells.where((c) => !c.deleted)) {
          if (c.next == nullNodeId ||
              cell(c.next).deleted ||
              cell(c.next).prior != c.id) {
            mismatches++;
          }
          if (c.prior == nullNodeId ||
              cell(c.prior).deleted ||
              cell(c.prior).next != c.id) {
            mismatches++;
          }
        }
      }
      final dangling = <String>{};
      final edges = <SceneEdge>[];
      for (final c in cells.where((c) => !c.deleted)) {
        for (final port in [EdgePort.next, if (!merge) EdgePort.prior]) {
          final target = port == EdgePort.next ? c.next : c.prior;
          final id = '${c.id}-${port.name}';
          if (target != nullNodeId && cell(target).deleted) dangling.add(id);
          final wrap =
              target != nullNodeId &&
              ((cell(target).x - c.x).abs() > 150 ||
                  (port == EdgePort.next &&
                      target.endsWith('head') &&
                      c.id != target) ||
                  (port == EdgePort.prior &&
                      c.id.endsWith('head') &&
                      c.id != target));
          edges.add(
            SceneEdge(
              id: id,
              fromNodeId: c.id,
              toNodeId: target,
              fromPort: port,
              visualState:
                  dangling.contains(id) ||
                      target == c.id && !c.id.endsWith('head')
                  ? NodeVisualState.error
                  : changed == id
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
              curvature: wrap
                  ? 130
                  : merge
                  ? 0
                  : 24,
              weightLabel: changed == id ? port.name : null,
            ),
          );
        }
      }
      final scene = SceneSnapshot(
        nodes: [
          for (final c in cells)
            SceneNode(
              id: c.id,
              label: c.id.endsWith('head')
                  ? c.id == 'a-head'
                        ? 'HA'
                        : 'HB'
                  : c.data,
              x: c.x,
              y: c.y,
              width: 80,
              height: 52,
              shape: NodeShape.linkedCell,
              memoryAddress: c.address,
              logicBadge: c.deleted
                  ? '已释放'
                  : c.id.endsWith('head')
                  ? '头结点'
                  : null,
              isDeleted: c.deleted,
              opacity: c.deleted ? .2 : 1,
              visualState: c.id.endsWith('head')
                  ? NodeVisualState.sentinel
                  : roots.values.contains(c.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
        edges: edges,
        pointers: [
          for (final p in roots.entries)
            PointerBadge(
              id: p.key,
              label: p.key,
              targetNodeId: p.value,
              dy: -30 - roots.keys.toList().indexOf(p.key) * 20.0,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'state',
            title: '结构状态',
            columns: const ['返回', '输出 e', '双向不一致项', '悬空边'],
            rows: [
              [
                status,
                output ?? '—',
                merge ? '—' : '$mismatches',
                '${dangling.length}',
              ],
            ],
          ),
          AuxTableSnapshot(
            id: 'orders',
            title: '从 HA 出发的数据顺序（遇重复结点停止）',
            columns: const ['正向 next', '反向 prior'],
            rows: [
              [
                order('a-head').join(' → '),
                merge ? '单向结构' : order('a-head', reverse: true).join(' → '),
              ],
            ],
          ),
          AuxTableSnapshot(
            id: 'heap',
            title: '模拟堆字段',
            columns: const ['ID', '地址', 'data', 'next', 'prior', '存活'],
            rows: [
              for (final c in cells)
                [
                  c.id,
                  c.address,
                  c.data,
                  address(c.next),
                  merge ? '—' : address(c.prior),
                  c.deleted ? '已释放' : '是',
                ],
            ],
          ),
        ],
      );
      final lost = detectMemoryLeaks(scene);
      return scene.copyWith(
        zones: [
          for (final n in scene.nodes.where((n) => lost.contains(n.id)))
            SceneZoneOverlay(
              id: 'lost-${n.id}',
              label: '失联',
              x: n.x - 5,
              y: n.y - 5,
              width: 90,
              height: 62,
              visualState: NodeVisualState.error,
              pattern: ZonePattern.dashed,
            ),
        ],
      );
    }

    void record(
      String tag,
      String title,
      String explanation, {
      int writes = 0,
      int reads = 0,
      int allocations = 0,
      bool error = false,
      bool milestone = false,
    }) {
      final line = source.tags[tag]!;
      builder.step(
        title: title,
        explain: explanation,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        scene: snapshot(),
        vars: {
          ...vars,
          ...roots.map((k, v) => MapEntry(k, address(v))),
          'result': status,
          'out': ?output,
        },
        callStack: [
          StackActivationRecord(
            id: 'ring-call',
            functionName: merge
                ? 'Concat'
                : op == CircularOperation.delete
                ? 'ListDelete_DuL'
                : 'ListInsert_DuL',
            arguments: {
              if (merge) 'Ta': address(ta),
              if (merge) 'Tb': address(initialTb ?? nullNodeId),
              if (!merge) 'i': '${input.position}',
              if (!merge && op != CircularOperation.delete) 'e': input.value,
            },
            locals: {...vars, ...roots.map((k, v) => MapEntry(k, address(v)))},
            returnLocation: 'Main',
          ),
        ],
        deltaWrite: writes,
        deltaRead: reads,
        deltaAllocate: allocations,
        error: error,
        milestone: milestone,
      );
    }

    record(
      'entry',
      '准备 ${names[op.index]}',
      merge
          ? '两条带头结点的单循环链，仅持有尾指针 Ta、Tb；尾结点的 next 即头结点。'
          : '带头结点的双向循环链；空表 HA.next=HA.prior=HA。',
      milestone: true,
    );
    if (merge) {
      record('empty', '检查 B 是否为空', 'Tb->next==Tb 表示 B 仅有头结点。', reads: 1);
      if (input.b.isEmpty) {
        cell('b-head').deleted = true;
        roots.remove('Tb');
        status = 'Ta';
        record(
          'emptyReturn',
          '空 B · 释放 HB 并返回 Ta',
          'B 为空时四步主流程不适用，否则将使用已释放的 Tb。保留 A，单独释放 B 的头结点；两表都空也适用。',
          milestone: true,
        );
        roots['T'] = roots.remove('Ta')!;
        record(
          'returnA',
          '返回原尾指针',
          '结果仍是 A 的完整循环，操作次数与元素个数无关。',
          milestone: true,
        );
        return builder.build();
      }
      roots['p'] = cell(ta).next;
      record('save', '① p = Ta->next', 'p 保存 HA，确保稍后可以封闭合并后的环。', reads: 1);
      cell(ta).next = cell(cell(roots['Tb']!).next).next;
      changed = '$ta-next';
      record(
        'connect',
        '② Ta->next = Tb->next->next',
        'A 尾部直接接到 B 首元；不遍历 A 或 B。',
        writes: 1,
        reads: 2,
      );
      cell('b-head').deleted = true;
      changed = null;
      record(
        'free',
        '③ delete Tb->next',
        '释放冗余 HB。此微步 Tb.next 暂时悬空，下一步只覆盖它，绝不解引用已释放的头结点。Dart 下一步解除引用，由 GC 回收。',
        milestone: true,
      );
      cell(roots['Tb']!).next = roots['p']!;
      changed = '${roots['Tb']}-next';
      record(
        'close',
        '④ Tb->next = p',
        'B 尾部回接 HA，形成包含 A、B 全部元素的单循环链。',
        writes: 1,
      );
      final tail = roots['Tb']!;
      roots
        ..clear()
        ..['T'] = tail;
      status = 'T = 原 Tb';
      changed = null;
      record(
        'return',
        '返回合并后的尾指针',
        '只做常数次指针读取与两次 next 写入；无逐结点扫描。模拟场景绘制成本不计入算法复杂度。',
        milestone: true,
      );
      return builder.build();
    }
    roots['p'] = cell('a-head').next;
    var j = 1;
    vars['j'] = '1';
    record('cursor', 'p 指向首元', '插入在 p 之前；尾插时 p 可以为 HA。删除不能删除 HA。');
    while (roots['p'] != 'a-head' && j < input.position) {
      roots['p'] = cell(roots['p']!).next;
      j++;
      vars['j'] = '$j';
      record('walk', '沿 next 定位 p', '按位序定位是 O(n)；后续已知结点的局部修改是 O(1)。', reads: 1);
    }
    final invalid =
        input.position < 1 ||
        j != input.position ||
        (op == CircularOperation.delete && roots['p'] == 'a-head');
    if (invalid) {
      status = 'ERROR';
      record(
        'bounds',
        'ERROR · 位序越界',
        '插入合法范围 1～n+1，删除 1～n；结构保持原样。',
        error: true,
      );
      return builder.build();
    }
    record('bounds', '定位成功', 'p=${address(roots['p']!)}。');
    final p = cell(roots['p']!);
    if (op == CircularOperation.delete) {
      output = p.data;
      record('read', '保存被删元素', 'e=p->data=$output。', reads: 1);
      cell(p.prior).next = p.next;
      changed = '${p.prior}-next';
      record(
        'deleteNext',
        '① p->prior->next = p->next',
        '先让前驱绕过 p；p 局部变量仍持有待删结点。',
        writes: 1,
      );
      cell(p.next).prior = p.prior;
      changed = '${p.next}-prior';
      record(
        'deletePrior',
        '② p->next->prior = p->prior',
        '再让后继反向连接前驱；删除唯一元素时 HA 的两指针均回到自身。',
        writes: 1,
      );
      p.deleted = true;
      roots.remove('p');
      changed = null;
      record('free', '释放 p', 'C99 释放后清除局部指针；Dart 清除引用由 GC 回收。');
    } else {
      final s = allocate(
        'new',
        input.value,
        p.id == 'a-head' ? 152 + input.a.length * 112.0 : p.x - 56,
        350,
      );
      roots['s'] = s.id;
      record(
        'allocate',
        '分配新结点 s',
        '新结点 data 已写入，prior/next 初始为空；由 s 持有，不会误报泄漏。',
        allocations: 1,
      );
      s.prior = p.prior;
      changed = 'new-prior';
      record(
        'first',
        '① s->prior = p->prior',
        '先保存原前驱。接链期间双向字段可能暂不一致，应在四步后恢复。',
        writes: 1,
      );
      void second() {
        cell(p.prior).next = s.id;
        changed = '${p.prior}-next';
        record(
          'second',
          wrong ? '错误② · 改到了 s->next' : '② p->prior->next = s',
          wrong
              ? '由于 p.prior 已变成 s，②实际执行 s.next=s，覆盖了第③步的 s.next=p，形成自环。'
              : '通过尚未改写的 p.prior 找到原前驱，令其 next 指向 s。',
          writes: 1,
          error: wrong,
          milestone: wrong,
        );
      }

      void third() {
        s.next = p.id;
        changed = 'new-next';
        record('third', '③ s->next = p', '让新结点连接后继 p。', writes: 1);
      }

      void fourth() {
        p.prior = s.id;
        changed = '${p.id}-prior';
        record(
          'fourth',
          wrong ? '错误④ · 提前覆盖 p->prior' : '④ p->prior = s',
          wrong
              ? 'p.prior 提前指向 s；②再通过它寻找原前驱就会写错对象。原前驱仍保存在 s.prior 中，但这段误序代码没有使用它。'
              : '最后再修改 p.prior；此时四个链接都已正确建立。',
          writes: 1,
          error: wrong,
          milestone: wrong,
        );
      }

      if (wrong) {
        status = '误序反例';
        fourth();
        third();
        second();
        return builder.build();
      }
      second();
      third();
      fourth();
      roots.remove('s');
    }
    roots.remove('p');
    vars.remove('j');
    changed = null;
    status = 'OK';
    record(
      'return',
      '${names[op.index]} 完成',
      'next/prior 恢复互为前后继，正向与反向数据次序互逆。',
      milestone: true,
    );
    return builder.build();
  }
}
