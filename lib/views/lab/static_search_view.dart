import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch7_search/static_search.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../models/playback_model.dart';
import '../../models/trace_model.dart';
import 'lesson_player.dart';

class StaticSearchView extends ConsumerStatefulWidget {
  const StaticSearchView({super.key});
  @override
  ConsumerState<StaticSearchView> createState() => _StaticSearchState();
}

class _StaticSearchState extends LessonPlayer<StaticSearchView, SearchInput> {
  @override
  final module = const StaticSearchModule();
  @override
  SearchInput input = const SearchInput();
  SearchInput linear = const SearchInput(),
      blocks = const SearchInput(
        method: SearchMethod.block,
        groups: textbookSearchBlocks,
        key: 38,
      );
  @override
  String get presetKey => 'static-search-presets';
  @override
  String get theoryHint => switch (input.method) {
    SearchMethod.binary =>
      '图 7.2、7.3 按位序画判定树。ASL 按每次访问一个内部结点计一次关键字探测。成功时不同关键字等概率，失败时不同关键字之间及两端的间隙等概率。',
    SearchMethod.block => '图 7.4 规定块间严格有序，块内可以无序。索引比较与块内比较分别计数。',
    _ => '算法 7.1 和 7.2 都从表尾查找。语句频度分别统计边界判断、关键字比较、下标递减和哨兵写入。',
  };
  @override
  void changeInput(SearchInput next) {
    if (next.method == SearchMethod.block) {
      blocks = next;
    } else {
      linear = next;
    }
    super.changeInput(next);
  }

