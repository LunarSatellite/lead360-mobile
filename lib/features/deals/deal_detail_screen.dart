import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/money.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/detail_kit.dart';
import 'deals_providers.dart';

class DealDetailScreen extends ConsumerWidget {
  const DealDetailScreen({super.key, required this.dealId});
  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deal = ref.watch(dealDetailProvider(dealId));
    return Scaffold(
      appBar: AppBar(title: const Text('Deal')),
      body: AsyncView(
        value: deal,
        onRetry: () => ref.invalidate(dealDetailProvider(dealId)),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DetailHeader(initial: d.name.isNotEmpty ? d.name[0] : '?', title: d.name, subtitle: d.status.label),
            const SizedBox(height: 20),
            DetailSection('Deal', [
              DetailRow('Amount', money(d.amount, d.currency)),
              DetailRow('Stage', d.stageName),
              DetailRow('Account', d.accountName),
              DetailRow('Owner', d.ownedByUserName),
              DetailRow('Close date', d.closeDate == null ? null : DateFormat('MMM d, y').format(d.closeDate!.toLocal())),
            ]),
          ],
        ),
      ),
    );
  }
}
