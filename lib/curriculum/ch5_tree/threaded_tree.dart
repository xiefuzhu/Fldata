import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import 'bitree_traverse.dart';

part 'threaded_tree_source.dart';

class ThreadedTreeModule implements AlgorithmModule<TreeInput> {
  const ThreadedTreeModule({this.traversalOnly = false});
  final bool traversalOnly;
  @override
  String get id => 'ch5_threaded_tree';
  @override
  List<AlgorithmPreset<TreeInput>> get presets => const [
    AlgorithmPreset(id: 'sample', name: '教材树 · 七个结点', input: TreeInput()),
    AlgorithmPreset(
      id: 'figure',
      name: '图 5.16 · 表达式树',
      input: TreeInput(sequence: '-+a##*b##-c##d##/e##f##'),
    ),
    AlgorithmPreset(
      id: 'right',
      name: '连续右孩子',
      input: TreeInput(sequence: 'A#B#C##'),
    ),
    AlgorithmPreset(
      id: 'single',
      name: '单结点',
      input: TreeInput(sequence: 'A##'),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '空树',
      input: TreeInput(sequence: '#'),
    ),
  ];
  @override
  ValidationResult<TreeInput> validateInput(String raw) =>
      const BiTreeModule().validateInput(raw);
  @override
  TraceTimeline generateTrace(TreeInput input) =>
      _Threading(input, traversalOnly).run();
}

class _Cell {
  _Cell(this.id, this.data);
  final String id, data;
  _Cell? left, right;
  bool lTag = false, rTag = false;
}

class _Threading {
  _Threading(TreeInput input, this.traversalOnly)
    : builder = TraceBuilder(
        moduleId: 'ch5_threaded_tree',
        inputSummary: input.sequence,
        codeLines: {
          for (final lang in CodeLang.values)
            lang: _threadSource(traversalOnly, lang),
        },
      ) {
    _Cell? make(BinaryNode? n) {
      if (n == null) return null;
      final cell = _Cell(n.id, n.label);
      cells.add(cell);
      cell.left = make(n.left);
      cell.right = make(n.right);
      return cell;
    }

    root = make(readPreorder(input.sequence));
    final template = SceneSnapshot(
      nodes: [
        for (final cell in [head, ...cells])
          SceneNode(
            id: cell.id,
            label: cell.data,
            x: 0,
            y: 0,
            width: 222,
            height: 48,
          ),
      ],
      edges: [
        if (root != null) _edge(head, root!, false, false),
        for (final c in cells) ...[
          if (c.left != null) _edge(c, c.left!, false, false),
          if (c.right != null) _edge(c, c.right!, true, false),
        ],
      ],
    );
    final layout = TreeReingoldLayout.arrange(
      template,
      origin: const Vec2(x: 95, y: 52),
      siblingGap: 54,
      levelGap: 66,
    );
    positions = {for (final n in layout.nodes) n.id: n};
  }
  final bool traversalOnly;
  final TraceBuilder builder;
  final head = _Cell('Thrt', 'Thrt');
  final cells = <_Cell>[];
  late final _Cell? root;
  late final Map<String, SceneNode> positions;
  _Cell? pre;
  bool hasHead = false;
  final calls = <StackActivationRecord>[];
  final output = StringBuffer();

  SceneEdge _edge(_Cell from, _Cell to, bool right, bool thread) => SceneEdge(
    id: '${from.id}.${right ? "R" : "L"}',
    fromNodeId: from.id,
    toNodeId: to.id,
    fromPort: right ? EdgePort.rchild : EdgePort.lchild,
    style: thread ? EdgeStyle.dashedThread : EdgeStyle.solidArrow,
    curvature: thread ? (from == head || to == head ? 86 : 48) : 0,
  );

