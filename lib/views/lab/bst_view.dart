import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'badge_event.dart';
import '../../models/study_badge.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch7_search/bst.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import '../../enum/ds_enums.dart';
import '../../ui/tokens/m3e_springs.dart';
import '../../providers/playback_provider.dart';
import 'lesson_player.dart';

class BstView extends ConsumerStatefulWidget {
  const BstView({super.key});
  @override
  ConsumerState<BstView> createState() => _BstViewState();
}

class _BstViewState extends LessonPlayer<BstView, BstInput> {
  @override
  final module = const BstModule();
  @override
  BstInput input = const BstInput();
  @override
  String get presetKey => 'bst-presets';
  @override
  String get theoryHint => input.operation == BstOperation.avl
      ? '教材 §7.3.2 · BF = 左子树高度 − 右子树高度。角标中的箭头表示从上次记录值到当前实际值，回溯到该结点时刷新记录。沿插入路径向上，首先达到 |BF| = 2 的结点就是最小不平衡子树的根。LL、RR 只需单旋，LR、RL 先旋孩子，再旋子树根。'
      : '二叉排序树的左子树关键字均小于根，右子树均大于根。中序遍历严格递增。同一组记录的插入顺序决定树高和等概率成功查找长度。删除双孩子结点时保留 p 的地址，用直接前驱的数据覆盖 p，再摘除前驱。';
  @override
  void loadInput(BstInput next) {
    super.loadInput(next);
    if (next.operation == BstOperation.avl) {
      vm.toggleBreakpoint(CodeLang.cLike, avlLockLine);
    }
  }

  BstInput? customAvl;
  @override
  void onPlaybackChange(PlaybackState? old, PlaybackState next) {
    if (!foreground ||
        !visible ||
        !identical(customAvl, input) ||
        old?.frameIndex == next.frameIndex) {
      return;
    }
    final vars = next.currentFrame!.inlineVars;
    final i = ['LL', 'RR', 'LR', 'RL'].indexOf(vars['旋转类型'] ?? '');
    if (vars['阶段'] == '旋转' && i >= 0) {
      saveBadgeEvent(
        context,
        ref
            .read(achievementRepositoryProvider)
            .milestone(StudyBadge.avlBalancer, i),
      );
    }
  }

  Future<void> edit({bool continuation = false}) async {
    final next = await showDialog<BstInput>(
      context: context,
      builder: (_) => _BstDialog(input, continuation),
    );
    if (!mounted || next == null) return;
    final previousEnd = ref.read(playbackProvider).frameIndex;
    customAvl = next.operation == BstOperation.avl ? next : null;
    runCustomInput(next);
    if (continuation && next.operation == BstOperation.avl) {
      vm.seek((previousEnd - 1).clamp(0, previousEnd).toDouble());
    }
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<BstOperation>(
      key: const ValueKey('bst-operation'),
      value: input.operation,
      items: [
        for (final op in BstOperation.values)
          DropdownMenuItem(value: op, child: Text(op.label)),
      ],
      onChanged: (op) {
        if (op != null) changeInput(input.operate(op, input.key));
      },
    ),
    TextButton.icon(
      key: const ValueKey('bst-edit'),
      onPressed: edit,
      icon: const Icon(Icons.edit_outlined),
      label: Text(
        input.operation == BstOperation.build ||
                input.operation == BstOperation.avl
            ? '编辑序列'
            : 'key = ${input.key}',
      ),
    ),
    TextButton(
      key: const ValueKey('bst-continue'),
      onPressed: state.frameIndex == state.timeline!.frames.length - 1
          ? () => edit(continuation: true)
          : null,
      child: Text(
        input.operation == BstOperation.avl
            ? '追加关键字'
            : input.operation == BstOperation.build && input.comparison != null
            ? '在树 A 上继续'
            : '在结果树上继续',
      ),
    ),
  ];
  @override
  Widget stage(PlaybackState state) => _BstStage(input: input, state: state);
}

class _BstStage extends StatefulWidget {
  const _BstStage({required this.input, required this.state});
  final BstInput input;
  final PlaybackState state;
  @override
  State<_BstStage> createState() => _BstStageState();
}

