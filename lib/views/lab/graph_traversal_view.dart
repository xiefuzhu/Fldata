import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/graph_traversal.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'graph_lesson_player.dart';
import 'six_degree_stage.dart';
import '../../curriculum/ch6_graph/six_degrees.dart';
import '../../engine/vm/algorithm_module.dart';

class GraphTraversalView extends ConsumerStatefulWidget {
  const GraphTraversalView({super.key, this.sixDegrees = false});
  final bool sixDegrees;
  @override
  ConsumerState<GraphTraversalView> createState() => _GraphTraversalState();
}

class _GraphTraversalState extends GraphLessonPlayer<GraphTraversalView> {
  var mode = TraversalMode.matrix;
  String? source;
  late bool six = widget.sixDegrees;
  bool editing = false;
  var rule = SixDegreeRule.distance;
  var traversalGraph = textbookG4, socialGraph = communityNetwork;
  String? traversalSource, socialSource;
  @override
  bool get showGraphTools => !six || editing;
  void toggleCase(bool value) {
    if (value) {
      traversalGraph = input;
      traversalSource = source;
      source = socialSource;
    } else {
      socialGraph = input;
      socialSource = source;
      source = traversalSource;
    }
    six = value;
    editing = false;
    changeInput(six ? socialGraph : traversalGraph);
  }

  void choosePerson(String id) {
    source = id;
    changeInput(input);
    vm.play(direction: PlaybackDirection.forward);
  }

  @override
  GraphInputModel input = textbookG4;
  @override
  AlgorithmModule<GraphInputModel> get module => six
      ? SixDegreeModule(rule: rule, source: source)
      : GraphTraversalModule(mode: mode, source: source);
  @override
  String get presetKey => 'traversal-presets';
  @override
  String get replayLabel => six ? '回放六度空间' : '回放遍历';
  @override
  String get theoryHint => six
      ? '案例 6.2 按人数统计触达比例。教材算法 6.14 将源点标为已访问，Vis_Num 从零开始；第 185 页印刷循环至多出队七人。六层 BFS 以最短距离为界。'
      : '算法 6.3 从一个起点深搜，6.4 依次补访尚未访问的根。算法 6.5 逐列查矩阵，算法 6.6 沿 firstarc / nextarc 深搜。算法 6.7 在首次入队时标记顶点，再按队首次序访问邻接链。';
  TraceTimeline? laidOut;
  late SceneSnapshot forest;
  late Size forestSize;

  @override
  void loadInput(GraphInputModel next) {
    if (!next.vertices.any((v) => v.id == source)) {
      source = next.vertices.firstOrNull?.id;
    }
    super.loadInput(next);
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    FilterChip(
      key: const ValueKey('six-case'),
      label: const Text('六度空间'),
      selected: six,
      onSelected: toggleCase,
    ),
    const SizedBox(width: 8),
    if (six)
      DropdownButton<SixDegreeRule>(
        key: const ValueKey('six-rule'),
        value: rule,
        items: [
          for (final r in SixDegreeRule.values)
            DropdownMenuItem(value: r, child: Text(r.label)),
        ],
        onChanged: (r) {
          if (r != null) {
            rule = r;
            changeInput(input);
          }
        },
      )
    else
      DropdownButton<TraversalMode>(
        key: const ValueKey('traversal-mode'),
        value: mode,
        items: [
          for (final m in TraversalMode.values)
            DropdownMenuItem(value: m, child: Text(m.label)),
        ],
        onChanged: (m) {
          if (m != null) {
            mode = m;
            changeInput(input);
          }
        },
      ),
    const SizedBox(width: 12),
    const Text('起点 '),
    DropdownButton<String>(
      key: const ValueKey('traversal-source'),
      value: source,
      items: [
        for (final v in input.vertices)
          DropdownMenuItem(value: v.id, child: Text(v.id)),
      ],
      onChanged: (s) {
        if (s != null) {
          if (six) {
            choosePerson(s);
          } else {
            source = s;
            changeInput(input);
          }
        }
      },
    ),
    const SizedBox(width: 12),
    if (six)
      IconButton(
        tooltip: editing ? '查看六度传播' : '编辑网络',
        icon: Icon(editing ? Icons.radar : Icons.edit_outlined),
        onPressed: () {
          vm.pause();
          setState(() => editing = !editing);
        },
      ),
    ...super.controls(state),
  ];

  void layoutForest(TraceTimeline timeline) {
    if (identical(timeline, laidOut)) return;
    final scene = timeline.frames.last.scene;
    final rows = scene.auxTables.singleWhere((t) => t.id == 'forest').rows;
    final original = {for (final n in scene.nodes) n.id: n};
    forest = TreeReingoldLayout.arrange(
      SceneSnapshot(
        nodes: [for (final row in rows) original[row[0]]!],
        edges: [
          for (final row in rows)
            if (row[1] != '∅')
              SceneEdge(
                id: 'parent-${row[0]}',
                fromNodeId: row[1],
                toNodeId: row[0],
                visualState: NodeVisualState.sorted,
              ),
        ],
      ),
      levelGap: 32,
    );
    forestSize = Size(
      forest.nodes.fold<double>(160, (w, n) => math.max(w, n.x + n.width + 32)),
      forest.nodes.fold<double>(
        150,
        (h, n) => math.max(h, n.y + n.height + 32),
      ),
    );
    laidOut = timeline;
  }

