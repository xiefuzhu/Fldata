import 'package:flutter/material.dart';
import '../../ui/components/common_scaffold.dart';

class LabPlaceholder extends StatelessWidget {
  const LabPlaceholder({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) => const CommonScaffold(
    title: '算法实验室',
    subtitle: '看见算法，理解每一步',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: 64),
          SizedBox(height: 24),
          Text(
            '实验室正在建设',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Text(
            '此课程实验尚未开放，可从实验室入口查看 TraceVM 引擎预览。',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
