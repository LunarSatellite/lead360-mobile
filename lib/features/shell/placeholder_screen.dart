import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Temporary stand-in for tabs not yet implemented (Contacts, Deals, Tasks, More).
/// Replace each with its real screen following the Leads vertical as the pattern:
/// model → repository → providers → list/detail screen.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon, this.note});
  final String title;
  final IconData icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(note ?? 'Coming next — mirrors the Leads module.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
