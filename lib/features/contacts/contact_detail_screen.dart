import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/detail_kit.dart';
import 'contacts_providers.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({super.key, required this.contactId});
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(contactDetailProvider(contactId));
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: AsyncView(
        value: contact,
        onRetry: () => ref.invalidate(contactDetailProvider(contactId)),
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DetailHeader(initial: c.fullName.isNotEmpty ? c.fullName[0] : '?', title: c.fullName, subtitle: c.jobTitle),
            const SizedBox(height: 20),
            DetailSection('Contact', [
              DetailRow('Email', c.email),
              DetailRow('Phone', c.phone),
              DetailRow('Job title', c.jobTitle),
              DetailRow('Created', c.createdAt == null ? null : DateFormat('MMM d, y').format(c.createdAt!.toLocal())),
            ]),
          ],
        ),
      ),
    );
  }
}
