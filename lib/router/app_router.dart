import '../views/lab/shortest_path_view.dart';
import 'sort_exercise_route.dart';
import '../views/lab/dataset_launch.dart';
import '../views/settings/dataset_view.dart';
import '../views/lab/topo_critical_view.dart';
import '../views/lab/static_search_view.dart';
import '../views/lab/bst_view.dart';
import '../views/lab/btree_view.dart';
import '../views/lab/hash_table_view.dart';
import '../views/lab/insertion_sort_view.dart';
import '../views/lab/exchange_sort_view.dart';
import '../views/lab/selection_sort_view.dart';
import '../views/lab/merge_radix_view.dart';
import '../views/lab/external_sort_view.dart';
import '../views/lab/mst_view.dart';
import '../views/lab/graph_traversal_view.dart';
import '../views/lab/graph_storage_view.dart';
import '../views/lab/bitree_view.dart';
import '../views/lab/huffman_expr_view.dart';
import '../views/lab/glist_explorer_view.dart';
import '../views/lab/array_matrix_view.dart';
import '../views/lab/bf_kmp_view.dart';
import '../ui/components/command_palette.dart';
import '../ui/managers/build_manager_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/layout/app_shell.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/catalog/catalog_view.dart';
import '../views/lab/lab_placeholder.dart';
import '../views/lab/trace_preview.dart';
import '../views/lab/struct_mapping_view.dart';
import '../views/lab/adt_complex_view.dart';
import '../views/lab/complexity_lab_view.dart';
import '../views/lab/sqlist_view.dart';
import '../views/lab/linklist_view.dart';
import '../views/lab/circular_dulink_view.dart';
import '../views/lab/merge_compare_view.dart';
import '../views/lab/cases_polyn_book_view.dart';
import '../views/lab/stack_sq_link_view.dart';
import '../views/lab/queue_sq_link_view.dart';
import '../views/lab/cases_expr_dance_view.dart';
import '../views/lab/recursion_hanoi_view.dart';
import '../views/assessment/assessment_view.dart';
import '../views/assessment/question_detail.dart';
import '../curriculum/quiz_catalog.dart';
import '../models/quiz_question.dart';
import '../views/settings/settings_view.dart';

LabDeepLinkPayload? _reproFor(GoRouterState state) {
  final exercise = state.uri.queryParameters['exercise'];
  if (exercise == null) return null;
  final payload = questionById(exercise)?.reproLab;
  return payload?.moduleId == state.pathParameters['id'] ? payload : null;
}

