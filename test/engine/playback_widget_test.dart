import 'package:flutter/material.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/ui/managers/playback_actions.dart';
import 'package:fldata/views/lab/trace_preview.dart';

void main() {
  Future<ProviderContainer> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Shortcuts(
              shortcuts: playbackShortcuts,
              child: const TracePreview(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'real keyboard, code breakpoint, language switch and seek share state',
    (tester) async {
      final container = await mount(tester);
      PlaybackState state() => container.read(playbackProvider);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(state().position, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(state().position, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(state().position, 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('breakpoint-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('code-language')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dart').last);
      await tester.pumpAndSettle();
      expect(state().language, CodeLang.dart);
      expect(state().position, 0);
      await tester.tap(find.byKey(const ValueKey('play-toggle')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(state().position, 2);
      expect(state().pauseReason, PauseReason.breakpoint);
      expect(find.textContaining('命中断点'), findsOneWidget);
      final slider = find.byKey(const ValueKey('trace-seek'));
      await tester.drag(slider, const Offset(250, 0));
      await tester.pump();
      expect(state().position, greaterThan(2));
      expect(state().isPlaying, isFalse);
      await tester.tap(find.byTooltip('复位 · Home'));
      await tester.pumpAndSettle();
      expect(state().position, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'inactive app time does not advance playback and disposal stops ticker',
    (tester) async {
      final container = await mount(tester);
      await tester.tap(find.byKey(const ValueKey('play-toggle')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      final before = container.read(playbackProvider).position;
      expect(before, greaterThan(0));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 5));
      expect(container.read(playbackProvider).position, before);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        container.read(playbackProvider).position,
        closeTo(before + .5, .00001),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  for (final size in [const Size(390, 844), const Size(1360, 900)]) {
    testWidgets('layout presets render and seek at $size', (tester) async {
      final container = await mount(tester);
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      for (final name in [
        '线性槽位',
        '[0] 哨兵槽',
        '共享双栈',
        '环队列跨零点',
        '环队列留空判满',
        '双元素交换',
        '长距插入移位',
      ]) {
        await tester.ensureVisible(find.byKey(const ValueKey('demo-input')));
        await tester.tap(find.byKey(const ValueKey('demo-input')));
        await tester.pumpAndSettle();
        final option = find.text(name).last;
        await tester.ensureVisible(option);
        await tester.pumpAndSettle();
        await tester.tap(option);
        await tester.pumpAndSettle();
        final timeline = container.read(playbackProvider).timeline!;
        expect(timeline.moduleId, 'engine.layout-preview');
        expect(timeline.inputSummary, name);
        expect(tester.takeException(), isNull, reason: name);
        final vm = container.read(playbackProvider.notifier);
        if (timeline.frames.length > 1) {
          vm.seek(.5);
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$name midpoint');
          vm.last();
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$name endpoint');
          vm.first();
          await tester.pump();
        }
        if (name == '[0] 哨兵槽') {
          expect(
            find.descendant(
              of: find.byType(DsStageCanvas),
              matching: find.text('哨兵 / 暂存'),
            ),
            findsOneWidget,
          );
        }
        if (name == '环队列跨零点') {
          expect(
            find.descendant(
              of: find.byType(DsStageCanvas),
              matching: find.text('rear'),
            ),
            findsOneWidget,
          );
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
