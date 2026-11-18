# 08 — 教材全量评测中心、SM-2 学习系统与终验交付手册（Stage 6）

> **关联阶段**：Stage 6（`[S6-01]` ～ `[S6-08]`）  
> **核心职责**：将教材第 1～8 章课后《习题》打造为可交互、可可视化纠错、可自动判题的闭环练习系统，落地 SM-2 错题本与年度学习看板，并完成全工程质量终检与 Windows Release 交付。

---

## 一、严蔚敏教材第 1～8 章课后《习题》全量结构化索引

> 此表保留立项时的主题名录与 186 题估计。按用户提供的第 2 版原书核对，八章正式题库共 195 项。章节页码、原题计数及旧稿处理见 [题库来源与覆盖](QUIZ_SEED_COVERAGE.md)。

| 章节 | 选择题数 | 手算推演 / 应用题核心名录 | 算法设计题核心名录（类C编写/填空 + 测试用例评测） |
| :--- | :---: | :--- | :--- |
| **Ch1 绪论** | 6 题 | （融入客观/分析题）抽象数据类型定义辨析、6 段嵌套循环代码时间复杂度阶推导 | （暂无） |
| **Ch2 线性表** | 15 题 | 有序表/链式表归并手动状态推演、双链表指针操作步序排查（4 题代表性交互题） | **10 题**：两递增链表合并（不重复有序）、两非递减合为非递增表、求交集、求差集（修改 `LA` 返回个数）、正负拆分成两链表、遍历求最大节点、**单链表原地逆置**、删区间 `(mink, maxk)`、`DuLinkList` 节点 `change(p)` 与前驱交换、**顺序表 $O(n)$ 空间 $O(1)$ 删除所有值为 `item` 的元素** |
| **Ch3 栈和队列** | 15 题 | 出入栈序列合法性全枚举推演、算符优先与逆波兰手工转换 | **10 题**：共享数组双栈 `DblStack`（Init/Empty/Full/Push/Pop）、栈判回文、后缀表达式求值、`I/O` 操作序列合法性判定、仅设尾指针带头节点循环链队入出队、带 `tag` 标志循环队列（不浪费空间）、双端循环队列从两端插入删除、`Ackermann` 递归与非递归转换、输入负一为止算法、**链表递归求最大值/节点数/平均值** |
| **Ch4 串数组广义表** | 15 题 | **4 题**：串基本操作推导、`BF` vs `KMP` 比较次数手算、**`next[]` 与 `nextval[]` 逐格手算填表**、二维数组按行/按列地址计算与广义表 `GetHead/GetTail` 嵌套结果 | **6 题**：统计字符串各合法字符出现频度写入文件/数组、**递归逆序字符串**、`Insert(S, T, pos)`、格式串按行宽排版换行、`n` 维稀疏或对称统计、**数组元素按正负或负数在前正数在后 $O(n)$ 单趟分割重排** |
| **Ch5 树和二叉树** | 15 题 | **4 题**：二叉树性质度与节点数手算、已知先/中序画二叉树并转中序线索、森林转二叉树互译、**给出权值手建哈夫曼树计算编码与 `WPL`** | **8 题**：统计二叉树叶节点数、**判断两棵二叉树是否相等**、**递归交换左右子树**、双序遍历（先访问再左子树再重访再右子树）、**层序/递归求二叉树最大宽度**、层次统计度为 1 节点数、**输出二叉树中从根到每个叶子的路径及最长路径**、先序输出各节点及其所在层次 |
| **Ch6 图** | 15 题 | **5 题**：无向/有向图矩阵与邻接表手画、DFS/BFS 序列手写、Prim/Kruskal 加边顺序记录、**Dijkstra 逐轮 `S/D/Path` 手工填表（教材题）**、**AOE 网手算 `ve/vl/e/l` 与标定关键路径** | **5 题**：邻接矩阵与邻接表互相插入/删除点与边、邻接表实现非递归 DFS、邻接表判两顶点间是否存在简单路径、**判断无向图是否构成一棵树**、**DFS 判定图中是否存在长度为 `k` 的简单路径** |
| **Ch7 查找** | 15 题 | **7 题**：11 元素折半判定树构建及计算成功/失败 `ASL`、给定输入序列构造 BST、**AVL 逐个插入动态平衡调整（4 旋考察）**、**3 阶 B-树逐键插入分裂与删除合并推演**、**散列表线性/二次探测建表与手算 `ASL_succ / ASL_unsucc`** | **6 题**：折半查找递归实现、**判断给定二叉树链表是否为二叉排序树**、递增或递减输出 BST 中所有 `>= x` 的关键字、向无辅助平衡树插入、计算给定平衡二叉树高度、统计或查找第 `k` 小节点 |
| **Ch8 排序** | 15 题 | **3 题**：**给定序列写出直插、折半插、希尔(`dk=5,3,1`)、快排第 1 趟、堆排序初堆、二路归并、基数排序第 1 趟各趟中间状态序列**、排序稳定性反例构造、最佳归并树手算虚段数 | **6 题**：不带头节点/带头节点单链表简单选择排序、**双向冒泡排序（正反交替扫描）**、将所有奇数移到所有偶数前边（类快排划分）、**荷兰国旗三色（红/白/蓝）单趟排序重排**、改写快排小区间转直插优化、判定小根堆序列合法性 |

