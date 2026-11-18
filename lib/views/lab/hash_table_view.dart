import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../curriculum/ch7_search/hash_table.dart';
import '../../models/playback_model.dart';
import 'lesson_player.dart';

part 'hash_table_stage.dart';

class HashTableView extends ConsumerStatefulWidget {
  const HashTableView({super.key});
  @override
  ConsumerState<HashTableView> createState() => _HashTableViewState();
}

class _HashTableViewState extends LessonPlayer<HashTableView, HashInput> {
  @override
  final module = const HashModule();
  @override
  HashInput input = const HashInput();
  @override
  String get presetKey => 'hash-presets';
  @override
  String get theoryHint =>
      '算法 7.10 从散列入口开始查找。m 是表长，p 是本实验的初始地址数；开放地址的偏移按 m 回绕。成功 ASL 对现有记录等权，失败 ASL 对 0 到 p−1 的入口等权。链地址法沿 next 逐项比较，失败时计入末尾 NULL 的一次检查。';
  @override
  List<Widget> controls(PlaybackState state) => [
    DropdownButton<HashFunction>(
      key: const ValueKey('hash-function'),
      value: input.function,
      items: [
        for (final f in HashFunction.values)
          DropdownMenuItem(value: f, child: Text(f.label)),
      ],
      onChanged: (f) {
        if (f != null) changeInput(input.change(function: f));
      },
    ),
    DropdownButton<HashCollision>(
      key: const ValueKey('hash-method'),
      value: input.collision,
      items: [
        for (final c in HashCollision.values)
          DropdownMenuItem(value: c, child: Text(c.label)),
      ],
      onChanged: (c) {
        if (c != null) changeInput(input.change(collision: c));
      },
    ),
    TextButton.icon(
      key: const ValueKey('hash-edit'),
      onPressed: () async {
        final next = await showDialog<HashInput>(
          context: context,
          builder: (_) => _HashEditor(input),
        );
        if (next != null && mounted) runCustomInput(next);
      },
      icon: const Icon(Icons.edit_outlined),
      label: const Text('设置参数与操作'),
    ),
  ];
  @override
  Widget stage(PlaybackState state) => _HashStage(input, state);
}

class _HashEditor extends StatefulWidget {
  const _HashEditor(this.input);
  final HashInput input;
  @override
  State<_HashEditor> createState() => _HashEditorState();
}

class _HashEditorState extends State<_HashEditor> {
  late final v = widget.input;
  late String m = '${v.m}',
      p = '${v.p}',
      base = '${v.base}',
      digits = v.digits.join(' '),
      seed = '${v.seed}',
      initial = v.initial.join(' '),
      ops = v.operations;
  late bool boundary = v.boundaryFold;
  String? error;
  int number(String raw, String name) =>
      int.tryParse(raw.trim()) ?? (throw FormatException('$name 须为整数。'));
  List<int> numbers(String raw, String name) => raw
      .trim()
      .split(RegExp(r'[\s,，]+'))
      .where((s) => s.isNotEmpty)
      .map((s) => number(s, name))
      .toList();
  void apply() {
    try {
      final next = v.change(
        m: number(m, '表长'),
        p: number(p, '入口数'),
        base: number(base, '起点'),
        digits: numbers(digits, '选位'),
        seed: number(seed, '种子'),
        boundaryFold: boundary,
        initial: numbers(initial, '关键字'),
        operations: ops,
      );
      next.validate();
      Navigator.pop(context, next);
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  Widget field(
    String id,
    String label,
    String value,
    ValueChanged<String> set, {
    String? hint,
  }) => TextFormField(
    key: ValueKey('hash-$id'),
    initialValue: value,
    onChanged: set,
    decoration: InputDecoration(
      labelText: label,
      helperText: hint,
      helperMaxLines: 3,
    ),
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text('${v.function.label} · ${v.collision.label}'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        field('m', '表长 m', m, (s) => m = s),
        field('p', '初始地址数 p', p, (s) => p = s, hint: '除留余数法使用模数 p，入口为 0～p−1'),
        if (v.function == HashFunction.direct)
          field('base', '直接定址起点', base, (s) => base = s),
        if (v.function == HashFunction.digits)
          field(
            'digits',
            '按顺序选取数位',
            digits,
            (s) => digits = s,
            hint: '从右数，个位为 1，缺位补 0',
          ),
        if (v.function == HashFunction.fold)
          SwitchListTile(
            title: const Text('边界叠加'),
            subtitle: const Text('交替反转分组后相加'),
            value: boundary,
            onChanged: (b) => setState(() => boundary = b),
          ),
        if (v.collision == HashCollision.random)
          field('seed', '伪随机种子', seed, (s) => seed = s),
        field(
          'initial',
          '依次建表的关键字',
          initial,
          (s) => initial = s,
          hint: '空格或逗号分隔，留空从空表开始',
        ),
        field(
          'ops',
          '建表后的操作',
          ops,
          (s) => ops = s,
          hint: '插入 +38，删除 -38，查找 ?38',
        ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: apply, child: const Text('开始推演')),
    ],
  );
}
