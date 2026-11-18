import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/assessment/function_judge.dart';
import '../../models/quiz_question.dart';
import '../../providers/app_providers.dart';
import 'question_detail.dart';
import 'result_structure.dart';

class FunctionAttempt extends ConsumerStatefulWidget {
  const FunctionAttempt({super.key, required this.question});
  final CodeQuestion question;
  @override
  ConsumerState<FunctionAttempt> createState() => _FunctionAttemptState();
}

class _FunctionAttemptState extends ConsumerState<FunctionAttempt> {
  CodeQuestion get q => widget.question;
  late final editor = TextEditingController(text: FunctionJudge.starter(q));
  final clock = Stopwatch()..start();
  List<FunctionCaseResult>? results;
  bool running = false;
  String? error;

  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (running || results != null) return;
    final source = editor.text, duration = clock.elapsedMilliseconds;
    setState(() {
      running = true;
      error = null;
    });
    try {
      final repo = ref.read(quizRepositoryProvider);
      final cases = await FunctionJudge.run(source, q.testCases);
      final passed = cases.where((c) => c.passed).length;
      await repo.recordAttempt(
        questionId: q.id,
        chapterId: q.chapterId,
        type: q.type,
        isCorrect: passed == cases.length,
        score: (100 * passed / cases.length).round(),
        durationMs: duration,
        quality: passed == cases.length ? 4 : 1,
        answer: {
          'mode': 'function',
          'source': source,
          'passedCases': [for (final c in cases) c.passed],
        },
      );
      clock.stop();
      if (mounted) setState(() => results = cases);
    } catch (e) {
      if (mounted) setState(() => error = '本次判题未保存，可重新运行。$e');
    } finally {
      if (mounted) setState(() => running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = results;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('用 Dart 实现 solve，读取输入并返回结果。可使用内置核心类型和自定义辅助函数。'),
        ExpansionTile(
          title: const Text('查看用例输入与返回值'),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final sample in q.testCases)
              ExpansionTile(
                title: Text(sample.name),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText('输入  ${jsonEncode(sample.input)}'),
                  SelectableText('返回  ${jsonEncode(sample.expected)}'),
                ],
              ),
          ],
        ),
        TextField(
          key: const ValueKey('solve-editor'),
          controller: editor,
          minLines: 8,
          maxLines: 18,
          readOnly: running || result != null,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
          decoration: const InputDecoration(
            labelText: '完整函数 · Dart',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        if (error != null) Text(error!),
        if (result == null)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: running ? null : submit,
              child: Text(running ? '正在运行用例' : '运行判题'),
            ),
          )
        else ...[
          Text(
            '通过 ${result.where((c) => c.passed).length} / ${result.length} 组用例',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final (i, c) in q.testCases.indexed)
            ExpansionTile(
              key: ValueKey('function-case-$i'),
              leading: Icon(
                result[i].passed
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: result[i].passed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text('${i + 1}. ${c.name}'),
              subtitle: Text(result[i].passed ? '通过' : '失败'),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText('输入  ${jsonEncode(c.input)}'),
                if (result[i].error case final message?)
                  SelectableText(message),
                ResultStructure(label: '预期结构', value: c.expected),
                if (result[i].error == null)
                  ResultStructure(label: '实际结构', value: result[i].actual),
                _StructureDiff(
                  expected: c.expected,
                  actual: result[i].actual,
                  hasActual: result[i].error == null,
                ),
              ],
            ),
          ExpansionTile(
            title: const Text('查看参考函数'),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizText(
                '\x60\x60\x60dart\n${q.dartReferenceCode}\n\x60\x60\x60',
              ),
              QuizText(q.explanationMarkdown),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => setState(() {
                results = null;
                clock
                  ..reset()
                  ..start();
              }),
              child: const Text('修改函数并重试'),
            ),
          ),
        ],
      ],
    );
  }
}

/// Align both structures by field name and list index, including absent values.
class _StructureDiff extends StatelessWidget {
  const _StructureDiff({
    required this.expected,
    required this.actual,
    required this.hasActual,
  });
  final Object? expected, actual;
  final bool hasActual;

  static Map<String, String> _leaves(Object? root) {
    final leaves = <String, String>{};
    void walk(String path, Object? value) {
      if (value is Map && value.isNotEmpty) {
        for (final e in value.entries) {
          walk('$path[${jsonEncode(e.key)}]', e.value);
        }
      } else if (value is List && value.isNotEmpty) {
        for (final (i, item) in value.indexed) {
          walk('$path[$i]', item);
        }
      } else {
        leaves[path] = jsonEncode(value);
      }
    }

    walk('结果', root);
    return leaves;
  }

  @override
  Widget build(BuildContext context) {
    final left = _leaves(expected),
        right = hasActual ? _leaves(actual) : <String, String>{};
    final paths = {...left.keys, ...right.keys}.toList();
    // Put the first divergent slot in view even on long random sequences.
    final ordered = [
      for (final p in paths)
        if (left[p] != right[p]) p,
      for (final p in paths)
        if (left[p] == right[p]) p,
    ];
    Widget row(String path, String want, String got, {bool mismatch = false}) =>
        Container(
          color: mismatch ? Theme.of(context).colorScheme.errorContainer : null,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(path)),
              Expanded(flex: 2, child: SelectableText(want)),
              Expanded(flex: 2, child: SelectableText(got)),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row('结构位置', '预期', '实际'),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: ordered.length,
            itemBuilder: (context, i) {
              final p = ordered[i];
              return row(
                p,
                left[p] ?? '缺项',
                right[p] ?? '缺项',
                mismatch: left[p] != right[p],
              );
            },
          ),
        ),
      ],
    );
  }
}
