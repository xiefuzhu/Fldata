part of 'hash_table_view.dart';

class _HashStage extends StatefulWidget {
  const _HashStage(this.input, this.playback);
  final HashInput input;
  final PlaybackState playback;
  @override
  State<_HashStage> createState() => _HashStageState();
}

class _HashStageState extends State<_HashStage> {
  late HashStorage table;
  late HashAsl asl;
  int page = 0;
  static const pageSize = 16;
  Map<String, String> get vars => widget.playback.currentFrame!.inlineVars;
  int? get active => int.tryParse(vars['地址'] ?? '');
  @override
  void initState() {
    super.initState();
    refresh();
    page = (active ?? 0) ~/ pageSize;
  }

  @override
  void didUpdateWidget(_HashStage old) {
    super.didUpdateWidget(old);
    final reset = !identical(old.playback.timeline, widget.playback.timeline);
    final previous = old.playback.currentFrame!.inlineVars;
    if (reset || vars['版本'] != previous['版本']) refresh();
    if (reset || vars['地址'] != previous['地址'] && active != null) {
      page = (active ?? 0) ~/ pageSize;
    }
  }

  void refresh() {
    table = HashStorage.fromScene(
      widget.input,
      widget.playback.currentFrame!.scene,
    );
    asl = table.analyze();
  }

