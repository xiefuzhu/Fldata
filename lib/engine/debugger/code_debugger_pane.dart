import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../enum/ds_enums.dart';
import '../../models/playback_model.dart';
import '../../ui/tokens/ds_semantic_colors.dart';
import 'code_highlight_cache.dart';

class CodeDebuggerPane extends StatefulWidget {
  const CodeDebuggerPane({
    super.key,
    required this.state,
    required this.onLanguageChanged,
    required this.onToggleBreakpoint,
    this.lineCounts = const {},
  });
  final PlaybackState state;
  final Map<int, int> lineCounts;
  final ValueChanged<CodeLang> onLanguageChanged;
  final void Function(CodeLang, int) onToggleBreakpoint;
  @override
  State<CodeDebuggerPane> createState() => _CodeDebuggerPaneState();
}

class _CodeDebuggerPaneState extends State<CodeDebuggerPane> {
  final cache = CodeHighlightCache();
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<DsSemanticColors>() ??
        DsSemanticColors.fromScheme(colors);
    final maxCount = widget.lineCounts.values.fold<int>(1, math.max);
    final source =
        state.timeline?.codeLines[state.language] ?? const <String>[];
    final spans = cache.lines(state.language, source, colors);
    final active =
        (state.currentFrame?.activeLines[state.language] ?? const <int>[])
            .where((line) => line >= 1 && line <= source.length)
            .toSet();
    // inlineVars is a frame snapshot, not per-line provenance. Show it once after
    // the last active line, rather than imply a variable belongs to every line.
    final variableLine = active.isEmpty ? null : active.reduce(math.max);
    final vars = state.currentFrame?.inlineVars ?? const <String, String>{};
    final hit = state.pauseReason == PauseReason.breakpoint
        ? state.hitBreakpoint
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SegmentedButton<CodeLang>(
            key: const ValueKey('code-language'),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            segments: [
              ButtonSegment(
                value: CodeLang.cLike,
                label: const Text('类 C'),
                tooltip: '类 C / 伪代码',
              ),
              const ButtonSegment(value: CodeLang.c99, label: Text('C99')),
              const ButtonSegment(value: CodeLang.dart, label: Text('Dart')),
            ],
            selected: {state.language},
            onSelectionChanged: (selection) =>
                widget.onLanguageChanged(selection.single),
          ),
        ),
        if (hit != null)
          TweenAnimationBuilder<double>(
            key: ValueKey(
              'hit-${hit.language.name}-${hit.line}-${state.frameIndex}',
            ),
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 600),
            builder: (context, value, _) => Semantics(
              liveRegion: true,
              child: Container(
                key: const ValueKey('breakpoint-hit'),
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withValues(
                    alpha: .35 + .65 * math.cos(math.pi * value).abs(),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '● 命中第 ${hit.line} 行断点${hit.language == state.language ? '' : ' · ${_languageName(hit.language)}'}',
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: source.isEmpty
              ? const Center(child: Text('暂无代码'))
              : ListView.builder(
                  key: ValueKey('code-lines-${state.language.name}'),
                  itemCount: source.length,
                  itemBuilder: (context, index) {
                    final line = index + 1;
                    final isActive = active.contains(line);
                    final point = CodeBreakpoint(
                      language: state.language,
                      line: line,
                    );
                    final breakpoint = state.breakpoints.contains(point);
                    return Container(
                      key: ValueKey('code-row-$line'),
                      decoration: BoxDecoration(
                        color: isActive
                            ? semantic.codeActiveLineGlow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 42,
                            child: Semantics(
                              button: true,
                              toggled: breakpoint,
                              label: '${breakpoint ? '移除' : '设置'}第 $line 行断点',
                              child: Tooltip(
                                message:
                                    '${breakpoint ? '移除' : '设置'}第 $line 行断点',
                                child: InkWell(
                                  key: ValueKey('breakpoint-$line'),
                                  onTap: () => widget.onToggleBreakpoint(
                                    state.language,
                                    line,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          child: breakpoint
                                              ? Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: colors.error,
                                                )
                                              : null,
                                        ),
                                        Text(
                                          line.toString(),
                                          style: TextStyle(
                                            fontFamily: 'JetBrainsMono',
                                            fontSize: 11,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) => Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth,
                                      ),
                                      child: Text.rich(
                                        spans[index],
                                        key: ValueKey('code-text-$line'),
                                        softWrap: true,
                                      ),
                                    ),
                                    if (line == variableLine)
                                      for (final entry in vars.entries)
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: constraints.maxWidth,
                                          ),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: colors.secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                              child: Text(
                                                '${entry.key} = ${entry.value}',
                                                key: ValueKey(
                                                  'inline-var-${entry.key}',
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'JetBrainsMono',
                                                  fontSize: 11,
                                                  color: colors
                                                      .onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (widget.lineCounts.containsKey(line))
                            SizedBox(
                              width: 72,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 12, 8, 4),
                                child: Column(
                                  children: [
                                    Text(
                                      '${widget.lineCounts[line]} 次',
                                      key: ValueKey('line-frequency-$line'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      key: ValueKey('line-heat-$line'),
                                      value:
                                          widget.lineCounts[line]! / maxCount,
                                      minHeight: 5,
                                      color: colors.tertiary,
                                      backgroundColor:
                                          colors.surfaceContainerHighest,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _languageName(CodeLang language) => switch (language) {
    CodeLang.cLike => '类 C',
    CodeLang.c99 => 'C99',
    CodeLang.dart => 'Dart',
  };
}
