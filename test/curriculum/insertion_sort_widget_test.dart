import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('插入排序 · 哨兵移动、折半定位、希尔分组与稳定性回跳 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch8_insert_shell',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      SceneSnapshot scene() =>
          tester.widget<DsStageCanvas>(find.byType(DsStageCanvas)).scene;
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      final frames = container.read(playbackProvider).timeline!.frames;
      final save = frames
          .firstWhere((f) => f.inlineVars['阶段'] == '暂存')
          .stepIndex;
      vm.seek(save - .5);
      await tester.pumpAndSettle();
      final moving = scene().nodes.singleWhere((n) => n.id == 'record-copy');
      expect(moving.label, '38');
      expect(moving.y, isNot(scene().nodes.first.y));
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(scene().nodes.first.label, '38');
      expect(scene().nodes.first.isZeroSentinelSlot, true);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(scene().nodes.first.label, '∅');
      await tap(key('insertion-method'));
      await tap(find.text('折半插入').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('insertion-metrics')).data,
        contains('16　　RMN　29'),
      );
      expect(key('sort-stable'), findsOneWidget);
      await tap(key('insertion-presets'));
      await tap(find.text('图 8.2 · 希尔三趟分组').last);
      vm.stepInto();
      await tester.pumpAndSettle();
      expect(
        scene().edges.where((e) => e.style == EdgeStyle.shellArc),
        hasLength(5),
      );
      vm.last();
      await tester.pumpAndSettle();
      expect(key('sort-unstable'), findsOneWidget);
      final witness = int.parse(
        container.read(playbackProvider).currentFrame!.inlineVars['逆序帧']!,
      );
      await tap(key('sort-jump'));
      expect(container.read(playbackProvider).frameIndex, witness);
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['跨位'],
        contains('49*'),
      );
      await tap(key('insertion-edit'));
      await tester.enterText(key('insertion-keys'), '[9, 1, 9*, -2]');
      await tester.enterText(key('insertion-gaps'), '3 2');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.textContaining('最后一项须为 1'), findsOneWidget);
      await tester.enterText(key('insertion-gaps'), '2 1');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(scene().nodes.skip(1).map((n) => n.label), ['-2', '1', '9', '9*']);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