  Future<void> edit() async {
    final next = await showDialog<SearchInput>(
      context: context,
      builder: (_) => _InputDialog(input),
    );
    if (mounted && next != null) runCustomInput(next);
  }

  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<SearchMethod>(
      key: const ValueKey('search-method'),
      value: input.method,
      items: [
        for (final m in SearchMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) {
          changeInput(
            m == SearchMethod.block ? blocks : linear.change(method: m),
          );
        }
      },
    ),
    if (input.method == SearchMethod.block)
      DropdownButton<bool>(
        key: const ValueKey('block-index-method'),
        value: input.binaryIndex,
        items: const [
          DropdownMenuItem(value: false, child: Text('顺序索引')),
          DropdownMenuItem(value: true, child: Text('折半索引')),
        ],
        onChanged: (v) {
          if (v != null) changeInput(input.change(binaryIndex: v));
        },
      ),
    TextButton.icon(
      key: const ValueKey('search-edit'),
      onPressed: edit,
      icon: const Icon(Icons.edit_outlined),
      label: Text('key = ${input.key}'),
    ),
  ];

  @override
  Widget stage(PlaybackState state) {
    final frame = state.currentFrame!,
        scene = frame.scene,
        vars = frame.inlineVars;
    final tables = {for (final t in scene.auxTables) t.id: t};
    final strip = _Records(
      table: tables['records']!,
      sentinel: input.method == SearchMethod.sentinel,
    );
    final asl = tables['asl'],
        freq = tables['frequency'],
        index = tables['index'];
    return LayoutBuilder(
      builder: (context, c) {
        final tree = asl == null
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('折半判定树 · 圆内为位序，□ 为失败区间'),
                  SizedBox(
                    height: (c.maxHeight * .54).clamp(210.0, 450.0),
                    child: DsStageCanvas(
                      key: ValueKey(('decision-tree', input.values.length)),
                      scene: scene,
                      sceneSize: Size(
                        scene.nodes.fold<double>(
                          100,
                          (w, n) => math.max(w, n.x + n.width + 35),
                        ),
                        scene.nodes.fold<double>(
                          100,
                          (h, n) => math.max(h, n.y + n.height + 44),
                        ),
                      ),
                      nodeContentBuilder: (ctx, n) {
                        if (n.shape == NodeShape.circle) {
                          return Center(child: FittedBox(child: Text(n.label)));
                        }
                        final colors = Theme.of(ctx).colorScheme;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: n.visualState == NodeVisualState.active
                                ? colors.primaryContainer
                                : colors.surface,
                            border: Border.all(
                              color: colors.primary,
                              width: n.visualState == NodeVisualState.active
                                  ? 3
                                  : 1,
                            ),
                          ),
                          child: Center(child: Text(n.label)),
                        );
                      },
                    ),
                  ),
                ],
              );
        final stats = asl == null
            ? null
            : Column(
                key: const ValueKey('search-asl'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asl.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final row in asl.rows) Text('ASL（${row[0]}）\n${row[1]}'),
                  const Text('成功计内部结点层数；失败计外部结点层数减一。'),
                  if (vars['判定结点'] != null)
                    Text('当前路径已比较 ${frame.metrics.comparisons} 次'),
                ],
              );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frame.phaseTitle,
                key: const ValueKey('search-phase'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(frame.explanation),
              if (index != null) ...[
                Text(
                  '索引表（最大关键字 / 起始位序）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final (i, row) in index.rows.indexed)
                      Container(
                        key: ValueKey('index-block-$i'),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          color: index.highlightedRows.contains(i)
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                        ),
                        child: Text('块 ${row.first}\n${row[1]} / ${row[2]}'),
                      ),
                  ],
                ),
                if (vars['索引范围'] != null) Text('索引候选范围　${vars['索引范围']}'),
                const SizedBox(height: 8),
              ],
              strip,
              if (freq != null) ...[
                Text(freq.title, style: Theme.of(context).textTheme.titleSmall),
                Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    for (final row in [freq.columns, ...freq.rows])
                      TableRow(
                        children: [
                          for (final v in row)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                              child: Text(v),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
              if (index != null)
                Text('索引比较 ${vars['索引比较']} 次　块内比较 ${vars['块内比较']} 次'),
              if (tree != null && stats != null)
                if (c.maxWidth >= 680)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: tree),
                      const SizedBox(width: 12),
                      Expanded(child: stats),
                    ],
                  )
                else ...[
                  tree,
                  stats,
                ],
              if (vars['返回'] != '—')
                Text(
                  '查找返回位序　${vars['返回']}',
                  key: const ValueKey('search-result'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Records extends StatefulWidget {
  const _Records({required this.table, required this.sentinel});
  final AuxTableSnapshot table;
  final bool sentinel;
  @override
  State<_Records> createState() => _RecordsState();
}

class _RecordsState extends State<_Records> {
  final scroll = ScrollController();
  int? lastFocus;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.table.rows, colors = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final width = math.max(66.0, 56.0 * scale);
    final focus = rows.indexWhere(
      (r) => r[2].contains('mid') || r[2] == 'i' || r[3] == '命中',
    );
    if (focus != lastFocus) {
      lastFocus = focus;
      if (focus >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !scroll.hasClients || lastFocus != focus) return;
          final p = scroll.position;
          final x = focus * width + (widget.sentinel && focus > 0 ? 16 : 0);
          if (x < p.pixels || x + width > p.pixels + p.viewportDimension) {
            scroll.jumpTo(
              (x - (p.viewportDimension - width) / 2).clamp(
                0.0,
                p.maxScrollExtent,
              ),
            );
          }
        });
      }
    }
    if (rows.isEmpty) return const Text('空表');
    return Scrollbar(
      controller: scroll,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows) ...[
              if (widget.sentinel && row.first == '1')
                const SizedBox(width: 16),
              SizedBox(
                width: width,
                child: Column(
                  children: [
                    Text(
                      'R[${row[0]}]',
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(
                      height: 40 * scale,
                      child: CustomPaint(
                        foregroundPainter: row[3] == '哨兵'
                            ? const _SentinelBorder()
                            : null,
                        child: AnimatedContainer(
                          key: ValueKey('record-${row[0]}'),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 160),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: switch (row[3]) {
                              '哨兵' => Colors.deepPurple.shade700,
                              '比较' || '命中' => colors.primaryContainer,
                              '有效' => colors.secondaryContainer,
                              _ => colors.surfaceContainerLow,
                            },
                            border: row[3] == '哨兵'
                                ? null
                                : Border.all(color: colors.outlineVariant),
                          ),
                          child: FittedBox(
                            child: Text(
                              row[1],
                              style: TextStyle(
                                color: row[3] == '哨兵'
                                    ? Colors.white
                                    : row[3] == '排除'
                                    ? colors.outline
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (row.length > 4 && row[4].isNotEmpty)
                      Text(
                        row[4],
                        style: TextStyle(
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (row[3] == '哨兵')
                      const Text('监视哨', style: TextStyle(fontSize: 11)),
                    if (row[2].isNotEmpty)
                      Text(
                        '↑ ${row[2]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SentinelBorder extends CustomPainter {
  const _SentinelBorder();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final path = Path()..addRect(rect);
    final pen = Paint()
      ..color = Colors.deepPurple.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final metric = path.computeMetrics().first;
    for (double i = 0; i < metric.length; i += 8) {
      canvas.drawPath(
        metric.extractPath(i, math.min(i + 5, metric.length)),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_SentinelBorder old) => false;
}

class _InputDialog extends StatefulWidget {
  const _InputDialog(this.input);
  final SearchInput input;
  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  late String records = widget.input.groups
      .map((g) => g.join(' '))
      .join(widget.input.method == SearchMethod.block ? ' | ' : ' ');
  late String keyText = '${widget.input.key}';
  String? error;
  void apply() {
    final i = widget.input;
    final r = SearchInput.parse(records, keyText, i.method, i.binaryIndex);
    if (r.value case final v?) {
      Navigator.pop(context, v);
    } else {
      setState(() => error = r.error);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('查找输入'),
    scrollable: true,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          key: const ValueKey('search-records-input'),
          initialValue: records,
          minLines: 1,
          maxLines: 4,
          onChanged: (v) => records = v,
          decoration: InputDecoration(
            labelText: '记录表',
            helperText: widget.input.method == SearchMethod.block
                ? '块之间用 | 分隔'
                : '整数用空格分隔，留空表示空表',
          ),
        ),
        TextFormField(
          key: const ValueKey('search-key-input'),
          initialValue: keyText,
          onChanged: (v) => keyText = v,
          decoration: const InputDecoration(labelText: '查找关键字'),
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
      FilledButton(onPressed: apply, child: const Text('查找')),
    ],
  );
}
