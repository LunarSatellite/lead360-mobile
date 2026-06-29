import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'lead_model.dart';
import 'leads_providers.dart';

class LeadCreateScreen extends ConsumerStatefulWidget {
  const LeadCreateScreen({super.key});
  @override
  ConsumerState<LeadCreateScreen> createState() => _LeadCreateScreenState();
}

class _LeadCreateScreenState extends ConsumerState<LeadCreateScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _source = TextEditingController();
  final _notes = TextEditingController();
  LeadStage _stage = LeadStage.newLead;
  bool _saving = false;

  static const _stages = [LeadStage.newLead, LeadStage.warm, LeadStage.hot];

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _source, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty || _email.text.trim().isNotEmpty || _phone.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(leadsRepositoryProvider).create(
            customerName: _name.text.trim(),
            customerEmail: _email.text.trim(),
            customerPhone: _phone.text.trim(),
            stage: _stage,
            adSource: _source.text.trim(),
            notes: _notes.text.trim(),
          );
      ref.read(leadsPagedProvider.notifier).refresh();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead created')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New lead')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Label('Full name'),
          TextField(controller: _name, decoration: const InputDecoration(hintText: 'John Doe'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _Label('Phone'),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+1 555 000 1234'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _Label('Email'),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(hintText: 'john@example.com'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _Label('Stage'),
          Wrap(
            spacing: 8,
            children: _stages
                .map((s) => ChoiceChip(
                      label: Text(s.label),
                      selected: _stage == s,
                      onSelected: (_) => setState(() => _stage = s),
                      showCheckmark: false,
                      backgroundColor: AppColors.bgElevated,
                      selectedColor: AppColors.brand.withOpacity(0.15),
                      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _stage == s ? AppColors.brand : AppColors.textSecondary),
                      side: BorderSide(color: _stage == s ? AppColors.brand : AppColors.borderSubtle, width: 0.5),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          _Label('Source (how did you meet?)'),
          TextField(controller: _source, decoration: const InputDecoration(hintText: 'Trade show, referral…')),
          const SizedBox(height: 14),
          _Label('Notes'),
          TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(hintText: 'Context, next steps…')),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _valid && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                : const Text('Create lead'),
          ),
          if (!_valid)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Add at least a name, phone, or email.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}
