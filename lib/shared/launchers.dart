import 'package:url_launcher/url_launcher.dart';

/// tel: / mailto: / WhatsApp deep-link helpers. All best-effort — return false
/// if no handler app is available so callers can show a message.
class Launchers {
  static String _digits(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

  static Future<bool> call(String phone) => _open('tel:${_digits(phone)}');

  static Future<bool> email(String address, {String? subject}) {
    final q = subject == null ? '' : '?subject=${Uri.encodeComponent(subject)}';
    return _open('mailto:$address$q');
  }

  /// WhatsApp expects digits only (no +, no spaces).
  static Future<bool> whatsApp(String phone, {String? text}) {
    final num = _digits(phone).replaceAll('+', '');
    final q = text == null ? '' : '?text=${Uri.encodeComponent(text)}';
    return _open('https://wa.me/$num$q');
  }

  static Future<bool> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
