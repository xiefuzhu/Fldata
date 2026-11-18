import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:d4rt/d4rt.dart';

import '../../models/quiz_question.dart';

class FunctionCaseResult {
  const FunctionCaseResult(this.passed, {this.actual, this.error});
  final bool passed;
  final Object? actual;
  final String? error;
}

class FunctionJudge {
  /// The checked-in translations declare their support routines before solve.
  static String starter(CodeQuestion q) {
    final signature = RegExp(
      r'\bObject\s+solve\s*\([^)]*\)\s*\{',
    ).firstMatch(q.dartReferenceCode)!;
    return '${q.dartReferenceCode.substring(0, signature.end)}\n  // 在此实现算法，并返回用例要求的结果。\n  throw \'请先完成 solve\';\n}\n';
  }

  static Future<List<FunctionCaseResult>> run(
    String source,
    List<AlgorithmTestCase> cases,
  ) async {
    final port = ReceivePort();
    final results = <FunctionCaseResult>[];
    Isolate? worker;
    try {
      worker = await Isolate.spawn(
        _runCases,
        (port.sendPort, source, cases),
        onError: port.sendPort,
        onExit: port.sendPort,
      );
      await for (final message in port.timeout(const Duration(seconds: 10))) {
        if (message is! FunctionCaseResult) break;
        results.add(message);
        if (results.length == cases.length) break;
      }
    } on TimeoutException {
      // Fill only the outstanding cases below; retain completed feedback.
    } finally {
      worker?.kill(priority: Isolate.immediate);
      port.close();
    }
    while (results.length < cases.length) {
      results.add(const FunctionCaseResult(false, error: '判题中断或超过运行时间'));
    }
    return results;
  }

  static void _runCases((SendPort, String, List<AlgorithmTestCase>) request) {
    final (port, source, cases) = request;
    late final PrecompiledScript script;
    try {
      script = D4rt().compile(source: source);
      if (script.ast.directives.isNotEmpty) {
        throw const FormatException('请使用内置 Dart 核心类型，提交内容只需包含类型和函数。');
      }
    } catch (error) {
      for (final _ in cases) {
        port.send(FunctionCaseResult(false, error: _message(error)));
      }
      return;
    }
    for (final c in cases) {
      try {
        final raw = D4rt(onPrint: (_) {}).executeCompiled(
          script,
          name: 'solve',
          positionalArgs: [jsonDecode(jsonEncode(c.input))],
          maxSteps: 1000000,
          timeout: const Duration(seconds: 3),
        );
        final actual = _jsonResult(raw);
        port.send(
          FunctionCaseResult(
            const DeepCollectionEquality().equals(actual, c.expected),
            actual: actual,
          ),
        );
      } catch (error) {
        port.send(FunctionCaseResult(false, error: _message(error)));
      }
    }
  }

  static String _message(Object e) {
    final message = e.toString();
    return message.length > 700 ? '${message.substring(0, 700)}…' : message;
  }

  static Object? _jsonResult(Object? value) {
    var remaining = 20000;
    Object? copy(Object? item, int depth) {
      if (--remaining < 0 || depth > 128) {
        throw const FormatException('返回结构过大或有环');
      }
      if (item == null || item is bool || item is num && item.isFinite) {
        return item;
      }
      if (item is String && item.length <= 65536) return item;
      if (item is List) {
        return [for (final child in item) copy(child, depth + 1)];
      }
      if (item is Map && item.keys.every((k) => k is String)) {
        return {
          for (final entry in item.entries)
            entry.key as String: copy(entry.value, depth + 1),
        };
      }
      throw const FormatException('请返回可与用例对比的数值、文字、列表或对象');
    }

    return copy(value, 0);
  }
}
