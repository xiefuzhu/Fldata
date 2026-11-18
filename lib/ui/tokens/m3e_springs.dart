import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

abstract final class M3eSprings {
  static final fastSpatial = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 1400,
    ratio: 0.72,
  );
  static final standardSpatial = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 700,
    ratio: 0.75,
  );
  static final slowSpatial = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 320,
    ratio: 0.80,
  );
  static final effects = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 1200,
    ratio: 1,
  );
}

class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring)
    : simulation = SpringSimulation(spring, 0, 1, 0);
  final SpringSimulation simulation;
  @override
  double transformInternal(double t) => simulation.x(t * 0.5);
}

extension MotionScale on BuildContext {
  double get motionScale => MediaQuery.disableAnimationsOf(this) ? 0 : 1;
  Duration get motionDuration =>
      Duration(milliseconds: (300 * motionScale).round());
}
