# 02 — UI 设计系统：Material Design 3 Expressive × FlClash（Stage 0 下）

> **关联阶段**：Stage 0（`[S0-07]` ～ `[S0-12]`）  
> **架构来源**：直接吸收开源项目 `chen08209/FlClash` 的 `theme.dart`、`scaffold.dart`、`dashboard.dart` 与 `application.dart` 布局工程经验，全面注入 Material Design 3 Expressive 物理动效与连续超椭圆形状语言。

---

## 一、动态色彩系统与教材语义色扩展 (`lib/providers/theme_provider.dart`)

### 1.1 FlClash 同源 `DynamicColorSeeds` 与 64 容量 LRU 缓存
为了在桌面端拖拽调整主题滑块、切换夜间模式或触发高亮动画时避免重复计算 HCT 调色板造成掉帧，复刻 FlClash `lib/providers/state/theme.dart` 模式：
- **三源种子结构**：
  ```dart
  typedef DynamicColorSeeds = ({
    Color? lightSeed,
    Color? darkSeed,
    Color accentColor,
  });
  ```
- **8 套内置种子调色板（`ThemePalettePreset`）**：
  1. `systemDynamic`：通过 `DynamicColorBuilder` 自动提取 Windows DWM / Android Monet / macOS Accent 色。
  2. `textbookDualTone`（**默认首推：教材双色版**）：致敬人民邮电出版社《数据结构（第2版）》双色排版——主色 **黛青 (`#006874`)**，第三强调色覆盖为 **朱砂暖橙 (`#D84315`)**，用于高亮指针与重点语句，兼顾护眼与学科辨识度。
  3. `clashBlue`（`#1E65F3`，FlClash 经典科技蓝）。
  4. `violetExpressive`（`#6750A4`，M3 Expressive 标准紫罗兰）。
  5. `emeraldForest`（`#006C4C`，柔和护眼翠绿）。
  6. `amberGold`（`#8C5000`，温暖琥珀）。
  7. `roseCrimson`（`#9C4146`，胭脂红）。
  8. `monochrome`（极简中性灰阶）。
- **Pure Black 纯黑模式扩展 (`ColorScheme.toPureBlack(bool enabled)`)**：
  在暗色模式下开启 `pureBlack` 时，将 `surface` 与 `surfaceContainerLowest` 设为 `#000000`，卡片层级采用 `surfaceContainerLow (#0D0D10)` 并配 `1px` `outlineVariant.withValues(alpha: 0.35)` 精细描边，兼顾 OLED 节电与桌面暗色质感。

### 1.2 算法语义色扩展 `DsSemanticColors` (`ThemeExtension`)
数据结构可视化严禁在节点里写死 `Colors.red` / `Colors.green`（会与动态取色和暗黑模式冲突）。统一定义 `DsSemanticColors` 随 `ThemeData.extensions` 注入：

| 属性字段 | 教学语义用途 | 明亮模式参考色值 | 暗色模式参考色值 |
| :--- | :--- | :---: | :---: |
| `activePointer` | 当前游标指针 (`p`, `q`, `top`, `front`, `mid`) 徽章与光环 | `#006874` (`primary`) | `#4FD8EB` |
| `comparing` | 正在执行关键字比较的两个元素/分支条件 | `#E65100` (琥珀橙) | `#FFB74D` |
| `comparingContainer` | 比较元素的柔和背景容器填充 | `#FFE0B2` | `#4E342E` |
| `swappingOrMoving` | 正在飞跃交换、元素后移或指针正在重连的弧线 | `#D81B60` (洋红) | `#F48FB1` |
| `sortedOrVisited` | 已归位有序区、已入集合 `S` 或 `visited[v]=true` 节点 | `#2E7D32` (翡翠绿) | `#81C784` |
| `sortedContainer` | 已序元素的背景填充 | `#C8E6C9` | `#1B3B22` |
| `sentinelOrPivot` | 1-indexed 监视哨 `R[0]`、快排枢轴暂存 `r[0]`、链表头节点 | `#6A1B9A` (紫罗兰) | `#CE93D8` |
| `memoryLeakOrError` | 断链丢失的孤岛节点、栈上溢 `OVERFLOW`、拓扑环路死锁告警 | `#BA1A1A` (`error`) | `#FFB4AB` |
| `codeActiveLineGlow` | 代码调试器当前执行行的呼吸光带底色 | `primary.withValues(alpha: 0.14)` | `primary.withValues(alpha: 0.22)` |

