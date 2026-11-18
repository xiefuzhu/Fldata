part of 'ch3_textbook_code.dart';

CodeQuestion _doubleStack() {
  final values = _randomValues(301, 128);
  AlgorithmTestCase run(
    String name,
    int m,
    List<List<Object>> ops,
    List<Object> events,
    List<int> top,
  ) => _example(
    name,
    {'capacity': m, 'ops': ops},
    {'events': events, 'top': top},
  );
  return _design(
    1,
    title: "共享数组双栈",
    topic: "shared-stack",
    prompt:
        r'''将编号为0和1的两个栈存放于一个数组空间V[m]中，栈底分别处于数组的两端。当第0号栈的栈顶指针top[0]等于−1时该栈为空；当第1号栈的栈顶指针top[1]等于m时，该栈为空。两个栈均从两端向中间增长（见图3.17）。试编写双栈初始化，判断栈空、栈满，进栈和出栈等算法的函数。双栈数据结构的定义如下：

```c
typedef struct {
    int top[2], bot[2];  // 栈顶和栈底指针
    SElemType *V;        // 栈数组
    int m;               // 栈最大可容纳元素个数
} DblStack;
```

图 3.17 双栈结构的表示（依原图重绘）

```text
bot[0]   V[0] … V[top[0]] | 空闲区 | V[top[1]] … V[m−1]   bot[1]
  −1           增长 →                     ← 增长             m
```''',
    explanation:
        r'''用 −1 和 m 作为两个空栈的栈底位置。当 top[0]+1==top[1] 时，共享空间耗尽。0 号栈入栈时下标增一，1 号栈入栈时下标减一，出栈方向相反。初始化借用调用者给出的数组空间。''',
    template: r'''#include <stdbool.h>
typedef int SElemType;
typedef struct { int top[2], bot[2]; SElemType *V; int m; } DblStack;

void Init(DblStack *s, SElemType storage[], int m) {
    s->m = m; s->V = storage;
    s->top[0] = s->bot[0] = -1;
    s->top[1] = s->bot[1] = m;
}
bool Empty(const DblStack *s, int k) { return s->top[k] == s->bot[k]; }
bool Full(const DblStack *s) { return /*BLANK_1*/; }
bool Push(DblStack *s, int k, SElemType x) {
    if (Full(s)) return false;
    s->top[k] += /*BLANK_2*/;
    s->V[s->top[k]] = x;
    return true;
}
bool Pop(DblStack *s, int k, SElemType *x) {
    if (Empty(s, k)) return false;
    *x = s->V[s->top[k]];
    s->top[k] += /*BLANK_3*/;
    return true;
}''',
    answers: [
      r'''s->top[0] + 1 == s->top[1]''',
      r'''k == 0 ? 1 : -1''',
      r'''k == 0 ? -1 : 1''',
    ],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final m = input['capacity'] as int, cells = List<int>.filled(m, 0);
  final bottom = [-1, m], top = [-1, m], events = <Object>[];
  for (final op in input['ops'] as List) {
    final k = op[1] as int, dir = k == 0 ? 1 : -1;
    final empty = top[k] == bottom[k], full = top[0] + 1 == top[1];
    switch (op[0]) {
      case 'empty':
        events.add(empty);
      case 'full':
        events.add(full);
      case 'push':
        events.add(!full);
        if (!full) {
          top[k] += dir;
          cells[top[k]] = op[2] as int;
        }
      case 'pop':
        if (empty) {
          events.add('EMPTY');
        } else {
          events.add(cells[top[k]]);
          top[k] -= dir;
        }
    }
  }
  return {'events': events, 'top': top};
}''',
    cases: [
      run(
        '两端向中间增长',
        3,
        [
          ['push', 0, 8],
          ['push', 1, 5],
          ['push', 1, 7],
          ['full', 0],
          ['pop', 1],
          ['pop', 0],
        ],
        [true, true, true, true, 7, 8],
        [-1, 2],
      ),
      run(
        '无可用槽',
        0,
        [
          ['empty', 1],
          ['full', 0],
          ['push', 0, 1],
          ['pop', 0],
        ],
        [true, true, false, 'EMPTY'],
        [-1, 0],
      ),
      run(
        '单槽改由另一栈使用',
        1,
        [
          ['push', 1, 6],
          ['push', 0, 4],
          ['pop', 1],
          ['push', 0, 4],
        ],
        [true, false, 6, true],
        [0, 1],
      ),
      run(
        '同值分属两栈',
        2,
        [
          ['push', 0, 4],
          ['push', 1, 4],
          ['pop', 0],
          ['pop', 1],
        ],
        [true, true, 4, 4],
        [-1, 2],
      ),
      run(
        '两栈各自判空',
        2,
        [
          ['push', 0, 4],
          ['empty', 0],
          ['empty', 1],
          ['pop', 1],
          ['full', 1],
        ],
        [true, false, true, 'EMPTY', false],
        [0, 2],
      ),
      run(
        '固定种子交替装满再出栈',
        values.length,
        [
          for (final (i, v) in values.indexed) ['push', i % 2, v],
          for (var i = values.length - 1; i >= 0; i--) ['pop', i % 2],
        ],
        [for (final _ in values) true, ...values.reversed],
        [-1, values.length],
      ),
    ],
  );
}

CodeQuestion _palindrome() {
  final half = _randomValues(302, 128).map((x) => x + 128).toList();
  AlgorithmTestCase run(String name, String s, bool expected) =>
      _example(name, {'text': s}, expected);
  return _design(
    2,
    title: "用半栈判回文",
    topic: "half-stack-palindrome",
    prompt:
        r'''回文是指正读反读均相同的字符序列，如“abba”和“abdba”均是回文，但“good”不是回文。试写一个算法判定给定的字符序列是否为回文。（提示：将一半字符入栈）''',
    explanation:
        r'''前半段入栈，奇数长度越过中心字符，再逐个弹栈比较后半段。时间 O(n)，最多保存 ⌊n/2⌋ 个字符。C 入口接收字符码点和长度。''',
    template: r'''#include <stdint.h>
#include <stdlib.h>
int Palindrome(const uint32_t s[], size_t n) {
    size_t half = n / 2, top = 0;
    uint32_t *stack = half ? malloc(half * sizeof *stack) : NULL;
    if (half && !stack) return -1;
    for (size_t i = 0; i < half; ++i) stack[top++] = s[i];
    for (size_t i = /*BLANK_1*/; i < n; ++i) {
        if (/*BLANK_2*/) { free(stack); return 0; }
    }
    free(stack);
    return 1;
}''',
    answers: [r'''half + n % 2''', r'''stack[--top] != s[i]'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final s = (input['text'] as String).runes.toList(), half = s.length ~/ 2;
  final stack = s.take(half).toList();
  for (var i = half + s.length % 2; i < s.length; i++) {
    if (stack.removeLast() != s[i]) return false;
  }
  return true;
}''',
    cases: [
      run('教材偶数回文', 'abba', true),
      run('空串', '', true),
      run('单个码点', '🌲', true),
      run('教材奇数回文', 'abdba', true),
      run('教材反例', 'good', false),
      run('固定种子长回文', String.fromCharCodes([...half, ...half.reversed]), true),
    ],
  );
}

CodeQuestion _sentinelStack() {
  final values = _randomValues(303, 128).where((v) => v != -1).toList();
  AlgorithmTestCase run(
    String name,
    int cap,
    List<int> values,
    List<Object> output,
  ) => _example(name, {'capacity': cap, 'values': values}, output);
  return _design(
    3,
    title: "遇 −1 弹出并输出",
    topic: "stack-integer-stream",
    prompt:
        r'''设从键盘输入一整数的序列：a₁，a₂，a₃，…，aₙ，试编写算法实现：用栈结构存储输入的整数，当aᵢ≠−1时，将aᵢ进栈；当aᵢ=−1时，输出栈顶整数并出栈。算法应对异常情况（入栈满等）给出相应的信息。''',
    explanation:
        r'''逐项读取直到序列结束。遇 −1 且栈非空时输出弹出的整数。参考程序遇到满栈或空栈分别输出 FULL 或 EMPTY，并继续处理下一输入。''',
    template: r'''#include <stddef.h>
