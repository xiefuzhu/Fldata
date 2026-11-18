import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('静态查找工作台 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch7_linear_bin_block',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String id) => find.byKey(ValueKey(id));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      DsStageCanvas tree() => tester.widget(find.byType(DsStageCanvas));
      await tap(key('static-search-presets'));
      await tap(find.text('例 7.1 · 折半查 65').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('search-result')).data, contains('0'));
      expect(
        tree().scene.nodes
            .singleWhere((n) => n.visualState == NodeVisualState.active)
            .id,
        'gap10',
      );
      expect(
        find.descendant(
          of: key('search-asl'),
          matching: find.textContaining('44/12'),
        ),
        findsOneWidget,
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(
        tree().scene.nodes
            .singleWhere((n) => n.visualState == NodeVisualState.active)
            .id,
        'mid10',
      );
      await tap(key('search-method'));
      await tap(find.text('监视哨').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: key('record-0'), matching: find.text('65')),
        findsOneWidget,
      );
      expect(find.text('比较关键字'), findsWidgets);
      await tap(key('search-method'));
      await tap(find.text('分块查找').last);
      await tap(key('block-index-method'));
      await tap(find.text('折半索引').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('search-result')).data, contains('10'));
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['块内比较'],
        '4',
      );
      await tap(key('search-edit'));
      await tester.enterText(key('search-records-input'), '3 1 | 4 -5');
      await tap(find.widgetWithText(FilledButton, '查找'));
      expect(find.textContaining('后一块的每个关键字'), findsOneWidget);
      await tester.enterText(key('search-records-input'), '3 1 | 6 4');
      await tester.enterText(key('search-key-input'), '4');
      await tap(find.widgetWithText(FilledButton, '查找'));
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['返回'],
        '4',
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