  Widget slots(BuildContext ctx) {
    final colors = Theme.of(ctx).colorScheme, m = widget.input.m;
    final start = page * pageSize, end = math.min(start + pageSize, m);
    final cells = <Widget>[];
    for (var a = start; a < end; a++) {
      final values = table.cells[a], isActive = a == active;
      if (table.chained) {
        final depth = int.tryParse(vars['链位'] ?? '');
        Widget item(String text, bool highlighted) => DecoratedBox(
          decoration: BoxDecoration(
            color: highlighted
                ? colors.primaryContainer
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(text),
          ),
        );
        cells.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 3,
              children: [
                item('HT[$a]', isActive),
                for (var j = 0; j < (values?.length ?? 0); j++) ...[
                  const Text('→'),
                  item('${values![j]}', isActive && j == depth),
                ],
                const Text('→'),
                item('NULL', isActive && depth == (values?.length ?? 0)),
              ],
            ),
          ),
        );
      } else {
        final dead = values?.isEmpty == true;
        final cluster =
            widget.input.collision == HashCollision.linear &&
            values != null &&
            m > 1 &&
            (table.cells.containsKey((a + 1) % m) ||
                table.cells.containsKey((a - 1) % m));
        final label = dead ? 'DELETED' : values?.firstOrNull?.toString() ?? '∅';
        final bg = dead
            ? const Color(0xff645a73)
            : cluster
            ? Colors.orange.shade200
            : colors.surfaceContainerHighest;
        final fg = dead
            ? Colors.white
            : cluster
            ? Colors.black
            : colors.onSurface;
        cells.add(
          Container(
            key: ValueKey('hash-slot-$a'),
            width: 66,
            height: 62,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? colors.primary : colors.outlineVariant,
                width: isActive ? 3 : 1,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('[$a]', style: TextStyle(color: fg, fontSize: 11)),
                  if (dead) Icon(Icons.bookmark, color: fg, size: 14),
                  Text(
                    label,
                    style: TextStyle(color: fg, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m > pageSize)
          _Pager(
            start,
            end,
            m,
            () => setState(() => page--),
            () => setState(() => page++),
          ),
        table.chained
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cells,
              )
            : Wrap(spacing: 3, runSpacing: 3, children: cells),
        if (widget.input.collision == HashCollision.linear)
          const Text('橙色表示连续占用的探测区段；删除标记也会延续区段。'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.playback.currentFrame!, v = vars;
    return LayoutBuilder(
      builder: (ctx, c) {
        final panel = _AslPanel(
          key: ObjectKey(widget.playback.timeline),
          table: table,
          asl: asl,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'm = ${widget.input.m}　p = ${widget.input.p}　α = ${asl.success.length}/${widget.input.m}',
                key: const ValueKey('hash-params'),
              ),
              if (!table.chained)
                Text(
                  'Hᵢ = (H₀ + dᵢ) mod m　·　dᵢ = ${List.generate(math.min(6, widget.input.m), table.offsetAt).join("，")}${widget.input.m > 6 ? "，…" : ""}',
                ),
              Text(
                '${v['操作']}　${f.phaseTitle}',
                key: const ValueKey('hash-phase'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              if (v['公式']!.isNotEmpty && v['阶段'] != '散列') Text(v['公式']!),
              Text(f.explanation),
              if (v['路径']!.isNotEmpty)
                Text(
                  '${table.chained ? "链内检查" : "探测地址"}　${v['路径']}',
                  key: const ValueKey('hash-path'),
                ),
              const SizedBox(height: 8),
              if (c.maxWidth >= 680)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: slots(ctx)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: panel),
                  ],
                )
              else ...[
                slots(ctx),
                const Divider(),
                panel,
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager(this.start, this.end, this.total, this.back, this.forward);
  final int start, end, total;
  final VoidCallback back, forward;
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      IconButton(
        onPressed: start == 0 ? null : back,
        tooltip: '上一页',
        icon: const Icon(Icons.chevron_left),
      ),
      Text('${start + 1}–$end / $total'),
      IconButton(
        onPressed: end >= total ? null : forward,
        tooltip: '下一页',
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class _AslPanel extends StatefulWidget {
  const _AslPanel({super.key, required this.table, required this.asl});
  final HashStorage table;
  final HashAsl asl;
  @override
  State<_AslPanel> createState() => _AslPanelState();
}

class _AslPanelState extends State<_AslPanel> {
  bool miss = true;
  int page = 0;
  int? selected;
  @override
  Widget build(BuildContext context) {
    final asl = widget.asl,
        table = widget.table,
        total = miss ? asl.entries : asl.success.length;
    final lastPage = total == 0 ? 0 : (total - 1) ~/ 12;
    final current = math.min(page, lastPage),
        start = current * 12,
        end = math.min(total, start + 12);
    String mean(int sum, int count) {
      if (count == 0) return '—（空表）';
      final decimal = double.parse((sum / count).toStringAsFixed(3));
      final exact = 1000 % (count ~/ count.gcd(sum)) == 0;
      return '$sum/$count ${exact ? "=" : "≈"} $decimal';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('平均查找长度', style: Theme.of(context).textTheme.titleMedium),
        Text(
          '成功 ASL　${mean(asl.successSum, asl.success.length)}',
          key: const ValueKey('hash-asl-success'),
        ),
        Text(
          '失败 ASL　${mean(asl.failureSum, asl.entries)}',
          key: const ValueKey('hash-asl-failure'),
        ),
        Text(
          '失败时按 ${asl.entries} 个初始地址等权平均。${table.chained ? "链尾 NULL 计一次。" : "空槽与墓碑均计一次探测。"}',
        ),
        DropdownButton<bool>(
          key: const ValueKey('hash-detail'),
          value: miss,
          items: const [
            DropdownMenuItem(value: true, child: Text('逐入口 · 失败')),
            DropdownMenuItem(value: false, child: Text('逐关键字 · 成功')),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() {
                miss = v;
                page = 0;
                selected = null;
              });
            }
          },
        ),
        if (total > 12)
          _Pager(
            start,
            end,
            total,
            () => setState(() {
              page = current - 1;
              selected = null;
            }),
            () => setState(() {
              page = current + 1;
              selected = null;
            }),
          ),
        for (var i = start; i < end; i++)
          Builder(
            builder: (ctx) {
              final h = miss ? i : asl.success[i].$2,
                  key = miss ? null : asl.success[i].$1;
              final count = miss ? asl.failureAt(h) : asl.success[i].$3;
              return InkWell(
                onTap: () =>
                    setState(() => selected = selected == i ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${miss ? "入口 $h" : "键 $key · 入口 $h"}　$count 次'),
                      if (selected == i)
                        Text(
                          table
                              .probe(h, key)
                              .map(
                                (v) => table.chained
                                    ? (v.value?.toString() ?? "NULL")
                                    : '${v.address}',
                              )
                              .join(' → '),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
