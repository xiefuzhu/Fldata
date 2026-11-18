import 'dart:math';
import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'textbook_design.dart';

AlgorithmTestCase _case(
  String name,
  Map<String, dynamic> input,
  Object expected,
) => AlgorithmTestCase(name: name, input: input, expected: expected);

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
String _sample(int seed, int n) {
  final rng = Random(seed);
  return List.generate(
    n,
    (_) => _alphabet[rng.nextInt(_alphabet.length)],
  ).join();
}

final _longText = _sample(401, 160);
final _numbers = List.generate(144, (i) => i - 72)..shuffle(Random(406));
AlgorithmTestCase _frequencies(String name, String s) => _case(
  name,
  {'text': s},
  {
    for (final c in _alphabet.split(''))
      if (s.contains(c)) c: s.split(c).length - 1,
  },
);
AlgorithmTestCase _reverse(String name, String s) =>
    _case(name, {'text': s}, s.split('').reversed.join());
AlgorithmTestCase _insert(String name, String s, String t, int pos) => _case(
  name,
  {'s': s, 't': t, 'pos': pos},
  s.substring(0, pos - 1) + t + s.substring(pos - 1),
);
AlgorithmTestCase _line(
  String name,
  String s,
  int n,
  String out,
  String rest,
) => _case(name, {'text': s, 'width': n}, [out, rest]);
AlgorithmTestCase _matrix(String name, List<List<int>> rows, bool unique) =>
    _case(name, {'rows': rows}, unique ? 'yes' : 'no');
AlgorithmTestCase _partition(String name, List<int> a, List<int> expected) =>
    _case(name, {'a': a}, expected);

