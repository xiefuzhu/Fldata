import '../enum/ds_enums.dart';
import '../models/curriculum_model.dart';

const chapters = <ChapterMeta>[
  ChapterMeta(
    id: ChapterId.ch1,
    title: '绪论',
    summary: '逻辑结构、存储结构与复杂度',
    moduleIds: ['ch1_struct_mapping', 'ch1_adt_complex', 'ch1_complexity_lab'],
  ),
  ChapterMeta(
    id: ChapterId.ch2,
    title: '线性表',
    summary: '顺序表、链表与多项式',
    moduleIds: [
      'ch2_sqlist_ops',
      'ch2_linklist_ops',
      'ch2_circular_dulink',
      'ch2_merge_compare',
      'ch2_cases_polyn_book',
    ],
  ),
  ChapterMeta(
    id: ChapterId.ch3,
    title: '栈和队列',
    summary: '递归、汉诺塔与表达式求值',
    moduleIds: [
      'ch3_stack_sq_link',
      'ch3_recursion_hanoi',
      'ch3_queue_sq_link',
      'ch3_cases_expr_dance',
    ],
  ),
  ChapterMeta(
    id: ChapterId.ch4,
    title: '串、数组和广义表',
    summary: '模式匹配、矩阵压缩与广义表',
    moduleIds: ['ch4_bf_kmp_lab', 'ch4_array_matrix', 'ch4_glist_explorer'],
  ),
  ChapterMeta(
    id: ChapterId.ch5,
    title: '树和二叉树',
    summary: '遍历、线索化与哈夫曼编码',
    moduleIds: [
      'ch5_bitree_traverse',
      'ch5_threaded_tree',
      'ch5_tree_forest_conv',
      'ch5_huffman_expr',
    ],
  ),
  ChapterMeta(
    id: ChapterId.ch6,
    title: '图',
    summary: '图的存储、遍历、最小生成树与最短路径',
    moduleIds: [
      'ch6_graph_storage',
      'ch6_dfs_bfs_sixdeg',
      'ch6_mst_prim_kruskal',
      'ch6_shortest_path',
      'ch6_topo_critical',
    ],
  ),
  ChapterMeta(
    id: ChapterId.ch7,
    title: '查找',
    summary: '顺序、折半和分块查找，平衡树与散列',
    moduleIds: [
      'ch7_linear_bin_block',
      'ch7_bst_avl_lab',
      'ch7_btree_bplustree',
      'ch7_hash_table',
    ],
  ),
  ChapterMeta(
    id: ChapterId.ch8,
    title: '排序',
    summary: '内部排序、算法竞速与外部排序',
    moduleIds: [
      'ch8_insert_shell',
      'ch8_swap_bubble_quick',
      'ch8_select_heap',
      'ch8_merge_radix_race',
      'ch8_external_sort',
    ],
  ),
];

