# 03 — 确定性追踪虚拟机 (`TraceVM`)、60/120fps 混合画布与三语代码调试器（Stage 1）

> **关联阶段**：Stage 1（`[S1-01]` ～ `[S1-10]`）  
> **核心职责**：构建全书 46+ 个算法共用的底层物理渲染与逐行调试引擎。严禁在具体章节业务中手写 `AnimationController` 或 `Future.delayed` 硬编码不可逆动画。

---

## 一、核心引擎架构解答（Engine Q&A）

### Q1：如何实现零漂移的「单步前进、时光倒流回退（`Step Back`）、`0.25x~4x` 变速、断点暂停与任意进度条拖拽」？
- **解答**：采用 **「纯函数确定性执行 → 生成不可变 `TraceTimeline` 帧数组 → 双帧场景图物理插值（`SceneInterpolator`）」** 架构。
  1. 当用户选择算法或输入测试数据（如向单链表第 3 位插入 `'X'`），`AlgorithmModule.generateTrace(input)` 在 **< 2ms** 内在内存中运行完整个算法，利用 `TraceBuilder` 录制出完整的不可变快照序列 `List<TraceFrame> frames`。
  2. `PlaybackController` 仅维护一个标量状态 `(int frameIndex, double subProgress /* 0.0..1.0 */, double speed, bool isPlaying, Set<int> breakpoints)`。
  3. 无论用户点击 `Step Back` 倒退回任意一步，还是把进度条直接拉到第 18 帧，渲染器只需以 `SceneInterpolator.lerp(frames[k], frames[k+1], t)` 纯函数渲染画面。彻底杜绝「倒退时指针/数组状态残留错乱」问题！

### Q2：120Hz 高刷屏下如何确保二叉树重构、图松弛与 4 路排序同屏竞速绝对不掉帧？
- **解答**：贯彻 **「底层几何走批处理画笔，前景节点走独立合成层」** 的混合渲染策略：
  1. **`PointerEdgePainter` (`CustomPainter`)**：只负责绘制背景对齐网格、阴影区块、贝塞尔曲线指针弧线、树边、线索虚线与分组拱线。**铁律：严禁在 `paint(Canvas, Size)` 内未缓存地循环 `TextPainter.layout()`**，边权文字通过预计算缓存或限制只在变化时重绘（`shouldRepaint` 精确比对帧引用）。
  2. **`AnimatedNodeLayer` (Stack + `Positioned` + `RepaintBoundary`)**：每个数据节点、数组槽位、树节点渲染为轻量化 Widget，外层套用 `RepaintBoundary`，利用 `TweenAnimationBuilder` / `Ticker` 驱动的坐标与圆角形变直接由 Skia/Impeller 硬件纹理平移合成。
  3. **排序数组大规模降噪**：当排序竞速模式元素个数 `n > 24` 时，自动从「详细带数值方块槽」切换为「高密度彩色柱状条（`BarMode`）」，保持百帧丝滑对比。

### Q3：严蔚敏教材混用 `0-indexed` 与 `1-indexed`（含 `[0]` 监视哨/枢轴暂存单元），引擎如何统一渲染且精准传达教材原意？
- **解答**：这是学习严蔚敏教材最容易混淆的细节，引擎必须在数据结构层面显式区分并可视化：

