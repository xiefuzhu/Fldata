const cListSupport = r'''#include <stdlib.h>
typedef struct Node {
  int data;
  struct Node *next, *prior;
} Node;
''';

// Node IDs belong to the verification adapter; algorithms reuse the nodes.
const dartListSupport = r'''class Node {
  Node(this.id, this.value);
  final String id;
  final int value;
  Node? next, prior;
}
Node build(List<dynamic> values, String prefix) {
  final head = Node(prefix + 'H', 0);
  var tail = head;
  for (var i = 0; i < values.length; i++) {
    final node = Node(prefix + i.toString(), values[i] as int);
    tail.next = node;
    node.prior = tail;
    tail = node;
  }
  return head;
}
Map<String, dynamic> snapshot(Node head) {
  final values = <int>[], ids = <String>[];
  final seen = <Node>{};
  for (var p = head.next; p != null && p != head; p = p.next) {
    if (!seen.add(p)) throw StateError('cycle');
    values.add(p.value);
    ids.add(p.id);
  }
  return {'values': values, 'ids': ids};
}
''';
