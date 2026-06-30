import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_count.dart';

const _valueStyle = TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, height: 1);

/// KPI tile: icon chip + big value + label, with a tinted accent.
/// Pass [count] for an integer KPI (animated count-up) or [value] for a formatted string.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.icon, required this.accent, this.value, this.count, this.onTap})
      : assert(value != null || count != null, 'StatCard needs value or count');
  final String label;
  final String? value;
  final int? count;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glass1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(height: 12),
            if (count != null)
              AnimatedCount(count!, style: _valueStyle)
            else
              Text(value!, style: _valueStyle),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: const TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// Proportional stacked bar + legend for a stage distribution.
class PipelineBar extends StatelessWidget {
  const PipelineBar({super.key, required this.segments});
  final List<({String label, int count, Color color})> segments;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (s, e) => s + e.count);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: AppColors.bgElevated)
                  : Row(
                      children: segments
                          .where((s) => s.count > 0)
                          .map((s) => Expanded(flex: s.count, child: Container(color: s.color)))
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: segments
                .map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Text('${s.label} ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('${s.count}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
  }
}
