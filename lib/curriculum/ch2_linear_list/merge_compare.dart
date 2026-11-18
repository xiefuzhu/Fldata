import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'merge_source.dart';

enum MergeOperation { union, sequential, linked }

class MergeInput {
  const MergeInput({
    this.operation = MergeOperation.linked,
    this.a = const [1, 3, 5],
    this.b = const [2, 3, 6],
  });
  final MergeOperation operation;
  final List<int> a, b;
  MergeInput copyWith({MergeOperation? operation}) =>
      MergeInput(operation: operation ?? this.operation, a: a, b: b);
}

class _Cell {
  _Cell(this.id, this.value, this.x, this.y, this.address, {this.head = false});
  final String id, address;
  final int? value;
  final bool head;
  double x, y;
  String next = nullNodeId;
  bool deleted = false;
}

class MergeCompareModule implements AlgorithmModule<MergeInput> {
  const MergeCompareModule();
  @override
  String get id => 'ch2_merge_compare';
  static const names = ['无序表并集', '顺序有序归并', '链式原地归并'];
  @override
  List<AlgorithmPreset<MergeInput>> get presets => const [
    AlgorithmPreset(id: 'linked', name: '重建 · 交错与相等元素', input: MergeInput()),
    AlgorithmPreset(
      id: 'sq',
      name: '对比 · 新数组 LC',
      input: MergeInput(operation: MergeOperation.sequential),
    ),
    AlgorithmPreset(
      id: 'union',
      name: '集合 · 无序且部分重合',
      input: MergeInput(
        operation: MergeOperation.union,
        a: [5, 1, 3],
        b: [3, 2, 5, 7],
      ),
    ),
    AlgorithmPreset(
      id: 'remainder',
      name: '整串 · B 剩余三结点',
      input: MergeInput(a: [1], b: [2, 4, 6]),
    ),
    AlgorithmPreset(
      id: 'empty-a',
      name: '边界 · A 空表',
      input: MergeInput(a: [], b: [2, 4]),
    ),
    AlgorithmPreset(
      id: 'empty-b',
      name: '边界 · B 空表',
      input: MergeInput(a: [1, 3], b: []),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '边界 · 两表均空',
      input: MergeInput(a: [], b: []),
    ),
    AlgorithmPreset(
      id: 'ties',
      name: '稳定性 · 全相等',
      input: MergeInput(a: [3, 3], b: [3, 3]),
    ),
  ];
  @override
  ValidationResult<MergeInput> validateInput(String raw) {
    final p = raw.split('|');
    if (p.length != 3) return const ValidationResult.failure('格式：操作|A 元素|B 元素');
    final op = MergeOperation.values.where((o) => o.name == p[0]).firstOrNull;
    List<int?> parse(String s) => s.trim().isEmpty
        ? []
        : s.trim().split(RegExp(r'[,，\s]+')).map(int.tryParse).toList();
    final a = parse(p[1]), b = parse(p[2]);
    if (op == null ||
        a.length > 6 ||
        b.length > 6 ||
        [...a, ...b].any((v) => v == null || v.abs() > 99)) {
      return const ValidationResult.failure('每表最多 6 个 −99～99 的整数；留空表示空表。');
    }
    final aa = a.cast<int>(), bb = b.cast<int>();
    if (op == MergeOperation.union &&
        (aa.toSet().length != aa.length || bb.toSet().length != bb.length)) {
      return const ValidationResult.failure('并集按集合定义：各输入表内部不能有重复元素。');
    }
    bool sorted(List<int> v) {
      for (var i = 1; i < v.length; i++) {
        if (v[i] < v[i - 1]) return false;
      }
      return true;
    }

    if (op != MergeOperation.union && (!sorted(aa) || !sorted(bb))) {
      return const ValidationResult.failure('有序归并要求 A、B 各自非递减；请编辑输入或选择预设。');
    }
    return ValidationResult.success(MergeInput(operation: op, a: aa, b: bb));
  }

