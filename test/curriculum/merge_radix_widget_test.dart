import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'lesson_test_support.dart';

void main() {
  for (final width in [320.0, 1600.0]) {
    testWidgets('归并、十桶和多赛道战报 · $width', (tester) async {
      final (container, db) = await mount(
        tester,
        Size(width, 900),
        textScale: width == 320 ? 1.7 : 1,
        courseId: 'ch8_merge_radix_race',
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

      Future<void> seek(double n) async {
        vm.seek(n);
        await tester.pumpAndSettle();
      }

      int step(String phase) => container
          .read(playbackProvider)
          .timeline!
          .frames
          .firstWhere((f) => f.inlineVars['阶段'] == phase)
          .stepIndex;
      final write = step('写入');
      await seek(write - .5);
      expect(
        scene().nodes.singleWhere((n) => n.id == 'merge-copy').label,
        '38',
      );
      expect(scene().nodes.any((n) => n.id == 'm5:7'), false);
      vm.last();
      await tester.pumpAndSettle();
      expect(scene().nodes.where((n) => n.id.startsWith('m')), hasLength(13));
      await seek(0);
      expect(scene().edges, isEmpty);
      await tap(key('merge-radix-method'));
      await tap(find.text('链式基数').last);
      final distribution = step('分配');
      await seek(distribution - .5);
      final flying = scene().nodes.singleWhere((n) => n.id == 'member1');
      expect(flying.label, '278');
      expect(flying.y, inInclusiveRange(111, 333));
      await seek(distribution.toDouble());
      expect(
        scene().nodes.singleWhere((n) => n.id == 'bucket8').logicBadge,
        'f=1  e=1',
      );
      vm.stepBack();
      await tester.pumpAndSettle();
      expect(scene().nodes.any((n) => n.id == 'member1'), false);
      await tap(key('merge-radix-edit'));
      await tester.enterText(key('merge-radix-keys'), '-2 10');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      expect(find.textContaining('使用非负十进制整数'), findsOneWidget);
      await tester.enterText(key('merge-radix-keys'), '10 0 10');
      await tap(find.widgetWithText(FilledButton, '开始推演'));
      vm.last();
      await tester.pumpAndSettle();
      expect(
        container.read(playbackProvider).currentFrame!.inlineVars['链序'],
        '2,1,3',
      );

      await tap(key('open-race'));
      await tap(key('race-heap'));
      expect(tester.widget<FilledButton>(key('race-start')).onPressed, isNull);
      await tap(key('race-radix'));
      await tap(key('race-merge'));
      await tap(key('race-simple'));
      expect(tester.widget<FilterChip>(key('race-heap')).onSelected, isNull);
      await tap(key('race-sample'));
      await tap(find.text('大量重复').last);
      if (width > 320) {
        await tap(find.byType(DropdownButton<int>));
        await tap(find.text('32 项').last);
      }
      // Await the real compute isolate before advancing the test clock.
      final start =
          tester.widget<FilledButton>(key('race-start')).onPressed!
              as Future<void> Function();
      await tester.runAsync(start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 330));
      expect(find.byType(DsStageCanvas), findsNWidgets(4));
      if (width > 320) {
        for (final canvas in tester.widgetList<DsStageCanvas>(
          find.byType(DsStageCanvas),
        )) {
          expect(canvas.sortingRace, true);
          expect(canvas.scene.nodes, hasLength(32));
        }
        await tester.pump(const Duration(minutes: 5));
      } else {
        await tester.tap(key('race-finish'));
      }
      await tester.pumpAndSettle();
      expect(find.text('竞速战报'), findsOneWidget);
      final race = await (db.select(
        db.achievementsTable,
      )..where((r) => r.achievementId.equals('race_champion'))).getSingle();
      expect(race.progressCurrent, 1);
      expect(race.evidenceMask, 1);
      final table = tester.widget<DataTable>(find.byType(DataTable));
      expect(table.rows, hasLength(4));
      final ticks = table.rows
          .map((r) => int.parse((r.cells[2].child as Text).data!))
          .toList();
      expect(ticks, [...ticks]..sort());
      await tap(find.text('关闭'));
      await tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    });
  }
}
