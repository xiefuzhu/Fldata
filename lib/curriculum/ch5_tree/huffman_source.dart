part of 'huffman_expr.dart';

// The debugger aligns the same operation across the three language tabs.
const _buildSource = {
  CodeLang.cLike: [
    'initialize HT[1..2n−1]; read n leaf weights',
    'for i = n+1..2n−1: select two smallest unparented roots s1,s2',
    '  HT[i] = join(s1,s2); WPL += HT[i].weight',
    'for each leaf: ascend via parent; prepend 0 for left, 1 for right',
    '  HC[leaf] = completed code',
  ],
  CodeLang.c99: [
    'HTNode HT[2*n]; initialize(HT, weights, n);',
    'for(int i=n+1;i<2*n;i++){ selectTwo(HT,i-1,&s1,&s2);',
    '  HT[i]=join(HT,i,s1,s2); wpl+=HT[i].weight; }',
    'for(int i=1;i<=n;i++){ int j=n-1; buf[j]=0; for(int c=i,p; (p=HT[c].parent); c=p) buf[--j]=HT[p].lchild==c?\'0\':\'1\';',
    '  HC[i]=copyString(buf+j); }',
  ],
  CodeLang.dart: [
    'final ht = initialize(weights);',
    'while (ht.length < 2*n) { final (s1,s2) = selectTwo(ht);',
    '  join(ht,s1,s2); wpl += ht.last.weight; }',
    'for (var i=1;i<=n;i++) { var s=""; for(var c=i;ht[c].parent!=0;){ final p=ht[c].parent; s=(ht[p].left==c?"0":"1")+s; c=p; }',
    '  codes[ht[i].symbol!] = s; }',
  ],
};
const _decodeSource = {
  CodeLang.cLike: [
    'p = root',
    'for bit in stream: follow child; at leaf output symbol and reset p',
    'return output',
  ],
  CodeLang.c99: [
    'int p=root;',
    'for(size_t k=0; k<len; ++k){ p=bits[k]==\'0\'?HT[p].lchild:HT[p].rchild; if(!HT[p].lchild){ emit(p); p=root; } }',
    'return p==root;',
  ],
  CodeLang.dart: [
    'var p=root;',
    'for(final bit in bits.split("")){ p=bit=="0"?ht[p].left:ht[p].right; if(ht[p].symbol!=null){ output.write(ht[p].symbol); p=root; } }',
    'return output.toString();',
  ],
};
const _exprSource = {
  CodeLang.cLike: [
    'push(OPTR,#); EXPT = empty',
    'operand: push(EXPT,leaf(token)); advance',
    'compare top(OPTR) with token',
    '< : push(OPTR, token); advance',
    '= : remove matching parentheses; advance',
    '> : pop operator, right and left roots; push their new parent',
    'when both marks are #: root = top(EXPT)',
    'EvaluateExpTree(T):',
    '  if leaf: return its integer value',
    '  return apply(T.op, Evaluate(left), Evaluate(right))',
    'result = EvaluateExpTree(root)',
    'report input or evaluation error',
  ],
  CodeLang.c99: [
    'pushOp(\'#\');',
    'if(number(tok)){ pushTree(leaf(tok)); advance(); }',
    'else switch(precede(peekOp(),tok)){',
    'case \'<\': pushOp(tok); advance(); break;',
    'case \'=\': popOp(); advance(); break;',
    'case \'>\': op=popOp(); b=popTree(); a=popTree(); pushTree(node(op,a,b)); break; }',
    'Tree *root=peekTree();',
    'int eval(Tree *t){',
    '  if(!t->left) return value(t);',
    '  int a=eval(t->left); int b=eval(t->right); return apply(t->op,a,b); }',
    'result=eval(root);',
    'reportError();',
  ],
  CodeLang.dart: [
    'final optr=["#"], expt=<Node>[];',
    'if(number(token)){ expt.add(leaf(token)); advance(); }',
    'else { switch(compare(optr.last,token)){',
    'case "<": optr.add(token); advance();',
    'case "=": optr.removeLast(); advance();',
    'case ">": final op=optr.removeLast(), b=expt.removeLast(), a=expt.removeLast(); expt.add(node(op,a,b)); }}',
    'final root=expt.single;',
    'BigInt eval(Node t){',
    '  if(t.left==null) return BigInt.parse(t.token);',
    '  return apply(t.token,eval(t.left!),eval(t.right!)); }',
    'final result=eval(root);',
    'throw FormatException(message);',
  ],
};
