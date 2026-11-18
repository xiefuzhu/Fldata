# Fldata (`fldata`) — 总控工程蓝图与跨对话进度同步中心

> **项目定位**：基于严蔚敏、李冬梅、吴伟民编著《数据结构（C语言版）（第2版）》的交互式可视化学习、逐行代码调试与评测软件。  
> **技术基准**：UI 与应用架构深度对标开源项目 `chen08209/FlClash`（v0.9.3），视觉系统融合 **Material Design 3 Expressive (M3E)** 物理弹簧动效与形状形变，底层引擎为自研确定性时间旅行追踪虚拟机（`TraceVM`）。  
> **运行策略**：**Windows 桌面端优先实机验证**（已具备 Flutter 3.47.7 + Dart 3.13.5 + VS 2026 环境），**Android 与 macOS 端在架构、布局、手势与工程配置层同步预设到位（执行阶段免跑模拟器/真机编译）**。

---

## 一、四大核心设计支柱概览

1. **M3 Expressive × FlClash 视觉与工程壳层**
   - 继承 FlClash 的 `Riverpod 3.x + Freezed + Drift + DynamicColor + re_highlight` 清晰分层架构与 `Builder` 驱动的零帧延迟 Bento 仪表盘。
   - 引入 M3 Expressive **Spatial / Effects 双轨物理弹簧（`motor` / `sprung`）**、Flutter 3.47 原生超椭圆连续圆角（`RoundedSuperellipseBorder`）、胶囊↔超方框态变交互、`Pure Black` OLED 纯黑模式，以及致敬原书排版的「**教材双色版（朱砂暖橙 `#D84315` × 黛青 `#006874`）**」主题方案。
2. **60/120fps 丝滑动画 × 三语可视化代码调试器**
   - 抛弃不可逆的异步定时动画，采用 **纯函数确定性执行 → 生成不可变 `TraceTimeline` → 双帧场景图物理插值** 架构，原生支持 **前进、时光倒流回退（`Step Back`）、`0.25x~4x` 变速、关键帧进度条拖拽、断点暂停**。
   - 覆盖原书第 1～8 章 **全部 46+ 实验室与算法（算法 2.1～8.12）+ 全部案例（案例 2.1～6.2）+ 外部排序（第 8.7 节）**，代码面板支持 **`教材类C语言` / `标准 C99` / `Dart`** 三语逐行同步高亮、行尾实时变量值胶囊（`Inline Variable Pill`）与递归工作栈（含 `RetLoc` 返回标号）。
3. **教材原题全量评测与 SM-2 进度追踪**
   - 结构化录入全书 **106 道客观选择题 + 29 道手算推演应用题 + 51 道算法设计题**，配套四大交互判题器（客观题实验室反例一键重现、手算填表按格诊断、指针外科连线防内存泄漏沙盒、类C关键空行/多用例自动判题）。
   - 基于 Drift SQLite 持久化记录实验完成度、年度热力图、八章掌握度加权雷达与 **SM-2 遗忘曲线错题本**，支持 `.structclash.json` 跨设备全量备份恢复。
4. **Windows 主验证 × Android / macOS 原生级预设**
   - 工程初始化即包含 `windows,android,macos` 三平台；桌面端配备 `window_manager` 自定义无边框标题栏、`flutter_acrylic` 毛玻璃与 `Ctrl/Cmd+K` 全局命令面板；macOS 预设透明标题栏、红绿灯 `76dp` 安全区、双指触控板手势与文件读写沙盒权限；Android 预设 `enableEdgeToEdge()`、预测性返回手势、不可锁死方向的多形态断点切换与 `48×48dp` 触控热区 + 触觉反馈。

---

## 二、跨对话 / 跨模型接力执行 SOP 与进度同步铁律（必读）

本 `.doc/` 文档库专为**多对话分阶段接力开发**设计，旨在彻底消除重复摸底与上下文膨胀。任何接手开发的 AI 模型必须严格遵守以下协议：

### 2.1 新对话启动 3 步曲（Start Protocol）
1. **第一且唯一启动动作**：调用 `read_file` 读取本文件 `.doc/README.md`，定位「三、全局阶段进度矩阵」与「四、全模块细粒度进度同步勾选总表」中**第一个未完成的 `[ ]` 子任务**，并核对「五、会话接力日志」中上一轮留下的环境状态与注意事项。
2. **按需单本加载（Context Protection）**：根据目标子任务所属阶段，**仅读取对应的那 1 本专项规格书（`01`～`08`）**。严禁一次性批量读取全套 `.doc/*.md` 文件。
3. **绝对红线 —— 禁止读取教材 PDF**：工作区根目录下的 30.6 MB《数据结构》PDF 共 274 页，读取该文件会触发全页图像解码并瞬间撑爆上下文窗口。全书知识点、算法细节、数组下标约定与习题清单均已精确写入 `04`～`08` 号规格书中，严格禁止再次读取 `.pdf`。

### 2.2 子任务交付双写同步铁律（Sync-Before-Stop Protocol）
每完成一个或一组子模块，并在 **Windows** 上完成静态检查与对应测试验证后，模型在结束本轮对话前**必须执行以下两处文档同步写入**，严禁只写代码不更新进度：
1. **局部勾选**：打开正在执行的专项规格书（如 `04_MODULES_CH1_CH2_CH3_LINEAR_STACK_QUEUE.md`），将已完成子任务的 `- [ ]` 更新为 `- [x]`。
2. **全局看板同步**：更新本文件 `.doc/README.md` 的三个区域：
   - 更新「全局阶段进度矩阵」中的完成计数（如 `7/12` → `8/12`）与状态标记（`⏳ 待开始` → `🚧 进行中` → `✅ 已完成`）；
   - 更新「全模块细粒度进度同步勾选总表」中对应 `[Sx-xx]` 项为 `[x]`；
   - 在「五、会话接力日志」末尾追加一条结构化接力记录（日期时间、完成 ID、修改文件清单、实测通过的命令及输出摘要、下一棒推荐起始任务 ID 与遗留提醒）。

---

## 三、文档导航地图（单本均控制在一轮可完整读取体积内）

| 文档编号 | 文件名 | 适用阶段 | 核心解答问题与涵盖范围 |
| :---: | :--- | :---: | :--- |
| **00** | `README.md` | 全阶段 | 总控入口、阶段进度矩阵、71 项细粒度同步勾选表、会话接力日志 |
| **01** | `01_SCAFFOLD_DATABASE_AND_PLATFORM_ARCH.md` | Stage 0 (上) | 非空目录安全初始化、`pubspec.yaml` 全量版本、三层架构边界、Drift 8 表 Schema 与 JSON 备份、三端平台配置 |
| **02** | `02_UI_DESIGN_SYSTEM_M3E_AND_FLCLASH.md` | Stage 0 (下) | FlClash 动态取色 + LRU 缓存 + PureBlack、`DsSemanticColors`、M3E 双轨弹簧与超椭圆形变、Bento 仪表盘、三断点工作台 |
| **03** | `03_TRACE_VM_AND_ANIMATION_ENGINE.md` | Stage 1 | 确定性 `TraceVM` 时光倒流机制、120Hz 混合画布性能优化、1-indexed 哨兵槽规范、四种几何布局与插值公式、三语调试器 |
| **04** | `04_MODULES_CH1_CH2_CH3_LINEAR_STACK_QUEUE.md` | Stage 2 | 第1章（绪论/复杂度仪）、第2章（算法 2.1～2.19、断链反例、稀疏多项式与图书管理）、第3章（算法 3.1～3.23、递归工作栈、算符优先表 3.1） |
| **05** | `05_MODULES_CH4_CH5_STRING_ARRAY_GLIST_TREE.md` | Stage 3 | 第4章（BF vs KMP、`next/nextval` 显微镜、环状病毒、矩阵压缩、广义表）、第5章（欧拉环游轨迹、线索树、森林 45° 旋转、哈夫曼与表达式树） |
| **06** | `06_MODULES_CH6_GRAPH_ALGORITHMS.md` | Stage 4 | 第6章（4种存储同步、DFS/BFS 生成树与六度空间、Prim vs Kruskal、Dijkstra 表 6.4 与 Floyd 热力回溯、拓扑与 AOE 关键路径） |
| **07** | `07_MODULES_CH7_CH8_SEARCH_AND_SORT.md` | Stage 5 | 第7章（折半判定树、BST 删除三分支、AVL 4种旋转、`m` 阶 B-树分裂合并、散列表 `ASL`）、第8章（10种内排、`49*` 稳定性、竞速擂台、外部排序三大件） |
| **08** | `08_ASSESSMENT_SYSTEM_AND_QA_ROADMAP.md` | Stage 6 | 教材题索引（原计划 186，逐题核对 195）、四大交互判题沙盒算法、SM-2 错题调度、掌握度雷达公式、Stage 0～6 Windows 门禁与双端静态终检 |

