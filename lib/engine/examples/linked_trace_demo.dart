import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../vm/algorithm_module.dart';
import '../vm/trace_builder.dart';

enum LinkedDemoInput { normal, broken, empty }

/// Engine fixture only. Not a completed textbook lesson or progress entry.
class LinkedTraceDemo implements AlgorithmModule<LinkedDemoInput> {
  const LinkedTraceDemo();
  @override
  String get id => 'engine.linked-preview';
  @override
  ValidationResult<LinkedDemoInput> validateInput(String raw) {
    for (final value in LinkedDemoInput.values) {
      if (value.name == raw.trim()) return ValidationResult.success(value);
    }
    return const ValidationResult.failure('请选择 normal、broken 或 empty 引擎示例');
  }

  @override
  List<AlgorithmPreset<LinkedDemoInput>> get presets => const [
    AlgorithmPreset(id: 'normal', name: '安全插入', input: LinkedDemoInput.normal),
    AlgorithmPreset(id: 'broken', name: '断链反例', input: LinkedDemoInput.broken),
    AlgorithmPreset(id: 'empty', name: '空链表边界', input: LinkedDemoInput.empty),
  ];
  @override
  TraceTimeline generateTrace(LinkedDemoInput input) {
    final broken = input == LinkedDemoInput.broken;
    final empty = input == LinkedDemoInput.empty;
    final code = <CodeLang, List<String>>{
      CodeLang.cLike: [
        '// L 指向头结点',
        's = NewNode(21);',
        broken ? '// 错误：尚未保存 L->next' : 's->next = L->next;',
        'L->next = s;',
        's = NULL;',
        'return OK;',
      ],
      CodeLang.c99: [
        '/* L: head node */',
        'Node *s = new_node(21);',
        broken ? '/* missing: s->next = L->next; */' : 's->next = L->next;',
        'L->next = s;',
        's = NULL;',
        'return 0;',
      ],
      CodeLang.dart: [
        '// L is the head',
        'var s = Node(21);',
        broken ? '// missing: s.next = L.next;' : 's.next = L.next;',
        'L.next = s;',
        's = null;',
        'return;',
      ],
    };
    var nodes = <SceneNode>[
      const SceneNode(
        id: 'head',
        label: '头结点',
        x: 32,
        y: 100,
        width: 88,
        shape: NodeShape.linkedCell,
        memoryAddress: '0x1000',
      ),
      if (!empty) ...[
        const SceneNode(
          id: 'a',
          label: '12',
          x: 288,
          y: 100,
          width: 88,
          shape: NodeShape.linkedCell,
          memoryAddress: '0x1040',
        ),
        const SceneNode(
          id: 'b',
          label: '34',
          x: 416,
          y: 100,
          width: 88,
          shape: NodeShape.linkedCell,
          memoryAddress: '0x1080',
        ),
      ],
    ];
    var edges = <SceneEdge>[
      SceneEdge(
        id: 'head.next',
        fromNodeId: 'head',
        toNodeId: empty ? nullNodeId : 'a',
        fromPort: EdgePort.next,
      ),
      if (!empty) ...[
        const SceneEdge(
          id: 'a.next',
          fromNodeId: 'a',
          toNodeId: 'b',
          fromPort: EdgePort.next,
        ),
        const SceneEdge(
          id: 'b.next',
          fromNodeId: 'b',
          toNodeId: nullNodeId,
          fromPort: EdgePort.next,
        ),
      ],
    ];
    var pointers = <PointerBadge>[
      const PointerBadge(id: 'L', label: 'L', targetNodeId: 'head'),
    ];
    SceneSnapshot snapshot() => SceneSnapshot(
      nodes: nodes,
      edges: edges,
      pointers: pointers,
      auxTables: [
        AuxTableSnapshot(
          id: 'memory',
          title: '指针快照',
          columns: const ['端口', '目标'],
          rows: edges
              .map(
                (e) => [e.id, e.toNodeId == nullNodeId ? 'NULL' : e.toNodeId],
              )
              .toList(),
        ),
      ],
    );
    final recorder = TraceBuilder(
      moduleId: id,
      inputSummary: presets.firstWhere((p) => p.input == input).name,
      codeLines: code,
      trackLinkedOwnership: true,
    );
    void record(
      int line,
      String title,
      String explain, {
      int reads = 0,
      int writes = 0,
      int allocate = 0,
      int space = 0,
      bool milestone = false,
      bool error = false,
      bool returned = false,
    }) {
      recorder.step(
        title: title,
        explain: explain,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: {'L': 'head', 's': line < 2 || line >= 5 ? 'NULL' : 'x'},
        scene: snapshot(),
        callStack: returned
            ? []
            : [
                const StackActivationRecord(
                  id: 'insert',
                  functionName: 'InsertPreview',
                  arguments: {'value': '21'},
                  returnLocation: 'Main',
                ),
              ],
        deltaRead: reads,
        deltaWrite: writes,
        deltaAllocate: allocate,
        deltaSpace: space,
        statementCounts: {'line.$line': 1},
        milestone: milestone,
        error: error,
      );
    }

    record(1, '初始链表', '命名外指针 L 保存头结点。', milestone: true);
    nodes = [
      ...nodes,
      const SceneNode(
        id: 'x',
        label: '21',
        x: 160,
        y: 210,
        width: 88,
        shape: NodeShape.linkedCell,
        visualState: NodeVisualState.active,
        memoryAddress: '0x10C0',
      ),
    ];
    edges = [
      ...edges,
      const SceneEdge(
        id: 'x.next',
        fromNodeId: 'x',
        toNodeId: nullNodeId,
        fromPort: EdgePort.next,
      ),
    ];
    pointers = [
      ...pointers,
      const PointerBadge(id: 's', label: 's', targetNodeId: 'x'),
    ];
    record(2, '分配新结点', 's 暂存新结点，尚未接入主链。', allocate: 1, space: 1);
    if (!broken) {
      edges = edges
          .map(
            (e) => e.id == 'x.next'
                ? e.copyWith(toNodeId: empty ? nullNodeId : 'a')
                : e,
          )
          .toList();
    }
    record(
      3,
      broken ? '跳过保存后继' : '先保存后继',
      broken ? '这里故意省略 s->next = L->next，下一步将丢失旧链。' : '先让新结点保存原后继，再修改主链。',
      reads: broken ? 0 : 1,
      writes: broken ? 0 : 1,
    );
    edges = edges
        .map((e) => e.id == 'head.next' ? e.copyWith(toNodeId: 'x') : e)
        .toList();
    nodes = nodes.map((n) => n.id == 'x' ? n.copyWith(y: 100) : n).toList();
    record(
      4,
      broken ? '断链：不可达结点' : '接入主链',
      broken ? '12、34 不再被任何外指针访问，已标记泄漏；可回退观察出错前状态。' : 'L->next 指向新结点，原后继仍然可达。',
      writes: 1,
      milestone: true,
      error: broken,
    );
    if (broken) return recorder.build();
    pointers = pointers.where((p) => p.id != 's').toList();
    record(5, '释放临时引用', '新结点由主链持有，清除 s 不会丢失结点。', writes: 1, space: -1);
    record(6, '返回', '预览完成。可拖动时间轴或倒放核对每一步。', milestone: true, returned: true);
    return recorder.build();
  }
}
