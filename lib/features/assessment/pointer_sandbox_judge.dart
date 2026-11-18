import '../../engine/vm/memory_leaks.dart';
import '../../models/quiz_question.dart';

enum PointerIssue {
  leak,
  cycle,
  dangling,
  reciprocal,
  links,
  roots,
  deletion,
  instruction,
}

class PointerJudgeResult {
  const PointerJudgeResult(this.issue, this.message, [this.nodes = const {}]);
  final PointerIssue? issue;
  final String message;
  final Set<String> nodes;
  bool get correct => issue == null;
}

PointerJudgeResult evaluatePointerGraph({
  required Map<String, String?> expectedNextMap,
  required Map<String, String?> actualNextMap,
  Map<String, String?>? expectedPriorMap,
  Map<String, String?>? actualPriorMap,
  required Set<String> rootPointers,
  required Set<String> deletedNodes,
  bool circular = false,
  bool binaryTree = false,
}) {
  final live = {...expectedNextMap.keys, ...actualNextMap.keys}
    ..removeAll(deletedNodes);
  final adjacency = {
    for (final id in live)
      id: [
        if (actualNextMap[id] case final String child) child,
        if (binaryTree && actualPriorMap?[id] != null) actualPriorMap![id]!,
      ],
  };
  final leaks = unreachableNodes(live, adjacency, rootPointers);
  if (leaks.isNotEmpty) {
    return PointerJudgeResult(
      PointerIssue.leak,
      '发现结点 [${leaks.join("、")}] 指针丢失，导致内存泄漏。',
      leaks,
    );
  }

  if (!circular && !binaryTree) {
    String? nextLive(String? id) =>
        live.contains(id) ? actualNextMap[id] : null;
    for (final root in rootPointers.where(live.contains)) {
      String? slow = root, fast = root;
      do {
        slow = nextLive(slow);
        fast = nextLive(nextLive(fast));
        if (slow == null || fast == null || !live.contains(fast)) break;
        if (slow == fast) {
          final cycle = <String>{slow};
          var n = nextLive(slow);
          while (n != null && cycle.add(n)) {
            n = nextLive(n);
          }
          return PointerJudgeResult(
            PointerIssue.cycle,
            '快慢指针在 $slow 相遇，next 链形成了环。',
            cycle,
          );
        }
      } while (true);
    }
  }
  if (binaryTree) {
    final visiting = <String>{}, done = <String>{};
    String? cycle(String id) {
      if (visiting.contains(id)) return id;
      if (!live.contains(id) || done.contains(id)) return null;
      visiting.add(id);
      for (final child in adjacency[id]!) {
        final hit = cycle(child);
        if (hit != null) return hit;
      }
      visiting.remove(id);
      done.add(id);
      return null;
    }

    for (final root in rootPointers) {
      final hit = cycle(root);
      if (hit != null) {
        return PointerJudgeResult(PointerIssue.cycle, '孩子指针返回祖先 $hit，树中出现环。', {
          hit,
        });
      }
    }
  }
  final dangling = {
    ...rootPointers.where((id) => !live.contains(id)),
    for (final id in live)
      for (final target in [actualNextMap[id], actualPriorMap?[id]])
        if (target != null && !live.contains(target)) target,
  };
  if (dangling.isNotEmpty) {
    return PointerJudgeResult(
      PointerIssue.dangling,
      '指针仍指向无效结点 ${dangling.join("、")}。',
      dangling,
    );
  }

  final second = expectedPriorMap != null && expectedPriorMap.isNotEmpty;
  if (second && !binaryTree) {
    for (final node in live) {
      final next = actualNextMap[node], prior = actualPriorMap?[node];
      if (next != null && actualPriorMap?[next] != node) {
        return PointerJudgeResult(
          PointerIssue.reciprocal,
          '$node.next 指向 $next，但 $next.prior 没有指回 $node。',
          {node, next},
        );
      }
      if (prior != null && actualNextMap[prior] != node) {
        return PointerJudgeResult(
          PointerIssue.reciprocal,
          '$node.prior 指向 $prior，但 $prior.next 没有指回 $node。',
          {node, prior},
        );
      }
    }
  }
  for (final id in {...live, ...expectedNextMap.keys}) {
    if (!live.contains(id) ||
        !expectedNextMap.containsKey(id) ||
        !actualNextMap.containsKey(id) ||
        actualNextMap[id] != expectedNextMap[id] ||
        (second &&
            (actualPriorMap?.containsKey(id) != true ||
                actualPriorMap![id] != expectedPriorMap[id]))) {
      return PointerJudgeResult(PointerIssue.links, '结点 $id 的连接尚未达到题目要求。', {
        id,
      });
    }
  }
  return const PointerJudgeResult(null, '连接正确，所有保留结点均可从根指针到达。');
}

