import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'activity_providers.dart';

/// Compact, reusable activity timeline for a record detail screen.
class ActivityTimeline extends ConsumerWidget {
  const ActivityTimeline({super.key, required this.kind, required this.id});
  final int kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(activityTimelineProvider((kind: kind, id: id)));
    return events.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand))),
      ),
      error: (_, __) => const Text('Could not load activity.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      data: (list) {
        if (list.isEmpty) {
          return const Text('No activity yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
        }
        return Column(
          children: [
            for (var i = 0; i < list.length; i++) _TimelineRow(event: list[i], isLast: i == list.length - 1),
          ],
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});
  final ActivityEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 9, height: 9, margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
              ),
              if (!isLast) Expanded(child: Container(width: 1, color: AppColors.borderMedium)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(event.kindLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (event.occurredAt != null)
                        Text(DateFormat('MMM d, HH:mm').format(event.occurredAt!.toLocal()),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    ],
                  ),
                  if (event.summary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(event.summary, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