class _BstStageState extends State<_BstStage> {
  late Size extent;
  static final rotationSpring = SpringCurve(M3eSprings.standardSpatial);
  @override
  void initState() {
    super.initState();
    measure();
  }

  @override
  void didUpdateWidget(_BstStage old) {
    super.didUpdateWidget(old);
    if (!identical(widget.state.timeline, old.state.timeline)) measure();
  }

  void measure() {
    double w = 180, h = 120;
    for (final frame in widget.state.timeline!.frames) {
      for (final n in frame.scene.nodes) {
        w = math.max(w, n.x + n.width + 40);
        h = math.max(h, n.y + n.height + 40);
      }
    }
    extent = Size(w, h);
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input,
        state = widget.state,
        f = state.currentFrame!,
        frames = state.timeline!.frames;
    final next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final t = MediaQuery.disableAnimationsOf(context) ? 0.0 : state.subProgress;
    final avl = input.operation == BstOperation.avl;
    final rotating = avl && next.inlineVars['阶段'] == '旋转';
    var scene = SceneInterpolator.lerp(
      f.scene,
      next.scene,
      t,
      spatialProgress: rotating ? rotationSpring.transform(t) : t,
    );
    final balance = {
      if (avl)
        for (final row in f.scene.auxTables.last.rows)
          row.first: (int.parse(row[row.length - 2]), int.parse(row.last)),
    };
    if (t > 0 && t < 1 && next.inlineVars['阶段'] == '复制') {
      final source = scene.nodes.firstWhere(
        (n) => n.id == next.inlineVars['s'],
      );
      final dest = scene.nodes.firstWhere((n) => n.id == next.inlineVars['p']);
      scene = scene.copyWith(
        nodes: [
          ...scene.nodes,
          SceneNode(
            id: 's.data',
            label: source.label,
            x: source.x + (dest.x - source.x) * t + 5,
            y: source.y + (dest.y - source.y) * t - 24 * math.sin(math.pi * t),
            width: 38,
            height: 38,
            visualState: NodeVisualState.moving,
          ),
        ],
      );
    }
    final rows = f.scene.auxTables.first.rows,
        compare = rows.length == 2,
        vars = f.inlineVars;
    final stats = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${compare ? "树 ${row[0]}　" : ""}${row[1]} 个结点　高 ${row[2]}　成功 ASL ${row[3]}',
                  key: ValueKey('bst-stats-${row[0]}'),
                ),
                Text('中序　${row[4].isEmpty ? "∅" : row[4]}'),
              ],
            ),
          ),
        if (input.operation != BstOperation.build && !avl)
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final name in ['p', 'f', 'q', 's', 'Tᵢ'])
                if (vars.containsKey(name)) Text('$name = ${vars[name]}'),
            ],
          ),
        if (vars['路径']?.isNotEmpty == true) Text('访问路径　${vars['路径']}'),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) {
        final graph = SizedBox(
          height: (c.maxHeight * .62).clamp(235.0, 530.0),
          child: scene.nodes.isEmpty
              ? const Center(child: Text('空树 ∅'))
              : DsStageCanvas(
                  key: ObjectKey(state.timeline),
                  scene: scene,
                  sceneSize: extent,
                  nodeContentBuilder: (ctx, n) {
                    final (stored, bf) = balance[n.id] ?? (0, 0);
                    String signed(int value) =>
                        value > 0 ? '+$value' : '$value';
                    final badge = stored == bf
                        ? 'BF ${signed(bf)}'
                        : 'BF ${signed(stored)}→${signed(bf)}';
                    final content = Tooltip(
                      message:
                          '${n.id} · key = ${n.label}${avl ? " · $badge" : ""}',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: FittedBox(
                              child: Text(
                                n.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: FittedBox(
                              child: Text(
                                n.id,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (!avl) return content;
                    return Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        content,
                        Positioned(
                          top: -9,
                          right: -17,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bf.abs() >= 2
                                  ? Colors.orange.shade900
                                  : Theme.of(
                                      ctx,
                                    ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: bf.abs() >= 2
                                      ? Colors.white
                                      : Theme.of(
                                          ctx,
                                        ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                key: const ValueKey('bst-phase'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(f.explanation),
              if (vars['旋转类型'] case final type?)
                Chip(
                  label: Text(
                    '$type · ${vars['阶段']}',
                    key: const ValueKey('avl-rotation'),
                  ),
                ),
              if (input.operation == BstOperation.build || avl) ...[
                Text(
                  '${compare ? "A" : "输入"}　${BstInput.sequence(input.values)}',
                ),
                if (compare) Text('B　${BstInput.sequence(input.comparison!)}'),
                Text('已读 ${vars['已读']} 项　* 表示同关键字再次出现'),
              ],
              if (c.maxWidth >= 700)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: graph),
                    const SizedBox(width: 8),
                    Expanded(child: stats),
                  ],
                )
              else ...[
                graph,
                stats,
              ],
              if (vars['结果'] != '—')
                Text('操作结果　${vars['结果']}', key: const ValueKey('bst-result')),
            ],
          ),
        );
      },
    );
  }
}

class _BstDialog extends StatefulWidget {
  const _BstDialog(this.input, this.continuation);
  final BstInput input;
  final bool continuation;
  @override
  State<_BstDialog> createState() => _BstDialogState();
}

class _BstDialogState extends State<_BstDialog> {
  late BstOperation op =
      widget.continuation && widget.input.operation == BstOperation.build
      ? BstOperation.search
      : widget.input.operation;
  late String values = BstInput.sequence(widget.input.values),
      other = BstInput.sequence(widget.input.comparison ?? []),
      target = '${widget.input.key}';
  String? error;
  List<int> parse(String s) => s.trim().isEmpty
      ? []
      : s
            .trim()
            .split(RegExp(r'[\s,，]+'))
            .map((token) => int.parse(token.replaceFirst(RegExp(r'\*$'), '')))
            .toList();
  void apply() {
    final appendAvl = widget.continuation && op == BstOperation.avl;
    final sequence = op == BstOperation.build || op == BstOperation.avl;
    final key = sequence && !appendAvl
        ? widget.input.key
        : int.tryParse(target.trim());
    if (key == null) {
      setState(() => error = '关键字须为整数。');
      return;
    }
    try {
      if (widget.continuation) {
        Navigator.pop(
          context,
          appendAvl
              ? BstInput(
                  operation: op,
                  values: [...widget.input.values, key],
                  key: key,
                )
              : widget.input.operate(op, key, continueResult: true),
        );
        return;
      }
      final keys = parse(values);
      final next = BstInput(
        values: keys,
        operation: op,
        key: key,
        comparison: op == BstOperation.avl
            ? null
            : op != BstOperation.build
            ? widget.input.comparison
            : other.trim().isEmpty
            ? null
            : parse(other),
        history:
            op != BstOperation.build && listEquals(keys, widget.input.values)
            ? widget.input.history
            : const [],
      );
      Navigator.pop(context, next);
    } on FormatException {
      setState(() => error = '序列须为用空格或逗号分隔的整数。');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.continuation ? '在结果树上继续' : '设置初始树与操作'),
    scrollable: true,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!(widget.continuation && op == BstOperation.avl))
          DropdownButton<BstOperation>(
            key: const ValueKey('bst-dialog-operation'),
            value: op,
            items: [
              for (final x in BstOperation.values)
                if (!widget.continuation ||
                    (x != BstOperation.build && x != BstOperation.avl))
                  DropdownMenuItem(value: x, child: Text(x.label)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => op = v);
            },
          ),
        if (!widget.continuation) ...[
          TextFormField(
            key: const ValueKey('bst-values'),
            initialValue: values,
            minLines: 1,
            maxLines: 4,
            onChanged: (v) => values = v,
            decoration: const InputDecoration(
              labelText: '初始插入序列',
              helperText: '留空可从空树开始',
            ),
          ),
          if (op == BstOperation.build)
            TextFormField(
              key: const ValueKey('bst-other'),
              initialValue: other,
              onChanged: (v) => other = v,
              decoration: const InputDecoration(labelText: '对照序列（可选）'),
            ),
        ],
        if (op != BstOperation.build &&
            (op != BstOperation.avl || widget.continuation))
          TextFormField(
            key: const ValueKey('bst-key'),
            initialValue: target,
            onChanged: (v) => target = v,
            decoration: const InputDecoration(labelText: '关键字'),
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
