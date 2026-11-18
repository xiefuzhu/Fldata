import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'ch6_graph/topo_critical.dart';

const dijkstraPracticeId = 'practice_ch6_table64';
const parallelAoeId = 'practice_ch6_parallel_aoe';
final parallelAoeGraph = topoPresets.singleWhere((p) => p.id == 'aoe').input;
const table64Practice = TraceTableQuestion(
  id: dijkstraPracticeId,
  chapterId: ChapterId.ch6,
  title: '表 6.4 · Dijkstra 松弛过程',
  topic: '图 G₆ 的五轮距离与前驱',
  sourceLabel: '配套演练 · 教材表 6.4',
  promptMarkdown:
      '从 v0 出发。弧及权值为 v0→v2(10)、v0→v4(30)、v0→v5(100)、v1→v2(5)、v2→v3(50)、v3→v5(10)、v4→v3(20)、v4→v5(60)。按每轮选点时的状态填 D, Path。前驱用顶点下标，无前驱填 −1。',
  columns: ['v0', 'v1', 'v2', 'v3', 'v4', 'v5'],
  rowLabels: [
    '第 1 轮 · v2',
    '第 2 轮 · v4',
    '第 3 轮 · v3',
    '第 4 轮 · v5',
    '第 5 轮 · 无',
  ],
  answerRows: [
    ['0, -1', '∞, -1', '10, 0', '∞, -1', '30, 0', '100, 0'],
    ['0, -1', '∞, -1', '10, 0', '60, 2', '30, 0', '100, 0'],
    ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '90, 4'],
    ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '60, 3'],
    ['0, -1', '∞, -1', '10, 0', '50, 4', '30, 0', '60, 3'],
  ],
  explanationMarkdown:
      '先经 v2 把 v3 的距离降到 60，经 v4 再降到 50，最后经 v3 把 v5 降到 60。v1 不可达。',
);
final parallelAoePractice = TraceTableQuestion(
  id: parallelAoeId,
  chapterId: ChapterId.ch6,
  title: '图 6.28 · 标定并行关键路径',
  topic: '两条关键路径上的活动',
  sourceLabel: '配套演练 · 教材图 6.28 与表 6.7',
  promptMarkdown: '在网络中标出全部关键活动。两个分支都必须在工期内完成。',
  columns: const ['关键活动'],
  rowLabels: [for (final a in parallelAoeGraph.arcs) '活动 ${a.tail}→${a.head}'],
  answerRows: [
    for (final a in parallelAoeGraph.arcs)
      [
        const {
              'v0→v1',
              'v1→v4',
              'v4→v6',
              'v6→v8',
              'v4→v7',
              'v7→v8',
            }.contains('${a.tail}→${a.head}')
            ? '是'
            : '否',
      ],
  ],
  explanationMarkdown:
      '工期为 18。共同前段为 v0→v1→v4，随后可经 v6 或 v7 到达 v8。两条路径上的活动均无时间余量。',
);

const _matrixFrame = '''int sum(int n, const int *const B[]) {
  int s = 0;
  for (int i = 0; i < n; i++)
    for (int j = 0; /*BLANK_1*/; j++)
      s += /*BLANK_2*/;
  return s;
}''';

final matrixSumPractice = CodeQuestion(
  id: 'practice_ch1_matrix_sum',
  chapterId: ChapterId.ch1,
  title: '矩阵求和程序',
  topic: '第 6（3）题配套编程',
  sourceLabel: '配套演练 · 取材于第 1 章习题 6（3）的已有程序，书页 17',
  promptMarkdown: '实现原程序的矩阵累加。输入 matrix 为整数方阵，返回所有元素之和。',
  explanationMarkdown: '外层逐行，内层逐列，将每个位置的值累加一次。',
  template: _matrixFrame,
  referenceCode: _matrixFrame
      .replaceFirst('/*BLANK_1*/', 'j < n')
      .replaceFirst('/*BLANK_2*/', 'B[i][j]'),
  blanks: const [
    CodeBlank(marker: '/*BLANK_1*/', acceptedAnswers: ['j < n']),
    CodeBlank(marker: '/*BLANK_2*/', acceptedAnswers: ['B[i][j]']),
  ],
  dartReferenceCode: '''Object solve(Map<String,dynamic> data) {
    var sum = 0;
    for (final row in data['matrix'] as List) {
      for (final value in row as List) {
        sum += value as int;
      }
    }
    return sum;
  }''',
  testCases: const [
    AlgorithmTestCase(
      name: '二阶方阵',
      input: {
        'matrix': [
          [1, 2],
          [3, 4],
        ],
      },
      expected: 10,
    ),
    AlgorithmTestCase(name: '空矩阵', input: {'matrix': []}, expected: 0),
    AlgorithmTestCase(
      name: '单元素',
      input: {
        'matrix': [
          [-7],
        ],
      },
      expected: -7,
    ),
    AlgorithmTestCase(
      name: '全重复',
      input: {
        'matrix': [
          [3, 3],
          [3, 3],
        ],
      },
      expected: 12,
    ),
    AlgorithmTestCase(
      name: '首尾抵消',
      input: {
        'matrix': [
          [-4, 0],
          [0, 4],
        ],
      },
      expected: 0,
    ),
    AlgorithmTestCase(
      name: '正负混合',
      input: {
        'matrix': [
          [2, -5, 8],
          [0, 4, 2],
          [-7, 3, 1],
        ],
      },
      expected: 8,
    ),
  ],
);
final achievementPractice = [
  matrixSumPractice,
  table64Practice,
  parallelAoePractice,
];
