import 'dart:math';
import '../../models/trace_model.dart';
import 'exchange_sort.dart';
import 'insertion_sort.dart';
import 'merge_radix.dart';
import 'selection_sort.dart';
import 'sort_records.dart';

enum RaceAlgorithm {
  direct('直接插入', 'n', 'n²', 'n²', '1', true),
  binary('折半插入', 'n log n', 'n²', 'n²', '1', true),
  shell('希尔排序', '依增量', '依增量', '教材估计 n¹·³', '1', false),
  bubble('冒泡排序', 'n', 'n²', 'n²', '1', true),
  quick('快速排序', 'n log n', 'n²', 'n log n', 'log n，最坏 n', false),
  simple('简单选择', 'n²', 'n²', 'n²', '1', false),
  tournament('树形选择', 'n log n', 'n log n', 'n log n', 'n', true),
  heap('堆排序', 'n log n', 'n log n', 'n log n', '1', false),
  merge('二路归并', 'n log n', 'n log n', 'n log n', 'n', true),
  radix('链式基数', 'd(n+r)', 'd(n+r)', 'd(n+r)', 'n+r', true);

  const RaceAlgorithm(
    this.label,
    this.best,
    this.worst,
    this.average,
    this.space,
    this.stable,
  );
  final String label, best, worst, average, space;
  final bool stable;
  TraceTimeline trace(List<int> keys) => switch (this) {
    RaceAlgorithm.direct ||
    RaceAlgorithm.binary ||
    RaceAlgorithm.shell => const InsertionModule().generateTrace(
      InsertionInput(keys: keys, method: InsertionMethod.values.byName(name)),
    ),
    RaceAlgorithm.bubble ||
    RaceAlgorithm.quick => const ExchangeModule().generateTrace(
      ExchangeInput(keys: keys, method: ExchangeMethod.values.byName(name)),
    ),
    RaceAlgorithm.simple ||
    RaceAlgorithm.tournament ||
    RaceAlgorithm.heap => const SelectionModule().generateTrace(
      SelectionInput(keys: keys, method: SelectionMethod.values.byName(name)),
    ),
    RaceAlgorithm.merge ||
    RaceAlgorithm.radix => const MergeRadixModule().generateTrace(
      MergeRadixInput(keys: keys, method: MergeRadixMethod.values.byName(name)),
    ),
  };
}

enum RaceSample {
  random('随机'),
  ascending('正序'),
  descending('逆序'),
  duplicates('大量重复');

  const RaceSample(this.label);
  final String label;
  List<int> generate(int n, int seed) {
    final gen = Random(seed),
        result = List.generate(
          n,
          (_) => gen.nextInt(this == duplicates ? 4 : 100),
        );
    if (this == ascending) result.sort();
    if (this == descending) result.sort((a, b) => b.compareTo(a));
    return result;
  }
}

class RaceRequest {
  const RaceRequest(this.keys, this.algorithms);
  final List<int> keys;
  final List<RaceAlgorithm> algorithms;
}

class RaceBeat {
  const RaceBeat(
    this.tick,
    this.labels,
    this.active,
    this.comparisons,
    this.moves,
    this.links,
    this.title,
  );
  final int tick, comparisons, moves, links;
  final List<String> labels;
  final Set<int> active;
  final String title;
}

class RaceLane {
  const RaceLane(this.algorithm, this.beats, this.inverted, this.peakDepth);
  final RaceAlgorithm algorithm;
  final List<RaceBeat> beats;
  final bool inverted;
  final int peakDepth;
  RaceBeat at(int tick) {
    var low = 0, high = beats.length;
    while (low + 1 < high) {
      final m = (low + high) ~/ 2;
      if (beats[m].tick <= tick) {
        low = m;
      } else {
        high = m;
      }
    }
    return beats[low];
  }
}

List<RaceLane> buildRace(RaceRequest req) {
  if (req.algorithms.length < 2 ||
      req.algorithms.length > 4 ||
      req.algorithms.toSet().length != req.algorithms.length) {
    throw ArgumentError('请选择 2～4 种不同的算法。');
  }
  return [for (final a in req.algorithms) _lane(a, req.keys)];
}

RaceLane _lane(RaceAlgorithm a, List<int> keys) {
  final trace = a.trace(keys),
      original = SortRecord.tag(keys).map((r) => r.label).toList();
  final beats = [RaceBeat(0, original, {}, 0, 0, 0, '起点')];
  var previous = original;
  for (final f in trace.frames) {
    final metrics = f.metrics, vars = f.inlineVars;
    final links = a == RaceAlgorithm.radix ? metrics.writes : 0;
    final tick = metrics.comparisons + metrics.moves + links;
    final last = f.stepIndex == trace.frames.length - 1;
    if (!last && tick == beats.last.tick) continue;
    final List<String> row;
    if (a == RaceAlgorithm.radix) {
      row = [
        for (final s in vars['链序']!.split(',').where((s) => s.isNotEmpty))
          original[int.parse(s) - 1],
      ];
    } else if (a == RaceAlgorithm.merge) {
      row = [...previous];
      final write = vars['写槽'];
      if (write != null) {
        final node = f.scene.nodes.firstWhere((n) => n.id == write);
        final i = int.parse(write.replaceFirst(RegExp(r'^\D+'), ''));
        row[i - 1] = node.label;
      }
    } else {
      row = f.scene.nodes
          .skip(1)
          .take(keys.length)
          .map((n) => n.label)
          .toList();
      if (a == RaceAlgorithm.tournament) {
        final placed = row.where((s) => s != '∅').toSet();
        row.setAll(placed.length, original.where((s) => !placed.contains(s)));
      }
    }
    final active = {
      for (var i = 0; i < row.length; i++)
        if (row[i] != previous[i]) i,
    };
    if (active.isEmpty && a != RaceAlgorithm.radix) {
      for (var i = 0; i < row.length; i++) {
        if (f.scene.nodes[i + 1].visualState == NodeVisualState.comparing) {
          active.add(i);
        }
      }
    }
    final beat = RaceBeat(
      tick,
      row,
      active,
      metrics.comparisons,
      metrics.moves,
      links,
      f.phaseTitle,
    );
    if (tick == beats.last.tick) {
      beats[beats.length - 1] = beat;
    } else {
      beats.add(beat);
    }
    previous = row;
  }
  return RaceLane(
    a,
    beats,
    trace.frames.last.inlineVars.containsKey('逆序帧'),
    trace.frames.last.metrics.maxCallDepth,
  );
}
