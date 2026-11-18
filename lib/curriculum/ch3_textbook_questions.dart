import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';

const _chapter = '《数据结构（C语言版）》第2版，ISBN 978-7-115-37950-4，第3章习题';
const _p83 = '$_chapter，书页83（PDF第91页）';
const _p83to84 = '$_chapter，书页83～84（PDF第91～92页）';
const _p84 = '$_chapter，书页84（PDF第92页）';
const _p84to85 = '$_chapter，书页84～85（PDF第92～93页）';

const ch3TextbookChoices = <ChoiceQuestion>[
  ChoiceQuestion(
    id: 'textbook_ch3_1_01',
    chapterId: ChapterId.ch3,
    title: '第1题（1）',
    sourceLabel: '$_p83，第1题（1）',
    topic: "出栈次序",
    reproLab: LabDeepLinkPayload(
      moduleId: 'ch3_stack_sq_link',
      presetPayloadJson: '{"push":[1,2,3,4,5],"pop":[4,3,1,2,5]}',
      targetStepIndex: 7,
      highlightReason: '弹出 4 和 3 后，2 挡在 1 上方。',
    ),
    promptMarkdown: "若让元素1，2，3，4，5依次进栈，则出栈次序不可能出现（　）的情况。",
    options: ["5，4，3，2，1", "2，1，5，4，3", "4，3，1，2，5", "2，3，5，4，1"],
    correctIndices: {2},
    explanationMarkdown: "要先弹出 4，须先将 1 至 4 压栈。随后弹出 3 时，2 仍压在 1 上面，因此下一个不能弹出 1。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_02',
    chapterId: ChapterId.ch3,
    title: '第1题（2）',
    sourceLabel: '$_p83，第1题（2）',
    topic: "固定首个出栈元素",
    reproLab: LabDeepLinkPayload(
      moduleId: 'ch3_stack_sq_link',
      presetPayloadJson: '{"push":[1,2,3,4],"pop":[4,3,2,1]}',
      targetStepIndex: 6,
      highlightReason: '以 n=4 为例，先弹出 4 后，第二次只能弹出 3。',
    ),
    promptMarkdown: "若已知一个栈的入栈序列是1，2，3，…，n，其输出序列为p₁，p₂，p₃，…，pₙ，若p₁=n，则pᵢ为（　）。",
    options: ["i", "n−i", "n−i+1", "不确定"],
    correctIndices: {2},
    explanationMarkdown:
        "第一次弹出 n 时，全部 n 个元素都已入栈。其后的弹出顺序只能是 n−1 到 1，第 i 个值为 n−i+1。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_03',
    chapterId: ChapterId.ch3,
    title: '第1题（3）',
    sourceLabel: '$_p83，第1题（3）',
    topic: "循环队列长度",
    promptMarkdown:
        "数组Q[n]用来表示一个循环队列，f为当前队列头元素的前一位置，r为队尾元素的位置，假定队列中元素的个数小于n，计算队列中元素个数的公式为（　）。",
    options: ["r−f", "(n+f−r)%n", "n+r−f", "(n+r−f)%n"],
    correctIndices: {3},
    explanationMarkdown: "从 f 向前走到 r 的步数就是元素个数。按 n 取模处理绕回；元素数小于 n 时，此余数唯一确定长度。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_04',
    chapterId: ChapterId.ch3,
    title: '第1题（4）',
    sourceLabel: '$_p83，第1题（4）',
    topic: "链栈弹出",
    promptMarkdown:
        "链式栈结点为（data，link），top指向栈顶，若想摘除栈顶结点，并将删除结点的值保存到x中，则应执行操作（　）。",
    options: [
      "x=top->data;top=top->link;",
      "top=top->link;x=top->link;",
      "x=top;top=top->link;",
      "x=top->link;",
    ],
    correctIndices: {0},
    explanationMarkdown: "先读取旧栈顶的 data，再让 top 沿 link 指向下一结点。题目的两步关注取值和摘链。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_05',
    chapterId: ChapterId.ch3,
    title: '第1题（5）',
    sourceLabel: '$_p83to84，第1题（5）',
    topic: "阶乘调用次数",
    promptMarkdown: '''设有一个递归算法如下：

```c
int fact(int n)
{//n 大于等于 0
    if(n<=0) return 1;
    else return n*fact(n-1);
}
```

则计算fact(n)需要调用该函数的次数为（　）。''',
    options: ["n+1", "n−1", "n", "n+2"],
    correctIndices: {0},
    explanationMarkdown: "从首次 fact(n) 到基例 fact(0)，参数依次为 n、n−1、…、0，共 n+1 次函数调用。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_06',
    chapterId: ChapterId.ch3,
    title: '第1题（6）',
    sourceLabel: '$_p84，第1题（6）',
    topic: "栈的应用",
    promptMarkdown: "栈在（　）中有所应用。",
    options: ["递归调用", "函数调用", "表达式求值", "前三个选项都有"],
    correctIndices: {3},
    explanationMarkdown: "函数调用与递归调用按后调用先返回的顺序恢复现场。表达式求值也可以使用栈保存操作数和运算符。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_07',
    chapterId: ChapterId.ch3,
    title: '第1题（7）',
    sourceLabel: '$_p84，第1题（7）',
    topic: "打印缓冲区",
    promptMarkdown:
        "为解决计算机主机与打印机间速度不匹配问题，通常设一个打印数据缓冲区。主机将要输出的数据依次写入该缓冲区，而打印机则依次从该缓冲区中取出数据。该缓冲区的逻辑结构应该是（　）。",
    options: ["队列", "栈", "线性表", "有序表"],
    correctIndices: {0},
    explanationMarkdown: "先写入的数据应先交给打印机，队列的先进先出次序正好表达这个要求。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_08',
    chapterId: ChapterId.ch3,
    title: '第1题（8）',
    sourceLabel: '$_p84，第1题（8）',
    topic: "栈的最小容量",
    promptMarkdown:
        "设栈S和队列Q的初始状态为空，元素e1、e2、e3、e4、e5和e6依次进入栈S，一个元素出栈后即进入Q，若6个元素出队的序列是e2、e4、e3、e6、e5和e1，则栈S的容量至少应该是（　）。",
    options: ["2", "3", "4", "6"],
    correctIndices: {1},
    explanationMarkdown:
        "出队保持出栈次序。弹出 e2 后栈内还有 e1；要下一个弹出 e4，必须让 e1、e3、e4 同时在栈内。弹出 e4、e3 后再压入 e5、e6，也只用三个槽。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_09',
    chapterId: ChapterId.ch3,
    title: '第1题（9）',
    sourceLabel: '$_p84，第1题（9）',
    topic: "逆向增长的顺序栈",
    promptMarkdown: "若一个栈以向量V[1..n]存储，初始栈顶指针top设为n+1，则元素x进栈的正确操作是（　）。",
    options: [
      "top++; V[top]=x;",
      "V[top]=x; top++;",
      "top--; V[top]=x;",
      "V[top]=x; top--;",
    ],
    correctIndices: {2},
    explanationMarkdown: "空栈 top 在有效区间右侧。先减一使 top 指向 n，再写入第一个元素；后续继续向小下标增长。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_10',
    chapterId: ChapterId.ch3,
    title: '第1题（10）',
    sourceLabel: '$_p84，第1题（10）',
    topic: "括号配对",
    promptMarkdown: "设计一个判别表达式中左、右括号是否配对出现的算法，采用（　）数据结构最佳。",
    options: ["线性表的顺序存储结构", "队列", "线性表的链式存储结构", "栈"],
    correctIndices: {3},
    explanationMarkdown: "每遇到一个右括号，就要与最近的尚未匹配的左括号配对，所需顺序是后进先出。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_11',
    chapterId: ChapterId.ch3,
    title: '第1题（11）',
    sourceLabel: '$_p84，第1题（11）',
    topic: "链队出队",
    promptMarkdown: "用链接方式存储的队列，在进行删除运算时（　）。",
    options: ["仅修改头指针", "仅修改尾指针", "头、尾指针都要修改", "头、尾指针可能都要修改"],
    correctIndices: {3},
    explanationMarkdown: "从队头摘除元素；若删去最后一个数据结点，队尾也要恢复为空队时的位置。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_12',
    chapterId: ChapterId.ch3,
    title: '第1题（12）',
    sourceLabel: '$_p84，第1题（12）',
    topic: "循环队列入队",
    promptMarkdown: "循环队列存储在数组A[0..m]中，则入队时的操作为（　）。",
    options: [
      "rear=rear+1",
      "rear=(rear+1)%(m-1)",
      "rear=(rear+1)%m",
      "rear=(rear+1)%(m+1)",
    ],
    correctIndices: {3},
    explanationMarkdown: "下标从 0 到 m，两端均包含，共 m+1 个位置。从下标 m 前进一格应回到 0。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_13',
    chapterId: ChapterId.ch3,
    title: '第1题（13）',
    sourceLabel: '$_p84，第1题（13）',
    topic: "循环队列判空",
    promptMarkdown: "最大容量为n的循环队列，队尾指针是rear，队头是front，则队空的条件是（　）。",
    options: [
      "(rear+1)%n==front",
      "rear==front",
      "rear+1==front",
      "(rear-1)%n==front",
    ],
    correctIndices: {1},
    explanationMarkdown:
        "按本章以 front 与 rear 相同表示空队的约定，空队时两者重合；在预留一个空位的实现中，rear 的下一位置等于 front 才是满队。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_14',
    chapterId: ChapterId.ch3,
    title: '第1题（14）',
    sourceLabel: '$_p84，第1题（14）',
    topic: "端点操作",
    promptMarkdown: "栈和队列的共同点是（　）。",
    options: ["都是先进先出", "都是先进后出", "只允许在端点处插入和删除元素", "没有共同点"],
    correctIndices: {2},
    explanationMarkdown: "栈的插入和删除都在栈顶。队列在队尾插入、队头删除，两者都把操作限制在端点。",
  ),
  ChoiceQuestion(
    id: 'textbook_ch3_1_15',
    chapterId: ChapterId.ch3,
    title: '第1题（15）',
    sourceLabel: '$_p84to85，第1题（15）',
    topic: "递归算法组成",
    promptMarkdown: "一个递归算法必须包括（　）。",
    options: ["递归部分", "终止条件和递归部分", "迭代部分", "终止条件和迭代部分"],
    correctIndices: {1},
    explanationMarkdown: "递归部分把问题缩小，终止条件给出可直接求解的基例，使调用能够返回。",
  ),
];
