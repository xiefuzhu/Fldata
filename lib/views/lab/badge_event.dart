import 'package:flutter/material.dart';

Future<void> saveBadgeEvent(BuildContext context, Future<void> write) async {
  try {
    await write;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('成就记录保存失败：$e')));
    }
  }
}
