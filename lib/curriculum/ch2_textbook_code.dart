import 'dart:math';
import '../enum/ds_enums.dart';
import '../models/quiz_question.dart';
import 'ch2_code_quiz_seed.dart';
import 'ch2_code_support.dart';

part 'ch2_textbook_code_cases.dart';
part 'ch2_textbook_code_references.dart';

const _source =
    '《数据结构（C语言版）》第2版，ISBN 978-7-115-37950-4，第2章习题，书页53（PDF第61页），第2题';

final ch2TextbookCode = List<CodeQuestion>.unmodifiable([
  _exercise(
    1,
    '将两个递增的有序链表合并为一个递增的有序链表。要求结果链表仍使用原来两个链表的存储空间，不另外占用其他的存储空间。表中不允许有重复的数据。',
    cases: _setCases(1),
  ),
  _exercise(
    2,
    '将两个非递减的有序链表合并为一个非递增的有序链表。要求结果链表仍使用原来两个链表的存储空间，不另外占用其他的存储空间。表中允许有重复的数据。',
    title: '归并为非递增链表',
  ),
  _exercise(
    3,
    '已知两个链表A和B分别表示两个集合，其元素递增排列。请设计一个算法，用于求出A与B的交集，并存放在A链表中。',
    cases: _setCases(3),
  ),
  _exercise(
    4,
    '已知两个链表A和B分别表示两个集合，其元素递增排列。请设计算法求出两个集合A和B的差集（即仅由在A中出现而不在B中出现的元素所构成的集合），并以同样的形式存储，同时返回该集合的元素个数。',
    cases: _setCases(4),
  ),
  _exercise(
    5,
    '设计算法将一个带头结点的单链表A分解为两个具有相同结构的链表B和C，其中B表的结点为A表中值小于零的结点，而C表的结点为A表中值大于零的结点（链表A中的元素为非零整数，要求B、C表利用A表的结点）。',
    title: '复用结点拆分正负链表',
    solution: _split,
    cases: _splitCases(),
  ),
  _exercise(6, '设计一个算法，通过一趟遍历确定长度为n的单链表中值最大的结点。', title: '一趟遍历查找最大值结点'),
  _exercise(
    7,
    '设计一个算法，将链表中所有结点的链接方向“原地”逆转，即要求仅利用原表的存储空间，换句话说，要求算法的空间复杂度为O(1)。',
  ),
  _exercise(
    8,
    '设计一个算法，删除递增有序链表中值大于mink且小于maxk的所有元素（mink和maxk是给定的两个参数，其值可以和表中的元素相同，也可以不同）。',
    title: '递增链表删除开区间',
    solution: _interval,
    cases: _intervalCases(),
  ),
  _exercise(
    9,
    '已知p指向双向循环链表中的一个结点，其结点结构为data、prior、next三个域，写出算法change(p)，交换p所指向的结点及其前驱结点的顺序。',
    title: '双向循环链表交换相邻结点',
    solution: _swap,
    cases: _swapCases(),
  ),
  _exercise(
    10,
    '已知长度为n的线性表A采用顺序存储结构，请写一个时间复杂度为O(n)、空间复杂度为O(1)的算法，该算法可删除线性表中所有值为item的数据元素。',
  ),
]);

CodeQuestion _exercise(
  int number,
  String prompt, {
  String? title,
  _Solution? solution,
  List<AlgorithmTestCase>? cases,
}) {
  final suffix = number.toString().padLeft(2, '0');
  final existing = ch2CodeQuizSeed.singleWhere(
    (q) => q.id == 'ch2_code_$suffix',
  );
  final template = solution?.template ?? existing.template;
  final blanks = solution == null
      ? existing.blanks
      : [
          for (final (i, answer) in solution.answers.indexed)
            CodeBlank(marker: '/*BLANK_${i + 1}*/', acceptedAnswers: [answer]),
        ];
  var reference = existing.referenceCode;
  if (solution != null) {
    reference = template;
    for (final blank in blanks) {
      reference = reference.replaceFirst(
        blank.marker,
        blank.acceptedAnswers.first,
      );
    }
  }
  return CodeQuestion(
    id: 'textbook_ch2_2_$suffix',
    chapterId: ChapterId.ch2,
    title: '第2题（$number）· ${title ?? existing.title}',
    sourceLabel: '$_source（$number）',
    topic: existing.topic,
    promptMarkdown: prompt,
    explanationMarkdown: solution?.explanation ?? existing.explanationMarkdown,
    template: template,
    referenceCode: reference,
    dartReferenceCode: solution?.dart ?? existing.dartReferenceCode,
    blanks: blanks,
    testCases:
        cases ??
        [
          for (final c in existing.testCases)
            AlgorithmTestCase(
              name: c.name == '主题重建示例' ? '演算示例' : c.name,
              input: c.input,
              expected: c.expected,
            ),
        ],
  );
}
