import 'dart:math' as math;
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'bst_source.dart';

part 'avl.dart';

enum BstOperation {
  build('建树'),
  search('查找'),
  insert('插入'),
  delete('删除'),
  avl('AVL 插入');

  const BstOperation(this.label);
  final String label;
}

typedef BstCommand = ({BstOperation operation, int key});
const _fig75 = [45, 12, 53, 3, 37, 100, 24, 61, 90, 78];
const _fig710c = [53, 17, 78, 9, 45, 70, 94, 23, 60, 75, 88];

class BstInput {
  const BstInput({
    this.values = _fig710c,
    this.operation = BstOperation.delete,
    this.key = 78,
    this.comparison,
    this.history = const [],
  });
  final List<int> values;
  final List<int>? comparison;
  final BstOperation operation;
  final int key;
  final List<BstCommand> history;

  BstInput operate(
    BstOperation next,
    int target, {
    bool continueResult = false,
  }) => BstInput(
    values: values,
    comparison: comparison,
    operation: next,
    key: target,
    history: next == BstOperation.build || next == BstOperation.avl
        ? const []
        : [
            ...history,
            if (continueResult &&
                (operation == BstOperation.insert ||
                    operation == BstOperation.delete))
              (operation: operation, key: key),
          ],
  );
  static String sequence(List<int> keys) {
    final seen = <int>{};
    return keys.map((k) => seen.add(k) ? '$k' : '$k*').join(' ');
  }
}

class BstModule implements AlgorithmModule<BstInput> {
  const BstModule();
  @override
  String get id => 'ch7_bst_avl_lab';
  @override
  List<AlgorithmPreset<BstInput>> get presets => const [
    AlgorithmPreset(
      id: 'del78',
      name: '图 7.10(c) · 删除双孩子结点 78',
      input: BstInput(),
    ),
    AlgorithmPreset(
      id: 'left',
      name: '图 7.10(a) · 左孩子接替 45',
      input: BstInput(values: [53, 17, 78, 9, 45, 65, 87, 23], key: 45),
    ),
    AlgorithmPreset(
      id: 'right',
      name: '图 7.10(b) · 右孩子接替 78',
      input: BstInput(values: [53, 17, 78, 9, 23, 94, 88], key: 78),
    ),
    AlgorithmPreset(
      id: 'leaf',
      name: '图 7.5(a) · 删除叶子 24',
      input: BstInput(values: _fig75, key: 24),
    ),
    AlgorithmPreset(
      id: 'find100',
      name: '图 7.5(a) · 查找 100',
      input: BstInput(values: _fig75, operation: BstOperation.search, key: 100),
    ),
    AlgorithmPreset(
      id: 'find40',
      name: '图 7.5(a) · 查找 40',
      input: BstInput(values: _fig75, operation: BstOperation.search, key: 40),
    ),
    AlgorithmPreset(
      id: 'ins55',
      name: '图 7.7 · 插入 55',
      input: BstInput(values: _fig75, operation: BstOperation.insert, key: 55),
    ),
    AlgorithmPreset(
      id: 'fig78',
      name: '图 7.8 · 从空树建树',
      input: BstInput(
        values: [45, 24, 53, 45, 12, 24, 90],
        operation: BstOperation.build,
      ),
    ),
    AlgorithmPreset(
      id: 'fig76',
      name: '图 7.6 · 相同六键的两种树形',
      input: BstInput(
        values: [45, 24, 53, 12, 37, 93],
        comparison: [12, 24, 37, 45, 53, 93],
        operation: BstOperation.build,
      ),
    ),
    ..._avlPresets,
    AlgorithmPreset(
      id: 'star',
      name: '重复键与递增序列对照',
      input: BstInput(
        values: [45, 24, 53, 45, 12, 24],
        comparison: [12, 24, 37, 45, 53],
        operation: BstOperation.build,
      ),
    ),
  ];
  @override
  ValidationResult<BstInput> validateInput(String raw) {
    final p = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择二叉排序树预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(BstInput input) => _Run(input, id).record();
}

class _Node {
  _Node(this.id, this.key);
  final String id;
  int key;
  int avlHeight = 1, avlBalance = 0;
  _Node? left, right;
}

class _Tree {
  _Tree(this.prefix);
  final String prefix;
  int serial = 0;
  _Node? root;

