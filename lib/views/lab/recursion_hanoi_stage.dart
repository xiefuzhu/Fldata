import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch3_stack_queue/recursion_hanoi.dart';
import '../../curriculum/ch3_stack_queue/recursion_trace.dart';
import '../../models/trace_model.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/debugger/call_tree_projection.dart';

class RecursionHanoiStage extends StatelessWidget {
  const RecursionHanoiStage({
    super.key,
    required this.timeline,
    required this.frameIndex,
    required this.progress,
    required this.input,
  });
  final TraceTimeline timeline;
  final int frameIndex;
  final double progress;
  final RecursionInput input;
  @override
  Widget build(BuildContext context) {
    final frame = timeline.frames[frameIndex],
        next = timeline
            .frames[math.min(frameIndex + 1, timeline.frames.length - 1)];
    final row = frame.scene.auxTables.first.rows.first;
    final hanoi = input.kind == RecursionKind.hanoi,
        traverse = input.kind == RecursionKind.traverse;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text('调用 ${row[0]} · 深度 ${frame.callStack.length}'),
                  ),
                  if (hanoi)
                    Chip(
                      key: const ValueKey('hanoi-moves'),
                      label: Text('搬移 ${row[1]} / ${(1 << input.n) - 1}'),
                    ),
                  if (!hanoi && !traverse)
                    Chip(
                      key: const ValueKey('recursion-result'),
                      label: Text('结果：${row[2]}'),
                    ),
                ],
              ),
              if (hanoi)
                SizedBox(
                  height: (c.maxHeight * .42).clamp(180, 320),
                  child: HanoiBoard(
                    scene: interpolateHanoi(frame.scene, next.scene, progress),
                  ),
                ),
              if (traverse) ...[
                SizedBox(
                  height: 200,
                  child: DsStageCanvas(
                    key: ValueKey(input.raw),
                    scene: frame.scene,
                    sceneSize: Size(
                      math.max(400, input.values.length * 112 + 100),
                      220,
                    ),
                  ),
                ),
                Text(
                  '输出：${row[3].isEmpty ? '—' : row[3]}',
                  key: const ValueKey('recursion-output'),
                ),
              ],
              if (!hanoi && !traverse)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    frame.callStack.isEmpty
                        ? 'Main 收到结果 ${row[2]}'
                        : frame.callStack
                              .map(
                                (r) => '${r.functionName}(${r.arguments['n']})',
                              )
                              .join(' → '),
                    key: const ValueKey('recursion-chain'),
                  ),
                ),
              Text(frame.explanation),
              const SizedBox(height: 8),
              Text(
                '递归调用树 · 当前 / 等待 / 已返回',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(
                height: (c.maxHeight * .38).clamp(200, 300),
                child: RecursionTree(
                  timeline: timeline,
                  frameIndex: frameIndex,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '活动记录峰值 ${frame.metrics.maxCallDepth} · 每次调用单独保存参数和局部；回退会移除未来调用。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HanoiBoard extends StatelessWidget {
  const HanoiBoard({super.key, required this.scene});
  final SceneSnapshot scene;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '汉诺塔三柱；${scene.auxTables.last.rows.map((r) => '${r[0]}：${r[1].isEmpty ? '空' : r[1]}').join('；')}',
    child: CustomPaint(
      key: const ValueKey('hanoi-board'),
      painter: _HanoiPainter(scene, Theme.of(context).colorScheme),
      size: Size.infinite,
    ),
  );
}

class _HanoiPainter extends CustomPainter {
  _HanoiPainter(this.scene, this.colors);
  final SceneSnapshot scene;
  final ColorScheme colors;
  static const palette = [
    Color(0xff78dce8),
    Color(0xffa9dc76),
    Color(0xffffd866),
    Color(0xffffa568),
    Color(0xffab9df2),
    Color(0xffff80a5),
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 660, size.height / 320);
    canvas.save();
    canvas.translate(
      (size.width - 660 * scale) / 2,
      (size.height - 320 * scale) / 2,
    );
    canvas.scale(scale);
    final paint = Paint()..color = colors.outlineVariant;
    void text(String text, double x, double y, Color color) {
      final p = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p.paint(canvas, Offset(x - p.width / 2, y));
    }

    for (var i = 0; i < 3; i++) {
      final x = 110.0 + 220 * i;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 4, 82, 8, 200),
          const Radius.circular(4),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 96, 282, 192, 7),
          const Radius.circular(3),
        ),
        paint,
      );
      text('ABC'[i], x, 295, colors.onSurface);
    }
    for (final n in scene.nodes) {
      final disk = int.parse(n.label);
      paint.color = palette[disk - 1];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(n.x, n.y, n.width, n.height),
          const Radius.circular(10),
        ),
        paint,
      );
      text(n.label, n.x + n.width / 2, n.y + 1, const Color(0xff182028));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HanoiPainter old) =>
      old.scene != scene || old.colors != colors;
}

