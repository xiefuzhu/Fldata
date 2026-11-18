List<(String, int)> parseKeyOperations(String raw) {
  final result = <(String, int)>[];
  for (final token
      in raw.trim().split(RegExp(r'[\s,，]+')).where((s) => s.isNotEmpty)) {
    if (!['+', '-', '?'].contains(token[0]) ||
        int.tryParse(token.substring(1)) == null) {
      throw const FormatException('操作须使用 +键、-键 或 ?键，例如 +30 -12 ?47。');
    }
    result.add((token[0], int.parse(token.substring(1))));
  }
  return result;
}