| 数据结构 / 算法 | 下标起始 | `[0]` 号存储单元的教材专属语义 | 引擎可视化渲染规范 |
| :--- | :---: | :--- | :--- |
| 顺序表 `SqList.elem[]` (第 2 章) | **`0-indexed`** | 存储第 1 个正式数据元素 `a₁` | 首个槽位上方标 `[0]`，逻辑位序标 `位序 1`（双下标对照！） |
| 顺序定长串 `SString ch[]` (第 4 章) | **`1-indexed`** | `ch[0]` 闲置不用或存放串长（教材算法 4.1～4.5 按 `1..length` 处理） | 最左侧 `[0]` 槽渲染为紫罗兰色 `S[0]: len` 只读胶囊槽 |
| 哈夫曼静态表 `HT[1..2n-1]` (第 5 章) | **`1-indexed`** | 约定 `0` 代表「空指针/无双亲或无孩子」 | 表格从行号 `1` 开始，指针值为 `0` 自动显示为 `∅ (0)` |
| 监视哨顺序查找 `ST.R[1..length]` (第 7 章) | **`1-indexed`** | **`R[0]` 为监视哨（Sentinel）**，查找前写入 `ST.R[0].key = key` | 最左侧独立隔出带虚线紫罗兰外框的 `[0] 哨兵` 槽位 |
| 内排序表 `L.r[1..length]` (第 8 章) | **`1-indexed`** | **`r[0]` 为监视哨或快排枢轴暂存单元** | 插入排序/快排执行到 `L.r[0] = L.r[i]` 时，原元素**平滑飞跃停靠到 `[0] 暂存区`** |

---

## 二、核心追踪与场景模型定义 (`lib/models/trace_model.dart`)

> 所有类均使用 `@freezed` 不可变生成，保证跨帧比对、JSON 导出测试集及 Riverpod `select` 高效无副作用。

```dart
@freezed
sealed class TraceTimeline with _$TraceTimeline {
  const factory TraceTimeline({
    required String moduleId,
    required String inputSummary,
    required List<TraceFrame> frames,
    required Map<CodeLang, List<String>> codeLines, // 三语代码按行切分，1-indexed 行号对应 frames
  }) = _TraceTimeline;
}

@freezed
sealed class TraceFrame with _$TraceFrame {
  const factory TraceFrame({
    required int stepIndex,
    required String phaseTitle,                     // 简短阶段标题，如 "第 2 趟 · 枢轴左扫"
    required String explanation,                    // 教材原理解说（中文）
    required Map<CodeLang, List<int>> activeLines,  // 三种语言当前高亮行号列表（1-based）
    @Default({}) Map<String, String> inlineVars,    // 行尾变量胶囊: {"i": "3", "p": "0x1040"}
    required SceneSnapshot scene,
    @Default([]) List<StackActivationRecord> callStack, // 递归/函数调用工作栈
    required ComplexityMetrics metrics,
    @Default(false) bool isKeyMilestone,            // 关键里程碑（如一趟结束），用于进度条刻度点与 Step Over
    @Default(false) bool isErrorState,              // 是否触发 ERROR / OVERFLOW / 成环警告
  }) = _TraceFrame;
}

@freezed
sealed class SceneSnapshot with _$SceneSnapshot {
  const factory SceneSnapshot({
    @Default(SceneLayoutMode.freeCanvas) SceneLayoutMode layoutMode,
    @Default([]) List<SceneNode> nodes,
    @Default([]) List<SceneEdge> edges,
    @Default([]) List<PointerBadge> pointers,
    @Default([]) List<AuxTableSnapshot> auxTables,
    @Default([]) List<SceneZoneOverlay> zones,      // 区域阴影/割集虚线框（如有序区、U/V-U、当前查找区间）
  }) = _SceneSnapshot;
}

@freezed
sealed class SceneNode with _$SceneNode {
  const factory SceneNode({
    required String id,               // 全局稳定 ID（用于跨帧物理位置/颜色插值匹配！）
    required String label,            // 主显示值，如 "49" 或 "49*"
    required double x,                // 逻辑画布归一化/虚拟坐标 X
    required double y,                // 逻辑画布虚拟坐标 Y
    @Default(NodeShape.roundedRect) NodeShape shape, // rect / circle / arraySlot / linkedCell / bTreeBox / bucket
    @Default(NodeVisualState.normal) NodeVisualState visualState,
    String? indexBadge,               // 左上角槽位下标，如 "[0]", "[3]"
    String? logicBadge,               // 右上角附注，如 "BF=+2", "ve=4/vl=6", "LTag=1"
    String? memoryAddress,            // 链式节点的模拟十六进制地址，如 "0x1080"
    @Default(false) bool isZeroSentinelSlot,
    @Default(false) bool isOrphanLeak,// 断链不可达内存泄漏高亮标记
    @Default(1.0) double opacity,
    @Default(1.0) double scale,
    String? groupTag,                 // 希尔排序增量组号、Kruskal连通分量色组
  }) = _SceneNode;
}

@freezed
sealed class SceneEdge with _$SceneEdge {
  const factory SceneEdge({
    required String id,               // 边稳定 ID（如 "edge_nodeA_next" 或 "u_v"）
    required String fromNodeId,
    required String toNodeId,         // 支持指向特殊常量 "_NULL_" 渲染接地符号 ⊥
    @Default(EdgePort.auto) EdgePort fromPort, // next / prior / lchild / rchild / center
    @Default(EdgeStyle.solidArrow) EdgeStyle style, // solidArrow / dashedThread / undirected / shellArc / swapArc
    @Default(NodeVisualState.normal) NodeVisualState visualState,
    String? weightLabel,
    @Default(0.0) double curvature,   // 0 直线，正负为贝塞尔弧弯曲度（避免双向弧或线索重合并遮挡）
    @Default(1.0) double drawProgress,// 0.0..1.0 控制连线生长动画
  }) = _SceneEdge;
}
```

