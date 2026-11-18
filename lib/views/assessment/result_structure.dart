import 'dart:convert';

import 'package:flutter/material.dart';

/// Show the JSON-shaped algorithm output as named branches and numbered slots.
class ResultStructure extends StatefulWidget {
  const ResultStructure({super.key, required this.label, required this.value});
  final String label;
  final Object? value;

  @override
  State<ResultStructure> createState() => _ResultStructureState();
}

class _ResultStructureState extends State<ResultStructure> {
  int start = 0;

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    if (value is! Map && value is! List) {
      return ListTile(
        dense: true,
        title: Text(widget.label),
        subtitle: SelectableText(jsonEncode(value)),
      );
    }
    final map = value is Map ? value : null;
    final keys = map?.keys.toList();
    final list = value is List ? value : null;
    final length = keys?.length ?? list!.length;
    final end = (start + 12).clamp(0, length);
    return ExpansionTile(
      dense: true,
      initiallyExpanded: widget.label == '预期结构' || widget.label == '实际结构',
      title: Text('${widget.label} · $length ${list == null ? "个字段" : "个元素"}'),
      childrenPadding: const EdgeInsetsDirectional.only(start: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (length == 0) Text(list == null ? '{}' : '[]'),
        if (list != null &&
            list
                .skip(start)
                .take(end - start)
                .every((e) => e is! Map && e is! List))
          Wrap(
            spacing: 2,
            runSpacing: 4,
            children: [
              for (var i = start; i < end; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '[$i]',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SelectableText(jsonEncode(list[i])),
                    ],
                  ),
                ),
            ],
          )
        else
          for (var i = start; i < end; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: ResultStructure(
                key: ValueKey(i),
                label: keys == null ? '[$i]' : keys[i].toString(),
                value: keys == null ? list![i] : map![keys[i]],
              ),
            ),
        if (length > 12)
          Row(
            children: [
              IconButton(
                tooltip: '上一组元素',
                onPressed: start == 0
                    ? null
                    : () => setState(() => start -= 12),
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${start + 1}–$end / $length'),
              IconButton(
                tooltip: '下一组元素',
                onPressed: end == length
                    ? null
                    : () => setState(() => start += 12),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    );
  }
}
