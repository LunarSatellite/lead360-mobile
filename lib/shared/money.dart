import 'package:intl/intl.dart';

/// Currency formatter shared across deals/quotes/invoices screens.
String money(num? amount, String currency) {
  if (amount == null) return '—';
  try {
    return NumberFormat.simpleCurrency(name: currency.isEmpty ? 'USD' : currency).format(amount);
  } catch (_) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
