import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch8_sort/insertion_sort.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import 'sort_playback.dart';
import '../../models/playback_model.dart';
import 'lesson_player.dart';

class InsertionSortView extends ConsumerStatefulWidget {
  const InsertionSortView({super.key, this.launch});
  final LessonLaunch<InsertionInput>? launch;
  @override
  ConsumerState<InsertionSortView> createState() => _InsertionSortViewState();
}

class _InsertionSortViewState
    extends LessonPlayer<InsertionSortView, InsertionInput> {
  @override
  LessonLaunch<InsertionInput>? get launch => widget.launch;
  @override
  final module = const InsertionModule();
  @override
  InsertionInput input = const InsertionInput();
  @override
  String get presetKey => 'insertion-presets';
  @override
  String get theoryHint => switch (input.method) {
    InsertionMethod.direct =>
      '算法 8.1 的 r[0] 同时是暂存区与监视哨。向前比较时遇到相等键即停止，保留相等记录的输入次序。',
    InsertionMethod.binary =>
      '算法 8.2 以折半查找定位，遇到相等键继续向右。后移次数与直接插入相同，每趟暂存与回填均计入 RMN。',
    InsertionMethod.shell =>
      '算法 8.3 在间隔 dk 的子序列内插入。r[0] 只作暂存，j ≤ 0 时停止；跨组移动可能改变相等键的先后顺序。',
  };
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<InsertionMethod>(
      key: const ValueKey('insertion-method'),
      value: input.method,
      items: [
        for (final m in InsertionMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) changeInput(input.change(method: m));
      },
    ),
    TextButton.icon(
      key: const ValueKey('insertion-edit'),
      icon: const Icon(Icons.edit_outlined),
      label: Text(input.method == InsertionMethod.shell ? '设置序列与增量' : '设置序列'),
      onPressed: () async {
        final next = await showDialog<InsertionInput>(
          context: context,
          builder: (_) => _Editor(input),
        );
        if (mounted && next != null) runCustomInput(next);
      },
    ),
  ];

  @override
  Widget stage(PlaybackState state) {
    final f = state.currentFrame!,
        v = f.inlineVars,
        frames = state.timeline!.frames;
    final next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final scene = interpolateSort(
      f,
      next,
      MediaQuery.disableAnimationsOf(context) ? 0 : state.subProgress,
    );
    final prefix = int.parse(v['有序区']!);
    final complete = v['阶段'] == '完成', metric = f.metrics;
    return LayoutBuilder(
      builder: (ctx, c) {
        final panel = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KCN　${metric.comparisons}　　RMN　${metric.moves}',
              key: const ValueKey('insertion-metrics'),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            Text('后移 ${v['后移']} 次　·　辅助记录 1　·　递归深度 ${metric.callDepth}'),
            if (input.method == InsertionMethod.shell)
              Text('增量序列　${input.gaps.join(" → ")}'),
            if (complete) ...[
              sortStabilityResult(
                ctx,
                input.keys,
                v,
                (index) => vm.seek(index.toDouble()),
              ),
              const Divider(),
              const Text('同一输入的插入排序对照'),
              for (final row in f.scene.auxTables.last.rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${row[0]}　KCN ${row[1]}　RMN ${row[4]}\n后移 ${row[2]}，暂存与回填 ${row[3]}',
                  ),
                ),
            ],
          ],
        );
        final last = f.scene.nodes.last;
        final graph = SizedBox(
          height: (c.maxHeight * .56).clamp(220.0, 380.0),
          child: DsStageCanvas(
            key: ObjectKey(state.timeline),
            scene: scene,
            sceneSize: Size(last.x + last.width + 32, 250),
            nodeContentBuilder: (context, n) {
              final idx = int.tryParse(n.id.replaceFirst('slot', ''));
              final sorted = idx != null && idx > 0 && idx <= prefix;
              final star = n.label.indexOf('*');
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sorted ? Colors.green.withValues(alpha: .15) : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: FittedBox(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: n.isZeroSentinelSlot
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: star < 0
                                ? n.label
                                : n.label.substring(0, star),
                          ),
                          if (star >= 0)
                            TextSpan(
                              text: n.label.substring(star),
                              style: TextStyle(
                                color: n.isZeroSentinelSlot
                                    ? Colors.amberAccent
                                    : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.phaseTitle,
                key: const ValueKey('insertion-phase'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              Text(f.explanation),
              Wrap(
                spacing: 12,
                children: [
                  if (input.method == InsertionMethod.shell)
                    Text('dk = ${v['dk']}'),
                  if (v['i'] != '0') Text('i = ${v['i']}'),
                  for (final name in ['j', 'low', 'mid', 'high'])
                    if (v.containsKey(name)) Text('$name = ${v[name]}'),
                  if (prefix > 0) Text('有序区 1..$prefix'),
                ],
              ),
              if (c.maxWidth >= 670)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: graph),
                    const SizedBox(width: 12),
                    Expanded(child: panel),
                  ],
                )
              else ...[
                graph,
                panel,
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor(this.input);
  final InsertionInput input;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late String values = widget.input.keys.join(' '),
      gaps = widget.input.gaps.join(' ');
  String? error;
  void apply() {
    try {
      final next = widget.input.change(
        keys: InsertionInput.parse(values, tagged: true),
        gaps: InsertionInput.parse(gaps),
      );
      next.validate();
      Navigator.pop(context, next);
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text('${widget.input.method.label}设置'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          key: const ValueKey('insertion-keys'),
          initialValue: values,
          onChanged: (v) => values = v,
          decoration: const InputDecoration(
            labelText: '记录序列',
            helperText: '用空格或逗号分隔；同键按输入次序自动加星',
            helperMaxLines: 3,
          ),
        ),
        if (widget.input.method == InsertionMethod.shell)
          TextFormField(
            key: const ValueKey('insertion-gaps'),
            initialValue: gaps,
            onChanged: (v) => gaps = v,
            decoration: const InputDecoration(
              labelText: '递减增量序列',
              helperText: '末项为 1',
            ),
          ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: apply, child: const Text('开始推演')),
    ],
  );
}
