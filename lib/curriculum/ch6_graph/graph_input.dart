import '../../models/trace_model.dart';

enum GraphKind {
  udg('UDG', false, false),
  udn('UDN', false, true),
  dg('DG', true, false),
  dn('DN', true, true);

  const GraphKind(this.label, this.directed, this.weighted);
  final String label;
  final bool directed, weighted;
}

typedef GraphVertex = ({String id, Vec2 point, bool pinned});
typedef GraphArc = ({String id, String tail, String head, int weight});

/// Vertex order defines textbook subscripts. Arc order is the input order.
class GraphInputModel {
  GraphInputModel._(
    this.kind,
    this.vertexPrefix,
    Iterable<GraphVertex> vertices,
    Iterable<GraphArc> arcs,
    this.nextVertex,
    this.nextArc,
  ) : vertices = List.unmodifiable(vertices),
      arcs = List.unmodifiable(arcs);
  factory GraphInputModel.empty(
    GraphKind kind, {
    String vertexPrefix = 'V',
    int firstVertex = 1,
  }) => GraphInputModel._(kind, vertexPrefix, [], [], firstVertex, 1);
  static const infinity = 32767;
  final GraphKind kind;
  final String vertexPrefix;
  final List<GraphVertex> vertices;
  final List<GraphArc> arcs;
  final int nextVertex, nextArc;

  GraphInputModel addVertex(Vec2 point) => GraphInputModel._(
    kind,
    vertexPrefix,
    [
      ...vertices,
      (id: '$vertexPrefix$nextVertex', point: point, pinned: false),
    ],
    arcs,
    nextVertex + 1,
    nextArc,
  );
  GraphArc? edge(String tail, String head) => arcs
      .where(
        (e) =>
            e.tail == tail && e.head == head ||
            !kind.directed && e.tail == head && e.head == tail,
      )
      .firstOrNull;

  GraphInputModel connect(String tail, String head, {int weight = 1}) {
    if (!vertices.any((v) => v.id == tail) ||
        !vertices.any((v) => v.id == head)) {
      throw const FormatException('端点必须在顶点表内');
    }
    if (edge(tail, head) != null) throw const FormatException('这条边已经存在');
    if (kind.weighted && weight >= infinity) {
      throw const FormatException('权值须小于 32767');
    }
    return GraphInputModel._(
      kind,
      vertexPrefix,
      vertices,
      [
        ...arcs,
        (
          id: 'e$nextArc',
          tail: tail,
          head: head,
          weight: kind.weighted ? weight : 1,
        ),
      ],
      nextVertex,
      nextArc + 1,
    );
  }

  GraphInputModel removeVertex(String id) => GraphInputModel._(
    kind,
    vertexPrefix,
    vertices.where((v) => v.id != id),
    arcs.where((e) => e.tail != id && e.head != id),
    nextVertex,
    nextArc,
  );
  GraphInputModel removeEdge(String id) => GraphInputModel._(
    kind,
    vertexPrefix,
    vertices,
    arcs.where((e) => e.id != id),
    nextVertex,
    nextArc,
  );
  GraphInputModel pin(String id, Vec2 point) => GraphInputModel._(
    kind,
    vertexPrefix,
    [
      for (final v in vertices)
        v.id == id ? (id: id, point: point, pinned: true) : v,
    ],
    arcs,
    nextVertex,
    nextArc,
  );
}

class GraphStorage {
  GraphStorage(GraphInputModel input, int count)
    : directed = input.kind.directed,
      vertices = input.vertices,
      arcs = input.arcs.take(count).toList(growable: false) {
    for (final v in vertices) {
      outgoing[v.id] = [];
      incoming[v.id] = [];
    }
    for (final e in arcs) {
      cells[(e.tail, e.head)] = e;
      links[e.id] = (
        left: first[e.tail],
        right: directed ? firstIn[e.head] : first[e.head],
      );
      first[e.tail] = e.id;
      if (directed) {
        firstIn[e.head] = e.id;
      } else {
        first[e.head] = e.id;
        cells[(e.head, e.tail)] = e;
        outgoing[e.head]!.add((vertex: e.tail, arc: e));
      }
      outgoing[e.tail]!.add((vertex: e.head, arc: e));
      incoming[e.head]!.add((vertex: e.tail, arc: e));
    }
  }
  final bool directed;
  final List<GraphVertex> vertices;
  final List<GraphArc> arcs;
  final cells = <(String, String), GraphArc>{};
  final first = <String, String>{}, firstIn = <String, String>{};
  // Directed: left=tlink, right=hlink. Undirected: left=ilink, right=jlink.
  final links = <String, ({String? left, String? right})>{};
  final outgoing = <String, List<({String vertex, GraphArc arc})>>{};
  final incoming = <String, List<({String vertex, GraphArc arc})>>{};
  Iterable<({String vertex, GraphArc arc})> chain(
    String id, {
    bool reverse = false,
  }) => (reverse && directed ? incoming : outgoing)[id]!.reversed;
}
