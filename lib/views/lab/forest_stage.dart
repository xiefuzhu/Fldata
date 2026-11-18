import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch5_tree/bitree_traverse.dart';
import '../../curriculum/ch5_tree/forest_conversion.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/playback_model.dart';
import '../../ui/tokens/m3e_springs.dart';

class ForestStage extends StatefulWidget {
  const ForestStage({super.key, required this.state});
  final PlaybackState state;
  @override
  State<ForestStage> createState() => _ForestStageState();
}

class _ForestStageState extends State<ForestStage> {
  static final spring = SpringCurve(M3eSprings.slowSpatial);
  static final effects = SpringCurve(M3eSprings.effects);
  int storage = 0;
  String? selected;
  @override
  Widget build(BuildContext context) {
    final state = widget.state,
        frames = state.timeline!.frames,
        frame = state.currentFrame!;
    final next = frames[math.min(state.frameIndex + 1, frames.length - 1)];
    final progress = state.subProgress;
    final movingBack =
        progress > 0 && state.direction == PlaybackDirection.reverse;
    final caption = progress > 0 ? next : frame;
    const undo = [
      ('断开兄弟连线', '移除同层金线，各棵树的根重新独立。'),
      ('接回其余孩子', '沿兄弟链恢复同一双亲到各个孩子的连线。'),
      ('展开二叉树', '把右兄弟移回同层，将第一个孩子放回双亲下方。'),
    ];
    final scene = MediaQuery.disableAnimationsOf(context)
        ? frame.scene
        : SceneInterpolator.lerp(
            frame.scene,
            next.scene,
            effects.transform(progress).clamp(0.0, 1.0),
            spatialProgress: spring.transform(progress),
          );
    final endpoints = [...frames.first.scene.nodes, ...frames.last.scene.nodes];
    final size = Size(
      endpoints.fold<double>(240, (w, n) => math.max(w, n.x + n.width + 40)),
      endpoints.fold<double>(150, (h, n) => math.max(h, n.y + n.height + 48)),
    );
    final table = scene.auxTables[storage], vars = frame.inlineVars;
    final one = vars['根数'] == '1';
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movingBack ? undo[state.frameIndex].$1 : caption.phaseTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(movingBack ? undo[state.frameIndex].$2 : caption.explanation),
            SizedBox(
              height: (c.maxHeight * 0.55).clamp(200.0, 530.0),
              child: scene.nodes.isEmpty
                  ? const Center(child: Text('空森林 ∅'))
                  : DsStageCanvas(
                      scene: scene,
                      sceneSize: size,
                      selectedNodeId: selected,
                      onSelect: (id) => setState(() => selected = id),
                    ),
            ),
            Text(
              '${one ? "树先根" : "森林先序"}　${vars["森林先序"]}　｜　二叉树先序　${vars["二叉先序"]}',
            ),
            Text(
              '${one ? "树后根" : "森林中序"}　${vars["森林中序"]}　｜　二叉树中序　${vars["二叉中序"]}',
            ),
            DropdownButton<int>(
              key: const ValueKey('forest-storage'),
              value: storage,
              items: [
                for (final (i, label) in ['双亲表示法', '孩子链表', '孩子兄弟表示法'].indexed)
                  DropdownMenuItem(value: i, child: Text(label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => storage = value);
              },
            ),
            if (table.rows.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 18,
                  horizontalMargin: 8,
                  showCheckboxColumn: false,
                  columns: [
                    for (final s in table.columns) DataColumn(label: Text(s)),
                  ],
                  rows: [
                    for (final row in table.rows)
                      DataRow(
                        selected: row.first == selected,
                        onSelectChanged: (_) =>
                            setState(() => selected = row.first),
                        cells: [for (final cell in row) DataCell(Text(cell))],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ForestInputDialog extends StatefulWidget {
  const ForestInputDialog({
    super.key,
    required this.sequence,
    required this.binary,
  });
  final String sequence;
  final bool binary;
  @override
  State<ForestInputDialog> createState() => _ForestInputDialogState();
}

class _ForestInputDialogState extends State<ForestInputDialog> {
  late final controller = TextEditingController(
    text: widget.binary
        ? forestBinarySequence(parseForest(widget.sequence))
        : widget.sequence,
  );
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void apply() {
    try {
      final roots = widget.binary
          ? forestFromBinary(readPreorder(controller.text))
          : parseForest(controller.text);
      Navigator.pop(
        context,
        TreeInput(
          sequence: roots.isEmpty
              ? '#'
              : roots.map((n) => n.expression).join(','),
        ),
      );
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.binary ? '编辑二叉树' : '编辑森林'),
    content: SingleChildScrollView(
      child: TextField(
        key: const ValueKey('forest-sequence'),
        controller: controller,
        decoration: InputDecoration(
          labelText: widget.binary ? '先序串（# 为空孩子）' : '森林括号式',
          helperText: widget.binary
              ? '左孩子为长子，右孩子为兄弟。'
              : '例如 A(B,C),D。单个字符表示结点，# 表示空森林。',
          helperMaxLines: 3,
          errorText: error,
          errorMaxLines: 2,
        ),
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
