part of 'bitree_traverse.dart';

class _TreeWorkshop {
  _TreeWorkshop(this.input, this.root)
    : diagram = _TreeDiagram(root),
      builder = TraceBuilder(
        moduleId: 'ch5_bitree_traverse',
        inputSummary: input.sequence,
        codeLines: {
          for (final l in CodeLang.values) l: _workshopListing(input.lesson, l),
        },
      );
  final TreeInput input;
  final BinaryNode? root;
  final _TreeDiagram diagram;
  final TraceBuilder builder;
  TreeLesson get mode => input.lesson;
  final grown = <String>{}, visited = <String>{}, answers = <String, int>{};
  final output = <String>[],
      calls = <StackActivationRecord>[],
      queue = Queue<BinaryNode>();
  late final tokens = _symbols(input.sequence);
  late final inorder = diagram.ordered.map((n) => n.label).toList();
  late final ranks = {for (final (i, n) in diagram.ordered.indexed) n.id: i};
  late final order = _symbols(
    traversalSequence(
      root,
      mode == TreeLesson.postIn ? TreeLesson.postorder : TreeLesson.preorder,
    ),
  );
  int cursor = 0;
  late final width = math.max(190.0, diagram.nodes.length * 80.0 + 100);
  late final height = math.max(160.0, diagram.levels.length * 110.0 + 70);
  bool get growing => mode == TreeLesson.create || mode.isReconstruction;
  String get function => BiTreeModule.names[mode.index];

  void step(
    int line,
    String title,
    String explain, {
    BinaryNode? focus,
    Map<String, String> vars = const {},
    bool allocate = false,
    int queueDelta = 0,
    bool milestone = false,
  }) {
    final copying = mode == TreeLesson.copy;
    final table = mode == TreeLesson.levelOrder
        ? AuxTableSnapshot(
            id: 'queue',
            title: '队头 → 队尾',
            columns: ['指针', '值'],
            rows: [
              for (final n in queue) [n.id, n.label],
            ],
          )
        : AuxTableSnapshot(
            id: 'locals',
            title: '当前调用',
            columns: ['变量', '值'],
            rows: [
              for (final e in vars.entries) [e.key, e.value],
            ],
          );
    final lines = [line];
    builder.step(
      title: title,
      explain: explain,
      cLikeLines: lines,
      c99Lines: lines,
      dartLines: lines,
      callStack: calls,
      deltaAllocate: allocate ? 1 : 0,
      deltaSpace: queueDelta,
      milestone: milestone || allocate,
      vars: {
        '输出': output.join(),
        '画布宽': '${copying ? width * 2 : width}',
        '画布高': '$height',
        ...vars,
      },
      scene: SceneSnapshot(
        layoutMode: SceneLayoutMode.tree,
        auxTables: [table],
        nodes: [
          for (final n in diagram.nodes)
            if (!growing || grown.contains(n.id))
              n.copyWith(
                visualState: focus?.id == n.id
                    ? NodeVisualState.active
                    : visited.contains(n.id)
                    ? NodeVisualState.sorted
                    : NodeVisualState.normal,
                indexBadge: answers[n.id]?.toString(),
              ),
          if (copying)
            for (final n in diagram.nodes)
              if (grown.contains(n.id))
                n.copyWith(
                  id: 'copy-${n.id}',
                  x: n.x + width,
                  visualState: focus?.id == n.id
                      ? NodeVisualState.active
                      : NodeVisualState.sorted,
                ),
        ],
        edges: [
          for (final e in diagram.edges)
            if (!growing || grown.contains(e.toNodeId)) e,
          if (copying)
            for (final e in diagram.edges)
              if (grown.contains(e.toNodeId))
                e.copyWith(
                  id: 'copy-${e.id}',
                  fromNodeId: 'copy-${e.fromNodeId}',
                  toNodeId: 'copy-${e.toNodeId}',
                ),
        ],
        zones: copying
            ? [
                SceneZoneOverlay(
                  id: 'original',
                  label: '原树',
                  x: 4,
                  y: 4,
                  width: width - 8,
                  height: height - 8,
                ),
                SceneZoneOverlay(
                  id: 'copy',
                  label: '副本',
                  x: width + 4,
                  y: 4,
                  width: width - 8,
                  height: height - 8,
                ),
              ]
            : [],
      ),
    );
  }

  TraceTimeline record() {
    step(
      1,
      function,
      mode == TreeLesson.levelOrder ? '从空队列开始。' : '从根开始，逐次查看调用与返回。',
    );
    if (mode == TreeLesson.levelOrder) {
      _levelOrder();
    } else {
      final result = _visit(root, '根', 0, 0, diagram.nodes.length);
      final stat = mode == TreeLesson.depth || mode == TreeLesson.count;
      step(
        mode.isReconstruction ? 7 : 6,
        '$function完成',
        stat
            ? '根调用返回 $result。'
            : mode == TreeLesson.copy
            ? '原树与副本的结点一一对应。'
            : '全部输入已处理。',
        vars: {
          '结果': stat
              ? '$result'
              : mode == TreeLesson.copy
              ? '副本 ${grown.length} 个结点'
              : '已建 ${grown.length} 个结点',
        },
        milestone: true,
      );
    }
    return builder.build();
  }

