import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../launchers.dart';

/// Call / Email / WhatsApp action row for a record with a phone/email.
/// Renders only the actions that have data.
class ContactActions extends StatelessWidget {
  const ContactActions({super.key, this.phone, this.email});
  final String? phone;
  final String? email;

  bool get _hasPhone => (phone ?? '').trim().isNotEmpty;
  bool get _hasEmail => (email ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasPhone && !_hasEmail) return const SizedBox.shrink();
    return Row(
      children: [
        if (_hasPhone)
          _ActionButton(icon: Icons.call, label: 'Call', onTap: () => _run(context, Launchers.call(phone!), 'No dialer available')),
        if (_hasPhone) const SizedBox(width: 10),
        if (_hasPhone)
          _ActionButton(icon: Icons.chat, label: 'WhatsApp', color: const Color(0xFF25D366), onTap: () => _run(context, Launchers.whatsApp(phone!), 'WhatsApp not installed')),
        if (_hasPhone && _hasEmail) const SizedBox(width: 10),
        if (_hasEmail)
          _ActionButton(icon: Icons.mail_outline, label: 'Email', onTap: () => _run(context, Launchers.email(email!), 'No mail app available')),
      ],
    );
  }

  Future<void> _run(BuildContext context, Future<bool> action, String failMsg) async {
    final ok = await action;
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failMsg)));
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.brand;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: c.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withOpacity(0.3), width: 0.5),
          ),
          child: Column(children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