  SceneSnapshot visibleForest(TraceFrame frame) {
    final visited = frame.scene.auxTables
        .singleWhere((t) => t.id == 'forest')
        .rows
        .map((r) => r[0])
        .toSet();
    return forest.copyWith(
      nodes: [
        for (final n in forest.nodes)
          if (visited.contains(n.id))
            n.copyWith(
              visualState: n.id == frame.inlineVars['v']
                  ? NodeVisualState.active
                  : NodeVisualState.sorted,
            ),
      ],
      edges: [
        for (final e in forest.edges)
          if (visited.contains(e.toNodeId)) e,
      ],
    );
  }

  @override
  Widget stage(PlaybackState state) {
    final timeline = state.timeline!,
        f = state.currentFrame!,
        vars = f.inlineVars;
    if (six) {
      return SixDegreeStage(
        state: state,
        rule: rule,
        onSource: choosePerson,
        editor: editing ? editorCanvas(f.scene, traversal: true) : null,
        editorHint: editorHint,
      );
    }
    layoutForest(timeline);
    final next = timeline
        .frames[math.min(timeline.frames.length - 1, state.frameIndex + 1)];
    final tree =
        state.subProgress == 0 || MediaQuery.disableAnimationsOf(context)
        ? visibleForest(f)
        : SceneInterpolator.lerp(
            visibleForest(f),
            visibleForest(next),
            state.subProgress,
          );
    final scan = f.scene.auxTables.singleWhere((t) => t.id == 'scan');
    final bfs = mode == TraversalMode.breadth;
    Widget pane(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Expanded(child: child),
      ],
    );
    final graph = pane(
      '原图 · $editorHint',
      editorCanvas(f.scene, traversal: true),
    );
    final result = pane(
      '${bfs ? '广度' : '深度'}优先生成森林',
      tree.nodes.isEmpty
          ? const Center(child: Text('等待访问起点'))
          : DsStageCanvas(
              key: const ValueKey('traversal-forest'),
              scene: tree,
              sceneSize: forestSize,
              traversalEdges: true,
            ),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 560;
        final height = (c.maxHeight * (wide ? 0.60 : 0.37)).clamp(200.0, 500.0);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('访问序列　${vars['访问序列']!.isEmpty ? '∅' : vars['访问序列']}'),
              Text(
                '${bfs ? '队列（队首在左）' : '递归路径'}　${(vars[bfs ? '队列' : '递归路径'] ?? '').isEmpty ? '∅' : vars[bfs ? '队列' : '递归路径']}',
              ),
              if (wide)
                SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      Expanded(child: graph),
                      const VerticalDivider(width: 10),
                      Expanded(child: result),
                    ],
                  ),
                )
              else ...[
                SizedBox(height: height, child: graph),
                SizedBox(height: height, child: result),
              ],
              const Text('绿色实线为树边，灰色虚线为已检查的非树边。'),
              Text('${scan.title}　累计检查 ${f.metrics.reads} 次'),
              if (scan.rows.isNotEmpty)
                _ScanStrip(table: scan, matrix: mode == TraversalMode.matrix),
              Text(f.explanation),
            ],
          ),
        );
      },
    );
  }
}

class _ScanStrip extends StatefulWidget {
  const _ScanStrip({required this.table, required this.matrix});
  final AuxTableSnapshot table;
  final bool matrix;
  @override
  State<_ScanStrip> createState() => _ScanStripState();
}

class _ScanStripState extends State<_ScanStrip> {
  final scroller = ScrollController();
  @override
  void dispose() {
    scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final table = widget.table, index = table.highlightedRows.firstOrNull;
    final extent = 76.0 * MediaQuery.textScalerOf(context).scale(1);
    if (index != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !scroller.hasClients ||
            index != widget.table.highlightedRows.firstOrNull) {
          return;
        }
        final p = scroller.position,
            start = index * extent,
            end = start + extent;
        if (start < p.pixels || end > p.pixels + p.viewportDimension) {
          scroller.jumpTo(
            (start < p.pixels ? start : end - p.viewportDimension).clamp(
              0,
              p.maxScrollExtent,
            ),
          );
        }
      });
    }
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: scroller,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, row) in table.rows.indexed)
            Container(
              key: ValueKey('scan-slot-$i'),
              width: extent,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: index == i
                    ? colors.tertiaryContainer
                    : colors.surfaceContainerLow,
                border: Border.all(color: colors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.matrix
                    ? '${row[0]}\n${row[1]}'
                    : '${row[1]} →\n${row[0]}',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