#include <stdio.h>
void Process(const int input[], size_t n, int stack[], size_t capacity, FILE *out) {
    size_t top = 0;
    for (size_t i = 0; i < n; ++i) {
        if (input[i] == -1) {
            if (top == 0) fputs("EMPTY\n", out);
            else fprintf(out, "%d\n", /*BLANK_1*/);
        } else if (/*BLANK_2*/) {
            fputs("FULL\n", out);
        } else {
            stack[top++] = input[i];
        }
    }
}''',
    answers: [r'''stack[--top]''', r'''top == capacity'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final stack = <int>[], output = <Object>[];
  for (final x in (input['values'] as List).cast<int>()) {
    if (x == -1) {
      output.add(stack.isEmpty ? 'EMPTY' : stack.removeLast());
    } else if (stack.length == input['capacity']) {
      output.add('FULL');
    } else {
      stack.add(x);
    }
  }
  return output;
}''',
    cases: [
      run('多次弹出后继续读入', 2, [4, 7, -1, -1, 9, -1], [7, 4, 9]),
      run('空输入', 0, [], []),
      run('空栈弹出', 1, [-1], ['EMPTY']),
      run('重复值并溢出', 2, [6, 6, 6, -1, -1], ['FULL', 6, 6]),
      run('零容量', 0, [5, -1], ['FULL', 'EMPTY']),
      run('固定种子批量进出', values.length, [
        ...values,
        for (final _ in values) -1,
      ], values.reversed.toList()),
    ],
  );
}

CodeQuestion _postfix() {
  final values = _randomValues(304, 128);
  AlgorithmTestCase run(String name, String expression, Object expected) =>
      _example(name, {'expression': expression}, expected);
  return _design(
    4,
    title: "后缀表达式求值",
    topic: "postfix-evaluation",
    prompt:
        r'''从键盘上输入一个后缀表达式，试编写算法计算表达式的值。规定：逆波兰表达式的长度不超过一行，以“$”作为输入结束，操作数之间用空格分隔，操作符只可能有+、−、*、/四种运算。例如：23434 + 2*$。''',
    explanation:
        r'''读到数就入栈。运算符先弹出右操作数 b，再取左操作数 a，计算 a op b。结束符到来时应恰剩一项。扫描页例串的数字 23434 之间没有可辨认的空格，照印刷串读取会在 + 处缺操作数。项目另给带明确分隔的可算示例。''',
    template: r'''#include <ctype.h>
