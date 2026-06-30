import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/money.dart';
import '../../shared/widgets/skeleton.dart';
import 'dashboard_providers.dart';
import 'widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final auth = ref.watch(authControllerProvider);
    final name = auth is AuthAuthenticated && auth.user.displayName.isNotEmpty ? auth.user.displayName.split(' ').first : 'there';

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _Greeting(name: name),
          const SizedBox(height: 20),
          data.when(
            loading: () => const _DashboardSkeleton(),
            error: (e, _) => _ErrorBox(onRetry: () => ref.invalidate(dashboardProvider)),
            data: (d) => _Body(d),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brand.withOpacity(0.18), AppColors.glass1],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brand.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13)),
                const SizedBox(height: 2),
                Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.bolt, color: AppColors.bg, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.d);
  final DashboardData d;
  @override
  Widget build(BuildContext context) {
    final l = d.leads;
    final deals = d.deals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            StatCard(label: 'Total leads', count: l.total, icon: Icons.people_alt, accent: AppColors.brand),
            StatCard(label: 'Hot leads', count: l.hotCount, icon: Icons.local_fire_department, accent: AppColors.danger),
            StatCard(label: 'Pipeline value', value: money(deals.totalPipelineValue, 'USD'), icon: Icons.trending_up, accent: AppColors.info),
            StatCard(label: 'Win rate', value: '${deals.winRate.toStringAsFixed(0)}%', icon: Icons.emoji_events, accent: AppColors.success),
          ],
        ),
        const SectionHeader('Lead pipeline'),
        PipelineBar(segments: [
          (label: 'New', count: l.newCount, color: AppColors.info),
          (label: 'Warm', count: l.warmCount, color: AppColors.warning),
          (label: 'Hot', count: l.hotCount, color: AppColors.danger),
          (label: 'Nurturing', count: l.nurturingCount, color: AppColors.violet),
          (label: 'Converted', count: l.convertedCount, color: AppColors.success),
        ]),
        const SectionHeader('Today'),
        Row(
          children: [
            Expanded(child: _MiniStat(label: 'Converted today', value: '${l.convertedToday}', color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat(label: 'Closing this month', value: money(deals.closingThisMonthValue, 'USD'), color: AppColors.brand)),
          ],
        ),
        const SectionHeader('Quick actions'),
        Row(
          children: [
            _Action(icon: Icons.person_add_alt, label: 'New lead', onTap: () => context.push('/leads/new')),
            const SizedBox(width: 12),
            _Action(icon: Icons.auto_awesome, label: 'Copilot', onTap: () => context.push('/copilot')),
            const SizedBox(width: 12),
            _Action(icon: Icons.search, label: 'Search', onTap: () => context.push('/search')),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glass1, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.glass1, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle, width: 0.5),
          ),
          child: Column(children: [
            Icon(icon, color: AppColors.brand, size: 20),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.45,
          children: List.generate(4, (_) => const Skeleton(height: 100, radius: 16)),
        ),
        const SizedBox(height: 20),
        const Skeleton(height: 90, radius: 16),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(children: [
        const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 32),
        const SizedBox(height: 10),
        const Text('Could not load your dashboard.', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