### `TraceBuilder` 链式录制 DSL 设计 (`lib/engine/vm/trace_builder.dart`)
为大幅降低第 1～8 章 46+ 个模块的代码冗余，设计直观的录制器 DSL：
```dart
class TraceBuilder {
  TraceBuilder({required this.moduleId, required this.inputSummary, required this.codeLines});
  // 自动累加并继承上一步的 metrics 与 scene，只需声明本步增量与代码映射
  void step({
    required String title,
    required String explain,
    List<int> cLikeLines = const [],
    List<int> c99Lines = const [],
    List<int> dartLines = const [],
    Map<String, String> vars = const {},
    required SceneSnapshot scene,
    List<StackActivationRecord>? callStack,
    int deltaCompare = 0,
    int deltaMove = 0,
    bool milestone = false,
    bool error = false,
  });
}
```
同时 `AlgorithmModule<TInput>` 接口强制要求所有模块实现：
- `ValidationResult validateInput(String raw)`（返回具体错误提示，如 `"第 5 项系数格式非法"` 或 `"B-树阶数 m 必须在 3..6 之间"`）；
- `List<PresetDataset<TInput>> get presets`（至少含「教材原题数据」、「常规数据」、「边界极限数据」3 组预设）；
- `TraceTimeline generateTrace(TInput input)`（无副作用纯函数）。

---

## 三、四大经典几何布局与物理插值算法规范 (`lib/engine/layout/`)

### 3.1 线性表、哨兵槽、双栈与循环队列布局 (`linear_memory_layout.dart`)
1. **一维连续数组与 1-indexed 哨兵隔离**：默认槽宽 `56dp`、间距 `8dp`；若 `hasSentinelZero == true`，`[0]` 号槽与 `[1]` 号槽之间额外拉大至 `24dp` 间隙并绘制一条纵向分隔虚线与 `监视哨/枢轴暂存` 标题头。
2. **共享空间双栈 (`DblStack`)**：`[0..m-1]` 水平槽位中，`top[0]` 从左向右生长（默认从 `-1` 起始），`top[1]` 从右向左生长（`m` 起始），二者相遇 `top[0] + 1 == top[1]` 时中间缝隙闪烁红色 `满栈告警`。
3. **循环队列极坐标圆盘视图（防反向大绕圈插值解法）**：
   - 设容量为 $M = \text{MAXQSIZE}$，第 $i$ 个扇区角度 $\theta_i = -\frac{\pi}{2} + \frac{2\pi i}{M}$。
   - **关键算法解答**：当指针 `rear` 从 `M-1` 绕回到 `0` 时，直接线性插值角度会从 `315°` 逆向甩一整圈回到 `0°`。必须在 `SceneInterpolator` 中采用**最短正方向圆弧插值**（队列指针恒顺时针推进）：
     $$\Delta\theta = ((\theta_{\text{next}} - \theta_{\text{prev}}) \bmod 2\pi + 2\pi) \bmod 2\pi \quad (\text{回退倒放时反向取负})$$
   - 少用一空间判满时，最后一个空闲挡位绘制斜线阴影标记为 `(rear+1)%M == front 留空防冲突位`。

