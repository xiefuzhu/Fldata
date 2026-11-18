import '../../models/quiz_question.dart';

/// Compares C tokens while preserving literal contents and operator boundaries.
class CLikeTokenNormalizer {
  static final _token = RegExp(
    r'''(?:\s+|//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'|[A-Za-z_]\w*|0[xX][0-9a-fA-F]+[uUlL]*|(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?[uUlLfF]*|>>=|<<=|\.\.\.|->|\+\+|--|&&|\|\||[=!<>+\-*/%&|^]=|<<|>>|[^\s])''',
  );
  static final _identifier = RegExp(r'^[A-Za-z_]\w*$');

  static List<String> _tokens(String source) => [
    for (final m in _token.allMatches(source))
      if (m[0]!.trim().isNotEmpty &&
          !m[0]!.startsWith('//') &&
          !m[0]!.startsWith('/*'))
        m[0]!,
  ];

  static List<String> _ungroup(List<String> t) {
    while (t.length >= 3 && t.first == '(' && t.last == ')') {
      var depth = 0;
      var whole = true;
      for (var i = 0; i < t.length - 1; i++) {
        if (t[i] == '(') depth++;
        if (t[i] == ')') depth--;
        if (depth <= 0) {
          whole = false;
          break;
        }
      }
      if (!whole || depth != 1) break;
      t = t.sublist(1, t.length - 1);
    }
    return t;
  }

  // Restrict NULL rewrites to a variable or member chain used as a condition.
  static bool _member(List<String> t) {
    if (t.isEmpty || t.length.isEven) return false;
    for (var i = 0; i < t.length; i++) {
      if (i.isEven
          ? !_identifier.hasMatch(t[i])
          : !['.', '->'].contains(t[i])) {
        return false;
      }
    }
    return true;
  }

  static List<String> _condition(List<String> tokens) {
    final t = _ungroup(tokens);
    final ors = <int>[], ands = <int>[];
    var depth = 0;
    for (var i = 0; i < t.length; i++) {
      final op = t[i];
      if (['(', '[', '{'].contains(op)) depth++;
      if ([')', ']', '}'].contains(op)) depth--;
      if (depth != 0) continue;
      if ([
        '?',
        ',',
        '=',
        '+=',
        '-=',
        '*=',
        '/=',
        '%=',
        '<<=',
        '>>=',
        '&=',
        '|=',
        '^=',
      ].contains(op)) {
        return t;
      }
      if (op == '||') ors.add(i);
      if (op == '&&') ands.add(i);
    }
    final positions = ors.isEmpty ? ands : ors;
    if (positions.isNotEmpty) {
      final result = <String>['('];
      var start = 0;
      for (final pos in positions) {
        result.addAll(_condition(t.sublist(start, pos)));
        result.add(t[pos]);
        start = pos + 1;
      }
      return result
        ..addAll(_condition(t.sublist(start)))
        ..add(')');
    }
    if (t.length >= 3 && t.last == 'NULL') {
      final lhs = _ungroup(t.sublist(0, t.length - 2));
      if (_member(lhs)) {
        if (t[t.length - 2] == '!=') return lhs;
        if (t[t.length - 2] == '==') return ['!', ...lhs];
      }
    }
    if (t.isNotEmpty && t.first == '!') {
      final rhs = _ungroup(t.sublist(1));
      if (_member(rhs)) return ['!', ...rhs];
    }
    return t;
  }

  static bool equivalent(
    String input,
    String answer, {
    bool condition = false,
    bool statement = false,
  }) {
    List<String> canonical(String source) {
      final tokens = _tokens(source);
      if (statement) {
        final hasSemi = tokens.isNotEmpty && tokens.last == ';';
        final body = hasSemi ? tokens.sublist(0, tokens.length - 1) : tokens;
        final t = _ungroup(body);
        String? name;
        if (t.length == 2 && (t.first == '++' || t.last == '++')) {
          name = t.first == '++' ? t.last : t.first;
        } else if (t.length == 5 &&
            t[1] == '=' &&
            t[0] == t[2] &&
            t[3] == '+' &&
            t[4] == '1') {
          name = t[0];
        }
        if (name != null && _identifier.hasMatch(name)) {
          return [name, '++', if (hasSemi) ';'];
        }
      }
      if (tokens.any((t) => t == ';' || t == '{' || t == '}')) return tokens;
      return condition ? _condition(tokens) : _ungroup(tokens);
    }

    final left = canonical(input), right = canonical(answer);
    if (left.isEmpty || left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}

class AlgorithmCodeJudge {
  static List<bool> gradeBlanks(CodeQuestion question, List<String> answers) {
    return [
      for (final (i, blank) in question.blanks.indexed)
        i < answers.length && _matches(question.template, blank, answers[i]),
    ];
  }

  static bool _matches(String template, CodeBlank blank, String input) {
    final offset = template.indexOf(blank.marker);
    final before = CLikeTokenNormalizer._tokens(template.substring(0, offset));
    final after = CLikeTokenNormalizer._tokens(
      template.substring(offset + blank.marker.length),
    );
    final condition =
        before.length >= 2 &&
        ['if', 'while'].contains(before[before.length - 2]) &&
        before.last == '(' &&
        after.firstOrNull == ')';
    final statement =
        before.isNotEmpty &&
        [';', '{', '}'].contains(before.last) &&
        (after.firstOrNull == ';' ||
            blank.acceptedAnswers.every((a) => a.trimRight().endsWith(';')));
    return blank.acceptedAnswers.any(
      (answer) => CLikeTokenNormalizer.equivalent(
        input,
        answer,
        condition: condition,
        statement: statement,
      ),
    );
  }
}
