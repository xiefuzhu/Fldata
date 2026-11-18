import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/ch1_intro/struct_mapping.dart';
import 'package:fldata/models/trace_model.dart';

void main() {
  const module = StructMappingModule();
  test('all eight mappings preserve topology and bounded unique addresses', () {
    for (final logical in LogicalStructure.values) {
      for (final storage in StorageStructure.values) {
        for (final count in [1, 3, 5, 8]) {
          final input = MappingInput(
            logical: logical,
            storage: storage,
            count: count,
          );
          final timeline = module.generateTrace(input);
          expect(timeline, module.generateTrace(input));
          expect(timeline.frames.length, count + 1);
          final scene = timeline.frames.last.scene;
          final physical = scene.nodes
              .where((n) => n.groupTag == 'physical')
              .toList();
          expect(physical.length, 8);
          expect(physical.map((n) => n.memoryAddress).toSet().length, 8);
          final rows = scene.auxTables.single.rows;
          expect(rows.map((r) => r[2]).toSet().length, count);
          for (var i = 0; i < count; i++) {
            final address = int.parse(rows[i][3].substring(2), radix: 16);
            expect(address, inInclusiveRange(0x2000, 0x2038));
            expect(address % 8, 0);
            if (storage == StorageStructure.sequential) {
              expect(address, 0x2000 + i * 8);
            }
            final frame = timeline.frames[i + 1];
            expect(
              frame.scene.nodes
                  .where((n) => n.visualState == NodeVisualState.active)
                  .map((n) => n.id)
                  .toSet(),
              {'logical-$i', 'physical-$i'},
            );
            expect(frame.scene.auxTables.single.highlightedRows, {i});
          }
          final logicalEdges = scene.edges
              .where((e) => e.id.startsWith('logical-'))
              .toList();
          final physicalEdges = scene.edges
              .where((e) => e.id.startsWith('physical-'))
              .toList();
          if (storage == StorageStructure.sequential) {
            expect(physicalEdges, isEmpty);
          } else {
            expect(
              physicalEdges.length,
              logical == LogicalStructure.graph
                  ? logicalEdges.length * 2
                  : logical == LogicalStructure.collection
                  ? count - 1
                  : logicalEdges.length,
            );
            for (final edge in physicalEdges) {
              final from = int.parse(edge.fromNodeId.split('-').last);
              final to = int.parse(edge.toNodeId.split('-').last);
              expect(rows[from][4], contains(rows[to][3]));
            }
          }
          if (logical == LogicalStructure.collection) {
            expect(logicalEdges, isEmpty);
          }
          expect(
            TraceTimeline.fromJson(
              jsonDecode(jsonEncode(timeline)) as Map<String, dynamic>,
            ),
            timeline,
          );
        }
      }
    }
  });
  test('linked locations are scattered and remain stable while stepping', () {
    final trace = module.generateTrace(
      const MappingInput(storage: StorageStructure.linked),
    );
    final addresses = trace.frames.first.scene.auxTables.single.rows
        .map((r) => r[3])
        .toList();
    expect(addresses, isNot(List.generate(5, StructMappingModule.address)));
    for (final frame in trace.frames) {
      expect(frame.scene.auxTables.single.rows.map((r) => r[3]), addresses);
    }
  });
  test(
    'game-tree edges add one legal alternating move to the parent board',
    () {
      final scene = module
          .generateTrace(
            const MappingInput(logical: LogicalStructure.tree, count: 8),
          )
          .frames
          .first
          .scene;
      final nodes = {
        for (final n in scene.nodes.where((n) => n.groupTag == 'logical'))
          n.id: n,
      };
      for (final edge in scene.edges.where(
        (e) => e.id.startsWith('logical-'),
      )) {
        final parent = nodes[edge.fromNodeId]!.label
            .replaceAll(RegExp(r'\s'), '')
            .split('');
        final child = nodes[edge.toNodeId]!.label
            .replaceAll(RegExp(r'\s'), '')
            .split('');
        final changes = [
          for (var i = 0; i < 9; i++)
            if (parent[i] != child[i]) i,
        ];
        expect(changes.length, 1);
        expect(parent[changes.single], '·');
        expect(
          child[changes.single],
          parent.where((c) => c != '·').length.isEven ? 'X' : 'O',
        );
      }
    },
  );
  test('input and preset bounds are explicit', () {
    expect(module.validateInput('tree linked 8 31').isValid, isTrue);
    for (final raw in [
      'tree linked 9 31',
      'linear sequential 0 1',
      'graph linked 3 -1',
      'bad sequential 3 1',
      'linear sequential 3',
    ]) {
      expect(module.validateInput(raw).isValid, isFalse);
    }
    for (final preset in module.presets) {
      expect(module.generateTrace(preset.input).frames, isNotEmpty);
    }
  });
}