#include <stdlib.h>
#include <string.h>
typedef enum { OK, OPERANDS, ZERO, TOKEN, END, RESULT, NOMEM } EvalStatus;
EvalStatus Evaluate(const char *line, double *value) {
    double *s = malloc((strlen(line) + 1) * sizeof *s);
    if (!s) return NOMEM;
    size_t top = 0;
    EvalStatus status = END;
    for (const char *p = line; *p; ) {
        if (isspace((unsigned char)*p)) { ++p; continue; }
        if (*p == '$') {
            status = top == 1 ? OK : RESULT;
            if (status == OK) *value = s[0];
            break;
        }
        int signedNumber = (*p == '-' || *p == '+') &&
            (p == line || isspace((unsigned char)p[-1])) &&
            (isdigit((unsigned char)p[1]) || p[1] == '.');
        if (isdigit((unsigned char)*p) || *p == '.' || signedNumber) {
            char *next;
            double x = strtod(p, &next);
            if (next == p) { status = TOKEN; break; }
            s[top++] = x; p = next; continue;
        }
        char op = *p++;
        if (!strchr("+-*/", op)) { status = TOKEN; break; }
        if (/*BLANK_1*/) { status = OPERANDS; break; }
        double b = s[--top], a = s[top - 1];
        if (op == '/' && b == 0) { status = ZERO; break; }
        switch (op) {
            case '+': s[top - 1] = a + b; break;
            case '-': s[top - 1] = /*BLANK_2*/; break;
            case '*': s[top - 1] = a * b; break;
            case '/': s[top - 1] = /*BLANK_3*/; break;
        }
    }
    free(s); return status;
}''',
    answers: [r'''top < 2''', r'''a - b''', r'''a / b'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  final text = input['expression'] as String, stack = <double>[];
  final number = RegExp(r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?');
  for (var i = 0; i < text.length;) {
    final c = text[i];
    if (c.trim().isEmpty) {
      i++;
      continue;
    }
    if (c == r'$') return stack.length == 1 ? stack.single : 'RESULT';
    final signed = (c == '+' || c == '-');
    if (!signed || i == 0 || text[i - 1].trim().isEmpty) {
      final match = number.matchAsPrefix(text, i);
      if (match != null) {
        stack.add(double.parse(match[0]!));
        i = match.end;
        continue;
      }
    }
    i++;
    if (!'+-*/'.contains(c)) return 'TOKEN';
    if (stack.length < 2) return 'OPERANDS';
    final b = stack.removeLast(), a = stack.removeLast();
    if (c == '/' && b == 0) return 'ZERO';
    stack.add(switch (c) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      _ => a / b,
    });
  }
  return 'END';
}''',
    cases: [
      run('明确分隔与相邻算符', r'23 434 + 2*$', 914.0),
      run('原页例串按字面读取', r'23434 + 2*$', 'OPERANDS'),
      run('单个负数', r'-7$', -7.0),
      run('除零', r'5 0/$', 'ZERO'),
      run('减法和除法次序', r'8 2/ 7-$', -3.0),
      run(
        '固定种子长表达式',
        values.map((n) => n.toString()).join(' ') +
            (' +' * (values.length - 1)) +
            r'$',
        values.fold<int>(0, (s, v) => s + v).toDouble(),
      ),
    ],
  );
}

CodeQuestion _ioSequence() {
  final long = _randomValues(305, 64).map((v) {
    final n = v.abs() + 1;
    return 'I' * n + 'O' * n;
  }).join();
  AlgorithmTestCase run(String name, String ops, bool valid) =>
      _example(name, {'ops': ops}, valid);
  return _design(
    5,
    title: "判断入栈与出栈序列",
    topic: "stack-operation-sequence",
    prompt:
        r'''假设以I和O分别表示入栈和出栈操作。栈的初态和终态均为空，入栈和出栈的操作序列可表示为仅由I和O组成的序列，称可以操作的序列为合法序列，否则称为非法序列。
