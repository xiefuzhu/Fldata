import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/catalog.dart';
import '../../database/app_database.dart';

class MasteryRadar extends StatefulWidget {
  const MasteryRadar({super.key, required this.rows});
  final List<ChapterMastery> rows;
  @override
  State<MasteryRadar> createState() => _MasteryRadarState();
}

class _MasteryRadarState extends State<MasteryRadar> {
  int selection = 0;
  @override
  Widget build(BuildContext context) {
    final byId = {for (final r in widget.rows) r.chapterId: r};
    final scores = [
      for (final c in chapters) byId[c.id.name]?.overallMastery ?? 0.0,
    ];
    final scheme = Theme.of(context).colorScheme;
    final row = byId[chapters[selection].id.name];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('八章掌握度', style: Theme.of(context).textTheme.titleMedium),
        Center(
          child: Semantics(
            image: true,
            label: '八章掌握度雷达图，可选择章节查看分项',
            child: CustomPaint(
              size: const Size(208, 206),
              painter: _RadarPainter(
                scores,
                scheme.primary,
                scheme.outlineVariant,
                scheme.onSurface,
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final (i, chapter) in chapters.indexed)
              ChoiceChip(
                label: Text('${i + 1} · ${scores[i].round()}%'),
                tooltip: chapter.title,
                selected: i == selection,
                onSelected: (_) => setState(() => selection = i),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '第 ${selection + 1} 章 · ${chapters[selection].title}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          '实验 ${(row?.labCompletionRate ?? 0).round()}%　概念 ${(row?.conceptScore ?? 0).round()}%　推演 ${(row?.traceScore ?? 0).round()}%　设计 ${(row?.codingScore ?? 0).round()}%',
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.scores, this.primary, this.grid, this.ink);
  final List<double> scores;
  final Color primary, grid, ink;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero),
        radius = math.min(size.width, size.height) * .37;
    Offset point(int i, double fraction) {
      final angle = (i * 2 / scores.length - .5) * math.pi;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * radius * fraction;
    }

    Path polygon(double Function(int) scale) {
      final p = Path();
      for (var i = 0; i < scores.length; i++) {
        final offset = point(i, scale(i));
        if (i == 0) {
          p.moveTo(offset.dx, offset.dy);
        } else {
          p.lineTo(offset.dx, offset.dy);
        }
      }
      return p..close();
    }

    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..color = grid
      ..strokeWidth = 1;
    for (final f in [.25, .5, .75, 1.0]) {
      canvas.drawPath(polygon((_) => f), pen);
    }
    for (var i = 0; i < scores.length; i++) {
      canvas.drawLine(center, point(i, 1), pen);
      final label = TextPainter(
        text: TextSpan(
          text: '第${i + 1}章',
          style: TextStyle(fontSize: 12, color: ink),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final at = point(i, 1.14);
      label.paint(
        canvas,
        Offset(at.dx - label.width / 2, at.dy - label.height / 2),
      );
      label.dispose();
    }
    final shape = polygon((i) => scores[i] / 100);
    canvas.drawPath(shape, Paint()..color = primary.withValues(alpha: .24));
    canvas.drawPath(
      shape,
      pen
        ..color = primary
        ..strokeWidth = 2,
    );
    for (var i = 0; i < scores.length; i++) {
      canvas.drawCircle(
        point(i, scores[i] / 100),
        2.6,
        Paint()..color = primary,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.scores != scores ||
      old.primary != primary ||
      old.grid != grid ||
      old.ink != ink;
}
