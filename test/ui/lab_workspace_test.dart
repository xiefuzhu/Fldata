import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/engine/debugger/code_debugger_pane.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/views/lab/trace_preview.dart';

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const Scaffold(body: TracePreview()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return container;
  }

  testWidgets(
    'breakpoint reparenting preserves engine panes, language and playback state',
    (tester) async {
      final container = await mount(tester, const Size(1360, 900));
      final vm = container.read(playbackProvider.notifier);
      vm.seek(2);
      vm.setLanguage(CodeLang.dart);
      vm.toggleBreakpoint(CodeLang.cLike, 3);
      await tester.pumpAndSettle();
      final before = container.read(playbackProvider);
      final stageState = tester.state(find.byType(DsStageCanvas));
      final codeState = tester.state(find.byType(CodeDebuggerPane));
      for (final size in [
        const Size(800, 1000),
        const Size(390, 844),
        const Size(1100, 760),
        const Size(1099, 760),
        const Size(1360, 900),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(container.read(playbackProvider), before);
        expect(
          identical(tester.state(find.byType(DsStageCanvas)), stageState),
          isTrue,
        );
        expect(
          identical(
            tester.state(find.byType(CodeDebuggerPane, skipOffstage: false)),
            codeState,
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull, reason: size.toString());
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('desktop dividers resize both axes without resetting the trace', (
    tester,
  ) async {
    final container = await mount(tester, const Size(1360, 900));
    container.read(playbackProvider.notifier).seek(1.5);
    await tester.pumpAndSettle();
    final stage = find.byType(DsStageCanvas);
    final code = find.byType(CodeDebuggerPane);
    final width = tester.getSize(stage).width;
    final height = tester.getSize(code).height;
    final mouse = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('stage-divider'))),
      kind: PointerDeviceKind.mouse,
    );
    await mouse.moveBy(const Offset(100, 0));
    await mouse.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(stage).width, greaterThan(width + 60));
    final verticalMouse = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('code-divider'))),
      kind: PointerDeviceKind.mouse,
    );
    await verticalMouse.moveBy(const Offset(0, -60));
    await verticalMouse.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(code).height, lessThan(height - 30));
    expect(container.read(playbackProvider).position, 1.5);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'tablet stage has 55 percent of pane space and inspector tabs work',
    (tester) async {
      await mount(tester, const Size(800, 1000));
      final area = tester.getSize(
        find.byKey(const ValueKey('workspace-medium')),
      );
      expect(
        tester.getSize(find.byType(DsStageCanvas)).height + 16,
        closeTo((area.height - 12) * .55, .01),
      );
      await tester.tap(find.text('调用栈与内存表'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('内存与辅助表'));
      await tester.pumpAndSettle();
      expect(find.text('结点内存'), findsOneWidget);
      await tester.tap(find.text('原理与复杂度'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('trace-theory')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'phone handle snaps to middle and mini code opens full debugger',
    (tester) async {
      final container = await mount(tester, const Size(390, 844));
      final draggable = tester.widget<DraggableScrollableSheet>(
        find.byKey(const ValueKey('workspace-sheet')),
      );
      expect(draggable.controller!.size, closeTo(.12, .001));
      final height = tester
          .getSize(find.byKey(const ValueKey('workspace-compact')))
          .height;
      await tester.drag(
        find.byKey(const ValueKey('sheet-handle')),
        Offset(0, -height * .33),
      );
      await tester.pumpAndSettle();
      expect(draggable.controller!.size, closeTo(.45, .01));
      await tester.tap(find.byKey(const ValueKey('mini-code-open')));
      await tester.pumpAndSettle();
      expect(draggable.controller!.size, closeTo(.85, .001));
      await tester.tap(find.byKey(const ValueKey('breakpoint-3')));
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).breakpoints,
        contains(const CodeBreakpoint(language: CodeLang.cLike, line: 3)),
      );
      await tester.tap(find.byKey(const ValueKey('sheet-handle')));
      await tester.pumpAndSettle();
      expect(draggable.controller!.size, closeTo(.12, .001));
      expect(
        tester.getSize(find.byKey(const ValueKey('play-toggle'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'compact overflow menu changes real VM direction, speed and camera follow',
    (tester) async {
      final container = await mount(tester, const Size(390, 844));
      for (final label in ['倒放', '2.0×', '自动跟随镜头']) {
        await tester.tap(find.byKey(const ValueKey('transport-options')));
        await tester.pumpAndSettle();
        final item = find.ancestor(
          of: find.text(label).last,
          matching: find.byType(CheckedPopupMenuItem<String>),
        );
        await tester.ensureVisible(item);
        await tester.tap(item);
        await tester.pumpAndSettle();
      }
      expect(
        container.read(playbackProvider).direction,
        PlaybackDirection.reverse,
      );
      expect(container.read(playbackProvider).speed, 2);
      expect(
        tester.widget<DsStageCanvas>(find.byType(DsStageCanvas)).followCamera,
        isTrue,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'small phone and enlarged text can expand code without overflow',
    (tester) async {
      await mount(tester, const Size(320, 640), textScale: 1.7);
      await tester.tap(find.byKey(const ValueKey('mini-code-open')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('调用栈与内存表'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
