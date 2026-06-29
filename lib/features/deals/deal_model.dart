import '../../core/network/json.dart';

enum DealStatus { open, won, lost, unknown }

DealStatus dealStatusFromInt(int v) => switch (v) {
      1 => DealStatus.open,
      2 => DealStatus.won,
      3 => DealStatus.lost,
      _ => DealStatus.unknown,
    };

extension DealStatusX on DealStatus {
  String get label => switch (this) {
        DealStatus.open => 'Open',
        DealStatus.won => 'Closed Won',
        DealStatus.lost => 'Closed Lost',
        DealStatus.unknown => 'Unknown',
      };
}

class Deal {
  final String id;
  final String name;
  final String? accountName;
  final String? stageName;
  final double? amount;
  final String currency;
  final DealStatus status;
  final String? ownedByUserName;
  final DateTime? closeDate;

  const Deal({
    required this.id,
    required this.name,
    required this.currency,
    required this.status,
    this.accountName,
    this.stageName,
    this.amount,
    this.ownedByUserName,
    this.closeDate,
  });

  factory Deal.fromJson(Map<String, dynamic> j) {
    final raw = j['amount'] ?? j['Amount'];
    return Deal(
      id: str(j, 'id') ?? '',
      name: str(j, 'name') ?? 'Deal',
      accountName: str(j, 'accountName'),
      stageName: str(j, 'stageName'),
      amount: raw == null ? null : doubleOr(j, 'amount'),
      currency: str(j, 'currency') ?? 'USD',
      status: dealStatusFromInt(intOr(j, 'status', 1)),
      ownedByUserName: str(j, 'ownedByUserName'),
      closeDate: dateOrNull(j, 'closeDate'),
    );
  }
}
