import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../layout/linear_memory_layout.dart';
import '../layout/circular_queue_layout.dart';
import '../vm/algorithm_module.dart';
import '../vm/trace_builder.dart';

enum LayoutDemoInput {
  linear,
  sentinel,
  stacks,
  queueWrap,
  queueFull,
  swap,
  insert,
  bars,
}

/// Geometry fixtures, not completed curriculum modules.
class LayoutTraceDemo implements AlgorithmModule<LayoutDemoInput> {
  const LayoutTraceDemo();
  @override
  String get id => 'engine.layout-preview';
  @override
  List<AlgorithmPreset<LayoutDemoInput>> get presets => const [
    AlgorithmPreset(id: 'bars', name: '大数组柱状模式', input: LayoutDemoInput.bars),
    AlgorithmPreset(id: 'linear', name: '线性槽位', input: LayoutDemoInput.linear),
    AlgorithmPreset(
      id: 'sentinel',
      name: '[0] 哨兵槽',
      input: LayoutDemoInput.sentinel,
    ),
    AlgorithmPreset(id: 'stacks', name: '共享双栈', input: LayoutDemoInput.stacks),
    AlgorithmPreset(
      id: 'queueWrap',
      name: '环队列跨零点',
      input: LayoutDemoInput.queueWrap,
    ),
    AlgorithmPreset(
      id: 'queueFull',
      name: '环队列留空判满',
      input: LayoutDemoInput.queueFull,
    ),
    AlgorithmPreset(id: 'swap', name: '双元素交换', input: LayoutDemoInput.swap),
    AlgorithmPreset(
      id: 'insert',
      name: '长距插入移位',
      input: LayoutDemoInput.insert,
    ),
  ];
  @override
  ValidationResult<LayoutDemoInput> validateInput(String raw) {
    for (final preset in presets) {
      if (preset.id == raw.trim()) {
        return ValidationResult.success(preset.input);
      }
    }
    return const ValidationResult.failure('请选择一个布局样例');
  }