### 3.2 元素交换「对偶抛物弧线」跃迁算法
当帧 `k` 与帧 `k+1` 检测到两个节点（如 `nodeA` 与 `nodeB`）发生位置交换（`posA_new == posB_old` 且 `posB_new == posA_old`）或长距插入移位时：
- **公式**：设 `t ∈ [0, 1]`（经 `M3eSprings.standardSpatial` 驱动）：
  $$\text{arch}(t) = \sin(\pi \cdot t) \times h_{\text{arc}}, \quad h_{\text{arc}} = \min(56, 0.25 \cdot |x_B - x_A| + 18)$$
- 左往右飞的元素取负法线向上抛跃（$y(t) = y_0 - \text{arch}(t)$），右往左飞的元素取正法线向下抛跃（$y(t) = y_0 + \text{arch}(t)$），彻底避免二者在正中心穿透重叠！

### 3.3 链表指针重连动画与孤岛断链检测
- **指针端口精准坐标**：链式节点绘制为三段或二段矩形 `[prior | data | next]`，输出端点位于 `next` 格正中，输入端点位于目标节点左侧正中（`⊥` 表示 `NULL` 接地符号）。
- **断链/内存泄漏静态可达性扫描器 (`detectMemoryLeaks`)**：每次构建链表快照时，自动执行 BFS 从所有命名外指针（`L, La, Lb, pa, pb, p, q, s`）沿着节点 `next/lchild/rchild` 遍历可达集合；任何**未被标记为 `deleted` 且不在可达集合内**的节点立刻置 `isOrphanLeak = true`，在画布上高亮为红色虚线闪框并提示 `"⚠️ 警告：该节点指针已丢失，发生内存泄漏！"`（专用于第 2 章算法 2.9 误序操作反例演示）。

### 3.4 树与图布局 (`tree_reingold_layout.dart` & `graph_layout_engine.dart`)
1. **改良 `Reingold-Tilford` 树/森林/B-树布局**：
   - 自动适应不同宽度节点（普通二叉树节点 `48×48` 圆 vs 线索五元组节点 `120×44` vs `m` 阶 B-树可变宽多关键字盒子 `n*36 + 28`）。
   - 子树轮廓（Contour）碰撞检测保证同层最小间距 `24dp`，且父节点恒居其直接孩子水平重心。由于每个树节点携带全局稳定 `SceneNode.id`（即节点内存实例 ID），AVL 旋转或 B-树分裂前后计算出的新旧 `(x, y)` 经过弹簧插值后，整个子树会自动呈现流畅优雅的「刚体物理滑动旋转」效果！
2. **图布局引擎（双模协同）**：
   - 所有教材原例图（如第 6 章的 $G_1..G_6$、表 6.4 有向网、AOE 工程网）内置**经过人工美化排版的教科书预设标准化坐标 (`[0..1, 0..1]`)**，打开即刻清晰美观、边权不遮挡。
   - 用户手动加点加边或生成随机六度空间图时，运行后台 **Fruchterman-Reingold 力导向迭代（60～100 步预设收敛，非动画实时抖动）** 自动分散节点，且支持鼠标/手指任意拖拽固定单个顶点坐标。

---

## 四、三语代码调试器与播放控制栏规格 (`lib/engine/debugger/`)

