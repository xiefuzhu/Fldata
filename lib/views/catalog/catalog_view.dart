import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../curriculum/catalog.dart';
import '../../ui/components/common_scaffold.dart';
import '../../ui/components/bento_card.dart';

class CatalogView extends ConsumerStatefulWidget {
  const CatalogView({super.key, this.chapterId});
  final String? chapterId;
  @override
  ConsumerState<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends ConsumerState<CatalogView> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(lessonProgressProvider).value ?? const [];
    final visible = chapters
        .where(
          (c) =>
              (widget.chapterId == null || c.id.name == widget.chapterId) &&
              (c.title +
                      c.summary +
                      c.id.name +
                      modules
                          .where((m) => m.chapterId == c.id)
                          .map((m) => m.title)
                          .join(' '))
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList();
    return CommonScaffold(
      title: '课程目录',
      subtitle: '数据结构（C语言版 · 第2版）',
      onSearch: (value) => setState(() => query = value),
      child: visible.isEmpty
          ? const Center(child: Text('没有匹配的章节'))
          : ListView.separated(
              itemCount: visible.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chapter = visible[index];
                return BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '第 ${chapter.id.index + 1} 章 · ${chapter.title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(chapter.summary),
                      const SizedBox(height: 16),
                      if (chapter.moduleIds.isEmpty)
                        const Chip(
                          avatar: Icon(Icons.construction, size: 16),
                          label: Text('实验内容尚未开放'),
                        )
                      else
                        for (final id in chapter.moduleIds)
                          ListTile(
                            key: ValueKey('course-$id'),
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.science_outlined),
                            title: Text(moduleById(id)!.title),
                            subtitle: Text(
                              moduleById(id)!.textbookReferences.join(' · '),
                            ),
                            trailing: Text(switch (progress
                                .where((p) => p.moduleId == id)
                                .firstOrNull
                                ?.status) {
                              2 => '已学',
                              1 => '继续',
                              _ => '开始',
                            }),
                            onTap: () => context.go('/lab/$id'),
                          ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
