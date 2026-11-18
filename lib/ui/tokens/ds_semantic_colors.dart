import 'package:flutter/material.dart';

@immutable
class DsSemanticColors extends ThemeExtension<DsSemanticColors> {
  const DsSemanticColors({
    required this.activePointer,
    required this.comparing,
    required this.comparingContainer,
    required this.swappingOrMoving,
    required this.sortedOrVisited,
    required this.sortedContainer,
    required this.sentinelOrPivot,
    required this.memoryLeakOrError,
    required this.codeActiveLineGlow,
  });
  final Color activePointer;
  final Color comparing;
  final Color comparingContainer;
  final Color swappingOrMoving;
  final Color sortedOrVisited;
  final Color sortedContainer;
  final Color sentinelOrPivot;
  final Color memoryLeakOrError;
  final Color codeActiveLineGlow;
  factory DsSemanticColors.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return DsSemanticColors(
      activePointer: scheme.primary,
      comparing: Color(dark ? 0xFFFFB74D : 0xFFE65100),
      comparingContainer: Color(dark ? 0xFF4E342E : 0xFFFFE0B2),
      swappingOrMoving: Color(dark ? 0xFFF48FB1 : 0xFFD81B60),
      sortedOrVisited: Color(dark ? 0xFF81C784 : 0xFF2E7D32),
      sortedContainer: Color(dark ? 0xFF1B3B22 : 0xFFC8E6C9),
      sentinelOrPivot: Color(dark ? 0xFFCE93D8 : 0xFF6A1B9A),
      memoryLeakOrError: scheme.error,
      codeActiveLineGlow: scheme.primary.withValues(alpha: dark ? 0.22 : 0.14),
    );
  }
  @override
  DsSemanticColors copyWith({
    Color? activePointer,
    Color? comparing,
    Color? comparingContainer,
    Color? swappingOrMoving,
    Color? sortedOrVisited,
    Color? sortedContainer,
    Color? sentinelOrPivot,
    Color? memoryLeakOrError,
    Color? codeActiveLineGlow,
  }) => DsSemanticColors(
    activePointer: activePointer ?? this.activePointer,
    comparing: comparing ?? this.comparing,
    comparingContainer: comparingContainer ?? this.comparingContainer,
    swappingOrMoving: swappingOrMoving ?? this.swappingOrMoving,
    sortedOrVisited: sortedOrVisited ?? this.sortedOrVisited,
    sortedContainer: sortedContainer ?? this.sortedContainer,
    sentinelOrPivot: sentinelOrPivot ?? this.sentinelOrPivot,
    memoryLeakOrError: memoryLeakOrError ?? this.memoryLeakOrError,
    codeActiveLineGlow: codeActiveLineGlow ?? this.codeActiveLineGlow,
  );
  @override
  DsSemanticColors lerp(covariant DsSemanticColors? other, double t) =>
      other == null
      ? this
      : DsSemanticColors(
          activePointer: Color.lerp(activePointer, other.activePointer, t)!,
          comparing: Color.lerp(comparing, other.comparing, t)!,
          comparingContainer: Color.lerp(
            comparingContainer,
            other.comparingContainer,
            t,
          )!,
          swappingOrMoving: Color.lerp(
            swappingOrMoving,
            other.swappingOrMoving,
            t,
          )!,
          sortedOrVisited: Color.lerp(
            sortedOrVisited,
            other.sortedOrVisited,
            t,
          )!,
          sortedContainer: Color.lerp(
            sortedContainer,
            other.sortedContainer,
            t,
          )!,
          sentinelOrPivot: Color.lerp(
            sentinelOrPivot,
            other.sentinelOrPivot,
            t,
          )!,
          memoryLeakOrError: Color.lerp(
            memoryLeakOrError,
            other.memoryLeakOrError,
            t,
          )!,
          codeActiveLineGlow: Color.lerp(
            codeActiveLineGlow,
            other.codeActiveLineGlow,
            t,
          )!,
        );
}
