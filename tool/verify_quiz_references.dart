import 'dart:convert';
import 'dart:io';

import 'package:fldata/curriculum/quiz_catalog.dart';
import 'package:fldata/models/quiz_question.dart';

// Executes only repository-owned reference translations, never student code.
Future<void> main(List<String> args) async {
  final project = File.fromUri(Platform.script).parent.parent;
  final output = Directory('${project.path}/.dart_tool/quiz_reference_checks');
  await output.create(recursive: true);
  var questionCount = 0, caseCount = 0;
  for (final q in [
    ...quizQuestions,
    ...draftQuizQuestions,
  ].whereType<CodeQuestion>()) {
    if (args.isNotEmpty && !q.id.startsWith(args.single)) continue;
    var completed = q.template;
    if (q.blanks.length < 2 || q.blanks.length > 4 || q.testCases.length != 6) {
      throw StateError('${q.id}: expected 2–4 blanks and six cases');
    }
    for (final blank in q.blanks) {
      if (completed.split(blank.marker).length != 2 ||
          blank.acceptedAnswers.isEmpty) {
        throw StateError('${q.id}: missing or ambiguous blank');
      }
      completed = completed.replaceFirst(
        blank.marker,
        blank.acceptedAnswers.first,
      );
    }
    if (completed != q.referenceCode) {
      throw StateError('${q.id}: completed template differs from reference');
    }
    final data = File('${output.path}/${q.id}.json');
    await data.writeAsString(
      jsonEncode([
        for (final c in q.testCases)
          {'name': c.name, 'input': c.input, 'expected': c.expected},
      ]),
    );
    final runner = File('${output.path}/${q.id}.dart');
    await runner.writeAsString(
      "import 'dart:convert';\nimport 'dart:io';\n${q.dartReferenceCode}$_runner",
    );
    final result = await Process.run(Platform.resolvedExecutable, [
      runner.path,
      data.path,
    ], workingDirectory: project.path);
    if (result.exitCode != 0) {
      stderr.write(result.stderr);
      stderr.write(result.stdout);
      throw StateError('${q.id}: reference execution failed');
    }
    stdout.write('${q.id}: ${result.stdout}');
    questionCount++;
    caseCount += q.testCases.length;
  }
  if (questionCount == 0) throw StateError('No matching code seeds');
  stdout.writeln('Verified $questionCount references / $caseCount cases.');
}

const _runner = r'''
Object? canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: canonical(value[key])};
  }
  if (value is List) return value.map(canonical).toList();
  return value;
}
void main(List<String> args) {
  final cases = jsonDecode(File(args.single).readAsStringSync()) as List;
  for (final c in cases) {
    final actual = solve((c['input'] as Map).cast<String, dynamic>());
    final expectedJson = jsonEncode(canonical(c['expected']));
    final actualJson = jsonEncode(canonical(actual));
    if (actualJson != expectedJson) {
      throw StateError('${c['name']}\nexpected: $expectedJson\nactual: $actualJson');
    }
  }
  print('${cases.length} cases passed');
}
''';
