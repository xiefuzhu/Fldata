import 'dart:math' as math;
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

part 'match_extensions.dart';

enum MatchMode { compare, prefix, rotations }

class MatchInput {
  const MatchInput({
    this.text = 'ababcabcacbab',
    this.pattern = 'abcac',
    this.optimized = false,
    this.mode = MatchMode.compare,
  });
  final String text, pattern;
  final bool optimized;
  final MatchMode mode;
}

// Store the length in slot zero, matching the textbook's SString convention.
class SString {
  SString(String value) : slots = [value.length, ...value.codeUnits];
  final List<int> slots;
  int get length => slots[0];
  int operator [](int index) => slots[index];
}

List<int> failureLinks(SString pattern, {required bool optimized}) {
  return _buildLinks(pattern, optimized, null);
}

enum _LinkEvent { start, compare, advance, store, inherit, retreat, finish }

typedef _ObserveLink =
    void Function(
      int j,
      int k,
      List<int> links,
      _LinkEvent event,
      int previousK,
    );
List<int> _buildLinks(SString pattern, bool optimized, _ObserveLink? observe) {
  final links = List.filled(pattern.length + 1, 0);
  var j = 1, k = 0;
  observe?.call(j, k, links, _LinkEvent.start, 0);
  while (j < pattern.length) {
    observe?.call(j, k, links, _LinkEvent.compare, k);
    if (k == 0 || pattern[j] == pattern[k]) {
      j++;
      k++;
      observe?.call(j, k, links, _LinkEvent.advance, k);
      final inherit = optimized && pattern[j] == pattern[k];
      links[j] = inherit ? links[k] : k;
      observe?.call(
        j,
        k,
        links,
        inherit ? _LinkEvent.inherit : _LinkEvent.store,
        k,
      );
    } else {
      final old = k;
      k = links[k];
      observe?.call(j, k, links, _LinkEvent.retreat, old);
    }
  }
  observe?.call(j, k, links, _LinkEvent.finish, k);
  return links;
}

class _Track {
  _Track(this.name);
  final String name;
  int i = 1, j = 1, comparisons = 0, line = 2;
  int? result, from;
  bool compared = false, fallback = false;
  String action = '准备匹配';
  void advance(SString s, SString t, List<int> links, {required bool kmp}) {
    compared = false;
    if (result != null) return;
    from = null;
    fallback = false;
    if (j > t.length || i > s.length) {
      result = j > t.length ? i - t.length : 0;
      line = 7;
      action = result == 0 ? '未匹配' : '匹配位置 $result';
    } else if (kmp && j == 0) {
      i++;
      j = 1;
      line = 4;
      action = 'j=0，跳过当前主串字符';
    } else {
      compared = true;
      comparisons++;
      if (s[i] == t[j]) {
        action = 'S[$i] = T[$j]，同时前进';
        i++;
        j++;
        line = 4;
      } else {
        final oldJ = j;
        fallback = true;
        from = i;
        line = 5;
        if (kmp) {
          j = links[j];
          action = '锁定 i=$i，j：$oldJ → $j';
        } else {
          i = i - j + 2;
          j = 1;
          action = 'i：$from → $i，j 回到 1';
        }
      }
    }
  }
}

class BfKmpModule implements AlgorithmModule<MatchInput> {
  const BfKmpModule();
  @override
  String get id => 'ch4_bf_kmp_lab';
  @override
  List<AlgorithmPreset<MatchInput>> get presets => const [
    AlgorithmPreset(
      id: 'prefix-standard',
      name: '递推 · abaabcac',
      input: MatchInput(mode: MatchMode.prefix, pattern: 'abaabcac'),
    ),
    AlgorithmPreset(
      id: 'prefix-skip',
      name: '连续跳过 · aaaab',
      input: MatchInput(
        mode: MatchMode.prefix,
        pattern: 'aaaab',
        optimized: true,
      ),
    ),
    AlgorithmPreset(
      id: 'rotations',
      name: '环串 · baa',
      input: MatchInput(
        mode: MatchMode.rotations,
        text: 'ccaabcc',
        pattern: 'baa',
      ),
    ),
    AlgorithmPreset(id: 'example', name: '教材示例', input: MatchInput()),
    AlgorithmPreset(
      id: 'repeat',
      name: '重复前缀',
      input: MatchInput(text: 'aaaaaaaaab', pattern: 'aaaab'),
    ),
    AlgorithmPreset(
      id: 'miss',
      name: '匹配失败',
      input: MatchInput(text: 'ababab', pattern: 'abac'),
    ),
  ];
  @override
  ValidationResult<MatchInput> validateInput(String raw) {
    final parts = raw.split('|');
    if (parts.length != 2 ||
        !RegExp(r'^[a-zA-Z0-9]{0,24}$').hasMatch(parts[0]) ||
        !RegExp(r'^[a-zA-Z0-9]{0,12}$').hasMatch(parts[1])) {
      return const ValidationResult.failure('请输入英文字母或数字，主串最多 24 位，模式串最多 12 位。');
    }
    return ValidationResult.success(
      MatchInput(text: parts[0], pattern: parts[1]),
    );
  }