/// Pointer assignments evaluate the right hand side against the pre-step heap.
/// The statements are the exercise's own assignment/free cards.
class PointerHeap {
  PointerHeap(
    Map<String, String?> next,
    Map<String, String?> prior,
    Map<String, String?> roots, [
    Set<String> deleted = const {},
  ]) : next = Map.unmodifiable(next),
       prior = Map.unmodifiable(prior),
       roots = Map.unmodifiable(roots),
       deleted = Set.unmodifiable(deleted);
  factory PointerHeap.initial(PointerSandboxQuestion q) =>
      PointerHeap(q.initialNext, q.initialPrior, {
        for (final name in {...q.locals, ...q.expectedRoots.keys}) name: null,
        ...q.roots,
      });
  final Map<String, String?> next, prior, roots;
  final Set<String> deleted;
  bool live(String id) => next.containsKey(id) && !deleted.contains(id);
  PointerHeap connect(String? owner, String field, String? target) {
    if (target != null && !live(target)) throw StateError('目标 $target 已失效。');
    if (owner == null) {
      if (!roots.containsKey(field)) throw StateError('未知局部指针 $field。');
      return PointerHeap(next, prior, {...roots, field: target}, deleted);
    }
    if (!live(owner)) throw StateError('无法写入已释放结点 $owner。');
    if (field == 'next' || field == 'lchild') {
      return PointerHeap({...next, owner: target}, prior, roots, deleted);
    }
    if ((field == 'prior' || field == 'rchild') && prior.containsKey(owner)) {
      return PointerHeap(next, {...prior, owner: target}, roots, deleted);
    }
    throw StateError('结点 $owner 没有 $field 域。');
  }

  PointerHeap release(String id, {String? local}) {
    if (!live(id)) throw StateError('结点 $id 已释放。');
    // The exercise retires the operand variable. Other aliases remain dangling.
    return PointerHeap(next, prior, {...roots, ?local: null}, {...deleted, id});
  }

  PointerHeap execute(String card) {
    final text = card.replaceAll(RegExp(r'[;\s]'), '');
    String? resolve(List<String> path) {
      if (path.length == 1 && path.first == 'NULL') return null;
      if (!roots.containsKey(path.first)) {
        throw StateError('未知指针 ${path.first}。');
      }
      var target = roots[path.first];
      for (final field in path.skip(1)) {
        if (target == null || !live(target)) {
          throw StateError('解引用 ${target ?? "NULL"} 失败。');
        }
        target = switch (field) {
          'next' || 'lchild' => next[target],
          'prior' || 'rchild' when prior.containsKey(target) => prior[target],
          _ => throw StateError('未知指针域 $field。'),
        };
      }
      return target;
    }

    if (text.startsWith('free(') && text.endsWith(')')) {
      final operand = text.substring(5, text.length - 1).split('->');
      final id = resolve(operand);
      if (id == null) return this; // C free(NULL)
      return release(id, local: operand.length == 1 ? operand.single : null);
    }
    final sides = text.split('=');
    if (sides.length != 2) throw StateError('指令不是指针赋值。');
    final target = resolve(sides[1].split('->')), left = sides[0].split('->');
    if (left.length == 1) return connect(null, left.first, target);
    final owner = resolve(left.sublist(0, left.length - 1));
    if (owner == null) throw StateError('无法写入 NULL 的指针域。');
    return connect(owner, left.last, target);
  }

  Map<String, dynamic> toJson() => {
    'next': next,
    'prior': prior,
    'roots': roots,
    'deleted': deleted.toList(),
  };
}

class PointerSandboxJudge {
  const PointerSandboxJudge();
  PointerJudgeResult evaluate(PointerSandboxQuestion q, PointerHeap heap) {
    final result = evaluatePointerGraph(
      expectedNextMap: q.expectedNext,
      actualNextMap: heap.next,
      expectedPriorMap: q.expectedPrior,
      actualPriorMap: heap.prior,
      rootPointers: heap.roots.values.whereType<String>().toSet(),
      deletedNodes: heap.deleted,
      circular: q.circular,
      binaryTree: q.binaryTree,
    );
    if (!result.correct) return result;
    if (q.deletedNodes.length != heap.deleted.length ||
        !heap.deleted.containsAll(q.deletedNodes)) {
      return const PointerJudgeResult(PointerIssue.deletion, '核对题目要求释放的结点。');
    }
    for (final name in {...heap.roots.keys, ...q.expectedRoots.keys}) {
      if (heap.roots[name] != q.expectedRoots[name]) {
        return PointerJudgeResult(
          PointerIssue.roots,
          '指针 $name 还应指向 ${q.expectedRoots[name] ?? "NULL"}。',
          {if (heap.roots[name] != null) heap.roots[name]!},
        );
      }
    }
    return result;
  }
}
