import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';

const _chapter = '《数据结构（C语言版）》第2版，ISBN 978-7-115-37950-4，第1章习题';
const _page16 = '$_chapter，书页16（PDF第24页）';
const _page17 = '$_chapter，书页17（PDF第25页）';
const _page18 = '$_chapter，书页18（PDF第26页）';

const ch1TextbookShortAnswers = <ShortAnswerQuestion>[
  ShortAnswerQuestion(
    id: 'textbook_ch1_1',
    chapterId: ChapterId.ch1,
    title: '第1题',
    sourceLabel: '$_page16，第1题',
    topic: "数据结构的基本概念",
    promptMarkdown: "简述下列概念：数据、数据元素、数据项、数据对象、数据结构、逻辑结构、存储结构、抽象数据类型。",
    explanationMarkdown: r'''- 数据是可由计算机识别和处理的符号表示，如数字、文本和图像。
- 数据元素是组织和处理数据时作为整体考虑的基本单位，如一条学生记录。
- 数据项是组成数据元素的、在当前问题中不可再分的最小单位，如记录中的学号。
- 数据对象是性质相同的数据元素的集合，如全班学生记录的集合。
- 数据结构是相互之间存在特定关系的数据元素的集合。
- 逻辑结构描述元素之间的关系，如线性次序或树的父子关系。
- 存储结构是数据元素及其逻辑关系在计算机中的表示。
- 抽象数据类型由数据对象、对象上的关系和基本操作共同定义，其使用者通过约定的操作访问数据。''',
  ),
  ShortAnswerQuestion(
    id: 'textbook_ch1_2',
    chapterId: ChapterId.ch1,
    title: '第2题',
    sourceLabel: '$_page16，第2题',
    topic: "逻辑结构与存储结构",
    promptMarkdown: "试举一个数据结构的例子，叙述其逻辑结构和存储结构两个层次的含义及相互关系。",
    explanationMarkdown:
        "以按到达顺序排队的人员为例，甲、乙、丙依次排列，乙的直接前驱是甲，直接后继是丙。用数组保存时可用相邻下标表示这一先后关系；用链表保存时可用节点之间的链接表示它。两种存储方式实现同一个逻辑次序。",
  ),
  ShortAnswerQuestion(
    id: 'textbook_ch1_3',
    chapterId: ChapterId.ch1,
    title: '第3题',
    sourceLabel: '$_page17，第3题',
    topic: "四种基本关系",
    promptMarkdown: "简述逻辑结构的四种基本关系并画出它们的关系图。",
    explanationMarkdown:
        r'''集合中的元素同属一个集合，没有额外的次序。线性结构按一对一的前驱、后继关系组织。树形结构中一个双亲可以有多个孩子，每个非根节点只有一个双亲。图结构可表达多对多的关系。

```text
集合          线性          树形          图
{A, B, C}     A → B → C       A         A ─── B
                             / \        | \   |
                            B   C       C ─── D
```''',
  ),
  ShortAnswerQuestion(
    id: 'textbook_ch1_4',
    chapterId: ChapterId.ch1,
    title: '第4题',
    sourceLabel: '$_page17，第4题',
    topic: "存储结构",
    promptMarkdown: "存储结构由哪两种基本的存储方法实现？",
    explanationMarkdown: "顺序存储和链式存储。顺序存储通过存储位置体现元素的逻辑关系；链式存储在结点中保存指向相关结点的链接。",
  ),
];

const ch1TextbookChoices = <ChoiceQuestion>[
  ChoiceQuestion(
    id: 'textbook_ch1_5_01',
    chapterId: ChapterId.ch1,
    title: '第5题（1）· 逻辑结构分类',
    sourceLabel: '$_page17，第5题（1）',
    topic: '逻辑结构分类',
    promptMarkdown: '在数据结构中，从逻辑上可以把数据结构分成（　）。',
    options: ['动态结构和静态结构', '紧凑结构和非紧凑结构', '线性结构和非线性结构', '内部结构和外部结构'],
    correctIndices: {2},
    explanationMarkdown: '按元素之间的逻辑关系，可分为线性结构和非线性结构。',
  ),
  ChoiceQuestion(
    id: 'textbook_ch1_5_02',
    chapterId: ChapterId.ch1,
    title: '第5题（2）· 逻辑结构与存储',
    sourceLabel: '$_page17，第5题（2）',
    topic: '逻辑结构与存储',
    promptMarkdown: '与数据元素本身的形式、内容、相对位置、个数无关的是数据的（　）。',
    options: ['存储结构', '存储实现', '逻辑结构', '运算实现'],
    correctIndices: {2},
    explanationMarkdown: '逻辑结构描述元素之间的关系。相同的关系可以出现在不同类型的数据上，也可以用不同的存储方式实现。',
  ),
  ChoiceQuestion(
    id: 'textbook_ch1_5_03',
    chapterId: ChapterId.ch1,
    title: '第5题（3）· 数据元素的特性',
    sourceLabel: '$_page17，第5题（3）',
    topic: '数据元素的特性',
    promptMarkdown: '通常要求同一逻辑结构中的所有数据元素具有相同的特性，这意味着（　）。',
    options: [
      '数据具有同一特点',
      '不仅数据元素所包含的数据项的个数要相同，而且对应数据项的类型要一致',
      '每个数据元素都一样',
      '数据元素所包含的数据项的个数相等',
    ],
    correctIndices: {1},
    explanationMarkdown: '同一结构中的记录有相同的字段组成和对应的字段类型，字段的值可以不同。',
  ),
  ChoiceQuestion(
    id: 'textbook_ch1_5_04',
    chapterId: ChapterId.ch1,
    title: '第5题（4）· 数据结构的基本概念',
    sourceLabel: '$_page17，第5题（4）',
    topic: '数据结构的基本概念',
    promptMarkdown: '以下说法正确的是（　）。',
    options: [
      '数据元素是数据的最小单位',
      '数据项是数据的基本单位',
      '数据结构是带有结构的各数据项的集合',
      '一些表面上很不相同的数据可以有相同的逻辑结构',
    ],
    correctIndices: {3},
    explanationMarkdown: '例如，学号序列与书名序列都可以具有线性关系。数据的基本单位是数据元素，组成元素的最小单位是数据项。',
  ),
  ChoiceQuestion(
    id: 'textbook_ch1_5_05',
    chapterId: ChapterId.ch1,
    title: '第5题（5）· 时间复杂度',
    sourceLabel: '$_page17，第5题（5）',
    topic: '时间复杂度',
    promptMarkdown: '算法的时间复杂度取决于（　）。',
    options: ['问题的规模', '待处理数据的初态', '计算机的配置', 'A 和 B'],
    correctIndices: {3},
    explanationMarkdown: '基本操作的次数可随输入规模及初始排列而变。例如，插入排序对已经有序和逆序的同规模序列执行的比较次数不同。',
  ),
  ChoiceQuestion(
    id: 'textbook_ch1_5_06',
    chapterId: ChapterId.ch1,
    title: '第5题（6）· 非线性结构',
    sourceLabel: '$_page17，第5题（6）',
    topic: '非线性结构',
    promptMarkdown: '以下数据结构中，（　）是非线性数据结构。',
    options: ['树', '字符串', '队列', '栈'],
    correctIndices: {0},
    explanationMarkdown: '树的节点可有多个孩子。字符串、队列和栈的元素按线性次序组织。',
  ),
];