const modules = <AlgorithmMeta>[
  AlgorithmMeta(
    id: 'ch8_external_sort',
    chapterId: ChapterId.ch8,
    title: '外部排序 · 败者树、置换选择与最佳归并树',
    complexity: ComplexitySpec(
      time: 'k 路归并每次重赛 O(log k)，置换选择生成初始段 O(n log w)',
      space: '归并树比赛缓冲 O(k)，置换选择工作区 O(w)',
    ),
    textbookReferences: ['第 8.7 节', '图 8.18、8.19', '表 8.1', '图 8.21～8.23'],
  ),
  AlgorithmMeta(
    id: 'ch8_merge_radix_race',
    chapterId: ChapterId.ch8,
    title: '归并、链式基数排序与竞速',
    complexity: ComplexitySpec(
      time: '二路归并 O(n log n)，基数排序 O(d(n+r))',
      space: '二路归并 O(n)，静态链式基数 O(n+r)',
    ),
    textbookReferences: ['算法 8.10～8.12', '图 8.13、8.15', '表 8.2'],
  ),
  AlgorithmMeta(
    id: 'ch8_select_heap',
    chapterId: ChapterId.ch8,
    title: '选择排序 · 简单选择、锦标赛树与堆',
    complexity: ComplexitySpec(
      time: '简单选择 O(n²)，树形选择与堆排序 O(n log n)',
      space: '简单选择与堆排序 O(1)，锦标赛树 O(n)',
    ),
    textbookReferences: ['算法 8.6～8.9', '例 8.5～8.7', '图 8.6、8.8、8.10～8.12'],
  ),
  AlgorithmMeta(
    id: 'ch8_swap_bubble_quick',
    chapterId: ChapterId.ch8,
    title: '交换排序 · 冒泡与快速排序',
    complexity: ComplexitySpec(
      time: '冒泡最坏 O(n²)，启用 flag 时最好 O(n)；快排平均 O(n log n)，最坏 O(n²)',
      space: '冒泡 O(1)；快排递归栈平均 O(log n)，最坏 O(n)',
    ),
    textbookReferences: ['算法 8.4、8.5', '图 8.3～8.5'],
  ),
  AlgorithmMeta(
    id: 'ch8_insert_shell',
    chapterId: ChapterId.ch8,
    title: '插入排序 · 直接、折半与希尔',
    complexity: ComplexitySpec(
      time: '直接、折半插入最坏 O(n²)；希尔排序取决于增量序列',
      space: '辅助记录 O(1)',
    ),
    textbookReferences: ['算法 8.1～8.3', '例 8.1、8.2', '图 8.1、8.2'],
  ),
  AlgorithmMeta(
    id: 'ch7_hash_table',
    chapterId: ChapterId.ch7,
    title: '散列表 · 冲突处理与平均查找长度',
    complexity: ComplexitySpec(
      time: '均匀散列且控制装填因子时平均 O(1)，线性探测最坏 O(m)，链查找最坏 O(n)',
      space: '开放地址 O(m)，链地址 O(m+n)',
    ),
    textbookReferences: ['算法 7.10', '例 7.2、7.3', '图 7.28～7.30', '表 7.2、7.4'],
  ),
  AlgorithmMeta(
    id: 'ch7_btree_bplustree',
    chapterId: ChapterId.ch7,
    title: 'B-树与 B+树 · 多路查找与叶链',
    complexity: ComplexitySpec(
      time: 'B-树访问 O(logₘ n) 层，每页顺序比较 O(m)；B+树定位后沿叶链扫描',
      space: '每页 O(m)，全树 O(n)',
    ),
    textbookReferences: ['算法 7.8～7.9', '图 7.22、7.25～7.27'],
  ),
  AlgorithmMeta(
    id: 'ch7_bst_avl_lab',
    chapterId: ChapterId.ch7,
    title: '二叉排序树与 AVL · 查找、增删与旋转',
    complexity: ComplexitySpec(
      time: 'BST 查找与增删 O(h)，有序建树最坏 O(n²)；AVL 插入 O(log n)',
      space: '递归查找与插入 O(h)，迭代删除 O(1)',
    ),
    textbookReferences: [
      '算法 7.4～7.7',
      '图 7.5～7.10',
      '7.3.2 平衡二叉树',
      '图 7.12～7.20',
    ],
  ),
  AlgorithmMeta(
    id: 'ch7_linear_bin_block',
    chapterId: ChapterId.ch7,
    title: '顺序、折半与分块查找',
    complexity: ComplexitySpec(
      time: '顺序 O(n)，折半 O(log n)，分块 O(b + s) 或 O(log b + s)',
      space: '查找附加空间 O(1)，索引表 O(b)',
    ),
    textbookReferences: ['算法 7.1～7.3', '例 7.1', '图 7.1～7.4'],
  ),
  AlgorithmMeta(
    id: 'ch6_topo_critical',
    chapterId: ChapterId.ch6,
    title: '拓扑排序与 AOE 关键路径',
    complexity: ComplexitySpec(time: 'O(n + e)', space: '辅助数组和栈 O(n)，活动表 O(e)'),
    textbookReferences: ['算法 6.12～6.13', '例 6.4', '图 6.27～6.29', '表 6.7'],
  ),
  AlgorithmMeta(
    id: 'ch6_shortest_path',
    chapterId: ChapterId.ch6,
    title: '最短路径 · Dijkstra 与 Floyd',
    complexity: ComplexitySpec(
      time: 'Dijkstra O(n²)，Floyd O(n³)',
      space: 'Dijkstra 辅助数组 O(n)，Floyd 双矩阵 O(n²)',
    ),
    textbookReferences: [
      '算法 6.10～6.11',
      '例 6.2～6.3',
      '图 6.22～6.25',
      '表 6.2～6.5',
    ],
  ),
  AlgorithmMeta(
    id: 'ch6_mst_prim_kruskal',
    chapterId: ChapterId.ch6,
    title: '最小生成树 · Prim 与 Kruskal',
    complexity: ComplexitySpec(
      time: 'Prim O(n²)；Kruskal 排序及数组合并 O(e log e + n²)',
      space: '顶点辅助表 O(n)，排序边表 O(e)',
    ),
    textbookReferences: ['算法 6.8～6.9', '图 6.19～6.20', '表 6.1'],
  ),
  AlgorithmMeta(
    id: 'ch6_dfs_bfs_sixdeg',
    chapterId: ChapterId.ch6,
    title: '图的遍历、生成森林与六度空间',
    complexity: ComplexitySpec(
      time: '邻接矩阵 O(n²)，邻接表 O(n+e)',
      space: '访问标志、递归栈或队列 O(n)',
    ),
    textbookReferences: ['算法 6.3～6.7、6.14', '图 6.17～6.18', '案例 6.2'],
  ),
  AlgorithmMeta(
    id: 'ch6_graph_storage',
    chapterId: ChapterId.ch6,
    title: '图的编辑与四种存储结构',
    complexity: ComplexitySpec(
      time: '矩阵初始化 O(n²)，链表头插 O(e)（端点已定位）',
      space: '邻接矩阵 O(n²)，链式存储 O(n+e)',
    ),
    textbookReferences: ['6.4.1～6.4.4', '算法 6.1～6.2', '图 6.9～6.14'],
  ),
  AlgorithmMeta(
    id: 'ch5_huffman_expr',
    chapterId: ChapterId.ch5,
    title: '哈夫曼编码与表达式树',
    complexity: ComplexitySpec(
      time: '顺序选择建树 O(n²)，表达式建树与求值 O(m)',
      space: 'HT 与表达式树 O(n)、O(m)，编码表按实际码长计',
    ),
    textbookReferences: ['算法 5.10～5.13', '表 5.2、图 5.29', '案例 5.1～5.2'],
  ),
  AlgorithmMeta(
    id: 'ch5_tree_forest_conv',
    chapterId: ChapterId.ch5,
    title: '树、森林与二叉树的互转',
    complexity: ComplexitySpec(time: '转换 O(n)', space: '输出结构 O(n)'),
    textbookReferences: ['第 5.6 节', '图 5.19、5.21、5.24', '孩子兄弟法与遍历对应关系'],
  ),
  AlgorithmMeta(
    id: 'ch5_threaded_tree',
    chapterId: ChapterId.ch5,
    title: '中序线索二叉树',
    complexity: ComplexitySpec(
      time: '线索化与遍历 O(n)',
      space: '线索化 O(h)，线索遍历 O(1)',
    ),
    textbookReferences: ['算法 5.7～5.9', '图 5.16', '带头结点的中序线索化与遍历'],
  ),
  AlgorithmMeta(
    id: 'ch5_bitree_traverse',
    chapterId: ChapterId.ch5,
    title: '二叉树 · 遍历、建树与重构',
    complexity: ComplexitySpec(time: '遍历 O(n)', space: '深度优先 O(h)，层序 O(最大层宽)'),
    textbookReferences: ['算法 5.1～5.6', '图 5.11', '二叉树五条性质', '层序队列与双序列重构'],
  ),
  AlgorithmMeta(
    id: 'ch4_glist_explorer',
    chapterId: ChapterId.ch4,
    title: '广义表 · 取头取尾与链式存储',
    complexity: ComplexitySpec(
      time: '深度遍历 O(节点数)，取头/尾视图 O(1)',
      space: '递归求深度 O(嵌套深度)',
    ),
    textbookReferences: ['广义表的定义与存储', 'GetHead / GetTail'],
  ),
  AlgorithmMeta(
    id: 'ch4_array_matrix',
    chapterId: ChapterId.ch4,
    title: '数组与矩阵 · 地址、压缩与转置',
    complexity: ComplexitySpec(
      time: '寻址 O(1)，快速转置 O(列数 + 非零项数)',
      space: '转置辅助 O(列数)',
    ),
    textbookReferences: ['多维数组与特殊矩阵', '三元组快速转置'],
  ),
  AlgorithmMeta(
    id: 'ch4_bf_kmp_lab',
    chapterId: ChapterId.ch4,
    title: '串匹配 · BF、KMP 与环串检测',
    complexity: ComplexitySpec(
      time: 'BF O(nm) / KMP O(n+m)',
      space: 'BF O(1) / KMP O(m)',
    ),
    textbookReferences: ['算法 4.1～4.5', '案例 4.1'],
  ),
  AlgorithmMeta(
    id: 'ch3_cases_expr_dance',
    chapterId: ChapterId.ch3,
    title: '栈队列案例 · 转换、匹配、求值与舞伴',
    complexity: ComplexitySpec(
      time: '转换 O(log N)；匹配/求值 O(n)',
      space: '栈与队列 O(n)',
    ),
    textbookReferences: ['算法 3.20～3.23', '表 3.1 算符优先关系'],
  ),
  AlgorithmMeta(
    id: 'ch3_queue_sq_link',
    chapterId: ChapterId.ch3,
    title: '队列 · 循环复用与链队复位',
    complexity: ComplexitySpec(
      time: '入队/出队/读首元 O(1)',
      space: '循环容量 M−1；链队保留头结点',
    ),
    textbookReferences: ['算法 3.11～3.19', '线性假溢出对照'],
  ),
  AlgorithmMeta(
    id: 'ch3_recursion_hanoi',
    chapterId: ChapterId.ch3,
    title: '递归 · 汉诺塔与返回地址',
    complexity: ComplexitySpec(
      time: '汉诺塔 Θ(2ⁿ)；阶乘/遍历 O(n)',
      space: '活动工作栈 O(n)',
    ),
    textbookReferences: ['算法 3.9～3.10', '图 3.10 / 3.11', 'Fact / Fib'],
  ),
  AlgorithmMeta(
    id: 'ch3_stack_sq_link',
    chapterId: ChapterId.ch3,
    title: '栈 · 顺序、链式与共享双栈',
    complexity: ComplexitySpec(
      time: '入栈/出栈/读栈顶 O(1)',
      space: '链栈入栈新增 1 节点；操作辅助 O(1)',
    ),
    textbookReferences: ['算法 3.1～3.8', '共享双栈习题'],
  ),
  AlgorithmMeta(
    id: 'ch2_cases_polyn_book',
    chapterId: ChapterId.ch2,
    title: '多项式与图书 · 稀疏相加和增删查',
    complexity: ComplexitySpec(
      time: '建表 O(n²)；相加 O(m+n)；图书定位 O(n)',
      space: '多项式原地相加辅助 O(1)',
    ),
    textbookReferences: ['案例 2.1～2.3', '算法 2.18～2.19'],
  ),
  AlgorithmMeta(
    id: 'ch2_merge_compare',
    chapterId: ChapterId.ch2,
    title: '线性表合并 · 数组复制与链式穿接',
    complexity: ComplexitySpec(
      time: '并集 O(mn+n)；有序归并 O(m+n)',
      space: '新数组 O(m+n) / 链式辅助 O(1)',
    ),
    textbookReferences: ['表 2.2 / 2.3', '算法 2.15～2.17'],
  ),
  AlgorithmMeta(
    id: 'ch2_circular_dulink',
    chapterId: ChapterId.ch2,
    title: '循环与双向链表 · 合并与四指针',
    complexity: ComplexitySpec(
      time: '尾指针合并 O(1)；按位序定位 O(n)',
      space: '辅助空间 O(1)',
    ),
    textbookReferences: ['2.5.3', '算法 2.13～2.14'],
  ),
  AlgorithmMeta(
    id: 'ch2_linklist_ops',
    chapterId: ChapterId.ch2,
    title: '单链表 · 指针操作与断链反例',
    complexity: ComplexitySpec(time: '定位 O(n)；局部接链 O(1)', space: '操作辅助空间 O(1)'),
    textbookReferences: ['算法 2.6～2.12'],
  ),
  AlgorithmMeta(
    id: 'ch2_sqlist_ops',
    chapterId: ChapterId.ch2,
    title: '顺序表 · 基本操作与移动分析',
    complexity: ComplexitySpec(
      time: '读取 O(1)；查找/插入/删除 O(n)',
      space: '操作辅助空间 O(1)',
    ),
    textbookReferences: ['算法 2.1～2.5'],
  ),
  AlgorithmMeta(
    id: 'ch1_complexity_lab',
    chapterId: ChapterId.ch1,
    title: '复杂度 · 增长、频度与空间',
    complexity: ComplexitySpec(
      time: '随示例 O(1)～O(n³)',
      space: '原地 O(1) / 副本 O(n)',
    ),
    textbookReferences: ['1.4 例 1.4～1.11', '图 1.7'],
  ),
  AlgorithmMeta(
    id: 'ch1_adt_complex',
    chapterId: ChapterId.ch1,
    title: 'ADT Complex · 复数与封装',
    complexity: ComplexitySpec(time: 'O(1)', space: 'O(1)'),
    textbookReferences: ['1.3 抽象数据类型 ADT Complex'],
  ),
  AlgorithmMeta(
    id: 'ch1_struct_mapping',
    chapterId: ChapterId.ch1,
    title: '逻辑结构与存储结构映射',
    complexity: ComplexitySpec(
      time: '顺序定位 O(1)；链表按序号定位 O(n)',
      space: '本例固定 64 字节模拟内存',
    ),
    textbookReferences: ['1.1 例 1.1～1.3', '1.2 逻辑结构与存储结构'],
  ),
];
AlgorithmMeta? moduleById(String id) =>
    modules.where((m) => m.id == id).firstOrNull;
