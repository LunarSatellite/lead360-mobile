import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Branded splash shown while the session bootstraps — a gentle scale/fade-in of
/// the gradient logo mark over the dark ground.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (_, t, child) => Opacity(opacity: t.clamp(0, 1), child: Transform.scale(scale: t, child: child)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.bolt, color: AppColors.bg, size: 36),
              ),
              const SizedBox(height: 18),
              const Text('Lead360',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 24),
              const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
