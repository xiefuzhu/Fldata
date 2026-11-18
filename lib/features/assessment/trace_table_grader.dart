import '../../models/quiz_question.dart';
import '../../curriculum/achievement_practice.dart';

const kmpTableId = 'textbook_ch4_2_01';
const aoeTableId = 'textbook_ch6_2_05';
const dijkstraTableId = 'textbook_ch6_2_04';
const sortTableId = 'textbook_ch8_2_01';

class TraceTableGrade {
  const TraceTableGrade(
    this.cells,
    this.hits,
    this.total, {
    this.edgeSetCorrect,
  });

  /// Null denotes an inapplicable cell. Edges have per-edge feedback but
  /// contribute one collective point for the set.
  final List<List<bool?>> cells;
  final int hits, total;
  final bool? edgeSetCorrect;
  bool get complete => hits == total;
  int get score => complete ? 100 : (100 * hits / total).round().clamp(0, 99);
}

class TraceTableGrader {
  const TraceTableGrader();
  static bool hasEdgeSet(TraceTableQuestion q) =>
      q.id == aoeTableId || q.id == parallelAoeId;
  static bool isEdgeCell(TraceTableQuestion q, int row, int col) =>
      hasEdgeSet(q) &&
      col == q.columns.length - 1 &&
      q.rowLabels[row].startsWith('活动 ');
  static bool isFixed(TraceTableQuestion q, int row, int col) =>
      q.id == aoeTableId && q.answerRows[row][col] == '—';
  static String edgeId(TraceTableQuestion q, int row) =>
      q.rowLabels[row].substring('活动 '.length);

  TraceTableGrade grade(
    TraceTableQuestion q,
    List<List<String>> rows, {
    Set<String> edges = const {},
  }) {
    var hits = 0, total = 0;
    final expectedEdges = <String>{};
    final cells = <List<bool?>>[];
    for (final (r, expected) in q.answerRows.indexed) {
      final marks = <bool?>[];
      for (final (c, value) in expected.indexed) {
        if (isFixed(q, r, c)) {
          marks.add(null);
          continue;
        }
        if (isEdgeCell(q, r, c)) {
          final edge = edgeId(q, r);
          if (value == '是') expectedEdges.add(edge);
          marks.add(edges.contains(edge) == (value == '是'));
          continue;
        }
        final answer = r < rows.length && c < rows[r].length ? rows[r][c] : '';
        final ok = equivalent(value, answer);
        marks.add(ok);
        total++;
        if (ok) hits++;
      }
      cells.add(marks);
    }
    bool? edgeSetCorrect;
    if (hasEdgeSet(q)) {
      edgeSetCorrect =
          edges.length == expectedEdges.length &&
          edges.containsAll(expectedEdges);
      total++;
      if (edgeSetCorrect) hits++;
    }
    return TraceTableGrade(cells, hits, total, edgeSetCorrect: edgeSetCorrect);
  }

  String _normalize(String s) => s
      .trim()
      .replaceAll('（', '(')
      .replaceAll('）', ')')
      .replaceAll('，', ',')
      .replaceAll('：', ':')
      .replaceAll('；', ';')
      .replaceAll('＊', '*')
      .replaceAll('->', '→')
      .replaceAll('²', '^2')
      .replaceAll('−', '-')
      .replaceAll(
        RegExp(r'\b(?:infinity|inf)\b|无穷大', caseSensitive: false),
        '∞',
      )
      .replaceAllMapped(RegExp(r'\s*([→/,:;|()\[\]])\s*'), (m) => m[1]!)
      .replaceAll(RegExp(r'\s+'), ' ');

  bool equivalent(String expected, String actual) {
    final a = _normalize(expected), b = _normalize(actual);
    if (b.isEmpty) return false;
    if (a == b) return true;
    if (a == '—') return b == '-';
    if (a.startsWith('O(') && a.endsWith(')')) {
      String order(String v) => v
          .replaceAll(' ', '')
          .replaceAll('n*m', 'nm')
          .replaceAll('m*n', 'nm')
          .replaceAll('sqrt(n)', '√n')
          .replaceAll('log2', 'log');
      return order(a) == order(b);
    }
    // For a list of numeric records, commas and spaces separate the same slots.
    final list = RegExp(r'^(?:-?\d+\*?|∞|∅)(?:[ ,]+(?:-?\d+\*?|∞|∅))+$');
    if (list.hasMatch(a) && list.hasMatch(b)) {
      return a.split(RegExp('[ ,]+')).join(' ') ==
          b.split(RegExp('[ ,]+')).join(' ');
    }
    final rational = RegExp(r'^(-?\d+)/(\d+)$');
    final left = rational.firstMatch(a);
    if (left != null) {
      final right = rational.firstMatch(b);
      if (right != null) {
        final d = BigInt.parse(right[2]!);
        return d != BigInt.zero &&
            BigInt.parse(left[1]!) * d ==
                BigInt.parse(right[1]!) * BigInt.parse(left[2]!);
      }
      final decimal = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(b);
      if (decimal != null) {
        final fraction = decimal[3] ?? '';
        return BigInt.parse(left[1]!) * BigInt.from(10).pow(fraction.length) ==
            BigInt.parse('${decimal[1]}${decimal[2]}$fraction') *
                BigInt.parse(left[2]!);
      }
    }
    return false;
  }

  String feedback(TraceTableQuestion q, int row, int col) {
    final ref = q.answerRows[row][col];
    if (q.id == kmpTableId) {
      final j = row + 1, ch = q.rowLabels[row].split(' · ').last;
      if (j == 1) return 'j=1 是起点，next[1] 和 nextval[1] 都取 0。';
      final next = int.parse(q.answerRows[row][0]);
      if (col == 0) {
        return 'T[$j]=$ch。观察前 $row 个字符，最长相等真前后缀长 ${next - 1}，所以 next[$j]=$next。';
      }
      final fallback = q.rowLabels[next - 1].split(' · ').last;
      return 'T[$j]=$ch，next[$j]=$next。T[$next]=$fallback，${ch == fallback ? "两字符相同，沿用 nextval[$next]" : "两字符不同，保留回退位置 $next"}，因此 nextval[$j]=$ref。';
    }
    return '${q.rowLabels[row]} · ${q.columns[col]}，参考值为 $ref。';
  }
}
