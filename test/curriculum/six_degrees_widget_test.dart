import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('六度空间 · 切源点、波纹回退和教材循环 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch6_dfs_bfs_sixdeg',
      );
      final vm = container.read(playbackProvider.notifier);
      Finder key(String k) => find.byKey(ValueKey(k));
      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tap(key('six-case'));
      expect(find.textContaining('0 / 30 = 0.0%'), findsOneWidget);
      DsStageCanvas canvas() => tester.widget(key('six-network'));
      final frames = container.read(playbackProvider).timeline!.frames;
      final layer6 = frames.indexWhere((f) => f.inlineVars['最远层'] == '6');
      vm.seek(layer6.toDouble());
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.where((n) => n.groupTag == '6').length, 1);
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(canvas().scene.nodes.where((n) => n.groupTag == '6'), isEmpty);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.textContaining('29 / 30 = 96.7%'), findsOneWidget);
      final center = canvas().scene.nodes.first;
      final rings = <int, double>{};
      for (final node in canvas().scene.nodes.skip(1)) {
        final d = int.parse(node.groupTag!);
        final distance =
            (Offset(node.x, node.y) - Offset(center.x, center.y)).distance;
        rings.putIfAbsent(d, () => distance);
        expect(distance, closeTo(rings[d]!, 0.01));
      }
      expect(rings[6], closeTo(6 * rings[1]!, 0.01));
      final person = key('scene-node-V28');
      await tester.ensureVisible(person);
      await tester.pumpAndSettle();
      await tester.tap(person);
      await tester.pump();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['源点'],
        'V28',
      );
      expect(container.read(playbackProvider).isPlaying, true);
      vm.last();
      await tester.pumpAndSettle();
      expect(
        int.parse(
          container.read(playbackProvider).currentFrame!.inlineVars['已达其他人']!,
        ),
        lessThan(29),
      );
      await tap(key('six-rule'));
      await tap(find.text('教材七次出队').last);
      vm.last();
      await tester.pumpAndSettle();
      expect(find.textContaining('已出队 7 次'), findsOneWidget);
      await tap(find.byTooltip('编辑网络'));
      expect(key('graph-tool'), findsOneWidget);
      await tap(find.byTooltip('查看六度传播'));
      expect(key('six-network'), findsOneWidget);
      await tap(key('six-case'));
      expect(key('traversal-mode'), findsOneWidget);
      expect(
        container.read(playbackProvider).currentFrame!.scene.nodes.length,
        8,
      );
      await tap(key('six-case'));
      expect(canvas().selectedNodeId, 'V28');
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
