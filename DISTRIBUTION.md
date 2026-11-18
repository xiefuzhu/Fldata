# Fldata 交付说明

## 在 Windows 运行

完整解压发布包，打开 `Fldata.exe`（或便携目录中的 `portable/windows-x64/Fldata.exe`）。这个目录包含 Flutter 引擎、插件、SQLite、应用资源和 x64 Visual C++ 运行库，可以整目录复制到另一台 Windows x64 电脑。学习记录保存在运行者的本机用户目录。需要迁移记录时，可在「设置 → 学习记录」导出或导入备份。

## 从源码构建

ZIP 解压后的顶层就是 Flutter 工程，包含依赖锁文件 `pubspec.lock`。本版使用 Flutter 3.47.7、Dart 3.13.5 构建。搭建 Windows 开发环境时，安装 Flutter SDK、Git Bash 和带「使用 C++ 的桌面开发」工作负载的 Visual Studio。首次还原依赖需要联网，或准备已有的依赖缓存。

在工程根目录运行以下命令。

```bash
flutter pub get
flutter test
flutter build windows --release
```

新生成的程序位于 `build/windows/x64/runner/Release/`。仓库已包含 Dart 生成文件。修改数据模型后，运行 `dart run build_runner build` 更新。若 Windows 在创建插件符号链接时报错，安装 Node.js 后可在 Git Bash 运行 `bash scripts/bootstrap_windows.sh`，再重新构建。

Android 和 macOS 的原生工程分别在 `android/` 和 `macos/`。Android 附有 Gradle Wrapper。在装有 Android SDK 的环境运行 `flutter build apk`，或在装有 Xcode 和所需插件工具链的 Mac 上运行 `flutter build macos`。本次随包提供的可执行版本为 Windows x64。

## 源码与文档导航

| 位置 | 内容 |
| --- | --- |
| `lib/`、`test/` | 应用源码、生成模型、课程算法、题库与测试 |
| `windows/`、`android/`、`macos/` | 三个平台的原生入口和构建配置 |
| `assets/` | 字体、字体许可证、题图和其他课程资源 |
| `scripts/`、`tool/` | 构建辅助脚本和题库参考验证工具 |
| [项目说明](README.md) | 功能、开发环境和历史验证记录 |
| [计划与设计文档](.doc/README.md) | 工程架构、界面、TraceVM、八章实验和评测规格 |
| [教材题目来源索引](.doc/QUIZ_SEED_COVERAGE.md) | 195 项正式习题的书页、题号与覆盖范围 |
| [实施计划](task_plan.md)、[实施记录](progress.md)、[开发发现](findings.md) | 阶段交付与决策记录 |

教材 PDF 是外部参考资料，随包提供项目内的题库、题图与页码索引。Flutter 依赖的许可声明保存在 Windows 发布目录的 `data/flutter_assets/NOTICES.Z`，字体许可另见 `assets/fonts/OFL.txt`。