  @override
  TraceTimeline generateTrace(MergeInput input) {
    if (!validateInput(
      '${input.operation.name}|${input.a.join(',')}|${input.b.join(',')}',
    ).isValid) {
      throw ArgumentError('Invalid merge input');
    }
    final linked = input.operation == MergeOperation.linked,
        union = input.operation == MergeOperation.union;
    final source = MergeSource(input.operation);
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${names[input.operation.index]} · A=${input.a} · B=${input.b}',
      codeLines: source.lines,
      trackLinkedOwnership: linked,
    );
    final cells = <_Cell>[],
        roots = <String, String>{},
        vars = <String, String>{};
    final result = <int>[], accepted = <String>[];
    final arrayA = [...input.a];
    var status = '待执行', changed = '', allocated = false;
    String? ghostFrom;
    double ghostX = 0, ghostY = 0;
    _Cell cell(String id) => cells.firstWhere((c) => c.id == id);
    String address(String id) => id == nullNodeId ? 'NULL' : cell(id).address;
    void makeList(String prefix, List<int> values, double y) {
      final list = <_Cell>[];
      for (var i = -1; i < values.length; i++) {
        final c = _Cell(
          i < 0 ? '$prefix-head' : '$prefix-$i',
          i < 0 ? null : values[i],
          40 + (i + 1) * 96.0,
          y,
          '0x${(0x7000 + cells.length * 32).toRadixString(16)}',
          head: i < 0,
        );
        cells.add(c);
        list.add(c);
      }
      for (var i = 0; i < list.length - 1; i++) {
        list[i].next = list[i + 1].id;
      }
    }

    if (linked) {
      makeList('a', input.a, 130);
      makeList('b', input.b, 310);
      roots.addAll({'LA': 'a-head', 'LB': 'b-head'});
    }
    String chain() {
      final out = <String>[], seen = <String>{};
      var p = cell('a-head').next;
      while (p != nullNodeId && seen.add(p)) {
        out.add('${cell(p).value}');
        p = cell(p).next;
      }
      return out.join(' → ');
    }

