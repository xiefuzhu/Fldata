import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../common/platform_detector.dart';
import '../../models/trace_model.dart';
import 'animated_node_layer.dart';
import 'pointer_edge_painter.dart';
import 'stage_hit_test.dart';
import 'trackpad_gesture_recognizer.dart';

/// Camera state belongs to a dataset (widget key), never to a playback frame.
/// InteractiveViewer supplies the transform surface and wheel zoom. Dedicated
/// contact/native recognizers own the canvas before an ancestor Scrollable,
/// applying each gesture exactly once.
class DsStageCanvas extends StatefulWidget {
  const DsStageCanvas({
    super.key,
    required this.scene,
    required this.sceneSize,
    this.pinnedIds = const {},
    this.onDragStart,
    this.onDrag,
    this.onSelect,
    this.onBlankTap,
    this.onEdgeTap,
    this.onDragEnd,
    this.pulseEdgeId,
    this.traversalEdges = false,
    this.sortingRace = false,
    this.followCamera = false,
    this.onCameraInteraction,
    this.selectedNodeId,
    this.backdropPainter,
    this.nodeContentBuilder,
  });
  final SceneSnapshot scene;
  final Size sceneSize;
  final Set<String> pinnedIds;
  final void Function(String, Vec2)? onDragStart, onDrag;
  final ValueChanged<String>? onSelect;
  final ValueChanged<Vec2>? onBlankTap;
  final ValueChanged<String>? onEdgeTap;
  final void Function(String, bool cancelled)? onDragEnd;
  final String? pulseEdgeId;
  final bool traversalEdges;
  final bool sortingRace;
  final bool followCamera;
  final VoidCallback? onCameraInteraction;
  final String? selectedNodeId;
  final CustomPainter? backdropPainter;
  final Widget Function(BuildContext, SceneNode)? nodeContentBuilder;
  @override
  State<DsStageCanvas> createState() => _DsStageCanvasState();
}

class _DsStageCanvasState extends State<DsStageCanvas> {
  final camera = TransformationController();
  final pointers = <int>{};
  Size viewport = Size.zero;
  String? selected, candidate, dragging;
  Offset? down;
  bool moved = false;
  bool followScheduled = false;
  bool manualOverride = false;
  int viewerEpoch = 0;
  double contactScale = 1;
  Offset contactAnchor = Offset.zero;
  double trackpadScale = 1;
  Offset trackpadAnchor = Offset.zero;
  bool get bars => widget.sortingRace && widget.scene.nodes.length > 24;
  SceneSnapshot get displayed =>
      bars ? barScene(widget.scene, widget.sceneSize) : widget.scene;
  double get fitScale => math.min(
    1,
    math.min(
      viewport.width / widget.sceneSize.width,
      viewport.height / widget.sceneSize.height,
    ),
  );
  double get minimumScale => math.min(.1, fitScale);
  Vec2 scenePoint(Offset p) {
    final v = camera.toScene(p);
    return Vec2(x: v.dx, y: v.dy);
  }

  void manualCamera() {
    manualOverride = true;
    widget.onCameraInteraction?.call();
  }

