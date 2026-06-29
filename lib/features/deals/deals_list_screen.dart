import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/money.dart';
import '../../shared/widgets/paged_list_view.dart';
import 'deal_model.dart';
import 'deals_providers.dart';

class DealsListScreen extends ConsumerStatefulWidget {
  const DealsListScreen({super.key});
  @override
  ConsumerState<DealsListScreen> createState() => _DealsListScreenState();
}

class _DealsListScreenState extends ConsumerState<DealsListScreen> {
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final deals = ref.watch(dealsPagedProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _ctrl,
            onSubmitted: (v) => ref.read(dealsSearchProvider.notifier).state = v.trim(),
            decoration: const InputDecoration(
              hintText: 'Search deals…',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: PagedListView<Deal>(
            state: deals,
            emptyText: 'No deals found',
            onRefresh: () => ref.read(dealsPagedProvider.notifier).refresh(),
            onLoadMore: () => ref.read(dealsPagedProvider.notifier).loadMore(),
            itemBuilder: (_, d) => _DealCard(d),
          ),
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard(this.d);
  final Deal d;

  Color get _statusColor => switch (d.status) {
        DealStatus.won => AppColors.success,
        DealStatus.lost => AppColors.danger,
        _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/deals/${d.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glass1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Text(money(d.amount, d.currency),
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _statusColor.withOpacity(0.3), width: 0.5),
                  ),
                  child: Text(d.status.label, style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text([d.stageName, d.accountName].where((s) => (s ?? '').isNotEmpty).join(' · '),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
