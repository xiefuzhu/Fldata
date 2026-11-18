part of 'bitree_traverse.dart';

List<String> _listing(TreeLesson mode, CodeLang lang) {
  final dart = lang == CodeLang.dart, pseudo = lang == CodeLang.cLike;
  if (mode == TreeLesson.properties) {
    return [
      '// 二叉树性质（根为第 1 层）',
      '// 第 i 层至多 2^(i-1) 个节点',
      '// 深度 k 的树至多 2^k-1 个节点',
      '// 对非空二叉树：n0=n2+1',
      '// 非空完全二叉树：k=floor(log2(n))+1',
      '// 完全树按层编号：parent=i/2 取整，left=2i，right=2i+1',
    ];
  }
  if (mode == TreeLesson.stack) {
    if (pseudo) {
      return [
        '中序遍历(T)',
        '  S ← 空栈，p ← T',
        '  当 p 非空或 S 非空',
        '    若 p 非空：Push(S,p)',
        '      p ← p.left',
        '    否则 q ← Pop(S)',
        '      Visit(q)',
        '      p ← q.right',
        '  结束',
      ];
    }
    return [
      dart
          ? 'void inorder(BinaryNode? root, void Function(String) visit) {'
          : 'void inorder(BiTree root) {',
      dart
          ? '  final s=<BinaryNode>[]; var p=root;'
          : '  SqStack s; InitStack(&s); BiTree p=root,q;',
      dart
          ? '  while(p!=null || s.isNotEmpty) {'
          : '  while(p || !StackEmpty(s)) {',
      dart ? '    if(p!=null) { s.add(p);' : '    if(p) { Push(&s,p);',
      dart ? '      p=p.left;' : '      p=p->lchild;',
      dart
          ? '    } else { final q=s.removeLast();'
          : '    } else { Pop(&s,&q);',
      dart ? '      visit(q.label);' : '      Visit(q->data);',
      dart ? '      p=q.right; }' : '      p=q->rchild; }',
      '  } }',
    ];
  }
  String tap(TreeLesson phase, String side) {
    if (phase != mode) return '  // $side';
    return pseudo
        ? '  访问 T（$side）'
        : dart
        ? '  visit(t.label); // $side'
        : '  Visit(t->data); // $side';
  }

  return [
    pseudo
        ? '遍历(T)'
        : dart
        ? 'void walk(BinaryNode? t, void Function(String) visit) {'
        : 'void walk(BiTree t) {',
    pseudo
        ? '  若 T 为空则返回'
        : dart
        ? '  if(t==null) return;'
        : '  if(!t) return;',
    tap(TreeLesson.preorder, '左切点'),
    pseudo
        ? '  遍历左子树'
        : dart
        ? '  walk(t.left,visit);'
        : '  walk(t->lchild);',
    tap(TreeLesson.inorder, '底切点'),
    pseudo
        ? '  遍历右子树'
        : dart
        ? '  walk(t.right,visit);'
        : '  walk(t->rchild);',
    tap(TreeLesson.postorder, '右切点'),
    pseudo ? '结束' : '}',
  ];
}