  void _levelOrder() {
    if (root != null) queue.add(root!);
    step(
      2,
      '检查根',
      root == null ? '空树没有可入队的结点。' : '根结点入队。',
      focus: root,
      queueDelta: queue.length,
    );
    while (queue.isNotEmpty) {
      final n = queue.removeFirst();
      step(3, '出队 ${n.label}', '从队头取出 ${n.id}。', focus: n, queueDelta: -1);
      output.add(n.label);
      visited.add(n.id);
      step(4, '访问 ${n.label}', '将该结点追加到层序输出。', focus: n, milestone: true);
      for (final (child, line, side) in [(n.left, 5, '左'), (n.right, 6, '右')]) {
        if (child != null) queue.add(child);
        step(
          line,
          child == null ? '$side孩子为空' : '$side孩子 ${child.label} 入队',
          child == null ? '继续检查下一位置。' : '追加到队尾，等待本层较早的结点处理完毕。',
          focus: child ?? n,
          queueDelta: child == null ? 0 : 1,
        );
      }
    }
    step(7, '层序遍历完成', '队列已空。', milestone: true);
  }

  int _visit(BinaryNode? n, String slot, int a, int b, int length) {
    final parent = calls.lastOrNull;
    calls.add(
      StackActivationRecord(
        id: 'call-$slot',
        functionName: function,
        arguments: {'位置': slot, '结点': n?.label ?? 'NULL'},
        returnLocation: parent?.arguments['位置'] ?? '主程序',
        parentCallId: parent?.id,
      ),
    );
    final context = <String, String>{'位置': slot};
    if (mode == TreeLesson.create) {
      context['本调用字符'] = tokens[cursor++];
    }
    if (mode.isReconstruction) {
      context.addAll({
        mode == TreeLesson.postIn ? '后序区间' : '先序区间': order
            .sublist(a, a + length)
            .join(),
        '中序区间': inorder.sublist(b, b + length).join(),
        '中序起点': '$b',
      });
    }
    void emit(
      int line,
      String title,
      String explain, {
      bool allocate = false,
      bool key = false,
    }) {
      if (mode == TreeLesson.create) {
        context.addAll({'游标': '$cursor', '字符': tokens[cursor - 1]});
      }
      calls[calls.length - 1] = calls.last.copyWith(locals: Map.of(context));
      step(
        line,
        title,
        explain,
        focus: n,
        vars: context,
        allocate: allocate,
        milestone: key,
      );
    }

    emit(
      1,
      '进入 $slot',
      mode == TreeLesson.create
          ? '读取第 $cursor 个字符 ${context["本调用字符"]}。'
          : '处理当前位置的子树。',
    );
    if (n == null) {
      context['返回'] = mode == TreeLesson.depth || mode == TreeLesson.count
          ? '0'
          : 'NULL';
      emit(2, '空子树', '$slot 返回 ${context["返回"]}。');
      calls.removeLast();
      return 0;
    }
    final pivot = ranks[n.id]!,
        leftSize = pivot - b,
        rightSize = length - leftSize - 1;
    if (mode.isReconstruction) {
      context.addAll({
        '左区间': inorder.sublist(b, pivot).join(),
        '分割根': n.label,
        '右区间': inorder.sublist(pivot + 1, b + length).join(),
        '分割下标': '$pivot',
      });
      emit(
        3,
        '定位中序分割点 ${n.label}',
        '取${mode == TreeLesson.postIn ? "后序末项" : "先序首项"}，中序下标 $pivot 左右分别有 $leftSize、$rightSize 个结点。',
        key: true,
      );
    }
    final stat = mode == TreeLesson.count || mode == TreeLesson.depth;
    if (!stat) {
      grown.add(n.id);
      emit(
        mode.isReconstruction ? 4 : 3,
        mode == TreeLesson.copy ? '复制 ${n.label}' : '建立 ${n.label}',
        mode == TreeLesson.copy
            ? '从 ${n.id} 复制数据到独立结点 copy-${n.id}。'
            : '将新结点放入 $slot。',
        allocate: true,
      );
    }
    final leftLine = stat
        ? 3
        : mode.isReconstruction
        ? 5
        : 4;
    final rightLine = leftLine + 1;
    final childA = mode == TreeLesson.postIn ? a : a + 1;
    emit(leftLine, '递归进入左子树', '保留当前调用，转向 ${n.label} 的左孩子。');
    final l = _visit(n.left, '${n.id}.left', childA, b, leftSize);
    if (stat) context['左返回'] = '$l';
    emit(rightLine, '递归进入右子树', '左子树已返回，转向 ${n.label} 的右孩子。');
    final r = _visit(
      n.right,
      '${n.id}.right',
      childA + leftSize,
      pivot + 1,
      rightSize,
    );
    final value = mode == TreeLesson.depth
        ? 1 + math.max<int>(l, r)
        : 1 + l + r;
    if (stat) {
      answers[n.id] = value;
      context.addAll({'右返回': '$r', '返回': '$value'});
    } else {
      context['返回'] = mode == TreeLesson.copy ? 'copy-${n.id}' : n.id;
    }
    visited.add(n.id);
    emit(
      rightLine + 1,
      '${n.label} 返回 ${context["返回"]}',
      stat
          ? mode == TreeLesson.depth
                ? 'max($l, $r) + 1 = $value。'
                : '$l + $r + 1 = $value。'
          : '左右孩子均已处理。',
      key: true,
    );
    calls.removeLast();
    return value;
  }
}
