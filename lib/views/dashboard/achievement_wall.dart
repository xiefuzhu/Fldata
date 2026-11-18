import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/app_database.dart';
import '../../models/study_badge.dart';
import '../../providers/app_providers.dart';
import '../../ui/components/bento_card.dart';

const _destinations = {
  StudyBadge.firstTrace: ('/catalog', '浏览课程'),
  StudyBadge.pointerSurgeon: ('/assessment/practice_ch2_after', '打开指针沙盒'),
  StudyBadge.hanoiMaster: ('/lab/ch3_recursion_hanoi', '打开汉诺塔'),
  StudyBadge.kmpNavigator: ('/assessment/textbook_ch4_2_01', '练习 nextval 填表'),
  StudyBadge.eulerWalker: ('/lab/ch5_bitree_traverse', '进入遍历实验'),
  StudyBadge.huffmanCompressor: ('/lab/ch5_huffman_expr', '打开哈夫曼实验'),
  StudyBadge.shortestPathfinder: (
    '/assessment/practice_ch6_table64',
    '填写表 6.4',
  ),
  StudyBadge.criticalArchitect: (
    '/assessment/practice_ch6_parallel_aoe',
    '标定关键活动',
  ),
  StudyBadge.avlBalancer: ('/lab/ch7_bst_avl_lab', '打开 AVL 实验'),
  StudyBadge.raceChampion: ('/lab/ch8_merge_radix_race', '进入排序竞速课程'),
};
const _icons = [
  Icons.memory,
  Icons.link,
  Icons.layers,
  Icons.find_replace,
  Icons.account_tree,
  Icons.compress,
  Icons.route,
  Icons.alt_route,
  Icons.balance,
  Icons.flag,
  Icons.local_fire_department,
  Icons.school,
];

class AchievementWall extends ConsumerWidget {
  const AchievementWall({super.key});
  Future<void> inspect(
    BuildContext context,
    StudyBadge b,
    Achievement? row,
  ) async {
    final destination = _destinations[b];
    final date = row?.unlockedAt?.toLocal().toIso8601String().substring(0, 10);
    final parts = switch (b) {
      StudyBadge.eulerWalker => ['先序', '中序', '后序', '转为二叉树', '还原为森林'],
      StudyBadge.avlBalancer => ['LL', 'RR', 'LR', 'RL'],
      _ => <String>[],
    };
    final path = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(b.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(b.condition),
            const SizedBox(height: 8),
            Text(
              date == null
                  ? '进度 ${row?.progressCurrent ?? 0} / ${b.target}'
                  : '已解锁 · $date',
            ),
            if (parts.isNotEmpty)
              for (final (i, p) in parts.indexed)
                Text(
                  '${((row?.evidenceMask ?? 0) & (1 << i)) != 0 ? "✓" : "○"} $p',
                ),
            if (b == StudyBadge.raceChampion)
              Text(
                (row?.evidenceMask ?? 0) != 0 ? '已完成同场稳定性对比' : '尚待同场比较稳定和不稳定算法',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
          if (b == StudyBadge.eulerWalker)
            TextButton(
              onPressed: () => Navigator.pop(ctx, '/lab/ch5_tree_forest_conv'),
              child: const Text('进入森林转换'),
            ),
          if (destination != null)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, destination.$1),
              child: Text(destination.$2),
            ),
        ],
      ),
    );
    if (path != null && context.mounted) context.push(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BentoCard(
      child: ref
          .watch(achievementsProvider)
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('成就记录读取失败'),
            data: (rows) {
              final records = {for (final r in rows) r.achievementId: r};
              final unlocked = StudyBadge.values
                  .where((b) => records[b.id]?.unlockedAt != null)
                  .length;
              final colors = Theme.of(context).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '成就墙 · $unlocked / 12',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, c) {
                      final min =
                          175 * MediaQuery.textScalerOf(context).scale(1);
                      final cols = ((c.maxWidth + 8) / (min + 8)).floor().clamp(
                        1,
                        4,
                      );
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final b in StudyBadge.values)
                            SizedBox(
                              width: (c.maxWidth - 8 * (cols - 1)) / cols,
                              child: ListTile(
                                key: ValueKey(b.id),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: records[b.id]?.unlockedAt != null
                                    ? colors.secondaryContainer
                                    : colors.surfaceContainer,
                                leading: Icon(
                                  _icons[b.index],
                                  color: records[b.id]?.unlockedAt != null
                                      ? colors.primary
                                      : colors.outline,
                                ),
                                title: Text(b.title),
                                subtitle: Text(
                                  records[b.id]?.unlockedAt != null
                                      ? '已解锁'
                                      : '${records[b.id]?.progressCurrent ?? 0} / ${b.target}',
                                ),
                                onTap: () => inspect(context, b, records[b.id]),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
    );
  }
}