final nativeWindowProvider = Provider<bool>((ref) => true);
final navigatorKey = GlobalKey<NavigatorState>();
final appRouterProvider = Provider<GoRouter>((ref) {
  final nativeWindow = ref.watch(nativeWindowProvider);
  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
      ShellRoute(
        builder: (context, state, child) => BuildManagerStack(
          nativeWindow: nativeWindow,
          openCommand: () => showCommandPalette(context),
          child: AppShell(child: child),
        ),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardView()),
          GoRoute(
            path: '/catalog',
            builder: (_, state) => CatalogView(
              key: ValueKey(state.uri.toString()),
              chapterId: state.uri.queryParameters['chapter'],
            ),
          ),
          GoRoute(
            path: '/lab/:id',
            builder: (_, state) => DatasetScope(
              launch: state.extra is DatasetLaunch
                  ? state.extra as DatasetLaunch
                  : null,
              child:
                  sortExerciseRoute(state) ??
                  (state.pathParameters['id'] == 'overview'
                      ? const TracePreview()
                      : state.pathParameters['id'] == 'ch1_struct_mapping'
                      ? const StructMappingView()
                      : state.pathParameters['id'] == 'ch1_adt_complex'
                      ? const AdtComplexView()
                      : state.pathParameters['id'] == 'ch1_complexity_lab'
                      ? const ComplexityLabView()
                      : state.pathParameters['id'] == 'ch2_sqlist_ops'
                      ? const SqListView()
                      : state.pathParameters['id'] == 'ch2_linklist_ops'
                      ? const LinkListView()
                      : state.pathParameters['id'] == 'ch2_circular_dulink'
                      ? const CircularDulinkView()
                      : state.pathParameters['id'] == 'ch2_merge_compare'
                      ? const MergeCompareView()
                      : state.pathParameters['id'] == 'ch2_cases_polyn_book'
                      ? const CasesPolynBookView()
                      : state.pathParameters['id'] == 'ch3_stack_sq_link'
                      ? StackSqLinkView(
                          key: ValueKey(state.uri.toString()),
                          repro: _reproFor(state),
                        )
                      : state.pathParameters['id'] == 'ch3_recursion_hanoi'
                      ? const RecursionHanoiView()
                      : state.pathParameters['id'] == 'ch8_external_sort'
                      ? const ExternalSortView()
                      : state.pathParameters['id'] == 'ch8_merge_radix_race'
                      ? const MergeRadixView()
                      : state.pathParameters['id'] == 'ch8_select_heap'
                      ? const SelectionSortView()
                      : state.pathParameters['id'] == 'ch8_swap_bubble_quick'
                      ? const ExchangeSortView()
                      : state.pathParameters['id'] == 'ch8_insert_shell'
                      ? const InsertionSortView()
                      : state.pathParameters['id'] == 'ch7_hash_table'
                      ? const HashTableView()
                      : state.pathParameters['id'] == 'ch7_btree_bplustree'
                      ? const BTreeView()
                      : state.pathParameters['id'] == 'ch7_bst_avl_lab'
                      ? const BstView()
                      : state.pathParameters['id'] == 'ch7_linear_bin_block'
                      ? const StaticSearchView()
                      : state.pathParameters['id'] == 'ch6_topo_critical'
                      ? const TopoCriticalView()
                      : state.pathParameters['id'] == 'ch6_shortest_path'
                      ? const ShortestPathView()
                      : state.pathParameters['id'] == 'ch6_mst_prim_kruskal'
                      ? const MstView()
                      : state.pathParameters['id'] == 'ch6_dfs_bfs_sixdeg'
                      ? GraphTraversalView(
                          sixDegrees:
                              state.uri.queryParameters['preset'] ==
                              'community30',
                        )
                      : state.pathParameters['id'] == 'ch6_graph_storage'
                      ? const GraphStorageView()
                      : state.pathParameters['id'] == 'ch5_huffman_expr'
                      ? const HuffmanExprView()
                      : state.pathParameters['id'] == 'ch5_tree_forest_conv'
                      ? const BiTreeView(
                          key: ValueKey('forest-conversion'),
                          course: TreeCourse.forest,
                        )
                      : state.pathParameters['id'] == 'ch5_threaded_tree'
                      ? const BiTreeView(
                          key: ValueKey('threaded-tree'),
                          course: TreeCourse.threaded,
                        )
                      : state.pathParameters['id'] == 'ch5_bitree_traverse'
                      ? const BiTreeView()
                      : state.pathParameters['id'] == 'ch4_glist_explorer'
                      ? const GListExplorerView()
                      : state.pathParameters['id'] == 'ch4_array_matrix'
                      ? const ArrayMatrixView()
                      : state.pathParameters['id'] == 'ch4_bf_kmp_lab'
                      ? const BfKmpView()
                      : state.pathParameters['id'] == 'ch3_queue_sq_link'
                      ? const QueueSqLinkView()
                      : state.pathParameters['id'] == 'ch3_cases_expr_dance'
                      ? const CasesExprDanceView()
                      : LabPlaceholder(id: state.pathParameters['id']!)),
            ),
          ),
          GoRoute(
            path: '/assessment',
            builder: (_, _) => const AssessmentView(),
            routes: [
              GoRoute(
                path: ":id",
                builder: (_, state) => QuestionDetail(
                  key: ValueKey(state.pathParameters["id"]),
                  id: state.pathParameters["id"]!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const SettingsView(),
            routes: [
              GoRoute(path: 'datasets', builder: (_, _) => const DatasetView()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