---

## 四、全局阶段进度矩阵（Progress Sync Matrix）

> **状态图标约定**：`⏳ 待开始` | `🚧 进行中` | `✅ 已完成` | `⚠️ 阻塞待排查`

| 阶段 | 阶段名称 | 对应规格书 | 核心交付物摘要 | 完成度 | 当前状态 | Windows 阶段验收门禁 | 最近更新备注 |
| :---: | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **Stage 0** | 工程底座、DB 与 M3E 壳层 | `01` + `02` | 三端初始化、Drift 8 表、主题/弹簧、Bento 首页骨架、`AppShell` | `12/12` | ✅ 已完成 | `build_runner` + `flutter analyze` + `test/database_test.dart` | 12 项完成；播放动作接口已就绪，进入 TraceVM |
| **Stage 1** | 核心 `TraceVM` 与混合引擎 | `03` | `AlgorithmModule`、`TraceBuilder`、画布/画笔、布局算法、三语调试器 | `10/10` | ✅ 已完成 | `flutter test test/engine/` | S1-01～10 完成；02 三断点实验工作台已接入 |
| **Stage 2** | 第1～3章：线性/栈/队列 | `04` | 算法 2.1～3.23 共 12 个交互实验室 + 前3章题库种子 | `12/12` | ✅ 已完成 | `flutter test test/curriculum/ch1_to_ch3_test.dart` | 12 项完成，前三章原题 66/66 |
| **Stage 3** | 第4～5章：串/数组/树 | `05` | KMP、矩阵/广义表、欧拉环游、线索树、哈夫曼等 7 实验室 + 题库 | `10/10` | ✅ 已完成 | `flutter test test/curriculum/ch4_to_ch5_test.dart` | 52/52 项教材习题及章节联合断言通过 |
| **Stage 4** | 第6章：图论全套实验室 | `06` | 4存储互转、遍历、MST、最短路径、关键路径 5 大实验室 + 题库 | `8/8` | ✅ 已完成 | `flutter test test/curriculum/ch6_graph_test.dart` | 25/25 项教材习题及章节联合断言通过 |
| **Stage 5** | 第7～8章：查找与排序 | `07` | AVL/B-树/散列 + 10种内排 + 竞速擂台 + 败者树外排 + 题库 | `11/11` | ✅ 已完成 | `flutter test test/curriculum/ch7_to_ch8_test.dart` | 依赖 Stage 1 |
| **Stage 6** | 评测沙盒、看板与终验 | `08` | 4大交互判题器、SM-2 错题流、热力图与双端配置终检、Release 构建 | `8/8` | ✅ 已完成 | `dart format` + `flutter analyze` + `flutter test` + `flutter build windows --release` | 最终闭环阶段 |

---

## 五、全模块细粒度进度同步勾选总表（共 71 项）

### Stage 0：工程底座、数据库与 M3E × FlClash UI 系统 (`12/12`)
- [x] `[S0-01]` 使用 `flutter create --platforms=windows,android,macos .` 安全初始化项目并配置 `.gitignore` 保护根目录 `.pdf`
- [x] `[S0-02]` 配置 `pubspec.yaml` 全量依赖、绑定 `JetBrainsMono` 字体资源与 `build.yaml` / `analysis_options.yaml`
- [x] `[S0-03]` 实现 `lib/common/`、`lib/enum/` 与 `lib/models/` 核心 Freezed 配置/课程领域模型并跑通 `build_runner`
- [x] `[S0-04]` 实现 Drift `AppDatabase` 全部 8 张持久化表、TypeConverters 与三端 `Progress/Quiz/Backup` Repository
- [x] `[S0-05]` 预设完成 Windows 高 DPI/窗口化配置，以及 macOS（`MainFlutterWindow.swift`、Entitlements）与 Android（`enableEdgeToEdge`、Manifest 无方向锁定）工程配置
- [x] `[S0-06]` 编写并跑通 `test/database_test.dart`（建表、进度更新、SM-2 写入、`.structclash.json` 导出/合并导入）
- [x] `[S0-07]` 实现 FlClash 同款 `ThemeProvider`（`DynamicColorSeeds`、64-LRU 缓存、教材双色版、PureBlack）与 `DsSemanticColors`
- [x] `[S0-08]` 实现 M3E 双轨弹簧 `m3e_springs.dart`、`RoundedSuperellipseBorder` 圆角形变 Token 与 `ElasticPress` / `BentoCard` 组件
- [x] `[S0-09]` 实现 `BuildManagerStack` 包装栈（含 `WindowHeaderManager` 兼容 Win 自定义标题栏与 Mac 76dp 红绿灯避让 + `HotKeyManager`）
- [x] `[S0-10]` 实现 `GoRouter` 路由表与三断点自适应 `AppShell` + 复刻 FlClash 弹簧搜索栏 `CommonScaffold` + `Ctrl/Cmd+K` 命令面板
- [x] `[S0-11]` 实现 FlClash 零帧延迟 Bento 首页仪表盘骨架（`_DesktopDashboard` 2/4列与 `_MobileDashboard`）及设置页外观切换
- [x] `[S0-12]` 编写并跑通 `test/ui/responsive_shell_test.dart`（验证 390dp 手机、800dp 平板、1280dp 桌面三断点无溢出切换）

