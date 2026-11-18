import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch8_sort/exchange_sort.dart';
import 'sort_keys_editor.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/debugger/call_tree_projection.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';
import 'sort_playback.dart';

class ExchangeSortView extends ConsumerStatefulWidget {
  const ExchangeSortView({super.key, this.launch});
  final LessonLaunch<ExchangeInput>? launch;
  @override
  ConsumerState<ExchangeSortView> createState() => _ExchangeState();
}

class _ExchangeState extends LessonPlayer<ExchangeSortView, ExchangeInput> {
  @override
  LessonLaunch<ExchangeInput>? get launch => widget.launch;
  @override
  final module = const ExchangeModule();
  @override
  ExchangeInput input = const ExchangeInput();
  @override
  String get presetKey => 'exchange-presets';
  @override
  String get theoryHint => input.method == ExchangeMethod.bubble
      ? '算法 8.4 只交换严格逆序的相邻记录。每次交换计三次记录移动，某趟无交换说明剩余区间已有序。'
      : '算法 8.5 选择区间首记录作为枢轴。high 跳过大于或等于枢轴的键，low 跳过小于或等于枢轴的键。枢轴归位后先递归左区间，再递归右区间。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<ExchangeMethod>(
      key: const ValueKey('exchange-method'),
      value: input.method,
      items: [
        for (final m in ExchangeMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) changeInput(input.change(method: m));
      },
    ),
    if (input.method == ExchangeMethod.bubble)
      FilterChip(
        key: const ValueKey('bubble-flag'),
        selected: input.earlyStop,
        label: const Text('flag 提前终止'),
        onSelected: (v) => changeInput(input.change(earlyStop: v)),
      ),
    TextButton.icon(
      key: const ValueKey('exchange-edit'),
      icon: const Icon(Icons.edit_outlined),
      label: const Text('设置序列'),
      onPressed: () async {
        final next = await showDialog<List<int>>(
          context: context,
          builder: (_) => SortKeysEditor(
            input.keys,
            fieldKey: 'exchange-keys',
            title: '设置交换排序序列',
          ),
        );
        if (mounted && next != null) runCustomInput(input.change(keys: next));
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
    final quick = input.method == ExchangeMethod.quick,
        n = input.keys.length,
        metrics = f.metrics,
        last = f.scene.nodes.last;
    return LayoutBuilder(
      builder: (ctx, c) {
        final graph = SizedBox(
          height: (c.maxHeight * .48).clamp(218.0, 380.0),
          child: DsStageCanvas(
            key: ObjectKey(state.timeline),
            scene: scene,
            sceneSize: Size(last.x + last.width + 32, 246),
            nodeContentBuilder: (ctx, node) => Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontWeight: node.label.contains('*')
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: node.isZeroSentinelSlot
                          ? Colors.white
                          : node.label.contains('*')
                          ? Theme.of(ctx).colorScheme.primary
                          : Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final panel = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KCN　${metrics.comparisons}　　RMN　${metrics.moves}',
              key: const ValueKey('exchange-metrics'),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            if (quick) ...[
              Text(
                'QSort 栈深　当前 ${metrics.callDepth}　峰值 ${metrics.maxCallDepth}',
                key: const ValueKey('quick-depth'),
              ),
              if (n > 0) Text('$n 个记录：均分时 ${n.bitLength} 层，逐个划出最值时 $n 层。'),
            ] else
              Text('趟数 ${v['趟']}　交换 ${v['交换次数']} 次'),
            if (v['阶段'] == '完成')
              sortStabilityResult(
                ctx,
                input.keys,
                v,
                (index) => vm.seek(index.toDouble()),
              ),
          ],
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.phaseTitle,
                key: const ValueKey('exchange-phase'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              Text(f.explanation),
              Wrap(
                spacing: 12,
                children: [
                  for (final name in ['m', 'j', 'flag', 'low', 'high', '空坑'])
                    if (v.containsKey(name)) Text('$name = ${v[name]}'),
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
              if (quick) ...[
                const Text('递归区间树'),
                _QuickTree(timeline: state.timeline!, index: state.frameIndex),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuickTree extends StatefulWidget {
  const _QuickTree({required this.timeline, required this.index});
  final TraceTimeline timeline;
  final int index;
  @override
  State<_QuickTree> createState() => _QuickTreeState();
}

class _QuickTreeState extends State<_QuickTree> {
  late SceneSnapshot scene;
  late Size extent;
  @override
  void initState() {
    super.initState();
    project();
  }

  @override
  void didUpdateWidget(_QuickTree old) {
    super.didUpdateWidget(old);
    if (!identical(old.timeline, widget.timeline) ||
        old.index != widget.index) {
      project();
    }
  }

  void project() {
    final p = CallTreeProjection(widget.timeline, widget.index),
        nodes = <SceneNode>[],
        edges = <SceneEdge>[];
    for (final r in p.records.values) {
      final lo = int.parse(r.arguments['low']!),
          hi = int.parse(r.arguments['high']!);
      if (lo > hi) continue;
      final pivot = r.locals['pivot'] ?? r.locals['record'];
      nodes.add(
        SceneNode(
          id: r.id,
          label: '[$lo, $hi]${pivot == null ? "" : "　$pivot"}',
          x: 0,
          y: 0,
          width: 110,
          height: 44,
          logicBadge: r.id == p.topId
              ? '执行中'
              : p.activeIds.contains(r.id)
              ? '等待返回'
              : '已返回',
          visualState: r.id == p.topId
              ? NodeVisualState.active
              : p.activeIds.contains(r.id)
              ? NodeVisualState.comparing
              : NodeVisualState.sorted,
        ),
      );
      if (r.parentCallId case final parent?) {
        edges.add(
          SceneEdge(
            id: 'call-${r.id}',
            fromNodeId: parent,
            toNodeId: r.id,
            fromPort: r.arguments['low'] == p.records[parent]!.arguments['low']
                ? EdgePort.lchild
                : EdgePort.rchild,
          ),
        );
      }
    }
    scene = TreeReingoldLayout.arrange(
      SceneSnapshot(nodes: nodes, edges: edges),
      slantSingleChild: true,
    );
    double w = 180, h = 100;
    for (final n in scene.nodes) {
      w = math.max(w, n.x + n.width + 28);
      h = math.max(h, n.y + n.height + 36);
    }
    extent = Size(w, h);
  }

  @override
  Widget build(BuildContext context) => scene.nodes.isEmpty
      ? const Text('尚无非空递归区间')
      : SizedBox(
          height: 300,
          child: DsStageCanvas(
            key: const ValueKey('quick-tree'),
            scene: scene,
            sceneSize: extent,
            nodeContentBuilder: (ctx, n) =>
                Center(child: FittedBox(child: Text(n.label))),
          ),
        );
}
