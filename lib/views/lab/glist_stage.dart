import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch4_string_array_glist/glist_explorer.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/trace_model.dart';

class GListStage extends StatelessWidget {
  const GListStage({
    super.key,
    required this.input,
    required this.frame,
    required this.next,
    required this.progress,
  });
  final GListInput input;
  final TraceFrame frame, next;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final scene = SceneInterpolator.lerp(frame.scene, next.scene, progress);
    final size = Size(
      scene.nodes.fold<double>(
        210,
        (right, n) => math.max(right, n.x + n.width + 40),
      ),
      scene.nodes.fold<double>(
        120,
        (bottom, n) => math.max(bottom, n.y + n.height + 50),
      ),
    );
    final vars = frame.inlineVars;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vars['当前值']!,
                key: const ValueKey('glist-value'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('长度 ${vars["长度"]}　深度 ${vars["深度"]}'),
              Text(frame.phaseTitle),
              if (scene.nodes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('L → NULL（空表）'),
                )
              else
                SizedBox(
                  height: (c.maxHeight - 120).clamp(170.0, 550.0),
                  child: DsStageCanvas(
                    key: ValueKey((input.expression, input.mode, vars['操作数'])),
                    scene: scene,
                    sceneSize: size,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
