import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'deals_providers.dart';

class DealCreateScreen extends ConsumerStatefulWidget {
  const DealCreateScreen({super.key});
  @override
  ConsumerState<DealCreateScreen> createState() => _DealCreateScreenState();
}

class _DealCreateScreenState extends ConsumerState<DealCreateScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _currency = TextEditingController(text: 'USD');
  String? _stageId;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _amount, _currency]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty && (_stageId?.isNotEmpty ?? false);

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(dealsRepositoryProvider).create(
            name: _name.text.trim(),
            stageId: _stageId!,
            amount: double.tryParse(_amount.text.trim()),
            currency: _currency.text.trim().isEmpty ? 'USD' : _currency.text.trim().toUpperCase(),
          );
      ref.read(dealsPagedProvider.notifier).refresh();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deal created')));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(dealStagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('New deal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Label('Deal name'),
          TextField(controller: _name, decoration: const InputDecoration(hintText: 'Acme — annual license'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _Label('Stage'),
          stages.when(
            loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator(color: AppColors.brand, backgroundColor: AppColors.bgElevated)),
            error: (_, __) => const Text('Could not load stages.', style: TextStyle(color: AppColors.danger, fontSize: 12)),
            data: (list) {
              if (list.isEmpty) return const Text('No pipeline stages configured.', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
              _stageId ??= list.first.id;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list
                    .map((s) => ChoiceChip(
                          label: Text(s.name),
                          selected: _stageId == s.id,
                          onSelected: (_) => setState(() => _stageId = s.id),
                          showCheckmark: false,
                          backgroundColor: AppColors.bgElevated,
                          selectedColor: AppColors.brand.withOpacity(0.15),
                          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _stageId == s.id ? AppColors.brand : AppColors.textSecondary),
                          side: BorderSide(color: _stageId == s.id ? AppColors.brand : AppColors.borderSubtle, width: 0.5),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Label('Amount'),
                  TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: '0.00')),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Label('Currency'),
                  TextField(controller: _currency, decoration: const InputDecoration(hintText: 'USD')),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _valid && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                : const Text('Create deal'),
          ),
          if (!_valid)
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('Name and a stage are required.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
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
