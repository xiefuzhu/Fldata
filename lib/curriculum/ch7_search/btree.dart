import 'dart:math' as math;
import '../../engine/layout/tree_reingold_layout.dart';
import '../../engine/vm/algorithm_module.dart';
import '../../engine/vm/trace_builder.dart';
import '../../models/trace_model.dart';
import 'btree_source.dart';
import 'key_operations.dart';

part 'btree_scene.dart';
part 'bplus.dart';

const _fig725 = [90, 24, 3, 45, 37, 12, 50, 100, 53, 61, 70];
const _fig727 = [59, 85, 10, 72, 51, 44, 63, 15, 91, 21, 97, 37];

class MultiwayInput {
  const MultiwayInput({
    this.order = 3,
    this.initial = _fig725,
    this.operations = '+30 +26 +85 +7',
    this.plus = false,
    this.low = 37,
    this.high = 72,
  });
  final int order, low, high;
  final List<int> initial;
  final String operations;
  final bool plus;
  int get minimum => (order + 1) ~/ 2 - 1;
  MultiwayInput configure({int? order, bool? plus}) => MultiwayInput(
    order: order ?? this.order,
    plus: plus ?? this.plus,
    initial: initial,
    operations: operations,
    low: low,
    high: high,
  );
  static List<(String, int)> parseOperations(String raw) =>
      parseKeyOperations(raw);
}

class MultiwayModule implements AlgorithmModule<MultiwayInput> {
  const MultiwayModule();
  @override
  String get id => 'ch7_btree_bplustree';
  @override
  List<AlgorithmPreset<MultiwayInput>> get presets => const [
    AlgorithmPreset(
      id: 'insert',
      name: '图 7.25 · 连续插入与根分裂',
      input: MultiwayInput(),
    ),
    AlgorithmPreset(
      id: 'delete',
      name: '图 7.26 · 借位、合并与降高',
      input: MultiwayInput(operations: '-12 -50 -53 -37'),
    ),
    AlgorithmPreset(
      id: 'search',
      name: '还原图 7.22 · 查 47 与 23',
      input: MultiwayInput(
        order: 4,
        initial: [99, 101, 27, 78, 11, 39, 18, 35, 47, 53, 43, 64],
        operations: '-101 ?47 ?23',
      ),
    ),
    AlgorithmPreset(
      id: 'range',
      name: '图 7.27 · 沿叶链查 [37, 72]',
      input: MultiwayInput(plus: true, initial: _fig727),
    ),
  ];
  @override
  ValidationResult<MultiwayInput> validateInput(String raw) {
    final p = presets.where((p) => p.id == raw.trim()).firstOrNull;
    return p == null
        ? const ValidationResult.failure('请选择多路树预设。')
        : ValidationResult.success(p.input);
  }

  @override
  TraceTimeline generateTrace(MultiwayInput input) {
    if (input.order < 3 ||
        input.order > 5 ||
        (input.plus && input.low > input.high)) {
      throw ArgumentError('阶数或查询区间无效');
    }
    return _Run(input, id).record();
  }
}

class _Page {
  _Page(this.id);
  final String id;
  final keys = <int>[];
  final children = <_Page>[];
  _Page? parent, next;
  bool get leaf => children.isEmpty;
  void attach(int i, _Page child) {
    children.insert(i, child);
    child.parent = this;
  }

  int lower(int key) {
    final i = keys.indexWhere((v) => v >= key);
    return i < 0 ? keys.length : i;
  }
}

class _Run {
  _Run(this.input, String id)
    : b = TraceBuilder(
        moduleId: id,
        inputSummary: '${input.order} 阶 ${input.plus ? "B+树" : "B-树"}',
        codeLines: multiwaySource(input.plus),
      );
  final MultiwayInput input;
  final TraceBuilder b;
  _Page? root;
  int serial = 0;
  _Page page() => _Page('p${++serial}');
  bool recording = false;
  String operation = '', result = '';
  final hits = <int>[];
  TraceTimeline record() {
    for (final key in input.initial) {
      if (input.plus) {
        addPlus(key);
      } else {
        insert(key);
      }
    }
    recording = true;
    emit(1, '初始', '初始树', '由初始序列建树，相等键只保留一份。', milestone: true);
    if (input.plus) {
      scan();
    } else {
      for (final (op, key) in MultiwayInput.parseOperations(input.operations)) {
        operation = '$op$key';
        result = '';
        if (op == '+') {
          insert(key);
        } else if (op == '-') {
          remove(key);
        } else {
          search(key);
        }
        emit(
          12,
          '操作结束',
          '$operation · $result',
          '可在内存表核对各页的关键字与孩子指针。',
          milestone: true,
        );
      }
    }
    return b.build();
  }

  (_Page?, int, bool) locate(int key) {
    var n = root;
    while (n != null) {
      final i = n.lower(key), found = i < n.keys.length && n.keys[i] == key;
      emit(
        2,
        '查找',
        '在 ${n.id} 内查找 $key',
        found ? '命中 K${i + 1}。' : '已排除前 $i 个关键字，检查 P$i。',
        focus: n,
        key: found ? key : null,
        reads: 1,
        compares: i + (i < n.keys.length ? 1 : 0),
      );
      if (found || n.leaf) return (n, i, found);
      n = n.children[i];
    }
    return (null, 0, false);
  }

