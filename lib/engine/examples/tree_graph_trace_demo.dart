import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';
import '../layout/tree_reingold_layout.dart';
import '../layout/graph_layout_engine.dart';
import '../layout/graph_presets.dart';
import '../vm/algorithm_module.dart';
import '../vm/trace_builder.dart';

enum TreeGraphDemoInput {
  treeRotation,
  forest,
  bTreeSplit,
  graphPreset,
  graphForce,
}

class TreeGraphTraceDemo implements AlgorithmModule<TreeGraphDemoInput> {
  const TreeGraphTraceDemo();
  @override
  String get id => 'engine.tree-graph-preview';
  @override
  List<AlgorithmPreset<TreeGraphDemoInput>> get presets => const [
    AlgorithmPreset(
      id: 'treeRotation',
      name: '二叉树旋转布局',
      input: TreeGraphDemoInput.treeRotation,
    ),
    AlgorithmPreset(
      id: 'forest',
      name: '混合宽度森林',
      input: TreeGraphDemoInput.forest,
    ),
    AlgorithmPreset(
      id: 'bTreeSplit',
      name: 'B-树分裂布局',
      input: TreeGraphDemoInput.bTreeSplit,
    ),
    AlgorithmPreset(
      id: 'graphPreset',
      name: '表 6.4 图布局',
      input: TreeGraphDemoInput.graphPreset,
    ),
    AlgorithmPreset(
      id: 'graphForce',
      name: '图力导向与固定',
      input: TreeGraphDemoInput.graphForce,
    ),
  ];
  @override
  ValidationResult<TreeGraphDemoInput> validateInput(String raw) {
    for (final p in presets) {
      if (p.id == raw.trim()) return ValidationResult.success(p.input);
    }
    return const ValidationResult.failure('请选择树/图布局样例');
  }

