import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';

/// CrmActivityEntityKind (backend): Contact=1, Deal=2, SupportCase=3, Lead=4, Account=5.
class ActivityEntityKind {
  static const contact = 1;
  static const deal = 2;
  static const lead = 4;
}

class ActivityEvent {
  final String id;
  final int eventKind;
  final String summary;
  final DateTime? occurredAt;

  const ActivityEvent({required this.id, required this.eventKind, required this.summary, this.occurredAt});

  factory ActivityEvent.fromJson(Map<String, dynamic> j) => ActivityEvent(
        id: str(j, 'id') ?? '',
        eventKind: intOr(j, 'eventKind'),
        summary: str(j, 'summary') ?? '',
        occurredAt: dateOrNull(j, 'occurredAt'),
      );

  /// Friendly label for the event kind (subset of CrmActivityEventKind).
  String get kindLabel => switch (eventKind) {
        1 => 'Comment',
        2 => 'Stage changed',
        3 => 'Deal created',
        4 => 'Assignment',
        5 => 'Task completed',
        6 => 'Signal',
        7 => 'Field edited',
        16 => 'Task created',
        17 => 'Call',
        18 => 'Meeting',
        19 => 'Note',
        20 => 'Created',
        21 => 'Updated',
        22 => 'Deleted',
        _ => 'Activity',
      };
}

typedef ActivityKey = ({int kind, String id});

/// GET /v1/crm/timeline/{kind}/{entityId} — newest-first activity for one record.
final activityTimelineProvider =
    FutureProvider.autoDispose.family<List<ActivityEvent>, ActivityKey>((ref, key) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get('/v1/crm/timeline/${key.kind}/${key.id}', queryParameters: {'page': 1, 'pageSize': 30});
  if (res.statusCode == 200 && res.data is Map) {
    return listOr(Map<String, dynamic>.from(res.data), 'items')
        .whereType<Map<String, dynamic>>()
        .map(ActivityEvent.fromJson)
        .toList();
  }
  return const [];
});
