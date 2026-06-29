import 'package:flutter/material.dart';

/// One-shot fade + subtle upward slide on first build — gives lists/cards a
/// premium entrance without a controller. Cheap (TweenAnimationBuilder).
class FadeInSlide extends StatelessWidget {
  const FadeInSlide({super.key, required this.child, this.duration = const Duration(milliseconds: 280), this.offsetY = 12});
  final Widget child;
  final Duration duration;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * offsetY), child: child),
      ),
      child: child,
    );
  }
}
