import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../database/app_database.dart';

import '../../common/study_days.dart';

class StudyCalendar extends StatefulWidget {
  const StudyCalendar({super.key, required this.days, required this.today});
  final List<DailyStudyStats> days;
  final DateTime today;
  @override
  State<StudyCalendar> createState() => _StudyCalendarState();
}

class _StudyCalendarState extends State<StudyCalendar> {
  DateTime? selected;
  final scroll = ScrollController();
  int? positionedYear;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = studyDay(widget.today);
    final date = selected ?? today;
    final rows = {for (final day in widget.days) day.dateKey: day};
    final years = {
      today.year,
      date.year,
      for (final day in widget.days)
        if (DateTime.tryParse(day.dateKey) case final parsed?)
          if (parsed.year <= today.year) parsed.year,
    }.toList()..sort((a, b) => b.compareTo(a));
    final first = DateTime.utc(date.year);
    final start = first.subtract(Duration(days: first.weekday - 1));
    final last = DateTime.utc(date.year, 12, 31);
    final weeks = last.difference(start).inDays ~/ 7 + 1;
    final row = rows[dayKey(date)];
    final days = rows.values
        .where((r) => r.dateKey.startsWith('${date.year}-') && studied(r))
        .length;
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.surfaceContainerHighest,
      Color.lerp(scheme.surfaceContainerHighest, scheme.primary, .32)!,
      Color.lerp(scheme.surfaceContainerHighest, scheme.primary, .60)!,
      scheme.primary,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('年度学习热力图', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<int>(
              value: date.year,
              items: [
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year 年')),
              ],
              onChanged: (year) {
                if (year != null) {
                  setState(
                    () => selected = year == today.year
                        ? today
                        : DateTime.utc(year, 12, 31),
                  );
                }
              },
            ),
          ],
        ),
        Text('本年学习 $days 天 · 当前连续 ${currentStudyStreak(rows, today)} 天'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) {
            final cell = math.max(15.0, box.maxWidth / weeks);
            if (positionedYear != date.year) {
              positionedYear = date.year;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && scroll.hasClients) {
                  scroll.jumpTo(
                    ((date.difference(start).inDays ~/ 7 + 1) * cell -
                            box.maxWidth)
                        .clamp(0.0, scroll.position.maxScrollExtent),
                  );
                }
              });
            }
            return SingleChildScrollView(
              controller: scroll,
              scrollDirection: Axis.horizontal,
              child: GestureDetector(
                onTapUp: (p) {
                  final r = ((p.localPosition.dy - 21) / cell).floor();
                  if (r < 0 || r > 6) return;
                  final d = start.add(
                    Duration(days: 7 * (p.localPosition.dx / cell).floor() + r),
                  );
                  if (d.year == date.year && !d.isAfter(today)) {
                    setState(() => selected = d);
                  }
                },
                child: Semantics(
                  label: '按周排列的年度学习热力图，可通过下方日期按钮查看每日明细',
                  image: true,
                  child: CustomPaint(
                    size: Size(cell * weeks, 21 + 7 * cell),
                    painter: _CalendarPainter(
                      start,
                      last,
                      today,
                      date,
                      rows,
                      colors,
                      scheme.onSurface,
                      cell,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.event),
              label: Text(dayKey(date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(date.year, date.month, date.day),
                  firstDate: DateTime(years.last),
                  lastDate: DateTime(today.year, today.month, today.day),
                );
                if (picked != null && mounted) {
                  setState(() {
                    selected = studyDay(picked);
                    positionedYear = null;
                  });
                }
              },
            ),
            Text(
              '学习 ${math.max(row?.studyMinutes ?? 0, (row?.studySeconds ?? 0) ~/ 60)} 分钟 · 实验 ${row?.labsCompleted ?? 0} · 作答 ${row?.questionsSolved ?? 0}',
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarPainter extends CustomPainter {
  _CalendarPainter(
    this.start,
    this.last,
    this.today,
    this.selected,
    this.rows,
    this.colors,
    this.ink,
    this.cell,
  );
  final DateTime start, last, today, selected;
  final Map<String, DailyStudyStats> rows;
  final List<Color> colors;
  final Color ink;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final first = DateTime.utc(last.year);
    for (
      var date = first;
      !date.isAfter(last);
      date = date.add(const Duration(days: 1))
    ) {
      final week = date.difference(start).inDays ~/ 7;
      final x = week * cell, y = 21 + (date.weekday - 1) * cell;
      if (date.day == 1) {
        final label = TextPainter(
          text: TextSpan(
            text: '${date.month}月',
            style: TextStyle(color: ink, fontSize: 11),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, Offset(x, 0));
        label.dispose();
      }
      final row = rows[dayKey(date)];
      final activity =
          math.max(row?.studyMinutes ?? 0, (row?.studySeconds ?? 0) ~/ 60) +
          (row?.questionsSolved ?? 0) * 3 +
          (row?.labsCompleted ?? 0) * 8;
      final level = !studied(row)
          ? 0
          : activity < 15
          ? 1
          : activity < 45
          ? 2
          : 3;
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, y + 1, cell - 3, cell - 3),
        const Radius.circular(2),
      );
      paint
        ..style = PaintingStyle.fill
        ..color = date.isAfter(today)
            ? colors.first.withValues(alpha: .35)
            : colors[level];
      canvas.drawRRect(box, paint);
      if (date == selected) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = ink;
        canvas.drawRRect(box, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CalendarPainter old) =>
      !identical(old.rows, rows) ||
      old.selected != selected ||
      old.today != today ||
      old.ink != ink ||
      old.cell != cell ||
      old.colors.last != colors.last;
}
