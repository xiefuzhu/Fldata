import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';

enum SqListOperation { init, get, locate, insert, delete }

class SqListInput {
  const SqListInput({
    this.operation = SqListOperation.insert,
    this.values = const [12, 24, 36, 48],
    this.capacity = 6,
    this.position = 2,
    this.value = 99,
  });
  final SqListOperation operation;
  final List<int> values;
  final int capacity, position, value;
  SqListInput copyWith({SqListOperation? operation}) => SqListInput(
    operation: operation ?? this.operation,
    values: values,
    capacity: capacity,
    position: position,
    value: value,
  );
}

class SqListModule implements AlgorithmModule<SqListInput> {
  const SqListModule();
  @override
  String get id => 'ch2_sqlist_ops';
  static const names = [
    'InitList_Sq',
    'GetElem',
    'LocateElem_Sq',
    'ListInsert_Sq',
    'ListDelete_Sq',
  ];
  @override
  List<AlgorithmPreset<SqListInput>> get presets => const [
    AlgorithmPreset(id: 'insert', name: '重建示例 · 中间插入 99', input: SqListInput()),
    AlgorithmPreset(
      id: 'delete',
      name: '正常 · 删除首元',
      input: SqListInput(operation: SqListOperation.delete, position: 1),
    ),
    AlgorithmPreset(
      id: 'get',
      name: '正常 · 一步读取第 3 项',
      input: SqListInput(operation: SqListOperation.get, position: 3),
    ),
    AlgorithmPreset(
      id: 'find',
      name: '正常 · 查找 36',
      input: SqListInput(operation: SqListOperation.locate, value: 36),
    ),
    AlgorithmPreset(
      id: 'zero',
      name: '边界 · 插入 i=0',
      input: SqListInput(position: 0),
    ),
    AlgorithmPreset(
      id: 'beyond',
      name: '边界 · 插入 i=length+2',
      input: SqListInput(position: 6),
    ),
    AlgorithmPreset(
      id: 'full',
      name: '边界 · 表满插入',
      input: SqListInput(capacity: 4),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '边界 · 空表删除',
      input: SqListInput(
        operation: SqListOperation.delete,
        values: [],
        position: 1,
      ),
    ),
    AlgorithmPreset(
      id: 'append',
      name: '边界 · 尾后插入无需移动',
      input: SqListInput(position: 5),
    ),
    AlgorithmPreset(
      id: 'missing',
      name: '边界 · 查找不存在的值',
      input: SqListInput(operation: SqListOperation.locate),
    ),
  ];
  // op | capacity | position | value | comma-separated elements (empty allowed).
  @override
  ValidationResult<SqListInput> validateInput(String raw) {
    final parts = raw.split('|').map((s) => s.trim()).toList();
    if (parts.length != 5) {
      return const ValidationResult.failure('格式：操作 | 容量 | 位序 | 值 | 逗号分隔元素');
    }
    final op = SqListOperation.values
        .where((v) => v.name == parts[0])
        .firstOrNull;
    final capacity = int.tryParse(parts[1]),
        position = int.tryParse(parts[2]),
        value = int.tryParse(parts[3]);
    final values = parts[4].isEmpty
        ? <int?>[]
        : parts[4].split(RegExp(r'[,，\s]+')).map(int.tryParse).toList();
    if (op == null ||
        capacity == null ||
        capacity < 1 ||
        capacity > 12 ||
        position == null ||
        position < -1 ||
        position > 14 ||
        value == null ||
        value.abs() > 999 ||
        values.length > capacity ||
        values.any((v) => v == null || v.abs() > 999)) {
      return const ValidationResult.failure(
        '容量 1～12；元素个数不超过容量；整数值 −999～999；位序 −1～14（允许演示越界）。',
      );
    }
    return ValidationResult.success(
      SqListInput(
        operation: op,
        capacity: capacity,
        position: position,
        value: value,
        values: values.cast<int>(),
      ),
    );
  }