---

## 二、Material 3 Expressive 物理弹簧与连续形状系统 (`lib/ui/tokens/`)

### 2.1 双轨物理弹簧规范 (`m3e_springs.dart`)
封装 `motor` 与 `sprung`，所有动画拒绝平庸的线性匀速插值：

| 弹簧名称 | 类型 | 刚度 `stiffness` | 阻尼比 `dampingRatio` | 适用场景 |
| :--- | :---: | :---: | :---: | :--- |
| `M3eSprings.fastSpatial` | 空间位移 | `1400.0` | `0.72` (轻微回弹) | `ElasticPress` 按钮按压缩放、Chip 选中切换、导航胶囊指示器滑移 |
| `M3eSprings.standardSpatial` | 空间位移 | `700.0` | `0.75` (细腻弹性) | 链表插入节点弹开、数组元素平移、AVL 旋转父子换位、B-树分裂、Bento 卡片重排 |
| `M3eSprings.slowSpatial` | 空间位移 | `320.0` | `0.80` (稳重惯性) | 三栏分割面版宽度平滑展开、移动端底部抽屉吸附动画 |
| `M3eSprings.effects` | 视觉属性 | `1200.0` | `1.00` (**临界阻尼无过冲**) | 节点背景高亮染色、代码行渐变、透明度淡入淡出（防止颜色闪烁越界） |

> **无障碍防晕动保护**：提供 `BuildContext.motionScale` 扩展，若 `MediaQuery.disableAnimationsOf(context)` 为 `true`，所有动画时长与弹簧模拟直接 `jumpTo(target)` 瞬时完成。

### 2.2 连续曲率超椭圆形状与 M3E 态变 (`m3e_shapes.dart`)
- **全面启用 Flutter 3.47 原生 `RoundedSuperellipseBorder`**：相比普通 `RoundedRectangleBorder`，连续曲率角在桌面高分屏上能消除直边向圆角过渡的折痕感。
  - 小控件 / 行内变量胶囊：`radius: 10`
  - 中等卡片 (`BentoCard`)：`radius: 20` + 悬浮 `1px` `outlineVariant` 边框
  - 底部悬浮播放栏 / 搜索胶囊：`radius: 28`
- **Expressive Shape Morphing（状态形变规范）**：
  - **主控 Play/Pause 按钮**：暂停状态呈现高饱满全圆胶囊（`BorderRadius.circular(28)`），点击开始播放时伴随 `fastSpatial` 弹簧在 220ms 内形变为温润圆角超方框（`BorderRadius.circular(14)`），给用户极强的状态反馈。
  - **算法分支 Segmented Tab**：未选中分段采用略方的 `radius: 10`，选中态瞬间膨大为 `radius: 999` 胶囊背景。

---

## 三、FlClash 工程壳层与零帧延迟 Bento 仪表盘

### 3.1 `BuildManagerStack` 多端包装栈 (`lib/ui/managers/`)
复刻 FlClash `application.dart` 职责分离思路，由外向内包裹整个路由树：
1. **`WindowHeaderManager`**：
   - Windows 桌面端顶部插入 `40dp` 自定义标题栏（集成 `DragToMoveArea` 拖拽区、应用图标+当前页面面包屑、`Ctrl+K` 快捷搜索触发胶囊按钮、以及自适应主题色的 最小化/最大化/关闭 按钮）。
   - **macOS 预设分支**：左侧预留 `MacTrafficLightInset = 76.0` 安全边距避让原生红绿灯，`DragToMoveArea` 覆盖中间空白区，**绝不绘制 Windows 风格右侧关闭按钮**。
   - **Android 端**：完全透明直通内容区，交由内部 `SafeArea` 配合系统 Edge-to-Edge 状态栏着色渲染。