TraceTimeline _recordTree(TreeInput input, BinaryNode? root) {
  final diagram = _TreeDiagram(root), mode = input.lesson;
  final builder = TraceBuilder(
    moduleId: 'ch5_bitree_traverse',
    inputSummary: input.sequence,
    codeLines: {for (final lang in CodeLang.values) lang: _listing(mode, lang)},
  );
  final output = <String>[],
      seen = <String>{},
      stack = <BinaryNode>[],
      calls = <StackActivationRecord>[];
  final stats = <List<String>>[];
  var tour = -1;
  void step(
    int line,
    String title,
    String explain, {
    BinaryNode? focus,
    BinaryNode? p,
    BinaryNode? q,
    String side = '',
    bool emit = false,
    bool milestone = false,
  }) {
    if (emit) {
      output.add(focus!.label);
      seen.add(focus.id);
    }
    final lines = [line];
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: lines,
      c99Lines: lines,
      dartLines: lines,
      callStack: calls,
      deltaWrite: emit ? 1 : 0,
      milestone: milestone || emit,
      vars: {
        '输出': output.join(),
        '轨迹序号': '$tour',
        '切点': side,
        '节点': focus?.id ?? '',
        '采集': emit ? '是' : '否',
        if (mode == TreeLesson.stack) ...{
          'p': p?.id ?? 'NULL',
          'q': q?.id ?? 'NULL',
        },
      },
      scene: SceneSnapshot(
        layoutMode: SceneLayoutMode.tree,
        nodes: [
          for (final n in diagram.nodes)
            n.copyWith(
              visualState: n.id == focus?.id
                  ? NodeVisualState.active
                  : seen.contains(n.id)
                  ? NodeVisualState.sorted
                  : NodeVisualState.normal,
              indexBadge: mode == TreeLesson.properties
                  ? n.id.substring(1)
                  : null,
            ),
        ],
        edges: diagram.edges,
        pointers: [
          if (mode == TreeLesson.stack && p != null)
            PointerBadge(id: 'p', label: 'p', targetNodeId: p.id),
          if (mode == TreeLesson.stack && q != null)
            PointerBadge(id: 'q', label: 'q', targetNodeId: q.id, dy: 35),
        ],
        auxTables: [
          if (mode == TreeLesson.properties)
            AuxTableSnapshot(
              id: 'properties',
              title: '性质与当前树',
              columns: ['性质', '本树'],
              rows: stats,
            )
          else if (mode == TreeLesson.stack)
            AuxTableSnapshot(
              id: 'stack',
              title: 'SqStack<BiTree> · 栈底到栈顶',
              columns: ['槽', '指针', '值'],
              rows: [
                for (var i = 0; i < stack.length; i++)
                  ['$i', stack[i].id, stack[i].label],
              ],
            )
          else
            AuxTableSnapshot(
              id: 'visit',
              title: '已采集节点',
              columns: ['位序', '值'],
              rows: [
                for (var i = 0; i < output.length; i++) ['${i + 1}', output[i]],
              ],
            ),
        ],
      ),
    );
  }

  if (mode == TreeLesson.properties) {
    final n = diagram.nodes.length,
        k = diagram.levels.length,
        complete = n > 0 && diagram.maxIndex == BigInt.from(n);
    step(1, '二叉树的五条性质', '节点旁的数字表示它在完全二叉树中的位置。');
    for (var i = 1; i <= k; i++) {
      stats.add(['第 $i 层', '${diagram.levels[i]} ≤ ${BigInt.one << (i - 1)}']);
    }
    step(2, '各层节点数', '根在第 1 层，每下一层最多翻倍。', milestone: true);
    stats.add(['深度 $k', '$n ≤ ${(BigInt.one << k) - BigInt.one}']);
    step(3, '深度与容量', '各层容量相加得到 2ᵏ−1。', milestone: true);
    stats.add([
      '叶子与二度节点',
      n == 0 ? '空树' : '${diagram.leaves} = ${diagram.degreeTwo} + 1',
    ]);
    step(4, '叶子与二度节点', '非空树有 n−1 条边，按父节点统计又有 n₁+2n₂ 条。', milestone: true);
    stats.add([
      '完全树深度',
      complete
          ? '⌊log₂ $n⌋ + 1 = ${n.bitLength}'
          : n == 0
          ? '空树深度为 0'
          : '当前树非完全，实际深度 $k',
    ]);
    step(5, '完全树的深度', '完全树非末层全满，末层从左连续填充。', milestone: true);
    stats.add([
      '完全树编号',
      complete
          ? '从 1 到 $n 连续'
          : n == 0
          ? '无节点'
          : '位置编号有缺口',
    ]);
    step(
      6,
      '完全树的双亲与孩子',
      '对完全树，i>1 时双亲是 ⌊i/2⌋。2i 与 2i+1 在 1～n 内时分别为左、右孩子。',
      milestone: true,
    );
    if (complete) {
      for (final node in [
        ...diagram.ordered,
      ]..sort((a, b) => a.index.compareTo(b.index))) {
        step(
          6,
          '检查编号 ${node.index} · ${node.label}',
          '双亲 ${node.index == BigInt.one ? "无" : node.index >> 1}，左孩子 ${node.left?.index ?? "无"}，右孩子 ${node.right?.index ?? "无"}。',
          focus: node,
        );
      }
    }
  } else if (mode == TreeLesson.stack) {
    var p = root;
    step(2, '初始化指针栈', 'p 指向根，栈为空。', p: p);
    while (p != null || stack.isNotEmpty) {
      if (p != null) {
        stack.add(p);
        step(
          4,
          'Push(${p.label})',
          '保存指针，再沿左孩子下降。',
          p: p,
          focus: p,
          milestone: true,
        );
        p = p.left;
        step(
          5,
          p == null ? 'p = NULL' : 'p 转向 ${p.label}',
          '已移动到左孩子。',
          p: p,
          focus: p,
        );
      } else {
        final q = stack.removeLast();
        step(6, 'Pop → ${q.label}', '取出最近一个左子树已处理的节点。', q: q, focus: q);
        step(7, '访问 ${q.label}', '将节点追加到中序输出。', q: q, focus: q, emit: true);
        p = q.right;
        step(
          8,
          p == null ? '右孩子为空' : 'p 转向 ${p.label}',
          '继续处理右子树。',
          p: p,
          q: q,
          focus: p,
        );
      }
    }
    step(9, '栈空且 p = NULL', '中序遍历完成。', milestone: true);
  } else {
    step(1, '从根的左侧出发', '同一条轮廓按左、底、右切点记录先、中、后序。');
    void walk(BinaryNode? node, String ret) {
      if (node == null) return;
      calls.add(
        StackActivationRecord(
          id: node.id,
          functionName: 'walk',
          arguments: {'t': node.label},
          returnLocation: ret,
          parentCallId: calls.isEmpty ? null : calls.last.id,
        ),
      );
      void tap(TreeLesson phase, int line, String side) {
        tour++;
        step(
          line,
          '${node.label} · $side切点',
          phase == mode ? '采集节点 ${node.label}。' : '沿轮廓继续。',
          focus: node,
          side: side,
          emit: mode == phase,
        );
      }

      tap(TreeLesson.preorder, 3, '左');
      walk(node.left, '${node.label} · 底切点');
      tap(TreeLesson.inorder, 5, '底');
      walk(node.right, '${node.label} · 右切点');
      tap(TreeLesson.postorder, 7, '右');
      calls.removeLast();
    }

    walk(root, '主程序');
    if (root != null) tour++;
    step(8, '环游完成', root == null ? '空树没有采集点。' : '从根的右侧绕回起点。', milestone: true);
  }
  return builder.build();
}
