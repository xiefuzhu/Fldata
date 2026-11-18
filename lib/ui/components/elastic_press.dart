import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../tokens/m3e_springs.dart';

class ElasticPress extends StatefulWidget {
  const ElasticPress({super.key, required this.child, required this.onPressed});
  final Widget child;
  final VoidCallback onPressed;
  @override
  State<ElasticPress> createState() => _ElasticPressState();
}

class _ElasticPressState extends State<ElasticPress>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController.unbounded(vsync: this, value: 1);
  void target(double value) {
    if (context.motionScale == 0) {
      controller.value = value;
    } else {
      controller.animateWith(
        SpringSimulation(
          M3eSprings.fastSpatial,
          controller.value,
          value,
          controller.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    child: Semantics(
      button: true,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (active) => target(active ? 0.96 : 1),
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: widget.child,
        ),
      ),
    ),
    builder: (context, child) =>
        Transform.scale(scale: controller.value, child: child),
  );
}
