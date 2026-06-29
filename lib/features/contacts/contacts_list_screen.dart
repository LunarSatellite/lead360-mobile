import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/paged_list_view.dart';
import 'contact_model.dart';
import 'contacts_providers.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});
  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsPagedProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _ctrl,
            onSubmitted: (v) => ref.read(contactsSearchProvider.notifier).state = v.trim(),
            decoration: const InputDecoration(
              hintText: 'Search name, email, phone…',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: PagedListView<Contact>(
            state: contacts,
            emptyText: 'No contacts found',
            emptyIcon: Icons.contacts_outlined,
            onRefresh: () => ref.read(contactsPagedProvider.notifier).refresh(),
            onLoadMore: () => ref.read(contactsPagedProvider.notifier).loadMore(),
            itemBuilder: (_, c) => _ContactCard(c),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard(this.c);
  final Contact c;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/contacts/${c.id}'),
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
              child: Text((c.fullName.isNotEmpty ? c.fullName[0] : '?').toUpperCase(),
                  style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.fullName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(c.jobTitle ?? c.email ?? c.phone ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
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
