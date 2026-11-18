import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/dart.dart';
import '../../enum/ds_enums.dart';

/// At most one source/theme entry per language, owned by one debugger pane.
/// Parse the full source before splitting so multiline comments/strings keep
/// their syntax state. Playback position and variables are not cache keys.
class CodeHighlightCache {
  final Highlight _highlight = Highlight()
    ..registerLanguage('c', langC)
    ..registerLanguage('dart', langDart);
  final _entries =
      <
        CodeLang,
        ({List<String> source, ColorScheme colors, List<TextSpan> spans})
      >{};
  @visibleForTesting
  int compilationCount = 0;
  List<TextSpan> lines(
    CodeLang language,
    List<String> source,
    ColorScheme colors,
  ) {
    final entry = _entries[language];
    if (entry != null &&
        entry.colors == colors &&
        listEquals(entry.source, source)) {
      return entry.spans;
    }
    const font = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 13,
      height: 1.5,
    );
    final base = font.copyWith(color: colors.onSurface);
    final renderer = TextSpanRenderer(base, {
      'keyword': TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
      'type': TextStyle(color: colors.primary),
      'built_in': TextStyle(color: colors.secondary),
      'title': TextStyle(color: colors.secondary),
      'title.function': TextStyle(color: colors.secondary),
      'string': TextStyle(color: colors.tertiary),
      'number': TextStyle(color: colors.tertiary),
      'literal': TextStyle(color: colors.tertiary),
      'comment': TextStyle(
        color: colors.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      'meta': TextStyle(color: colors.secondary),
    });
    final text = source.join('\n');
    _highlight
        .highlight(
          code: text,
          language: language == CodeLang.dart ? 'dart' : 'c',
        )
        .render(renderer);
    compilationCount++;
    final rows = <List<TextSpan>>[[]];
    void visit(TextSpan span, TextStyle inherited) {
      final style = inherited.merge(span.style);
      final pieces = (span.text ?? '').split('\n');
      for (var i = 0; i < pieces.length; i++) {
        if (i > 0) rows.add([]);
        if (pieces[i].isNotEmpty) {
          rows.last.add(TextSpan(text: pieces[i], style: style));
        }
      }
      for (final child in span.children ?? const <InlineSpan>[]) {
        if (child is TextSpan) visit(child, style);
      }
    }

    visit(renderer.span ?? TextSpan(text: text), base);
    final spans = List<TextSpan>.unmodifiable(
      source.isEmpty
          ? const <TextSpan>[]
          : rows.map(
              (row) => TextSpan(
                style: base,
                children: List<InlineSpan>.unmodifiable(row),
              ),
            ),
    );
    _entries[language] = (
      source: List.unmodifiable(source),
      colors: colors,
      spans: spans,
    );
    return spans;
  }
}
