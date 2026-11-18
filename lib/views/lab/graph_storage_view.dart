import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/graph_storage_module.dart';
import '../../models/playback_model.dart';
import 'graph_storage_panel.dart';
import 'graph_lesson_player.dart';

class GraphStorageView extends ConsumerStatefulWidget {
  const GraphStorageView({super.key});
  @override
  ConsumerState<GraphStorageView> createState() => _GraphStorageViewState();
}

class _GraphStorageViewState extends GraphLessonPlayer<GraphStorageView> {
  @override
  final module = const GraphStorageModule();
  @override
  GraphInputModel input = graphPresets.first.input;
  @override
  String get presetKey => 'graph-preset';
  @override
  String get theoryHint => '算法 6.1 用邻接矩阵建无向网，算法 6.2 用头插法建无向图的邻接表。有向图只更新弧尾的出边。';
  @override
  bool get startAtLast => true;
  @override
  String get replayLabel => '回放建表';
  @override
  Widget stage(PlaybackState state) {
    final frame = state.currentFrame!;
    final n = int.parse(frame.inlineVars['已录入']!);
    final storage = GraphStorage(input, n);
    final canvas = editorCanvas(frame.scene);
    final panel = GraphStoragePanel(
      input: input,
      storage: storage,
      onMark: (id) {
        if (id != marked) setState(() => marked = id);
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${input.kind.label} · ${input.vertices.length} 点 / $n 边　$editorHint',
          key: const ValueKey('graph-summary'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth >= 560) {
                return Row(
                  children: [
                    Expanded(child: canvas),
                    const VerticalDivider(width: 8),
                    Expanded(child: panel),
                  ],
                );
              }
              if (c.maxHeight < 250) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 200, child: canvas),
                      SizedBox(height: 220, child: panel),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(flex: 5, child: canvas),
                  const Divider(height: 6),
                  Expanded(flex: 4, child: panel),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
