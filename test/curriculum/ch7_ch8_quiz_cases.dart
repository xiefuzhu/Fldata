import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch8_sort/external_sort.dart';
import 'package:fldata/curriculum/ch8_sort/sort_race.dart';
import 'package:fldata/curriculum/ch8_sort/sort_records.dart';
import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/models/quiz_question.dart';

void ch7Ch8QuizCases() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('教材题号逐项定位，八章共 195 项，图 7.31 可离线读取', () async {
    expect(quizQuestions.map((q) => q.id).toSet(), hasLength(195));
    expect(quizQuestions, hasLength(195));
    for (final (chapter, applications) in [(7, 7), (8, 3)]) {
      final chapterQuestions = quizQuestions.where(
        (q) => q.chapterId.name == 'ch$chapter',
      );
      final counts = [15, applications, 6];
      expect(chapterQuestions.map((q) => q.id), [
        for (var i = 0; i < counts.length; i++)
          for (var n = 1; n <= counts[i]; n++)
            'textbook_ch${chapter}_${i + 1}_${n.toString().padLeft(2, "0")}',
      ]);
      for (final q in chapterQuestions.whereType<TraceTableQuestion>()) {
        expect(q.answerRows, hasLength(q.rowLabels.length), reason: q.id);
        for (final r in q.answerRows) {
          expect(r, hasLength(q.columns.length), reason: q.id);
        }
      }
      for (final q in chapterQuestions.whereType<ChoiceQuestion>()) {
        expect(q.options, hasLength(4));
        expect(q.correctIndices.single, inInclusiveRange(0, 3));
      }
    }
    final q = questionById('textbook_ch7_2_04')!;
    const asset = 'assets/quiz/ch7/fig731.png';
    expect(q.promptMarkdown, contains(asset));
    expect((await rootBundle.load(asset)).getUint32(0), 0x89504e47);
    expect(questionById('textbook_ch7_3_03')!.sourceLabel, contains('232～233'));
    expect(questionById('textbook_ch8_2_03')!.sourceLabel, contains('270～271'));
  });

  test('第八章应用题的初装工作区、败者树和三条归并段与实际追踪一致', () {
    final q = questionById('textbook_ch8_2_03') as TraceTableQuestion;
    final frames = const ExternalModule()
        .generateTrace(
          const ExternalInput.replacement([
            101,
            51,
            19,
            61,
            3,
            71,
            31,
            17,
            19,
            100,
            55,
            20,
            9,
            30,
            50,
            6,
            90,
          ], 6),
        )
        .frames;
    final built = frames.firstWhere((f) => f.inlineVars['阶段'] == '建树完成');
    expect(q.answerRows.map((r) => r.single), [
      built.scene.auxTables[1].rows.map((r) => r[1]).join(' '),
      built.scene.auxTables[0].rows.map((r) => r[1]).join(' '),
      ...frames.last.scene.auxTables.last.rows.map((r) => r[2]),
    ]);
  });

  test('十种内排在同一组样例上验证非降序、记录身份和实际稳定性', () {
    final inverted = <RaceAlgorithm>{};
    for (final keys in [
      RaceSample.random.generate(12, 815),
      sortExample81,
      [9, 6, 5, 3, 1],
      [7],
      sortExample82,
      [2, 2, 1],
      [2, 2],
    ]) {
      final records = SortRecord.tag(keys);
      final stable = [...records]
        ..sort((a, b) {
          final cmp = a.key.compareTo(b.key);
          return cmp == 0 ? a.origin.compareTo(b.origin) : cmp;
        });
      final stableLabels = stable.map((r) => r.label).join(' ');
      final byLabel = {for (final r in records) r.label: r};
      const algorithms = RaceAlgorithm.values;
      for (var i = 0; i < algorithms.length; i += 2) {
        for (final lane in buildRace(
          RaceRequest(keys, algorithms.sublist(i, i + 2)),
        )) {
          final labels = lane.beats.last.labels;
          final reason = '${lane.algorithm} $keys';
          expect(labels.toSet(), byLabel.keys.toSet(), reason: reason);
          expect(
            labels.map((s) => byLabel[s]!.key),
            stable.map((r) => r.key),
            reason: reason,
          );
          expect(
            lane.inverted,
            labels.join(' ') != stableLabels,
            reason: reason,
          );
          if (lane.algorithm.stable) {
            expect(lane.inverted, isFalse, reason: reason);
          }
          if (lane.inverted) inverted.add(lane.algorithm);
        }
      }
    }
    expect(inverted, {
      RaceAlgorithm.shell,
      RaceAlgorithm.quick,
      RaceAlgorithm.simple,
      RaceAlgorithm.heap,
    });
  });
}
