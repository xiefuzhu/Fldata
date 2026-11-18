import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/app_database.dart';
import 'mastery_radar.dart';
import 'achievement_wall.dart';
import 'study_calendar.dart';
import '../../providers/app_providers.dart';
import '../../curriculum/catalog.dart';
import '../../curriculum/quiz_catalog.dart';
import '../../ui/components/bento_card.dart';
import '../../ui/components/elastic_press.dart';
import '../../ui/components/common_scaffold.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(lessonProgressProvider);
    final days = ref.watch(dailyStatsProvider);
    final due = ref.watch(dueQuestionsProvider);
    final lessons = [...?progress.value]
      ..sort((a, b) => b.lastVisitedAt.compareTo(a.lastVisitedAt));
    final minutes = days.value?.fold<int>(
      0,
      (sum, day) => sum + day.studyMinutes,
    );
    return CommonScaffold(
      title: '让结构，一目了然',
      subtitle: '从一条指针开始，理解每一步发生了什么。',
      child: LayoutBuilder(
        builder: (context, c) {
          final scale = math.max(
            1.0,
            MediaQuery.textScalerOf(context).scale(16) / 16,
          );
          final mobile = MediaQuery.sizeOf(context).width < 600;
          final cols = mobile
              ? 1
              : c.maxWidth / scale >= 1000
              ? 4
              : c.maxWidth / scale >= 500
              ? 2
              : 1;
          const gap = 16.0;
          final width = (c.maxWidth - gap * (cols - 1)) / cols;
          final heroHeight = 124 * scale;
          final statsHeight =
              (4 / cols).ceil() * 100 * scale + ((4 / cols).ceil() - 1) * gap;
          final chaptersHeight =
              32 * scale +
              (8 / cols).ceil() * 72 * scale +
              ((8 / cols).ceil() - 1) * gap;
          final rowsHeight =
              heroHeight + gap + statsHeight + 20 + chaptersHeight + gap;
          final panels =
              !mobile &&
              c.maxWidth >= 620 * scale &&
              c.maxHeight >= rowsHeight + 180 * scale;
          final stats = Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              _Stat(
                width: width,
                height: 100 * scale,
                label: '完成的实验',
                value: progress.hasError
                    ? '读取失败'
                    : progress.isLoading
                    ? '—'
                    : lessons.where((l) => l.status == 2).length.toString(),
                icon: Icons.task_alt,
              ),
              _Stat(
                width: width,
                height: 100 * scale,
                label: '累计学习 / 分钟',
                value: days.hasError ? '读取失败' : minutes?.toString() ?? '—',
                icon: Icons.timelapse,
              ),
              _Stat(
                width: width,
                height: 100 * scale,
                label: '已访问的实验',
                value: progress.hasError
                    ? '读取失败'
                    : progress.isLoading
                    ? '—'
                    : lessons.length.toString(),
                icon: Icons.route_outlined,
              ),
              _Stat(
                width: width,
                height: 100 * scale,
                label: '知识章节',
                value: '08',
                icon: Icons.auto_stories_outlined,
              ),
            ],
          );
          final map = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32 * scale,
                child: Text(
                  '课程地图',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final chapter in chapters)
                    SizedBox(
                      width: width,
                      height: 72 * scale,
                      child: BentoCard(
                        padding: EdgeInsets.zero,
                        child: ElasticPress(
                          onPressed: () =>
                              context.go('/catalog?chapter=${chapter.id.name}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '0${chapter.id.index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    chapter.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
          if (panels) {
            return ListView(
              key: const PageStorageKey('dashboard-wide-scroll'),
              children: [
                SizedBox(
                  height: c.maxHeight,
                  child: Column(
                    key: const ValueKey('dashboard-panels'),
                    children: [
                      SizedBox(height: heroHeight, child: const _Welcome()),
                      const SizedBox(height: gap),
                      SizedBox(height: statsHeight, child: stats),
                      const SizedBox(height: 20),
                      SizedBox(height: chaptersHeight, child: map),
                      const SizedBox(height: gap),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _RecentPanel(
                                progress: progress,
                                lessons: lessons,
                              ),
                            ),
                            const SizedBox(width: gap),
                            Expanded(child: _ReviewPanel(due: due)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: gap),
                const _LearningPanels(),
                const SizedBox(height: gap),
                const AchievementWall(),
                const SizedBox(height: gap),
              ],
            );
          }
          return ListView(
            key: const ValueKey('dashboard-summary'),
            children: [
              const _Welcome(),
              const SizedBox(height: gap),
              _ActivitySummary(
                progress: progress,
                lessons: lessons,
                due: due,
                stacked: mobile,
              ),
              const SizedBox(height: gap),
              const _LearningPanels(),
              const SizedBox(height: gap),
              stats,
              const SizedBox(height: 20),
              map,
              const SizedBox(height: gap),
              const AchievementWall(),
              const SizedBox(height: gap),
            ],
          );
        },
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '把抽象的算法，变成可探索的过程',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '沿着八章教材，建立你的知识地图。',
          style: TextStyle(color: scheme.onPrimaryContainer),
        ),
      ],
    );
    final button = FilledButton.icon(
      onPressed: () => context.go('/catalog'),
      icon: const Icon(Icons.arrow_forward),
      label: const Text('浏览课程地图'),
    );
    return BentoCard(
      color: scheme.primaryContainer,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) => c.maxWidth >= 600
            ? Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 20),
                  button,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [text, const SizedBox(height: 16), button],
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.width,
    required this.height,
    required this.label,
    required this.value,
    required this.icon,
  });
  final double width, height;
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: BentoCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _RecentPanel extends StatelessWidget {
  const _RecentPanel({required this.progress, required this.lessons});
  final AsyncValue<List<LessonProgress>> progress;
  final List<LessonProgress> lessons;
  @override
  Widget build(BuildContext context) => _Panel(
    title: '最近实验',
    child: progress.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('实验记录读取失败')),
      data: (_) => lessons.isEmpty
          ? const Center(child: Text('还没有实验记录'))
          : ListView.builder(
              key: const PageStorageKey('recent-experiments'),
              itemCount: lessons.length,
              itemBuilder: (context, i) => ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => context.go('/lab/${lessons[i].moduleId}'),
                title: Text(
                  moduleById(lessons[i].moduleId)?.title ?? lessons[i].moduleId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('学习 ${lessons[i].timeSpentSeconds} 秒'),
                trailing: Icon(
                  lessons[i].status == 2
                      ? Icons.check_circle_outline
                      : Icons.history,
                ),
              ),
            ),
    ),
  );
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({required this.due, this.fromSheet = false});
  final bool fromSheet;
  final AsyncValue<List<WrongQuestion>> due;
  @override
  Widget build(BuildContext context) => _Panel(
    title: '今日待复习 · 含逾期',
    child: due.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('复习记录读取失败')),
      data: (rows) => rows.isEmpty
          ? const Center(child: Text('暂无到期错题'))
          : ListView.builder(
              key: const PageStorageKey('due-reviews'),
              itemCount: rows.length,
              itemBuilder: (context, i) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_edu),
                onTap: questionById(rows[i].questionId) == null
                    ? null
                    : () {
                        final router = GoRouter.of(context);
                        if (fromSheet) Navigator.of(context).pop();
                        router.push('/assessment/${rows[i].questionId}');
                      },
                title: Text(
                  questionById(rows[i].questionId)?.topic ?? rows[i].questionId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '第 ${rows[i].chapterId.replaceFirst('ch', '')} 章 · 累计错 ${rows[i].errorCount} 次',
                ),
                trailing: Text(
                  rows[i].nextReviewAt.toLocal().toString().substring(0, 10),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => BentoCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    ),
  );
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({
    required this.progress,
    required this.lessons,
    required this.due,
    required this.stacked,
  });
  final AsyncValue<List<LessonProgress>> progress;
  final List<LessonProgress> lessons;
  final AsyncValue<List<WrongQuestion>> due;
  final bool stacked;
  @override
  Widget build(BuildContext context) {
    final recent = Text(
      progress.hasError
          ? '实验记录读取失败'
          : progress.isLoading
          ? '正在读取实验记录…'
          : lessons.isEmpty
          ? '最近实验：暂无记录'
          : '最近实验：${moduleById(lessons.first.moduleId)?.title ?? lessons.first.moduleId}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final review = TextButton.icon(
      icon: const Icon(Icons.history_edu),
      onPressed: due.value?.isNotEmpty == true
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => FractionallySizedBox(
                heightFactor: .7,
                child: Consumer(
                  builder: (context, ref, _) => _ReviewPanel(
                    due: ref.watch(dueQuestionsProvider),
                    fromSheet: true,
                  ),
                ),
              ),
            )
          : null,
      label: Text(
        due.hasError
            ? '复习记录读取失败'
            : due.isLoading
            ? '正在读取复习记录…'
            : '今日到期复习：${due.requireValue.length} 题',
      ),
    );
    return BentoCard(
      padding: const EdgeInsets.all(16),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [recent, const SizedBox(height: 8), review],
            )
          : Row(
              children: [
                Expanded(child: recent),
                const SizedBox(width: 16),
                Expanded(child: review),
              ],
            ),
    );
  }
}

class _LearningPanels extends ConsumerWidget {
  const _LearningPanels();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(dailyStatsProvider),
        mastery = ref.watch(chapterMasteryProvider);
    final now =
        ref.watch(studyClockProvider).value?.toLocal() ?? DateTime.now();
    final heat = BentoCard(
      child: days.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => const Text('每日学习记录读取失败'),
        data: (rows) => StudyCalendar(days: rows, today: now),
      ),
    );
    final radar = BentoCard(
      child: mastery.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => const Text('章节掌握度读取失败'),
        data: (rows) => MasteryRadar(rows: rows),
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 880
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: heat),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: radar),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [heat, const SizedBox(height: 16), radar],
            ),
    );
  }
}