  void frame(
    int line,
    String title,
    String explain, {
    _Cell? p,
    String? field,
    bool visit = false,
    bool key = false,
    int allocated = 0,
  }) {
    final visible = [if (hasHead) head, ...cells];
    final rows = [
      for (final c in visible)
        [
          c.id,
          c.lTag ? '1' : '0',
          c.left?.id ?? 'NULL',
          c.data,
          c.right?.id ?? 'NULL',
          c.rTag ? '1' : '0',
        ],
    ];
    final edges = <SceneEdge>[];
    for (final c in visible) {
      for (final (target, right, tag) in [
        (c.left, false, c.lTag),
        (c.right, true, c.rTag),
      ]) {
        if (target != null) {
          final e = _edge(c, target, right, tag);
          edges.add(
            field == e.id ? e.copyWith(visualState: NodeVisualState.active) : e,
          );
        }
      }
    }
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      callStack: calls,
      deltaAllocate: allocated,
      deltaWrite: visit ? 1 : 0,
      milestone: key || visit,
      vars: {
        'p': p?.id ?? 'NULL',
        if (!traversalOnly) 'pre': pre?.id ?? 'NULL',
        '输出': output.toString(),
        '栈深': '${calls.length}',
      },
      scene: SceneSnapshot(
        layoutMode: SceneLayoutMode.tree,
        nodes: [
          for (final c in visible)
            positions[c.id]!.copyWith(
              indexBadge: c.id,
              visualState: c == p
                  ? NodeVisualState.active
                  : c == head
                  ? NodeVisualState.sentinel
                  : NodeVisualState.normal,
            ),
        ],
        edges: edges,
        pointers: [
          if (p != null)
            PointerBadge(id: 'p', label: 'p', targetNodeId: p.id, dx: 74),
          if (!traversalOnly && pre != null)
            PointerBadge(
              id: 'pre',
              label: 'pre',
              targetNodeId: pre!.id,
              dx: 138,
            ),
        ],
        auxTables: [
          AuxTableSnapshot(
            id: 'thread-fields',
            title: 'BiThrNode · 存储字段',
            columns: ['地址', 'LTag', 'lchild', 'data', 'rchild', 'RTag'],
            rows: rows,
            highlightedRows: {if (p != null) visible.indexOf(p)},
          ),
        ],
      ),
    );
  }

  TraceTimeline run() {
    // In traversal mode construction prepares the input before recording 5.9.
    if (!traversalOnly) frame(1, '普通二叉链表', '实线表示孩子链接，空指针等待线索化。');
    hasHead = true;
    head.rTag = true;
    head.right = head;
    if (!traversalOnly) {
      frame(
        2,
        '建立头结点',
        'Thrt 的 LTag=0、RTag=1，右指针先指向自身。',
        allocated: 1,
        key: true,
      );
    }
    head.left = root ?? head;
    if (root == null) {
      if (!traversalOnly) {
        frame(3, '空树闭环', 'Thrt 的左右指针都指回 Thrt。', p: head, key: true);
      }
    } else {
      pre = head;
      if (!traversalOnly) {
        frame(4, '从根开始线索化', 'Thrt 左指针指向根，pre 初始化为 Thrt。', p: root);
      }
      _thread(root!);
      pre!.right = head;
      pre!.rTag = true;
      if (!traversalOnly) {
        frame(
          6,
          '末结点指向头结点',
          '最后访问的结点以 Thrt 为后继。',
          p: pre,
          field: '${pre!.id}.R',
          key: true,
        );
      }
      head.right = pre;
      if (!traversalOnly) {
        frame(
          7,
          '头结点连接末结点',
          'Thrt 右线索指向末结点，首结点的左线索指回 Thrt。',
          p: head,
          field: 'Thrt.R',
          key: true,
        );
      }
    }
    if (traversalOnly) _traverse();
    return builder.build();
  }

  void _thread(_Cell p) {
    if (!traversalOnly) {
      calls.add(
        StackActivationRecord(
          id: p.id,
          functionName: 'InThreading',
          arguments: {'p': p.id},
          returnLocation: calls.isEmpty
              ? 'InOrderThreading'
              : 'InThreading(${calls.last.id})',
          parentCallId: calls.lastOrNull?.id,
        ),
      );
      frame(9, '进入 ${p.data}', '当前递归调用处理 ${p.id}。', p: p);
      frame(10, '处理左子树', p.left == null ? '左孩子为空，返回本结点。' : '沿左孩子进入子树。', p: p);
    }
    if (p.left != null) _thread(p.left!);
    if (p.left == null) {
      p.lTag = true;
      p.left = pre;
      if (!traversalOnly) {
        frame(
          11,
          '建立左线索',
          '${p.id} 的左空域指向前驱 ${pre!.id}，LTag 变为 1。',
          p: p,
          field: '${p.id}.L',
          key: true,
        );
      }
    } else if (!traversalOnly) {
      frame(11, '保留左孩子', 'LTag=0，左指针保持指向孩子。', p: p);
    }
    if (pre != head && pre!.right == null) {
      pre!.rTag = true;
      pre!.right = p;
      if (!traversalOnly) {
        frame(
          12,
          '建立前驱的右线索',
          '${pre!.id} 的右空域指向后继 ${p.id}，RTag 变为 1。',
          p: p,
          field: '${pre!.id}.R',
          key: true,
        );
      }
    }
    pre = p;
    if (!traversalOnly) {
      frame(13, 'pre 移至 ${p.data}', '当前结点成为下一次中序访问的前驱。', p: p, key: true);
      frame(14, '处理右子树', p.right == null ? '右孩子为空，返回上一层。' : '沿右孩子进入子树。', p: p);
    }
    if (p.right != null) _thread(p.right!);
    if (!traversalOnly) calls.removeLast();
  }

  void _traverse() {
    var p = head.left!;
    frame(
      2,
      '从 Thrt 左指针出发',
      '输入为已线索化的树。遍历只移动指针 p，遇到 Thrt 即停止。',
      p: p,
      field: 'Thrt.L',
    );
    void move(bool right, int line, String title) {
      final from = p;
      p = (right ? p.right : p.left)!;
      frame(
        line,
        title,
        '从 ${from.id} 沿${right ? "右" : "左"}指针到达 ${p.id}。',
        p: p,
        field: '${from.id}.${right ? "R" : "L"}',
      );
    }

    void visit(int line) {
      output.write(p.data);
      frame(line, '访问 ${p.data}', '将 ${p.id} 的数据追加到中序输出。', p: p, visit: true);
    }

    while (p != head) {
      while (!p.lTag) {
        move(false, 4, '沿左孩子下降');
      }
      visit(5);
      while (p.rTag && p.right != head) {
        move(true, 7, '沿右线索找后继');
        visit(8);
      }
      move(true, 10, p.rTag ? '沿末结点线索返回 Thrt' : '转入右子树');
    }
    frame(11, '遍历结束', 'p 已回到 Thrt，整个遍历的调用栈深度为 0。', p: p, key: true);
  }
}