1. **`CodeDebuggerPane`**：
   - 顶部紧凑 `SegmentedButton` 切换：`类C (教材原版)` / `C99` / `Dart`；语言切换不改变当前执行的逻辑步骤（因为 `TraceFrame.activeLines` 同时维护了三语行号映射）。
   - 使用 `re_highlight` 预编译语法高亮 `TextSpan` 列表并按 `codeLines` 缓存，逐行构建 `ListView.builder`。
   - 左侧装订线宽度 `42dp`，点击任意有效行号切换红点断点（若算法在自动播放中命中断点行，`PlaybackController` 立即停在该帧并闪烁提示 `"● 命中第 X 行断点"`）。
   - 当前执行行整行铺设 `DsSemanticColors.codeActiveLineGlow` 圆角光带；行末（空间不足时折行悬浮在下方）渲染 `Inline Variable Pill`（例如 `mid = 5`、`a[mid] = 56 > key(21)`）。
2. **`CallStackInspector`（递归工作栈 + 递归树）**：
   - 栈帧卡片自底向上堆叠，每张卡片按严蔚敏教材第 3.3 节格式显示：函数名 + 实参快照 + 局部变量 + **返回位置标号（如 `RetLoc1`、`Main`）**。
   - 切换页签可查看随执行动态生长高亮的**递归调用树**（适用于汉诺塔、快排、二叉树递归遍历、Floyd 路径递归回溯）。
3. **`PlaybackTransportBar`（M3E 悬浮播放控制台）**：
   - 组件从左到右：`[⏮ 复位] [⏪ 上一步 (Step Back)] [▶/⏸ 主控变形胶囊] [⏩ 下一步 (Step Into)] [⏭ 跳至下一里程碑 (Step Over)]` + 中间关键帧时间轴进度条（里程碑帧处绘制菱形小标记供一键吸附）+ 右侧 `[0.25x ~ 4x 倍速选择器] [自动跟随镜头开关]`。

---

## 五、本模块子任务同步勾选清单 (`[S1-01]` ～ `[S1-10]`)

- [x] `[S1-01]` 定义 `lib/models/trace_model.dart` 完整 Freezed 模型族并生成 `.freezed.dart / .g.dart`
- [x] `[S1-02]` 实现 `AlgorithmModule<TInput>` 接口、`TraceBuilder` 链式录制 DSL 与复杂度统计器
- [x] `[S1-03]` 实现 `PlaybackController` Riverpod 状态机（支持正倒放、StepBack、StepOverMilestone、Seek、断点自动暂停、倍速调节）
- [x] `[S1-04]` 实现 `SceneInterpolator` 插值器与链表可达性内存泄漏检测器 (`detectMemoryLeaks`)
- [x] `[S1-05]` 实现线性内存条（含 `[0]` 哨兵专槽）、极坐标环状队列最短弧旋转插值与对偶抛物弧线交换计算器
- [x] `[S1-06]` 实现改良 `Reingold-Tilford` 树/B-树可变宽布局器与图预设坐标/力导向/手动 Pin 布局器
- [x] `[S1-07]` 实现 `DsStageCanvas`（InteractiveViewer + 触控板 `PointerPanZoom` + `48dp` 触控命中）、`PointerEdgePainter` 与 `AnimatedNodeLayer`
- [x] `[S1-08]` 实现 `CodeDebuggerPane`（三语切换、`re_highlight` 缓存、断点红点、行内变量胶囊）
- [x] `[S1-09]` 实现 `CallStackInspector`（含 `RetLoc` 与递归树联动）、`MemoryTableInspector` 与 `PlaybackTransportBar`
- [x] `[S1-10]` 编写并跑通 `test/engine/trace_vm_test.dart` 与 `test/engine/playback_widget_test.dart`（测试内容：时光倒流帧状态一致性、环状角度最短弧插值无反向旋转、断点精准暂停、100 节点树布局零重叠）

## 实施记录（2026-11-15）

S1-01～04 已落地并通过核心回归。引擎录制和加载边界复制所有嵌套可变集合，Freezed 模型提供只读访问与值比较。AlgorithmModule 的泛型预设命名为 AlgorithmPreset<T>，避免与数据库使用的非泛型 PresetDataset 混淆。链表模块在 TraceBuilder 构造时启用 trackLinkedOwnership，后续每次录制自动扫描；非链式场景不误判为泄漏。deleted 结点不参与活内存可达性，prior/线索/无向边不作为所有权边。

