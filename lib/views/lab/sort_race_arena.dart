import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../curriculum/ch8_sort/sort_race.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/trace_model.dart';

class SortRaceArena extends StatefulWidget {
  const SortRaceArena({super.key, this.onFinished});
  final ValueChanged<bool>? onFinished;
  @override
  State<SortRaceArena> createState() => _SortRaceArenaState();
}

class _SortRaceArenaState extends State<SortRaceArena>
    with SingleTickerProviderStateMixin {
  final chosen = <RaceAlgorithm>{RaceAlgorithm.quick, RaceAlgorithm.heap};
  RaceSample sample = RaceSample.random;
  int seed = 1, count = 10, tick = 0, end = 0;
  List<RaceLane>? lanes;
  bool loading = false, reported = false;
  late final AnimationController clock = AnimationController(vsync: this)
    ..addListener(advance);
  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  void advance() {
    if (lanes == null) return;
    final value = (clock.value * end).round();
    if (value != tick) setState(() => tick = value);
    if (value == end && !reported) {
      reported = true;
      final stability = lanes!.map((l) => l.algorithm.stable).toSet();
      widget.onFinished?.call(stability.length == 2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && lanes != null) report();
      });
    }
  }

  Future<void> start() async {
    setState(() => loading = true);
    try {
      final result = await compute(
        buildRace,
        RaceRequest(sample.generate(count, seed), chosen.toList()),
      );
      if (!mounted) return;
      end = result.map((l) => l.beats.last.tick).reduce(math.max);
      clock.duration = Duration(milliseconds: math.max(1, end * 55));
      setState(() {
        lanes = result;
        loading = false;
        tick = 0;
        reported = false;
      });
      clock.forward(from: 0);
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成赛道失败：$e')));
      }
    }
  }

  void report() {
    final noTies = sample.generate(count, seed).toSet().length == count;
    final ranked = [...lanes!]
      ..sort((a, b) => a.beats.last.tick.compareTo(b.beats.last.tick));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('竞速战报'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${sample.label} · $count 项 · 样本 $seed。按完成节拍排名，相同节拍并列。'),
            const Text('教材表 8.2 · 各种内部排序方法的比较（第 267 页）。复杂度列为 O(·) 内的量级。'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  for (final h in [
                    '名次',
                    '算法',
                    '节拍',
                    'KCN',
                    'RMN',
                    '游标写入',
                    '最好',
                    '最坏',
                    '平均',
                    '辅助空间',
                    '本场栈深',
                    '算法稳定性',
                    '本场同键',
                  ])
                    DataColumn(label: Text(h)),
                ],
                rows: [
                  for (final lane in ranked)
                    DataRow(
                      cells: [
                        for (final v in [
                          '${ranked.indexWhere((l) => l.beats.last.tick == lane.beats.last.tick) + 1}',
                          lane.algorithm.label,
                          '${lane.beats.last.tick}',
                          '${lane.beats.last.comparisons}',
                          '${lane.beats.last.moves}',
                          '${lane.beats.last.links}',
                          lane.algorithm.best,
                          lane.algorithm.worst,
                          lane.algorithm.average,
                          lane.algorithm.space,
                          '${lane.peakDepth}',
                          lane.algorithm.stable ? '稳定' : '不稳定',
                          noTies
                              ? '无同键'
                              : lane.inverted
                              ? '出现逆序'
                              : '保持原序',
                        ])
                          DataCell(Text(v)),
                      ],
                    ),
                ],
              ),
            ),
            if (chosen.contains(RaceAlgorithm.simple))
              const Text('表 8.2 将简单选择列为稳定。这里按例 8.5 的交换实现标为不稳定。'),
            if (chosen.contains(RaceAlgorithm.tournament))
              const Text('树形选择为补充项，采用同键左侧优先。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('排序竞速')),
      body: SafeArea(child: lanes == null ? _settings() : _tracks()),
    );
  }

  Widget _settings() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        '参赛算法（${chosen.length}/4）',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final a in RaceAlgorithm.values)
            FilterChip(
              key: ValueKey('race-${a.name}'),
              label: Text(a.label),
              selected: chosen.contains(a),
              onSelected: loading || (!chosen.contains(a) && chosen.length == 4)
                  ? null
                  : (v) => setState(() {
                      if (v) {
                        chosen.add(a);
                      } else {
                        chosen.remove(a);
                      }
                    }),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<RaceSample>(
            key: const ValueKey('race-sample'),
            value: sample,
            items: [
              for (final s in RaceSample.values)
                DropdownMenuItem(value: s, child: Text(s.label)),
            ],
            onChanged: loading
                ? null
                : (s) {
                    if (s != null) setState(() => sample = s);
                  },
          ),
          DropdownButton<int>(
            value: count,
            items: [
              for (final n in [8, 10, 16, 32])
                DropdownMenuItem(value: n, child: Text('$n 项')),
            ],
            onChanged: loading
                ? null
                : (n) {
                    if (n != null) setState(() => count = n);
                  },
          ),
          TextButton(
            onPressed: loading ? null : () => setState(() => seed++),
            child: Text('换样本 · $seed'),
          ),
        ],
      ),
      Text(
        sample.generate(count, seed).join('　'),
        key: const ValueKey('race-input'),
      ),
      const SizedBox(height: 12),
      const Text('所有赛道使用同一序列和时钟。一次关键字比较、一次记录移动或基数排序的一次游标写入各占一拍。'),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          key: const ValueKey('race-start'),
          onPressed: loading || chosen.length < 2 ? null : start,
          child: Text(loading ? '生成赛道…' : '开始竞速'),
        ),
      ),
    ],
  );
  Widget _tracks() => Column(
    children: [
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${sample.label} · $tick / $end 拍'),
          IconButton(
            tooltip: clock.isAnimating ? '暂停' : '继续',
            onPressed: tick == end
                ? null
                : () => setState(() {
                    if (clock.isAnimating) {
                      clock.stop();
                    } else {
                      clock.forward();
                    }
                  }),
            icon: Icon(clock.isAnimating ? Icons.pause : Icons.play_arrow),
          ),
          TextButton(
            key: const ValueKey('race-finish'),
            onPressed: tick == end
                ? report
                : () {
                    clock.stop();
                    clock.value = 1;
                  },
            child: Text(tick == end ? '查看战报' : '跳到终点'),
          ),
          TextButton(
            onPressed: () {
              clock.stop();
              setState(() => lanes = null);
            },
            child: const Text('调整设置'),
          ),
        ],
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (ctx, c) {
            final wide = c.maxWidth >= 720;
            return GridView.count(
              padding: const EdgeInsets.all(6),
              crossAxisCount: wide ? 2 : 1,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              mainAxisExtent: wide ? 212 : 164,
              children: [
                for (final lane in lanes!)
                  _RaceTrack(
                    lane: lane,
                    beat: lane.at(tick),
                    done: tick >= lane.beats.last.tick,
                  ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

class _RaceTrack extends StatelessWidget {
  const _RaceTrack({
    required this.lane,
    required this.beat,
    required this.done,
  });
  final RaceLane lane;
  final RaceBeat beat;
  final bool done;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${lane.algorithm.label} · ${done ? "完成" : beat.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'KCN ${beat.comparisons}　 RMN ${beat.moves}${lane.algorithm == RaceAlgorithm.radix ? "　游标 ${beat.links}" : ""}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, c) {
                final n = beat.labels.length,
                    bars = n > 24,
                    cols = bars
                        ? n
                        : math.max(1, math.min(n, (c.maxWidth / 40).floor()));
                final width = c.maxWidth / cols,
                    rows = (n / cols).ceil(),
                    height = c.maxHeight / math.max(1, rows);
                final scene = SceneSnapshot(
                  nodes: [
                    for (var i = 0; i < n; i++)
                      SceneNode(
                        id: 'lane$i',
                        label: bars
                            ? beat.labels[i].split('*').first
                            : beat.labels[i],
                        x: i % cols * width,
                        y: bars ? 120 : (i ~/ cols) * height,
                        width: math.max(1, width - 2),
                        height: math.min(44, math.max(2, height - 2)),
                        visualState: beat.active.contains(i)
                            ? NodeVisualState.moving
                            : done
                            ? NodeVisualState.sorted
                            : NodeVisualState.normal,
                      ),
                  ],
                );
                return DsStageCanvas(
                  sortingRace: true,
                  scene: scene,
                  sceneSize: Size(
                    c.maxWidth,
                    bars ? math.max(c.maxHeight, 125) : c.maxHeight,
                  ),
                  nodeContentBuilder: (_, n) =>
                      Center(child: FittedBox(child: Text(n.label))),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
