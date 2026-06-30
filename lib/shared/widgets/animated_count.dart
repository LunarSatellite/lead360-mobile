import 'package:flutter/material.dart';

/// Counts up from 0 to [value] on first build — a premium touch for KPI tiles.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount(this.value, {super.key, required this.style, this.duration = const Duration(milliseconds: 700)});
  final int value;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text('${v.round()}', style: style),
    );
  }
}
