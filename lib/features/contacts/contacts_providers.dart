import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import '../../shared/paged_list.dart';
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

  /// POST /v1/crm/contacts (CrmContactCreateRequest). allowDuplicate skips the
  /// server-side dedup 409 (offer this after the user is warned).
  Future<Contact> create({
    required String fullName,
    String? email,
    String? phone,
    String? jobTitle,
    bool allowDuplicate = false,
  }) async {
    final res = await _api.dio.post('/v1/crm/contacts', data: {
      'fullName': fullName,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (jobTitle != null && jobTitle.isNotEmpty) 'jobTitle': jobTitle,
      'allowDuplicate': allowDuplicate,
    });
    if ((res.statusCode == 200 || res.statusCode == 201) && res.data is Map) {
      return Contact.fromJson(Map<String, dynamic>.from(res.data));
    }
    final msg = (res.data is Map ? (res.data['message'] ?? res.data['Message']) : null)?.toString();
    throw Exception(msg ?? 'Failed to create contact');
  }
}

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) => ContactsRepository(ref.read(apiClientProvider)));
final contactsSearchProvider = StateProvider<String>((ref) => '');

class ContactsPaged extends PagedListNotifier<Contact> {
  @override
  PagedState<Contact> build() {
    ref.watch(contactsSearchProvider);
    return super.build();
  }

  @override
  Future<Paged<Contact>> fetch(int page, int pageSize) =>
      ref.read(contactsRepositoryProvider).list(page: page, pageSize: pageSize, search: ref.read(contactsSearchProvider));
}

final contactsPagedProvider = AutoDisposeNotifierProvider<ContactsPaged, PagedState<Contact>>(ContactsPaged.new);

final contactDetailProvider = FutureProvider.autoDispose.family<Contact, String>(
    (ref, id) => ref.read(contactsRepositoryProvider).getById(id));