---

## 二、四大交互式判题与纠错引擎核心规格 (`lib/features/assessment/`)

### 2.1 引擎 1：客观题与「一键实验室反例重现」协议
- 每道选择题的数据模型除包含 `options`, `correctIndices`, `explanationMarkdown` 外，新增可选字段 **`LabDeepLinkPayload? reproLab`**（含 `moduleId`, `presetPayloadJson`, `targetStepIndex`, `highlightReason`）。
- 当学生答错诸如「入栈序列 `1,2,3,4` 哪个出栈序列不可能得到？」时，解析卡片底部显示高亮按钮 **`[在顺序栈实验室中运行验证]`**。点击后通过 `GoRouter` 携带参数直达 `ch3_stack_sq_link`，自动载入该出栈序列并单步暂停在非法弹栈报错那一帧！

### 2.2 引擎 2：可视化手算推演填表判题器 (`TraceTableGrader`)
原计划预计 29 道交互推演。逐页录入后，第 4～8 章有 23 项应用题，其中 20 项使用表格，另 3 项为第 5 章含画图或开放编码方案的参考作答。连同第 1 章 6 项复杂度推演，正式目录共有 26 道可逐格判分的题目。
- **统一交互形态**：界面给出不可编辑的题干数据结构预览（如模式串或有向网拓扑图）+ 下方带边框的**动态交互填表网格 / 边集点选开关**：
  - KMP 填表自动识别 `1-indexed` 格子，学生填错哪一列 `j`，批改后悬停该格精确提示 `"此处 T[j]='c', next[j]=2, 应继续检查 T[next[j]] 是否与 T[j] 相等"`；
  - Dijkstra / AOE 填表支持输入数字或点击 `∞` 快捷芯片填入无穷大，在图画布上直接点选关键活动弧组成关键路径集合对比答案 Set；
  - 第 8 章「各趟排序状态题」直接复用 `ArraySlotNode` 格子，允许学生通过拖拽换位或键入数字填写第 1 趟划分结果，按对位率给予部分分并一键调出对应排序实验室对照动画。

### 2.3 引擎 3：指针外科手术沙盒判题器 (`PointerSandboxJudge`)
专为解决学生对链表指针语句顺序糊涂的痛点（适用于第 2、3、5 章）：
- **交互操作**：画布展示初始链表节点卡片与游离待插节点 `s`、局部指针 `p, q, L`；支持桌面端鼠标拖拽端口连线（移动端点击起点端口再点目标节点）或按顺序点选指令卡片排列执行次序。
- **实时三段式静态与图论判题器**（写入纯 Dart 类供测试验证）：
  ```dart
  PointerJudgeResult evaluatePointerGraph({
    required Map<String, String?> expectedNextMap,
    required Map<String, String?> actualNextMap,
    Map<String, String?>? expectedPriorMap,
    Map<String, String?>? actualPriorMap,
    required Set<String> rootPointers,
    required Set<String> deletedNodes,
  });
  ```
  1. **第一步（内存泄漏探测）**：从所有根指针 (`L`, `Ta`, `Tb` 等) 出发顺 `actualNextMap` 做可达性 BFS，若存在未被 `deleted` 却不可达的节点 → 立即判错并在画布标红该游离节点：`"发现节点 [x] 指针丢失，导致内存泄漏！"`；
  2. **第二步（意外成环检测）**：非循环链表场景下使用 Floyd 快慢指针从头指针出发检测是否发生断链后的自环死循环；
  3. **第三步（双向一致性与终态比对）**：核对正序遍历序与逆序 `prior` 遍历序是否严格匹配预期链表序列，全部吻合即亮出绿色满分动效。

### 2.4 引擎 4：类C算法填空与多边界用例沙盒判题器 (`AlgorithmCodeJudge`)
针对全书 51 道课后《算法设计题》，提供双模式评测以同时照顾手机触屏与桌面键鼠编码习惯：
1. **模式 A：结构化关键空行补全（手机/平板推荐，同样桌面可用）**
   - 展示教材标准类C代码框架，挖空 2～4 处最核心条件或指针赋值语句（如单链表逆置的 `p->next = q->next; q->next = L->next; L->next = q;`）。
   - 判题器内置 **`CLikeTokenNormalizer` 词法等价规约器**：自动消除多余空格/外围括号并将等价写法归一化（例如 `p != NULL` 规约等同于 `p`、`p->next == NULL` 等同 `!p->next`、`i = i + 1` 等同 `i++` / `++i`），减少死板字符串匹配的误伤。
