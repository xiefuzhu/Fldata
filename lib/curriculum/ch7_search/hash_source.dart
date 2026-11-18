part of 'hash_table.dart';

Map<CodeLang, List<String>> hashSource(HashCollision method) {
  final offset = switch (method) {
    HashCollision.linear => 'i',
    HashCollision.quadratic => 'signed_square(i)',
    _ => 'offsets[i]',
  };
  final rows = method == HashCollision.chain
      ? const [
          (
            '计算入口 h，取得桶头及其链接位置',
            'int h=H(key); Node **link=&HT[h];',
            'final h=hash(key); var p=head[h]; Node? prev;',
          ),
          (
            '比较链中记录，失配后沿 next 前进',
            'while(*link && (*link)->key!=key) link=&(*link)->next;',
            'while(p!=null && p.key!=key){ prev=p; p=p.next; }',
          ),
          ('读到空指针，查找失败', 'int found=(*link!=NULL);', 'final found=p!=null;'),
          (
            '链地址删除直接重接链接',
            '/* A chain has no deleted-slot state. */',
            '// 链不使用墓碑。',
          ),
          (
            '当前记录关键字相等即命中',
            'if(found && op==SEARCH) return FOUND;',
            'if(found && op==search) return hit;',
          ),
          (
            '相等键不重复接入',
            'if(found && op==INSERT) return DUPLICATE;',
            'if(found && op==insert) return duplicate;',
          ),
          (
            '插入时将新记录接到当前空链接',
            'if(!found && op==INSERT) *link=new_node(key);',
            'if(!found && op==insert) appendAt(h,prev,Node(key));',
          ),
          (
            '删除时重接前驱或桶头',
            'if(found && op==DELETE){ Node *old=*link; *link=old->next; free(old); }',
            'if(found && op==remove) relink(h,prev,p!.next);',
          ),
          ('返回本次操作结果', 'return status(op,found);', 'return status(op,found);'),
        ]
      : [
          (
            '计算初始地址，清除已记墓碑与空位',
            'int h=H(key), first=-1, empty=-1, hit=-1;',
            'final h=hash(key); int? first,empty,hit;',
          ),
          (
            '按探测序列计算地址并读取槽状态',
            'for(int i=0;i<m;i++){ int a=((h+$offset)%m+m)%m;',
            'for(var i=0;i<m;i++){ final a=(h+$offset)%m;',
          ),
          (
            '遇到从未使用的空槽即可结束',
            '  if(HT[a].state==EMPTY){ empty=a; break; }',
            '  if(ht[a].empty){ empty=a; break; }',
          ),
          (
            '墓碑保留探测链，插入时记住首个可复用槽',
            '  if(HT[a].state==DELETED){ if(first<0) first=a; continue; }',
            '  if(ht[a].deleted){ first??=a; continue; }',
          ),
          (
            '关键字相等则记录命中地址',
            '  if(HT[a].key==key){ hit=a; break; } }',
            '  if(ht[a].key==key){ hit=a; break; } }',
          ),
          (
            '完成去重检查，优先选择首个墓碑',
            'int dest=first>=0?first:empty;',
            'final dest=first??empty;',
          ),
          (
            '有可写槽且未命中时才插入',
            'if(op==INSERT && hit<0 && dest>=0) store(HT,dest,key);',
            'if(op==insert && hit==null && dest!=null) store(dest,key);',
          ),
          (
            '删除时把命中槽标为 DELETED',
            'if(op==DELETE && hit>=0) HT[hit].state=DELETED;',
            'if(op==remove && hit!=null) ht[hit].markDeleted();',
          ),
          (
            '返回命中地址或失败状态',
            'return result(op,hit,dest);',
            'return result(op,hit,dest);',
          ),
        ];
  return {
    CodeLang.cLike: [for (final r in rows) r.$1],
    CodeLang.c99: [for (final r in rows) r.$2],
    CodeLang.dart: [for (final r in rows) r.$3],
  };
}
