import 'dart:math' as math;
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';

enum LogicalStructure { collection, linear, tree, graph }

enum StorageStructure { sequential, linked }

class MappingInput {
  const MappingInput({
    this.logical = LogicalStructure.linear,
    this.storage = StorageStructure.sequential,
    this.count = 5,
    this.seed = 17,
  });
  final LogicalStructure logical;
  final StorageStructure storage;
  final int count, seed;
  MappingInput copyWith({
    LogicalStructure? logical,
    StorageStructure? storage,
    int? count,
    int? seed,
  }) => MappingInput(
    logical: logical ?? this.logical,
    storage: storage ?? this.storage,
    count: count ?? this.count,
    seed: seed ?? this.seed,
  );
}

/// A 64-byte teaching arena of eight 8-byte records: one uint16 data ID and
/// three uint16 relation fields. Linked fields contain simulated addresses;
/// sequential tree/graph fields contain indices. This is not a host ABI.
class StructMappingModule implements AlgorithmModule<MappingInput> {
  const StructMappingModule();
  static const base = 0x2000, stride = 8, capacity = 8;
  static const logicalNames = ['集合', '线性（学籍表）', '树形（井字棋）', '图形（交通网）'];
  static const storageNames = ['顺序存储', '链式存储'];
  static String address(int slot) =>
      '0x${(base + slot * stride).toRadixString(16).toUpperCase()}';
  @override
  String get id => 'ch1_struct_mapping';
  @override
  List<AlgorithmPreset<MappingInput>> get presets => const [
    AlgorithmPreset(
      id: 'teaching',
      name: '教材场景示例 · 5 个结点',
      input: MappingInput(),
    ),
    AlgorithmPreset(
      id: 'small',
      name: '常规对照 · 3 个结点',
      input: MappingInput(count: 3, seed: 23),
    ),
    AlgorithmPreset(
      id: 'full',
      name: '边界 · 8 槽全部占用',
      input: MappingInput(count: 8, seed: 31),
    ),
  ];
  @override
  ValidationResult<MappingInput> validateInput(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.length != 4) {
      return const ValidationResult.failure('输入格式：逻辑类型 存储类型 结点数 随机种子');
    }
    final logical = LogicalStructure.values
        .where((v) => v.name == parts[0])
        .firstOrNull;
    final storage = StorageStructure.values
        .where((v) => v.name == parts[1])
        .firstOrNull;
    final count = int.tryParse(parts[2]), seed = int.tryParse(parts[3]);
    if (logical == null ||
        storage == null ||
        count == null ||
        count < 1 ||
        count > capacity ||
        seed == null ||
        seed < 0 ||
        seed > 65535) {
      return const ValidationResult.failure('请选择有效结构，结点数 1～8，随机种子 0～65535');
    }
    return ValidationResult.success(
      MappingInput(
        logical: logical,
        storage: storage,
        count: count,
        seed: seed,
      ),
    );
  }

  @override
  TraceTimeline generateTrace(MappingInput input) {
    if (input.count < 1 ||
        input.count > capacity ||
        input.seed < 0 ||
        input.seed > 65535) {
      throw ArgumentError('Invalid mapping input');
    }
    final linked = input.storage == StorageStructure.linked;
    final slots = List<int>.generate(capacity, (i) => i);
    if (linked) slots.shuffle(math.Random(input.seed));
    final allocated = slots.take(input.count).toList();
    final outgoing = List.generate(input.count, (_) => <int>[]);
    if (input.logical == LogicalStructure.linear) {
      for (var i = 0; i < input.count - 1; i++) {
        outgoing[i].add(i + 1);
      }
    } else if (input.logical == LogicalStructure.tree) {
      for (var i = 1; i < input.count; i++) {
        outgoing[(i - 1) ~/ 2].add(i);
      }
    } else if (input.logical == LogicalStructure.graph) {
      void connect(int a, int b) {
        if (!outgoing[a].contains(b)) {
          outgoing[a].add(b);
          outgoing[b].add(a);
        }
      }

      if (input.count == 2) connect(0, 1);
      if (input.count > 2) {
        for (var i = 0; i < input.count; i++) {
          connect(i, (i + 1) % input.count);
        }
      }
      if (input.count >= 5) connect(0, input.count ~/ 2);
    }
    final storedLinks = input.logical == LogicalStructure.collection && linked
        ? List.generate(
            input.count,
            (i) => <int>[if (i + 1 < input.count) i + 1],
          )
        : outgoing;
    final boards = <List<String>>[];
    if (input.logical == LogicalStructure.tree) {
      boards.add(List.filled(9, '·'));
      const priority = [4, 0, 2, 6, 8, 1, 3, 5, 7];
      for (var i = 1; i < input.count; i++) {
        final board = List<String>.of(boards[(i - 1) ~/ 2]);
        final free = priority.where((cell) => board[cell] == '·').toList();
        final turn = board.where((cell) => cell != '·').length;
        board[free[(i - 1) % 2]] = turn.isEven ? 'X' : 'O';
        boards.add(board);
      }
    }
    String label(int i) => switch (input.logical) {
      LogicalStructure.collection => '元素 ${i + 1}',
      LogicalStructure.linear =>
        '${['张', '李', '王', '陈', '刘', '杨', '赵', '黄'][i]}同学',
      LogicalStructure.tree => [
        for (var row = 0; row < 3; row++)
          boards[i].skip(row * 3).take(3).join(' '),
      ].join('\n'),
      LogicalStructure.graph =>
        '${['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛'][i]}城',
    };
    final logicalEdges = <SceneEdge>[
      for (var i = 0; i < input.count; i++)
        for (final j in outgoing[i])
          if (input.logical != LogicalStructure.graph || i < j)
            SceneEdge(
              id: 'logical-$i-$j',
              fromNodeId: 'logical-$i',
              toNodeId: 'logical-$j',
              style: input.logical == LogicalStructure.graph
                  ? EdgeStyle.undirected
                  : EdgeStyle.solidArrow,
            ),
    ];
    var logical = SceneSnapshot(
      nodes: [
        for (var i = 0; i < input.count; i++)
          SceneNode(
            id: 'logical-$i',
            label: label(i),
            x: input.logical == LogicalStructure.linear
                ? 24 + i * 112.0
                : 220 + 160 * math.cos(i * 2 * math.pi / input.count),
            y: input.logical == LogicalStructure.linear
                ? 120
                : 180 + 120 * math.sin(i * 2 * math.pi / input.count),
            width: input.logical == LogicalStructure.tree ? 88 : 80,
            height:
                input.logical == LogicalStructure.tree ||
                    input.logical == LogicalStructure.graph
                ? 80
                : 52,
            shape: input.logical == LogicalStructure.graph
                ? NodeShape.circle
                : NodeShape.roundedRect,
            indexBadge: 'i=${i + 1}',
            groupTag: 'logical',
          ),
      ],
      edges: logicalEdges,
    );
    if (input.logical == LogicalStructure.tree) {
      logical = TreeReingoldLayout.arrange(logical);
    }
    List<String> fields(int i) {
      if (input.logical == LogicalStructure.collection && !linked) {
        return const ['无逻辑关系'];
      }
      if (!linked && input.logical == LogicalStructure.linear) {
        return [i == input.count - 1 ? '末项' : '后继：相邻槽'];
      }
      return [
        for (var f = 0; f < 3; f++)
          'f$f=${f >= storedLinks[i].length
              ? (linked ? 'NULL' : 'FFFF')
              : linked
              ? address(allocated[storedLinks[i][f]])
              : '[${storedLinks[i][f]}]'}',
      ];
    }

    final physical = <SceneNode>[
      for (var slot = 0; slot < capacity; slot++)
        SceneNode(
          id: allocated.contains(slot)
              ? 'physical-${allocated.indexOf(slot)}'
              : 'free-$slot',
          label: allocated.contains(slot)
              ? 'data=${allocated.indexOf(slot) + 1}'
              : '空闲',
          x: 24 + slot * 124.0,
          y: 110,
          width: 116,
          height: 56,
          indexBadge: address(slot),
          memoryAddress: address(slot),
          groupTag: 'physical',
          logicBadge: allocated.contains(slot)
              ? fields(allocated.indexOf(slot)).join('\n')
              : '可分配',
        ),
    ];
    final physicalEdges = <SceneEdge>[
      if (linked)
        for (var i = 0; i < input.count; i++)
          for (final j in storedLinks[i])
            SceneEdge(
              id: 'physical-$i-$j',
              fromNodeId: 'physical-$i',
              toNodeId: 'physical-$j',
              curvature:
                  (allocated[i] < allocated[j] ? -1 : 1) *
                  (80 + (i * 3 + j) % 5 * 20.0),
            ),
    ];
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary:
          '${logicalNames[input.logical.index]} · ${storageNames[input.storage.index]} · ${input.count} 个结点',
      codeLines: const {
        CodeLang.cLike: [
          'Locate(i, storage, base, addrMap) {',
          '  if (storage == SEQUENTIAL)',
          '    return base + (i - 1) * 8;',
          '  else',
          '    return addrMap[i - 1];',
          '}',
        ],
        CodeLang.c99: [
          '#include <stdint.h>',
          'uint16_t locate(int i, int linked, const uint16_t *addr_map) {',
          '  return linked ? addr_map[i - 1] : 0x2000 + (i - 1) * 8;',
          '}',
        ],
        CodeLang.dart: [
          'int locate(int i, bool linked, List<int> addresses) {',
          '  return linked ? addresses[i - 1] : 0x2000 + (i - 1) * 8;',
          '}',
        ],
      },
    );
    final principle = switch (input.logical) {
      LogicalStructure.collection =>
        '集合只表达同属一个集合；屏幕位置和编号不代表先后关系。本例链式模式的 next 存储链用于遍历，不给集合添加逻辑次序。',
      LogicalStructure.linear => '学籍表中每项至多有一个直接前驱与后继；顺序存储以相邻槽表达先后。',
      LogicalStructure.tree => '井字棋局部博弈树表示父局面到下一步落子的分支；这里只取部分合法落子，不是完整博弈树。',
      LogicalStructure.graph => '交通网示例为无向图；连接表示两城有道路，不代表地图距离或真实交通路线。',
    };
    for (var selected = -1; selected < input.count; selected++) {
      final selectedIds = {'logical-$selected', 'physical-$selected'};
      final location = selected < 0 ? '' : address(allocated[selected]);
      builder.step(
        title: selected < 0 ? '逻辑关系与物理位置' : '结点 ${selected + 1} → $location',
        explain:
            '$principle\n${linked ? '链式存储按固定种子分配空闲槽，关系字段保存模拟地址。addrMap 仅是演示器的编号到地址索引，不代表链表支持按序号 O(1) 查找。' : '连续记录按 LOC(aᵢ)=LOC(a₁)+(i−1)×l 定位。这里 l=8 字节；树与图还需要关系索引，不能只靠相邻位置还原拓扑。'}\n内存区间 [0x2000,0x2040)，共 8 个 8 字节教学记录：2 字节 data ID + 3 个 2 字节关系字段。顺序关系字段用 0-based 索引，FFFF 表示无关系；链式字段用 16 位模拟地址，NULL=0。姓名与棋盘为 ID 的展示说明，不是记录内字符串。',
        cLikeLines: [
          selected < 0
              ? 1
              : linked
              ? 5
              : 3,
        ],
        c99Lines: [selected < 0 ? 2 : 3],
        dartLines: [selected < 0 ? 1 : 2],
        vars: selected < 0
            ? {'n': input.count.toString(), 'l': '8 字节'}
            : {
                'i': (selected + 1).toString(),
                'addr': location,
                'l': '8',
                '定位': linked ? 'addrMap[$selected]' : '0x2000 + $selected × 8',
              },
        scene: SceneSnapshot(
          nodes: [
            for (final node in [...logical.nodes, ...physical])
              node.copyWith(
                visualState: selectedIds.contains(node.id)
                    ? NodeVisualState.active
                    : NodeVisualState.normal,
              ),
          ],
          edges: [...logical.edges, ...physicalEdges],
          auxTables: [
            AuxTableSnapshot(
              id: 'mapping',
              title: '逻辑结点 → 内存槽',
              columns: const ['序号 i', 'data ID', '槽下标', '模拟地址', '关系字段'],
              rows: [
                for (var i = 0; i < input.count; i++)
                  [
                    (i + 1).toString(),
                    (i + 1).toString(),
                    allocated[i].toString(),
                    address(allocated[i]),
                    fields(i).join('；'),
                  ],
              ],
              highlightedRows: {if (selected >= 0) selected},
            ),
          ],
        ),
        deltaRead: selected >= 0 && linked ? 1 : 0,
        milestone: selected == -1 || selected == input.count - 1,
      );
    }
    return builder.build();
  }
}
