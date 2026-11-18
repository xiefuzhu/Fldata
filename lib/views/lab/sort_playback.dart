import 'package:flutter/material.dart';
import '../../engine/layout/swap_trajectory.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/trace_model.dart';

SceneSnapshot interpolateSort(TraceFrame current, TraceFrame next, double t) {
  final scene = SceneInterpolator.lerp(current.scene, next.scene, t);
  final a = int.tryParse(next.inlineVars['来源'] ?? ''),
      b = int.tryParse(next.inlineVars['目标'] ?? '');
  if (t <= 0 || t >= 1 || a == null || b == null || a == b) return scene;
  final source = current.scene.nodes[a], dest = next.scene.nodes[b];
  final pos = SwapTrajectory.position(
    Vec2(x: source.x, y: source.y),
    Vec2(x: dest.x, y: dest.y),
    t,
  );
  return scene.copyWith(
    nodes: [
      ...scene.nodes,
      if (next.inlineVars.containsKey("双向"))
        _returningRecord(source, dest, current.scene.nodes[b].label, t),
      SceneNode(
        id: 'record-copy',
        label: source.label,
        x: pos.x,
        y: pos.y,
        width: source.width,
        height: source.height,
        shape: NodeShape.arraySlot,
        visualState: NodeVisualState.moving,
      ),
    ],
  );
}

SceneNode _returningRecord(
  SceneNode left,
  SceneNode right,
  String label,
  double t,
) {
  final p = SwapTrajectory.position(
    Vec2(x: right.x, y: right.y),
    Vec2(x: left.x, y: left.y),
    t,
  );
  return SceneNode(
    id: 'record-return',
    label: label,
    x: p.x,
    y: p.y,
    width: right.width,
    height: right.height,
    shape: NodeShape.arraySlot,
    visualState: NodeVisualState.moving,
  );
}

Widget sortStabilityResult(
  BuildContext context,
  List<int> keys,
  Map<String, String> v,
  ValueChanged<int> onJump,
) {
  final witness = int.tryParse(v['逆序帧'] ?? '');
  if (witness != null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          key: const ValueKey('sort-unstable'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          label: Text(
            '不稳定 (Unstable)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
        Text('关键字 ${v['逆序键']} 的原位序 ${v['原位序']} 已逆序。'),
        TextButton(
          key: const ValueKey('sort-jump'),
          onPressed: () => onJump(witness),
          child: Text('查看跨位帧 ${witness + 1}'),
        ),
      ],
    );
  }
  return Text(
    keys.toSet().length == keys.length ? '本例无相等关键字' : '本例保持同键记录的原始次序',
    key: const ValueKey('sort-stable'),
  );
}