  List<_Node> path(int key) {
    final path = <_Node>[];
    var p = root;
    while (p != null) {
      path.add(p);
      if (p.key == key) break;
      p = key < p.key ? p.left : p.right;
    }
    return path;
  }

  _Node add(int key, _Node? parent) {
    final node = _Node('$prefix${++serial}', key);
    if (parent == null) {
      root = node;
    } else if (key < parent.key) {
      parent.left = node;
    } else {
      parent.right = node;
    }
    return node;
  }

  (_Node, bool, int) insert(int key) {
    final pathToKey = path(key), parent = pathToKey.lastOrNull;
    if (parent != null && parent.key == key) {
      return (parent, false, pathToKey.length);
    }
    return (add(key, parent), true, pathToKey.length);
  }

  String field(_Node? parent, _Node old) => parent == null
      ? 'T'
      : identical(parent.left, old)
      ? '${parent.id}.lchild'
      : '${parent.id}.rchild';
  void replace(_Node? parent, _Node old, _Node? next) {
    if (parent == null) {
      root = next;
    } else if (identical(parent.left, old)) {
      parent.left = next;
    } else {
      parent.right = next;
    }
  }
}

class _Run {
  _Run(this.input, String id)
    : b = TraceBuilder(
        moduleId: id,
        inputSummary:
            '${input.operation == BstOperation.avl ? "AVL" : "BST"} · ${input.operation.label} · ${BstInput.sequence(input.values)}',
        codeLines: bstSource(input.operation.name),
      );
  final BstInput input;
  final TraceBuilder b;
  final a = _Tree('n'), other = _Tree('b');
  bool recording = false;
  bool get comparing =>
      input.operation == BstOperation.build && input.comparison != null;
  String result = '—';
  int? step;
  final trail = <_Node>[];
  final stack = <StackActivationRecord>[];
  final roles = <String, _Node?>{};
  _Node? detached, unbalancedRoot;
  String? rotationType;
  TraceTimeline record() {
    if (input.operation != BstOperation.build &&
        input.operation != BstOperation.avl) {
      for (final v in input.values) {
        a.insert(v);
      }
      for (final command in input.history) {
        if (command.operation == BstOperation.insert) {
          a.insert(command.key);
        }
        if (command.operation == BstOperation.delete) {
          remove(command.key);
        }
      }
    }
    roles.clear();
    trail.clear();
    result = '—';
    recording = true;
    switch (input.operation) {
      case BstOperation.build:
        build();
      case BstOperation.avl:
        buildAvl();
      case BstOperation.search:
        searchOrInsert(false);
      case BstOperation.insert:
        searchOrInsert(true);
      case BstOperation.delete:
        remove(input.key);
    }
    return b.build();
  }

  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    _Node? focus,
    _Node? second,
    (_Node, _Node)? graft,
    int comparisons = 0,
    int writes = 0,
    int alloc = 0,
    bool milestone = false,
  }) {
    if (!recording) return;
    final nodes = <SceneNode>[],
        edges = <SceneEdge>[],
        stats = <List<String>>[],
        links = <List<String>>[];
    final trees = [a, if (comparing) other];
    final avl = input.operation == BstOperation.avl;
    final marked = <String>{};
    for (final tree in trees) {
      int total = 0, count = 0;
      final inorder = <int>[];
      int visit(_Node? n, int depth, bool inside) {
        if (n == null) return 0;
        inside = inside || identical(n, unbalancedRoot);
        if (inside) marked.add(n.id);
        count++;
        total += depth;
        final badges = [
          if (n == tree.root) (comparing ? (tree == a ? '树 A' : '树 B') : 'T'),
          for (final role in roles.entries)
            if (role.value == n) role.key,
        ];
        nodes.add(
          SceneNode(
            id: n.id,
            label: '${n.key}',
            x: 0,
            y: 0,
            width: 48,
            height: 48,
            shape: NodeShape.circle,
            groupTag: tree.prefix,
            memoryAddress: n.id,
            logicBadge: badges.isEmpty ? null : badges.join(' · '),
            visualState: n == focus
                ? NodeVisualState.active
                : n == second
                ? NodeVisualState.moving
                : trail.contains(n)
                ? NodeVisualState.comparing
                : NodeVisualState.normal,
          ),
        );
        for (final (child, port) in [
          (n.left, EdgePort.lchild),
          (n.right, EdgePort.rchild),
        ]) {
          if (child != null) {
            edges.add(
              SceneEdge(
                id: '${n.id}.${port.name}',
                fromNodeId: n.id,
                toNodeId: child.id,
                fromPort: port,
                visualState: trail.contains(n) && trail.contains(child)
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
            );
          }
        }
        final row = [
          n.id,
          '${n.key}',
          n.left?.id ?? 'NULL',
          n.right?.id ?? 'NULL',
          '在树中',
        ];
        links.add(row);
        final leftHeight = visit(n.left, depth + 1, inside);
        inorder.add(n.key);
        final rightHeight = visit(n.right, depth + 1, inside);
        if (avl) row.addAll(['${n.avlBalance}', '${leftHeight - rightHeight}']);
        return 1 + math.max(leftHeight, rightHeight);
      }

      final height = visit(tree.root, 1, false);
      stats.add([
        tree == a ? 'A' : 'B',
        '$count',
        '$height',
        count == 0 ? '—' : '$total/$count',
        inorder.join(' '),
      ]);
    }
    var scene = TreeReingoldLayout.arrange(
      SceneSnapshot(nodes: nodes, edges: edges),
      slantSingleChild: true,
      levelGap: 32,
      origin: const Vec2(x: 32, y: 36),
    );
    if (marked.isNotEmpty) {
      scene = _markAvlSubtree(scene, marked, rotationType!);
    }
    if (detached case final d?) {
      final x =
          scene.nodes.fold<double>(16, (m, n) => math.max(m, n.x + n.width)) +
          36;
      scene = scene.copyWith(
        nodes: [
          ...scene.nodes,
          SceneNode(
            id: d.id,
            label: '${d.key}',
            x: x,
            y: 36,
            width: 48,
            height: 48,
            shape: NodeShape.circle,
            visualState: NodeVisualState.moving,
            memoryAddress: d.id,
            logicBadge: '待释放',
          ),
        ],
      );
      links.add([
        d.id,
        '${d.key}',
        d.left?.id ?? 'NULL',
        d.right?.id ?? 'NULL',
        '待释放',
      ]);
    }
    if (graft != null) {
      final (from, to) = graft;
      scene = scene.copyWith(
        edges: [
          ...scene.edges,
          SceneEdge(
            id: 'graft',
            fromNodeId: from.id,
            toNodeId: to.id,
            curvature: 56,
            visualState: NodeVisualState.active,
          ),
        ],
      );
    }
    b.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      callStack: stack,
      deltaCompare: comparisons,
      deltaWrite: writes,
      deltaAllocate: alloc,
      milestone: milestone,
      vars: {
        '阶段': phase,
        '结果': result,
        '旋转类型': ?rotationType,
        '根': a.root?.id ?? 'NULL',
        if (step != null) '已读': '$step',
        if (trail.isNotEmpty) '路径': trail.map((n) => n.id).join(' → '),
        for (final e in roles.entries) e.key: e.value?.id ?? 'NULL',
      },
      scene: scene.copyWith(
        auxTables: [
          AuxTableSnapshot(
            id: 'tree-stats',
            title: '树形与等概率成功 ASL',
            columns: ['树', '结点数', '高度', 'ASL', '中序'],
            rows: stats,
          ),
          AuxTableSnapshot(
            id: 'bst-links',
            title: '二叉链表',
            columns: [
              '结点',
              'key',
              'lchild',
              'rchild',
              '状态',
              if (avl) ...['已更新 BF', '实际 BF'],
            ],
            rows: links,
          ),
        ],
      ),
    );
  }

  void build() {
    step = 0;
    emit(1, '空树', '初始化空树', '按序读入关键字并调用 InsertBST。', milestone: true);
    final sequences = [
      (a, input.values),
      if (comparing) (other, input.comparison!),
    ];
    for (
      var i = 0;
      i < sequences.map((e) => e.$2.length).reduce(math.max);
      i++
    ) {
      final notes = <String>[];
      int checks = 0, created = 0;
      _Node? first, second;
      for (final (tree, seq) in sequences) {
        if (i >= seq.length) continue;
        final key = seq[i];
        final (n, added, visited) = tree.insert(key);
        checks += visited;
        if (added) created++;
        if (tree == a) {
          first = n;
        } else {
          second = n;
        }
        notes.add(
          '${comparing ? (tree == a ? "A　" : "B　") : ""}$key${added ? " 插入 ${n.id}" : "* 已存在，跳过"}',
        );
      }
      step = i + 1;
      emit(
        2,
        '读入',
        '读入第 $step 项',
        notes.join('；'),
        focus: first,
        second: second,
        comparisons: checks,
        writes: created,
        alloc: created,
        milestone: true,
      );
    }
    result = '建树完成';
    emit(3, '完成', result, '等概率成功 ASL 为所有结点所在层数之和除以结点数，根在第一层。', milestone: true);
  }

  void push(_Node? n, bool insert) {
    final fn = insert ? 'InsertBST' : 'SearchBST', id = 'call${stack.length}';
    stack.add(
      StackActivationRecord(
        id: id,
        functionName: fn,
        arguments: {'T': n?.id ?? 'NULL', 'key': '${input.key}'},
        returnLocation: stack.isEmpty ? '调用方' : '递归调用处',
        parentCallId: stack.lastOrNull?.id,
      ),
    );
  }

  void searchOrInsert(bool insert) {
    emit(
      1,
      '开始',
      insert ? '从根开始插入' : '从根开始递归查找',
      '当前根指针 T = ${a.root?.id ?? "NULL"}。',
      milestone: true,
    );
    final key = input.key, path = a.path(key);
    for (final n in path) {
      push(n, insert);
      trail.add(n);
      roles['Tᵢ'] = n;
      final same = key == n.key, left = key < n.key;
      emit(
        same
            ? 2
            : left
            ? 3
            : 4,
        '比较',
        '比较 $key 与 ${n.key}',
        same
            ? '关键字相等。'
            : left
            ? '递归访问左子树。'
            : '递归访问右子树。',
        focus: n,
        comparisons: 1,
      );
    }
    final last = path.lastOrNull;
    _Node? found;
    if (last != null && last.key == key) {
      found = last;
      result = insert ? '重复键，保留 ${last.id}' : '返回 ${last.id}';
      emit(
        2,
        '相等',
        result,
        insert ? '树形和结点数保持原值。' : '返回命中结点地址。',
        focus: last,
        milestone: true,
      );
    } else {
      push(null, insert);
      roles['Tᵢ'] = null;
      emit(1, '空链', '到达 NULL', insert ? '在该空链位置新建叶子。' : '没有匹配结点。');
      if (insert) {
        found = a.add(key, last);
        roles['Tᵢ'] = found;
        result = '插入 ${found.id}';
        emit(
          5,
          '新叶',
          result,
          '新叶子的左右指针均为空。',
          focus: found,
          writes: 1,
          alloc: 1,
          milestone: true,
        );
      } else {
        result = '返回 NULL';
      }
    }
    while (stack.isNotEmpty) {
      stack.removeLast();
      final caller = stack.lastOrNull?.arguments['T'];
      roles['Tᵢ'] = path.where((v) => v.id == caller).firstOrNull;
      emit(
        insert ? 6 : 5,
        stack.isEmpty ? '完成' : '返回',
        stack.isEmpty ? result : '返回上一层',
        insert ? '递归插入结束。' : '查询结果逐层返回到调用方。',
        focus: found,
        milestone: stack.isEmpty,
      );
    }
  }

  void remove(int key) {
    roles.clear();
    trail.clear();
    emit(1, '开始', '定位待删关键字 $key', 'p 从根出发，f 跟随 p 记录它的双亲。', milestone: true);
    final path = a.path(key);
    _Node? f;
    for (final n in path) {
      roles['p'] = n;
      roles['f'] = f;
      trail.add(n);
      emit(
        1,
        '比较',
        '检查 ${n.key}',
        key == n.key
            ? 'p 命中待删记录。'
            : key < n.key
            ? 'f 跟上 p，向左查找。'
            : 'f 跟上 p，向右查找。',
        focus: n,
        comparisons: 1,
      );
      if (n.key != key) f = n;
    }
    final p = path.lastOrNull;
    if (p == null || p.key != key) {
      roles['p'] = null;
      roles['f'] = f;
      result = '未找到 $key';
      emit(2, '完成', result, '查找到空链，原树保持原状。', milestone: true);
      return;
    }
    _Node removed = p;
    _Node? parent = f, next;
    int rewireLine = 8;
    if (p.left != null && p.right != null) {
      var q = p, s = p.left!;
      roles['q'] = q;
      roles['s'] = s;
      trail.add(s);
      emit(
        3,
        '左子树',
        '进入 p 的左子树',
        '令 q = p，s = p.lchild，沿右链寻找中序直接前驱。',
        focus: s,
        second: p,
      );
      while (s.right != null) {
        q = s;
        s = s.right!;
        trail.add(s);
        roles['q'] = q;
        roles['s'] = s;
        emit(4, '沿右链', '沿右链到 ${s.key}', 'q 指向 s 的双亲。', focus: s, second: q);
      }
      emit(
        4,
        '前驱',
        '找到前驱 ${s.key}',
        's 没有右孩子；它的左孩子将在原位置接替它。',
        focus: s,
        second: p,
        milestone: true,
      );
      p.key = s.key;
      emit(
        5,
        '复制',
        '将 s.data 复制到 p',
        'p = ${p.id} 的地址保持不变，两个位置暂时显示同一关键字 ${s.key}。',
        focus: p,
        second: s,
        writes: 1,
        milestone: true,
      );
      removed = s;
      parent = q;
      next = s.left;
      rewireLine = 6;
    } else {
      next = p.left ?? p.right;
      emit(
        7,
        '分类',
        next == null
            ? '删除叶子'
            : p.left != null
            ? '左孩子接替'
            : '右孩子接替',
        next == null ? '把指向 p 的链接置空。' : '把指向 p 的链接改指向唯一孩子 ${next.key}。',
        focus: p,
        second: next,
        milestone: true,
      );
    }
    final field = a.field(parent, removed),
        assignment = '$field ← ${next?.id ?? "NULL"}';
    if (next != null) {
      emit(
        rewireLine,
        '预览重接',
        assignment,
        parent == null ? '提升唯一孩子为新根。' : '蓝色弧线标出即将写入的链接。',
        focus: removed,
        second: next,
        graft: parent == null ? null : (parent, next),
      );
    }
    a.replace(parent, removed, next);
    detached = removed;
    trail.clear();
    emit(
      rewireLine,
      '重接',
      assignment,
      '原结点 ${removed.id} 已从树中摘下，等待释放。',
      focus: next,
      writes: 1,
      milestone: true,
    );
    detached = null;
    roles.removeWhere((_, n) => identical(n, removed));
    result = '已删除 $key';
    emit(9, '释放', '释放 ${removed.id}', '$result，树中剩余结点仍按中序递增。', milestone: true);
  }
}