实验室页面是引擎预览，采用基础几何插值与小画布，尚不是 S1-07～09 的完整专用组件；后续补充弹簧空间轨迹、环队列/交换轨迹、完整绘制与调试器。两个 engine 测试文件已存在并通过，但 S1-10 中环状角度与百结点树验证尚未实现，保持未完成。<2ms 生成与 120fps 目标未做性能测量。

### S1-05 已实现（2026-11-15）

- `linear_memory_layout.dart`：默认 56×48 槽位、8dp 间隙；哨兵与 [1] 总间隙 24dp、分隔虚线与标题，数组下标/逻辑位序分开；共享双栈验证 -1/m 初值、相遇判满与重叠拒绝。
- `circular_queue_layout.dart`：θ=-π/2+2πi/M；轨道保留圆心、半径与角度。正向采用 [0,2π) 的顺时针模差，不取可能逆向的带符号最短路径；倒放对原始帧对递减 t。满队列以 rear 槽为唯一留空位，斜线标识。
- `swap_trajectory.dart`：稳定 ID 同排交换自动走上下双弧，弧高 min(56,0.25×|dx|+18)，端点精确；线性 moving 结点支持长距插入。空间弹簧与透明度独立，环指针保持单调角度。
- 实验室可切换 7 个布局样例；新增几何/反向回放/JSON 与两种尺寸交互回归。S1-10 的环队列角度验证已完成；百结点树仍待 S1-06。

### S1-06 与 S1-10 验证补齐（2026-11-15）

- TreeReingoldLayout 按有序子树逐层合并左右轮廓，采用实际结点尺寸；B-树盒宽 keys.length×36+28。根列表可定义森林顺序，二叉端口保证左/右顺序；多父/结构环/不完整根集合会被拒绝，线索边不参与结构遍历。
- GraphLayoutEngine 提供标准化预设、画布中心坐标 Pin、确定性 FR 与 Isolate 后台入口。节点受画布边界约束；固定点精确保留。输入场景和 pins 在后台入口复制，视图用请求序号抛弃过期结果。力导向不宣称任意图全局最少交叉或标签永不冲突。
- 当前核实预设为附件 06 的表 6.4 六顶点八边；G1..G6/AOE 完整教材数据留给 S4。新增五个树图预览，不冒充课程完成。
- S1-10 要求的百结点树验证在 tree_graph_layout_test.dart 完成；既有 trace_vm_test.dart、layout_test.dart、playback_widget_test.dart 覆盖回退、环角与断点，tree_graph_widget_test.dart 补充拖动/异步结果。测试按职责分文件，S1-10 的已列验收内容现已齐全。

### S1-07 已实现（2026-11-16）

- DsStageCanvas 使用 InteractiveViewer 变换表面与滚轮焦点缩放；专用 Scale/PointerPanZoom 识别器提前取得画布手势，解决外层 ListView 抢占慢速纵向平移。触控板累计 pan/scale 每次只应用一次，滚轮信号由 resolver 消费。
- 镜头矩阵独立于 TraceFrame，缩放为 uniform x/y/z；适应画布、缩放按钮、鼠标/单指平移、双指捏合与触控板平移/缩放。切换样例或窗口尺寸改变自动适应；同一数据集播放、seek、图重排保持镜头。自动跟随开关留在 S1-09 播放控制台。
- hitTestStageNode 在屏幕坐标扩展到至少 48×48dp；可见边界优先，再按中心距离和绘制顺序消歧。图拖动通过逆矩阵回到逻辑场景，保留抓取偏移；两指/触控板不 Pin 顶点。隐藏/删除节点不命中。
- PointerEdgePainter 批绘网格、区域边框/阴影线、二次贝塞尔箭头、树边、线索虚线、分组弧与空指针；边权由 Widget 覆盖层承载，paint 无 TextPainter.layout。shouldRepaint 比较快照引用/颜色/告警脉冲。
- AnimatedNodeLayer 使用稳定 ID 的 Positioned + RepaintBoundary；直接消费单一 TraceVM Ticker 的插值坐标/缩放/透明度，保持 seek/倒放确定性，不另加节点位置计时器。支持节点状态、哨兵、固定标记与选择数值。排序入口显式启用且 n>24 时为 BarMode，32 元素样例可回退检查。
- 12 项新增画布回归覆盖命中、滚轮焦点/上下限、原生触控板与兼容滚动、渐进纵向手势归属、双指、图拖动逆变换、镜头生命周期、柱状阈值和边端口；相关测试共 32 项通过。原生窗口已检查鼠标操作；物理触控板/触屏与 120fps 未测。

