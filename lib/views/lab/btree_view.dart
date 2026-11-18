import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch7_search/btree.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import '../../ui/tokens/m3e_springs.dart';
import 'lesson_player.dart';

class BTreeView extends ConsumerStatefulWidget {
  const BTreeView({super.key});
  @override
  ConsumerState<BTreeView> createState() => _BTreeViewState();
}

class _BTreeViewState extends LessonPlayer<BTreeView, MultiwayInput> {
  @override
  final module = const MultiwayModule();
  @override
  MultiwayInput input = const MultiwayInput();
  @override
  String get presetKey => 'btree-presets';
  @override
  String get theoryHint => input.plus
      ? '教材图 7.27 用子树的最大键作索引。即使命中索引键也需下降到叶页，真实记录指针全部位于叶页。'
      : '算法 7.8 同时查找页与页内位置。算法 7.9 在末层插入，溢出页的中键上推。删除内部键可用后继替换，再在末层处理下溢。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<bool>(
      key: const ValueKey('btree-mode'),
      value: input.plus,
      items: const [
        DropdownMenuItem(value: false, child: Text('B-树')),
        DropdownMenuItem(value: true, child: Text('B+树')),
      ],
      onChanged: (v) {
        if (v != null) changeInput(input.configure(plus: v));
      },
    ),
    DropdownButton<int>(
      key: const ValueKey('btree-order'),
      value: input.order,
      items: [
        for (final m in [3, 4, 5])
          DropdownMenuItem(value: m, child: Text('$m 阶')),
      ],
      onChanged: (v) {
        if (v != null) changeInput(input.configure(order: v));
      },
    ),
    TextButton.icon(
      key: const ValueKey('btree-edit'),
      icon: const Icon(Icons.edit_outlined),
      label: Text(input.plus ? '设置查询区间' : '编辑序列与操作'),
      onPressed: () async {
        final next = await showDialog<MultiwayInput>(
          context: context,
          builder: (_) => _Editor(input),
        );
        if (mounted && next != null) runCustomInput(next);
      },
    ),
  ];
  @override
  Widget stage(PlaybackState state) => _MultiwayStage(input, state);
}

