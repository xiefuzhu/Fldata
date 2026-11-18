part of 'bitree_traverse.dart';

List<String> _symbols(String text) =>
    text.replaceAll(RegExp(r'\s+'), '').runes.map(String.fromCharCode).toList();

String traversalSequence(BinaryNode? root, TreeLesson order) {
  final result = StringBuffer();
  void visit(BinaryNode? n) {
    if (n == null) return;
    if (order == TreeLesson.preorder) result.write(n.label);
    visit(n.left);
    if (order == TreeLesson.inorder) result.write(n.label);
    visit(n.right);
    if (order == TreeLesson.postorder) result.write(n.label);
  }

  visit(root);
  return result.toString();
}

/// Encode the selected reconstruction using the course's # null marker.
/// Equal labels can have more than one solution. Try splits left to right
/// and reuse the result for each traversal interval.
String reconstructSequence(
  String traversal,
  String inorder, {
  required bool postorder,
}) {
  final order = _symbols(traversal), middle = _symbols(inorder);
  if (order.length != middle.length) throw const FormatException('两个序列的结点数不同。');
  if (order.contains('#') || middle.contains('#')) {
    throw const FormatException('重构序列只填写结点，空树请留空。');
  }
  final positions = <String, List<int>>{};
  for (final (i, v) in middle.indexed) {
    (positions[v] ??= []).add(i);
  }
  final splits = <(int, int, int), int>{};
  bool valid(int a, int b, int n) {
    if (n == 0) return true;
    final key = (a, b, n), cached = splits[key];
    if (cached != null) return cached >= 0;
    final label = order[postorder ? a + n - 1 : a],
        childStart = postorder ? a : a + 1;
    for (final pivot in positions[label] ?? const <int>[]) {
      final left = pivot - b;
      if (left >= 0 &&
          left < n &&
          valid(childStart, b, left) &&
          valid(childStart + left, pivot + 1, n - left - 1)) {
        splits[key] = pivot;
        return true;
      }
    }
    splits[key] = -1;
    return false;
  }

  if (!valid(0, 0, middle.length)) {
    throw const FormatException('这两个遍历序列无法构成同一棵二叉树。');
  }
  final encoded = StringBuffer();
  void write(int a, int b, int n) {
    if (n == 0) {
      encoded.write('#');
      return;
    }
    final pivot = splits[(a, b, n)]!,
        left = pivot - b,
        childStart = postorder ? a : a + 1;
    encoded.write(middle[pivot]);
    write(childStart, b, left);
    write(childStart + left, pivot + 1, n - left - 1);
  }

  write(0, 0, middle.length);
  return encoded.toString();
}