    SceneSnapshot snapshot() {
      final nodes = <SceneNode>[],
          edges = <SceneEdge>[],
          pointers = <PointerBadge>[];
      if (linked) {
        for (final c in cells) {
          nodes.add(
            SceneNode(
              id: c.id,
              label: c.head ? (c.id == 'a-head' ? 'HA' : 'HB') : '${c.value}',
              x: c.x,
              y: c.y,
              width: 64,
              height: 48,
              shape: NodeShape.linkedCell,
              memoryAddress: c.address,
              logicBadge: c.deleted
                  ? '已释放'
                  : c.head
                  ? '头结点'
                  : c.id.startsWith('a')
                  ? '来自 A'
                  : '来自 B',
              isDeleted: c.deleted,
              opacity: c.deleted ? .2 : 1,
              visualState: c.head
                  ? NodeVisualState.sentinel
                  : roots.values.contains(c.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
          );
          if (!c.deleted) {
            edges.add(
              SceneEdge(
                id: '${c.id}-next',
                fromNodeId: c.id,
                toNodeId: c.next,
                fromPort: EdgePort.next,
                curvature:
                    c.next != nullNodeId &&
                        (cell(c.next).y != c.y ||
                            (cell(c.next).x - c.x).abs() > 110)
                    ? 48
                    : 0,
                visualState: changed == c.id
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
                weightLabel: changed == c.id ? 'next' : null,
              ),
            );
          }
        }
        for (final e in roots.entries) {
          pointers.add(
            PointerBadge(
              id: e.key,
              label: e.key,
              targetNodeId: e.value,
              dy:
                  -28 -
                  roots.keys
                          .where((key) => roots[key] == e.value)
                          .toList()
                          .indexOf(e.key) *
                      22.0,
            ),
          );
        }
      } else {
        void row(String prefix, List<int?> values, double y, int base) {
          for (var i = 0; i < values.length; i++) {
            nodes.add(
              SceneNode(
                id: '$prefix-$i',
                label: values[i] == null ? '·' : '${values[i]}',
                x: 40 + i * 72.0,
                y: y,
                width: 56,
                height: 48,
                shape: NodeShape.arraySlot,
                indexBadge: '$prefix[$i]',
                memoryAddress: '0x${(base + i * 4).toRadixString(16)}',
                visualState: changed == '$prefix-$i'
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
            );
          }
        }

        row(
          'A',
          [
            ...arrayA,
            if (union)
              for (
                var i = arrayA.length;
                i < input.a.length + input.b.length;
                i++
              )
                null,
          ],
          110,
          0x8000,
        );
        row('B', input.b, 250, 0x9000);
        if (allocated) {
          row(
            'C',
            [
              ...result,
              for (
                var i = result.length;
                i < input.a.length + input.b.length;
                i++
              )
                null,
            ],
            390,
            0xa000,
          );
        }
        for (final key in ['i', 'j', 'k']) {
          final index = int.tryParse(vars[key] ?? '');
          final prefix = key == 'i'
              ? 'A'
              : key == 'j'
              ? 'B'
              : 'C';
          if (index != null &&
              !(union && key == 'i' && index >= input.a.length) &&
              nodes.any((n) => n.id == '$prefix-$index')) {
            pointers.add(
              PointerBadge(
                id: key,
                label: key,
                targetNodeId: '$prefix-$index',
                dy: -52,
              ),
            );
          }
        }
        if (ghostFrom != null) {
          final from = nodes.singleWhere((n) => n.id == ghostFrom);
          nodes.add(
            SceneNode(
              id: 'copy',
              label: from.label,
              x: ghostX,
              y: ghostY,
              width: 56,
              height: 48,
              visualState: NodeVisualState.moving,
              logicBadge: '复制',
            ),
          );
        }
      }
      return SceneSnapshot(
        layoutMode: linked
            ? SceneLayoutMode.freeCanvas
            : SceneLayoutMode.linearMemory,
        nodes: nodes,
        edges: edges,
        pointers: pointers,
        auxTables: [
          AuxTableSnapshot(
            id: 'result',
            title: '合并进度',
            columns: const ['状态', '已确定结果前缀', '从 HA 当前可达'],
            rows: [
              [
                status,
                (union ? arrayA : result).join(' → '),
                linked ? chain() : '—',
              ],
            ],
          ),
          AuxTableSnapshot(
            id: 'heap',
            title: linked ? '复用堆节点（模拟地址）' : '数组槽（模拟 int=4B）',
            columns: const ['ID', '地址', '值', 'next'],
            rows: linked
                ? [
                    for (final c in cells)
                      [
                        c.id,
                        c.address,
                        c.head ? '头结点' : '${c.value}',
                        c.deleted ? '已释放' : address(c.next),
                      ],
                  ]
                : [
                    for (final n in nodes.where((n) => n.id != 'copy'))
                      [n.id, n.memoryAddress!, n.label, '—'],
                  ],
          ),
        ],
      );
    }

    void frame(
      String tag,
      String title,
      String explain, {
      int compare = 0,
      int read = 0,
      int write = 0,
      int move = 0,
      int allocate = 0,
      int space = 0,
      bool milestone = false,
    }) {
      final line = source.tags[tag]!;
      builder.step(
        title: title,
        explain: explain,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: {...vars, for (final e in roots.entries) e.key: address(e.value)},
        scene: snapshot(),
        callStack: [
          StackActivationRecord(
            id: 'merge',
            functionName: linked
                ? 'MergeList_L'
                : union
                ? 'MergeList'
                : 'MergeList_Sq',
            arguments: {'A': '${input.a}', 'B': '${input.b}'},
            locals: {
              ...vars,
              for (final e in roots.entries) e.key: address(e.value),
            },
            returnLocation: '调用方',
          ),
        ],
        deltaCompare: compare,
        deltaRead: read,
        deltaWrite: write,
        deltaMove: move,
        deltaAllocate: allocate,
        deltaSpace: space,
        milestone: milestone,
      );
    }

    frame(
      'entry',
      '进入 · ${names[input.operation.index]}',
      linked
          ? '两条带头结点单链表；稳定 ID 与地址属于节点，穿接时不会重新分配。'
          : union
          ? 'A/B 内部无重复。A 已预留 m+n 容量，追加不移动原有元素。'
          : 'A、B 非递减；相等时优先 A，保留全部重复元素。',
    );
    status = '执行中';
    if (linked) {
      roots.addAll({
        'pa': cell('a-head').next,
        'pb': cell('b-head').next,
        'pc': 'a-head',
        'LC': 'a-head',
      });
      cell('a-head').y = 490;
      frame(
        'init',
        '初始化 pa / pb / pc',
        'LC 复用 HA，pc 是已确定结果的尾部边界；原 next 后缀在覆盖前仍可能可达。',
        read: 2,
      );
      while (roots['pa'] != nullNodeId && roots['pb'] != nullNodeId) {
        final pa = roots['pa']!,
            pb = roots['pb']!,
            takeA = cell(pa).value! <= cell(pb).value!;
        frame(
          'compare',
          '比较 · ${cell(pa).value} ≤ ${cell(pb).value}',
          takeA ? 'A 胜出；相等值也先取 A，保持稳定性。' : 'B 胜出。',
          compare: 1,
          read: 2,
        );
        final key = takeA ? 'pa' : 'pb',
            winner = takeA ? pa : pb,
            pc = roots['pc']!;
        cell(pc).next = winner;
        changed = pc;
        accepted.add(winner);
        result.add(cell(winner).value!);
        cell(winner).x = 40 + accepted.length * 96.0;
        cell(winner).y = 490;
        frame(
          takeA ? 'attachA' : 'attachB',
          '穿接 · pc->next = $key',
          '只修改旧 pc 的 next，胜出节点地址不变；其原后继还保留，$key 暂未前进。',
          write: 1,
          milestone: true,
        );
        changed = '';
        roots[key] = cell(winner).next;
        frame(
          takeA ? 'advanceA' : 'advanceB',
          '前进 · $key',
          '沿胜出节点原 next 保存未处理后缀。',
          read: 1,
        );
        roots['pc'] = winner;
        frame('advanceC', '前进 · pc', 'pc 移到刚接入的节点；下一次会覆盖它的 next。', read: 1);
      }
      final rest = roots['pa'] != nullNodeId ? roots['pa']! : roots['pb']!;
      changed = roots['pc']!;
      cell(changed).next = rest;
      var p = rest;
      while (p != nullNodeId) {
        accepted.add(p);
        result.add(cell(p).value!);
        cell(p).x = 40 + accepted.length * 96.0;
        cell(p).y = 490;
        p = cell(p).next;
      }
      frame(
        'tail',
        '整串挂接 · pc->next = pa ? pa : pb',
        '一侧已空，只写一次 next 接上另一侧整串。画面排布遍历不计入算法操作。',
        write: 1,
        milestone: true,
      );
      changed = '';
      cell('b-head').deleted = true;
      roots.remove('LB');
      frame(
        'free',
        '释放冗余头结点 LB',
        '只释放 HB，B 的数据节点已归入 LC。C99 调用后原 LA/LB 不再作为独立表使用；Dart 由 GC 回收头结点。',
        milestone: true,
      );
      roots
        ..clear()
        ..addAll({'LC': 'a-head'});
      status = '完成';
      frame(
        'return',
        '返回 LC · 原地归并',
        '新增数据节点 0；pa/pb/pc 等固定数量指针占 O(1) 辅助空间。总时间 O(m+n)。',
        milestone: true,
      );
    } else if (union) {
      vars['m'] = '${input.a.length}';
      frame('init', '固定原 A 长度 m', 'B 内部无重复，所以只需查找原 A 前缀；此前追加的 B 元素不可能等于当前元素。');
      for (var j = 0; j < input.b.length; j++) {
        vars.addAll({'j': '$j', 'i': '0', 'e': '${input.b[j]}'});
        frame('read', '取 B[$j] = ${input.b[j]}', '从原 A 前缀开始线性查找。', read: 1);
        var i = 0;
        for (; i < input.a.length; i++) {
          vars['i'] = '$i';
          final found = input.a[i] == input.b[j];
          frame(
            'compare',
            '查找 · A[$i] == e',
            found ? '已存在，不重复追加。' : '不相等，继续查找。',
            compare: 1,
            read: 1,
          );
          if (found) break;
        }
        vars['i'] = '$i';
        if (i == input.a.length) {
          arrayA.add(input.b[j]);
          changed = 'A-${arrayA.length - 1}';
          frame(
            'append',
            '追加 · ${input.b[j]}',
            '原 A 中不存在 e，直接写入预留末槽。',
            write: 1,
            milestone: true,
          );
          changed = '';
        }
      }
      vars.clear();
      status = '完成';
      frame(
        'return',
        '返回 A ∪ B',
        '查找最多 m·n 次，遍历 B 另需 O(n)：总 O(mn+n)，m≥1 时通常记 O(mn)。预留数组容量不计本次辅助分配。',
        milestone: true,
      );
    } else {
      allocated = true;
      frame(
        'allocate',
        '开辟 LC · ${input.a.length + input.b.length} 槽',
        '新结果数组占 m+n 个数据槽；A、B 的数据与地址保留。空结果使用零数据槽。',
        allocate: input.a.isEmpty && input.b.isEmpty ? 0 : 1,
        space: input.a.length + input.b.length,
        milestone: true,
      );
      var i = 0, j = 0;
      vars.addAll({'i': '0', 'j': '0', 'k': '0'});
      frame('init', '初始化 i / j / k', '分别指向 A、B 的候选与 LC 的下一空槽。');
      void copy(bool a, String tag) {
        final index = a ? i : j, value = a ? input.a[i] : input.b[j];
        ghostFrom = '${a ? 'A' : 'B'}-$index';
        ghostX = 40 + index * 72.0;
        ghostY = a ? 110 : 250;
        frame(tag, '读取 · $ghostFrom', '准备复制值 $value；源槽保持原值。', read: 1);
        ghostX = 40 + result.length * 72.0;
        ghostY = 390;
        changed = 'C-${result.length}';
        result.add(value);
        frame(
          tag,
          '写入 · $changed',
          '值复制到独立的 LC 槽，来源地址不变。',
          write: 1,
          move: 1,
          milestone: true,
        );
        ghostFrom = null;
        changed = '';
      }

      while (i < input.a.length && j < input.b.length) {
        final a = input.a[i] <= input.b[j];
        frame(
          'compare',
          '比较 · ${input.a[i]} ≤ ${input.b[j]}',
          a ? '取 A；相等时 A 先进入 LC。' : '取 B。',
          compare: 1,
          read: 2,
        );
        copy(a, a ? 'copyA' : 'copyB');
        if (a) {
          i++;
          vars['i'] = '$i';
        } else {
          j++;
          vars['j'] = '$j';
        }
        frame(a ? 'advanceA' : 'advanceB', '前进来源游标', '仅被选中的输入向后移动一槽。');
        vars['k'] = '${result.length}';
        frame('advanceC', '前进 k', 'LC 下一空槽随写入向后移动。');
      }
      while (i < input.a.length) {
        copy(true, 'tailA');
        i++;
        vars['i'] = '$i';
        vars['k'] = '${result.length}';
        frame('tailA', '复制 A 剩余项', '顺序数组仍需逐项复制，不能只写一个链指针。');
      }
      while (j < input.b.length) {
        copy(false, 'tailB');
        j++;
        vars['j'] = '$j';
        vars['k'] = '${result.length}';
        frame('tailB', '复制 B 剩余项', '顺序数组仍需逐项复制，不能只写一个链指针。');
      }
      status = '完成';
      frame(
        'return',
        '返回 LC · 顺序归并',
        '总共复制 m+n 个值。时间 O(m+n)，新结果空间 O(m+n)；不含结果的工作游标空间 O(1)。',
        milestone: true,
      );
    }
    return builder.build();
  }
}
