import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/stage_pill.dart';
import 'lead_model.dart';
import 'leads_providers.dart';

class LeadsListScreen extends ConsumerStatefulWidget {
  const LeadsListScreen({super.key});
  @override
  ConsumerState<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends ConsumerState<LeadsListScreen> {
  final _searchCtrl = TextEditingController();

  static const _stages = [
    null, LeadStage.newLead, LeadStage.warm, LeadStage.hot, LeadStage.qualified, LeadStage.converted,
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(leadsFilterProvider);
    final leads = ref.watch(leadsListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (v) => ref.read(leadsFilterProvider.notifier).update((f) => f.copyWith(search: v.trim())),
            decoration: InputDecoration(
              hintText: 'Search name, phone, intent…',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _stages[i];
              final active = filter.stage == s;
              return ChoiceChip(
                label: Text(s?.label ?? 'All'),
                selected: active,
                onSelected: (_) => ref.read(leadsFilterProvider.notifier).update(
                      (f) => s == null ? f.copyWith(clearStage: true) : f.copyWith(stage: s),
                    ),
                showCheckmark: false,
                backgroundColor: AppColors.bgElevated,
                selectedColor: AppColors.brand.withOpacity(0.15),
                labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.brand : AppColors.textSecondary),
                side: BorderSide(color: active ? AppColors.brand : AppColors.borderSubtle, width: 0.5),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () async => ref.invalidate(leadsListProvider),
            child: AsyncView(
              value: leads,
              onRetry: () => ref.invalidate(leadsListProvider),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return ListView(children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: Text('No leads found', style: TextStyle(color: AppColors.textMuted))),
                    ),
                  ]);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: paged.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _LeadCard(paged.items[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard(this.lead);
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/leads/${lead.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glass1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.brand.withOpacity(0.1),
              child: Text(
                (lead.displayName.isNotEmpty ? lead.displayName[0] : '?').toUpperCase(),
                style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lead.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(lead.intentSummary ?? lead.companyName ?? lead.customerEmail ?? lead.channelHandle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StagePill(lead.stage),
                const SizedBox(height: 6),
                Text('${lead.score}',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
