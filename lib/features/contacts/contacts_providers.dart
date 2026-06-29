import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import 'contact_model.dart';

class ContactsRepository {
  ContactsRepository(this._api);
  final ApiClient _api;

  Future<Paged<Contact>> list({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _api.dio.get('/v1/crm/contacts', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    if (res.statusCode == 200 && res.data is Map) {
      return Paged.fromJson(Map<String, dynamic>.from(res.data), Contact.fromJson);
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed to load contacts');
  }

  Future<Contact> getById(String id) async {
    final res = await _api.dio.get('/v1/crm/contacts/$id');
    if (res.statusCode == 200 && res.data is Map) {
      return Contact.fromJson(Map<String, dynamic>.from(res.data));
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Contact not found');
  }
}

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) => ContactsRepository(ref.read(apiClientProvider)));
final contactsSearchProvider = StateProvider<String>((ref) => '');
final contactsListProvider = FutureProvider.autoDispose<Paged<Contact>>((ref) async {
  final search = ref.watch(contactsSearchProvider);
  return ref.read(contactsRepositoryProvider).list(search: search);
});
final contactDetailProvider = FutureProvider.autoDispose.family<Contact, String>(
    (ref, id) => ref.read(contactsRepositoryProvider).getById(id));
