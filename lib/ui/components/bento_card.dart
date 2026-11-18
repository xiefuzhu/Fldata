import 'package:flutter/material.dart';
import '../tokens/m3e_shapes.dart';

class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Material(
        color: color ?? scheme.surfaceContainerLow,
        shape: M3eShapes.shape(
          20,
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
