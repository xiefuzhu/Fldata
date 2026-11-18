import 'package:flutter/material.dart';

abstract final class M3eShapes {
  static RoundedSuperellipseBorder shape(
    double radius, {
    BorderSide side = BorderSide.none,
  }) => RoundedSuperellipseBorder(
    borderRadius: BorderRadius.circular(radius),
    side: side,
  );
  static final small = shape(10);
  static final card = shape(20);
  static final capsule = shape(28);
}
