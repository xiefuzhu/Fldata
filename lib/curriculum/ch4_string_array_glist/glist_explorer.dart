import 'dart:math' as math;
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../enum/ds_enums.dart';
import '../../models/trace_model.dart';

part 'glist_scene.dart';

enum GListViewMode { syntax, headTail, extended }

enum Peel { head, tail }

sealed class GValue {
  const GValue(this.id);
  final String id;
  int get depth;
  String get notation;
}

class GAtom extends GValue {
  const GAtom(super.id, this.name);
  final String name;
  @override
  int get depth => 0;
  @override
  String get notation => name;
}

class GSequence extends GValue {
  GSequence(String id, List<GValue> children)
    : this._(id, List.unmodifiable(children), 0);
  GSequence._(this.origin, this.elements, this.start) : super('$origin:$start');
  final String origin;
  final List<GValue> elements;
  final int start;
  Iterable<GValue> get items => elements.skip(start);
  int get length => elements.length - start;
  @override
  late final int depth =
      1 + items.fold(0, (n, child) => math.max(n, child.depth));
  @override
  String get notation => '(${items.map((x) => x.notation).join(', ')})';
  GValue peel(Peel operation) {
    if (length == 0) throw StateError('空表没有表头或表尾');
    return operation == Peel.head
        ? elements[start]
        : GSequence._(origin, elements, start + 1);
  }
}

class _GParser {
  _GParser(this.text);
  final String text;
  int cursor = 0;
  static final _space = RegExp(r'\s');
  static final _atom = RegExp(r'[^\s(),=]+');
  void spaces() {
    while (cursor < text.length && _space.hasMatch(text[cursor])) {
      cursor++;
    }
  }

  bool take(String token) {
    spaces();
    if (!text.startsWith(token, cursor)) return false;
    cursor++;
    return true;
  }

  Never fail(String message) =>
      throw FormatException('第 ${cursor + 1} 个字符：$message');
  GValue parse() {
    if (text.length > 256) throw const FormatException('课程输入最多 256 个字符。');
    spaces();
    final begin = cursor, name = _atom.matchAsPrefix(text, cursor);
    if (name != null) {
      cursor = name.end;
      if (!take('=')) cursor = begin;
    }
    final root = value();
    spaces();
    if (cursor != text.length) fail('表达式后还有多余内容。');
    return root;
  }

  GValue value() {
    spaces();
    final pos = cursor;
    if (take('(')) {
      final children = <GValue>[];
      if (!take(')')) {
        do {
          children.add(value());
        } while (take(','));
        if (!take(')')) fail('需要逗号或右括号。');
      }
      return GSequence('list-$pos', children);
    }
    final match = _atom.matchAsPrefix(text, cursor);
    if (match == null) fail('需要原子或括号表。');
    cursor = match.end;
    return GAtom('atom-$pos', match.group(0)!);
  }
}

class GListInput {
  const GListInput({
    this.expression = 'D = (E, (a), (b, (c, d)))',
    this.mode = GListViewMode.syntax,
    this.path = const [],
  });
  final String expression;
  final GListViewMode mode;
  final List<Peel> path;
}

const _source = {
  CodeLang.cLike: [
    '读取表达式，括号建立表，逗号分隔同层元素',
    'Depth(原子) = 0',
    'Depth(表) = 1 + max(各元素深度，初值 0)',
    'Length(表) = 顶层元素个数',
    'Head(非空表) = 首个元素',
    'Tail(非空表) = 剩余元素组成的表',
  ],
  CodeLang.c99: [
    '// 逻辑序列接口：list 判别表，n 为顶层项数，items 为连续元素视图。',
    'int depth(Value v) { if (!v.list) return 0;',
    '  int h=0; for(int i=0;i<v.n;i++){ int d=depth(v.items[i]); if(d>h) h=d; } return h+1; }',
    'int length(Value list) { return list.n; }',
    'Value head(Value list) { return list.items[0]; }',
    'Value tail(Value list) { ++list.items; --list.n; return list; }',
  ],
  CodeLang.dart: [
    '// GValue 是解析结果，GSequence 持有子元素序列。',
    'int depth(GValue v) { if (v is GAtom) return 0;',
    '  return 1+(v as GSequence).items.fold<int>(0,(h,x)=>math.max(h,depth(x))); }',
    'int length(GSequence list) => list.length;',
    'GValue head(GSequence list) => list.elements[list.start];',
    'GSequence tail(GSequence list) => GSequence._(list.origin,list.elements,list.start+1);',
  ],
};