2. **模式 B：完整函数编码 + 内置 Dart 参考沙盒多用例评测（桌面强推）**
   - 每道算法题预置一个可执行的内置受限类C子集表达式/状态机求值器（涵盖变量、指针索引、节点分配、循环、`if/else`、递归），或配套预设 Dart 翻译模板。
   - 点击「运行判题」后依次跑通 **6 组标准用例**：① 教材样例、② 空表/空树/零节点、③ 单元素极限、④ 全重复元素、⑤ 边界首尾插入/删除、⑥ 大规模随机序列；输出每组用例通过/失败徽章，点击失败用例可直观对比「预期结构图 vs 实际出错结构图」。

---

## 三、学习进度模型、SM-2 错题调度与成就系统

### 3.1 掌握度四维加权模型
每章得分 $\text{Mastery}_c \in [0, 100]$ 由 `QuizRepository` 在每次完成实验或交卷后事务更新写入 `ChapterMasteryTable`：
$$\text{Mastery}_c = 0.30 \times \text{LabCompletion}_c + 0.25 \times \text{ChoiceAccuracy}_c + 0.25 \times \text{TraceTaskScore}_c + 0.20 \times \text{AlgorithmDesignScore}_c$$
- 其中 `LabCompletion_c` 为该章所有实验室满足 `watchedFullTrace == true || customRunCount >= 1` 的占比。

### 3.2 SM-2 间隔重复错题本调度实现 (`lib/common/math_utils.dart`)
答错即进入 `WrongQuestionBookTable`；在错题重练模式下根据做题结果映射评分 $q \in \{0..5\}$（秒对 `5`、思考正确 `4`、提示后对 `3`、小错 `2`、大错 `1`）：
```dart
Sm2ScheduleResult computeNextSm2({
  required int prevRepetition,
  required int prevIntervalDays,
  required double prevEf,
  required int quality, // 0..5
}) {
  if (quality < 3) {
    return Sm2ScheduleResult(
      repetition: 0,
      intervalDays: 1,
      easinessFactor: math.max(1.3, prevEf - 0.2),
      isMastered: false,
    );
  }
  final int nextRep = prevRepetition + 1;
  final int nextInterval = switch (nextRep) {
    1 => 1,
    2 => 6,
    _ => (prevIntervalDays * prevEf).round(),
  };
  final double nextEf = math.max(
    1.3,
    prevEf + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)),
  );
  return Sm2ScheduleResult(
    repetition: nextRep,
    intervalDays: nextInterval,
    easinessFactor: nextEf,
    isMastered: nextRep >= 3,
  );
}
```

### 3.3 12 枚数据结构成就徽章名录
1. `first_trace`（初窥内存）：完整观看第 1 个算法可视化追踪；
2. `pointer_surgeon`（指针外科圣手）：在指针手术沙盒连续 5 题零内存泄漏通关；
3. `hanoi_master`（递归悟道者）：拖动汉诺塔至 `n=5` 并观察递归工作栈归零；
4. `kmp_navigator`（永不回溯）：KMP `nextval` 交互填表题满分；
5. `euler_walker`（欧拉轮廓漫游者）：完成第 5 章三种遍历与树转森林双向转换；
6. `huffman_compressor`（信息熵大师）：用哈夫曼实验室压缩并无损还原一条自定义文本；
7. `shortest_pathfinder`（图论探路者）：手动填对 Dijkstra 表 6.4 全部松弛数值；
8. `critical_architect`（关键工程总师）：正确标定含并行关键路径的 AOE 网络；
9. `avl_balancer`（绝不倾斜）：在 AVL 实验室亲自触发全部 `LL / RR / LR / RL` 四种旋转；
10. `race_champion`（排序竞速评论员）：完成至少 3 场 `SortRaceArena` 擂台并对比稳定/不稳定算法；
11. `streak_7days`（七日精进）：连续 7 天点亮学习热力图；
12. `eight_chapters_grandmaster`（严书通关宗师）：8 个章节综合掌握度全部突破 `80%`。

---

## 四、全阶段质量门禁与跨端静态复核清单

