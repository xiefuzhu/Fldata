import 'package:flutter/material.dart';
import '../../curriculum/ch8_sort/sort_records.dart';

class SortKeysEditor extends StatefulWidget {
  const SortKeysEditor(
    this.keys, {
    super.key,
    required this.fieldKey,
    required this.title,
    this.validate,
  });
  final String fieldKey, title;
  final List<int> keys;
  final String? Function(List<int>)? validate;
  @override
  State<SortKeysEditor> createState() => _SortKeysEditorState();
}

class _SortKeysEditorState extends State<SortKeysEditor> {
  late String value = widget.keys.join(' ');
  String? error;
  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.title),
    content: TextFormField(
      key: ValueKey(widget.fieldKey),
      initialValue: value,
      onChanged: (s) => value = s,
      decoration: InputDecoration(
        labelText: '记录序列',
        helperText: '空格或逗号分隔，同键按输入次序标记',
        helperMaxLines: 3,
        errorText: error,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () {
          try {
            final keys = parseSortIntegers(value, tagged: true);
            final message = widget.validate?.call(keys);
            if (message != null) throw FormatException(message);
            Navigator.pop(context, keys);
          } on FormatException catch (e) {
            setState(() => error = e.message);
          }
        },
        child: const Text('开始推演'),
      ),
    ],
  );
}