### Stage 1：确定性追踪虚拟机 (`TraceVM`) 与混合渲染引擎 (`10/10`)
- [x] `[S1-01]` 定义 `lib/models/trace_model.dart` 不可变追踪模型族（`TraceTimeline`, `TraceFrame`, `SceneSnapshot`, `SceneNode`, `SceneEdge`, `PointerBadge`, `AuxTableSnapshot`, `StackActivationRecord`, `ComplexityMetrics`）
- [x] `[S1-02]` 实现 `AlgorithmModule<TInput>` 统一抽象接口、`TraceBuilder` 链式录制 DSL 与复杂度频度统计器
- [x] `[S1-03]` 实现 `PlaybackController` Riverpod 状态机（正放、暂停、`StepInto`、`StepOverMilestone`、`StepBack`、`Seek`、`0.25x~4x` 倍速与断点命中暂停）
- [x] `[S1-04]` 实现 `SceneInterpolator` 双帧物理插值器与链表断链/内存泄漏静态可达性检测器
- [x] `[S1-05]` 实现线性内存条（含 1-indexed `[0]` 哨兵专槽）、极坐标环状队列（最短弧角插值）与元素交换对偶抛物弧线计算器
- [x] `[S1-06]` 实现改良 `Reingold-Tilford` 树/森林/B-树布局器与图力导向+可拖拽固定布局器
- [x] `[S1-07]` 实现 `DsStageCanvas` 缩放/平移/触控板手势画布、`PointerEdgePainter` 贝塞尔画笔与 `AnimatedNodeLayer`
- [x] `[S1-08]` 实现 `CodeDebuggerPane`（`类C / C99 / Dart` 三语切换、`re_highlight` 主题、行号断点开关、行尾实时变量胶囊）
- [x] `[S1-09]` 实现 `CallStackInspector`（`RetLoc` 活动记录与递归树联动）、`MemoryTableInspector` 与 `PlaybackTransportBar`
- [x] `[S1-10]` 编写并跑通 `test/engine/trace_vm_test.dart` 与 `test/engine/playback_widget_test.dart`

### Stage 2：第 1～3 章全算法实验室与题库种子 (`12/12`)
- [x] `[S2-01]` `ch1_struct_mapping`：4种逻辑结构 × 2种存储结构内存条映射可视化
- [x] `[S2-02]` `ch1_adt_complex`：复数 `ADT Complex` 三元组封装与复平面向量动画
- [x] `[S2-03]` `ch1_complexity_lab`：渐近增长曲线仪（图 1.7）、例 1.4～1.10 语句频度热力计、例 1.11 空间复杂度对比
- [x] `[S2-04]` `ch2_sqlist_ops`：顺序表算法 2.1～2.5（后移/前移动画、$E_{\text{ins}}/E_{\text{del}}$ 公式计算、`ERROR/OVERFLOW` 演示）
- [x] `[S2-05]` `ch2_linklist_ops`：单链表算法 2.6～2.12（带头节点切换、两拍插入动画 + 误序断链丢失反例模式、前/后插建表）
- [x] `[S2-06]` `ch2_circular_dulink`：仅尾指针循环链表 `O(1)` 合并 + 双向链表算法 2.13～2.14 四指针修改演示
- [x] `[S2-07]` `ch2_merge_compare`：表 2.2/2.3 对比 + 算法 2.15～2.17（无序并集、顺序归并、链式原地穿针归并）
- [x] `[S2-08]` `ch2_cases_polyn_book`：案例 2.1 稠密多项式 + 案例 2.2（算法 2.18～2.19 稀疏多项式相加含零系数双释放）+ 案例 2.3 图书管理双版
- [x] `[S2-09]` `ch3_stack_sq_link`：顺序栈算法 3.1～3.4（`top` 指向栈顶上一空位约定）、链栈算法 3.5～3.8 与共享双栈 `DblStack`
- [x] `[S2-10]` `ch3_recursion_hanoi`：阶乘/斐波/算法 3.9/算法 3.10 汉诺塔三柱搬移 + 递归工作栈 `RetLoc` 与递归树三联动
- [x] `[S2-11]` `ch3_queue_sq_link` & `ch3_cases_expr_dance`：假溢出 vs 环状循环队列（算法 3.11～3.19 含删唯一元素尾指针重置）+ 案例 3.1～3.4（表 3.1 算符优先求值）
- [x] `[S2-12]` 注入第 1～3 章全部课后习题种子数据，编写并跑通 `test/curriculum/ch1_to_ch3_test.dart`

### Stage 3：第 4～5 章全算法实验室与题库种子 (`10/10`)
- [x] `[S3-01]` `ch4_bf_kmp_lab`：1-indexed `SString`、BF vs KMP（算法 4.1～4.2）上下双轨同屏滑动对比
- [x] `[S3-02]` `ch4_bf_kmp_lab` 深度扩展：`get_next`（算法 4.3）与 `get_nextval`（算法 4.4）对称前后缀递推显微镜 + 案例 4.1 环状病毒 DNA 检测（算法 4.5）
- [x] `[S3-03]` `ch4_array_matrix`：行主序/列主序寻址动画 + 对称/上下三角/三对角矩阵压缩 + 稀疏矩阵三元组快速转置
- [x] `[S3-04]` `ch4_glist_explorer`：广义表解析器、头尾链表 vs 扩展线性链表双视图、`GetHead`/`GetTail` 剥壳与深度计算
- [x] `[S3-05]` `ch5_bitree_traverse`：二叉树 5 性质、算法 5.1 递归遍历 + 图 5.11 欧拉环游轨迹小球 + 算法 5.2 非递归遍历
- [x] `[S3-06]` `ch5_bitree_traverse` 建树扩展：层序遍历、算法 5.3 含 `#` 先序建树、先中/后中重构树、算法 5.4～5.6
- [x] `[S3-07]` `ch5_threaded_tree`：算法 5.7～5.9 中序线索二叉树（五元组节点、`pre` 指针追踪、虚线前驱后继线索与双向头节点遍历）
- [x] `[S3-08]` `ch5_tree_forest_conv`：双亲/孩子/孩子兄弟表示法 + 树/森林 ↔ 二叉树「连兄弟-断连线-旋转 45°」可逆动画
- [x] `[S3-09]` `ch5_huffman_expr`：算法 5.10～5.11 哈夫曼树（`HT[1..2n-1]` 动态表与文本压缩编解码）+ 案例 5.2（算法 5.12～5.13 表达式二叉树求值）
- [x] `[S3-10]` 注入第 4～5 章课后习题种子数据，编写并跑通 `test/curriculum/ch4_to_ch5_test.dart`

### Stage 4：第 6 章图论全套实验室与题库种子 (`8/8`)
- [x] `[S4-01]` 交互式图编辑器与 `ch6_graph_storage`：`AMGraph` / `ALGraph` / `OLGraph` / `AMLGraph` 四种存储实时互转与悬停高亮
- [x] `[S4-02]` `ch6_dfs_bfs_sixdeg`：DFS 邻接矩阵/邻接表遍历（算法 6.3～6.6）、BFS（算法 6.7）与生成树/森林抽取
- [x] `[S4-03]` `ch6_dfs_bfs_sixdeg` 案例扩展：案例 6.2 / 算法 6.14 六度空间小世界网络 6 层波纹统计模拟
- [x] `[S4-04]` `ch6_mst_prim_kruskal`：Prim（算法 6.8 `closedge[]` 动态表与割集包络线）与 Kruskal（算法 6.9 `Vexset[]` 并查集染色判环）
- [x] `[S4-05]` `ch6_shortest_path`：Dijkstra（算法 6.10 复刻教材表 6.4 逐轮松弛演示）
- [x] `[S4-06]` `ch6_shortest_path` 扩展：Floyd（算法 6.11 $D^{(k)}$ / $Path^{(k)}$ 双矩阵热力图与最短路递归回溯）
- [x] `[S4-07]` `ch6_topo_critical`：拓扑排序（算法 6.12 `indegree[]` 与死锁环路检测）与 AOE 关键路径（算法 6.13 `ve/vl/e/l` 表与多路径高亮）
- [x] `[S4-08]` 注入第 6 章课后习题种子数据（含表 6.9 / 关键路径填表），编写并跑通 `test/curriculum/ch6_graph_test.dart`