  @override
  TraceTimeline generateTrace(LayoutDemoInput input) {
    List<SceneNode> slots(List<String> values) => [
      for (var i = 0; i < values.length; i++)
        SceneNode(id: 'slot-$i', label: values[i], x: 0, y: 0),
    ];
    final values = slots(['49', '38', '65', '97']);
    final scenes = <SceneSnapshot>[];
    final titles = <String>[];
    final explanations = <String>[];
    final sources = <CodeLang, List<String>>{
      for (final lang in CodeLang.values) lang: [],
    };
    void add(
      SceneSnapshot scene,
      String title,
      String explanation,
      String c,
      String dart,
    ) {
      scenes.add(scene);
      titles.add(title);
      explanations.add(explanation);
      sources[CodeLang.cLike]!.add(c);
      sources[CodeLang.c99]!.add(c);
      sources[CodeLang.dart]!.add(dart);
    }

    switch (input) {
      case LayoutDemoInput.bars:
        final data = slots(
          List.generate(32, (i) => ((i * 17 + 11) % 97 + 1).toString()),
        );
        add(
          LinearMemoryLayout.arrange(data),
          '大数组柱状预览',
          '超过 24 个元素时显示柱状；点击柱条查看数值。这里只演示渲染，不运行排序课程。',
          '/* render 32 values */',
          '// render 32 values',
        );
        add(
          LinearMemoryLayout.arrange(data.reversed.toList()),
          '逆序位置',
          '稳定 ID 保持柱条身份，拖动时间轴可回退检查位置。',
          '/* reversed positions */',
          '// reversed positions',
        );
      case LayoutDemoInput.linear:
        add(
          LinearMemoryLayout.arrange(values),
          '0 基下标与逻辑位序',
          '[0] 存放第 1 个元素；默认槽宽 56，槽间距 8。',
          'i = 0; /* elem[0]: first element */',
          'var i = 0; // elem[0]: first element',
        );
      case LayoutDemoInput.sentinel:
        final sentinel = [
          const SceneNode(id: 'sentinel', label: '空', x: 0, y: 0),
          ...values,
        ];
        add(
          LinearMemoryLayout.arrange(sentinel, hasSentinelZero: true),
          '[0] 监视哨/枢轴暂存',
          '紫色 [0] 为独立暂存槽；[1] 才是正式元素的起点，间隙为 24。',
          '/* r[0] reserved; data starts at r[1] */',
          '// r[0] reserved; data starts at r[1]',
        );
        add(
          LinearMemoryLayout.arrange([
            sentinel[0].copyWith(label: '49'),
            ...values,
          ], hasSentinelZero: true),
          '写入暂存槽',
          '写入暂存值不改变正式元素的逻辑位序。',
          'r[0] = r[1];',
          'r[0] = r[1];',
        );
      case LayoutDemoInput.stacks:
        add(
          LinearMemoryLayout.sharedStacks(values),
          '双栈初始状态',
          'top[0] = -1，top[1] = m，两个栈向中间增长。',
          'top[0] = -1; top[1] = 4;',
          'top[0] = -1; top[1] = 4;',
        );
        add(
          LinearMemoryLayout.sharedStacks(values, topLeft: 0, topRight: 2),
          '两端向中间增长',
          '左栈占 [0]，右栈占 [2..3]；仅剩 [1]。',
          'top[0] = 0; top[1] = 2;',
          'top[0] = 0; top[1] = 2;',
        );
        add(
          LinearMemoryLayout.sharedStacks(values, topLeft: 1, topRight: 2),
          '满栈告警',
          'top[0] + 1 == top[1]，两个栈不能继续入栈。',
          '++top[0]; /* full */',
          'top[0]++; // full',
        );
      case LayoutDemoInput.queueWrap:
      case LayoutDemoInput.queueFull:
        final front = input == LayoutDemoInput.queueFull ? 1 : 6;
        SceneSnapshot queueAt(int rear) {
          final count = (rear - front + 8) % 8;
          final queue = slots(
            List.generate(
              8,
              (i) => (i - front + 8) % 8 < count ? (i * 10).toString() : '·',
            ),
          );
          return CircularQueueLayout.arrange(queue, front: front, rear: rear);
        }
        add(
          queueAt(7),
          'rear 位于末槽',
          '下一步 rear 从 7 到 0，顺时针只跨一个槽位。',
          'front = $front; rear = 7;',
          'front = $front; rear = 7;',
        );
        add(
          queueAt(0),
          input == LayoutDemoInput.queueFull ? '留空一格判满' : 'rear 跨过零点',
          input == LayoutDemoInput.queueFull
              ? '(rear+1)%8 == front；[0] 保留为空，斜线区域不能继续入队。'
              : '位置回到 [0]；倒放或拖动会沿同一段圆弧回退。',
          'rear = (rear + 1) % 8;',
          'rear = (rear + 1) % 8;',
        );
      case LayoutDemoInput.swap:
        add(
          LinearMemoryLayout.arrange(values),
          '交换前',
          '稳定 ID 追踪元素；左到右向上，右到左向下。',
          '/* swap r[0] and r[3] */',
          '// swap r[0] and r[3]',
        );
        add(
          LinearMemoryLayout.arrange([
            values[3],
            values[1],
            values[2],
            values[0],
          ]),
          '交换后',
          '交换中点上下错开，避免两个元素穿透重叠。',
          'swap(&r[0], &r[3]);',
          'final t = r[0]; r[0] = r[3]; r[3] = t;',
        );
      case LayoutDemoInput.insert:
        final moving = values
            .map((n) => n.copyWith(visualState: NodeVisualState.moving))
            .toList();
        add(
          LinearMemoryLayout.arrange(moving),
          '移位前',
          '插入元素沿下弧向左移动，被跨过的元素沿上弧右移。',
          '/* move r[3] to r[0] */',
          '// move r[3] to r[0]',
        );
        add(
          LinearMemoryLayout.arrange([
            moving[3],
            moving[0],
            moving[1],
            moving[2],
          ]),
          '移位后',
          '整个过程按快照计算，可重复 seek，不累计偏移。',
          'insert_front(r, 3);',
          'r.insert(0, r.removeAt(3));',
        );
    }
    final recorder = TraceBuilder(
      moduleId: id,
      inputSummary: presets.firstWhere((p) => p.input == input).name,
      codeLines: sources,
    );
    for (var i = 0; i < scenes.length; i++) {
      recorder.step(
        title: titles[i],
        explain: explanations[i],
        scene: scenes[i],
        cLikeLines: [i + 1],
        c99Lines: [i + 1],
        dartLines: [i + 1],
        milestone: true,
      );
    }
    return recorder.build();
  }
}