  @override
  TraceTimeline generateTrace(SqListInput input) {
    if (!validateInput(
      '${input.operation.name}|${input.capacity}|${input.position}|${input.value}|${input.values.join(',')}',
    ).isValid) {
      throw ArgumentError('Invalid SqList input');
    }
    final op = input.operation,
        n = op == SqListOperation.init ? 0 : input.values.length;
    final code = _SqCode(op);
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${names[op.index]} · n=$n · i=${input.position} · e=${input.value}',
      codeLines: code.lines,
    );
    final slots = List<int?>.filled(input.capacity, null);
    if (op != SqListOperation.init) slots.setRange(0, n, input.values);
    var length = n, allocated = op != SqListOperation.init;
    String result = '待执行';
    int? output, focus, ghostSlot;
    String? ghostId;
    int? ghostValue;
    final vars = <String, String>{
      'i': '${input.position}',
      'e': '${input.value}',
    };
    SceneSnapshot snapshot() => SceneSnapshot(
      layoutMode: SceneLayoutMode.linearMemory,
      nodes: [
        if (allocated)
          for (var k = 0; k < slots.length; k++)
            SceneNode(
              id: 'slot-$k',
              label: slots[k]?.toString() ?? '·',
              x: 32 + k * 64.0,
              y: 128,
              shape: NodeShape.arraySlot,
              indexBadge: '[$k]',
              logicBadge: k < length ? '位序 ${k + 1}' : '有效区外',
              memoryAddress: '0x${(0x4000 + k * 4).toRadixString(16)}',
              visualState: k == focus
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
              opacity: k < length ? 1 : .45,
            ),
        if (ghostId != null)
          SceneNode(
            id: ghostId!,
            label: ghostValue.toString(),
            x: 32 + ghostSlot! * 64.0,
            y: 128,
            shape: NodeShape.arraySlot,
            visualState: NodeVisualState.moving,
            groupTag: 'assignment-copy',
          ),
      ],
      pointers: [
        if (focus != null && allocated)
          PointerBadge(
            id: 'cursor',
            label: '下标 $focus',
            targetNodeId: 'slot-$focus',
          ),
      ],
      auxTables: [
        AuxTableSnapshot(
          id: 'list-state',
          title: 'SqList 与返回值',
          columns: const ['elem', 'length', 'capacity', '返回', '输出 e'],
          rows: [
            [
              allocated ? '0x4000' : 'NULL',
              '$length',
              '${input.capacity}',
              result,
              output?.toString() ?? '—',
            ],
          ],
        ),
        AuxTableSnapshot(
          id: 'physical-slots',
          title: '物理槽（有效区外内容不属于线性表）',
          columns: const ['下标', '地址', '内容', '有效'],
          rows: [
            if (allocated)
              for (var k = 0; k < slots.length; k++)
                [
                  '$k',
                  '0x${(0x4000 + k * 4).toRadixString(16)}',
                  slots[k]?.toString() ?? '未写入',
                  k < length ? '是' : '否',
                ],
          ],
        ),
      ],
    );
    void record(
      String tag,
      String title,
      String explain, {
      int moves = 0,
      int reads = 0,
      int writes = 0,
      int compares = 0,
      int allocations = 0,
      bool error = false,
      bool milestone = false,
    }) {
      final line = code.tags[tag]!;
      builder.step(
        title: title,
        explain: explain,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: {
          ...vars,
          'length': '$length',
          'result': result,
          if (output != null) 'out': '$output',
        },
        scene: snapshot(),
        deltaMove: moves,
        deltaRead: reads,
        deltaWrite: writes,
        deltaCompare: compares,
        deltaAllocate: allocations,
        error: error,
        milestone: milestone,
        callStack: [
          StackActivationRecord(
            id: 'sqlist-call',
            functionName: names[op.index],
            arguments: {'i': '${input.position}', 'e': '${input.value}'},
            locals: {'length': '$length', ...vars},
            returnLocation: 'Main',
          ),
        ],
      );
    }

