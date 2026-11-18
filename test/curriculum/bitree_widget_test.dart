import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1360.0]) {
    testWidgets('Huffman codec and expression tree at $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 860),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch5_huffman_expr',
      );
      final vm = container.read(playbackProvider.notifier);
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      vm.last();
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('huffman-plain'));
      await tester.ensureVisible(field);
      await tester.enterText(field, '?');
      await tester.pump();
      expect(find.textContaining('不在当前编码表中'), findsOneWidget);
      await tester.enterText(field, 'bf');
      await tester.pump();
      expect(find.text('比特流　1000'), findsOneWidget);
      expect(find.textContaining('占定长 66.7%'), findsOneWidget);
      await tap(find.text('逐位走树译码'));
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['输出'],
        'bf',
      );
      expect(
        (await (db.select(db.achievementsTable)
                  ..where((r) => r.achievementId.equals('huffman_compressor')))
                .getSingle())
            .unlockedAt,
        isNotNull,
      );
      await tap(find.byKey(const ValueKey('application-mode')));
      await tap(find.text('表达式树').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('结果　15'), findsOneWidget);
      await tap(find.text('编辑表达式'));
      await tester.enterText(
        find.byKey(const ValueKey('application-input')),
        '8/(3-3)#',
      );
      await tap(find.text('应用'));
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.isErrorState,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  for (final width in [320.0, 1360.0]) {
    testWidgets('forest storage and reversible playback at $width', (
      tester,
    ) async {
      final (container, db) = await mount(
        tester,
        Size(width, 860),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch5_tree_forest_conv',
      );
      final vm = container.read(playbackProvider.notifier);
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tap(find.text('转为二叉树'));
      expect(container.read(playbackProvider).frameIndex, 3);
      await tap(find.byKey(const ValueKey('forest-storage')));
      await tap(find.text('孩子兄弟表示法').last);
      expect(find.text('nextsibling'), findsWidgets);
      await tap(find.text('还原为森林'));
      expect(container.read(playbackProvider).position, 0);
      expect(
        (await (db.select(db.achievementsTable)
                  ..where((r) => r.achievementId.equals('euler_walker')))
                .getSingle())
            .evidenceMask,
        24,
      );
      await tap(find.text('编辑二叉树'));
      await tester.enterText(
        find.byKey(const ValueKey('forest-sequence')),
        'AB#C##D##',
      );
      await tap(find.text('应用'));
      expect(
        container.read(playbackProvider).timeline!.inputSummary,
        'A(B,C),D',
      );
      expect(container.read(playbackProvider).frameIndex, 3);
      await tap(find.text('编辑森林'));
      await tester.enterText(
        find.byKey(const ValueKey('forest-sequence')),
        '#',
      );
      await tap(find.text('应用'));
      vm.last();
      await tester.pumpAndSettle();
      expect(find.text('空森林 ∅'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
  for (final width in [320.0, 1360.0]) {
    testWidgets(
      'threaded tree course, field boxes and zero-stack replay at $width',
      (tester) async {
        final (container, db) = await mount(
          tester,
          Size(width, 860),
          textScale: width == 320 ? 1.7 : 1,
          courseId: 'ch5_threaded_tree',
        );
        final vm = container.read(playbackProvider.notifier);
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        vm.last();
        await tester.pumpAndSettle();
        expect(find.text('LTag'), findsWidgets);
        expect(find.text('RTag'), findsWidgets);
        await tap(find.byKey(const ValueKey('thread-mode')));
        await tap(find.text('无栈中序遍历').last);
        vm.last();
        await tester.pumpAndSettle();
        expect(find.text('中序输出　CBEGDFA'), findsOneWidget);
        final trace = container.read(playbackProvider).timeline!;
        vm.seek(
          trace.frames.indexWhere((f) => f.phaseTitle == '沿右线索找后继').toDouble(),
        );
        await tester.pumpAndSettle();
        expect(
          container.read(playbackProvider).currentFrame!.metrics.callDepth,
          0,
        );
        await tap(find.text('编辑树'));
        await tester.enterText(
          find.byKey(const ValueKey('tree-sequence')),
          '#',
        );
        await tap(find.text('应用'));
        vm.last();
        await tester.pumpAndSettle();
        expect(find.text('中序输出　∅'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await leave(tester, container, db);
      },
    );
  }
  for (final size in [
    const Size(320, 720),
    const Size(990, 760),
    const Size(1360, 860),
  ]) {
    testWidgets('tree catalog, mode switch and input at $size', (tester) async {
      final (container, db) = await mount(
        tester,
        size,
        textScale: size.width == 320 ? 1.7 : 1,
      );
      final vm = container.read(playbackProvider.notifier);
      Future<void> tapVisible(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      vm.seek(5);
      await tester.pumpAndSettle();
      for (final label in ['中序', '中序 · 指针栈']) {
        await tapVisible(find.byKey(const ValueKey('tree-mode')));
        await tapVisible(find.text(label).last);
        expect(
          container.read(playbackProvider).frameIndex,
          label == '中序' ? 5 : 0,
        );
      }
      await tapVisible(find.text('编辑树'));
      await tester.enterText(find.byKey(const ValueKey('tree-sequence')), 'A#');
      await tapVisible(find.text('应用'));
      expect(find.textContaining('缺少节点'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('tree-sequence')),
        'A#B##',
      );
      await tapVisible(find.text('应用'));
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['输出'],
        'AB',
      );
      for (final (label, outer) in [
        ('先序 + 中序', 'ABDGCEF'),
        ('后序 + 中序', 'GDBEFCA'),
      ]) {
        await tapVisible(find.byKey(const ValueKey('tree-mode')));
        await tapVisible(find.text(label).last);
        await tapVisible(find.text('编辑树'));
        final first = find.byKey(const ValueKey('tree-sequence'));
        final middle = find.byKey(const ValueKey('tree-inorder'));
        await tester.enterText(first, outer);
        await tester.enterText(middle, 'X');
        await tapVisible(find.text('应用'));
        expect(find.text('两个序列的结点数不同。'), findsOneWidget);
        await tester.enterText(middle, 'DGBAECF');
        await tapVisible(find.text('应用'));
        final frames = container.read(playbackProvider).timeline!.frames;
        final split = frames.indexWhere((f) => f.phaseTitle == '定位中序分割点 A');
        expect(split, greaterThan(0));
        vm.seek(split.toDouble());
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('tree-partition')), findsOneWidget);
        vm.last();
        await tester.pumpAndSettle();
        expect(
          container.read(playbackProvider).currentFrame!.scene.nodes.length,
          7,
        );
      }
      await tapVisible(find.byKey(const ValueKey('tree-mode')));
      await tapVisible(find.text('先序').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['输出'],
        'ABDGCEF',
      );
      if (size.width == 1360) {
        for (final label in ['先序', '中序', '后序']) {
          await tapVisible(find.byKey(const ValueKey('tree-mode')));
          await tapVisible(find.text(label).last);
          final frames = container.read(playbackProvider).timeline!.frames;
          for (var i = 0; i < frames.length; i++) {
            vm.seek(i.toDouble());
          }
          await tester.pumpAndSettle();
        }
        expect(
          (await (db.select(db.achievementsTable)
                    ..where((r) => r.achievementId.equals('euler_walker')))
                  .getSingle())
              .evidenceMask,
          7,
        );
      }
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