  void search(int key) {
    final (n, i, found) = locate(key);
    result = found ? '命中 $key' : '未找到 $key';
    emit(
      3,
      '返回',
      result,
      'SearchBTree 返回 (pt=${n?.id ?? "NULL"}, i=${found ? i + 1 : i}, tag=${found ? 1 : 0})。',
      focus: n,
      key: found ? key : null,
    );
  }

  void insert(int key) {
    final (last, i, found) = locate(key);
    if (found) {
      result = '已有 $key';
      return;
    }
    var n = last ?? (root = page());
    n.keys.insert(i, key);
    emit(
      4,
      '插入',
      '写入 $key',
      '在 ${n.id} 的 K${i + 1} 处插入。',
      focus: n,
      key: key,
      writes: 1,
    );
    while (n.keys.length == input.order) {
      final mid = (input.order + 1) ~/ 2 - 1, up = n.keys[mid];
      emit(
        5,
        '溢出',
        '${n.id} 溢出 · 分裂位置 s = ${mid + 1}',
        '键数达到 ${input.order}。K${mid + 1} = $up 将升入双亲。',
        focus: n,
        key: up,
        split: true,
        milestone: true,
      );
      final right = page();
      right.keys.addAll(n.keys.sublist(mid + 1));
      n.keys.removeRange(mid, n.keys.length);
      if (!n.leaf) {
        final tail = n.children.sublist(mid + 1);
        n.children.removeRange(mid + 1, n.children.length);
        for (final child in tail) {
          right.attach(right.children.length, child);
        }
      }
      final grew = n.parent == null;
      final parent = n.parent ?? (root = page());
      if (grew) parent.attach(0, n);
      final pos = parent.children.indexOf(n);
      parent.keys.insert(pos, up);
      parent.attach(pos + 1, right);
      emit(
        6,
        '分裂',
        grew ? '$up 上升 · 新建根' : '$up 上升至 ${parent.id}',
        '${n.id} 保留左半页，${right.id} 保存右半页。${grew ? "树高增加一层。" : "继续检查双亲。"}',
        focus: parent,
        key: up,
        writes: 3,
        from: n.id,
        to: right.id,
        milestone: true,
      );
      n = parent;
    }
    result = '已插入 $key';
  }

  void remove(int key) {
    final (found, i, ok) = locate(key);
    if (!ok) {
      result = '未找到 $key';
      return;
    }
    var n = found!, slot = i;
    if (!n.leaf) {
      var leaf = n.children[i + 1];
      while (!leaf.leaf) {
        leaf = leaf.children.first;
      }
      final successor = leaf.keys.first;
      emit(
        7,
        '后继',
        '以中序后继 $successor 接替 $key',
        '从 P${i + 1} 进入右子树，沿 P0 找到 ${leaf.id}。',
        focus: leaf,
        key: successor,
      );
      n.keys[i] = successor;
      n = leaf;
      slot = 0;
    }
    n.keys.removeAt(slot);
    emit(
      8,
      '删除',
      '从末层摘除关键字',
      '${n.id} 剩余 ${n.keys.length} 个键。',
      focus: n,
      writes: 1,
    );
    while (n.parent != null && n.keys.length < input.minimum) {
      final p = n.parent!, pos = p.children.indexOf(n);
      final left = pos > 0 ? p.children[pos - 1] : null,
          right = pos + 1 < p.children.length ? p.children[pos + 1] : null;
      emit(
        9,
        '下溢',
        '${n.id} 下溢',
        '至少需要 ${input.minimum} 个键。左兄弟 ${left?.keys.length ?? "无"}，右兄弟 ${right?.keys.length ?? "无"}。',
        focus: n,
        milestone: true,
      );
      final borrowRight = right != null && right.keys.length > input.minimum;
      if (borrowRight || (left != null && left.keys.length > input.minimum)) {
        final donor = borrowRight ? right : left!,
            sep = borrowRight ? pos : pos - 1;
        final down = p.keys[sep],
            up = donor.keys.removeAt(borrowRight ? 0 : donor.keys.length - 1);
        n.keys.insert(borrowRight ? n.keys.length : 0, down);
        p.keys[sep] = up;
        if (!donor.leaf) {
          n.attach(
            borrowRight ? n.children.length : 0,
            donor.children.removeAt(
              borrowRight ? 0 : donor.children.length - 1,
            ),
          );
        }
        emit(
          10,
          '借位',
          '向${borrowRight ? "右" : "左"}兄弟借位',
          '父键 $down 下沉，兄弟键 $up 上升。对应的孩子指针随键移接。',
          focus: n,
          key: down,
          writes: 3,
          milestone: true,
        );
        break;
      }
      final sep = right != null ? pos : pos - 1;
      final keep = p.children[sep],
          discard = p.children.removeAt(sep + 1),
          down = p.keys.removeAt(sep);
      keep.keys.addAll([down, ...discard.keys]);
      for (final child in discard.children) {
        keep.attach(keep.children.length, child);
      }
      emit(
        11,
        '合并',
        '三合一 · 父键 $down 下沉',
        '两页连同父键并入 ${keep.id}，检查双亲 ${p.id} 是否下溢。',
        focus: keep,
        key: down,
        writes: 3,
        milestone: true,
      );
      n = p;
    }
    if (root!.keys.isEmpty) {
      root = root!.children.firstOrNull;
      root?.parent = null;
      emit(
        11,
        '降高',
        root == null ? '删除最后一个键' : '唯一孩子成为新根',
        '原根已空，树高减一。',
        focus: root,
        milestone: true,
      );
    }
    result = '已删除 $key';
  }
}
