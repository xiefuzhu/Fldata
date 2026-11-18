# 01 — 工程脚手架、技术栈、Drift 数据库与三端平台架构（Stage 0 上）

> **关联阶段**：Stage 0（`[S0-01]` ～ `[S0-06]`）  
> **前置条件**：无（工作区当前仅包含教材 PDF 与 `.doc/` 文件夹）  
> **阅读提示**：本文件负责非 UI 底座架构；主题配色、M3E 弹簧与自适应导航壳层请配合阅读 `02_UI_DESIGN_SYSTEM_M3E_AND_FLCLASH.md`。

---

## 一、核心架构设计解答（Module Q&A）

### Q1：如何在已存在 30.6MB 教材 PDF 的非空目录安全初始化 `windows + android + macos` 三端工程？
- **解答**：Flutter CLI 允许在非空目录执行 `flutter create .`，它只会补充脚手架缺失文件，不会删除已有 `.pdf` 与 `.doc/`。但为了避免误将大体积 PDF 提交到版本库或引起构建资源打包警告，必须在初始化后第一时间更新 `.gitignore`。
- **执行命令**：
  ```powershell
  flutter create --project-name struct_clash --org com.datastructure.prism --platforms=windows,android,macos .
  ```
- **`.gitignore` 增量规则**：
  ```gitignore
  # 教材原文件体积巨大，不纳入代码索引或资产打包，但保留本地文件
  /*.pdf
  # 进度同步文档保留追踪
  !/.doc/
  !/.doc/**
  ```

### Q2：为何桌面窗口化采用 `window_manager + flutter_acrylic`，而不直接复制 FlClash 私有 `plugins/window` C++/Swift 插件？
- **解答**：FlClash 在仓库 `plugins/window/` 下维护了自定义 Win32 C++ 与 macOS Swift 原生消息通道，该插件强耦合其 VPN 托盘/代理核心状态。对于教学软件 `struct_clash`，使用社区成熟的 `window_manager: ^0.7.0` + `flutter_acrylic: ^1.1.4` 即可 100% 复刻 FlClash 的无边框沉浸式标题栏、Windows 11 Mica/Acrylic 侧边栏透光、macOS 标题栏隐藏与窗口宽高持久化记忆，且**彻底避免跨对话手写平台 C++/Swift 胶水代码带来的编译风险**。

### Q3：如何严格约束 UI / Engine-Domain / Data 三层依赖方向，保障全书 46+ 算法毫秒级无头单测？
- **解答**：参考 `Flutter Architecture Best Practices`，确立如下**单向依赖铁律**：
  ```mermaid
  flowchart LR
      UI["UI Layer (lib/views, lib/ui)"] -->|watch / read| Prov["State & Actions (lib/providers)"]
      Prov -->|generateTrace / evaluate| Engine["Domain & TraceVM (lib/engine/vm, lib/curriculum)"]
      Prov -->|CRUD / SM-2| Repo["Repositories (lib/database/repositories)"]
      Repo --> DB["Drift SQLite & Prefs (lib/database)"]
      UI -.->|仅允许只读展示| EngineModels["Immutable Models (lib/models, lib/enum)"]
      Engine --> EngineModels
      Repo --> EngineModels
  ```
  1. **`lib/curriculum/` 与 `lib/engine/vm/` 零 Flutter UI 依赖**：严禁出现 `package:flutter/material.dart` 或 `BuildContext`，仅允许引入 `dart:math`、`dart:collection`、`dart:ui`（仅限纯几何 `Offset`/`Size` 或使用自研 `Vec2`）及 `lib/models/`。如此一来，所有链表/KMP/AVL/Dijkstra/排序跟踪测试都可以在纯 Dart VM 下毫秒级并发跑通。
  2. **`lib/views/` 零数据库直连**：UI 页面不得直接实例化或查询 `AppDatabase`，所有读写必须经过 `lib/providers/`。

---

## 二、`pubspec.yaml`、`build.yaml` 与 `analysis_options.yaml` 完整规格

> 注：所有核心包版本号已按当前 `Flutter 3.47.7 / Dart 3.13.5` 与 `pub.dev` 最新稳定版核对。执行 `flutter pub get` 时若遇到 `build_runner` 跨插件约束微调，可通过 `flutter pub upgrade --major-versions build_runner`（仅限 dev_dependencies）自适应对齐。