class _Editor extends StatefulWidget {
  const _Editor(this.input);
  final MultiwayInput input;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late String seed = widget.input.initial.join(' '),
      ops = widget.input.operations,
      lo = '${widget.input.low}',
      hi = '${widget.input.high}';
  String? error;
  void apply() {
    try {
      final initial = seed
          .trim()
          .split(RegExp(r'[\s,，]+'))
          .where((s) => s.isNotEmpty)
          .map((v) {
            final n = int.tryParse(v);
            if (n == null) throw const FormatException('初始序列须为整数。');
            return n;
          })
          .toList();
      final low = int.tryParse(lo), high = int.tryParse(hi);
      if (widget.input.plus) {
        if (low == null || high == null || low > high) {
          throw const FormatException('闭区间需要整数，且下界应小于或等于上界。');
        }
      } else {
        MultiwayInput.parseOperations(ops);
      }
      Navigator.pop(
        context,
        MultiwayInput(
          order: widget.input.order,
          plus: widget.input.plus,
          initial: initial,
          operations: ops,
          low: low ?? widget.input.low,
          high: high ?? widget.input.high,
        ),
      );
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  Widget field(
    String id,
    String label,
    String value,
    ValueChanged<String> set, {
    String? hint,
  }) => TextFormField(
    key: ValueKey(id),
    initialValue: value,
    onChanged: set,
    decoration: InputDecoration(
      labelText: label,
      helperText: hint,
      helperMaxLines: 3,
    ),
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.input.plus ? 'B+树范围查询' : 'B-树查找、插入与删除'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        field(
          'btree-seed',
          '初始插入序列',
          seed,
          (v) => seed = v,
          hint: '用空格或逗号分隔，留空从空树开始',
        ),
        if (widget.input.plus) ...[
          field('btree-low', '下界（含）', lo, (v) => lo = v.trim()),
          field('btree-high', '上界（含）', hi, (v) => hi = v.trim()),
        ] else
          field(
            'btree-ops',
            '依次执行的操作',
            ops,
            (v) => ops = v,
            hint: '例如 +30 -12 ?47。向树中插入负数 −5 写作 +-5。',
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

class _MultiwayStage extends StatefulWidget {
  const _MultiwayStage(this.input, this.state);
  final MultiwayInput input;
  final PlaybackState state;
  @override
  State<_MultiwayStage> createState() => _MultiwayStageState();
}

class _MultiwayStageState extends State<_MultiwayStage> {
  static final spring = SpringCurve(M3eSprings.standardSpatial);
  late Size extent;
  @override
  void initState() {
    super.initState();
    measure();
  }

  @override
  void didUpdateWidget(_MultiwayStage old) {
    super.didUpdateWidget(old);
    if (!identical(old.state.timeline, widget.state.timeline)) measure();
  }

  void measure() {
    double w = 160, h = 120;
    for (final f in widget.state.timeline!.frames) {
      for (final n in f.scene.nodes) {
        w = math.max(w, n.x + n.width + 32);
        h = math.max(h, n.y + n.height + 36);
      }
    }
    extent = Size(w, h);
  }

  SceneSnapshot sceneAt(TraceFrame f, TraceFrame next, double t) {
    if (t == 0) return f.scene;
    final split = next.inlineVars['阶段'] == '分裂';
    var original = f.scene;
    if (split) {
      final source = f.scene.nodes.firstWhere(
        (n) => n.id == next.inlineVars['分裂页'],
      );
      final right = next.scene.nodes.firstWhere(
        (n) => n.id == next.inlineVars['新右页'],
      );
      original = original.copyWith(
        nodes: [
          ...original.nodes,
          right.copyWith(
            x: source.x + source.width - right.width,
            y: source.y,
            opacity: 0,
          ),
        ],
      );
    }
    final scene = SceneInterpolator.lerp(
      original,
      next.scene,
      t,
      spatialProgress: split ? spring.transform(t) : t,
    );
    final fly = split ? 'key${next.inlineVars['键']}' : null;
    return scene.copyWith(
      nodes: [
        for (final n in scene.nodes)
          if (n.groupTag == 'page') n,
        for (final n in scene.nodes)
          if (n.groupTag != 'page' && n.id != fly) n,
        if (fly != null)
          for (final n in scene.nodes)
            if (n.id == fly)
              n.copyWith(
                y: n.y - 24 * math.sin(math.pi * t),
                visualState: NodeVisualState.moving,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input,
        state = widget.state,
        f = state.currentFrame!,
        frames = state.timeline!.frames;
    final next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final scene = sceneAt(
      f,
      next,
      MediaQuery.disableAnimationsOf(context) ? 0 : state.subProgress,
    );
    final v = f.inlineVars;
    return LayoutBuilder(
      builder: (ctx, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              input.plus
                  ? '${input.order} 阶 B+树 · 非根页 ${input.minimum + 1}～${input.order} 个键'
                  : '${input.order} 阶 B-树 · 非根页 ${input.minimum} ≤ 键数 ≤ ${input.order - 1}',
              key: const ValueKey('btree-threshold'),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            Text(
              input.plus
                  ? '闭区间 [${input.low}, ${input.high}]'
                  : '操作序列　${input.operations.isEmpty ? "∅" : input.operations}',
            ),
            Text(
              f.phaseTitle,
              key: const ValueKey('btree-phase'),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            Text(f.explanation),
            SizedBox(
              height: (c.maxHeight * .68).clamp(220.0, 620.0),
              child: scene.nodes.isEmpty
                  ? const Center(child: Text('空树 ∅'))
                  : DsStageCanvas(
                      key: ObjectKey(state.timeline),
                      scene: scene,
                      sceneSize: extent,
                      nodeContentBuilder: (ctx, n) {
                        if (n.groupTag == 'page') {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 38,
                              child: Center(
                                child: FittedBox(child: Text(n.label)),
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: FittedBox(
                              child: Text(
                                n.label,
                                style: TextStyle(
                                  fontWeight: n.groupTag == 'key'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (input.plus)
              Text(
                '命中记录　${v['记录']!.isEmpty ? "∅" : v['记录']}',
                key: const ValueKey('btree-hits'),
              )
            else if (v['结果']!.isNotEmpty)
              Text('操作结果　${v['结果']}', key: const ValueKey('btree-result')),
          ],
        ),
      ),
    );
  }
}