class RecursionTree extends StatefulWidget {
  const RecursionTree({
    super.key,
    required this.timeline,
    required this.frameIndex,
  });
  final TraceTimeline timeline;
  final int frameIndex;
  @override
  State<RecursionTree> createState() => _RecursionTreeState();
}

class _RecursionTreeState extends State<RecursionTree> {
  late CallTreeProjection projection;
  late SceneSnapshot scene;
  late Size size;
  String? selected;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void didUpdateWidget(RecursionTree old) {
    super.didUpdateWidget(old);
    if (!identical(old.timeline, widget.timeline) ||
        old.frameIndex != widget.frameIndex) {
      refresh();
    }
  }

  void refresh() {
    projection = CallTreeProjection(widget.timeline, widget.frameIndex);
    final projected = projection.scene;
    scene = projected.copyWith(
      nodes: [
        for (final n in projected.nodes)
          projection.activeIds.contains(n.id)
              ? n
              : n.copyWith(visualState: NodeVisualState.normal),
      ],
    );
    size = Size(
      scene.nodes.fold<double>(400, (v, n) => math.max(v, n.x + n.width + 32)),
      scene.nodes.fold<double>(200, (v, n) => math.max(v, n.y + n.height + 44)),
    );
    if (!projection.records.containsKey(selected)) selected = null;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: DsStageCanvas(
          scene: scene,
          sceneSize: size,
          selectedNodeId: selected ?? projection.topId,
          onSelect: (id) => setState(() => selected = id),
        ),
      ),
      if (selected != null)
        Text(
          '${projection.records[selected]!.functionName} · RetLoc ${projection.records[selected]!.returnLocation} · ${projection.records[selected]!.locals}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
    ],
  );
}

class RecursionStackPanel extends StatelessWidget {
  const RecursionStackPanel({super.key, required this.frame});
  final TraceFrame frame;
  @override
  Widget build(BuildContext context) {
    final event = frame.scene.auxTables[1].rows.first,
        colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (event[0].isNotEmpty)
          Card(
            color: colors.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '已弹出 ${event[0]} → ${event[1]}；返回 ${event[2]}',
                key: const ValueKey('recursion-return-event'),
              ),
            ),
          ),
        const Text('系统工作栈 · 栈顶在前'),
        if (frame.callStack.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Main · 活动栈已空'),
          ),
        for (final r in frame.callStack.reversed)
          Card(
            key: ValueKey('recursion-record-${r.id}'),
            color: r == frame.callStack.last
                ? colors.secondaryContainer
                : colors.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r.functionName} · ${r.id}${r == frame.callStack.last ? ' · 栈顶' : ''}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '形参：${r.arguments.entries.map((e) => '${e.key}=${e.value}').join('，')}',
                  ),
                  Text('返回到：${r.returnLocation}'),
                  Text(
                    '当前 PC：${r.locals['PC']}',
                    key: ValueKey('recursion-pc-${r.id}'),
                    style: TextStyle(
                      color: r == frame.callStack.last
                          ? colors.primary
                          : colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (r.locals.keys.any((k) => k != 'PC'))
                    Text(
                      '局部：${r.locals.entries.where((e) => e.key != 'PC').map((e) => '${e.key}=${e.value}').join('，')}',
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class RecursionTheory extends StatelessWidget {
  const RecursionTheory({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('每次调用都是独立活动记录。子记录的“返回到”是调用者中恢复执行的位置；上层的“当前 PC”表示本层此刻执行/等待的位置，两者不同。'),
      SizedBox(height: 8),
      Text(
        'Hanoi(n,A,B,C)：先 Hanoi(n−1,A,C,B)，返回 RetLoc1 后 move(A,n,C)，再 Hanoi(n−1,B,A,C)，返回 RetLoc2 后返回上级。根调用返回 Main。盘号越大尺寸越大；每次只移动柱顶，不可大盘压小盘。',
      ),
      SizedBox(height: 8),
      Text(
        '汉诺塔移动次数 T(n)=2T(n−1)+1=2^n−1，时间 Θ(2^n)，活动栈峰值 n，辅助空间 O(n)。阶乘时间/栈空间 O(n)，0!=1；朴素 Fib(1)=Fib(2)=1，时间 Θ(φ^n)、栈空间 O(n)，重复调用不做记忆化。',
      ),
      SizedBox(height: 8),
      Text(
        'TraverseList 先输出 data 再递归 next，NULL 为基例，正向输出。n 个节点有 n+1 次调用，时间/栈空间 O(n)。动画和历史树保存所有已出现调用，其内存不等于算法的活动栈辅助空间。教学代码为重建实现。',
      ),
    ],
  );
}
