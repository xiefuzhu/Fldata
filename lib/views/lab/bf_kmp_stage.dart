import 'package:flutter/material.dart';
import '../../curriculum/ch4_string_array_glist/bf_kmp.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/trace_model.dart';

class BfKmpStage extends StatelessWidget {
  const BfKmpStage({
    super.key,
    required this.frame,
    required this.next,
    required this.progress,
    required this.input,
  });
  final TraceFrame frame, next;
  final double progress;
  final MatchInput input;
  @override
  Widget build(BuildContext context) {
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final rows = frame.scene.auxTables.last.rows;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (input.mode != MatchMode.compare)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('${frame.phaseTitle}　${frame.explanation}'),
              ),
            if (input.mode == MatchMode.compare)
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (row[0] == 'KMP' && row.last.startsWith('锁定'))
                        const Icon(Icons.lock_outline, size: 18),
                      Text(
                        '${row[0]}　i=${row[1]}　j=${row[2]}　比较 ${row[3]} 次　${row.last}',
                      ),
                    ],
                  ),
                ),
            SizedBox(
              height: (c.maxHeight - 85).clamp(180.0, 520.0),
              child: DsStageCanvas(
                key: ValueKey((
                  input.mode,
                  input.text,
                  input.pattern,
                  input.optimized,
                )),
                scene: scene,
                backdropPainter: input.mode == MatchMode.prefix
                    ? _BorderRanges(scene)
                    : null,
                sceneSize: switch (input.mode) {
                  MatchMode.compare => Size(
                    BfKmpModule.canvasWidth(input),
                    500,
                  ),
                  MatchMode.prefix => Size(
                    175 + 60.0 * input.pattern.length,
                    340,
                  ),
                  MatchMode.rotations => Size(
                    100 +
                        55.0 *
                            [
                              input.text.length,
                              2 * input.pattern.length,
                              5,
                            ].reduce((a, b) => a > b ? a : b),
                    360,
                  ),
                },
              ),
            ),
            if (input.mode == MatchMode.rotations && rows.isNotEmpty)
              Wrap(
                spacing: 12,
                children: [
                  for (final row in rows)
                    Text('${row[0]}. ${row[1]} → ${row[2]}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _BorderRanges extends CustomPainter {
  const _BorderRanges(this.scene);
  final SceneSnapshot scene;
  @override
  void paint(Canvas canvas, Size size) {
    for (final (prefix, state, color) in [
      ('前缀-', NodeVisualState.sorted, const Color(0xff248a4d)),
      ('后缀-', NodeVisualState.active, const Color(0xff287bc1)),
    ]) {
      final cells = scene.nodes.where(
        (n) => n.id.startsWith(prefix) && n.visualState == state,
      );
      if (cells.isEmpty) continue;
      final first = cells.first, last = cells.last;
      final bounds = Rect.fromLTRB(
        first.x - 4,
        first.y - 4,
        last.x + last.width + 4,
        last.y + last.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(9)),
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_BorderRanges old) => !identical(old.scene, scene);
}
