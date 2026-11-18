enum StudyBadge {
  firstTrace('first_trace', '初窥内存', '完整观看一次算法追踪。'),
  pointerSurgeon('pointer_surgeon', '指针外科圣手', '连续五次通过指针沙盒，且全程零泄漏。', 5),
  hanoiMaster('hanoi_master', '递归悟道者', '将汉诺塔设为五盘，观察最后一层递归返回。'),
  kmpNavigator('kmp_navigator', '永不回溯', '在含 nextval 的 KMP 填表题获得满分。'),
  eulerWalker('euler_walker', '欧拉轮廓漫游者', '完成先序、中序、后序，以及森林与二叉树的双向转换。', 5),
  huffmanCompressor('huffman_compressor', '信息熵大师', '编码自定义文本，逐位译码并还原原文。'),
  shortestPathfinder(
    'shortest_pathfinder',
    '图论探路者',
    '手动填对 Dijkstra 表 6.4 五轮的距离与前驱。',
  ),
  criticalArchitect(
    'critical_architect',
    '关键工程总师',
    '在图 6.28 的 AOE 网中标出两条关键路径上的全部活动。',
  ),
  avlBalancer('avl_balancer', '绝不倾斜', '使用自定义插入序列触发 LL、RR、LR、RL 四种旋转。', 4),
  raceChampion('race_champion', '排序竞速评论员', '完成三场排序竞速，并至少同场比较一次稳定与不稳定算法。', 3),
  streak7days('streak_7days', '七日精进', '连续七个自然日留下学习记录。', 7),
  grandmaster('eight_chapters_grandmaster', '严书通关宗师', '八章综合掌握度均超过 80%。', 8);

  const StudyBadge(this.id, this.title, this.condition, [this.target = 1]);
  final String id, title, condition;
  final int target;
  bool reached(int count, int mask) =>
      count >= target && (this != raceChampion || mask != 0);
}
