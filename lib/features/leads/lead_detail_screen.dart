import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/stage_pill.dart';
import 'lead_model.dart';
import 'leads_providers.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});
  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lead = ref.watch(leadDetailProvider(leadId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lead')),
      body: AsyncView(
        value: lead,
        onRetry: () => ref.invalidate(leadDetailProvider(leadId)),
        data: (l) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.brand.withOpacity(0.1),
                  child: Text((l.displayName.isNotEmpty ? l.displayName[0] : '?').toUpperCase(),
                      style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800, fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.displayName,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 6),
                      Row(children: [StagePill(l.stage), const SizedBox(width: 8), Text('Score ${l.score}', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700))]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Section('Contact', [
              _Row('Email', l.customerEmail),
              _Row('Phone', l.customerPhone),
              _Row('Company', l.companyName),
              _Row('Assigned to', l.assignedToUserName),
            ]),
            const SizedBox(height: 12),
            _Section('Context', [
              _Row('Intent', l.intentSummary),
              _Row('Channel', l.channelHandle),
              _Row('Last activity', _fmt(l.lastActivityAt)),
              _Row('Created', _fmt(l.createdAt)),
            ]),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.swap_horiz, size: 18),
              onPressed: () => _changeStage(context, ref, l),
              label: const Text('Change stage'),
            ),
          ],
        ),
      ),
    );
  }

  static String? _fmt(DateTime? d) => d == null ? null : DateFormat('MMM d, y · HH:mm').format(d.toLocal());

  Future<void> _changeStage(BuildContext context, WidgetRef ref, Lead l) async {
    const options = [LeadStage.newLead, LeadStage.warm, LeadStage.hot, LeadStage.qualified, LeadStage.converted, LeadStage.lost];
    final picked = await showModalBottomSheet<LeadStage>(
      context: context,
      backgroundColor: AppColors.bgCard,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((s) => ListTile(
                    title: Text(s.label, style: const TextStyle(color: AppColors.textPrimary)),
                    trailing: s == l.stage ? const Icon(Icons.check, color: AppColors.brand) : null,
                    onTap: () => Navigator.pop(context, s),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked == null || picked == l.stage) return;
    try {
      await ref.read(leadsRepositoryProvider).updateStage(l.id, picked);
      ref.invalidate(leadDetailProvider(l.id));
      ref.invalidate(leadsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${picked.label}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update: $e')));
      }
    }
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.rows);
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

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '—', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