class GListModule implements AlgorithmModule<GListInput> {
  const GListModule();
  @override
  String get id => 'ch4_glist_explorer';
  static const names = ['解析树', '头尾链表', '扩展线性链表'];
  @override
  List<AlgorithmPreset<GListInput>> get presets => const [
    AlgorithmPreset(id: 'sample', name: '教材示例 D', input: GListInput()),
    AlgorithmPreset(
      id: 'empty',
      name: '空表',
      input: GListInput(expression: '()'),
    ),
    AlgorithmPreset(
      id: 'nested-empty',
      name: '嵌套空表',
      input: GListInput(expression: '((), (()), a)'),
    ),
    AlgorithmPreset(
      id: 'repeat',
      name: '同值原子',
      input: GListInput(expression: '((a), a, a)'),
    ),
  ];
  @override
  ValidationResult<GListInput> validateInput(String raw) {
    try {
      _GParser(raw).parse();
      return ValidationResult.success(GListInput(expression: raw));
    } on FormatException catch (e) {
      return ValidationResult.failure(e.message);
    }
  }

  @override
  TraceTimeline generateTrace(GListInput input) {
    final root = _GParser(input.expression).parse();
    var result = root;
    final builder = TraceBuilder(
      moduleId: id,
      inputSummary: input.expression,
      codeLines: _source,
    );
    void record(
      int line,
      String title,
      String explain,
      int operations,
      GValue focus, {
      bool milestone = false,
    }) {
      final length = result is GSequence ? (result).length : null;
      final vars = {
        '当前值': result.notation,
        '长度': length?.toString() ?? '无定义',
        '深度': '${result.depth}',
        '操作数': '$operations',
        '可拆解': length != null && length > 0 ? '是' : '否',
      };
      builder.step(
        title: title,
        explain: explain,
        cLikeLines: [line],
        c99Lines: [line],
        dartLines: [line],
        vars: vars,
        scene: _gScene(result, focus, input.mode),
        milestone: milestone,
      );
    }

    record(1, '解析完成', '括号内的直接子项属于同一层。', 0, root);
    // Visit depth contributions bottom up. Empty and atom are distinct leaves.
    void visit(GValue node) {
      if (node is GSequence) {
        for (final child in node.items) {
          visit(child);
        }
      }
      record(
        node is GAtom ? 2 : 3,
        '${node.notation} 的深度为 ${node.depth}',
        node is GAtom ? '原子的深度为 0。' : '从各直接子项的最大深度加一，空表取 1。',
        0,
        node,
      );
    }

    visit(root);
    record(
      root is GAtom ? 2 : 4,
      '结构与度量',
      root is GSequence ? '每个直接子表只计为一个元素。' : '原子没有表长。',
      0,
      root,
      milestone: true,
    );
    for (var n = 0; n < input.path.length; n++) {
      if (result is! GSequence || (result).length == 0) {
        throw ArgumentError('当前值不可再拆解');
      }
      final op = input.path[n];
      result = (result).peel(op);
      record(
        op == Peel.head ? 5 : 6,
        op == Peel.head
            ? 'GetHead · ${result.notation}'
            : 'GetTail · ${result.notation}',
        op == Peel.head ? '首元素保留自身类型。' : '去掉一个首元素，其余元素仍组成表。',
        n + 1,
        result,
        milestone: true,
      );
    }
    return builder.build();
  }
}
