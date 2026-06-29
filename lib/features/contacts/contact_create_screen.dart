import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'contacts_providers.dart';

class ContactCreateScreen extends ConsumerStatefulWidget {
  const ContactCreateScreen({super.key});
  @override
  ConsumerState<ContactCreateScreen> createState() => _ContactCreateScreenState();
}

class _ContactCreateScreenState extends ConsumerState<ContactCreateScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _job = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _job]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _save({bool allowDuplicate = false}) async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(contactsRepositoryProvider).create(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            jobTitle: _job.text.trim(),
            allowDuplicate: allowDuplicate,
          );
      ref.read(contactsPagedProvider.notifier).refresh();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact created')));
      }
    } catch (e) {
      setState(() => _saving = false);
      final msg = e.toString();
      // The API returns 409 on a likely duplicate — offer to create anyway.
      if (mounted && msg.toLowerCase().contains('exist')) {
        final go = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Text('Possible duplicate', style: TextStyle(color: AppColors.textPrimary)),
            content: Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create anyway')),
            ],
          ),
        );
        if (go == true) return _save(allowDuplicate: true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New contact')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Label('Full name'),
          TextField(controller: _name, decoration: const InputDecoration(hintText: 'Jane Smith'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _Label('Email'),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(hintText: 'jane@company.com')),
          const SizedBox(height: 14),
          _Label('Phone'),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+1 555 000 1234')),
          const SizedBox(height: 14),
          _Label('Job title'),
          TextField(controller: _job, decoration: const InputDecoration(hintText: 'Head of Procurement')),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _valid && !_saving ? () => _save() : null,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                : const Text('Create contact'),
          ),
          if (!_valid)
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('A full name is required.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)));
}
