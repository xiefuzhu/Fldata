import 'dart:collection';
import 'dart:math' as math;
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

part 'bitree_trace.dart';
part 'tree_workshop.dart';
part 'tree_workshop_source.dart';
part 'tree_reconstruction.dart';

enum TreeLesson {
  preorder,
  inorder,
  postorder,
  stack,
  properties,
  levelOrder,
  create,
  preIn,
  postIn,
  copy,
  depth,
  count;

  bool get isTour => this == preorder || this == inorder || this == postorder;
  bool get isReconstruction => this == preIn || this == postIn;
  bool get isWorkshop => index >= levelOrder.index;
}

class TreeInput {
  const TreeInput({
    this.sequence = 'ABC##DE#G##F###',
    this.lesson = TreeLesson.preorder,
  });
  final String sequence;
  final TreeLesson lesson;
}

class BinaryNode {
  const BinaryNode(this.index, this.label, this.left, this.right);
  final BigInt index;
  final String label;
  final BinaryNode? left, right;
  String get id => 'b$index';
}

BinaryNode? readPreorder(String sequence) {
  final tokens = sequence.replaceAll(RegExp(r'\s+'), '').runes.toList();
  var cursor = 0;
  BinaryNode? read(BigInt index) {
    if (cursor == tokens.length) {
      throw FormatException('第 ${cursor + 1} 位缺少节点或 #。');
    }
    final token = String.fromCharCode(tokens[cursor++]);
    if (token == '#') return null;
    final left = read(index << 1), right = read((index << 1) + BigInt.one);
    return BinaryNode(index, token, left, right);
  }

  final root = read(BigInt.one);
  if (cursor != tokens.length) {
    throw FormatException('第 ${cursor + 1} 位开始有多余的字符。');
  }
  return root;
}

class BiTreeModule implements AlgorithmModule<TreeInput> {
  const BiTreeModule();
  @override
  String get id => 'ch5_bitree_traverse';
  static const names = [
    '先序',
    '中序',
    '后序',
    '中序 · 指针栈',
    '五条性质',
    '层序 · 队列',
    '先序建树',
    '先序 + 中序',
    '后序 + 中序',
    '复制二叉树',
    '计算深度',
    '统计结点数',
  ];
  @override
  List<AlgorithmPreset<TreeInput>> get presets => const [
    AlgorithmPreset(id: 'sample', name: '教材树 · 七个节点', input: TreeInput()),
    AlgorithmPreset(
      id: 'complete',
      name: '完全二叉树 · 六个节点',
      input: TreeInput(
        sequence: 'ABD##E##CF###',
        lesson: TreeLesson.properties,
      ),
    ),
    AlgorithmPreset(
      id: 'right',
      name: '连续右孩子',
      input: TreeInput(sequence: 'A#B#C##', lesson: TreeLesson.stack),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '空树',
      input: TreeInput(sequence: '#'),
    ),
    AlgorithmPreset(
      id: 'reconstruct',
      name: '序列重构 · ABDGCEF',
      input: TreeInput(sequence: 'ABD#G###CE##F##', lesson: TreeLesson.preIn),
    ),
  ];
  @override
  ValidationResult<TreeInput> validateInput(String raw) {
    try {
      readPreorder(raw);
      return ValidationResult.success(TreeInput(sequence: raw));
    } on FormatException catch (e) {
      return ValidationResult.failure(e.message);
    }
  }

  @override
  TraceTimeline generateTrace(TreeInput input) {
    final root = readPreorder(input.sequence);
    return input.lesson.isWorkshop
        ? _TreeWorkshop(input, root).record()
        : _recordTree(input, root);
  }
}

class _TreeDiagram {
  final nodes = <SceneNode>[],
      edges = <SceneEdge>[],
      levels = <int, int>{},
      ordered = <BinaryNode>[];
  int leaves = 0, degreeTwo = 0;
  BigInt maxIndex = BigInt.zero;
  _TreeDiagram(BinaryNode? root) {
    void visit(BinaryNode? n, int level) {
      if (n == null) return;
      visit(n.left, level + 1);
      nodes.add(
        SceneNode(
          id: n.id,
          label: n.label,
          shape: NodeShape.circle,
          width: 48,
          height: 48,
          x: 58 + ordered.length * 80.0,
          y: 60 + (level - 1) * 110.0,
        ),
      );
      ordered.add(n);
      levels.update(level, (x) => x + 1, ifAbsent: () => 1);
      if (n.index > maxIndex) maxIndex = n.index;
      if (n.left == null && n.right == null) leaves++;
      if (n.left != null && n.right != null) degreeTwo++;
      for (final (child, port) in [
        (n.left, EdgePort.lchild),
        (n.right, EdgePort.rchild),
      ]) {
        if (child != null) {
          edges.add(
            SceneEdge(
              id: '${n.id}-${child.id}',
              fromNodeId: n.id,
              toNodeId: child.id,
              fromPort: port,
            ),
          );
        }
      }
      visit(n.right, level + 1);
    }

    visit(root, 1);
  }
}
