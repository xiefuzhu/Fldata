part of 'btree.dart';

extension on _Run {
  // Each index slot stores its child's maximum, as in figure 7.27.
  void refreshIndex(_Page p) {
    p.keys
      ..clear()
      ..addAll(p.children.map((c) => c.keys.last));
  }

  void addPlus(int key) {
    var n = root ?? (root = page());
    while (!n.leaf) {
      n = n.children[math.min(n.lower(key), n.children.length - 1)];
    }
    final i = n.lower(key);
    if (i < n.keys.length && n.keys[i] == key) return;
    n.keys.insert(i, key);
    while (true) {
      if (n.keys.length <= input.order) {
        if (n.parent == null) return;
        n = n.parent!;
        refreshIndex(n);
        continue;
      }
      final right = page(), at = (input.order + 1) ~/ 2;
      if (n.leaf) {
        right.keys.addAll(n.keys.sublist(at));
        n.keys.removeRange(at, n.keys.length);
        right.next = n.next;
        n.next = right;
      } else {
        final tail = n.children.sublist(at);
        n.children.removeRange(at, n.children.length);
        for (final c in tail) {
          right.attach(right.children.length, c);
        }
        refreshIndex(n);
        refreshIndex(right);
      }
      final parent = n.parent ?? (root = page());
      if (parent.children.isEmpty) parent.attach(0, n);
      parent.attach(parent.children.indexOf(n) + 1, right);
      refreshIndex(parent);
      n = parent;
    }
  }

  void scan() {
    final lo = input.low, hi = input.high;
    operation = '[$lo, $hi]';
    var p = root;
    while (p != null && !p.leaf) {
      final i = p.lower(lo);
      emit(
        2,
        '索引',
        '在 ${p.id} 定位下界 $lo',
        i == p.keys.length
            ? '所有子树最大键都小于下界。'
            : '第 ${i + 1} 个索引键 ${p.keys[i]} ≥ $lo，下降至 ${p.children[i].id}。',
        focus: p,
        key: i < p.keys.length ? p.keys[i] : null,
        reads: 1,
      );
      if (i == p.keys.length) {
        p = null;
        break;
      }
      p = p.children[i];
    }
    var slot = p?.lower(lo) ?? 0;
    while (p != null) {
      emit(
        3,
        '叶页',
        '访问叶页 ${p.id}',
        '从第 ${slot + 1} 个槽开始检查记录。',
        focus: p,
        reads: 1,
      );
      while (slot < p.keys.length) {
        final k = p.keys[slot++];
        if (k > hi) {
          emit(
            5,
            '越界',
            '$k 超过上界 $hi',
            '后续叶键有序，本次扫描结束。',
            focus: p,
            key: k,
            compares: 1,
          );
          break;
        }
        hits.add(k);
        emit(
          4,
          '记录',
          '读取记录 R($k)',
          '$lo ≤ $k ≤ $hi，经叶槽中的记录指针取出。',
          focus: p,
          key: k,
          compares: 1,
        );
      }
      if (p.keys.last > hi || p.next == null) break;
      emit(
        6,
        '叶链',
        '沿叶链 ${p.id} → ${p.next!.id}',
        '从本页的后继指针进入下一页。',
        focus: p,
        link: p.next,
      );
      p = p.next;
      slot = 0;
    }
    result = hits.isEmpty ? '∅' : hits.join(' ');
    emit(
      7,
      '完成',
      '区间扫描完成',
      '闭区间 $operation 共命中 ${hits.length} 条记录。',
      milestone: true,
    );
  }
}
