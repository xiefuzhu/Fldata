import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/catalog.dart';
import '../../curriculum/dataset_catalog.dart';
import '../../database/app_database.dart';
import '../../database/repositories/dataset_repository.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../providers/app_providers.dart';
import '../../ui/components/common_scaffold.dart';
import '../lab/dataset_launch.dart';

final _repository = Provider(
  (ref) => DatasetRepository(ref.watch(databaseProvider)),
);
final _datasets = StreamProvider((ref) => ref.watch(_repository).watchAll());

class DatasetView extends ConsumerStatefulWidget {
  const DatasetView({super.key});
  @override
  ConsumerState<DatasetView> createState() => _DatasetViewState();
}

class _DatasetViewState extends ConsumerState<DatasetView> {
  String selected = chapters.first.moduleIds.first;
  void run(Object input, String presetId, {required bool custom}) =>
      context.push(
        Uri(
          path: '/lab/$selected',
          queryParameters: {'preset': presetId},
        ).toString(),
        extra: DatasetLaunch(selected, input, custom: custom),
      );
  void runSaved(UserCustomDataset row) {
    try {
      final module = datasetModules[selected];
      if (module == null) throw const FormatException('当前版本没有该课程。');
      run(
        datasetInput(module, row.payloadJson),
        row.payloadJson['preset'] as String,
        custom: true,
      );
    } on FormatException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> edit({
    AlgorithmPreset<Object>? preset,
    UserCustomDataset? existing,
  }) => showDialog<void>(
    context: context,
    builder: (_) => _DatasetEditor(
      moduleId: selected,
      preset: preset,
      existing: existing,
      repository: ref.read(_repository),
    ),
  );
  Future<void> remove(UserCustomDataset row) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除「${row.name}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) await ref.read(_repository).remove(row.id);
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(_datasets);
    final ids = {
      for (final chapter in chapters) ...chapter.moduleIds,
      for (final row in rows.asData?.value ?? <UserCustomDataset>[])
        row.moduleId,
      selected,
    };
    final saved =
        rows.asData?.value.where((r) => r.moduleId == selected).toList() ?? [];
    return CommonScaffold(
      title: '实验数据集',
      subtitle: '从课程示例开始，保存可重复运行的实验输入',
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回设置'),
            ),
          ),
          DropdownButtonFormField<String>(
            key: const ValueKey('dataset-course'),
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: '课程'),
            items: [
              for (final id in ids)
                DropdownMenuItem(
                  value: id,
                  child: Text(
                    moduleById(id)?.title ?? id,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) {
              if (id != null) setState(() => selected = id);
            },
          ),
          const SizedBox(height: 20),
          Text('我的数据集', style: Theme.of(context).textTheme.titleLarge),
          if (rows.isLoading) const LinearProgressIndicator(),
          if (rows.hasError) Text('读取失败：${rows.error}'),
          if (rows.hasValue && saved.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('从下方示例另存第一份数据集。'),
            ),
          for (final row in saved)
            ListTile(
              title: Text(row.name),
              onTap: () => edit(existing: row),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '运行 ${row.name}',
                    onPressed: () => runSaved(row),
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    tooltip: '删除 ${row.name}',
                    onPressed: () => remove(row),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          const Divider(),
          Text('课程示例', style: Theme.of(context).textTheme.titleLarge),
          for (final preset in datasetPresets(selected))
            ListTile(
              title: Text(preset.name),
              subtitle: Text(
                datasetText(preset.input),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => run(preset.input, preset.id, custom: false),
              trailing: IconButton(
                tooltip: '另存 ${preset.name}',
                onPressed: () => edit(preset: preset),
                icon: const Icon(Icons.copy),
              ),
            ),
        ],
      ),
    );
  }
}

class _DatasetEditor extends StatefulWidget {
  const _DatasetEditor({
    required this.moduleId,
    required this.repository,
    this.preset,
    this.existing,
  });
  final String moduleId;
  final DatasetRepository repository;
  final AlgorithmPreset<Object>? preset;
  final UserCustomDataset? existing;
  @override
  State<_DatasetEditor> createState() => _DatasetEditorState();
}

class _DatasetEditorState extends State<_DatasetEditor> {
  late final original = widget.existing?.payloadJson;
  late final preset =
      widget.preset ??
      datasetPresets(
        widget.moduleId,
      ).where((p) => p.id == original?['preset']).firstOrNull;
  late final legacy =
      preset == null || original != null && original?['input'] is! String;
  late final name = TextEditingController(
    text: widget.existing?.name ?? '${preset!.name} · 副本',
  );
  late final data = TextEditingController(
    text: legacy
        ? const JsonEncoder.withIndent('  ').convert(original)
        : original?['input'] as String? ?? datasetText(preset!.input),
  );
  String? error;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    data.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final Map<String, dynamic> payload;
      if (legacy) {
        final obj = jsonDecode(data.text);
        if (obj is! Map<String, dynamic>) {
          throw const FormatException('请输入 JSON 对象。');
        }
        payload = obj;
      } else {
        payload = {...?original, 'preset': preset!.id, 'input': data.text};
        datasetInput(datasetModules[widget.moduleId]!, payload);
      }
      await widget.repository.save(
        widget.moduleId,
        name.text,
        payload,
        id: widget.existing?.id,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          saving = false;
          error = e is FormatException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? '另存数据集' : '编辑数据集'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: '数据集名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: data,
              minLines: 2,
              maxLines: 7,
              decoration: InputDecoration(
                labelText: legacy ? '原始 JSON' : '实验输入',
                helperText: preset?.name,
                helperMaxLines: 2,
              ),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: saving ? null : save, child: const Text('保存')),
    ],
  );
}