### S1-08 已实现（2026-11-16）

- CodeDebuggerPane 用 SegmentedButton 切换类 C/C99/Dart，沿用 TraceFrame.activeLines 映射和 PlaybackController，不改变当前帧/子进度。
- CodeHighlightCache 使用已有 re_highlight 0.0.3，对整份源码一次解析、再按换行拆分 TextSpan，保留跨行注释/空行/原文；每个组件按语言仅存一个源码与 ColorScheme 条目，帧推进复用相同 TextSpan，源码/主题变化才重编译。
- 逐行 ListView.builder；42dp 装订线、48dp 行高点击区、行号与红点共存。命中提示单次 600ms 脉冲，减少动画设置关闭脉冲；切换语言仍显示原断点所属语言。
- 活动行采用 DsSemanticColors.codeActiveLineGlow；inlineVars 为整帧快照，统一放在当前语言最后一条活动行后，仅显示一次并自动换行；移除实验说明区重复变量。
- 新增 7 项测试覆盖跨行语法、源码/主题缓存、三语映射、断点、变量回退、280dp/1.7 倍文字及空代码。与既有播放/图交互共 15 项通过；静态检查与 Windows Debug 成功，实际窗口断点/语言切换已验证。

### S1-09 已实现（2026-11-16）

- CallTreeProjection 按当前帧前缀、稳定调用 ID 和 parentCallId 构建递归树；已返回调用保留最近快照，回退不会暴露未来调用。CallStackInspector 栈顶向上、卡片包含实参/局部/RetLoc，选择与树联动。
- MemoryTableInspector 显示结点地址/下标/状态、命名指针及边、辅助表；横纵滚动适应窄屏，当前行高亮随快照回退。
- PlaybackTransportBar 固定在预览底部，包含正倒放、步进/复位/末帧、里程碑跳转、0.25～4 倍速与跟随镜头。里程碑按真实帧比例绘制并提供 48dp 点击/语义区域；单帧/空轨迹禁用无效操作。
- 自动镜头保留用户缩放，仅在活动区域越界时平移或缩小，留出 24dp 边距；没有活动节点时跟随外部指针目标。手动操作立即退出自动跟随。
- Sum(n) 引擎样例展示调用/返回，基例没有 child 局部；不计入教材课程或学习记录。32 项相关测试通过，底部布局调整后 16 项、最后基例修正后 8 项重跑通过；静态检查与 Windows Debug 成功。原生窗口确认树/表联动、里程碑跳转、回退清除未来调用和基例变量。
- Stage 1 所列 10 项组件完成；02 的完整三断点工作台仍待接入，<2ms/120fps 与物理触控设备未实测。

### S1-07 续接复核（2026-11-16）

S1-07 功能已由 f3f0dce 提交，当前工作台继续复用混合画布。重新运行 stage_canvas_test.dart 与 tree_graph_widget_test.dart，共 16 项通过，覆盖屏幕命中、滚轮焦点、触控板事件、双指缩放、外层滚动竞争、镜头保持和图结点拖动。本轮无功能代码变更。此结果为组件/合成输入验证；物理触控板、触屏与 <2ms/120fps 仍未实测。