    record(
      'entry',
      '准备 ${names[op.index]}',
      '逻辑位序从 1 开始，elem 物理下标从 0 开始。模拟 ElemType 为 4 字节整数；容量为教学参数。',
      milestone: true,
    );
    if (op == SqListOperation.init) {
      allocated = true;
      record(
        'allocate',
        '分配连续存储',
        '申请 ${input.capacity} 个槽；分配失败分支见代码，本轨迹演示成功分配。',
        allocations: 1,
      );
      record('length', 'length = 0', '槽已分配但元素尚未写入；没有有效元素。');
      result = 'OK';
      record(
        'return',
        '初始化完成',
        'elem 指向首地址 0x4000，length 为 0。',
        milestone: true,
      );
      return builder.build();
    }
    if (op == SqListOperation.locate) {
      for (var j = 0; j < length; j++) {
        focus = j;
        vars['j'] = '$j';
        record(
          'compare',
          '比较 elem[$j]',
          '${slots[j]} ${slots[j] == input.value ? '==' : '!='} ${input.value}；从首元逐项查找。',
          reads: 1,
          compares: 1,
        );
        if (slots[j] == input.value) {
          result = '${j + 1}';
          record(
            'found',
            '返回位序 $result',
            '返回首次匹配的位置，不是物理下标。成功且各位序等概率时 ASL=(n+1)/2。',
            milestone: true,
          );
          return builder.build();
        }
      }
      vars.remove('j');
      result = '0';
      focus = null;
      record('missing', '未找到，返回 0', '未命中比较 n 次；空表为 0 次。', milestone: true);
      return builder.build();
    }
    final limit = length + (op == SqListOperation.insert ? 1 : 0);
    final invalid = input.position < 1 || input.position > limit;
    if (invalid) result = 'ERROR';
    record(
      'bounds',
      invalid ? 'ERROR · 位序越界' : '位序校验通过',
      '本操作合法位序为 [1, $limit]${limit == 0 ? '（空区间）' : ''}。',
      error: invalid,
    );
    if (invalid) return builder.build();
    if (op == SqListOperation.insert) {
      final full = length == input.capacity;
      if (full) result = 'OVERFLOW';
      record(
        'full',
        full ? 'OVERFLOW · 表满' : '容量校验通过',
        'length=$length，capacity=${input.capacity}。',
        error: full,
      );
      if (full) return builder.build();
    }
    final index = input.position - 1;
    if (op == SqListOperation.get || op == SqListOperation.delete) {
      focus = index;
      output = slots[index];
      record(
        'read',
        op == SqListOperation.get ? 'O(1) · 一步随机存取' : '先保存被删除值',
        '字节地址 = 0x4000 + (${input.position}−1) × 4 = 0x${(0x4000 + index * 4).toRadixString(16)}；e=$output。',
        reads: 1,
      );
    }
    void copySlot(int from, int to) {
      vars['j'] = '$from';
      focus = from;
      ghostId = 'copy-$from-$to';
      ghostSlot = from;
      ghostValue = slots[from];
      record('loop', '准备复制 [$from] → [$to]', '源槽仍保留原值；移动徽标表示赋值的副本，不是交换。');
      slots[to] = slots[from];
      ghostSlot = to;
      focus = to;
      record(
        'copy',
        'elem[$to] = elem[$from]',
        '${op == SqListOperation.insert ? '从右向左搬移，避免覆盖尚未读取的元素。' : '从左向右搬移，填补删除后的空位。'}本次计 1 次移动。',
        moves: 1,
        reads: 1,
        writes: 1,
      );
      ghostId = null;
    }

    if (op == SqListOperation.insert) {
      for (var j = length - 1; j >= index; j--) {
        copySlot(j, j + 1);
      }
      vars.remove('j');
      slots[index] = input.value;
      focus = index;
      record(
        'write',
        '写入新元素 ${input.value}',
        '写入 elem[$index]；插入元素的这次写入不计入已有元素的移动次数。',
        writes: 1,
      );
      length++;
      record(
        'length',
        'length++',
        '有效区扩展到 $length 项。均匀选择 n+1 个合法插入位序时 E_ins=n/2。',
      );
    } else if (op == SqListOperation.delete) {
      for (var j = index + 1; j < length; j++) {
        copySlot(j, j - 1);
      }
      vars.remove('j');
      length--;
      focus = null;
      record(
        'length',
        'length--',
        '末槽可能残留旧值，但已在有效区外；删除不要求清零。均匀选择 n 个删除位序时 E_del=(n−1)/2（n≥1）。',
      );
    }
    result = 'OK';
    record(
      'return',
      '${names[op.index]} 完成',
      op == SqListOperation.get
          ? '读取次数为 1，时间 O(1)。'
          : '移动次数：${op == SqListOperation.insert ? n - index : n - input.position}；辅助空间 O(1)。可倒放逐步检查物理槽。',
      milestone: true,
    );
    return builder.build();
  }
}