### Stage 5：第 7～8 章查找、内部/外部排序与竞速擂台 (`2/11`)
- [x] `[S5-01]` `ch7_linear_bin_block`：算法 7.1～7.3（监视哨顺序查找、折半查找区间收缩 + 同步判定树生成与 `ASL`、分块查找）
- [x] `[S5-02]` `ch7_bst_avl_lab`（上）：BST 算法 7.4～7.7 查找、建树与三种情形删除（含左子树最右下前驱替换）
- [x] `[S5-03]` `ch7_bst_avl_lab`（下）：AVL 平衡二叉树实时 `BF` 计算、最小不平衡子树识别与 `LL/RR/LR/RL` 弹簧旋转动画
- [x] `[S5-04]` `ch7_btree_bplustree`：`m` 阶 B-树（算法 7.8～7.9 查找、分裂上推、删除借位与合并）及 B+树叶链表范围查找
- [x] `[S5-05]` `ch7_hash_table`：4 种散列函数 + 算法 7.10 开放地址法（线性/二次/随机探测、`DELETED` 墓碑语义）+ 链地址法 + $ASL_{\text{succ}}/ASL_{\text{unsucc}}$
- [x] `[S5-06]` `ch8_insert_shell`：算法 8.1 直接插入（`r[0]` 哨兵）、8.2 折半插入、8.3 希尔排序分组拱线与 `49*` 稳定性角标系统
- [x] `[S5-07]` `ch8_swap_bubble_quick`：算法 8.4 冒泡（`flag` 提前结束）与算法 8.5 快速排序（`r[0]` 挖坑填数 + 递归分区树）
- [x] `[S5-08]` `ch8_select_heap`：算法 8.6 简单选择、树形选择锦标赛与算法 8.7～8.9 堆排序（数组 × 完全二叉树双生同步 `HeapAdjust`）
- [x] `[S5-09]` `ch8_merge_radix_race`：算法 8.10～8.11 归并排序、算法 8.12 链式基数排序 10 桶动画与 `SortRaceArena` 多算法同屏擂台
- [x] `[S5-10]` `ch8_external_sort`：第 8.7 节多路平衡归并败者树 `LoserTree`、置换-选择排序工作区 `WA[w]` 与最佳归并树补 `0` 虚段
- [x] `[S5-11]` 注入第 7～8 章课后习题种子数据，编写并跑通 `test/curriculum/ch7_to_ch8_test.dart`

### Stage 6：交互式评测中心、SM-2 错题本、看板精修与终验交付 (`0/8`)
- [x] `[S6-01]` 实现题库中心页（按章节/题型/难度筛选）与「客观题一键跳转实验室反例重现」协议
- [x] `[S6-02]` 实现 `TraceTableGrader` 可视化手算填表判题引擎（覆盖 KMP `next/nextval`、哈夫曼、Dijkstra、AOE、排序趟次）
- [x] `[S6-03]` 实现 `PointerSandboxJudge` 指针连线外科沙盒（拖拽端口连线 + Floyd 判环 + 内存泄漏孤岛检测）
- [x] `[S6-04]` 实现 `AlgorithmCodeJudge` 类C关键行补全与多边界用例自动评测器（支持空表/单点/极值差异图对比）
- [x] `[S6-05]` 完善首页 Bento 学习看板（年度学习热力图、八章掌握度雷达/进度环、SM-2 今日复习流、12 枚成就徽章）
- [x] `[S6-06]` 完善设置页功能（`.structclash.json` 导入/导出、内置示例数据管理、三端自适应预览调试开关）
- [x] `[S6-07]` 编写并跑通 `test/assessment/judges_and_sm2_test.dart` 与 `test/integration_smoke_test.dart`
- [x] `[S6-08]` 执行 Windows 全套质量门禁（`dart format` + `flutter analyze` + 全量 `flutter test` + `flutter build windows --release`）并静态复核 Android/macOS 配置无缺漏

---

## 六、会话接力日志（Session Handoff Changelog）

> **日志追加规范**：每次执行回合结束前，按时间正序追加一条记录，标明操作日期、完成任务 ID、通过的检查命令与下一棒起始建议。

