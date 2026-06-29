import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/money.dart';
import '../../shared/widgets/async_view.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider).trim();
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search leads, contacts, deals…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted),
              onPressed: () {
                _ctrl.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.length < 2
          ? const Center(child: Text('Type at least 2 characters', style: TextStyle(color: AppColors.textMuted)))
          : AsyncView(
              value: results,
              onRetry: () => ref.invalidate(searchResultsProvider),
              data: (r) {
                if (r.isEmpty) {
                  return const Center(child: Text('No matches', style: TextStyle(color: AppColors.textMuted)));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (r.leads.isNotEmpty) ...[
                      const _GroupHeader('Leads'),
                      for (final l in r.leads)
                        _ResultTile(
                          icon: Icons.people_alt_outlined,
                          title: l.displayName,
                          subtitle: l.intentSummary ?? l.customerEmail ?? l.channelHandle,
                          onTap: () => context.push('/leads/${l.id}'),
                        ),
                    ],
                    if (r.contacts.isNotEmpty) ...[
                      const _GroupHeader('Contacts'),
                      for (final c in r.contacts)
                        _ResultTile(
                          icon: Icons.contacts_outlined,
                          title: c.fullName,
                          subtitle: c.jobTitle ?? c.email ?? c.phone,
                          onTap: () => context.push('/contacts/${c.id}'),
                        ),
                    ],
                    if (r.deals.isNotEmpty) ...[
                      const _GroupHeader('Deals'),
                      for (final d in r.deals)
                        _ResultTile(
                          icon: Icons.handshake_outlined,
                          title: d.name,
                          subtitle: [d.stageName, money(d.amount, d.currency)].where((s) => (s ?? '').isNotEmpty).join(' · '),
                          onTap: () => context.push('/deals/${d.id}'),
                        ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(title.toUpperCase(),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.icon, required this.title, this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  if ((subtitle ?? '').isNotEmpty)
                    Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
