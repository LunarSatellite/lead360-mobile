import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared building blocks for record-detail screens (header + labelled sections).
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.initial, required this.title, this.subtitle, this.trailing});
  final String initial;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.brand.withOpacity(0.1),
          child: Text((initial.isNotEmpty ? initial : '?').toUpperCase(),
              style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800, fontSize: 20)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class DetailSection extends StatelessWidget {
  const DetailSection(this.title, this.rows, {super.key});
  final String title;
  final List<Widget> rows;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glass1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key});
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '—', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
