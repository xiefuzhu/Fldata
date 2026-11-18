part of 'hash_table.dart';

class _HashRun {
  _HashRun(this.input, String id)
    : table = HashStorage(input),
      b = TraceBuilder(
        moduleId: id,
        inputSummary:
            '${input.function.label} · ${input.collision.label} · m=${input.m}, p=${input.p}',
        codeLines: hashSource(input.collision),
      );
  final HashInput input;
  final HashStorage table;
  final TraceBuilder b;
  int revision = 0;
  String operation = '', formula = '', result = '';
  int? home, addr, depth, firstDeleted;
  final path = <String>[];
  TraceTimeline record() {
    emit(1, '初始', '初始化散列表', '表长 m = ${input.m}，初始入口为 0～${input.p - 1}。');
    for (final key in input.initial) {
      operate('+', key);
    }
    for (final (op, key) in parseKeyOperations(input.operations)) {
      operate(op, key);
    }
    return b.build();
  }

  void operate(String op, int key) {
    operation = '$op$key';
    path.clear();
    firstDeleted = null;
    addr = null;
    depth = null;
    result = '';
    final h = input.hash(key);
    home = h.home;
    formula = h.formula;
    emit(1, '散列', '计算 $key 的初始地址', formula);
    if (home == null) {
      result = '超出直接定址范围';
      emit(1, '结果', result, '直接定址支持起点 ${input.base} 至起点加 p−1 的关键字。');
      return;
    }
    bool found = false, empty = false;
    for (final visit in table.probe(home!, key)) {
      addr = visit.address;
      depth = visit.depth;
      final label = table.chained
          ? (visit.value?.toString() ?? 'NULL')
          : '$addr';
      path.add(label);
      empty = visit.value == null && !visit.deleted;
      found = visit.value == key;
      if (visit.deleted && op == '+' && firstDeleted == null) {
        firstDeleted = addr;
      }
      final heading = visit.deleted
          ? '越过 DELETED'
          : empty
          ? (table.chained ? '到达链尾 NULL' : '遇到空槽')
          : found
          ? '命中 $key'
          : '比较 ${visit.value} 与 $key';
      final place = table.chained
          ? '桶 $home，第 ${visit.depth + 1} 次检查'
          : 'H${path.length - 1} = ($home + (${visit.offset})) mod ${input.m} = $addr';
      emit(
        visit.deleted
            ? 4
            : empty
            ? 3
            : found
            ? 5
            : 2,
        '探测',
        heading,
        '$place。${visit.deleted
            ? (op == "+" ? "保留首个墓碑地址，继续排查重复键。" : "删除标记保留了后续探测路径。")
            : empty
            ? "到达查找失败的终点。"
            : found
            ? "关键字相等。"
            : "关键字不同，继续探测。"}',
        probe: true,
      );
    }
    if (op == '+') {
      if (found) {
        result = '重复键 $key';
      } else if (table.chained || empty || firstDeleted != null) {
        final dest = firstDeleted ?? addr!;
        if (table.chained) {
          (table.cells[dest] ??= []).add(key);
        } else {
          table.cells[dest] = [key];
        }
        addr = dest;
        revision++;
        result = '已插入 $key';
        emit(
          7,
          firstDeleted != null ? '复用' : '写入',
          result,
          firstDeleted != null
              ? '将 $key 写入最先遇到的墓碑槽 $dest。'
              : table.chained
              ? '将新记录接到桶 $dest 的链尾。'
              : '将 $key 写入空槽 $dest。',
          write: true,
        );
      } else {
        result =
            table.cells.length == input.m &&
                table.cells.values.every((cell) => cell.isNotEmpty)
            ? '表已满'
            : '探测序列耗尽';
      }
    } else if (op == '-' && found) {
      if (table.chained) {
        final bucket = table.cells[addr]!..removeAt(depth!);
        if (bucket.isEmpty) table.cells.remove(addr);
      } else {
        table.cells[addr!] = [];
      }
      revision++;
      result = '已删除 $key';
      emit(
        8,
        '删除',
        result,
        table.chained ? '将前驱链接改指后继，摘下该记录。' : '槽 $addr 留下 DELETED 墓碑，后续查找继续探测。',
        write: true,
      );
    } else {
      result = found ? '命中 $key' : '未找到 $key';
    }
    emit(
      9,
      '结果',
      result,
      '共检查 ${path.length} 次。${!empty && !found && !table.chained ? "本次探测已达到 m 次上限。" : ""}',
    );
  }

  void emit(
    int line,
    String phase,
    String title,
    String detail, {
    bool probe = false,
    bool write = false,
  }) {
    final addresses = table.cells.keys.toList()..sort();
    final rows = <List<String>>[], nodes = <SceneNode>[], edges = <SceneEdge>[];
    for (final a in addresses) {
      final keys = table.cells[a]!, dead = keys.isEmpty;
      rows.add([
        '$a',
        dead
            ? 'DELETED'
            : table.chained
            ? '链'
            : '记录',
        keys.join(' '),
      ]);
      nodes.add(
        SceneNode(
          id: 'a$a',
          label: table.chained
              ? '桶 $a'
              : dead
              ? 'DELETED'
              : '${keys.single}',
          memoryAddress: 'HT[$a]',
          x: 0,
          y: a * 52.0,
          shape: NodeShape.bucket,
          visualState: addr == a
              ? NodeVisualState.active
              : NodeVisualState.normal,
        ),
      );
      if (table.chained) {
        var prev = 'a$a';
        for (var j = 0; j < keys.length; j++) {
          final k = keys[j], id = 'k$k';
          nodes.add(
            SceneNode(
              id: id,
              label: '$k',
              x: (j + 1) * 90.0,
              y: a * 52.0,
              memoryAddress: id,
              shape: NodeShape.linkedCell,
              visualState: a == addr && j == depth
                  ? NodeVisualState.active
                  : NodeVisualState.normal,
            ),
          );
          edges.add(
            SceneEdge(
              id: '$prev.next',
              fromNodeId: prev,
              toNodeId: id,
              fromPort: EdgePort.next,
            ),
          );
          prev = id;
        }
        edges.add(
          SceneEdge(
            id: '$prev.next',
            fromNodeId: prev,
            toNodeId: nullNodeId,
            fromPort: EdgePort.next,
          ),
        );
      }
    }
    b.step(
      title: title,
      explain: detail,
      cLikeLines: [line],
      c99Lines: [line],
      dartLines: [line],
      vars: {
        '阶段': phase,
        '操作': operation,
        '公式': formula,
        '结果': result,
        '版本': '$revision',
        '入口': ?home?.toString(),
        '地址': ?addr?.toString(),
        '链位': ?depth?.toString(),
        '墓碑': ?firstDeleted?.toString(),
        '路径': path.join(' → '),
        '探测次数': '${path.length}',
      },
      scene: SceneSnapshot(
        nodes: nodes,
        edges: edges,
        auxTables: [
          AuxTableSnapshot(
            id: 'hash-storage',
            title: '非空槽与同义词链',
            columns: ['地址', '状态', '关键字（链序）'],
            rows: rows,
            highlightedRows: {
              if (addr != null && addresses.contains(addr))
                addresses.indexOf(addr!),
            },
          ),
        ],
      ),
      deltaCompare: probe ? 1 : 0,
      deltaRead: probe ? 1 : 0,
      deltaWrite: write ? 1 : 0,
      milestone: phase == '结果' || write,
    );
  }
}
