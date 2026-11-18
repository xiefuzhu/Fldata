import '../../enum/ds_enums.dart';
import 'cases_expr_dance.dart';

class CasesSource {
  CasesSource(CaseKind kind) {
    void row(String tag, String c, String dart) {
      tags[tag] = lines[CodeLang.dart]!.length + 1;
      for (final lang in CodeLang.values) {
        lines[lang]!.add(lang == CodeLang.dart ? dart : c);
      }
    }

    row(
      'intro',
      '// 教学重建：输入范围由课程表单限定；栈顶为有效末项。',
      '// 教学重建：输入范围由课程表单限定；List 末项为栈顶。',
    );
    row('header', '#include <stdio.h>', '// Dart 独立实现；不依赖 Flutter。');
    row('stdlib', '#include <stdlib.h>', '// 动态列表承载教学栈/队列');
    row('string', '#include <string.h>', '// 数值运算采用 double，除法为实数除法');
    row('ctype', '#include <ctype.h>', '// 栈操作按语义微步对齐');
    switch (kind) {
      case CaseKind.conversion:
        row(
          'entry',
          'void Convert(int N,int d,char *out){',
          'String Convert(int N,int d){',
        );
        row(
          'init',
          ' int S[32],top=0,k=0; const char *digits="0123456789ABCDEF";',
          ' final S=<int>[]; var out=""; const digits="0123456789ABCDEF";',
        );
        row('zero', ' if(N==0) S[top++]=0;', ' if(N==0) S.add(0);');
        row('loop', ' while(N>0){', ' while(N>0){');
        row('push', '  S[top++]=N%d;', '  S.add(N%d);');
        row('divide', '  N=N/d;', '  N=N~/d;');
        row('close', ' }', ' }');
        row('pop-loop', ' while(top>0){', ' while(S.isNotEmpty){');
        row('pop', '  int r=S[--top];', '  final r=S.removeLast();');
        row('emit', '  out[k++]=digits[r];', '  out+=digits[r];');
        row('pop-close', ' }', ' }');
        row('done', ' out[k]=0; }', ' return out; }');
      case CaseKind.brackets:
        row(
          'pair',
          "int matches(char a,char b){return (a=='('&&b==')')||(a=='['&&b==']')||(a=='{'&&b=='}');}",
          "bool matches(String a,String b)=>'([{'.indexOf(a)==')]}'.indexOf(b);",
        );
        row(
          'entry',
          'int Match(const char *s){ // 0 OK; 1 left; 2 right; 3 mismatch',
          'String Match(String s){',
        );
        row('init', ' char S[32]; int top=0;', ' final S=<String>[];');
        row(
          'read',
          ' for(int i=0;s[i];i++){char ch=s[i]; if(isspace((unsigned char)ch))continue;',
          ' for(final ch in s.split("")){if(ch.trim().isEmpty)continue;',
        );
        row(
          'push',
          "  if(strchr(\"([{\",ch)){S[top++]=ch;continue;}",
          "  if('([{'.contains(ch)){S.add(ch);continue;}",
        );
        row('right', '  if(top==0)return 2;', '  if(S.isEmpty)return "右括号冗余";');
        row('pop', '  char left=S[--top];', '  final left=S.removeLast();');
        row(
          'match',
          '  if(!matches(left,ch))return 3;',
          '  if(!matches(left,ch))return "左右类型不符";',
        );
        row('close', ' }', ' }');
        row('left', ' if(top>0)return 1;', ' if(S.isNotEmpty)return "左括号冗余";');
        row('done', ' return 0; }', ' return "匹配成功"; }');
      case CaseKind.expression:
        row(
          'ops',
          'const char *operators="+-*/()#";',
          'const operators="+-*/()#";',
        );
        row(
          'matrix',
          'const char *matrix[]={">><<<>>",">><<<>>",">>>><>>",">>>><>>","<<<<<=!",">>>>!>>","<<<<<!="};',
          'const matrix=[">><<<>>",">><<<>>",">>>><>>",">>>><>>","<<<<<=!",">>>>!>>","<<<<<!="];',
        );
        row(
          'precede',
          'char Precede(char a,char b){return matrix[strchr(operators,a)-operators][strchr(operators,b)-operators];}',
          'String Precede(String a,String b)=>matrix[operators.indexOf(a)][operators.indexOf(b)];',
        );
        row(
          'operate',
          "double Operate(double a,char t,double b){switch(t){case '+':return a+b;case '-':return a-b;case '*':return a*b;default:return a/b;}}",
          'double Operate(double a,String t,double b)=>switch(t){"+"=>a+b,"-"=>a-b,"*"=>a*b,_=>a/b};',
        );
        row(
          'entry',
          'double Evaluate(const char *s,int *error){',
          '(double?,String) Evaluate(String s){',
        );
        row(
          'init',
          " char OPTR[64]={'#'};double OPND[64];int t=1,n=0,i=0,need=1;*error=0;",
          ' final OPTR=<String>["#"],OPND=<double>[];var i=0,need=true;final tokens=RegExp(r"[0-9]+|[^\\s]").allMatches(s).map((m)=>m[0]!).toList();',
        );
        row(
          'read',
          ' while(1){while(isspace((unsigned char)s[i]))i++;char ch=s[i];',
          ' while(true){final ch=tokens[i];',
        );
        row(
          'number-check',
          '  if(isdigit((unsigned char)ch)){if(!need){*error=1;return 0;}',
          '  if(double.tryParse(ch)!=null){if(!need)return (null,"缺少运算符");',
        );
        row(
          'number',
          '   char *end;OPND[n++]=strtod(s+i,&end);i=(int)(end-s);need=0;continue;}',
          '   OPND.add(double.parse(ch));i++;need=false;continue;}',
        );
        row(
          'syntax',
          "  if((ch=='('&&!need)||(ch!='('&&need)){*error=1;return 0;}",
          '  if((ch=="("&&!need)||(ch!="("&&need))return (null,"缺少操作数或运算符");',
        );
        row(
          'compare',
          '  char relation=Precede(OPTR[t-1],ch);',
          '  final relation=Precede(OPTR.last,ch);',
        );
        row(
          'invalid',
          "  if(relation=='!'){*error=2;return 0;}",
          '  if(relation=="!")return (null,"括号不匹配");',
        );
        row(
          'accept',
          "  if(OPTR[t-1]=='#'&&ch=='#'){if(n!=1){*error=1;return 0;}return OPND[0];}",
          '  if(OPTR.last=="#"&&ch=="#")return OPND.length==1?(OPND.single,""):(null,"缺少运算符");',
        );
        row(
          'push',
          "  if(relation=='<'){OPTR[t++]=ch;i++;need=1;continue;}",
          '  if(relation=="<"){OPTR.add(ch);i++;need=true;continue;}',
        );
        row(
          'equal',
          "  if(relation=='='){t--;i++;need=0;continue;}",
          '  if(relation=="="){OPTR.removeLast();i++;need=false;continue;}',
        );
        row(
          'operands',
          '  if(n<2){*error=1;return 0;}',
          '  if(OPND.length<2)return (null,"缺少操作数");',
        );
        row('pop-b', '  double b=OPND[--n];', '  final b=OPND.removeLast();');
        row('pop-a', '  double a=OPND[--n];', '  final a=OPND.removeLast();');
        row(
          'pop-theta',
          '  char theta=OPTR[--t];',
          '  final theta=OPTR.removeLast();',
        );
        row(
          'zero',
          "  if(theta=='/'&&b==0){*error=3;return 0;}",
          '  if(theta=="/"&&b==0)return (null,"除数为零");',
        );
        row(
          'compute',
          '  double result=Operate(a,theta,b);',
          '  final result=Operate(a,theta,b);',
        );
        row('result', '  OPND[n++]=result;', '  OPND.add(result);');
        row('close', ' } }', ' } }');
      case CaseKind.dance:
        row(
          'entry',
          'void Dance(const char **M,int nm,const char **F,int nf,int rounds){',
          '(List<String>,List<String>,List<String>) Dance(List<String> male,List<String> female,int rounds){',
        );
        row(
          'init',
          ' const char *mp[6],*fp[6];',
          ' final M=List<String>.of(male),F=List<String>.of(female),history=<String>[];',
        );
        row(
          'round',
          ' for(int round=1;round<=rounds;round++){int pairs=0;',
          ' for(var round=1;round<=rounds;round++){final mp=<String>[],fp=<String>[];',
        );
        row(
          'loop',
          '  while(nm>0&&nf>0){',
          '  while(M.isNotEmpty&&F.isNotEmpty){',
        );
        row(
          'male',
          '   const char *m=M[0];for(int j=1;j<nm;j++)M[j-1]=M[j];nm--;',
          '   final m=M.removeAt(0);',
        );
        row(
          'female',
          '   const char *f=F[0];for(int j=1;j<nf;j++)F[j-1]=F[j];nf--;',
          '   final f=F.removeAt(0);',
        );
        row(
          'pair',
          '   mp[pairs]=m;fp[pairs]=f;pairs++;printf("%d: %s + %s\\n",round,m,f);',
          r'   mp.add(m);fp.add(f);history.add("$round: $m + $f");',
        );
        row('close', '  }', '  }');
        row('wait', '  /* 未配对者留在队首，优先参加下一曲。 */', '  // 未配对者留在队首，优先参加下一曲。');
        row(
          'return',
          '  for(int j=0;j<pairs;j++){M[nm++]=mp[j];F[nf++]=fp[j];}',
          '  for(var j=0;j<mp.length;j++){M.add(mp[j]);F.add(fp[j]);}',
        );
        row('round-close', ' }', ' }');
        row(
          'done',
          '} // M/F 为下一曲队序；数组移动只是顺序队列实现。',
          ' return (M,F,history); }',
        );
    }
  }
  final lines = <CodeLang, List<String>>{
    for (final lang in CodeLang.values) lang: [],
  };
  final tags = <String, int>{};
}
