import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch2_linear_list/linklist_ops.dart';
import 'package:fldata/engine/vm/memory_leaks.dart';
import 'package:fldata/models/trace_model.dart';

List<String> dataChain(TraceFrame frame) {
  final nodes = {for (final n in frame.scene.nodes) n.id: n};
  final next = {for (final e in frame.scene.edges) e.fromNodeId: e.toNodeId};
  var p = frame.scene.pointers.firstWhere((p) => p.id == 'L').targetNodeId;
  final seen = <String>{}, values = <String>[];
  while (p != nullNodeId && seen.add(p)) {
    if (p != 'head') values.add(nodes[p]!.label);
    p = next[p] ?? nullNodeId;
  }
  return values;
}

void main() {
  const module = LinkListModule();
  test(
    'all legal insert/delete positions with and without dummy head, empty/singleton included',
    () {
      for (final head in [true, false]) {
        for (var n = 0; n <= 5; n++) {
          final original = List.generate(n, (k) => String.fromCharCode(65 + k));
          for (var i = 1; i <= n + 1; i++) {
            final t = module.generateTrace(
              LinkListInput(values: original, hasHead: head, position: i),
            );
            expect(dataChain(t.frames.last), [...original]..insert(i - 1, 'X'));
            expect(dataChain(t.frames.first), original);
            expect(t.frames.last.metrics.allocations, 1);
            expect(t.frames.last.metrics.writes, 2);
            for (final f in t.frames) {
              expect(detectMemoryLeaks(f.scene), isEmpty, reason: f.phaseTitle);
            }
          }
          for (var i = 1; i <= n; i++) {
            final t = module.generateTrace(
              LinkListInput(
                operation: LinkListOperation.delete,
                values: original,
                hasHead: head,
                position: i,
              ),
            );
            expect(dataChain(t.frames.last), [...original]..removeAt(i - 1));
            expect(t.frames.last.inlineVars['out'], original[i - 1]);
            expect(
              t.frames.last.scene.nodes.where((n) => n.isDeleted).length,
              1,
            );
            expect(
              t.frames.last.scene.pointers.any((p) => p.id == 'q'),
              isFalse,
            );
            for (final f in t.frames) {
              expect(detectMemoryLeaks(f.scene), isEmpty, reason: f.phaseTitle);
            }
          }
        }
      }
    },
  );
  test(
    'normal insertion connects successor before predecessor; no-head first modifies L',
    () {
      for (final head in [true, false]) {
        final t = module.generateTrace(
          LinkListInput(hasHead: head, position: 1),
        );
        final first = t.frames.firstWhere(
          (f) => f.phaseTitle == '① s->next = 原后继',
        );
        expect(
          first.scene.edges.firstWhere((e) => e.fromNodeId == 'new').toNodeId,
          'node-0',
        );
        expect(dataChain(first), ['A', 'B', 'C', 'D']);
        expect(
          first.scene.edges
              .firstWhere((e) => e.fromNodeId == 'new')
              .visualState,
          NodeVisualState.active,
        );
        final second = t.frames[first.stepIndex + 1];
        expect(dataChain(second), ['X', 'A', 'B', 'C', 'D']);
        expect(
          second.scene.pointers.firstWhere((p) => p.id == 'L').targetNodeId,
          head ? 'head' : 'new',
        );
      }
    },
  );
  test(
    'wrong order loses exact suffix then self-cycles, reversing preserves original snapshots',
    () {
      for (final head in [true, false]) {
        for (final i in [1, 2, 5]) {
          final t = module.generateTrace(
            LinkListInput(hasHead: head, position: i, wrongOrder: true),
          );
          final a = t.frames[t.frames.length - 2], b = t.frames.last;
          expect(a.isErrorState, isTrue);
          expect(a.scene.zones.length, 5 - i);
          expect(
            a.scene.nodes
                .where((n) => n.isOrphanLeak)
                .every((n) => n.logicBadge == '失联'),
            isTrue,
          );
          expect(b.isErrorState, isTrue);
          expect(detectMemoryLeaks(a.scene), {
            for (var k = i - 1; k < 4; k++) 'node-$k',
          });
          expect(a.scene.nodes.where((n) => n.isOrphanLeak).length, 5 - i);
          expect(
            b.scene.edges.firstWhere((e) => e.fromNodeId == 'new').toNodeId,
            'new',
          );
          expect(dataChain(t.frames.first), ['A', 'B', 'C', 'D']);
          expect(detectMemoryLeaks(t.frames.first.scene), isEmpty);
          if (i == 5) expect(a.explanation, contains('没有后续结点'));
        }
      }
    },
  );
  test(
    'head/tail builds reverse/preserve input and no head init allocates nothing',
    () {
      for (final head in [true, false]) {
        for (final op in [
          LinkListOperation.createHead,
          LinkListOperation.createTail,
        ]) {
          final t = module.generateTrace(
            LinkListInput(operation: op, hasHead: head),
          );
          expect(
            dataChain(t.frames.last),
            op == LinkListOperation.createHead
                ? ['D', 'C', 'B', 'A']
                : ['A', 'B', 'C', 'D'],
          );
          expect(t.frames.last.metrics.allocations, head ? 5 : 4);
          expect(t.frames.first.callStack.single.arguments, {
            'a': 'A, B, C, D',
            'n': '4',
          });
          for (final f in t.frames) {
            expect(detectMemoryLeaks(f.scene), isEmpty, reason: f.phaseTitle);
          }
        }
        final init = module.generateTrace(
          LinkListInput(operation: LinkListOperation.init, hasHead: head),
        );
        expect(dataChain(init.frames.last), isEmpty);
        expect(init.frames.last.metrics.allocations, head ? 1 : 0);
        expect(init.frames.last.scene.nodes.length, head ? 1 : 0);
      }
    },
  );
  test('invalid get/delete/insert never relink, including empty lists', () {
    for (final head in [true, false]) {
      for (final values in [
        <String>[],
        ['A', 'B'],
      ]) {
        for (final op in [
          LinkListOperation.get,
          LinkListOperation.insert,
          LinkListOperation.delete,
        ]) {
          for (final i in [
            0,
            values.length + (op == LinkListOperation.insert ? 2 : 1),
          ]) {
            final t = module.generateTrace(
              LinkListInput(
                operation: op,
                values: values,
                hasHead: head,
                position: i,
              ),
            );
            expect(t.frames.last.isErrorState, isTrue);
            expect(t.frames.last.inlineVars['result'], 'ERROR');
            expect(t.frames.last.metrics.writes, 0);
            expect(dataChain(t.frames.last), values);
          }
        }
      }
    }
  });
  test('Get traverses to i, Locate returns first matching pointer or NULL', () {
    for (final head in [true, false]) {
      final get = module.generateTrace(
        LinkListInput(
          operation: LinkListOperation.get,
          position: 3,
          hasHead: head,
        ),
      );
      expect(get.frames.last.inlineVars['out'], 'C');
      expect(get.frames.where((f) => f.phaseTitle == 'p = p->next').length, 2);
      final locate = module.generateTrace(
        LinkListInput(
          operation: LinkListOperation.locate,
          values: ['A', 'B', 'A'],
          value: 'A',
          hasHead: head,
        ),
      );
      expect(
        locate.frames.last.inlineVars['result'],
        locate.frames.last.scene.nodes
            .firstWhere((n) => n.id == 'node-0')
            .memoryAddress,
      );
      expect(locate.frames.last.metrics.comparisons, 1);
      final missing = module.generateTrace(
        LinkListInput(
          operation: LinkListOperation.locate,
          value: 'Z',
          hasHead: head,
        ),
      );
      expect(missing.frames.last.inlineVars['result'], 'NULL');
      expect(missing.frames.last.metrics.comparisons, 4);
    }
  });
  test(
    'presets deterministic, immutable roundtrip, input controls teachable bounds',
    () {
      for (final preset in module.presets) {
        final t = module.generateTrace(preset.input);
        expect(module.generateTrace(preset.input), t);
        expect(TraceTimeline.fromJson(jsonDecode(jsonEncode(t.toJson()))), t);
      }
      expect(module.validateInput('insert|1|0|0|X|A B').isValid, isTrue);
      expect(module.validateInput('insert|1|0|1|X|').isValid, isTrue);
      expect(module.validateInput('insert|1|0|1|XX|A').isValid, isFalse);
    },
  );
}