  @override
  TraceTimeline generateTrace(TreeGraphDemoInput input) {
    SceneNode circle(String id) => SceneNode(
      id: id,
      label: id,
      x: 0,
      y: 0,
      width: 48,
      height: 48,
      shape: NodeShape.circle,
    );
    SceneEdge edge(String from, String to, [EdgePort port = EdgePort.auto]) =>
        SceneEdge(
          id: '$from->$to',
          fromNodeId: from,
          toNodeId: to,
          fromPort: port,
        );
    final scenes = <SceneSnapshot>[];
    final explanations = <String>[];
    void add(SceneSnapshot scene, String explanation) {
      scenes.add(scene);
      explanations.add(explanation);
    }

    switch (input) {
      case TreeGraphDemoInput.treeRotation:
        final nodes = ['4', '2', '6', '1', '3'].map(circle).toList();
        add(
          TreeReingoldLayout.arrange(
            SceneSnapshot(
              nodes: nodes,
              edges: [
                edge('4', '2', EdgePort.lchild),
                edge('4', '6', EdgePort.rchild),
                edge('2', '1', EdgePort.lchild),
                edge('2', '3', EdgePort.rchild),
              ],
            ),
          ),
          '旋转前：父结点位于直接孩子的水平重心，轮廓间距至少 24。',
        );
        add(
          TreeReingoldLayout.arrange(
            SceneSnapshot(
              nodes: nodes,
              edges: [
                edge('2', '1', EdgePort.lchild),
                edge('2', '4', EdgePort.rchild),
                edge('4', '3', EdgePort.lchild),
                edge('4', '6', EdgePort.rchild),
              ],
            ),
          ),
          '右旋后：结点 ID 保持不变。拖动时间轴观察子树移动或回退。',
        );
      case TreeGraphDemoInput.forest:
        add(
          TreeReingoldLayout.arrange(
            SceneSnapshot(
              nodes: [
                circle('A'),
                circle('B'),
                const SceneNode(
                  id: 'thread',
                  label: 'L | 1 | C | 0 | R',
                  x: 0,
                  y: 0,
                  width: 120,
                  height: 44,
                ),
                TreeReingoldLayout.bTreeNode(
                  id: 'wide',
                  keys: ['10', '20', '30', '40'],
                ),
                circle('D'),
                circle('E'),
              ],
              edges: [
                edge('A', 'B'),
                edge('A', 'thread'),
                edge('wide', 'D'),
                edge('wide', 'E'),
              ],
            ),
          ),
          '森林包含圆结点、120×44 五元组和可变宽 B-树盒子；各层按轮廓避免重叠。',
        );
      case TreeGraphDemoInput.bTreeSplit:
        final left = TreeReingoldLayout.bTreeNode(
          id: 'left',
          keys: ['5', '10'],
        );
        final right = TreeReingoldLayout.bTreeNode(
          id: 'right',
          keys: ['50', '60'],
        );
        add(
          TreeReingoldLayout.arrange(
            SceneSnapshot(
              nodes: [
                TreeReingoldLayout.bTreeNode(id: 'root', keys: ['20', '40']),
                left,
                TreeReingoldLayout.bTreeNode(
                  id: 'middle',
                  keys: ['25', '30', '35'],
                ),
                right,
              ],
              edges: [
                edge('root', 'left'),
                edge('root', 'middle'),
                edge('root', 'right'),
              ],
            ),
          ),
          '分裂前：多关键字盒子宽度为关键字数 × 36 + 28。',
        );
        add(
          TreeReingoldLayout.arrange(
            SceneSnapshot(
              nodes: [
                TreeReingoldLayout.bTreeNode(
                  id: 'root',
                  keys: ['20', '30', '40'],
                ),
                left,
                TreeReingoldLayout.bTreeNode(id: 'middle', keys: ['25']),
                TreeReingoldLayout.bTreeNode(id: 'new', keys: ['35']),
                right,
              ],
              edges: [
                edge('root', 'left'),
                edge('root', 'middle'),
                edge('root', 'new'),
                edge('root', 'right'),
              ],
            ),
          ),
          '分裂后：30 上移，新右盒子淡入，已有结点保持 ID。此处仅演示布局，不是完整 B-树插入课程。',
        );
      case TreeGraphDemoInput.graphPreset:
        add(
          GraphPresets.table64(),
          '使用附件表 6.4 的六顶点、八条带权边。坐标为人工排布；可拖动顶点固定，后台重新排布保持固定点。',
        );
      case TreeGraphDemoInput.graphForce:
        final graph = SceneSnapshot(
          nodes: [for (var i = 0; i < 8; i++) circle('n$i')],
          edges: [
            for (var i = 0; i < 8; i++)
              edge(
                'n$i',
                'n${(i + 1) % 8}',
              ).copyWith(style: EdgeStyle.undirected),
            edge('n0', 'n4').copyWith(style: EdgeStyle.undirected),
            edge('n2', 'n6').copyWith(style: EdgeStyle.undirected),
          ],
        );
        // Initial deterministic fixture. Interactive re-layout runs in an isolate.
        add(
          GraphLayoutEngine.forceDirected(graph),
          '引擎样例：80 步力导向结果。拖动即固定，重新排布在后台运行；清除固定可恢复自由布局。',
        );
    }
    final code = [
      for (var i = 0; i < scenes.length; i++) '// layout snapshot ${i + 1}',
    ];
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: presets.firstWhere((p) => p.input == input).name,
      codeLines: {for (final lang in CodeLang.values) lang: code},
    );
    for (var i = 0; i < scenes.length; i++) {
      builder.step(
        title: '${presets.firstWhere((p) => p.input == input).name} · ${i + 1}',
        explain: explanations[i],
        scene: scenes[i],
        cLikeLines: [i + 1],
        c99Lines: [i + 1],
        dartLines: [i + 1],
        milestone: true,
      );
    }
    return builder.build();
  }
}
