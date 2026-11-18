part of 'bst.dart';

const avlLockLine = 5;

const _avlPresets = [
  AlgorithmPreset(
    id: 'avl-fig712',
    name: '图 7.12 · AVL 生成过程',
    input: BstInput(operation: BstOperation.avl, values: [13, 24, 37, 90, 53]),
  ),
  AlgorithmPreset(
    id: 'avl-ll',
    name: '图 7.14(b) · LL 右旋',
    input: BstInput(
      operation: BstOperation.avl,
      values: [31, 25, 47, 16, 28, 9],
    ),
  ),
  AlgorithmPreset(
    id: 'avl-rr',
    name: '图 7.16(b) · RR 左旋',
    input: BstInput(
      operation: BstOperation.avl,
      values: [31, 25, 47, 40, 69, 76],
    ),
  ),
  AlgorithmPreset(
    id: 'avl-lr',
    name: '图 7.18(b) · LR 双旋',
    input: BstInput(
      operation: BstOperation.avl,
      values: [31, 25, 47, 16, 28, 26],
    ),
  ),
  AlgorithmPreset(
    id: 'avl-rl',
    name: '图 7.20(c) · RL 双旋',
    input: BstInput(
      operation: BstOperation.avl,
      values: [31, 25, 47, 40, 69, 43],
    ),
  ),
  AlgorithmPreset(
    id: 'avl-chain',
    name: '递增五键 · 连续 RR',
    input: BstInput(operation: BstOperation.avl, values: [10, 20, 30, 40, 50]),
  ),
];

SceneSnapshot _markAvlSubtree(
  SceneSnapshot scene,
  Set<String> ids,
  String type,
) {
  final nodes = scene.nodes.where((n) => ids.contains(n.id));
  final x = nodes.map((n) => n.x).reduce(math.min) - 8;
  final y = nodes.map((n) => n.y).reduce(math.min) - 14;
  return scene.copyWith(
    zones: [
      SceneZoneOverlay(
        id: 'avl-subtree',
        label: '$type · 最小不平衡子树',
        x: x,
        y: y,
        width: nodes.map((n) => n.x + n.width).reduce(math.max) + 22 - x,
        height: nodes.map((n) => n.y + n.height).reduce(math.max) + 19 - y,
        pattern: ZonePattern.dashed,
        visualState: NodeVisualState.comparing,
      ),
    ],
  );
}

extension on _Node {
  int refreshAvlHeight() {
    final l = left?.avlHeight ?? 0, r = right?.avlHeight ?? 0;
    avlHeight = 1 + math.max(l, r);
    avlBalance = l - r;
    return avlBalance;
  }
}

extension on _Run {
  void buildAvl() {
    step = 0;
    emit(1, '空树', '从空 AVL 树开始', '依次插入关键字，从新增叶子的双亲向根检查平衡。', milestone: true);
    for (final key in input.values) {
      step = step! + 1;
      final path = a.path(key);
      final parent = path.lastOrNull;
      if (parent != null && parent.key == key) {
        emit(
          2,
          '重复',
          '跳过重复键 $key',
          '结点 ${parent.id} 已存储该键。',
          focus: parent,
          comparisons: path.length,
        );
      } else {
        final leaf = a.add(key, parent);
        emit(
          3,
          '插入',
          '插入叶子 $key',
          '${leaf.id} 的左右子树均为空，BF = 0。',
          focus: leaf,
          alloc: 1,
          writes: 1,
          comparisons: path.length,
        );
        for (var i = path.length - 1; i >= 0; i--) {
          final pivot = path[i], bf = pivot.refreshAvlHeight();
          if (bf.abs() < 2) {
            emit(
              4,
              '回溯',
              '检查 ${pivot.key} 的平衡因子',
              '左高 ${pivot.left?.avlHeight ?? 0} − 右高 ${pivot.right?.avlHeight ?? 0} = $bf，继续向上检查。',
              focus: pivot,
            );
            continue;
          }
          repairAvl(i == 0 ? null : path[i - 1], pivot, bf > 0, key);
          break;
        }
      }
      emit(
        9,
        '平衡',
        '第 $step 项处理完毕',
        '所有结点的平衡因子均在 −1 到 +1 之间。',
        milestone: true,
      );
    }
    result = 'AVL 建树完成';
    emit(9, '完成', result, '中序序列严格递增。', milestone: true);
  }

  void repairAvl(_Node? parent, _Node pivot, bool leftHeavy, int key) {
    final child = leftHeavy ? pivot.left! : pivot.right!;
    final insideLeft = key < child.key;
    final doubleRotation = insideLeft != leftHeavy;
    final type = (leftHeavy ? 'L' : 'R') + (insideLeft ? 'L' : 'R');
    rotationType = type;
    unbalancedRoot = pivot;
    roles['A'] = pivot;
    roles['B'] = child;
    if (doubleRotation) roles['C'] = insideLeft ? child.left : child.right;
    emit(
      avlLockLine,
      '失衡',
      '$type · 锁定最小不平衡子树',
      '向上遇到的第一个失衡结点是 A = ${pivot.key}，BF = ${leftHeavy ? "+2" : "−2"}。继续播放可观察指针重接。',
      focus: pivot,
      second: child,
      milestone: true,
    );
    if (doubleRotation) {
      rotateAvl(pivot, child, left: leftHeavy, inner: true);
      emit(
        7,
        '中间态',
        '第一拍结束 · 已形成 ${leftHeavy ? "LL" : "RR"}',
        '内侧子树已移接，下一拍围绕 A = ${pivot.key} 旋转。',
        focus: pivot,
        milestone: true,
      );
    }
    unbalancedRoot = null;
    rotateAvl(parent, pivot, left: !leftHeavy, inner: false);
    rotationType = null;
    roles.clear();
  }

  void rotateAvl(
    _Node? parent,
    _Node pivot, {
    required bool left,
    required bool inner,
  }) {
    final raised = left ? pivot.right! : pivot.left!;
    final transfer = left ? raised.left : raised.right;
    final owner = a.field(parent, pivot);
    if (left) {
      pivot.right = transfer;
      raised.left = pivot;
    } else {
      pivot.left = transfer;
      raised.right = pivot;
    }
    a.replace(parent, pivot, raised);
    pivot.refreshAvlHeight();
    raised.refreshAvlHeight();
    final side = left ? '左' : '右', opposite = left ? '右' : '左';
    emit(
      inner ? 6 : 8,
      '旋转',
      '$rotationType · 围绕 ${pivot.key} $side旋',
      '$owner 改指 ${raised.key}。${raised.key} 原来的$side子树（${transfer?.key ?? "空"}）移接为 ${pivot.key} 的$opposite子树，${pivot.key} 成为 ${raised.key} 的$side孩子。',
      focus: raised,
      second: pivot,
      writes: 3,
      milestone: true,
    );
  }
}