final ch4TextbookCode = List<CodeQuestion>.unmodifiable([
  textbookDesign(
    ChapterId.ch4,
    3,
    1,
    page: 109,
    title: "字符频度写入文件",
    topic: "字符频度写入文件",
    prompt:
        r'''写一个算法统计在输入字符串中各个不同字符出现的频度并将结果存入文件（字符串中的合法字符为 A～Z 这 26 个字母和 0～9 这 10 个数字）。''',
    explanation:
        r'''用 36 个计数槽累计频度，再按 A～Z、0～9 的次序把非零项写入调用者打开的输出文件。Dart 对照返回同一字符到频度的映射。时间 O(n+36)。''',
    template: r'''#include <stdio.h>
void write_frequency(const char *s, FILE *out) {
    unsigned long freq[36] = {0};
    for (; *s; ++s) {
        int k = (*s >= 'A' && *s <= 'Z') ? *s-'A' : /*BLANK_1*/;
        ++freq[k];
    }
    for (int k=0; k<36; ++k) {
        if (/*BLANK_2*/) {
            int ch = k<26 ? 'A'+k : '0'+k-26;
            fprintf(out, "%c %lu\n", ch, freq[k]);
        }
    }
}''',
    answers: ["26 + *s - '0'", r'''freq[k] != 0'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final result = <String, int>{};
  for (final c in (input['text'] as String).split('')) {
    result.update(c, (n) => n + 1, ifAbsent: () => 1);
  }
  return result;
}''',
    cases: [
      _frequencies('字母和数字', 'A0AZ09Z'),
      _frequencies('空串', ''),
      _frequencies('单个数字', '7'),
      _frequencies('全重复', 'AAAAAA'),
      _frequencies('两段下标边界', 'AZ09'),
      _frequencies('固定种子长串', _longText),
    ],
  ),
  textbookDesign(
    ChapterId.ch4,
    3,
    2,
    page: 109,
    title: "递归原地逆序",
    topic: "递归原地逆序",
    prompt: r'''写一个递归算法来实现字符串逆序存储，要求不另设串存储空间。''',
    explanation:
        r'''交换当前区间的两端，再递归处理内部区间。只使用单字符临时量和递归调用栈。C 直接修改可写字符数组，Dart 把输入转换为可修改的字符序列后执行同一原地递归。''',
    template: r'''static void reverse_range(char s[], int lo, int hi) {
    if (/*BLANK_1*/) return;
    char tmp = s[lo]; s[lo] = s[hi]; s[hi] = tmp;
    reverse_range(s, /*BLANK_2*/, hi-1);
}
void reverse_string(char s[]) {
    int n=0; while (s[n]) ++n;
    reverse_range(s,0,n-1);
}''',
    answers: [r'''lo >= hi''', r'''lo + 1'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final data = (input['text'] as String).split('');
  void reverse(int lo, int hi) {
    if (lo >= hi) return;
    final saved = data[lo];
    data[lo] = data[hi];
    data[hi] = saved;
    reverse(lo + 1, hi - 1);
  }

  reverse(0, data.length - 1);
  return data.join();
}''',
    cases: [
      _reverse('奇数长度', 'ABCDE'),
      _reverse('空串', ''),
      _reverse('单字符', 'Z'),
      _reverse('相同字符', 'BBBB'),
      _reverse('首尾互换', 'ab'),
      _reverse('固定种子长串', _longText),
    ],
  ),
  textbookDesign(
    ChapterId.ch4,
    3,
    3,
    page: 109,
    title: "无库函数插串",
    topic: "无库函数插串",
    prompt:
        r'''编写算法，实现下面函数的功能。函数 void insert(char *s, char *t, int pos) 将字符串 t 插入到字符串 s 中，插入位置为 pos。假设分配给字符串 s 的空间足够让字符串 t 插入。（说明：不得使用任何库函数）''',
    explanation:
        r'''本解约定位序从 1 起，pos 指插入前的位置，len(s)+1 表示追加；t 为独立字符串。先从后往前搬移后缀及终止符，再从左往右复制 t。时间 O(|s|+|t|)。''',
    template: r'''void insert(char *s, char *t, int pos) {
    int n=0, m=0;
    while (s[n]) ++n;
    while (t[m]) ++m;
    int at=pos-1;
    for (int i=n; i>=at; --i) s[/*BLANK_1*/]=s[i];
    for (int i=0; i<m; ++i) s[/*BLANK_2*/]=t[i];
}''',
    answers: [r'''i + m''', r'''at + i'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final s = (input['s'] as String).codeUnits,
      t = (input['t'] as String).codeUnits;
  final at = (input['pos'] as int) - 1,
      buffer = [...s, ...List.filled(t.length, 0), 0];
  for (var i = s.length; i >= at; i--) {
    buffer[i + t.length] = buffer[i];
  }
  for (var i = 0; i < t.length; i++) {
    buffer[at + i] = t[i];
  }
  return String.fromCharCodes(buffer.take(buffer.length - 1).toList());
}''',
    cases: [
      _insert('中间插入', 'abcd', 'XY', 3),
      _insert('空目标', '', 'XY', 1),
      _insert('插到首位', 'a', 'b', 1),
      _insert('相同字符', 'aaaa', 'aa', 3),
      _insert('尾部空插入', 'abc', '', 4),
      _insert('长串末尾追加', _longText, 'TAIL', _longText.length + 1),
    ],
  ),
  textbookDesign(
    ChapterId.ch4,
    3,
    4,
    page: 109,
    title: "英文段落两端对齐",
    topic: "英文段落两端对齐",
    prompt:
        r'''已知字符串 S1 中存放一段英文，写出算法 format(s1, s2, s3, n)，将其按给定的长度 n 格式化成两端对齐的字符串 S2，其多余的字符送 S3。''',
    explanation:
        r'''取能放入宽 n 的最长完整单词前缀。词间空格均分，余数从左侧起每处多一个；单词独占一行时右补空格。若首词超过宽度，先截取 n 个字符，其余送 S3。输入按英文空格分词，S3 从首个未使用字符或下一个单词起保留余文，宽 0 时保留整个输入。''',
    template: r'''#include <stddef.h>
#include <string.h>
void format(const char *s1, char *s2, char *s3, size_t n) {
    const char *p=s1, *start, *rest=s1;
    size_t words=0, letters=0, out=0;
    if (!n) { s2[0]=0; strcpy(s3,s1); return; }
    while (*p==' ') ++p;
    start=p;
    while (*p) {
        const char *word=p;
        while (*p && *p!=' ') ++p;
        size_t len=(size_t)(p-word);
        if (letters+words+len>n) {
            if (!words) { memcpy(s2,word,n); s2[n]=0; strcpy(s3,word+n); return; }
            rest=word; break;
        }
        letters+=len; ++words;
        while (*p==' ') ++p;
        rest=p;
    }
    p=start;
    for (size_t i=0; i<words; ++i) {
        while (*p && *p!=' ') s2[out++]=*p++;
        while (*p==' ') ++p;
        if (i+1<words) {
            size_t spaces=(n-letters)/(words-1) + (/*BLANK_1*/);
            while (spaces--) s2[out++]=' ';
        }
    }
    while (out<n) s2[out++]=' ';
    s2[out]=0; strcpy(s3,/*BLANK_2*/);
}''',
    answers: [r'''i < (n-letters) % (words-1)''', r'''words ? rest : p'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final s = input['text'] as String, n = input['width'] as int;
  if (n == 0) return ['', s];
  final words = <String>[];
  var letters = 0, rest = s.length;
  for (final match in RegExp(r'[^ ]+').allMatches(s)) {
    final w = match[0]!;
    if (letters + words.length + w.length > n) {
      if (words.isEmpty)
        return [w.substring(0, n), s.substring(match.start + n)];
      rest = match.start;
      break;
    }
    letters += w.length;
    words.add(w);
  }
  final line = StringBuffer();
  for (var i = 0; i < words.length; i++) {
    if (i > 0) {
      final gaps = words.length - 1, spaces = n - letters;
      line.write(' ' * (spaces ~/ gaps + (i <= spaces % gaps ? 1 : 0)));
    }
    line.write(words[i]);
  }
  return [line.toString().padRight(n), s.substring(rest)];
}''',
    cases: [
      _line('间隔余数分给左侧', 'aa b c dddd', 7, 'aa  b c', 'dddd'),
      _line('空段落', '', 4, '    ', ''),
      _line('单词补空格', 'A', 3, 'A  ', ''),
      _line('重复单词', 'a a a a', 6, 'a  a a', 'a'),
      _line('首词跨行', 'abcdef gh', 3, 'abc', 'def gh'),
      _line('固定种子长段落', 'Go $_longText', 6, 'Go    ', _longText),
    ],
  ),
  textbookDesign(
    ChapterId.ch4,
    3,
    5,
    page: 110,
    title: "二维数组元素互异",
    topic: "二维数组元素互异",
    prompt: r'''设二维数组 a[1..m,1..n] 含有 m×n 个整数。

① 写一个算法判断 a 中所有元素是否互不相同？输出相关信息（yes/no）；
② 试分析算法的时间复杂度。''',
    explanation:
        r'''按行把矩阵看作 k=m×n 个元素。每对位置只比较一次，发现相等立即输出 no，否则输出 yes。最坏比较 k(k−1)/2 次，时间 O(m²n²)，额外空间 O(1)。''',
    template: r'''#include <stddef.h>
#include <stdio.h>
void distinct(const int *a, size_t m, size_t n, FILE *out) {
    size_t k=m*n;
    for (size_t i=0; i<k; ++i)
        for (size_t j=/*BLANK_1*/; j<k; ++j)
            if (/*BLANK_2*/) { fputs("no",out); return; }
    fputs("yes",out);
}''',
    answers: [r'''i + 1''', r'''a[i] == a[j]'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final rows = (input['rows'] as List).cast<List>(),
      n = rows.isEmpty ? 0 : rows.first.length,
      k = rows.length * n;
  for (var i = 0; i < k; i++) {
    for (var j = i + 1; j < k; j++) {
      if (rows[i ~/ n][i % n] == rows[j ~/ n][j % n]) return 'no';
    }
  }
  return 'yes';
}''',
    cases: [
      _matrix('互异的矩阵', [
        [0, -1],
        [9, 4],
      ], true),
      _matrix('零行', [], true),
      _matrix('单个整数', [
        [0],
      ], true),
      _matrix('全重复', [
        [7, 7],
        [7, 7],
      ], false),
      _matrix('首尾相同', [
        [3, 1, 2],
        [5, 4, 3],
      ], false),
      _matrix('固定种子互异矩阵', [
        for (var i = 0; i < 144; i += 12) _numbers.sublist(i, i + 12),
      ], true),
    ],
  ),
  textbookDesign(
    ChapterId.ch4,
    3,
    6,
    page: 110,
    title: "正负数线性分区",
    topic: "正负数线性分区",
    prompt:
        r'''设任意 n 个整数存放于数组 A[1..n] 中，试编写算法，将所有正数排在所有负数前面（要求：算法的时间复杂度为 O(n)）。''',
    explanation:
        r'''用 next 记录下一正数应占的位置，扫描中每见正数就交换至前段。一次扫描且原地完成。题目未规定零的位置，本解把零与负数放在正数之后；负数之间的相对次序可变。''',
    template: r'''void positives_first(int a[], int n) {
    int next=1;
    for (int i=1; i<=n; ++i) {
        if (/*BLANK_1*/) {
            int tmp=a[next]; a[next]=a[i]; a[i]=tmp;
            /*BLANK_2*/;
        }
    }
}''',
    answers: [r'''a[i] > 0''', r'''++next'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final a = List<int>.from(input['a']);
  var next = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] > 0) {
      final tmp = a[next];
      a[next] = a[i];
      a[i] = tmp;
      next++;
    }
  }
  return a;
}''',
    cases: [
      _partition('正负交错', [-1, 2, -3, 4], [2, 4, -3, -1]),
      _partition('空数组', [], []),
      _partition('单个零', [0], [0]),
      _partition('全重复负数', [-3, -3, -3], [-3, -3, -3]),
      _partition('零在首位', [0, -1, 3, 4], [3, 4, 0, -1]),
      _partition(
        '固定种子长分区',
        [...List.filled(144, -1), ..._numbers.map((v) => v.abs() + 1)],
        [..._numbers.map((v) => v.abs() + 1), ...List.filled(144, -1)],
      ),
    ],
  ),
]);
