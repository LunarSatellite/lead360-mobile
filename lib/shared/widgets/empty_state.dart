import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Friendly empty state: soft icon chip + title + optional subtitle/action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.brand.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: AppColors.brand, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
