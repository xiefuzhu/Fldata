import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'badge_event.dart';
import '../../models/study_badge.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch5_tree/huffman_expr.dart';
import '../../curriculum/ch5_tree/huffman_tree.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import '../../ui/tokens/m3e_springs.dart';
import 'lesson_player.dart';

class HuffmanExprView extends ConsumerStatefulWidget {
  const HuffmanExprView({super.key});
  @override
  ConsumerState<HuffmanExprView> createState() => _HuffmanExprState();
}

class _HuffmanExprState
    extends LessonPlayer<HuffmanExprView, ApplicationInput> {
  @override
  final module = const HuffmanExprModule();
  @override
  ApplicationInput input = const ApplicationInput();
  @override
  String get presetKey => 'huffman-preset';
  ApplicationInput? customDecode;
  @override
  void onPlaybackChange(PlaybackState? old, PlaybackState next) {
    final frame = next.currentFrame;
    if (visible &&
        foreground &&
        identical(input, customDecode) &&
        frame?.phaseTitle == '译码结束' &&
        frame?.inlineVars['输出'] == input.message) {
      customDecode = null;
      saveBadgeEvent(
        context,
        ref
            .read(achievementRepositoryProvider)
            .unlock(StudyBadge.huffmanCompressor),
      );
    }
  }

  bool get expression => input.mode == TreeApplication.expression;
  @override
  String get theoryHint => expression
      ? 'EXPT 保存子树根。形成表达式树以后，递归求出左右子树的值，再执行根上的运算。除法按整数向零取整。'
      : 'HT 从 1 开始编号。每一次合并都使两棵子树的所有叶子增加一层，合并权重之和等于 WPL。左边记 0，右边记 1。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<bool>(
      key: const ValueKey('application-mode'),
      value: expression,
      items: const [
        DropdownMenuItem(value: false, child: Text('哈夫曼编码')),
        DropdownMenuItem(value: true, child: Text('表达式树')),
      ],
      onChanged: (value) {
        if (value != null) {
          changeInput(
            input.withMode(
              value ? TreeApplication.expression : TreeApplication.construction,
            ),
          );
        }
      },
    ),
    TextButton.icon(
      onPressed: () async {
        final result = await showDialog<ApplicationInput>(
          context: context,
          builder: (_) => _ApplicationEditor(input),
        );
        if (result != null && mounted) runCustomInput(result);
      },
      icon: const Icon(Icons.edit_outlined),
      label: Text(expression ? '编辑表达式' : '编辑权值'),
    ),
    if (input.mode == TreeApplication.decode)
      TextButton(
        onPressed: () =>
            changeInput(input.withMode(TreeApplication.construction)),
        child: const Text('重看构造'),
      ),
  ];
  @override
  Widget stage(PlaybackState state) => _ApplicationStage(
    key: ValueKey(input),
    state: state,
    input: input,
    onDecode: (message, edited) {
      final decoded = input.withMode(TreeApplication.decode, message: message);
      customDecode =
          message.isNotEmpty && (edited || identical(input, customDecode))
          ? decoded
          : null;
      runCustomInput(decoded);
      vm.play();
    },
  );
}

class _ApplicationEditor extends StatefulWidget {
  const _ApplicationEditor(this.input);
  final ApplicationInput input;
  @override
  State<_ApplicationEditor> createState() => _EditorState();
}

