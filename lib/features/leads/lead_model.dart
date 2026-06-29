import '../../core/network/json.dart';

/// Mirrors the API LeadStage enum.
enum LeadStage { visitor, newLead, warm, hot, nurturing, converted, lost, qualified, mql, unknown }

LeadStage leadStageFromInt(int v) => switch (v) {
      0 => LeadStage.visitor,
      1 => LeadStage.newLead,
      2 => LeadStage.warm,
      3 => LeadStage.hot,
      4 => LeadStage.nurturing,
      5 => LeadStage.converted,
      6 => LeadStage.lost,
      7 => LeadStage.qualified,
      8 => LeadStage.mql,
      _ => LeadStage.unknown,
    };

extension LeadStageX on LeadStage {
  String get label => switch (this) {
        LeadStage.visitor => 'Visitor',
        LeadStage.newLead => 'New',
        LeadStage.warm => 'Warm',
        LeadStage.hot => 'Hot',
        LeadStage.nurturing => 'Nurturing',
        LeadStage.converted => 'Converted',
        LeadStage.lost => 'Lost',
        LeadStage.qualified => 'Qualified',
        LeadStage.mql => 'MQL',
        LeadStage.unknown => 'Unknown',
      };
  int get raw => switch (this) {
        LeadStage.visitor => 0,
        LeadStage.newLead => 1,
        LeadStage.warm => 2,
        LeadStage.hot => 3,
        LeadStage.nurturing => 4,
        LeadStage.converted => 5,
        LeadStage.lost => 6,
        LeadStage.qualified => 7,
        LeadStage.mql => 8,
        LeadStage.unknown => -1,
      };
}

class Lead {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String channelHandle;
  final LeadStage stage;
  final int score;
  final String? intentSummary;
  final String? assignedToUserName;
  final String? companyName;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;

  const Lead({
    required this.id,
    required this.channelHandle,
    required this.stage,
    required this.score,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.intentSummary,
    this.assignedToUserName,
    this.companyName,
    this.lastActivityAt,
    this.createdAt,
  });

  String get displayName =>
      (customerName?.isNotEmpty ?? false) ? customerName! : (channelHandle.isNotEmpty ? channelHandle : 'Lead');

  factory Lead.fromJson(Map<String, dynamic> j) => Lead(
        id: str(j, 'id') ?? '',
        customerName: str(j, 'customerName'),
        customerPhone: str(j, 'customerPhone'),
        customerEmail: str(j, 'customerEmail'),
        channelHandle: str(j, 'channelHandle') ?? '',
        stage: leadStageFromInt(intOr(j, 'stage')),
        score: intOr(j, 'score'),
        intentSummary: str(j, 'intentSummary'),
        assignedToUserName: str(j, 'assignedToUserName'),
        companyName: str(j, 'companyName'),
        lastActivityAt: dateOrNull(j, 'lastActivityAt'),
        createdAt: dateOrNull(j, 'createdAt'),
      );
}
