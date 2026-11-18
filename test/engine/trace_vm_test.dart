import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/engine/examples/linked_trace_demo.dart';
import 'package:fldata/engine/vm/trace_builder.dart';
import 'package:fldata/engine/vm/trace_validation.dart';
import 'package:fldata/engine/vm/scene_interpolator.dart';
import 'package:fldata/engine/vm/memory_leaks.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/playback_model.dart';
import 'package:fldata/models/trace_model.dart';
import 'package:fldata/providers/playback_provider.dart';

const demo = LinkedTraceDemo();
void main() {
  test(
    'recording owns nested collections and accumulates metrics atomically',
    () {
      final code = {
        for (final lang in CodeLang.values) lang: ['line1', 'line2'],
      };
      final nodes = [const SceneNode(id: 'n', label: '1', x: 0, y: 0)];
      final row = ['n'];
      final vars = {'v': 'old'};
      final locals = {'x': '1'};
      final active = [1];
      final builder = TraceBuilder(
        moduleId: 'fixture',
        inputSummary: '',
        codeLines: code,
      );
      builder.step(
        title: 'one',
        explain: '',
        cLikeLines: active,
        scene: SceneSnapshot(
          nodes: nodes,
          auxTables: [
            AuxTableSnapshot(
              id: 't',
              title: '',
              columns: const ['id'],
              rows: [row],
            ),
          ],
        ),
        vars: vars,
        callStack: [
          StackActivationRecord(
            id: 'call',
            functionName: 'f',
            locals: locals,
            returnLocation: 'Main',
          ),
        ],
        deltaRead: 1,
        deltaSpace: 2,
        deltaCompare: 3,
        statementCounts: {'stmt': 1},
      );
      final initial = builder.build();
      nodes.clear();
      row[0] = 'changed';
      vars['v'] = 'new';
      locals['x'] = '2';
      active[0] = 2;
      code[CodeLang.dart]!.clear();
      final first = initial.frames.single;
      expect(first.scene.nodes, hasLength(1));
      expect(first.scene.auxTables.single.rows.single, ['n']);
      expect(first.inlineVars['v'], 'old');
      expect(first.callStack.single.locals['x'], '1');
      expect(first.activeLines[CodeLang.cLike], [1]);
      expect(initial.codeLines[CodeLang.dart], hasLength(2));
      expect(() => first.scene.nodes.clear(), throwsUnsupportedError);
      expect(
        () => first.scene.auxTables.single.rows.single.add('bad'),
        throwsUnsupportedError,
      );
      expect(
        () => builder.step(title: 'bad', explain: '', deltaSpace: -3),
        throwsArgumentError,
      );
      expect(
        () => builder.step(
          title: 'bad',
          explain: '',
          cLikeLines: [9],
          deltaRead: 100,
        ),
        throwsArgumentError,
      );
      builder.step(
        title: 'two',
        explain: '',
        deltaSpace: -1,
        deltaRead: 2,
        callStack: [],
        statementCounts: {'stmt': 2},
      );
      final result = builder.build();
      expect(initial.frames, hasLength(1));
      expect(result.frames, hasLength(2));
      expect(result.frames.last.scene, first.scene);
      expect(
        result.frames.last.metrics,
        const ComplexityMetrics(
          reads: 3,
          comparisons: 3,
          auxiliarySpace: 1,
          peakAuxiliarySpace: 2,
          maxCallDepth: 1,
          statementCounts: {'stmt': 3},
        ),
      );
    },
  );
  test(
    'all fixture presets are deterministic and survive JSON round trips',
    () {
      for (final preset in demo.presets) {
        final trace = demo.generateTrace(preset.input);
        validateTimeline(trace);
        expect(demo.generateTrace(preset.input), trace);
        expect(
          TraceTimeline.fromJson(
            jsonDecode(jsonEncode(trace.toJson())) as Map<String, dynamic>,
          ),
          trace,
        );
        expect(demo.validateInput(preset.id).value, preset.input);
      }
      expect(demo.validateInput('unknown').isValid, isFalse);
    },
  );
  test('invalid timelines and dangling scene references are rejected', () {
    final trace = demo.generateTrace(LinkedDemoInput.normal);
    expect(
      () => validateTimeline(trace.copyWith(frames: [])),
      throwsArgumentError,
    );
    expect(
      () => validateTimeline(trace.copyWith(frames: [trace.frames[1]])),
      throwsArgumentError,
    );
    expect(
      () => validateScene(
        const SceneSnapshot(
          edges: [
            SceneEdge(id: 'e', fromNodeId: 'missing', toNodeId: nullNodeId),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateScene(
        const SceneSnapshot(
          nodes: [SceneNode(id: 'a', label: '', x: double.nan, y: 0)],
        ),
      ),
      throwsArgumentError,
    );
  });
  group('playback', () {
    late ProviderContainer container;
    late PlaybackController vm;
    PlaybackState state() => container.read(playbackProvider);
    setUp(() {
      container = ProviderContainer();
      container.listen(playbackProvider, (_, _) {});
      vm = container.read(playbackProvider.notifier);
      vm.load(demo.generateTrace(LinkedDemoInput.normal));
    });
    tearDown(() => container.dispose());
    test('seek and reverse restore exact recorded state without drift', () {
      final trace = state().timeline!;
      vm.last();
      for (var i = trace.frames.length - 1; i >= 0; i--) {
        expect(state().currentFrame, trace.frames[i]);
        expect(state().subProgress, 0);
        vm.stepBack();
      }
      vm.seek(2.75);
      expect(state().frameIndex, 2);
      expect(state().subProgress, .75);
      vm.stepBack();
      expect(state().position, 2);
      vm.nextMilestone();
      expect(state().position, 3);
      vm.nextMilestone();
      expect(state().position, 5);
      vm.play(direction: PlaybackDirection.reverse);
      vm.advance(const Duration(milliseconds: 700));
      expect(state().position, 4);
      expect(state().currentFrame, trace.frames[4]);
      vm.advance(const Duration(seconds: 10));
      expect(state().position, 0);
      expect(state().pauseReason, PauseReason.boundary);
    });
    test(
      'large elapsed steps stop at first breakpoint in either direction',
      () {
        vm.toggleBreakpoint(CodeLang.cLike, 2);
        vm.toggleBreakpoint(CodeLang.dart, 4);
        vm.setLanguage(CodeLang.c99);
        vm.play();
        vm.advance(const Duration(seconds: 10));
        expect(state().position, 1);
        expect(state().pauseReason, PauseReason.breakpoint);
        expect(
          state().hitBreakpoint,
          const CodeBreakpoint(language: CodeLang.cLike, line: 2),
        );
        vm.play();
        vm.advance(const Duration(seconds: 10));
        expect(state().position, 3);
        vm.last();
        vm.play(direction: PlaybackDirection.reverse);
        vm.advance(const Duration(seconds: 10));
        expect(state().position, 3);
        vm.play();
        vm.advance(const Duration(seconds: 10));
        expect(state().position, 1);
        expect(state().language, CodeLang.c99);
        expect(state().breakpoints, hasLength(2));
      },
    );
    test('fractional play, speeds, boundaries and invalid commands', () {
      vm.setSpeed(.25);
      vm.play();
      vm.advance(const Duration(milliseconds: 700));
      expect(state().position, .25);
      vm.setSpeed(4);
      vm.advance(const Duration(milliseconds: 350));
      expect(state().position, 2.25);
      vm.pause();
      vm.advance(const Duration(seconds: 1));
      expect(state().position, 2.25);
      vm.seek(-20);
      expect(state().position, 0);
      vm.seek(20);
      expect(state().position, 5);
      vm.play();
      expect(state().isPlaying, isFalse);
      for (final speed in [double.nan, double.infinity, 0.0, 4.1]) {
        expect(() => vm.setSpeed(speed), throwsArgumentError);
      }
      expect(() => vm.seek(double.nan), throwsArgumentError);
      expect(
        () => vm.advance(const Duration(microseconds: -1)),
        throwsArgumentError,
      );
      expect(() => vm.toggleBreakpoint(CodeLang.dart, 7), throwsArgumentError);
      vm.clear();
      vm.play();
      vm.first();
      vm.stepBack();
      expect(state().timeline, isNull);
      vm.load(
        state().timeline ??
            demo
                .generateTrace(LinkedDemoInput.normal)
                .copyWith(
                  frames: [
                    demo.generateTrace(LinkedDemoInput.normal).frames.first,
                  ],
                ),
      );
      vm.play();
      expect(state().isPlaying, isFalse);
      expect(state().position, 0);
    });
    test('error frames stop and stepping back clears leak state', () {
      vm.load(demo.generateTrace(LinkedDemoInput.broken));
      vm.play();
      vm.advance(const Duration(seconds: 10));
      expect(state().pauseReason, PauseReason.error);
      expect(state().position, 3);
      expect(
        state().currentFrame!.scene.nodes
            .where((n) => n.isOrphanLeak)
            .map((n) => n.id)
            .toSet(),
        {'a', 'b'},
      );
      vm.stepBack();
      expect(
        state().currentFrame!.scene.nodes.any((n) => n.isOrphanLeak),
        isFalse,
      );
    });
    test(
      'loading detaches timeline collections from callers and resets breakpoints',
      () {
        final original = demo.generateTrace(LinkedDemoInput.normal);
        final frames = original.frames.toList();
        vm.toggleBreakpoint(CodeLang.dart, 2);
        vm.load(original.copyWith(frames: frames));
        frames.clear();
        expect(state().timeline!.frames, hasLength(6));
        expect(state().breakpoints, isEmpty);
      },
    );
  });
  test(
    'interpolation fades creation/deletion and handles retargeting without residue',
    () {
      const a = SceneNode(id: 'a', label: 'old', x: 0, y: 0);
      const b = SceneNode(id: 'b', label: 'b', x: 100, y: 0);
      const before = SceneSnapshot(
        nodes: [a, b],
        edges: [SceneEdge(id: 'e', fromNodeId: 'a', toNodeId: 'b')],
        pointers: [PointerBadge(id: 'p', label: 'p', targetNodeId: 'b')],
      );
      final after = SceneSnapshot(
        nodes: [
          a.copyWith(x: 50, label: 'new'),
          const SceneNode(id: 'c', label: 'c', x: 200, y: 0),
        ],
        edges: const [SceneEdge(id: 'e', fromNodeId: 'a', toNodeId: 'c')],
        pointers: const [PointerBadge(id: 'p', label: 'p', targetNodeId: 'c')],
      );
      expect(
        identical(SceneInterpolator.lerp(before, after, 0), before),
        isTrue,
      );
      expect(
        identical(SceneInterpolator.lerp(before, after, 1), after),
        isTrue,
      );
      final middle = SceneInterpolator.lerp(before, after, .5);
      expect(middle.nodes.first.x, 25);
      expect(middle.nodes.first.label, 'old');
      expect(middle.nodes.skip(1).map((n) => n.opacity), [.5, .5]);
      expect(middle.edges, hasLength(2));
      expect(middle.edges.map((e) => e.id).toSet(), hasLength(2));
      expect(middle.pointers, hasLength(2));
      validateScene(middle);
      expect(SceneInterpolator.lerp(before, after, .5), middle);
      expect(before.nodes.first.x, 0);
      expect(
        () => SceneInterpolator.lerp(before, after, double.nan),
        throwsArgumentError,
      );
    },
  );
  test(
    'reachability handles cycles, multiple roots, deleted nodes and non-owning links',
    () {
      final nodes = ['a', 'b', 'c', 'd', 'deleted']
          .map(
            (id) => SceneNode(
              id: id,
              label: id,
              x: 0,
              y: 0,
              isDeleted: id == 'deleted',
            ),
          )
          .toList();
      final scene = SceneSnapshot(
        nodes: nodes,
        pointers: const [PointerBadge(id: 'L', label: 'L', targetNodeId: 'a')],
        edges: const [
          SceneEdge(
            id: 'ab',
            fromNodeId: 'a',
            toNodeId: 'b',
            fromPort: EdgePort.next,
          ),
          SceneEdge(
            id: 'ba',
            fromNodeId: 'b',
            toNodeId: 'a',
            fromPort: EdgePort.next,
          ),
          SceneEdge(
            id: 'bc',
            fromNodeId: 'b',
            toNodeId: 'c',
            fromPort: EdgePort.prior,
          ),
          SceneEdge(
            id: 'ad',
            fromNodeId: 'a',
            toNodeId: 'd',
            style: EdgeStyle.dashedThread,
          ),
        ],
      );
      expect(detectMemoryLeaks(scene), {'c', 'd'});
      final withRoot = scene.copyWith(
        pointers: [
          ...scene.pointers,
          const PointerBadge(id: 'p', label: 'p', targetNodeId: 'c'),
        ],
      );
      expect(detectMemoryLeaks(withRoot), {'d'});
      final marked = markMemoryLeaks(scene);
      expect(marked.nodes.where((n) => n.isOrphanLeak), hasLength(2));
      expect(scene.nodes.any((n) => n.isOrphanLeak), isFalse);
    },
  );
}