- **[2026-11-15 | Baseline 架构规划完成]**
  - **已完成**：摸底本地环境（Flutter 3.47.7 / Dart 3.13.5 / VS 2026 Win10 SDK `10.0.26100.0`）；完成《数据结构（C语言版·第2版）》全 8 章结构化拆解；完成 `chen08209/FlClash`（v0.9.3）架构与 UI 组件采样；建立本 `.doc/` 九本全模块工程规格文档库。
  - **工作区当前状态**：仅包含教材 PDF 与 `.doc/` 文档库，尚未创建 Flutter 工程代码。
  - **下一棒指引**：请读取 [01_SCAFFOLD_DATABASE_AND_PLATFORM_ARCH.md](file:///c:/flutter/dataStructure/.doc/01_SCAFFOLD_DATABASE_AND_PLATFORM_ARCH.md) 与 [02_UI_DESIGN_SYSTEM_M3E_AND_FLCLASH.md](file:///c:/flutter/dataStructure/.doc/02_UI_DESIGN_SYSTEM_M3E_AND_FLCLASH.md)，从 **`[S0-01]`** 开始执行 Stage 0。

- **[2026-11-15 | Windows 基础版本开工]**
  - **独立目录**：C:/Users/AndyYan/Desktop/codex/struct-clash；Git main；原计划基线提交 1dc7a2e。
  - **已完成 ID**：S0-01～S0-08、S0-10、S0-12（10/12）。
  - **修改文件**：三平台 Flutter 脚手架、pubspec/lock/build 配置、assets/fonts、lib/common/enum/models/database/providers/router/ui/views/curriculum、test、tool/scripts 与根目录进度记录。
  - **验证**：build_runner 成功；flutter analyze 无问题；flutter test 数据库/响应布局/主题共 12 项通过；flutter build windows --debug 成功。窗口实际启动：首页、设置页、标题栏、搜索按钮正常，已修复 Tooltip 缺 Overlay 问题。
  - **尚未完成**：S0-09 已有窗口管理、主题材质同步、Ctrl/Cmd+K/F；播放/步进/里程碑快捷键等待 Stage 1 引擎绑定。S0-11 已有 1/2/4 列首页与设置页，但底部最近记录/SM-2 双列表及矮屏摘要切换尚未实现。
  - **下一步**：补齐 S0-11，再由 S1-01 开始 TraceVM；在引擎落地时完成 S0-09 的播放快捷键。Stage 1～6 均未完成，不把目录占位页视为课程内容。
  - **兼容性修正**：drift_dev 使用 2.35.3；window_manager 使用 0.5.2；Dart 3 不兼容 sprung，改用 Flutter SpringSimulation；Android 使用 Flutter edgeToEdge API。实际依赖以 pubspec.lock 为准。
  - **限制**：Android/macOS 仅配置预设，未编译实测；未做 Release。Ctrl+K 组件测试通过，但自动化原生注入的 K 事件未保持 Ctrl，真实组合键仍待手动确认。备份合并遵照计划累加时间，重复导入会重复累加。

- **[2026-11-15 | Stage 0 补齐]**
  - **完成 ID**：S0-09、S0-11；Stage 0 12/12。
  - **实现**：按约束同步计算三行固定区域高度；高窗口底部双列表各自滚动，矮窗口降为摘要、外层单滚动。最近实验按访问时间倒序；到期复习包含逾期、排除未来和已掌握题；分钟时钟刷新查询。
  - **快捷键**：Space / 左右 / Shift+右 / Home / End 已通过统一 Intent/Actions 分发，实验室提供动作实现；文本编辑不被播放命令抢占。真实播放器绑定在下一阶段完成。
  - **验证**：flutter analyze 无问题；stage_zero_test 与 responsive_shell_test 共 6 项通过（真实数据库队列过滤、窗口即时切换、快捷键与输入焦点保护）。
  - **下一步**：S1-01～04；实现 TraceVM 并接入实验室引擎预览。

- **[2026-11-15 | TraceVM 核心落地]**
  - **完成 ID**：S1-01～04；Stage 0 的播放快捷键已绑定真实 PlaybackController。
  - **实现**：完整 Freezed/JSON 追踪模型；防御性快照复制；TraceBuilder 三语行号/场景/调用栈/复杂度增量；Riverpod 正倒放、单步/里程碑、任意 Seek、0.25～4 倍速、跨语言断点、错误帧暂停；稳定 ID 插值/创建删除淡入淡出/重连过渡；命名外指针可达性与泄漏扫描。
  - **可见入口**：侧栏「实验室」→ /lab/overview。安全插入、断链反例、空链表三种引擎样例；支持控件与 Space/方向键/Shift+右/Home/End。样例不写学习数据库，不计课程完成度。
  - **文件**：lib/models/trace_model*、playback_model*；lib/engine/vm、engine/examples；providers/playback_provider.dart；views/lab/trace_preview.dart；test/engine。
  - **验证**：build_runner 成功，flutter analyze 无问题，flutter test 全部 26 项通过（其中 TraceVM/播放交互 12 项）。flutter build windows --debug 成功；原生窗口已观察首页双列表、实验室第 3 行断点暂停、断链错误停靠，以及 Left 键回退后指针恢复且红色泄漏标记消失。
  - **下一棒**：S1-05 线性/哨兵/环队列最短弧/交换轨迹，然后 S1-06 树图布局。S1-07～09 目前仅预览组件，未完成全规格混合画布、语法高亮、递归树等。S1-10 已有核心测试，但环队列与百结点树测试须随布局实现补齐，保持未勾选。
  - **约定**：时间轴 k+t 始终对应 frames[k]→frames[k+1]，倒放只减少时间；语言切换不移动步骤、不丢断点；命中断点恢复只检查新进入帧；单帧时间轴不会循环播放。<2ms/120fps 仍是性能目标，未作实测结论。

- **[2026-11-15 | S1-05 布局与轨迹]**
  - **完成 ID**：S1-05；Stage 1 5/10。
  - **实现**：LinearMemoryLayout（56dp 槽、8dp 间隙、[0] 哨兵 24dp 隔离、双下标、共享双栈边界）；CircularQueueLayout（极坐标、指针轨道、留空一格判满）；SwapTrajectory（同排对调检测、上下双弧、moving 长距插入）。
  - **接入**：SceneInterpolator 采用稳定 ID；圆弧使用原始 k→k+1 的非负顺时针模差，倒放递减 t。新增 PointerOrbit/ZonePattern 的 Freezed/JSON 支持。实验室新增 7 个布局样例、哨兵虚线/紫色槽、满队列斜线、满栈缝隙单次闪烁。
  - **验证**：相关静态检查无问题；布局/TraceVM/交互/响应式共 26 项测试通过，其中新增 8 项布局测试、2 项多预设响应测试。Windows Debug 构建通过；原生窗口观察到哨兵紫色槽/分隔线/双下标、满队列斜线留空位及 End 跳转。样例空槽文字和标签间距修正后，12 项布局/交互测试与重建再次通过。
  - **下一棒**：S1-06 树/B-树与图布局；S1-07～09 完整画布/调试器仍未完成。S1-10 环队列和回退测试现已补齐，百结点树零重叠测试随 S1-06 实现，仍不勾选整个 S1-10。
  - **边界**：预览不是教材课程，不写学习记录。一个相同槽位到相同槽位的帧间变化代表零移动；完整一圈须录制中间步骤。环队列轨道不套会回摆的弹簧，交换空间轨迹使用 standardSpatial；透明度维持有界效果轨。<2ms/120fps 未做性能测量。

- **[2026-11-15 | S1-06 树与图布局]**
  - **完成 ID**：S1-06；同时补齐 S1-10 最后一项百结点树布局验证，Stage 1 7/10。S1-07～09 仍未完成。
  - **树**：非递归自底向上轮廓合并，支持树/森林/可变宽 B-树；实际宽高参与布局，同层至少 24dp，父结点位于直接孩子水平重心；稳定 ID 旋转按空间弹簧移动。
  - **图**：标准化预设坐标、60～100 步 FR（默认 80）、显式种子、后台 Isolate 重排、拖动固定/解除固定、过期任务结果丢弃。
  - **预览**：二叉树旋转、混合宽度森林、B-树分裂、表 6.4 六顶点带权网、图力导向。边权以 Widget 显示，绘制环节不循环 TextPainter.layout。
  - **文件**：engine/layout/tree_reingold_layout.dart、graph_layout_engine.dart、graph_presets.dart；engine/examples/tree_graph_trace_demo.dart；providers/graph_layout_provider.dart；views/lab/trace_preview.dart；test/engine/tree_graph_*。
  - **验证**：相关静态检查无问题；29 项引擎/既有交互 + 8 项新界面/响应式测试通过。百结点混合宽度和深链树无重叠、父结点居中、Pin 不漂移、后台输入复制、跨样例过期结果隔离均有断言。Windows Debug 构建及原生 B-树/拖动 Pin/后台重排检查通过；预设长边遮挡修正后，11 项树图测试、静态检查及 Windows 重建再次通过，最终原生窗口确认 v0→v5 绕开 v4。
  - **数据边界**：附件 06 只提供表 6.4 完整边集，该预设保留原边权、坐标为本项目人工排布。G1..G6 与标准 AOE 等缺少完整数据的教材图仍随 S4 录入，不冒充已有原图。其他样例只验证引擎，不记课程进度。
  - **下一棒**：S1-07 正式混合画布、缩放/平移/触控板与触控命中；然后 S1-08 语法高亮调试器、S1-09 递归树/检查器。S1-10 完成当前列出的回退/环队列/断点/百结点树测试要求，后续组件仍随实现增补回归。

- **[2026-11-16 | S1-07 混合画布]**
  - **完成 ID**：S1-07；Stage 1 8/10。S1-08～09 仍未完成。
  - **文件**：lib/engine/canvas/ 下的 DsStageCanvas、AnimatedNodeLayer、PointerEdgePainter、路径/命中/手势组件；trace_preview.dart、layout_trace_demo.dart；test/engine/stage_canvas_test.dart；README、task_plan、progress、findings 与本计划/03 局部计划。
  - **行为**：滚轮焦点缩放、空白平移、适应画布，镜头不随播放/seek 重置；触控板与单/双指统一归属画布，屏幕 48dp 命中，图拖动逆矩阵映射。文字走 Widget 层，节点独立 RepaintBoundary，排序入口 n>24 柱状显示。
  - **验证**：flutter analyze 无问题；stage_canvas_test、tree_graph_widget_test、playback_widget_test、layout_test、responsive_shell_test 共 32 项通过；flutter build windows --debug 成功。实际窗口滚轮/平移/复位、窄柱选择、缩放后固定图顶点通过。物理触控板/触屏、Android/macOS 与 <2ms/120fps 未验证。
  - **下一棒**：S1-08 CodeDebuggerPane；随后 S1-09 调用栈/递归树、内存表与完整播放控制台（含自动跟随镜头）。引擎样例不是已交付课程。

- **[2026-11-16 | S1-08 三语代码调试器]**
  - **完成 ID**：S1-08；Stage 1 9/10。
  - **文件**：lib/engine/debugger/code_debugger_pane.dart、code_highlight_cache.dart、lib/views/lab/trace_preview.dart、test/engine/code_debugger_test.dart；README/计划与进度记录。
  - **行为**：三语 SegmentedButton 不改变逻辑位置；re_highlight 整份源码编译后分行缓存，主题变化失效；42dp 装订线保留行号与红点，命中提示支持原断点语言；语义活动行光带与单次行内变量胶囊，窄屏换行。
  - **验证**：flutter analyze 无问题；code_debugger_test + playback_widget_test + tree_graph_widget_test 共 15 项通过；flutter build windows --debug 成功。原生窗口验证类 C 第 3 行断点暂停、变量显示，以及切换 Dart 保持第 3 帧。
  - **下一棒**：S1-09 调用栈/递归树、内存表、完整播放控制台及自动跟随镜头；然后继续 Stage 2～6。

- **[2026-11-16 | S1-09 检查器与播放控制台]**
  - **完成 ID**：S1-09；Stage 1 所列组件 10/10，Stage 0 12/12。完整实验工作台和 Stage 2～6 仍未完成。
  - **文件**：lib/engine/debugger/call_tree_projection.dart、call_stack_inspector.dart、memory_table_inspector.dart、playback_transport_bar.dart；engine/examples/recursion_trace_demo.dart；engine/canvas/ds_stage_canvas.dart；views/lab/trace_preview.dart；test/engine/inspectors_transport_test.dart、playback_widget_test.dart；README 与进度文档。
  - **行为**：活动栈卡片含实参/局部/RetLoc，调用树只投影当前帧前缀，保留已返回历史，回退移除未来调用；内存/指针/辅助表按快照更新；固定控制台支持正倒放、步进、里程碑吸附、0.25～4 倍速；自动镜头在活动区域越界时平移/缩小，手动操作退出跟随。
  - **验证**：flutter analyze 无问题；inspectors_transport_test、stage_canvas_test、playback_widget_test、tree_graph_widget_test、responsive_shell_test 共 32 项通过。底部布局调整后 16 项受影响测试重跑通过；基例局部变量修正后 8 项检查器测试再次通过。flutter build windows --debug 与 git diff --check 通过。
  - **实际窗口**：调用栈/递归树切换、辅助表高亮、点击末尾里程碑后历史树保留/活动表清空、回首帧仅保留根调用均已观察；最终构建的 Sum(0) 显示局部变量为空。物理触控设备与性能目标仍未测。
  - **下一棒**：先接入 02 的三断点实验工作台（桌面可拖拽分栏、平板标签、手机吸附抽屉及两行代码浮层），然后从 S2-01 开始课程实验。当前 Sum(n) 仅是引擎检查器样例，不代表 S2-10 汉诺塔课程完成。

- **[2026-11-16 | 02 响应式实验工作台]**
  - **完成范围**：接入此前未落地的 LabWorkspaceLayout，不增加 71 项主清单计数。Stage 0 12/12、Stage 1 组件 10/10；课程 Stage 2～6 未完成。
  - **文件**：lib/ui/layout/lab_workspace_layout.dart、app_shell.dart；lib/views/lab/trace_preview.dart；lib/engine/debugger/playback_transport_bar.dart；test/ui/lab_workspace_test.dart、responsive_shell_test.dart；02 与进度文档。
  - **行为**：桌面可拖拽 55% 舞台/右侧 60% 代码分栏；平板 55%/45% 舞台与多标签面板；手机两行代码浮层和 .12/.45/.85 吸附抽屉；跨断点保留面板/播放状态、48dp 主要播放控件和时间轴吸附。
  - **验证**：静态检查与 26 项相关测试通过。快速拖动修正后 6 项工作台用例重跑通过，额外补充的纵向单次鼠标断言专项通过；Windows Debug 构建成功。原生窗口已检查桌面横向分栏与中宽标签布局，手机抽屉/纵向分栏仅记组件验证。
  - **下一棒**：S2-01 结构与存储映射课程；按 04 推进前 3 章。主题、DB 与既有引擎不重做。未测物理触控设备或 <2ms/120fps。

- **[2026-11-16 | S1-07 续接复核]**
  - **状态**：已有功能提交 f3f0dce；S1-07 保持完成，不回退后续阶段进度。
  - **验证**：当前工作区运行 stage_canvas_test.dart 与 tree_graph_widget_test.dart，16 项通过；无功能代码修改。物理触控设备与性能目标仍未实测。
  - **提交范围**：本条与 03 的复核记录；工作区现有 S2-01 未提交开发内容保留，不纳入本次提交。

- **[2026-11-16 | S2-01 结构与存储课程]**
  - **完成 ID**：S2-01；Stage 2 1/12，Stage 0 12/12、Stage 1 10/10。
  - **行为**：四逻辑 × 两存储、8 槽模拟地址与关系字段、链式曲线、点选联动/闪烁、三个教学预设；课程目录/搜索/最近记录连通，前台时长、观看与显式已学状态保存。
  - **验证**：19 项课程/工作台/响应壳层测试通过，静态分析无问题，Windows Debug 成功；实际窗口确认入口、0x2018 定位、链式切换和树形显示。小屏大字采用组件验证，物理触控和性能未测。
  - **下一棒**：S2-02 ADT Complex，随后按 04 推进其余课程和题库。场景数据为教学重建；引擎预览仍不写学习记录。

- **[2026-11-16 | S2-02 ADT Complex]**
  - **完成 ID**：S2-02；Stage 2 2/12。
  - **行为**：七种复数操作、D/S/P 封装、加减平移/乘除极角动画、C 两次成员写回、除零保持输出；三语代码/调用栈/内存表及自定义输入、四预设、学习记录接入。
  - **验证**：28 项相关回归、静态分析与 Windows Debug 通过。原生窗口确认平行四边形、成员写回、乘以 i 中间向量及结果。小屏大字为组件验证，物理设备与性能未测。
  - **下一棒**：S2-03 复杂度曲线与频度/空间对比，然后按 04 继续。

- **[2026-11-16 | S2-03 复杂度实验室 / 本轮后暂停]**
  - **完成 ID**：S2-03；Stage 2 3/12。
  - **行为**：七增长曲线/触控悬停、规模滑块、逐行频度热力条、完整矩阵乘加、五类循环/顺序查找与双算法逆序空间对比；课程与学习记录接入。
  - **验证**：30 项相关回归、静态分析通过；最终颜色修正另通过 18 项课程/画布测试。原生窗口已确认指数值、3/9/27 频度和 1/7 槽对比。Debug 重建结果见 progress.md；物理设备与性能未测。
  - **后续**：遵用户“这轮结束先暂停”，提交后停止总目标；恢复后从 S2-04 开始。

- **[2026-11-16 | 恢复开发 / S2-04 顺序表]**
  - **完成 ID**：S2-04；Stage 2 4/12。
  - **实现**：Init/Get/Locate/Insert/Delete 三语纯追踪，0 下标与 1 位序、4 字节模拟地址、插删复制弧线与可逆内存快照；实际移动次数和 E_ins/E_del/ASL 等概率假设；越界、表满、空表、尾后插入与未命中预设。课程入口、输入、学习记录接入。
  - **验证**：10 项针对性测试及 flutter analyze 通过；Windows 实际窗口确认插入 99 的结果与 3 次移动、期望 2/1.5、红色 OVERFLOW 停靠。原生发现画布初始缩放偏小，增加高度；最终重建见 progress.md。
  - **下一棒**：S2-05 单链表、带头结点切换、插入两拍及误序断链沙盒，随后继续总计划。

- **[2026-11-16 | S2-05 单链表]**
  - **完成 ID**：S2-05；Stage 2 5/12。
  - **实现**：Init/Get/Locate/Insert/Delete/Create_H/Create_R 七操作，带头/无头实时切换；两拍接链、q 持有到释放、前插逆序/后插保序；误序覆盖入口触发失联检测与红色脉冲框，下一拍形成自环；三语教学代码、输入/预设、课程入口与学习记录接入。
  - **验证**：24 项算法/课程/画布回归通过，最终参数/标签修正另通过 12 项课程验证；flutter analyze 无问题，14 份正常 Dart 展示实现通过类型与空安全分析。Windows Debug 最终重建 10.3s。原生确认蓝色曲线、两拍插入、B/C/D 三结点失联、自环、前插 D→C→B→A 及无头 L 直接指首元；最终参数/标签修正由组件检查。
  - **下一棒**：S2-06 单循环链表 O(1) 合并与双向链表四指针操作。

- **[2026-11-16 | S2-06 循环与双向链表]**
  - **完成 ID**：S2-06；Stage 2 6/12。
  - **实现**：仅尾指针四步合并及 B 空表分支；双向循环链四步插入、两步删除、④ 提前于 ② 的误序反例；悬空边中间帧与双向一致性统计、左右端口/自环、三语代码/输入/预设/学习记录。
  - **验证**：23 项课程/画布回归、静态分析与 4 份 Dart 教学代码分析通过；最终单元素回环修正另通过 12 项课程测试。Windows Debug 最终重建 10.2s。原生检查合并结果 A→B→C→D→E、HB 释放时的悬空 next、双向正反序及删除唯一结点后的左右自环；最后回环路径修正为几何/组件验证。
  - **下一棒**：S2-07 无序并集、顺序有序归并与原地链式归并对比。

- **[2026-11-16 | S2-07 线性表合并对比]**
  - **完成 ID**：S2-07；Stage 2 7/12。
  - **实现**：集合并集、顺序新数组归并、链式 pa/pb/pc 逐步穿接与整串挂接/释放 HB；三语代码、稳定地址、时空比较卡、八预设、自定义输入、回退与学习记录。
  - **验证**：最终 11 项算法/课程测试、flutter analyze、Windows Debug（10.4s）通过；三份 Dart 教学源码独立分析和执行通过。原生确认穿接游标、A/B 相等值顺序、HB 释放、六槽 LC 和无序并集结果；最后状态/游标提示调整由组件验证。
  - **下一棒**：S2-08 稀疏多项式相加与图书管理，随后继续 Stage 2～6。

- **[2026-11-16 | S2-08 多项式与图书案例]**
  - **完成 ID**：S2-08；Stage 2 8/12。
  - **实现**：CreatePolyn 按指数有序插入、AddPolyn 同指数系数合并/相消双释放、稠密零槽对照；图书按编号查找和按位序插删、顺序/链式切换、结果续用；三语源码、十预设、自定义输入与学习记录。
  - **验证**：12 项算法/课程测试、八份 Dart 教学源码分析/执行、静态分析及 Windows Debug（10.5s）通过。原生确认相消 A/B 释放与四项结果、18/4/14 对照，以及图书插入/结果续用/顺序查找。
  - **下一棒**：S2-09 顺序栈、无头链栈、共享双栈，继续总计划。

- **[2026-11-16 | S2-09 栈实验室]**
  - **完成 ID**：S2-09；Stage 2 9/12。
  - **修改**：ch3_stack_queue/stack_{sq_link,source,trace}.dart、stack_sq_link_{view,stage}.dart、课程目录/路由、两份课程测试及计划文档。
  - **实现**：顺序栈四操作、无头链栈、共享双栈；单越界地址与数据槽分离、两拍 Push/Pop、双向空间共享、满空拒绝和学习记录。
  - **验证**：flutter test 两份 stack_sq_link 测试、flutter analyze、flutter build windows --debug 通过。11 项算法/课程测试通过，12 份 Dart 教学实现独立分析与执行通过；flutter analyze 无问题，Windows Debug 构建 10.0s。原生确认 990×856 初始整栈可见、最大化标签无重叠、Push 先写 99 再 top=4、共享满栈 OVERFLOW 自动暂停且零写入、右栈 top 4→3 与 8→9→99、唯一链节点出栈输出 42 且 S=NULL。
  - **下一棒**：S2-10 递归与汉诺塔，继续总计划。

- **[2026-11-16 | S2-10 递归与汉诺塔]**
  - **完成 ID**：S2-10；Stage 2 10/12。
  - **修改**：ch3_stack_queue/recursion_{hanoi,source,trace}.dart、recursion_hanoi_{view,stage}.dart、课程目录/路由、两份课程测试及计划。
  - **实现**：Fact/Fib/TraverseList/Hanoi 三语轨迹、独立调用 ID、返回值写回与弹栈恢复；三柱合法搬移/抛物线、RetLoc 事件和工作栈 PC、历史前缀递归树、输入/预设/学习记录。
  - **验证**：flutter test 两份 recursion_hanoi 测试、flutter analyze、flutter build windows --debug 通过。10 项算法/组件测试通过，四份 Dart 教学源码独立分析和执行通过，flutter analyze 无问题，Windows Debug 最终构建 10.1s。原生窗口确认三柱/树/工作栈同屏、RetLoc1 与 RetLoc2 弹栈后父记录 PC 恢复、三盘七步落在 C、Fib(5)=5 与九次独立调用。最后已返回节点中性色调整由组件验证，未重开原生窗口。
  - **下一棒**：S2-11 循环/链队与四个栈队列应用案例。

- **[2026-11-16 | S2-11 队列部分]**
  - **进度**：ch3_queue_sq_link 已完成；S2-11 四应用待做，Stage 2 保持 10/12。
  - **实现**：循环/线性/链队五操作、同序列假溢出对照、保留扇区、唯一节点 rear 复位、三语源码/输入/预设/学习记录。
  - **验证**：10 项队列算法/组件测试通过，另 12 项既有画布测试通过；三份 Dart 教学源码独立分析/执行通过，flutter analyze 无问题，最终 Windows Debug 构建 10.4s。原生窗口确认五槽满队保留扇区、同序列线性结果 4→9 且两次拒绝/环队结果 4→9→10→11 且零拒绝、唯一链节点删除时 rear 先复位再 free，活动代码和内存指针同步；标签轨道调整后已重开宽屏复核。代码面板保留手动滚动定位活动行。C99 未独立编译执行，物理触控与性能未测。
  - **下一棒**：ch3_cases_expr_dance 数制转换、括号匹配、表 3.1 算符优先和舞伴配对。

- **[2026-11-16 | S2-11 四应用完成]**
  - **完成 ID**：S2-11；与 e99d3fe 队列合并计为完整任务，Stage 2 11/12。
  - **实现**：数制转换支持 0～65535 与 2/8/16 进制、零特例；括号三类错误独立停靠。表达式按表 3.1 查表，双栈与输入游标/交叉高亮同步，弹 b、a、theta、计算、压回分帧；支持多位整数与 double 实数除法，拒绝一元负号/小数字面量，栈中保留完整浮点精度，显示最多八位有效数字。舞伴双 FIFO 按曲目配对，等待者留队首、已配对者曲终依次回队尾，多轮扩展明确标注。三语源码、12 预设、输入和学习记录已接入。
  - **验证**：11 项算法/组件测试通过，覆盖 390/990/1360 与 320@1.7；最终 flutter analyze 无问题，Windows Debug 构建 10.0s；四份 Dart 教学源码独立分析/执行通过。原生窗口确认优先表与双栈并排、Precede(-,)) 的 > 交叉高亮、先弹 b=2 和结果 15，舞伴第一曲等待小周/两曲后阿杰优先，255→FF，以及括号类型错误红色停靠。最终括号失败计数与取出项错误色由 6 项算法回归验证，未重开原生窗口。C99 未独立编译执行，物理触控与性能未测。
  - **下一棒**：S2-12 前三章习题种子与联合断言，然后继续 Stage 3～6。

