import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import '../../shared/paged_list.dart';
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

/// Infinite-scroll leads list for the active filter.
class LeadsPaged extends PagedListNotifier<Lead> {
  @override
  PagedState<Lead> build() {
    ref.watch(leadsFilterProvider); // reset + reload when the filter changes
    return super.build();
  }

  @override
  Future<Paged<Lead>> fetch(int page, int pageSize) {
    final f = ref.read(leadsFilterProvider);
    return ref.read(leadsRepositoryProvider).list(page: page, pageSize: pageSize, search: f.search, stage: f.stage);
  }
}

final leadsPagedProvider = AutoDisposeNotifierProvider<LeadsPaged, PagedState<Lead>>(LeadsPaged.new);

final leadDetailProvider = FutureProvider.autoDispose.family<Lead, String>((ref, id) async {
  return ref.read(leadsRepositoryProvider).getById(id);
});
