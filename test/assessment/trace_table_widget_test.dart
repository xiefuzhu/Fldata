import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fldata/application.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/database/app_database.dart';
import 'package:fldata/engine/canvas/ds_stage_canvas.dart';
import 'package:fldata/features/assessment/trace_table_grader.dart';
import 'package:fldata/models/quiz_question.dart';
import 'package:fldata/providers/app_providers.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('填表保存、无穷大、图上点弧和交换排序回放 $width', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 900);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          nativeWindowProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FldataApp(),
        ),
      );
      Future<void> open(String id) async {
        router.go('/assessment/$id');
        await t.pumpAndSettle();
      }

      Future<void> tap(Finder f) async {
        await t.pumpAndSettle();
        await Scrollable.ensureVisible(t.element(f), alignment: .5);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      Finder key(String name) => find.byKey(ValueKey(name));
      Finder field(int row, int col) => find.descendant(
        of: key('trace-0-$row-$col'),
        matching: find.byType(TextField),
      );
      await open(kmpTableId);
      await t.ensureVisible(field(2, 1));
      await t.enterText(field(2, 1), '9');
      await t.enterText(field(0, 0), '0');
      await tap(find.text('提交整题'));
      expect(find.text('4 分 · 答对 1/24 项'), findsOneWidget);
      expect(find.byTooltip(RegExp(r'T\[3\]=c')), findsWidgets);
      final first = await db.select(db.quizAttemptsTable).getSingle();
      expect(first.score, 4);
      expect(first.userAnswerJson['rows'][2][1], '9');
      expect(
        (await db.select(db.wrongQuestionBookTable).getSingle()).questionId,
        kmpTableId,
      );
      await open(dijkstraTableId);
      await tap(find.byTooltip('下一组'));
      final eDistance = key('trace-0-6-0');
      await tap(find.descendant(of: eDistance, matching: find.text('∞')));
      expect(t.widget<TextField>(field(6, 0)).controller!.text, '∞');
      await open(aoeTableId);
      final canvas = find.byType(DsStageCanvas);
      await t.ensureVisible(canvas);
      await t.pumpAndSettle();
      final p1 = t.getCenter(key('scene-node-1')),
          p3 = t.getCenter(key('scene-node-3'));
      await t.tapAt(Offset.lerp(p1, p3, .5)!);
      await t.pumpAndSettle();
      expect(t.widget<FilterChip>(key('critical-1→3')).selected, isTrue);
      await tap(find.text('提交整题'));
      final attempts = await db.select(db.quizAttemptsTable).get();
      expect(attempts.last.userAnswerJson['criticalEdges'], ['1→3']);

      await open(sortTableId);
      await tap(find.text('载入题干序列'));
      Future<void> swap(int a, int b) async {
        final from = key('answer-slot-$a'), to = key('answer-slot-$b');
        await t.ensureVisible(from);
        await t.ensureVisible(to);
        await t.pumpAndSettle();
        await t.dragFrom(
          t.getCenter(from),
          t.getCenter(to) - t.getCenter(from),
        );
        await t.pumpAndSettle();
      }

      await swap(0, 1);
      await tap(find.text('核对本趟'));
      expect(find.textContaining('本趟对位 10/10'), findsOneWidget);
      await tap(key('answer-slot-0'));
      final editor = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await t.enterText(editor, '22');
      await tap(find.text('确定'));
      await tap(find.text('核对本趟'));
      expect(find.textContaining('本趟对位 9/10'), findsOneWidget);
      final table = questionById(sortTableId)! as TraceTableQuestion;
      final index = table.rowLabels.indexOf('快排 [1,10]');
      await tap(key('trace-page'));
      final option = find.text('快排 [1,10]');
      await t.scrollUntilVisible(
        option,
        230,
        scrollable: find.byType(Scrollable).last,
      );
      await tap(option);
      await tap(find.text('实验室对照本趟'));
      final state = container.read(playbackProvider), f = state.currentFrame!;
      expect(state.timeline!.moduleId, 'ch8_swap_bubble_quick');
      expect(f.inlineVars['阶段'], '枢轴归位');
      expect(state.isPlaying, isFalse);
      expect(
        f.scene.nodes.skip(1).take(10).map((n) => n.label),
        table.answerRows[index],
      );
      await tap(find.byTooltip('返回推演题'));
      expect(t.widget<DropdownButton<int>>(key('trace-page')).value, index);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    });
  }
}
