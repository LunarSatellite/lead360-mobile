import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import 'deal_model.dart';

class DealsRepository {
  DealsRepository(this._api);
  final ApiClient _api;

  Future<Paged<Deal>> list({int page = 1, int pageSize = 20, String? search}) async {
    final res = await _api.dio.get('/v1/crm/deals', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    if (res.statusCode == 200 && res.data is Map) {
      return Paged.fromJson(Map<String, dynamic>.from(res.data), Deal.fromJson);
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed to load deals');
  }

  Future<Deal> getById(String id) async {
    final res = await _api.dio.get('/v1/crm/deals/$id');
    if (res.statusCode == 200 && res.data is Map) {
      return Deal.fromJson(Map<String, dynamic>.from(res.data));
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Deal not found');
  }
}

final dealsRepositoryProvider = Provider<DealsRepository>((ref) => DealsRepository(ref.read(apiClientProvider)));
final dealsSearchProvider = StateProvider<String>((ref) => '');
final dealsListProvider = FutureProvider.autoDispose<Paged<Deal>>((ref) async {
  final search = ref.watch(dealsSearchProvider);
  return ref.read(dealsRepositoryProvider).list(search: search);
});
final dealDetailProvider = FutureProvider.autoDispose.family<Deal, String>(
    (ref, id) => ref.read(dealsRepositoryProvider).getById(id));
