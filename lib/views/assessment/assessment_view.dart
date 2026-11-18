import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/catalog.dart';
import '../../curriculum/achievement_practice.dart';
import '../../curriculum/quiz_catalog.dart';
import '../../curriculum/pointer_practice.dart';
import '../../enum/ds_enums.dart';
import '../../providers/app_providers.dart';
import '../../ui/components/common_scaffold.dart';
import 'question_labels.dart';

class AssessmentView extends ConsumerStatefulWidget {
  const AssessmentView({super.key});
  @override
  ConsumerState<AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends ConsumerState<AssessmentView> {
  ChapterId? chapter;
  QuestionType? type;
  PracticeLevel? level;
  bool wrongOnly = false;
  String query = '';
  @override
  Widget build(BuildContext context) {
    final wrong = ref.watch(unmasteredQuestionIdsProvider);
    final wrongIds = wrong.value ?? const <String>{};
    final questions =
        [
              ...quizQuestions,
              if (type == QuestionType.pointerSandbox || wrongOnly)
                ...pointerPractice.values,
              if (wrongOnly)
                ...achievementPractice.where((q) => wrongIds.contains(q.id)),
              if (wrongOnly)
                ...draftQuizQuestions.where((q) => wrongIds.contains(q.id)),
            ]
            .where(
              (q) =>
                  (chapter == null || q.chapterId == chapter) &&
                  (type == null || q.type == type) &&
                  (level == null || practiceLevel(q) == level) &&
                  (!wrongOnly || wrongIds.contains(q.id)) &&
                  (query.isEmpty ||
                      '${q.title} ${q.topic} ${q.promptMarkdown} ${chapters[q.chapterId.index].title} ${q.id}'
                          .toLowerCase()
                          .contains(query)),
            )
            .toList();
    return CommonScaffold(
      title: '评测中心',
      subtitle: '教材习题 · 共 ${quizQuestions.length} 项',
      onSearch: (s) => setState(() => query = s.trim().toLowerCase()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                _FilterMenu(
                  title: '章节',
                  options: {
                    for (final c in chapters)
                      c.id: '第 ${c.id.index + 1} 章 · ${c.title}',
                  },
                  selected: chapter,
                  change: (v) => setState(() => chapter = v),
                ),
                _FilterMenu(
                  title: '题型',
                  options: questionTypeLabels,
                  selected: type,
                  change: (v) => setState(() => type = v),
                ),
                _FilterMenu(
                  title: '难度',
                  options: {for (final l in PracticeLevel.values) l: l.label},
                  selected: level,
                  change: (v) => setState(() => level = v),
                ),
                FilterChip(
                  label: const Text('只看错题'),
                  selected: wrongOnly,
                  onSelected: (v) => setState(() => wrongOnly = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (!wrongOnly || wrong.hasValue)
            Text(
              '符合条件 ${questions.length} 项',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          Expanded(
            child: wrongOnly && !wrong.hasValue
                ? Center(
                    child: wrong.hasError
                        ? TextButton(
                            onPressed: () =>
                                ref.invalidate(unmasteredQuestionIdsProvider),
                            child: const Text('错题记录读取失败，重试'),
                          )
                        : const CircularProgressIndicator(),
                  )
                : questions.isEmpty
                ? Center(child: Text(wrongOnly ? '当前筛选下没有待巩固的错题' : '当前筛选下没有习题'))
                : ListView.separated(
                    key: PageStorageKey(
                      'quiz-$chapter-$type-$level-$wrongOnly-$query',
                    ),
                    itemCount: questions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final q = questions[i];
                      return ListTile(
                        key: ValueKey(q.id),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),
                        title: Text(questionHeading(q)),
                        subtitle: Text(
                          '第 ${q.chapterId.index + 1} 章 · ${questionTypeLabels[q.type]} · ${practiceLevel(q).label}${q.id.startsWith("practice_")
                              ? " · 配套演练"
                              : q.id.startsWith("textbook_")
                              ? ""
                              : " · 历史草稿"}',
                        ),
                        trailing: Icon(
                          wrongIds.contains(q.id)
                              ? Icons.bookmark_outline
                              : Icons.chevron_right,
                        ),
                        onTap: () => context.push('/assessment/${q.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.title,
    required this.options,
    required this.selected,
    required this.change,
  });
  final String title;
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T?> change;
  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: '筛选$title',
    initialValue: selected == null
        ? 0
        : options.keys.toList().indexOf(selected as T) + 1,
    onSelected: (i) => change(i == 0 ? null : options.keys.elementAt(i - 1)),
    itemBuilder: (_) => [
      PopupMenuItem(value: 0, child: Text('全部$title')),
      for (final (i, name) in options.values.indexed)
        PopupMenuItem(value: i + 1, child: Text(name)),
    ],
    child: Chip(
      label: Text(options[selected] ?? title),
      avatar: const Icon(Icons.expand_more, size: 18),
    ),
  );
}
