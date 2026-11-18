import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../enum/ds_enums.dart';
import '../../providers/app_providers.dart';
import '../../ui/components/common_scaffold.dart';
import '../../ui/components/bento_card.dart';
import '../../ui/layout/layout_preview.dart';

const paletteNames = [
  '跟随系统',
  '教材双色',
  'Clash 蓝',
  '紫罗兰',
  '森林绿',
  '琥珀金',
  '胭脂红',
  '单色',
];

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});
  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool busy = false;
  Future<void> perform(
    Future<void> Function() action, {
    String? message,
  }) async {
    setState(() => busy = true);
    try {
      await action();
      if (mounted && message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败：$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> exportBackup() async {
    final json = await ref.read(backupRepositoryProvider).exportJson();
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: '导出学习记录',
      fileName: 'backup.fldata.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: utf8.encode(json),
    );
    if (destination == null) return;
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('备份已导出')));
    }
  }

  Future<void> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null) return;
    final data = result.files.single.bytes;
    if (data == null) throw const FormatException('无法读取备份文件');
    if (!mounted) return;
    final strategy = await showDialog<ImportStrategy>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('导入学习记录'),
        content: Text(
          '已选择 ${result.files.single.name}。合并会保留较高进度、累加实验时长，并按课程和名称追加数据集。覆盖会用备份替换本机的全部学习记录和自定义数据。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImportStrategy.overwrite),
            child: Text(
              '覆盖本机记录',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, ImportStrategy.mergePreferHigher),
            child: const Text('合并记录'),
          ),
        ],
      ),
    );
    if (!mounted || strategy == null) return;
    await ref
        .read(backupRepositoryProvider)
        .importJson(utf8.decode(data), strategy: strategy);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strategy == ImportStrategy.overwrite ? '已从备份恢复学习记录' : '备份已合并',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeSettingsProvider);
    return CommonScaffold(
      title: '设置',
      subtitle: '把工作台调整成你喜欢的样子',
      child: ListView(
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('外观', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                DropdownButtonFormField<AppearanceMode>(
                  initialValue: settings.mode,
                  decoration: const InputDecoration(labelText: '明暗模式'),
                  items: [
                    for (final mode in AppearanceMode.values)
                      DropdownMenuItem(
                        value: mode,
                        child: Text(['跟随系统', '浅色', '深色'][mode.index]),
                      ),
                  ],
                  onChanged: busy
                      ? null
                      : (mode) {
                          if (mode != null) {
                            perform(
                              () => ref
                                  .read(themeSettingsProvider.notifier)
                                  .update(settings.copyWith(mode: mode)),
                            );
                          }
                        },
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final palette in ColorStyle.values)
                      ChoiceChip(
                        label: Text(paletteNames[palette.index]),
                        selected: settings.palette == palette,
                        onSelected: busy
                            ? null
                            : (_) => perform(
                                () => ref
                                    .read(themeSettingsProvider.notifier)
                                    .update(
                                      settings.copyWith(palette: palette),
                                    ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pure Black'),
                  subtitle: const Text('在深色模式下使用纯黑背景'),
                  value: settings.pureBlack,
                  onChanged: busy
                      ? null
                      : (value) => perform(
                          () => ref
                              .read(themeSettingsProvider.notifier)
                              .update(settings.copyWith(pureBlack: value)),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('学习记录', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text('记录保存在本机。备份包含实验进度、答题流水、错题本和代码草稿。'),
                const SizedBox(height: 12),
                const Text(
                  '合并会累加实验学习时长，重复合并同一备份也会累加。',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: busy ? null : () => perform(exportBackup),
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('导出备份'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => perform(importBackup),
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('导入备份'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('实验数据集'),
              subtitle: const Text('浏览课程示例，编辑和运行自己的输入'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/datasets'),
            ),
          ),
          const SizedBox(height: 16),
          const PreviewSettings(),
        ],
      ),
    );
  }
}
