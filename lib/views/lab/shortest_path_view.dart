import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/ch6_graph/dijkstra.dart';
import '../../curriculum/ch6_graph/floyd.dart';
import '../../curriculum/ch6_graph/graph_input.dart';
import '../../curriculum/ch6_graph/shortest_path_module.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'floyd_stage.dart';
import 'graph_lesson_player.dart';

enum _PathMethod {
  dijkstra('Dijkstra'),
  floyd('Floyd');

  const _PathMethod(this.label);
  final String label;
}

class ShortestPathView extends ConsumerStatefulWidget {
  const ShortestPathView({super.key});
  @override
  ConsumerState<ShortestPathView> createState() => _ShortestPathState();
}

class _ShortestPathState extends GraphLessonPlayer<ShortestPathView> {
  String? source;
  int? destination;
  var method = _PathMethod.dijkstra;
  @override
  GraphInputModel input = shortestPathPresets.first.input;
  @override
  ShortestPathModule get module => method == _PathMethod.floyd
      ? const FloydModule()
      : DijkstraModule(source: source);
  @override
  String get presetKey => 'shortest-preset';
  @override
  String get replayLabel => '回放最短路径';
  @override
  String get theoryHint => method == _PathMethod.floyd
      ? '算法 6.11 逐轮允许中转顶点 k。严格缩短时，终点前驱来自右段 Path[k][j]。表 6.5 给出 G₇ 的四轮结果。'
      : '算法 6.10 每轮把 S 外暂定距离最小的顶点移入 S。边权非负时，其距离即可确定。Path 保存直接前驱的数组下标，−1 表示没有前驱。';
  @override
  void loadInput(GraphInputModel next) {
    destination = null;
    if (!next.vertices.any((v) => v.id == source)) {
      source = next.vertices.firstOrNull?.id;
    }
    super.loadInput(next);
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<_PathMethod>(
      key: const ValueKey('shortest-method'),
      value: method,
      items: [
        for (final m in _PathMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) {
          method = m;
          changeInput(input);
        }
      },
    ),
    if (method == _PathMethod.dijkstra) ...[
      const SizedBox(width: 8),
      const Text('源点 '),
      DropdownButton<String>(
        key: const ValueKey('shortest-source'),
        value: source,
        items: [
          for (final v in input.vertices)
            DropdownMenuItem(value: v.id, child: Text(v.id)),
        ],
        onChanged: (v) {
          if (v != null) {
            source = v;
            changeInput(input);
          }
        },
      ),
    ],
    const SizedBox(width: 12),
    if (method == _PathMethod.dijkstra)
      TextButton(
        onPressed: () => context.push('/assessment/practice_ch6_table64'),
        child: const Text('练习表 6.4'),
      ),
    ...super.controls(state),
  ];

  @override
  Widget stage(PlaybackState state) {
    if (method == _PathMethod.floyd) {
      return FloydStage(
        state: state,
        input: input,
        editorHint: editorHint,
        canvasBuilder: (scene, backdrop) =>
            editorCanvas(scene, backdrop: backdrop),
      );
    }
    final frame = state.currentFrame!,
        vars = frame.inlineVars,
        live = frame.scene.auxTables.first,
        rounds = frame.scene.auxTables.last;
    final colors = Theme.of(context).colorScheme;
    final done = vars['阶段'] == '完成', formula = vars['松弛算式'];
    var scene = frame.scene;
    String? pathText;
    final end = destination;
    if (done && end != null) {
      final route = dijkstraRoute(
        end,
        [for (final row in live.rows) int.parse(row[3])],
        [for (final row in live.rows) int.tryParse(row[2])],
      );
      final labels = [for (final i in route) live.rows[i].first];
      pathText = route.isEmpty
          ? '$source → ${live.rows[end].first}：不可达'
          : '${labels.join(' → ')}　长度 ${live.rows[end][2]}';
      final edges = <String>{
        for (var i = 1; i < labels.length; i++)
          input.edge(labels[i - 1], labels[i])!.id,
      };
      scene = scene.copyWith(
        edges: [
          for (final e in scene.edges)
            e.copyWith(
              visualState: edges.contains(e.id)
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
        ],
      );
    }
    final tables = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rounds.title, style: Theme.of(context).textTheme.titleSmall),
        const Text('每格为 D, Path。轮次行保留选点时的值。'),
        _PathTable(data: rounds),
        const SizedBox(height: 8),
        Text(live.title, style: Theme.of(context).textTheme.titleSmall),
        _PathTable(
          data: live,
          selected: done ? destination : null,
          onSelect: done ? (i) => setState(() => destination = i) : null,
        ),
      ],
    );
    final canvas = editorCanvas(scene);
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 560;
        final area = (c.maxHeight * .68).clamp(225.0, 540.0);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: frame.isErrorState ? colors.error : null,
                ),
              ),
              Text(
                '源点 ${vars['源点']}　S = ${vars['S']}',
                key: const ValueKey('shortest-summary'),
              ),
              if (formula != null)
                Container(
                  key: const ValueKey('relax-formula'),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    formula,
                    style: TextStyle(color: colors.onTertiaryContainer),
                  ),
                ),
              Text(frame.explanation),
              if (pathText != null)
                Text(pathText, key: const ValueKey('shortest-route')),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(height: area, child: canvas),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: tables),
                  ],
                )
              else ...[
                SizedBox(height: area, child: canvas),
                tables,
              ],
              Text(editorHint),
            ],
          ),
        );
      },
    );
  }
}

class _PathTable extends StatelessWidget {
  const _PathTable({required this.data, this.selected, this.onSelect});
  final AuxTableSnapshot data;
  final int? selected;
  final ValueChanged<int>? onSelect;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget cell(String value) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(value, softWrap: false),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: colors.outlineVariant),
        children: [
          TableRow(
            decoration: BoxDecoration(color: colors.surfaceContainerHighest),
            children: data.columns.map(cell).toList(),
          ),
          for (final (i, row) in data.rows.indexed)
            TableRow(
              decoration: BoxDecoration(
                color: selected == i || data.highlightedRows.contains(i)
                    ? colors.secondaryContainer
                    : null,
              ),
              children: [
                for (final (j, value) in row.indexed)
                  onSelect == null
                      ? cell(value)
                      : InkWell(
                          key: j == 0 ? ValueKey('route-to-$value') : null,
                          onTap: () => onSelect!(i),
                          child: cell(value),
                        ),
              ],
            ),
        ],
      ),
    );
  }
}
