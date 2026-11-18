/// The initial position follows a record through every assignment and breaks
/// ties only when diagnosing stability, never when comparing sort keys.
class SortRecord {
  const SortRecord(this.key, this.origin, this.occurrence);
  final int key, origin, occurrence;
  String get label => switch (occurrence) {
    1 => '$key',
    2 => '$key*',
    _ => '$key*$occurrence',
  };
  static List<SortRecord> tag(List<int> keys) {
    final seen = <int, int>{};
    return [
      for (var i = 0; i < keys.length; i++)
        SortRecord(
          keys[i],
          i + 1,
          seen.update(keys[i], (n) => n + 1, ifAbsent: () => 1),
        ),
    ];
  }
}

const sortExample81 = [49, 38, 65, 97, 76, 13, 27, 49];
const sortExample82 = [...sortExample81, 55, 4];

List<int> parseSortIntegers(String raw, {bool tagged = false}) {
  var text = raw.trim();
  if (text.startsWith('[') && text.endsWith(']')) {
    text = text.substring(1, text.length - 1).trim();
  }
  if (text.isEmpty) return [];
  return [
    for (final token in text.split(RegExp(r'[\s,，]+')))
      int.tryParse(
            tagged ? token.replaceFirst(RegExp(r'\*(?:\d+)?$'), '') : token,
          ) ??
          (throw FormatException('无法读取整数「$token」。')),
  ];
}

class SortCrossings {
  final _inversions = <(int, int), int>{};

  // The endpoints are the old and new physical (or pivot-hole) positions.
  // For a swap, count the pair at the endpoints once, on the first leg.
  String observe(
    List<SortRecord?> slots,
    SortRecord item,
    int from,
    int to,
    int frame, {
    bool includeDestination = false,
  }) {
    if (from == to) return '';
    final step = from < to ? 1 : -1, crossed = <String>[];
    final stop = includeDestination ? to + step : to;
    for (var i = from + step; i != stop; i += step) {
      final other = slots[i];
      if (other == null || other.key != item.key) continue;
      final pair = item.origin < other.origin
          ? (item.origin, other.origin)
          : (other.origin, item.origin);
      if ((item.origin > other.origin) == (to < from)) {
        _inversions[pair] = frame;
        crossed.add(other.label);
      } else {
        _inversions.remove(pair);
      }
    }
    return crossed.isEmpty
        ? ''
        : '${item.label} 从位序 $from 移到 $to，越过了同键记录 ${crossed.join("、")}。';
  }

  Map<String, String> result(List<int> input) {
    if (_inversions.isEmpty) return {};
    final first = _inversions.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );
    return {
      '逆序帧': '${first.value}',
      '逆序键': '${input[first.key.$1 - 1]}',
      '原位序': '${first.key.$1}、${first.key.$2}',
    };
  }
}
