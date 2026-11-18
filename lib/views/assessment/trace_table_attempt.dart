import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/ch8_sort/textbook_sort_pass.dart';
import '../../features/assessment/trace_table_grader.dart';
import '../../models/quiz_question.dart';
import '../../providers/app_providers.dart';
import 'critical_edge_picker.dart';
import '../../curriculum/achievement_practice.dart';
import 'sort_answer_slots.dart';

class TraceTableAttempt extends ConsumerStatefulWidget {
  const TraceTableAttempt({super.key, required this.question});
  final TraceTableQuestion question;
  @override
  ConsumerState<TraceTableAttempt> createState() => _AttemptState();
}

class _AttemptState extends ConsumerState<TraceTableAttempt> {
  TraceTableQuestion get q => widget.question;
  bool get sorting => q.id == sortTableId;
  int get pageSize => sorting ? 1 : 6;
  int get pageCount => (q.rowLabels.length + pageSize - 1) ~/ pageSize;
  late final rows = [
    for (final row in q.answerRows) List.filled(row.length, ''),
  ];
  final edges = <String>{}, clock = Stopwatch()..start();
  static const grader = TraceTableGrader();
  TraceTableGrade? grade;
  int page = 0, revision = 0;
  bool saving = false, checkedRow = false, usedHelp = false;
  String? error;
  bool get locked => saving || grade != null;
  bool get hasInput =>
      edges.isNotEmpty || rows.any((r) => r.any((v) => v.trim().isNotEmpty));