const ch1TextbookTraces = <TraceTableQuestion>[
  TraceTableQuestion(
    id: 'textbook_ch1_6_01',
    chapterId: ChapterId.ch1,
    title: '第6题（1）',
    sourceLabel: '$_page17，第6题（1）',
    topic: "固定初值与分支",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
x=90; y=100;
while(y>0)
    if(x>100)
        {x=x-10;y--;}
    else x++;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["while 循环体"],
    answerRows: [
      ["1101", "O(1)"],
    ],
    explanationMarkdown:
        "第一次令 y 减 1 前，x 从 90 增到 101，共执行 11 次 x++。此后每次减 1 前执行 10 次 x++。y 共减少 100 次，所以循环体执行 11 + 99×10 + 100 = 1101 次，初值固定。",
  ),
  TraceTableQuestion(
    id: 'textbook_ch1_6_02',
    chapterId: ChapterId.ch1,
    title: '第6题（2）',
    sourceLabel: '$_page17，第6题（2）',
    topic: "矩形数组置零",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
for(i=0; i<n; i++)
    for(j=0; j<m; j++)
        a[i][j]=0;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["n=9，m=4 时的赋值"],
    answerRows: [
      ["36", "O(nm)"],
    ],
    explanationMarkdown: "对正整数规模 n、m，每行清零 m 个元素，共 n 行，赋值 nm 次。",
  ),
  TraceTableQuestion(
    id: 'textbook_ch1_6_03',
    chapterId: ChapterId.ch1,
    title: '第6题（3）',
    sourceLabel: '$_page17，第6题（3）',
    topic: "矩阵元素求和",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
s=0;
for(i=0; i<n; i++)
    for(j=0; j<n; j++)
        s+=B[i][j];
sum=s;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["n=9 时的累加"],
    answerRows: [
      ["81", "O(n²)"],
    ],
    explanationMarkdown: "共 n 行，每行累加 n 次。循环前后的两次单独赋值只增加常数时间。",
  ),
  TraceTableQuestion(
    id: 'textbook_ch1_6_04',
    chapterId: ChapterId.ch1,
    title: '第6题（4）',
    sourceLabel: '$_page17，第6题（4）',
    topic: "以 3 为倍率的循环",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
i=1;
while(i<=n)
    i=i*3;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["n=9 时的乘法"],
    answerRows: [
      ["3", "O(log n)"],
    ],
    explanationMarkdown:
        "第 k 次乘法后 i=3ᵏ。对 n≥1，循环在 i 首次大于 n 时停止，乘法次数为 ⌊log₃ n⌋+1。n=9 时，i 从 1 经 3、9 到 27。",
  ),
  TraceTableQuestion(
    id: 'textbook_ch1_6_05',
    chapterId: ChapterId.ch1,
    title: '第6题（5）',
    sourceLabel: '$_page18，第6题（5）',
    topic: "逐行缩短的内层循环",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
x=0;
for(i=1; i<n; i++)
    for(j=1; j<=n-i; j++)
        x++;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["n=9 时的 x++"],
    answerRows: [
      ["36", "O(n²)"],
    ],
    explanationMarkdown: "外层 i 从 1 到 n−1，对应的内层次数依次为 n−1、n−2、…、1。总次数为 n(n−1)/2。",
  ),
  TraceTableQuestion(
    id: 'textbook_ch1_6_06',
    chapterId: ChapterId.ch1,
    title: '第6题（6）',
    sourceLabel: '$_page18，第6题（6）',
    topic: "平方边界",
    promptMarkdown: '''试分析下列各算法的时间复杂度。

```c
x=n; //n>1
y=0;
while(x>=(y+1)*(y+1))
    y++;
```''',
    columns: ['执行次数', '时间复杂度（最紧的 O 阶）'],
    rowLabels: ["n=9 时的 y++"],
    answerRows: [
      ["3", "O(√n)"],
    ],
    explanationMarkdown:
        "只有下一整数的平方不大于 n 才会执行 y++。退出时 y²≤n<(y+1)²，因此循环体执行 ⌊√n⌋ 次。",
  ),
];