2. **`ThemeManager`**：监听系统明暗模式及动态强调色变化，同步更新 `flutter_acrylic` 的 Mica 材质明暗调性或 Android `SystemUiOverlayStyle`。
3. **`HotKeyManager`**：通过 `Shortcuts` + `Actions` 统一拦截处理：
   - `Space`：实验室画布播放 / 暂停；
   - `ArrowLeft` / `ArrowRight`：单步时光倒流回退 / 单步前进；
   - `Shift + ArrowRight`：跳至下一里程碑（如一趟排序结束）；
   - `Home` / `End`：重置到首帧 / 跳至终帧；
   - `Ctrl+K`（Windows）/ `Cmd+K`（macOS）：唤醒全局算法/章节/习题模糊检索面板；
   - `Ctrl+F`（Windows）/ `Cmd+F`（macOS）：唤醒 `CommonScaffold` 页内弹簧搜索栏。

### 3.2 FlClash 风格 `CommonScaffold` 与零帧延迟 Bento 仪表盘
1. **复刻 `FlClash` `Scaffold` 的动态搜索体验**：
   - 桌面/平板端点击搜索按钮或按 `Ctrl/Cmd+F` 时，标题栏文字平滑淡出，搜索框以弹簧曲线从按钮位置横向展开填充顶栏；
   - **手机端（Compact）**：在目录/题库长列表页，搜索栏自动沉底停靠在拇指热区作为悬浮 `GooSurface` 胶囊搜索栏（带聚焦时右侧弹出的清除取消圆钮），顶部可叠加横向滚动的可删除过滤标签芯片（`ScaffoldKeyword`）。
2. **Bento 学习总览仪表盘 (`views/dashboard/dashboard_view.dart`) 算法细则**：
   - 直接复刻 `FlClash` `dashboard.dart` 第 1382～1650 行经过实机验证的**零布局抖动公式**：
     - 在 `LayoutBuilder` 回调内用 `constraints.biggest / textScale` 实时判定密度（桌面 `2 列` 或 `4 列`，手机单列滚动），不走首帧后置 `addPostFrameCallback` 测量，彻底根除闪烁；
     - 桌面计算列宽：`double column = math.min((maxWidth - horizontalPad - gap * (cols - 1)) / cols, maxColumnWidth * scale);`
     - 每个卡片独立包裹 **`RepaintBoundary(child: BentoCard(...))`**，确保学习时钟跳动或图表脉冲不影响邻居卡片重绘；
     - **防双层滚动冲突逻辑**：精确累加桌面端上方 3 行固定高度卡片组高度 `rowsHeight`，仅当 `constraints.maxHeight >= rowsHeight + tablesMinHeight` 时才在底部用 `Expanded` 铺开「最近实验记录表 + SM-2 今日待复习错题队列」双分栏列表；窗口矮于阈值时自动平滑降级为单行精简摘要卡。

---

## 四、三断点自适应布局架构 (`AppShell` 与 `LabWorkspaceLayout`)

通过单一真实数据源 `LayoutBreakpoint`（基于窗口宽度 `LayoutBuilder` 动态响应，支持桌面任意拖拽窗口宽度与 Android 折叠屏展开无缝切换）：

| 断点等级 | 宽度区间 | 外层导航壳 (`AppShell`) | 算法实验室三栏排布 (`LabWorkspaceLayout`) |
| :--- | :---: | :--- | :--- |
| **Compact (手机/窄窗口)** | `< 600dp` | M3E 底部 5 项 `NavigationBar`（首页/目录/实验室/评测/设置），尊重底部手势安全区 | **全屏舞台画布**（顶部悬浮 2 行高半透明当前代码微缩条，点击可弹出；底部 `DraggableScrollableSheet` 3 档吸附抽屉 `0.12 / 0.45 / 0.85` 承接完整代码、调用栈与变量表；底部悬浮播放控制条最小按钮热区 `48×48dp`） |
| **Medium (平板/折叠屏/半屏)** | `600dp ～ 1099dp` | 左侧紧凑 `NavigationRail` (`76dp` 宽，支持展开切换) | 上下分栏：**上方 55% 为交互舞台** + **下方 45% 为多标签页切换面板**（`代码调试` / `调用栈与内存表` / `教材原理解析与复杂度`）+ 底部悬浮播放条 |
| **Expanded (桌面宽屏)** | `≥ 1100dp` | 左侧 FlClash 风格半透明侧边栏（展开 `220dp` / 折叠 `72dp`，含章节快捷锚点） | **可拖拽比例分割三栏工作台**（左侧 `55%` 可调宽舞台画布 + 右侧上下分割：右上 `60%` 三语代码与断点调试器，右下 `40%` 递归工作栈/辅助数组/复杂度实时面板；最底部居中悬浮 M3E 胶囊播放控制条） |