  Future<void> submit() async {
    if (locked || !hasInput) return;
    final marked = grader.grade(q, rows, edges: edges);
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(quizRepositoryProvider)
          .recordAttempt(
            questionId: q.id,
            chapterId: q.chapterId,
            type: q.type,
            isCorrect: marked.complete,
            score: marked.score,
            answer: {
              'rows': [
                for (final r in rows) [...r],
              ],
              if (TraceTableGrader.hasEdgeSet(q))
                'criticalEdges': edges.toList()..sort(),
            },
            durationMs: clock.elapsedMilliseconds,
            quality: marked.complete
                ? (usedHelp ? 3 : 4)
                : marked.score >= 70
                ? 2
                : 1,
          );
      if (mounted) {
        setState(() {
          grade = marked;
          clock.stop();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '作答保存失败，可重试。$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void reset() => setState(() {
    for (final row in rows) {
      row.fillRange(0, row.length, '');
    }
    usedHelp = false;
    edges.clear();
    grade = null;
    checkedRow = false;
    page = 0;
    revision++;
    error = null;
    clock
      ..reset()
      ..start();
  });
  void setPage(int p) => setState(() {
    page = p;
    checkedRow = false;
  });
  void edit(int r, int c, String value) => setState(() {
    rows[r][c] = value;
    checkedRow = false;
  });
  void toggleEdge(String edge) => setState(() {
    if (!edges.remove(edge)) edges.add(edge);
  });
  Future<void> replay() async {
    usedHelp = true;
    final pass = TextbookSortPass.forRow(q, page);
    await context.push(
      Uri(
        path: '/lab/${pass.module}',
        queryParameters: {'exercise': q.id, 'row': '$page'},
      ).toString(),
    );
  }

  Widget cell(int r, int c) {
    final mark = grade?.cells[r][c], fixed = TraceTableGrader.isFixed(q, r, c);
    if (fixed) return const Center(child: Text('—'));
    if (TraceTableGrader.isEdgeCell(q, r, c)) {
      final edge = TraceTableGrader.edgeId(q, r);
      return FilterChip(
        label: Text(edges.contains(edge) ? '已选 $edge' : '未选 $edge'),
        selected: edges.contains(edge),
        avatar: mark == null ? null : Icon(mark ? Icons.check : Icons.close),
        onSelected: locked ? null : (_) => toggleEdge(edge),
      );
    }
    final infinity = q.id == dijkstraTableId && q.rowLabels[r].endsWith('距离 D');
    final message = mark == false ? grader.feedback(q, r, c) : '';
    final field = _AnswerCell(
      key: ValueKey('trace-$revision-$r-$c'),
      value: rows[r][c],
      name: '${q.rowLabels[r]} · ${q.columns[c]}',
      enabled: !locked,
      onChanged: (v) => edit(r, c, v),
      infinity: infinity,
      mark: mark,
    );
    return message.isEmpty ? field : Tooltip(message: message, child: field);
  }

  Widget grid() {
    final start = page * pageSize,
        end = (start + pageSize).clamp(0, rows.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 112.0;
        final cellWidth =
            ((constraints.maxWidth - labelWidth) / q.columns.length).clamp(
              118.0,
              300.0,
            );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            columnWidths: {
              0: const FixedColumnWidth(labelWidth),
              for (var c = 0; c < q.columns.length; c++)
                c + 1: FixedColumnWidth(cellWidth),
            },
            children: [
              TableRow(
                children: [
                  for (final title in [
                    q.id == kmpTableId ? 'j · T[j]' : '项目',
                    ...q.columns,
                  ])
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
              for (var r = start; r < end; r++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(q.rowLabels[r]),
                    ),
                    for (var c = 0; c < q.columns.length; c++)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: cell(r, c),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget sortRow() {
    final row = rows[page],
        marks =
            grade?.cells[page] ??
            (checkedRow
                ? [
                    for (final (i, v) in row.indexed)
                      grader.equivalent(q.answerRows[page][i], v),
                  ]
                : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const Text('点格子键入记录，或载入题干序列后拖动两个格子交换位置。16 与 16* 分别代表两条记录。'),
        SortAnswerSlots(
          values: row,
          marks: marks,
          edit: locked ? null : (c, v) => edit(page, c, v),
          swap: locked
              ? null
              : (a, b) => setState(() {
                  final saved = row[a];
                  row[a] = row[b];
                  row[b] = saved;
                  checkedRow = false;
                }),
        ),
        if (marks != null)
          Text(
            '本趟对位 ${marks.where((m) => m == true).length}/${marks.length} · 参考序列 ${q.answerRows[page].join("　")}',
          ),
        Wrap(
          spacing: 8,
          children: [
            if (!locked)
              TextButton(
                onPressed: () => setState(() {
                  row.setAll(0, exerciseSortLabels);
                  checkedRow = false;
                }),
                child: const Text('载入题干序列'),
              ),
            if (!locked)
              TextButton(
                onPressed: row.every((v) => v.isEmpty)
                    ? null
                    : () => setState(() {
                        checkedRow = true;
                        usedHelp = true;
                      }),
                child: const Text('核对本趟'),
              ),
            OutlinedButton.icon(
              onPressed: replay,
              icon: const Icon(Icons.science_outlined),
              label: const Text('实验室对照本趟'),
            ),
          ],
        ),
      ],
    );
  }

  String pageLabel(int i) {
    if (sorting) return q.rowLabels[i];
    final first = i * pageSize, last = (first + pageSize).clamp(0, rows.length);
    return '第 ${first + 1}～$last 行';
  }

  @override
  Widget build(BuildContext context) {
    final marks = grade;
    final firstWrong =
        marks?.cells.indexWhere((row) => row.contains(false)) ?? -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        if (q.id == 'textbook_ch5_2_04')
          const Text('HT 从 1 编号，空指针填 0，待写入权值填 —。合并两根后，下标较小者作左孩子。'),
        if (TraceTableGrader.hasEdgeSet(q))
          CriticalEdgePicker(
            parallel: q.id == parallelAoeId,
            edges: edges,
            toggle: locked ? null : toggleEdge,
          ),
        if (pageCount > 1)
          Row(
            children: [
              IconButton(
                tooltip: '上一组',
                onPressed: page == 0 ? null : () => setPage(page - 1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: DropdownButton<int>(
                  key: const ValueKey('trace-page'),
                  isExpanded: true,
                  value: page,
                  items: [
                    for (var i = 0; i < pageCount; i++)
                      DropdownMenuItem(value: i, child: Text(pageLabel(i))),
                  ],
                  onChanged: (i) {
                    if (i != null) setPage(i);
                  },
                ),
              ),
              IconButton(
                tooltip: '下一组',
                onPressed: page + 1 >= pageCount
                    ? null
                    : () => setPage(page + 1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        if (sorting) sortRow() else grid(),
        if (marks != null) ...[
          Text(
            '${marks.score} 分 · 答对 ${marks.hits}/${marks.total} 项',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (marks.edgeSetCorrect != null)
            Text(
              marks.edgeSetCorrect!
                  ? '关键活动集合正确'
                  : '关键活动集合有误，参考集合为 ${[for (final (r, label) in q.rowLabels.indexed)
                      if (label.startsWith("活动 ") && q.answerRows[r].last == "是") TraceTableGrader.edgeId(q, r)].join("、")}。',
            ),
          if (firstWrong >= 0 && page != firstWrong ~/ pageSize)
            TextButton(
              onPressed: () => setPage(firstWrong ~/ pageSize),
              child: const Text('定位首个错格'),
            ),
          if (!sorting)
            for (
              var r = page * pageSize;
              r < (page + 1) * pageSize && r < rows.length;
              r++
            )
              for (var c = 0; c < q.columns.length; c++)
                if (marks.cells[r][c] == false &&
                    !TraceTableGrader.isEdgeCell(q, r, c))
                  Text(grader.feedback(q, r, c)),
          Text(q.explanationMarkdown),
        ],
        if (error != null) Text(error!),
        Align(
          alignment: Alignment.centerLeft,
          child: marks != null
              ? OutlinedButton(onPressed: reset, child: const Text('重新推演'))
              : FilledButton(
                  onPressed: saving || !hasInput ? null : submit,
                  child: Text(saving ? '正在保存' : '提交整题'),
                ),
        ),
      ],
    );
  }
}

class _AnswerCell extends StatefulWidget {
  const _AnswerCell({
    super.key,
    required this.value,
    required this.name,
    required this.enabled,
    required this.onChanged,
    required this.infinity,
    required this.mark,
  });
  final String value, name;
  final bool enabled, infinity;
  final bool? mark;
  final ValueChanged<String> onChanged;
  @override
  State<_AnswerCell> createState() => _AnswerCellState();
}

class _AnswerCellState extends State<_AnswerCell> {
  late final controller = TextEditingController(text: widget.value);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.name,
    child: TextField(
      controller: controller,
      readOnly: !widget.enabled,
      minLines: 1,
      maxLines: 4,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: widget.mark != null
            ? Icon(
                widget.mark! ? Icons.check : Icons.close,
                color: widget.mark!
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              )
            : widget.infinity
            ? TextButton(
                onPressed: !widget.enabled
                    ? null
                    : () {
                        controller.text = '∞';
                        widget.onChanged('∞');
                      },
                child: const Text('∞'),
              )
            : null,
      ),
    ),
  );
}