class _SqCode {
  _SqCode(SqListOperation op) {
    void add(String tag, String pseudo, String c, String dart) {
      tags[tag] = lines[CodeLang.cLike]!.length + 1;
      lines[CodeLang.cLike]!.add(pseudo);
      lines[CodeLang.c99]!.add(c);
      lines[CodeLang.dart]!.add(dart);
    }

    add(
      'types',
      'SqList { ElemType *elem; int length; }',
      '#include <stdlib.h>',
      'class SqList { List<int?> elem = []; int length = 0; }',
    );
    add(
      'status',
      '// 状态：OK=1, ERROR=0, OVERFLOW=-1',
      'typedef struct { int *elem; int length; } SqList;',
      'const OK=1, ERROR=0, OVERFLOW=-1;',
    );
    add(
      'constants',
      '// capacity 为本实验容量参数',
      'enum { OK=1, ERROR=0, OVERFLOW=-1 };',
      '// out[0] 表示输出参数；调用方传入 [0]',
    );
    final name = SqListModule.names[op.index];
    add(
      'entry',
      '$name(L, i, e, capacity) {',
      'int $name(SqList *L, int i, int e, int capacity, int *out) {',
      'int $name(SqList L, int i, int e, int capacity, List<int> out) {',
    );
    if (op == SqListOperation.init) {
      add(
        'allocate',
        '  L.elem = new ElemType[capacity];',
        '  L->elem = malloc(capacity * sizeof *L->elem);',
        '  L.elem = List<int?>.filled(capacity, null);',
      );
      add(
        'failure',
        '  if (!L.elem) return OVERFLOW;',
        '  if (!L->elem) return OVERFLOW;',
        '  // Dart 分配失败由运行时抛出异常',
      );
      add('length', '  L.length = 0;', '  L->length = 0;', '  L.length = 0;');
    } else if (op == SqListOperation.locate) {
      add(
        'loop',
        '  for (j=0; j<L.length; j++) {',
        '  for (int j=0; j<L->length; j++) {',
        '  for (var j=0; j<L.length; j++) {',
      );
      add(
        'compare',
        '    if (L.elem[j] == e)',
        '    if (L->elem[j] == e)',
        '    if (L.elem[j] == e)',
      );
      add(
        'found',
        '      return j+1;',
        '      return j+1;',
        '      return j+1;',
      );
      add('endloop', '  }', '  }', '  }');
      add('missing', '  return 0;', '  return 0;', '  return 0;');
    } else {
      final extra = op == SqListOperation.insert ? '+1' : '';
      add(
        'bounds',
        '  if (i<1 || i>L.length$extra) return ERROR;',
        '  if (i<1 || i>L->length$extra) return ERROR;',
        '  if (i<1 || i>L.length$extra) return ERROR;',
      );
      if (op == SqListOperation.insert) {
        add(
          'full',
          '  if (L.length==capacity) return OVERFLOW;',
          '  if (L->length==capacity) return OVERFLOW;',
          '  if (L.length==capacity) return OVERFLOW;',
        );
        add(
          'loop',
          '  for (j=L.length-1; j>=i-1; j--)',
          '  for (int j=L->length-1; j>=i-1; j--)',
          '  for (var j=L.length-1; j>=i-1; j--)',
        );
        add(
          'copy',
          '    L.elem[j+1] = L.elem[j];',
          '    L->elem[j+1] = L->elem[j];',
          '    L.elem[j+1] = L.elem[j];',
        );
        add(
          'write',
          '  L.elem[i-1] = e;',
          '  L->elem[i-1] = e;',
          '  L.elem[i-1] = e;',
        );
        add('length', '  L.length++;', '  L->length++;', '  L.length++;');
      } else {
        add(
          'read',
          '  e = L.elem[i-1]; // 输出参数',
          '  *out = L->elem[i-1];',
          '  out[0] = L.elem[i-1]!;',
        );
        if (op == SqListOperation.delete) {
          add(
            'loop',
            '  for (j=i; j<L.length; j++)',
            '  for (int j=i; j<L->length; j++)',
            '  for (var j=i; j<L.length; j++)',
          );
          add(
            'copy',
            '    L.elem[j-1] = L.elem[j];',
            '    L->elem[j-1] = L->elem[j];',
            '    L.elem[j-1] = L.elem[j];',
          );
          add('length', '  L.length--;', '  L->length--;', '  L.length--;');
        }
      }
    }
    if (op != SqListOperation.locate) {
      add('return', '  return OK;', '  return OK;', '  return OK;');
    }
    add('end', '}', '}', '}');
  }
  final tags = <String, int>{};
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
}