class _EditorState extends State<_ApplicationEditor> {
  bool get expr => widget.input.mode == TreeApplication.expression;
  late final text = TextEditingController(
    text: expr
        ? widget.input.expression
        : widget.input.weights.entries
              .map((e) => '${e.key}:${e.value}')
              .join(' '),
  );
  String? error;
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void apply() {
    try {
      final i = widget.input;
      if (expr) {
        Navigator.pop(
          context,
          i.withMode(TreeApplication.expression, expression: text.text),
        );
      } else {
        final weights = parseWeights(text.text);
        Navigator.pop(
          context,
          i.withMode(
            TreeApplication.construction,
            weights: weights,
            message:
                i.message.runes.every(
                  (c) => weights.containsKey(String.fromCharCode(c)),
                )
                ? i.message
                : '',
          ),
        );
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(expr ? '编辑表达式' : '编辑权值'),
    content: TextField(
      key: const ValueKey('application-input'),
      controller: text,
      decoration: InputDecoration(
        labelText: expr ? '中缀表达式，以 # 结束' : '字符:权值，以空格分隔',
        errorText: error,
        errorMaxLines: 3,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: apply, child: const Text('应用')),
    ],
  );
}

class _ApplicationStage extends StatefulWidget {
  const _ApplicationStage({
    super.key,
    required this.state,
    required this.input,
    required this.onDecode,
  });
  final PlaybackState state;
  final ApplicationInput input;
  final void Function(String message, bool edited) onDecode;
  @override
  State<_ApplicationStage> createState() => _ApplicationStageState();
}

class _ApplicationStageState extends State<_ApplicationStage> {
  static final spring = SpringCurve(M3eSprings.slowSpatial);
  late final codec = HuffmanTree.build(widget.input.weights);
  bool editedPlain = false;
  late final plain = TextEditingController(text: widget.input.message);
  late final extent = measure();
  Size measure() {
    double w = 240, h = 120;
    for (final f in widget.state.timeline!.frames) {
      for (final n in f.scene.nodes) {
        w = math.max(w, n.x + n.width + 36);
        h = math.max(h, n.y + n.height + 36);
      }
    }
    return Size(w, h);
  }

  @override
  void dispose() {
    plain.dispose();
    super.dispose();
  }

  Widget matrix(AuxTableSnapshot table) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 30,
        dataRowMaxHeight: 56,
        columnSpacing: 12,
        horizontalMargin: 6,
        columns: [for (final c in table.columns) DataColumn(label: Text(c))],
        rows: [
          for (final (i, r) in table.rows.indexed)
            DataRow(
              color: table.highlightedRows.contains(i)
                  ? WidgetStatePropertyAll(Colors.amber.withValues(alpha: .35))
                  : null,
              cells: [for (final value in r) DataCell(Text(value))],
            ),
        ],
      ),
    );
  }

  Widget encoder() {
    String? error;
    var bits = '';
    try {
      bits = codec.encode(plain.text);
    } on FormatException catch (e) {
      error = e.message;
    }
    final fixed = plain.text.runes.length * codec.fixedWidth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('huffman-plain'),
          controller: plain,
          onChanged: (_) => setState(() => editedPlain = true),
          decoration: InputDecoration(labelText: '明文', errorText: error),
        ),
        if (error == null) ...[
          SelectableText('比特流　$bits', key: const ValueKey('huffman-bits')),
          Text(
            '定长 $fixed 位　哈夫曼 ${bits.length} 位${fixed == 0 ? '' : '　占定长 ${(100 * bits.length / fixed).toStringAsFixed(1)}%'}',
          ),
        ],
        FilledButton.tonal(
          onPressed: error == null
              ? () => widget.onDecode(plain.text, editedPlain)
              : null,
          child: const Text('逐位走树译码'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state,
        f = state.currentFrame!,
        frames = state.timeline!.frames,
        v = f.inlineVars;
    final expr = widget.input.mode == TreeApplication.expression,
        decode = widget.input.mode == TreeApplication.decode;
    final scene = MediaQuery.disableAnimationsOf(context)
        ? f.scene
        : SceneInterpolator.lerp(
            f.scene,
            frames[math.min(state.frameIndex + 1, frames.length - 1)].scene,
            state.subProgress,
            spatialProgress: spring.transform(state.subProgress),
          );
    return LayoutBuilder(
      builder: (context, c) {
        final canvas = SizedBox(
          height: (c.maxHeight * .57).clamp(220.0, 680.0),
          child: DsStageCanvas(scene: scene, sceneSize: extent),
        );
        final ht = f.scene.auxTables.first;
        final htPanel = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(ht.title), matrix(ht)],
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    f.phaseTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (!expr)
                    Text(
                      'WPL = ${v["WPL"]}${v.containsKey("树高") ? "　树高 ${v["树高"]}" : ""}',
                    ),
                ],
              ),
              if (expr) ...[
                Text('OPTR　${v["OPTR"]}'),
                Text('EXPT　${v["EXPT"]}'),
                Text('当前输入　${v["当前输入"]}　 后序　${v["后序"]}'),
              ] else if (v.containsKey('s1'))
                Text('s1 = ${v["s1"]}　s2 = ${v["s2"]}'),
              if (decode) ...[
                Text('已读 ${v["位序"]} / ${v["比特流"]!.length} 位'),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: v['比特流']!.substring(0, int.parse(v['位序']!)),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: v['比特流']!.substring(int.parse(v['位序']!))),
                    ],
                  ),
                ),
                Text('译出　${v["输出"]}', key: const ValueKey('huffman-output')),
              ],
              if (!expr && !decode && c.maxWidth >= 720)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 2, child: htPanel),
                    Expanded(flex: 3, child: canvas),
                  ],
                )
              else
                canvas,
              Text(f.explanation),
              if (expr && v.containsKey('结果'))
                Text('结果　${v["结果"]}', key: const ValueKey('expression-result')),
              if (!expr) ...[
                if (decode || state.frameIndex == frames.length - 1) encoder(),
                if (!decode && c.maxWidth < 720) htPanel,
                Text(f.scene.auxTables[1].title),
                matrix(f.scene.auxTables[1]),
              ],
            ],
          ),
        );
      },
    );
  }
}