- **[2026-11-16 | S2-12 首批种子]**
  - **进度**：S2-12 首批 48 道主题重建种子（36 选择、10 推演、2 指针）和四类数据契约已录入；来源逐题标注，教材原题对应未核验。6 项种子测试与计划指定 6 项前三章联合断言通过，flutter analyze 无问题；本次纯数据/测试变更未重复 Windows 构建。20 道算法设计种子待录入，S2-12 未完成，Stage 2 保持 11/12。
  - **范围**：新建四类习题模型、ch1/ch2/ch3_quiz_seed.dart、quiz_catalog.dart；题库界面仍归 Stage 6。
  - **下一棒**：补 20 道算法设计种子；来源/题量问题及覆盖清单见 [QUIZ_SEED_COVERAGE.md](QUIZ_SEED_COVERAGE.md)。

- **[2026-11-16 | S2-12 第 2 章设计题]**
  - **进度**：第 2 章 10 道算法设计题已录入，包含类 C 参考/2～4 处填空、可执行 Dart 翻译及每题六组数据。60 组参考执行、6 项种子测试和五个相关文件静态分析全部通过。题库现为 58 条；第 3 章 10 道设计题、教材来源与题量口径仍待处理，因此 Stage 2 保持 11/12。C 参考未独立编译，本轮未改 UI，不重复 Windows 构建。
  - **下一棒**：Ch3 十道设计题，更新覆盖记录；Stage 6 交互判题单独实施。