  void scheduleFollow() {
    if (followScheduled || !widget.followCamera || manualOverride) return;
    followScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      followScheduled = false;
      if (mounted) followActive();
    });
  }

  void followActive() {
    if (!widget.followCamera ||
        manualOverride ||
        viewport.isEmpty ||
        pointers.isNotEmpty) {
      return;
    }
    final scene = displayed;
    final active = {
      NodeVisualState.active,
      NodeVisualState.comparing,
      NodeVisualState.moving,
      NodeVisualState.error,
    };
    var nodes = scene.nodes
        .where(
          (n) =>
              active.contains(n.visualState) && !n.isDeleted && n.opacity > .01,
        )
        .toList();
    if (nodes.isEmpty) {
      final targets = scene.pointers
          .where((p) => p.opacity > .01)
          .map((p) => p.targetNodeId)
          .toSet();
      nodes = scene.nodes
          .where(
            (n) => targets.contains(n.id) && !n.isDeleted && n.opacity > .01,
          )
          .toList();
    }
    if (nodes.isEmpty) return;
    Rect? bounds;
    for (final n in nodes) {
      final r = Rect.fromLTWH(n.x, n.y, n.width, n.height);
      bounds = bounds == null ? r : bounds.expandToInclude(r);
    }
    final safe = Rect.fromLTWH(
      24,
      24,
      math.max(1, viewport.width - 48),
      math.max(1, viewport.height - 48),
    );
    final s = math
        .min(
          camera.value.getMaxScaleOnAxis(),
          math.min(safe.width / bounds!.width, safe.height / bounds.height),
        )
        .clamp(minimumScale, 8.0);
    final old = camera.value.getTranslation();
    var dx = old.x, dy = old.y;
    if (s != camera.value.getMaxScaleOnAxis()) {
      dx = safe.center.dx - bounds.center.dx * s;
      dy = safe.center.dy - bounds.center.dy * s;
    }
    final screen = Rect.fromLTWH(
      bounds.left * s + dx,
      bounds.top * s + dy,
      bounds.width * s,
      bounds.height * s,
    );
    if (screen.left < safe.left) {
      dx += safe.left - screen.left;
    } else if (screen.right > safe.right) {
      dx += safe.right - screen.right;
    }
    if (screen.top < safe.top) {
      dy += safe.top - screen.top;
    } else if (screen.bottom > safe.bottom) {
      dy += safe.bottom - screen.bottom;
    }
    camera.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(s, s, s, 1);
  }

  void fit() {
    if (!mounted || viewport.isEmpty) return;
    final s = fitScale;
    setState(() => viewerEpoch++); // Also stops InteractiveViewer's inertia.
    camera.value = Matrix4.identity()
      ..translateByDouble(
        (viewport.width - widget.sceneSize.width * s) / 2,
        (viewport.height - widget.sceneSize.height * s) / 2,
        0,
        1,
      )
      ..scaleByDouble(s, s, s, 1);
  }

  void zoom(double factor) {
    manualCamera();
    final focal = viewport.center(Offset.zero);
    final before = camera.toScene(focal);
    final scale = (camera.value.getMaxScaleOnAxis() * factor).clamp(
      minimumScale,
      8.0,
    );
    setState(() => viewerEpoch++);
    camera.value = Matrix4.identity()
      ..translateByDouble(
        focal.dx - before.dx * scale,
        focal.dy - before.dy * scale,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void beginContact(ScaleStartDetails details) {
    contactScale = camera.value.getMaxScaleOnAxis();
    contactAnchor = camera.toScene(details.localFocalPoint);
    if (dragging != null && pointers.length == 1 && down != null) {
      widget.onDragStart?.call(dragging!, scenePoint(down!));
    }
  }

  void updateContact(ScaleUpdateDetails details) {
    if (dragging != null && pointers.length == 1) {
      if (down != null &&
          (details.localFocalPoint - down!).distance > kTouchSlop) {
        moved = true;
      }
      if (moved) {
        widget.onDrag?.call(dragging!, scenePoint(details.localFocalPoint));
      }
      return;
    }
    final s = (contactScale * details.scale).clamp(minimumScale, 8.0);
    final focal = details.localFocalPoint;
    camera.value = Matrix4.identity()
      ..translateByDouble(
        focal.dx - contactAnchor.dx * s,
        focal.dy - contactAnchor.dy * s,
        0,
        1,
      )
      ..scaleByDouble(s, s, s, 1);
  }

  void beginTrackpad(PointerPanZoomStartEvent event) {
    manualCamera();
    trackpadScale = camera.value.getMaxScaleOnAxis();
    trackpadAnchor = camera.toScene(event.localPosition);
    setState(() {
      viewerEpoch++;
      candidate = null;
      dragging = null;
      moved = true;
    });
  }

  void updateTrackpad(PointerPanZoomUpdateEvent event) {
    final s = (trackpadScale * event.scale).clamp(minimumScale, 8.0);
    final pan = PointerEvent.transformDeltaViaPositions(
      untransformedEndPosition: event.position + event.pan,
      untransformedDelta: event.pan,
      transform: event.transform,
    );
    final focal = event.localPosition + pan;
    camera.value = Matrix4.identity()
      ..translateByDouble(
        focal.dx - trackpadAnchor.dx * s,
        focal.dy - trackpadAnchor.dy * s,
        0,
        1,
      )
      ..scaleByDouble(s, s, s, 1);
  }

  void pointerDown(PointerDownEvent event) {
    manualCamera();
    pointers.add(event.pointer);
    if (pointers.length != 1) {
      if (dragging != null) widget.onDragEnd?.call(dragging!, true);
      setState(() {
        candidate = null;
        dragging = null;
        moved = true;
      });
      return;
    }
    down = event.localPosition;
    moved = false;
    candidate = hitTestStageNode(displayed, camera.value, event.localPosition);
    setState(() {
      dragging =
          widget.scene.layoutMode == SceneLayoutMode.graph &&
              widget.onDrag != null
          ? candidate
          : null;
    });
  }

  void finishPointer(PointerEvent event, {bool cancelled = false}) {
    pointers.remove(event.pointer);
    if (moved && dragging != null) widget.onDragEnd?.call(dragging!, cancelled);
    if (!cancelled && !moved) {
      if (candidate != null) {
        select(candidate!);
      } else {
        final edge = widget.onEdgeTap == null
            ? null
            : hitTestStageEdge(displayed, camera.value, event.localPosition);
        if (edge != null) {
          widget.onEdgeTap!(edge);
        } else {
          widget.onBlankTap?.call(scenePoint(event.localPosition));
        }
      }
    }
    if (pointers.isEmpty) {
      setState(() {
        dragging = null;
        candidate = null;
        down = null;
      });
    }
  }

  void select(String id) {
    PlatformDetector.selectionFeedback();
    setState(() => selected = id);
    widget.onSelect?.call(id);
  }

  @override
  void didUpdateWidget(DsStageCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.followCamera && widget.followCamera) manualOverride = false;
    scheduleFollow();
    if (oldWidget.sceneSize != widget.sceneSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) => fit());
    }
    if (!widget.scene.nodes.any(
      (n) => n.id == selected && !n.isDeleted && n.opacity > .01,
    )) {
      selected = null;
    }
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.sceneSize.width > 0 && widget.sceneSize.height > 0);
    final scene = displayed;
    final selection = widget.selectedNodeId ?? selected;
    final selectedNode = scene.nodes
        .where((n) => n.id == selection)
        .firstOrNull;
    scheduleFollow();
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('canvas-zoom-out'),
                tooltip: '缩小画布',
                onPressed: () => zoom(1 / 1.25),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.remove, size: 20),
              ),
              IconButton(
                key: const ValueKey('canvas-zoom-in'),
                tooltip: '放大画布',
                onPressed: () => zoom(1.25),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.add, size: 20),
              ),
              IconButton(
                key: const ValueKey('canvas-fit'),
                tooltip: '适应画布',
                onPressed: () {
                  manualCamera();
                  fit();
                },
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.fit_screen, size: 20),
              ),
              Expanded(
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: camera,
                  builder: (context, matrix, _) => Text(
                    selectedNode == null
                        ? ('${(matrix.getMaxScaleOnAxis() * 100).round()}%${bars ? ' · 柱状模式' : ''}')
                        : ('${selectedNode.label} · ${selectedNode.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (viewport != constraints.biggest) {
                viewport = constraints.biggest;
                WidgetsBinding.instance.addPostFrameCallback((_) => fit());
              }
              return ClipRect(
                child: Listener(
                  key: const ValueKey('canvas-viewport'),
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: pointerDown,
                  onPointerMove: (e) {
                    if (down != null &&
                        (e.localPosition - down!).distance > kTouchSlop) {
                      moved = true;
                    }
                  },
                  onPointerUp: (e) => finishPointer(e),
                  onPointerCancel: (e) => finishPointer(e, cancelled: true),
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      manualCamera();
                      GestureBinding.instance.pointerSignalResolver.register(
                        event,
                        (_) {},
                      );
                    }
                  },
                  child: RawGestureDetector(
                    gestures: {
                      StageContactGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                            StageContactGestureRecognizer
                          >(StageContactGestureRecognizer.new, (recognizer) {
                            recognizer.onStart = beginContact;
                            recognizer.onUpdate = updateContact;
                          }),
                      StageTrackpadGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                            StageTrackpadGestureRecognizer
                          >(StageTrackpadGestureRecognizer.new, (recognizer) {
                            recognizer.onStart = beginTrackpad;
                            recognizer.onUpdate = updateTrackpad;
                          }),
                    },
                    child: InteractiveViewer(
                      key: ValueKey(viewerEpoch),
                      transformationController: camera,
                      constrained: false,
                      alignment: Alignment.topLeft,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: minimumScale,
                      maxScale: 8,
                      trackpadScrollCausesScale: false,
                      panEnabled: dragging == null,
                      scaleEnabled: dragging == null,
                      child: SizedBox(
                        width: widget.sceneSize.width,
                        height: widget.sceneSize.height,
                        child: Stack(
                          children: [
                            if (widget.backdropPainter != null)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: widget.backdropPainter,
                                ),
                              ),
                            Positioned.fill(
                              child: RepaintBoundary(
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey((
                                    scene.zones.map((z) => z.id).join(','),
                                    widget.pulseEdgeId,
                                  )),
                                  tween: Tween(begin: 0, end: 1),
                                  duration:
                                      MediaQuery.disableAnimationsOf(context) ||
                                          widget.pulseEdgeId == null &&
                                              !scene.zones.any(
                                                (z) =>
                                                    z.visualState ==
                                                    NodeVisualState.error,
                                              )
                                      ? Duration.zero
                                      : const Duration(milliseconds: 450),
                                  builder: (context, value, _) => CustomPaint(
                                    painter: PointerEdgePainter(
                                      scene,
                                      Theme.of(context).colorScheme.outline,
                                      pulseEdgeId: widget.pulseEdgeId,
                                      traversalEdges: widget.traversalEdges,
                                      edgePulse: math.sin(math.pi * value),
                                      zonePulse:
                                          .35 +
                                          .65 * math.cos(math.pi * value).abs(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: AnimatedNodeLayer(
                                scene: scene,
                                nodeContentBuilder: widget.nodeContentBuilder,
                                pinnedIds: widget.pinnedIds,
                                selectedId: selection,
                                onSelect: select,
                                barMode: bars,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
