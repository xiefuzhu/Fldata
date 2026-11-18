import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../curriculum/quiz_catalog.dart';
import '../curriculum/ch8_sort/textbook_sort_pass.dart';
import '../curriculum/ch8_sort/exchange_sort.dart';
import '../curriculum/ch8_sort/insertion_sort.dart';
import '../curriculum/ch8_sort/selection_sort.dart';
import '../curriculum/ch8_sort/merge_radix.dart';
import '../features/assessment/trace_table_grader.dart';
import '../models/quiz_question.dart';
import '../views/lab/lesson_player.dart';
import '../views/lab/exchange_sort_view.dart';
import '../views/lab/insertion_sort_view.dart';
import '../views/lab/selection_sort_view.dart';
import '../views/lab/merge_radix_view.dart';

Widget? sortExerciseRoute(GoRouterState state) {
  if (state.uri.queryParameters['exercise'] != sortTableId) return null;
  final row = int.tryParse(state.uri.queryParameters['row'] ?? '');
  final q = questionById(sortTableId)! as TraceTableQuestion;
  if (row == null || row < 0 || row >= q.rowLabels.length) return null;
  final pass = TextbookSortPass.forRow(q, row);
  if (state.pathParameters['id'] != pass.module) return null;
  LessonLaunch<T> launch<T>(T input) =>
      LessonLaunch(input, pass.target, '/assessment/$sortTableId');
  final key = ValueKey(state.uri.toString());
  return switch (pass.module) {
    'ch8_insert_shell' => InsertionSortView(
      key: key,
      launch: launch(
        InsertionInput(
          keys: exerciseSortKeys,
          method: switch (pass.method) {
            '希尔' => InsertionMethod.shell,
            '折半插入' => InsertionMethod.binary,
            _ => InsertionMethod.direct,
          },
        ),
      ),
    ),
    'ch8_select_heap' => SelectionSortView(
      key: key,
      launch: launch(
        SelectionInput(
          keys: exerciseSortKeys,
          method: pass.method == '简选'
              ? SelectionMethod.simple
              : SelectionMethod.heap,
        ),
      ),
    ),
    'ch8_swap_bubble_quick' => ExchangeSortView(
      key: key,
      launch: launch(
        ExchangeInput(
          keys: exerciseSortKeys,
          method: pass.method == '快排'
              ? ExchangeMethod.quick
              : ExchangeMethod.bubble,
        ),
      ),
    ),
    _ => MergeRadixView(
      key: key,
      launch: launch(
        const MergeRadixInput(keys: exerciseSortKeys, bottomUp: true),
      ),
    ),
  };
}