- **[2026-11-16 | 原题口径确认与暂停]**
  - 用户已确认必须逐题对应教材原题，暂不补写缺失题干。停止主题重建；现有 58 题仅保留为待核对/替换草稿，不计原题覆盖，已核验原题对应数为 0。第 3 章新设计题未写入文件。S2-12 待实际原题材料，Stage 2 保持 11/12。按用户要求，本轮收尾后暂停整个开发目标，等待恢复指令。
  - 本条取代前述“下一棒补重建题”的建议；恢复 S2-12 前先取得并核对教材原题。

### 2026-11-18 · S3-01
第四章课程目录已接入 BF/KMP 双轨工作台，支持一基下标、失配回溯、查表滑动、前缀高亮、预设和编辑双串。教材示例在两轨均返回 6。三项算法测试覆盖标准表、指针及 200 组短串配置，另两项组件测试从目录进入并验证输入、切换和回退。相关静态分析与 Windows Debug 构建通过。窗口显示由组件测试验证，尚未做本轮原生窗口目视检查。

### 2026-11-18 · S3-02
递推显微镜与实际匹配共用制表过程。前缀绿框、后缀蓝框随游标移动，未计算的槽显示为点，失配回退与 nextval 继承分别成帧。环串模式保留原环、展开和倍增快照，再逐一截取全部 m 个窗口执行 KMP，并保留每个窗口在主串中的首个位置（0 表示未匹配）。
abaabcac、aaaab 的 next/nextval 基准、已填表项和每帧前后缀内容通过核对，环串测试覆盖各旋转命中、缺失、重复、空串。390 与 1360 宽度从课程目录进入并切换三种模式。

