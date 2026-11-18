import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch8_sort/external_sort.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';

class ExternalSortView extends ConsumerStatefulWidget {
  const ExternalSortView({super.key});
  @override
  ConsumerState<ExternalSortView> createState() => _ExternalState();
}

class _ExternalState extends LessonPlayer<ExternalSortView, ExternalInput> {
  @override
  final module = const ExternalModule();
  @override
  ExternalInput input = const ExternalInput.merge();
  @override
  String get presetKey => 'external-presets';
  double? sampleMean;
  @override
  String get theoryHint => switch (input.method) {
    ExternalMethod.merge => '冠军保存在 ls[0]。其他内部结点保存败者的路号，每次只替换冠军所在路的外结点，然后沿父链重赛。',
    ExternalMethod.replacement =>
      'WA 的每槽记录带段号。新键小于 MINIMAX 时冻结到下一段，同键仍可留在当前段。随机输入和长文件的稳态期望段长约 2w。',
    ExternalMethod.optimal =>
      '段权表示物理块数。每次归并读取和写出相同数量的块，每片叶的权值乘深度得到它对 WPL 的贡献。零权虚段占据树的位置。',
  };
  @override
  void changeInput(ExternalInput next) {
    sampleMean = null;
    super.changeInput(next);
    if (next.padding > 0) {
      vm.seek(1);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('补入零权虚段'),
          content: Text(
            'm = ${next.keys.length}，k = ${next.width}。已补入 ${next.padding} 个零权虚段，叶数为 ${next.keys.length + next.padding}，首次归并会优先取出虚段。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('查看归并树'),
            ),
          ],
        ),
      );
    }
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<ExternalMethod>(
      key: const ValueKey('external-method'),
      value: input.method,
      items: [
        for (final m in ExternalMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) {
          changeInput(
            module.presets.firstWhere((p) => p.input.method == m).input,
          );
        }
      },
    ),
    TextButton.icon(
      key: const ValueKey('external-edit'),
      onPressed: () async {
        final next = await showDialog<ExternalInput>(
          context: context,
          builder: (_) => _ExternalEditor(input),
        );
        if (mounted && next != null) runCustomInput(next);
      },
      icon: const Icon(Icons.edit_outlined),
      label: const Text('设置输入'),
    ),
  ];
  @override
  Widget stage(PlaybackState state) {
    final f = state.currentFrame!,
        timeline = state.timeline!,
        frames = timeline.frames,
        next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final t = MediaQuery.disableAnimationsOf(context) ? 0.0 : state.subProgress;
    var scene = SceneInterpolator.lerp(f.scene, next.scene, t);
    final v = next.inlineVars, phase = v['阶段'];
    if (t > 0 && t < 1 && (phase == '比赛' || phase == '冠军')) {
      final duel = phase == '比赛',
          child = duel ? v['子位'] : '1',
          target = duel ? v['t'] : '0',
          slot = duel ? v['挑战者'] : v['胜者'];
      final a = f.scene.nodes.firstWhere((n) => n.id == 'pos$child'),
          z = next.scene.nodes.firstWhere((n) => n.id == 'pos$target');
      scene = scene.copyWith(
        nodes: [
          ...scene.nodes,
          SceneNode(
            id: 'advancing',
            label: '$slot',
            x: a.x + (z.x - a.x) * t,
            y: a.y + (z.y - a.y) * t,
            width: 38,
            height: 34,
            shape: NodeShape.circle,
            visualState: NodeVisualState.moving,
          ),
        ],
      );
    }
    final w = scene.nodes.fold(
          180.0,
          (s, n) => math.max(s, n.x + n.width + 34),
        ),
        h = scene.nodes.fold(150.0, (s, n) => math.max(s, n.y + n.height + 54));
    final vars = f.inlineVars,
        optimal = input.method == ExternalMethod.optimal,
        wa = input.method == ExternalMethod.replacement;
    return LayoutBuilder(
      builder: (ctx, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.phaseTitle, style: Theme.of(ctx).textTheme.titleMedium),
            Text(f.explanation),
            Wrap(
              spacing: 12,
              children: [
                for (final name in [
                  's',
                  't',
                  '胜者',
                  '段号',
                  'MINIMAX',
                  'm',
                  'k',
                  'u',
                ])
                  if (vars[name] != null) Text('$name = ${vars[name]}'),
              ],
            ),
            SizedBox(
              height: math.min(h, math.max(268.0, c.maxHeight * .67)),
              child: DsStageCanvas(
                key: ObjectKey(timeline),
                scene: scene,
                sceneSize: Size(w, h),
                nodeContentBuilder: (ctx, n) {
                  final label = Center(
                    child: FittedBox(
                      child: Text(
                        n.label,
                        style: TextStyle(
                          color: n.groupTag == 'virtual'
                              ? Colors.black87
                              : n.visualState == NodeVisualState.sentinel
                              ? Colors.white
                              : null,
                        ),
                      ),
                    ),
                  );
                  return n.groupTag == 'virtual'
                      ? CustomPaint(
                          painter: const _DummyPainter(),
                          child: label,
                        )
                      : label;
                },
              ),
            ),
            if (optimal)
              Text(
                'WPL　${vars['WPL']}　　外存读写　${vars['读写次数']} 块次',
                key: const ValueKey('external-io'),
              )
            else ...[
              Text(
                '外存记录　读 ${f.metrics.reads}　写 ${f.metrics.writes}　　比赛 ${f.metrics.comparisons} 次',
              ),
              for (final row in f.scene.auxTables.last.rows)
                Text('${row[0]}（${row[1]} 条）　${row[2]}'),
              if (wa) ...[
                Text(
                  'FI 剩余　${f.scene.auxTables.firstWhere((t) => t.id == "input").rows.single[1]}',
                ),
                if (vars['阶段'] == '完成')
                  Text(
                    '本例平均段长　${f.scene.auxTables.last.rows.isEmpty ? "0" : (input.keys.length / f.scene.auxTables.last.rows.length).toStringAsFixed(2)}',
                  ),
                TextButton(
                  key: const ValueKey('external-sample'),
                  onPressed: () => setState(
                    () => sampleMean = sampledRunLength(input.width),
                  ),
                  child: const Text('测量 4096 条随机记录'),
                ),
                if (sampleMean != null)
                  Text(
                    '固定种子 81，平均段长 ${sampleMean!.toStringAsFixed(2)}，2w = ${2 * input.width}。',
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DummyPainter extends CustomPainter {
  const _DummyPainter();
  @override
  void paint(Canvas c, Size size) {
    final center = size.center(Offset.zero),
        r = math.min(size.width, size.height) / 2;
    c.drawCircle(center, r, Paint()..color = Colors.grey.shade200);
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r - 2));
    final metric = path.computeMetrics().first;
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey.shade700;
    for (var i = 0.0; i < metric.length; i += 9) {
      c.drawPath(metric.extractPath(i, math.min(i + 5, metric.length)), pen);
    }
  }

  @override
  bool shouldRepaint(_DummyPainter oldDelegate) => false;
}

class _ExternalEditor extends StatefulWidget {
  const _ExternalEditor(this.input);
  final ExternalInput input;
  @override
  State<_ExternalEditor> createState() => _ExternalEditorState();
}

class _ExternalEditorState extends State<_ExternalEditor> {
  late String data = widget.input.method == ExternalMethod.merge
      ? widget.input.runs.map((r) => r.isEmpty ? '[]' : r.join(' ')).join('\n')
      : widget.input.keys.join(' ');
  late String parameter = widget.input.width.toString();
  String? error;
  @override
  Widget build(BuildContext context) {
    final method = widget.input.method;
    return AlertDialog(
      scrollable: true,
      title: Text('设置${method.label}输入'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const ValueKey('external-data'),
            initialValue: data,
            onChanged: (s) => data = s,
            minLines: method == ExternalMethod.merge ? 3 : 1,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: switch (method) {
                ExternalMethod.merge => '输入顺串（每行一路）',
                ExternalMethod.replacement => '外存输入 FI',
                ExternalMethod.optimal => '各段长度（物理块）',
              },
              helperText: method == ExternalMethod.merge
                  ? '每路非降序，空路用 [] 表示'
                  : '整数用空格或逗号分隔',
              helperMaxLines: 3,
            ),
          ),
          if (method != ExternalMethod.merge)
            TextFormField(
              key: const ValueKey('external-param'),
              initialValue: parameter,
              onChanged: (s) => parameter = s,
              decoration: InputDecoration(
                labelText: method == ExternalMethod.replacement
                    ? '工作区容量 w'
                    : '归并路数 k',
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
        FilledButton(
          onPressed: () {
            try {
              Navigator.pop(
                context,
                ExternalInput.parse(method, data, parameter),
              );
            } on FormatException catch (e) {
              setState(() => error = e.message);
            }
          },
          child: const Text('开始推演'),
        ),
      ],
    );
  }
}