① 下面所示的序列中哪些是合法的？
A. IOIIOIOO　B. IOOIOIIO　C. IIIOIOIO　D. IIIOOIOO
② 通过对①的分析，写出一个算法，判定所给的操作序列是否合法。若合法，返回true，否则返回false（假定被判定的操作序列已存入一维数组中）。''',
    explanation:
        r'''A、D 合法。B 的第三步试图从空栈弹出；C 结束时栈中还剩两个元素。用计数器跟踪栈深，每个前缀深度须非负，最终深度须为零。''',
    template: r'''#include <stdbool.h>
#include <stddef.h>
bool Legal(const char ops[], size_t n) {
    size_t depth = 0;
    for (size_t i = 0; i < n; ++i) {
        if (ops[i] == 'I') ++depth;
        else if (ops[i] == 'O' && /*BLANK_1*/) --depth;
        else return false;
    }
    return /*BLANK_2*/;
}''',
    answers: [r'''depth > 0''', r'''depth == 0'''],
    dart: r'''Object solve(Map<String, dynamic> input) {
  var depth = 0;
  for (final c in (input['ops'] as String).split('')) {
    if (c == 'I') {
      depth++;
    } else if (c == 'O' && depth > 0) {
      depth--;
    } else {
      return false;
    }
  }
  return depth == 0;
}''',
    cases: [
      run('教材 A', 'IOIIOIOO', true),
      run('教材 B', 'IOOIOIIO', false),
      run('教材 C', 'IIIOIOIO', false),
      run('教材 D', 'IIIOOIOO', true),
      run('空序列', '', true),
      run('固定种子嵌套序列', long, true),
    ],
  );
}
