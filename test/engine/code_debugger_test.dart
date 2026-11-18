import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/debugger/code_highlight_cache.dart';
import 'package:fldata/engine/debugger/code_debugger_pane.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/ui/tokens/ds_semantic_colors.dart';

void main() {
  final colors = ColorScheme.fromSeed(seedColor: Colors.teal);
  test(
    'source-wide highlight preserves multiline comments, blank lines and exact text',
    () {
      final cache = CodeHighlightCache();
      const source = [
        '/* comment',
        '   still comment',
        '*/',
        '',
        'int answer = 42;',
        '',
      ];
      final spans = cache.lines(CodeLang.c99, source, colors);
      expect(spans.map((s) => s.toPlainText()), source);
      final comment = spans[1].children!.cast<TextSpan>();
      expect(
        comment.every((s) => s.style!.fontStyle == FontStyle.italic),
        isTrue,
      );
      expect(
        spans[4].children!
            .cast<TextSpan>()
            .map((s) => s.style!.color)
            .toSet()
            .length,
        greaterThan(1),
      );
      expect(cache.lines(CodeLang.c99, const [], colors), isEmpty);
    },
  );
  test(
    'cache reuses equal source across frames and invalidates source or theme only',
    () {
      final cache = CodeHighlightCache();
      final source = ['int value = 1;'];
      final first = cache.lines(CodeLang.cLike, source, colors);
      expect(
        identical(first, cache.lines(CodeLang.cLike, List.of(source), colors)),
        isTrue,
      );
      cache.lines(CodeLang.dart, ['var value = 1;'], colors);
      expect(
        identical(first, cache.lines(CodeLang.cLike, source, colors)),
        isTrue,
      );
      expect(cache.compilationCount, 2);
      source[0] = 'int value = 2;';
      expect(
        cache.lines(CodeLang.cLike, source, colors).single.toPlainText(),
        source.single,
      );
      expect(first.single.toPlainText(), 'int value = 1;');
      final dark = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );
      final themed = cache.lines(CodeLang.cLike, source, dark);
      expect(themed.single.style!.color, dark.onSurface);
      expect(cache.compilationCount, 4);
    },
  );
  TraceTimeline fixture() => const TraceTimeline(
    moduleId: 'debugger.fixture',
    inputSummary: 'debugger',
    codeLines: {
      CodeLang.cLike: ['mid = 5;', 'value = a[mid];', 'return OK;'],
      CodeLang.c99: ['int mid = 5;', 'int value = a[mid];', 'return 0;'],
      CodeLang.dart: [
        'final mid = 5;',
        'final value = values[mid];',
        'return;',
      ],
    },
    frames: [
      TraceFrame(
        stepIndex: 0,
        phaseTitle: 'read',
        explanation: 'read',
        activeLines: {
          CodeLang.cLike: [1, 2],
          CodeLang.c99: [2],
          CodeLang.dart: [2],
        },
        inlineVars: {'mid': '5', 'a[mid]': '56 > key(21)'},
        scene: SceneSnapshot(),
      ),
      TraceFrame(
        stepIndex: 1,
        phaseTitle: 'return',
        explanation: 'return',
        activeLines: {
          CodeLang.cLike: [3],
          CodeLang.c99: [3],
          CodeLang.dart: [3],
        },
        inlineVars: {'mid': '6'},
        scene: SceneSnapshot(),
      ),
    ],
  );
  Future<void> mount(
    WidgetTester tester,
    PlaybackState state, {
    double width = 600,
    TextScaler scale = TextScaler.noScaling,
    ValueChanged<CodeLang>? onLanguage,
    void Function(CodeLang, int)? onBreakpoint,
    bool reduced = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: colors,
          extensions: [DsSemanticColors.fromScheme(colors)],
        ),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: scale, disableAnimations: reduced),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 360,
                child: CodeDebuggerPane(
                  state: state,
                  onLanguageChanged: onLanguage ?? (_) {},
                  onToggleBreakpoint: onBreakpoint ?? (_, _) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'segments change language without changing frame and inline vars occur once',
    (tester) async {
      var state = PlaybackState(
        timeline: fixture(),
        frameIndex: 0,
        subProgress: .4,
      );
      await mount(
        tester,
        state,
        onLanguage: (lang) => state = state.copyWith(language: lang),
      );
      expect(find.byKey(const ValueKey('inline-var-mid')), findsOneWidget);
      final row = tester.getRect(find.byKey(const ValueKey('code-row-2')));
      expect(
        row.contains(
          tester.getCenter(find.byKey(const ValueKey('inline-var-mid'))),
        ),
        isTrue,
      );
      await tester.tap(find.text('Dart'));
      await mount(tester, state);
      expect(state.language, CodeLang.dart);
      expect(state.position, .4);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('code-text-2')))
            .textSpan!
            .toPlainText(),
        'final value = values[mid];',
      );
      expect(find.text('mid = 5'), findsOneWidget);
    },
  );
  testWidgets(
    '42dp gutter toggles language-specific breakpoint and preserves line number',
    (tester) async {
      CodeBreakpoint? toggled;
      var state = PlaybackState(timeline: fixture(), language: CodeLang.c99);
      await mount(
        tester,
        state,
        onBreakpoint: (lang, line) =>
            toggled = CodeBreakpoint(language: lang, line: line),
      );
      final target = find.byKey(const ValueKey('breakpoint-2'));
      expect(tester.getSize(target).width, 42);
      expect(tester.getSize(target).height, 48);
      await tester.tap(target);
      expect(toggled, const CodeBreakpoint(language: CodeLang.c99, line: 2));
      state = state.copyWith(breakpoints: {toggled!});
      await mount(tester, state);
      expect(
        find.descendant(of: target, matching: find.byIcon(Icons.circle)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: target, matching: find.text('2')),
        findsOneWidget,
      );
      await mount(tester, state.copyWith(language: CodeLang.dart));
      expect(
        find.descendant(of: target, matching: find.byIcon(Icons.circle)),
        findsNothing,
      );
    },
  );
  testWidgets(
    'frame updates reuse TextSpans while variables and glow follow rewind',
    (tester) async {
      final state = PlaybackState(timeline: fixture());
      await mount(tester, state);
      final span = tester
          .widget<Text>(find.byKey(const ValueKey('code-text-1')))
          .textSpan;
      await mount(tester, state.copyWith(frameIndex: 1));
      expect(
        identical(
          span,
          tester
              .widget<Text>(find.byKey(const ValueKey('code-text-1')))
              .textSpan,
        ),
        isTrue,
      );
      expect(find.text('mid = 6'), findsOneWidget);
      expect(find.text('mid = 5'), findsNothing);
      final active =
          tester
                  .widget<Container>(find.byKey(const ValueKey('code-row-3')))
                  .decoration
              as BoxDecoration;
      expect(
        active.color,
        DsSemanticColors.fromScheme(colors).codeActiveLineGlow,
      );
      await mount(tester, state);
      expect(find.text('mid = 5'), findsOneWidget);
      expect(find.text('mid = 6'), findsNothing);
    },
  );
  testWidgets(
    'breakpoint hit announces hidden-language line and clears on resume',
    (tester) async {
      final hit = PlaybackState(
        timeline: fixture(),
        pauseReason: PauseReason.breakpoint,
        hitBreakpoint: const CodeBreakpoint(language: CodeLang.c99, line: 2),
      );
      await mount(tester, hit, reduced: true);
      expect(find.text('● 命中第 2 行断点 · C99'), findsOneWidget);
      await mount(
        tester,
        hit.copyWith(
          pauseReason: PauseReason.none,
          hitBreakpoint: null,
          isPlaying: true,
        ),
      );
      expect(find.byKey(const ValueKey('breakpoint-hit')), findsNothing);
    },
  );
  testWidgets(
    'narrow large text wraps code and pills without overflow; empty code has no gutter',
    (tester) async {
      await mount(
        tester,
        PlaybackState(timeline: fixture()),
        width: 280,
        scale: const TextScaler.linear(1.7),
      );
      expect(tester.takeException(), isNull);
      final code = tester.getRect(find.byKey(const ValueKey('code-text-2')));
      final pill = tester.getRect(find.byKey(const ValueKey('inline-var-mid')));
      expect(pill.top, greaterThanOrEqualTo(code.bottom));
      await mount(tester, const PlaybackState(), width: 280);
      expect(find.text('暂无代码'), findsOneWidget);
      expect(find.byKey(const ValueKey('breakpoint-1')), findsNothing);
    },
  );
}
