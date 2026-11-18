part of 'glist_explorer.dart';

SceneSnapshot _gScene(GValue root, GValue focus, GListViewMode mode) {
  final nodes = <SceneNode>[], edges = <SceneEdge>[], fields = <List<String>>[];
  void node(String id, String label, String badge, bool active) {
    nodes.add(
      SceneNode(
        id: id,
        label: label,
        logicBadge: badge,
        x: 0,
        y: 0,
        width: math.max(105.0, 18.0 * label.runes.length + 28),
        height: 50,
        visualState: active ? NodeVisualState.active : NodeVisualState.normal,
      ),
    );
  }

  void link(String from, String field, String to, {bool active = false}) {
    edges.add(
      SceneEdge(
        id: '$from/$field',
        fromNodeId: from,
        toNodeId: to,
        weightLabel: field,
        visualState: active ? NodeVisualState.active : NodeVisualState.normal,
      ),
    );
  }

  String display(String id) => id == nullNodeId ? 'NULL' : id;
  String syntax(GValue value) {
    node(
      value.id,
      value is GAtom ? value.name : '( )',
      value is GAtom ? '原子' : '表',
      value.id == focus.id,
    );
    if (value is GSequence) {
      var i = 1;
      for (final child in value.items) {
        link(value.id, '${i++}', syntax(child));
      }
    }
    fields.add([value.id, value is GAtom ? '原子' : '表', '深度', '${value.depth}']);
    return value.id;
  }

  String headTail(GValue value) {
    if (value is GAtom) {
      node(value.id, value.name, 'tag=0', value.id == focus.id);
      fields.add([value.id, '0', 'atom', value.name]);
      return value.id;
    }
    final seq = value as GSequence;
    if (seq.length == 0) return nullNodeId;
    for (var i = seq.start; i < seq.elements.length; i++) {
      final id = '${seq.origin}:$i',
          child = seq.elements[i],
          hp = headTail(child),
          tp = i + 1 < seq.elements.length
              ? '${seq.origin}:${i + 1}'
              : nullNodeId;
      final emptyFocus = hp == nullNodeId && child.id == focus.id;
      node(id, 'hp │ tp', 'tag=1', id == focus.id || emptyFocus);
      link(id, 'hp', hp, active: emptyFocus);
      link(id, 'tp', tp);
      fields.addAll([
        [id, '1', 'hp', display(hp)],
        [id, '1', 'tp', display(tp)],
      ]);
    }
    return seq.id;
  }

  // A sublist's hp addresses its first item; every item carries a sibling tp.
  String extended(GValue value, String sibling) {
    final atom = value is GAtom;
    node(
      value.id,
      atom ? value.name : '子表',
      'tag=${atom ? 0 : 1}',
      value.id == focus.id,
    );
    if (value is GSequence) {
      final first = value.length == 0
          ? nullNodeId
          : value.elements[value.start].id;
      link(value.id, 'hp', first);
      fields.add([value.id, '1', 'hp', display(first)]);
      for (var i = value.start; i < value.elements.length; i++) {
        final next = i + 1 < value.elements.length
            ? value.elements[i + 1].id
            : nullNodeId;
        extended(value.elements[i], next);
      }
    } else if (value is GAtom) {
      fields.add([value.id, '0', 'atom', value.name]);
    }
    link(value.id, 'tp', sibling);
    fields.add([value.id, atom ? '0' : '1', 'tp', display(sibling)]);
    return value.id;
  }

  final id = switch (mode) {
    GListViewMode.syntax => syntax(root),
    GListViewMode.headTail => headTail(root),
    GListViewMode.extended => extended(root, nullNodeId),
  };
  if (id == nullNodeId) fields.add(['L', '—', '根指针', 'NULL']);
  final scene = SceneSnapshot(
    nodes: nodes,
    edges: edges,
    pointers: [PointerBadge(id: 'root', label: 'L', targetNodeId: id)],
    auxTables: [
      AuxTableSnapshot(
        id: 'fields',
        title: GListModule.names[mode.index],
        columns: ['节点', '类型', '字段', '值'],
        rows: fields,
      ),
    ],
  );
  return TreeReingoldLayout.arrange(scene);
}