### 2026-11-18 · S3-03
新增第 4 章「数组与矩阵」。可编辑 1～5 行列、1～3 层、基址和元素字节数。点选单元格按选定存储顺序扫过前置元素并连到地址槽。对称矩阵映射到下三角，三角矩阵和三对角矩阵分别保留公共常数槽和零槽。稀疏矩阵支持编辑按行序排列的三元组，逐帧显示 num、初始起点、cpot、读写与最终转置表。步数对比统一按检查原表项计数，快速法另需按列计算起点。
8 项课程测试通过，含 3D 双顺序扫描、1～5 阶全部压缩坐标、空列/全零/负值转置与四尺寸工作台真实点选、编辑、回退。相关静态分析通过，Windows Debug 构建通过。二维公式展示简化后另通过 4 项领域测试。本轮未复核原生窗口。

### 2026-11-18 · S3-04
广义表课程支持可选名称赋值、原子、空表及括号嵌套，教学输入上限 256 个 UTF-16 码元。解析树逐节点求深度，表长只统计直接元素。用户可以连续取头取尾、退回历史帧后改选操作、切换头尾链表和扩展线性链表。每个存储节点的 tag、数据和链接可在检查器查看。头尾链表以 NULL 表示空表，扩展线性链表保留空子表节点。
测试通过两种存储图的指针独立还原每一步逻辑值。另验证示例深度与长度、错误输入、原子与空表边界、320 宽 1.7 倍字号、990 与 1360 宽的实际组件交互。6 项课程测试、相关静态分析和 Windows Debug 构建通过。本轮未做原生窗口目视检查。

## 2026-11-18 · S2-12 教材原页核对

据第二版教材书页 16～18、51～53、83～86，前三章分别有 16、25、25 项习题。第 1 章 5(1)～(6) 已录入，逐题标注书页、PDF 页与编号，答案和解析由项目编写。正式目录累计 6/66。旧稿 58 道继续单列，Stage 2 为 11/12。详见 [题库来源与覆盖](QUIZ_SEED_COVERAGE.md)。

第 1 章习题已全部录入（16/16），含四道简答及关系图、六道选择及六段原始复杂度程序。前三章累计 16/66。

第 2 章书页 51～53 的 15 道选择题已入库，前三章累计 31/66。第 2 章 10 道设计题仍待按原页核对。

第 2 章设计题 2(1)～(10) 已按书页 53 录入。第 2 章 25/25，前三章 41/66。每题包含 2～4 个类 C 填空及 6 个项目用例。10 份 Dart 参考与 MSVC 编译的 C 参考各通过相同的 60 个用例，原生检查包含结点身份、双向链接与被弃置结点的释放。

第 3 章 1(1)～(15) 已按书页 83～85 录入，正式题库累计 56/66。剩余 10 项均为第 3 章算法设计题，S2-12 保持未勾选。

## 2026-11-18 · S2-12 完成

前三章正式题库共 66 项，其中简答 4 项、选择 36 项、复杂度分析 6 项、算法设计 20 项。第 3 章最后 10 项已按书页 85～86 录入。图 3.17 随题重绘，四个 I/O 序列、后缀例串的分隔疑点、Ack(2,1) 的递归展开均有记录。第 3 章 10 份 C 参考通过 MSVC 编译并运行 60 个用例，对应 Dart 参考也通过 60 个用例。章节联合测试覆盖完整题号及规格指定的六项算法断言。Stage 2 已达 12/12，下一项为 S3-06。

## 2026-11-18 · Windows Release 终验

Stage 0～6 共 71 项已完成。八章共 33 门课程、195 项逐页对应教材的习题。设置页支持八表备份合并或覆盖、课程数据集管理、三种尺寸预览。408 项测试通过，Windows Release 已启动、响应并正常关闭。Android 和 macOS 已按静态清单复核。详细结果见 [实施记录](../progress.md)。
