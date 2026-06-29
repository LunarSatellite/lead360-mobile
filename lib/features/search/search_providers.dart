import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../contacts/contact_model.dart';
import '../contacts/contacts_providers.dart';
import '../deals/deal_model.dart';
import '../deals/deals_providers.dart';
import '../leads/lead_model.dart';
import '../leads/leads_providers.dart';

class SearchResults {
  final List<Lead> leads;
  final List<Contact> contacts;
  final List<Deal> deals;
  const SearchResults({this.leads = const [], this.contacts = const [], this.deals = const []});
  bool get isEmpty => leads.isEmpty && contacts.isEmpty && deals.isEmpty;
}

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Fans the query out to leads + contacts + deals (5 each) in parallel.
/// Only runs for queries of 2+ chars; shorter queries return empty.
final searchResultsProvider = FutureProvider.autoDispose<SearchResults>((ref) async {
  final q = ref.watch(searchQueryProvider).trim();
  if (q.length < 2) return const SearchResults();

  final results = await Future.wait([
    ref.read(leadsRepositoryProvider).list(search: q, pageSize: 5),
    ref.read(contactsRepositoryProvider).list(search: q, pageSize: 5),
    ref.read(dealsRepositoryProvider).list(search: q, pageSize: 5),
  ]);

  return SearchResults(
    leads: (results[0].items as List).cast<Lead>(),
    contacts: (results[1].items as List).cast<Contact>(),
    deals: (results[2].items as List).cast<Deal>(),
  );
});
