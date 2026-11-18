import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

/// Native pan/zoom belongs to the stage immediately. Waiting for the scale
/// recognizer's pan slop lets an ancestor vertical Scrollable win first.
/// Touch and mouse gestures continue through InteractiveViewer unchanged.
class StageTrackpadGestureRecognizer extends OneSequenceGestureRecognizer {
  ValueChanged<PointerPanZoomStartEvent>? onStart;
  ValueChanged<PointerPanZoomUpdateEvent>? onUpdate;
  @override
  bool isPointerAllowed(PointerDownEvent event) => false;
  @override
  bool isPointerPanZoomAllowed(PointerPanZoomStartEvent event) => true;
  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerPanZoomStartEvent) onStart?.call(event);
    if (event is PointerPanZoomUpdateEvent) onUpdate?.call(event);
    if (event is PointerPanZoomEndEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}
  @override
  String get debugDescription => 'stage trackpad';
}

/// The canvas owns direct contacts from down to up. Claiming early keeps a
/// slow vertical pan from becoming a scroll of the surrounding workbench.
class StageContactGestureRecognizer extends ScaleGestureRecognizer {
  @override
  bool isPointerPanZoomAllowed(PointerPanZoomStartEvent event) => false;
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
