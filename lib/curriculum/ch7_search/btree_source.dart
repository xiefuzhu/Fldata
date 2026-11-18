import '../../enum/ds_enums.dart';

// Each row is the same executable decision or pointer operation in three views.
Map<CodeLang, List<String>> multiwaySource(bool plus) {
  final rows = plus
      ? const [
          ('从根进入，保留闭区间的两端', 'Page *p=root; int i=0;', 'var p=root; var i=0;'),
          (
            '在索引页取首个最大键 ≥ low 的孩子',
            'while(p && !leaf(p)){ i=lower(p,low); p=i<p->n?p->child[i]:NULL; }',
            'while(p!=null && !p.leaf){ i=p.lower(low); p=i<p.keys.length?p.children[i]:null; }',
          ),
          (
            '从首个 ≥ low 的叶槽开始，换页后从首槽开始',
            'if(p)i=lower(p,low); while(p){ for(;i<p->n;i++){',
            'if(p!=null)i=p.lower(low); while(p!=null){ for(;i<p.keys.length;i++){',
          ),
          (
            '当前键 ≤ high 时，读取叶槽的记录指针',
            '  if(p->key[i]<=high) visit(p->record[i]);',
            '  if(p.keys[i]<=high){visit(p.records[i]);}',
          ),
          ('当前键 > high 时停止', '  else return; }', '  else {return;} }'),
          ('沿后继叶指针转到下一页', '  p=p->next; i=0; }', '  p=p.next; i=0; }'),
          ('返回已收集记录', 'return;', 'return;'),
        ]
      : const [
          ('装入初始树，依次处理操作', 'Page *t=initial;', 'var root=initial;'),
          (
            '在页内比较，选择孩子继续或在相等槽停下',
            'Result r=SearchBTree(t,key);',
            'final r=searchBTree(root,key);',
          ),
          (
            '返回页、位置及成功标志',
            'if(op==SEARCH) return r;',
            'if(op==search) return r;',
          ),
          (
            '插入到末层页的有序槽',
            'if(op==INSERT && !r.tag){ q=insert_slot(&t,r,key);',
            'if(op==insert && !r.found){ var q=insertSlot(r,key);',
          ),
          (
            '键数达到 m，取 s = ⌈m/2⌉ 为上推位置',
            '  while(q->n==m){ int s=(m+1)/2;',
            '  while(q.keys.length==m){ final s=(m+1)~/2;',
          ),
          (
            '拆出右页，将中键插入父页，根分裂则建新根',
            '    q=split_promote(&t,q,s); }}',
            '    q=splitPromote(q,s); }}',
          ),
          (
            '内部键由右子树最小记录接替，转到相应末层页',
            'if(op==DELETE && r.tag){ r=replace_by_successor_if_internal(r);',
            'if(op==remove && r.found){ final leaf=successorIfInternal(r);',
          ),
          ('移除末层记录', '  Page *q=erase_slot(r);', '  var q=eraseSlot(leaf);'),
          (
            '下溢时先查同一父页的相邻兄弟',
            '  while(q->parent && q->n<(m+1)/2-1){',
            '  while(q.parent!=null && q.keys.length<(m+1)~/2-1){',
          ),
          (
            '兄弟富余时，父键下沉，兄弟边界键上升',
            '    if(borrow_via_parent(q)) break;',
            '    if(borrowViaParent(q)) break;',
          ),
          (
            '否则合并两页和父键，向上修复，空根降高',
            '    q=merge_with_separator(q); } shrink_empty_root(&t); }',
            '    q=mergeWithSeparator(q); } root=shrinkEmptyRoot(root); }',
          ),
          ('返回操作结果', 'return result;', 'return result;'),
        ];
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
