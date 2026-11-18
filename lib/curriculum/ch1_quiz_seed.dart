import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';

const ch1QuizSeed = <QuizQuestion>[
  ChoiceQuestion(
    id: "ch1_choice_01",
    chapterId: ChapterId.ch1,
    title: "数据元素与数据项",
    promptMarkdown: "通常把什么作为数据结构中讨论和处理的基本单位？",
    options: ["数据元素", "数据项", "内存字节", "源代码语句"],
    correctIndices: {0},
    explanationMarkdown: "数据元素是讨论数据关系的基本单位；一个元素可以由多个数据项组成。",
    topic: "data-element",
  ),
  ChoiceQuestion(
    id: "ch1_choice_02",
    chapterId: ChapterId.ch1,
    title: "逻辑结构",
    promptMarkdown: "下列哪项描述逻辑结构？",
    options: ["元素之间的逻辑关系", "变量在内存中的绝对地址", "节点结构体的字节对齐", "文件的物理扇区"],
    correctIndices: {0},
    explanationMarkdown: "逻辑结构刻画元素之间的关系，与具体存储布局分离。",
    topic: "logical-structure",
  ),
  ChoiceQuestion(
    id: "ch1_choice_03",
    chapterId: ChapterId.ch1,
    title: "线性结构",
    promptMarkdown: "关于非空线性表，下列哪项正确？",
    options: [
      "每个元素都有两个前驱",
      "除首元素外，每个元素恰有一个直接前驱",
      "所有元素互不关联",
      "一个元素可以有任意多个直接后继",
    ],
    correctIndices: {1},
    explanationMarkdown: "首元素无直接前驱，尾元素无直接后继，其余元素各有一个直接前驱和后继。",
    topic: "linear-structure",
  ),
  ChoiceQuestion(
    id: "ch1_choice_04",
    chapterId: ChapterId.ch1,
    title: "抽象数据类型",
    promptMarkdown: "ADT 的定义应包含哪组内容？",
    options: ["数据对象、关系、基本操作", "CPU 型号、地址、寄存器", "仅数据类型名称", "只包含函数的机器码"],
    correctIndices: {0},
    explanationMarkdown: "ADT 描述 D、S、P，即数据对象、关系和基本操作；具体实现可以隐藏。",
    topic: "adt",
  ),
  ChoiceQuestion(
    id: "ch1_choice_05",
    chapterId: ChapterId.ch1,
    title: "算法的有穷性",
    promptMarkdown: "下列哪项是算法有穷性的含义？",
    options: ["对合法输入在有限步骤内结束", "只允许一个输入", "一定没有循环", "运行时间必须小于一秒"],
    correctIndices: {0},
    explanationMarkdown: "有穷性要求算法在有限步骤内终止，不排斥循环和递归，也不指定固定秒数。",
    topic: "algorithm-properties",
  ),
  ChoiceQuestion(
    id: "ch1_choice_06",
    chapterId: ChapterId.ch1,
    title: "时间复杂度的对象",
    promptMarkdown: "渐近时间复杂度主要描述什么？",
    options: ["问题规模增长时基本操作次数的增长趋势", "程序文件大小", "某台电脑的一次运行秒数", "编译器安装时间"],
    correctIndices: {0},
    explanationMarkdown: "以规模 n 建模基本操作次数，可比较算法增长趋势；常数时间仍受硬件和实现影响。",
    topic: "asymptotic-analysis",
  ),
  TraceTableQuestion(
    id: "ch1_trace_01",
    chapterId: ChapterId.ch1,
    title: "循环一：固定次数",
    promptMarkdown:
        "对 n≥1，统计语句 x++ 的执行次数。\n```c\nfor(i=0;i<100;i++)\n  for(j=0;j<10;j++) x++;\n```\n填写 n=8 的次数与关于 n 的紧确渐近时间阶。",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["1000", "Θ(1)"],
    ],
    explanationMarkdown: "两重循环的边界均为常数，与 n 无关；执行 100×10=1000 次。",
    topic: "constant-loop",
  ),
  TraceTableQuestion(
    id: "ch1_trace_02",
    chapterId: ChapterId.ch1,
    title: "循环二：一次扫描",
    promptMarkdown: "对 n≥1，统计 x++：\n```c\nfor(i=0;i<n;i++) x++;\n```",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["8", "Θ(n)"],
    ],
    explanationMarkdown: "i 取 0～n−1，共 n 次。",
    topic: "linear-loop",
  ),
  TraceTableQuestion(
    id: "ch1_trace_03",
    chapterId: ChapterId.ch1,
    title: "循环三：方形嵌套",
    promptMarkdown:
        "对 n≥1，统计 x++：\n```c\nfor(i=0;i<n;i++)\n  for(j=0;j<n;j++) x++;\n```",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["64", "Θ(n²)"],
    ],
    explanationMarkdown: "每个外层迭代执行 n 次，共 n×n 次。",
    topic: "square-loop",
  ),
  TraceTableQuestion(
    id: "ch1_trace_04",
    chapterId: ChapterId.ch1,
    title: "循环四：三角嵌套",
    promptMarkdown:
        "对 n≥1，统计 x++：\n```c\nfor(i=1;i<=n;i++)\n  for(j=1;j<=i;j++) x++;\n```",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["36", "Θ(n²)"],
    ],
    explanationMarkdown: "总次数 1+2+…+n=n(n+1)/2；n=8 时为 36。",
    topic: "triangular-loop",
  ),
  TraceTableQuestion(
    id: "ch1_trace_05",
    chapterId: ChapterId.ch1,
    title: "循环五：倍增",
    promptMarkdown:
        "对 n≥1，忽略机器整数溢出，统计 x++：\n```c\nfor(i=1;i<=n;i*=2) x++;\n```",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["4", "Θ(log n)"],
    ],
    explanationMarkdown: "访问 1、2、4、8；一般次数 floor(log₂n)+1。",
    topic: "doubling-loop",
  ),
  TraceTableQuestion(
    id: "ch1_trace_06",
    chapterId: ChapterId.ch1,
    title: "循环六：内层倍增",
    promptMarkdown:
        "对 n≥1，忽略机器整数溢出，统计 x++：\n```c\nfor(i=1;i<=n;i++)\n  for(j=1;j<=i;j*=2) x++;\n```",
    columns: ["执行次数（n=8）", "紧确时间阶"],
    rowLabels: ["整个循环"],
    answerRows: [
      ["21", "Θ(n log n)"],
    ],
    explanationMarkdown:
        "次数为 Σ(i=1..n)(floor(log₂i)+1)。n=8 时 1+2+2+3+3+3+3+4=21；上、下界均为 n log n 量级。",
    topic: "nested-doubling",
  ),
];