---

## 五、本模块子任务同步勾选清单 (`[S0-07]` ～ `[S0-12]`)

- [x] `[S0-07]` 实现 `ThemeProvider`（8 套预设含教材双色版、DynamicColor、64-LRU 缓存、PureBlack）与 `DsSemanticColors` 扩展
- [x] `[S0-08]` 实现 `m3e_springs.dart`、`m3e_shapes.dart`（`RoundedSuperellipseBorder`）、`ElasticPress` 与 `BentoCard`
- [x] `[S0-09]` 实现 `BuildManagerStack`（Win 40dp 标题栏 / Mac 76dp 红绿灯避让 / Android 透明直通 / 全局快捷键 `HotKeyManager`）
- [x] `[S0-10]` 实现 `GoRouter` 路由表、三断点 `AppShell`、`CommonScaffold`（桌面顶栏展开搜索 + 手机沉底胶囊搜索）与 `Ctrl/Cmd+K` 全局检索弹窗
- [x] `[S0-11]` 实现 FlClash 风格 Bento 首页仪表盘骨架（`DashboardView` 占位数据先联调布局算法）及设置页外观实时切换
- [x] `[S0-12]` 编写并跑通 `test/ui/responsive_shell_test.dart`（分别模拟 `390×844` 手机、`800×1100` 平板、`1360×860` 与矮屏 `1280×620` 桌面，断言零 `RenderFlex overflow` 报错）

## 2026-11-15 实施补充

S0-07、S0-08、S0-10、S0-12 完成。弹簧使用 Flutter SpringSimulation 直接实现参数，避免不兼容 Dart 3 的 sprung。S0-09 的播放快捷键尚待引擎；S0-11 首页底部双列表/矮屏摘要未完成，其余首页与设置骨架已可用。Windows 原生窗口已观察，组合键物理输入待手动确认，详见总控日志。

## 2026-11-15 Stage 0 补齐

S0-09/S0-11 已完成。播放键由 HotKeyManager 声明并由 PlaybackActions 限定在活动实验室内分发；编辑框保留原有键盘行为。首页依据实时约束与文字缩放计算高度，在双列表与摘要间切换。两类数据直接来自数据库，具有加载、错误、空状态。

## 2026-11-16 完整实验工作台接入

- [x] Expanded：左侧舞台默认 55%，右侧代码默认 60% 高度、检查器/原理占其余空间；横纵分隔条可拖动，双击复位，最小面板尺寸防止控件被挤没。
- [x] Medium：55% 舞台 + 45% 标签面板，代码/检查器/原理切换；检查器内含调用栈与内存辅助表。
- [x] Compact：舞台铺满可用区，两行半透明当前代码条点击展开完整代码；DraggableScrollableSheet 在 .12/.45/.85 吸附，固定底部播放条不被抽屉遮挡，主要控件 >=48dp。
- LabWorkspaceLayout 共享 AppShell 的 LayoutBreakpointScope；各引擎面板稳定重挂载，语言/断点/播放位置跨断点保留。原理面板消费当前 TraceFrame，教材解析仍随课程开发。
- 紧凑播放条保留常用步进，更多菜单提供复位/末帧/正倒放/倍速/镜头开关；时间轴里程碑按帧比例绘制，松手接近标记时吸附。
- 快速单次鼠标拖动起初无效，已用失败用例定位并改为 DragStartBehavior.down，横纵方向单次鼠标验证通过。分隔条语义同时提供 value/increasedValue/decreasedValue。
- 验证：flutter analyze 无问题；lab_workspace_test、responsive_shell_test、playback_widget_test、tree_graph_widget_test、inspectors_transport_test 共 26 项通过。最后拖动修正后 6 项工作台测试及 Windows Debug（10.1s）通过；纵向单次鼠标断言再次专项通过。
- 实际窗口确认宽屏布局、横向拖动、约 990dp 中宽布局与检查器标签；纵向分栏和 Compact 抽屉由组件测试覆盖。Computer Use 纵向拖动未观察到可判定变化，不将其记录为原生实测通过；Android/macOS 和物理触控设备未测。