```yaml
name: struct_clash
description: 严蔚敏《数据结构（C语言版·第2版）》交互式可视化学习与评测平台
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ^3.10.0
  flutter: ">=3.41.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # 状态管理与不可变数据模型 (对标 FlClash)
  flutter_riverpod: ^3.5.0
  riverpod_annotation: ^4.0.8
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0
  collection: ^1.19.1

  # Material 3 Expressive 视觉、动态取色与物理弹簧
  dynamic_color: ^2.1.0
  material_3_expressive: ^1.2.1
  motor: ^1.1.0
  sprung: ^3.0.1

  # 路由与三端桌面窗口化
  go_router: ^18.1.4
  window_manager: ^0.7.0
  flutter_acrylic: ^1.1.4

  # 本地持久化与备份导入导出 (对标 FlClash Drift 栈)
  drift: ^2.35.4
  drift_flutter: ^0.3.1
  shared_preferences: ^2.5.6
  path_provider: ^2.1.6
  path: ^1.9.1
  file_picker: ^10.3.3

  # 语法高亮与矢量图标
  re_highlight: ^0.0.3
  flutter_svg: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.15
  riverpod_generator: ^4.0.9
  freezed: ^4.0.1
  json_serializable: ^6.14.1
  drift_dev: ^2.35.4

flutter:
  uses-material-design: true
  assets:
    - assets/svg/
    - assets/presets/
  fonts:
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

> **字体降级保护**：若执行阶段无外网下载 `JetBrainsMono-*.ttf`，可临时在 `assets/fonts/` 放置开源字体或将代码面板 `fontFamily` 设为平台等宽回退链 `fontFamilyFallback: ['Cascadia Code', 'Consolas', 'Menlo', 'monospace']`，确保 Windows/macOS/Android 均不因缺失字体文件导致构建失败；有网络条件时优先从 JetBrains GitHub Releases 获取标准 TTF 放入 `assets/fonts/`。

**`build.yaml`**（加速代码生成，缩小扫描作用域）：
```yaml
targets:
  $default:
    builders:
      freezed:
        generate_for:
          include:
            - lib/models/**.dart
      json_serializable:
        generate_for:
          include:
            - lib/models/**.dart
      riverpod_generator:
        generate_for:
          include:
            - lib/providers/**.dart
      drift_dev:
        generate_for:
          include:
            - lib/database/**.dart
```

---

## 三、完整工程目录结构树

```text
lib/
├── main.dart                          # 初始化 WidgetsBinding、Drift、SharedPreferences、Desktop Window
├── application.dart                   # MaterialApp.router + BuildManagerStack + Theme/Locale 绑定
├── router/app_router.dart             # GoRouter ShellRoute (/dashboard, /catalog, /lab/:id, /assessment, /settings)
├── common/
│   ├── platform_detector.dart         # isDesktop / isWindows / isMacOS / isAndroid + 快捷键修饰符抽象
│   ├── debouncer.dart                 # 输入防抖、搜索防抖
│   └── math_utils.dart                # 角度最短弧插值、向量法线、SM-2 计算辅助
├── enum/
│   └── ds_enums.dart                  # ChapterId(ch1..ch8), CodeLang(cLike, c99, dart), ViewDensity, QuestionType, ColorStyle
├── models/
│   ├── settings_model.dart            # ThemeProps, WindowProps, LabPrefs (Freezed)
│   ├── curriculum_model.dart          # ChapterMeta, AlgorithmMeta, ComplexitySpec, PresetDataset
│   ├── trace_model.dart               # TraceTimeline, TraceFrame, SceneSnapshot, SceneNode, SceneEdge, AuxTable, StackFrame
│   └── assessment_model.dart          # QuizQuestion, ChoiceQuestion, TraceTableQuestion, PointerSandboxQuestion, CodeQuestion, MasteryReport
├── database/
│   ├── app_database.dart              # Drift @DriftDatabase(tables: [...]) 及 DAO 查询方法
│   ├── converters.dart                # Map/List JSON TypeConverter
│   └── repositories/
│       ├── progress_repository.dart   # 实验室访问计时、完成状态、DailyStudyStats 增量累加
│       ├── quiz_repository.dart       # 答题流水写入、SM-2 错题队列拉取与复习更新、Mastery 重算
│       └── backup_repository.dart     # 导出/导入 .structclash.json 与 ConflictResolution 合并策略
├── providers/                         # Riverpod @riverpod 控制器集合
├── ui/                                # M3E × FlClash 组件库 (见 02 号文档)
├── engine/                            # TraceVM、混合画布、布局器与三语调试器 (见 03 号文档)
├── curriculum/                        # 第 1~8 章纯逻辑实现与习题种子 (见 04~07 号文档)
└── views/                             # 首页 Bento、全书目录、三栏实验室、评测中心、设置页
```

---

## 四、Drift SQLite 数据库 8 张核心表与 JSON 备份规范 (`lib/database/app_database.dart`)

> 所有表名与字段名使用驼峰转下划线规则，日期统一存储为 UTC `DateTimeColumn`（或按本地日历生成的 `'YYYY-MM-DD'` 文本主键用于热力图按天聚合）。

| # | 表名 (`Table`) | 主键 (PK) | 核心字段清单与类型说明 | 业务职责与索引要求 |
| :-: | :--- | :--- | :--- | :--- |
| 1 | `LessonProgressTable` | `moduleId` (`Text`) | `chapterId` (`Text`), `status` (`Int`: 0未学/1学习中/2已完成), `watchedFullTrace` (`Bool`), `customRunCount` (`Int`), `timeSpentSeconds` (`Int`), `lastVisitedAt` (`DateTime`) | 跟踪 46+ 算法实验室的学习进度与自定义实验次数；为 `chapterId` 建索引 |
| 2 | `QuizAttemptsTable` | `id` (`Int` AutoInc) | `questionId` (`Text`), `chapterId` (`Text`), `questionType` (`Text`), `isCorrect` (`Bool`), `score` (`Int` 0..100), `userAnswerJson` (`Text`), `durationMs` (`Int`), `attemptedAt` (`DateTime`) | 完整留存每次做题历史流水，支持查看错题当时的错误作答细节 |
| 3 | `WrongQuestionBookTable` | `questionId` (`Text`) | `chapterId` (`Text`), `errorCount` (`Int`), `consecutiveCorrect` (`Int`), `easinessFactor` (`Real`, def `2.5`), `intervalDays` (`Int`, def `1`), `nextReviewAt` (`DateTime`), `userNote` (`Text`), `isMastered` (`Bool`) | **SM-2 间隔重复错题本核心表**；按 `nextReviewAt` 与 `isMastered` 建复合索引 |
| 4 | `ChapterMasteryTable` | `chapterId` (`Text`) | `conceptScore` (`Real`), `traceScore` (`Real`), `codingScore` (`Real`), `labCompletionRate` (`Real`), `overallMastery` (`Real` 0..100), `updatedAt` (`DateTime`) | 缓存每章四维得分与总掌握度，避免仪表盘高频聚合全表流水 |
| 5 | `DailyStudyStatsTable` | `dateKey` (`Text`) | `studyMinutes` (`Int`), `labsCompleted` (`Int`), `questionsSolved` (`Int`), `correctCount` (`Int`) | 驱动首页 GitHub 风格年度学习热力图与连续打卡天数 (`Streak`) |
| 6 | `UserCustomDatasetsTable` | `id` (`Int` AutoInc) | `moduleId` (`Text`), `name` (`Text`), `payloadJson` (`Text`), `createdAt` (`DateTime`) | 保存用户在实验室构造的自定义链表/二叉树/带权图邻接表 |
| 7 | `CodeDraftsTable` | `questionId` (`Text`) | `codeLang` (`Text`), `sourceCode` (`Text`), `lastPassRate` (`Real`), `updatedAt` (`DateTime`) | 实时保存算法设计题作答草稿，防止切换页面丢失代码 |
| 8 | `AchievementsTable` | `achievementId` (`Text`) | `title` (`Text`), `unlockedAt` (`DateTime`), `progressCurrent` (`Int`), `progressTarget` (`Int`) | 记录 12 枚数据结构成就徽章的解锁进度与解锁时间 |

### `.structclash.json` 跨设备导入/导出协议
```json
{
  "schemaVersion": 1,
  "app": "struct_clash",
  "exportedAt": "2026-11-15T16:00:00Z",
  "sourcePlatform": "windows",
  "payload": {
    "lessonProgress": [],
    "wrongQuestionBook": [],
    "chapterMastery": [],
    "dailyStudyStats": [],
    "userCustomDatasets": [],
    "codeDrafts": [],
    "achievements": []
  }
}
```
- **合并导入策略 (`ImportStrategy.mergePreferHigher`)**：导入时在 Drift 事务 `transaction(() async { ... })` 中执行：`LessonProgress` 取 `status` 较高者与 `timeSpentSeconds` 之和；`DailyStudyStats` 同日取较大值；`UserCustomDatasets` 按 `(moduleId, name)` 去重追加；若用户明确选择 `ImportStrategy.overwrite`，则清空 8 表后全量写入并重新计算 `ChapterMasteryTable`。

---

## 五、三端平台工程化配置细则

> **执行约定**：Stage 0 在 Windows 端跑通编译即可；**macOS 与 Android 相关工程文件必须在 `[S0-05]` 一次性按以下规范预设修改完毕**，保证后续跨平台直接可编译。

### 5.1 Windows 端（当前主验证平台）
- **`lib/main.dart` 窗口初始化**：
  ```dart
  if (Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1360, 860),
      minimumSize: Size(800, 600),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true, // macOS 自动显示原生红绿灯
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  ```
- **高 DPI 与 Mica 透光**：检查 `windows/runner/main.cpp` 与 `runner.exe.manifest` 已启用 `PerMonitorV2` DPI 感知；若用户开启「侧边栏透明质感」，Windows 11（Build >= 22621）调用 `Window.setEffect(effect: WindowEffect.mica, dark: isDark)`，旧版回退至 `WindowEffect.solid`。

### 5.2 macOS 端（预设就绪，本阶段免测）
- **`macos/Runner/MainFlutterWindow.swift`**：配置透明沉浸式标题栏以配合 Flutter `MacTrafficLightInset(76.0)`：
  ```swift
  self.titleVisibility = .hidden
  self.titlebarAppearsTransparent = true
  self.styleMask.insert(.fullSizeContentView)
  ```
- **`macos/Runner/DebugProfile.entitlements` & `Release.entitlements`**：添加本地备份文件授权，确保沙盒模式下 `file_picker` 读写 `.structclash.json` 正常：
  ```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
  ```

### 5.3 Android 端（预设就绪，本阶段免测）
- **`android/app/src/main/kotlin/.../MainActivity.kt`**：覆盖 `onCreate` 启用全面屏沉浸式 Edge-to-Edge：
  ```kotlin
  import android.os.Bundle
  import androidx.activity.enableEdgeToEdge
  import io.flutter.embedding.android.FlutterActivity

  class MainActivity : FlutterActivity() {
      override fun onCreate(savedInstanceState: Bundle?) {
          enableEdgeToEdge()
          super.onCreate(savedInstanceState)
      }
  }
  ```
- **`android/app/src/main/AndroidManifest.xml`**：
  - `<application>` 标签添加 `android:enableOnBackInvokedCallback="true"`（支持 Android 14+ 预测性返回动画）。
  - **严禁在 `<activity>` 上添加 `android:screenOrientation="portrait"` 或 `"landscape"`**：确保折叠屏展开与平板旋转能无缝切换至 Medium / Expanded 多栏工作台。
- **`android/app/build.gradle.kts`**：确认 `minSdk >= 24`，`compileSdk = 36`（支持最新 Edge-to-Edge 与高刷屏特性）。

---

## 六、本模块子任务同步勾选清单 (`[S0-01]` ～ `[S0-06]`)

> 执行模型完成一项后将下方 `[ ]` 改为 `[x]`，并同步更新 `.doc/README.md`。

- [x] `[S0-01]` 运行 `flutter create --project-name struct_clash --org com.datastructure.prism --platforms=windows,android,macos .` 并配置 `.gitignore` 忽略 `/*.pdf`
- [x] `[S0-02]` 编写 `pubspec.yaml`、`build.yaml`、配置等宽代码字体及 `analysis_options.yaml`，跑通 `flutter pub get`
- [x] `[S0-03]` 编写 `lib/common/`、`lib/enum/` 与 `lib/models/`（含 `settings_model`, `curriculum_model`, `trace_model` 骨架），跑通 `dart run build_runner build --delete-conflicting-outputs`
- [x] `[S0-04]` 实现 Drift `AppDatabase` 8 张表、`converters.dart` 及 `Progress / Quiz / Backup` 三个 Repository 类
- [x] `[S0-05]` 预设完成 Windows（`main.cpp`/窗口管理）、macOS（`MainFlutterWindow.swift` + `.entitlements`）及 Android（`MainActivity.kt` Edge-to-Edge + `AndroidManifest.xml` 无方向锁 + `build.gradle.kts`）全部配置
- [x] `[S0-06]` 编写 `test/database_test.dart` 并跑通 Windows 验证：
  ```powershell
  dart run build_runner build --delete-conflicting-outputs
  flutter analyze
  flutter test test/database_test.dart
  ```

## 2026-11-15 实施补充

S0-01～S0-06 已实现并验证。以上初始规格的依赖片段保留作规划记录；实际版本以根目录 pubspec.yaml / pubspec.lock 为准。Drift 增加每日 studySeconds 防止分钟取整丢失；备份补齐 quizAttempts。Android 通过 Flutter SystemUiMode.edgeToEdge 实现边到边布局，未套用不适用于 FlutterActivity 的 Kotlin 扩展。Android/macOS 未执行编译或实机测试。
