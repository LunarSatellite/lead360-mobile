import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import 'lead_model.dart';
import 'leads_repository.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) => LeadsRepository(ref.read(apiClientProvider)));

/// Current list filters (search + stage). Kept simple for v1.
class LeadsFilter {
  final String search;
  final LeadStage? stage;
  const LeadsFilter({this.search = '', this.stage});
  LeadsFilter copyWith({String? search, LeadStage? stage, bool clearStage = false}) =>
      LeadsFilter(search: search ?? this.search, stage: clearStage ? null : (stage ?? this.stage));
}

final leadsFilterProvider = StateProvider<LeadsFilter>((ref) => const LeadsFilter());

/// First page of leads for the active filter. (Pagination/infinite-scroll = follow-up.)
final leadsListProvider = FutureProvider.autoDispose<Paged<Lead>>((ref) async {
  final filter = ref.watch(leadsFilterProvider);
  return ref.read(leadsRepositoryProvider).list(search: filter.search, stage: filter.stage);
});

final leadDetailProvider = FutureProvider.autoDispose.family<Lead, String>((ref, id) async {
  return ref.read(leadsRepositoryProvider).getById(id);
});
