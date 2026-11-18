import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/examples/linked_trace_demo.dart';
import '../../engine/examples/layout_trace_demo.dart';
import '../../engine/examples/tree_graph_trace_demo.dart';
import '../../engine/layout/graph_layout_engine.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../engine/debugger/code_debugger_pane.dart';
import '../../engine/debugger/call_stack_inspector.dart';
import '../../engine/debugger/memory_table_inspector.dart';
import '../../engine/debugger/playback_transport_bar.dart';
import '../../engine/examples/recursion_trace_demo.dart';
import '../../models/trace_model.dart';
import '../../providers/playback_provider.dart';
import '../../providers/graph_layout_provider.dart';
import '../../ui/layout/lab_workspace_layout.dart';
import '../../ui/managers/playback_actions.dart';
import '../../ui/tokens/m3e_springs.dart';

class TracePreview extends ConsumerStatefulWidget {
  const TracePreview({super.key});
  @override
  ConsumerState<TracePreview> createState() => _TracePreviewState();
}

class _TracePreviewState extends ConsumerState<TracePreview>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const demo = LinkedTraceDemo();
  static const recursionDemo = RecursionTraceDemo();
  bool followCamera = false;
  static const layoutDemo = LayoutTraceDemo();
  static const treeGraphDemo = TreeGraphTraceDemo();
  final graphPins = <String, Vec2>{};
  Vec2 grabOffset = const Vec2(x: 0, y: 0);
  int layoutRequest = 0;
  bool arrangingGraph = false;
  String? graphError;
  static final spatialCurve = SpringCurve(M3eSprings.standardSpatial);
  TraceTimeline traceFor(String id) {
    if (id == 'recursion') return recursionDemo.generateTrace(3);
    final treeGraph = treeGraphDemo.validateInput(id);
    if (treeGraph.isValid) return treeGraphDemo.generateTrace(treeGraph.value!);
    final layout = layoutDemo.validateInput(id);
    return layout.isValid
        ? layoutDemo.generateTrace(layout.value!)
        : demo.generateTrace(demo.validateInput(id).value!);
  }

  void replaceGraph(SceneSnapshot scene) {
    final timeline = ref.read(playbackProvider).timeline!;
    controller.load(
      timeline.copyWith(
        frames: [timeline.frames.single.copyWith(scene: scene)],
      ),
    );
  }

  void startNodeDrag(String id, Vec2 point) {
    final n = ref
        .read(playbackProvider)
        .currentFrame!
        .scene
        .nodes
        .firstWhere((n) => n.id == id);
    grabOffset = Vec2(
      x: point.x - n.x - n.width / 2,
      y: point.y - n.y - n.height / 2,
    );
    layoutRequest++; // Discard an older background result when direct editing starts.
    setState(() {
      arrangingGraph = false;
      graphError = null;
    });
  }

  void dragNode(String id, Vec2 point) {
    final scene = ref.read(playbackProvider).currentFrame!.scene;
    final n = scene.nodes.firstWhere((n) => n.id == id);
    final center = GraphLayoutEngine.clampCenter(
      n,
      Vec2(x: point.x - grabOffset.x, y: point.y - grabOffset.y),
    );
    setState(() => graphPins[id] = center);
    replaceGraph(
      scene.copyWith(
        nodes: [
          for (final node in scene.nodes)
            node.id == id
                ? node.copyWith(
                    x: center.x - node.width / 2,
                    y: center.y - node.height / 2,
                  )
                : node,
        ],
      ),
    );
  }

  Future<void> arrangeGraph() async {
    final request = ++layoutRequest;
    final scene = ref.read(playbackProvider).currentFrame!.scene;
    setState(() {
      arrangingGraph = true;
      graphError = null;
    });
    try {
      final result = await ref.read(graphLayoutRunnerProvider)(
        scene,
        Map.unmodifiable(graphPins),
      );
      if (mounted && request == layoutRequest) replaceGraph(result);
    } catch (error) {
      if (mounted && request == layoutRequest) {
        setState(() => graphError = '排布失败：$error');
      }
    } finally {
      if (mounted && request == layoutRequest) {
        setState(() => arrangingGraph = false);
      }
    }
  }

  late final Ticker ticker;
  Duration previous = Duration.zero;
  String input = 'normal';
  bool visible = true;
  bool foreground = true;
  PlaybackController get controller => ref.read(playbackProvider.notifier);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((elapsed) {
      final delta = elapsed - previous;
      previous = elapsed;
      controller.advance(delta);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.load(traceFor(input));
    });
  }

  void syncTicker(bool playing) {
    if (playing && visible && foreground) {
      if (!ticker.isActive) {
        previous = Duration.zero;
        ticker.start();
      }
    } else if (ticker.isActive) {
      ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    visible = TickerMode.valuesOf(context).enabled;
    syncTicker(ref.read(playbackProvider).isPlaying);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    syncTicker(ref.read(playbackProvider).isPlaying);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    super.dispose();
  }

  void command(PlaybackCommand command) {
    switch (command) {
      case PlaybackCommand.toggle:
        controller.toggle();
      case PlaybackCommand.stepBack:
        controller.stepBack();
      case PlaybackCommand.stepInto:
        controller.stepInto();
      case PlaybackCommand.nextMilestone:
        controller.nextMilestone();
      case PlaybackCommand.first:
        controller.first();
      case PlaybackCommand.last:
        controller.last();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackProvider);
    ref.listen(
      playbackProvider.select((value) => value.isPlaying),
      (_, playing) => syncTicker(playing),
    );
    final timeline = state.timeline;
    final frame = state.currentFrame;
    if (timeline == null || frame == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final next = math.min(state.frameIndex + 1, timeline.frames.length - 1);
    final scene = MediaQuery.disableAnimationsOf(context)
        ? frame.scene
        : SceneInterpolator.lerp(
            frame.scene,
            timeline.frames[next].scene,
            state.subProgress,
            spatialProgress: spatialCurve.transform(state.subProgress),
          );
    var canvasWidth = 580.0;
    var canvasHeight =
        scene.layoutMode == SceneLayoutMode.circularQueue ||
            scene.layoutMode == SceneLayoutMode.graph
        ? 400.0
        : 300.0;
    if (scene.layoutMode != SceneLayoutMode.graph && input != 'bars') {
      for (final f in timeline.frames) {
        for (final n in f.scene.nodes) {
          canvasWidth = math.max(canvasWidth, n.x + n.width + 48);
          canvasHeight = math.max(canvasHeight, n.y + n.height + 48);
        }
      }
    }
    final source = timeline.codeLines[state.language] ?? const <String>[];
    final active = frame.activeLines[state.language] ?? const <int>[];
    final firstLine = active.isEmpty ? 1 : active.first;
    final miniLines = [
      for (
        var line = firstLine;
        line <= firstLine + 1 && line <= source.length;
        line++
      )
        '$line  ${source[line - 1]}',
    ];
    return PlaybackActions(
      onCommand: command,
      enabled: true,
      child: Focus(
        autofocus: true,
        child: LabWorkspaceLayout(
          toolbar: Row(
            children: [
              Tooltip(
                message: 'TraceVM 引擎预览 · 样例不写入学习记录，教材课程尚未开放',
                child: Text(
                  '引擎预览',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                key: const ValueKey('demo-input'),
                value: input,
                items: [
                  for (final preset in [
                    ...recursionDemo.presets,
                    ...demo.presets,
                    ...treeGraphDemo.presets,
                    ...layoutDemo.presets,
                  ])
                    DropdownMenuItem(
                      value: preset.id,
                      child: Text(preset.name),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    input = value;
                    graphPins.clear();
                    layoutRequest++;
                    arrangingGraph = false;
                    graphError = null;
                  });
                  controller.load(traceFor(value));
                },
              ),
              if (scene.layoutMode == SceneLayoutMode.graph) ...[
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  key: const ValueKey('graph-relayout'),
                  onPressed: arrangingGraph ? null : arrangeGraph,
                  icon: const Icon(Icons.hub_outlined),
                  label: Text(arrangingGraph ? '后台排布中…' : '重新排布'),
                ),
                TextButton(
                  key: const ValueKey('graph-unpin'),
                  onPressed: graphPins.isEmpty
                      ? null
                      : () => setState(() {
                          graphPins.clear();
                          layoutRequest++;
                          arrangingGraph = false;
                        }),
                  child: Text('解除固定 (${graphPins.length})'),
                ),
                const Text('拖动顶点即可固定位置'),
                if (graphError != null) Text(graphError!),
              ],
            ],
          ),
          stage: DsStageCanvas(
            key: ValueKey(input),
            scene: scene,
            sceneSize: Size(canvasWidth, canvasHeight),
            followCamera: followCamera,
            onCameraInteraction: () {
              if (followCamera) setState(() => followCamera = false);
            },
            sortingRace: input == 'bars',
            pinnedIds: graphPins.keys.toSet(),
            onDragStart: startNodeDrag,
            onDrag: dragNode,
          ),
          code: CodeDebuggerPane(
            key: ValueKey('debugger-$input'),
            state: state,
            onLanguageChanged: controller.setLanguage,
            onToggleBreakpoint: controller.toggleBreakpoint,
          ),
          callStack: CallStackInspector(
            key: ValueKey('calls-$input'),
            timeline: timeline,
            frameIndex: state.frameIndex,
          ),
          memory: MemoryTableInspector(
            key: ValueKey('memory-$input'),
            scene: frame.scene,
          ),
          theory: ListView(
            key: const ValueKey('trace-theory'),
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(frame.explanation),
              const SizedBox(height: 16),
              Text(
                '读取 ${frame.metrics.reads} · 写入 ${frame.metrics.writes} · 分配 ${frame.metrics.allocations}',
              ),
              Text(
                '当前/峰值辅助空间 ${frame.metrics.auxiliarySpace}/${frame.metrics.peakAuxiliarySpace}',
              ),
              const SizedBox(height: 16),
              const Text('当前为引擎样例，不写入学习记录。教材原理与课程实验将随章节开放。'),
            ],
          ),
          miniCode: Semantics(
            button: true,
            label: '打开完整代码调试器',
            child: SizedBox(
              height: 40 * MediaQuery.textScalerOf(context).scale(1),
              child: Text(
                miniLines.isEmpty ? '暂无代码 · 点击展开检查器' : miniLines.join('\n'),
                key: const ValueKey('mini-code-text'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
          transport: PlaybackTransportBar(
            compact: true,
            state: state,
            onCommand: command,
            onSeek: controller.seek,
            onSpeed: controller.setSpeed,
            onDirection: controller.setDirection,
            followCamera: followCamera,
            onFollowCamera: (v) => setState(() => followCamera = v),
          ),
        ),
      ),
    );
  }
}