  @override
  TraceTimeline generateTrace(MatchInput input) {
    if (!validateInput('${input.text}|${input.pattern}').isValid) {
      throw ArgumentError('Invalid strings');
    }
    if (input.mode == MatchMode.prefix) return _prefixTrace(input);
    if (input.mode == MatchMode.rotations) return _rotationTrace(input);
    final s = SString(input.text), t = SString(input.pattern);
    final links = failureLinks(t, optimized: input.optimized);
    final linkName = input.optimized ? 'nextval' : 'next';
    List<String> source(CodeLang lang, bool kmp) {
      final name = kmp ? 'Index_KMP' : 'Index_BF';
      final dart = lang == CodeLang.dart;
      final pseudo = lang == CodeLang.cLike;
      final len = dart ? 'length' : 'ch[0]';
      final fallback = kmp ? 'j = $linkName[j];' : 'i = i - j + 2; j = 1;';
      final match = kmp ? 'j == 0 || ' : '';
      if (pseudo) {
        return [
          '过程 $name(S,T${kmp ? ', $linkName' : ''})',
          '  i ← 1, j ← 1',
          '  当 i ≤ |S| 且 j ≤ |T| 重复',
          '    若 ${kmp ? 'j = 0 或 ' : ''}S[i] = T[j] 则 i++, j++',
          '    否则 $fallback',
          '  循环结束',
          '  返回 j > |T| ? i − |T| : 0',
          '结束',
        ];
      }
      return [
        dart
            ? 'int $name(SString S, SString T${kmp ? ', List<int> $linkName' : ''}) {'
            : 'int $name(SString S, SString T${kmp ? ', const int $linkName[]' : ''}) {',
        '  int i = 1, j = 1;',
        '  while (i <= S.$len && j <= T.$len) {',
        '    if ($match${dart ? 'S[i] == T[j]' : 'S.ch[i] == T.ch[j]'}) { i++; j++; }',
        '    else { $fallback }',
        '  }',
        '  return j > T.$len ? i - T.$len : 0;',
        '}',
      ];
    }

    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: 'S=${input.text}，T=${input.pattern}',
      codeLines: {
        for (final lang in CodeLang.values)
          lang: [...source(lang, false), '', ...source(lang, true)],
      },
    );
    final bf = _Track('BF'), kmp = _Track('KMP');
    void record({bool initial = false}) {
      final nodes = <SceneNode>[],
          edges = <SceneEdge>[],
          pointers = <PointerBadge>[];
      for (final track in [bf, kmp]) {
        final base = track == bf ? 80.0 : 305.0;
        final offset = track.i - track.j;
        nodes.add(
          SceneNode(
            id: track.name,
            label: track.name,
            x: 12,
            y: base - 56,
            width: 80,
            height: 38,
          ),
        );
        for (final pattern in [false, true]) {
          final str = pattern ? t : s, row = pattern ? 'T' : 'S';
          for (var col = 0; col <= str.length; col++) {
            final slot = '${track.name}-$row-$col';
            nodes.add(
              SceneNode(
                id: slot,
                label: col == 0
                    ? 'len=${str.length}'
                    : String.fromCharCode(str[col]),
                x: 18 + 60.0 * (col + (pattern ? offset : 0)),
                y: base + (pattern ? 82 : 0),
                width: 58,
                height: 40,
                indexBadge: '[$col]',
                isZeroSentinelSlot: col == 0,
                visualState: col == 0
                    ? NodeVisualState.sentinel
                    : pattern && col < track.j
                    ? NodeVisualState.sorted
                    : col == (pattern ? track.j : track.i)
                    ? NodeVisualState.comparing
                    : NodeVisualState.normal,
              ),
            );
            if (col == (pattern ? track.j : track.i)) {
              pointers.add(
                PointerBadge(
                  id: '$slot-cursor',
                  label: pattern ? 'j' : 'i',
                  targetNodeId: slot,
                ),
              );
            }
          }
        }
        if (track == bf &&
            track.fallback &&
            track.from != track.i &&
            track.i <= s.length) {
          edges.add(
            SceneEdge(
              id: 'bf-shift',
              fromNodeId: 'BF-S-${track.from}',
              toNodeId: 'BF-S-${track.i}',
              curvature: -48,
              visualState: NodeVisualState.error,
            ),
          );
        }
      }
      final lines = [bf.line, 9 + kmp.line];
      builder.step(
        title: initial ? '比较从第 1 位开始' : 'BF：${bf.action}　KMP：${kmp.action}',
        explain:
            'BF 已比较 ${bf.comparisons} 次，KMP 已比较 ${kmp.comparisons} 次。返回位置从 1 开始，0 表示未找到。',
        cLikeLines: lines,
        c99Lines: lines,
        dartLines: lines,
        vars: {
          for (final a in [bf, kmp]) ...{
            '${a.name}.i': '${a.i}',
            '${a.name}.j': '${a.j}',
            '${a.name}.result': '${a.result ?? "—"}',
          },
        },
        deltaCompare: (bf.compared ? 1 : 0) + (kmp.compared ? 1 : 0),
        milestone:
            initial ||
            bf.fallback ||
            kmp.fallback ||
            (bf.result != null && kmp.result != null),
        scene: SceneSnapshot(
          nodes: nodes,
          edges: edges,
          pointers: pointers,
          auxTables: [
            AuxTableSnapshot(
              id: 'links',
              title: linkName,
              columns: ['j', 'T[j]', linkName],
              rows: [
                for (var j = 1; j <= t.length; j++)
                  ['$j', String.fromCharCode(t[j]), '${links[j]}'],
              ],
            ),
            AuxTableSnapshot(
              id: 'tracks',
              title: '双轨状态',
              columns: ['轨道', 'i', 'j', '字符比较', '动作'],
              rows: [
                for (final a in [bf, kmp])
                  [a.name, '${a.i}', '${a.j}', '${a.comparisons}', a.action],
              ],
            ),
          ],
        ),
      );
    }

    record(initial: true);
    while (bf.result == null || kmp.result == null) {
      bf.advance(s, t, links, kmp: false);
      kmp.advance(s, t, links, kmp: true);
      record();
    }
    return builder.build();
  }

  static double canvasWidth(MatchInput input) =>
      60.0 *
      (math.max(input.text.length, input.pattern.length) +
          input.pattern.length +
          3);
}