### Stage 0 ～ Stage 6 Windows 实机交付终检命令（按序执行，必须全 0 退出码）
```powershell
# 1. 重新核验所有代码生成无遗留脏文件
dart run build_runner build --delete-conflicting-outputs

# 2. 代码格式化与静态分析零容忍检查
dart format --output=none --set-exit-if-changed lib test
flutter analyze

# 3. 跑通覆盖数据库、TraceVM、第1~8章全部算法及四大判题器的单元测试与集成冒烟测试
flutter test

# 4. 打包 Windows 桌面端正式 Release 产物验证可执行性
flutter build windows --release
```

### Android 与 macOS 免跑静态预设复核单（仅检查源文件，无需跨平台构建）
- [x] 检查 `android/app/src/main/AndroidManifest.xml`：不存在任何 `android:screenOrientation` 锁死指令，且已启用 `android:enableOnBackInvokedCallback="true"`。
- [x] 检查 `android/app/src/main/kotlin/.../MainActivity.kt`：已在原生窗口调用 `WindowCompat.enableEdgeToEdge(window)`。
- [x] 检查 `macos/Runner/MainFlutterWindow.swift`：确认设置 `titleVisibility = .hidden`、`titlebarAppearsTransparent = true` 与 `.fullSizeContentView`。
- [x] 检查 `macos/Runner/DebugProfile.entitlements` 与 `Release.entitlements`：均已添加 `com.apple.security.files.user-selected.read-write` 为 `<true/>`。
- [x] 检查共用界面、实验播放器和指针画布的核心交互组件（播放钮、端口热区、搜索胶囊）：触控命中尺寸 $\ge 48 \times 48\text{dp}$ 且已接入 `HapticFeedback`（通过 `PlatformDetector.isMobile` 分流触发）。

---

## 五、本模块子任务同步勾选清单 (`[S6-01]` ～ `[S6-08]`)

- [x] `[S6-01]` 实现题库列表页（8 章/4 题型/错题筛选）与客观题「一键实验室反例重现 (`LabDeepLinkPayload`)」联动
- [x] `[S6-02]` 实现 `TraceTableGrader` 可视化手算填表判题器（KMP / 哈夫曼 / Dijkstra / AOE / 排序趟次）
- [x] `[S6-03]` 实现 `PointerSandboxJudge` 指针连线沙盒（拖拽端口 + 可达性内存泄漏检测 + Floyd 判环）
- [x] `[S6-04]` 实现 `AlgorithmCodeJudge` 类C关键行补全（Token 归一化）与多边界用例对比评测器
- [x] `[S6-05]` 完善首页 Bento 学习看板（年度学习热力图、八章掌握度雷达、SM-2 今日待复习队列、12 枚成就墙）
- [x] `[S6-06]` 完善设置页功能（`.structclash.json` 导入/导出与两种冲突合并策略、自定义数据管理、多分辨率布局调试开关）
- [x] `[S6-07]` 编写并跑通 `test/assessment/judges_and_sm2_test.dart` 与 `test/integration_smoke_test.dart`
- [x] `[S6-08]` 执行 Windows 全套终验命令（`build_runner`, `dart format`, `flutter analyze`, `flutter test`, `flutter build windows --release`）并勾完「免跑静态预设复核单」，更新 `.doc/README.md` 全部阶段为 `✅ 已完成`

## 种子数据实施口径（2026-11-16，用户已确认）
用户要求逐题对应教材原题，暂不补写缺失题干。附件仅含主题与题量，未附完整原题，因此停止主题重建。现存 58 道重建题仅为待核对/替换草稿，不计教材原题覆盖；已核验原题对应数为 0。S2-12 保持未完成，待实际原题和必要图表补齐后逐题建立来源映射。第 3 章设计题未新增，Stage 6 判题器未完成。详见 [QUIZ_SEED_COVERAGE.md](QUIZ_SEED_COVERAGE.md)。上文 186 及 29 保留为原计划记录，实际题量以原题核对为准。

## 2026-11-18 · S2-12 教材原页核对

据第二版教材书页 16～18、51～53、83～86，前三章分别有 16、25、25 项习题。第 1 章 5(1)～(6) 已录入，逐题标注书页、PDF 页与编号，答案和解析由项目编写。正式目录累计 6/66。旧稿 58 道继续单列，Stage 2 为 11/12。详见 [题库来源与覆盖](QUIZ_SEED_COVERAGE.md)。

## 2026-11-18 · S2-12 完成

前三章正式题库共 66 项，其中简答 4 项、选择 36 项、复杂度分析 6 项、算法设计 20 项。第 3 章最后 10 项已按书页 85～86 录入。图 3.17 随题重绘，四个 I/O 序列、后缀例串的分隔疑点、Ack(2,1) 的递归展开均有记录。第 3 章 10 份 C 参考通过 MSVC 编译并运行 60 个用例，对应 Dart 参考也通过 60 个用例。章节联合测试覆盖完整题号及规格指定的六项算法断言。Stage 2 已达 12/12，下一项为 S3-06。
