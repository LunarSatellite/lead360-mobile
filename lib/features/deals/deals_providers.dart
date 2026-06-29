import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import '../../shared/paged_list.dart';
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

  /// GET /v1/crm/deals/stages — for the create-deal stage picker.
  Future<List<DealStage>> stages() async {
    final res = await _api.dio.get('/v1/crm/deals/stages');
    final data = res.data;
    final list = data is List ? data : (data is Map ? listOr(Map<String, dynamic>.from(data), 'items') : const []);
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => DealStage(id: str(j, 'id') ?? '', name: str(j, 'name') ?? 'Stage', order: intOr(j, 'order')))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// POST /v1/crm/deals (CrmDealCreateRequest).
  Future<Deal> create({
    required String name,
    required String stageId,
    double? amount,
    String currency = 'USD',
  }) async {
    final res = await _api.dio.post('/v1/crm/deals', data: {
      'name': name,
      'stageId': stageId,
      if (amount != null) 'amount': amount,
      'currency': currency,
    });
    if ((res.statusCode == 200 || res.statusCode == 201) && res.data is Map) {
      return Deal.fromJson(Map<String, dynamic>.from(res.data));
    }
    final msg = (res.data is Map ? (res.data['message'] ?? res.data['Message']) : null)?.toString();
    throw Exception(msg ?? 'Failed to create deal');
  }
}

class DealStage {
  final String id;
  final String name;
  final int order;
  const DealStage({required this.id, required this.name, this.order = 0});
}

final dealsRepositoryProvider = Provider<DealsRepository>((ref) => DealsRepository(ref.read(apiClientProvider)));
final dealsSearchProvider = StateProvider<String>((ref) => '');

class DealsPaged extends PagedListNotifier<Deal> {
  @override
  PagedState<Deal> build() {
    ref.watch(dealsSearchProvider);
    return super.build();
  }

  @override
  Future<Paged<Deal>> fetch(int page, int pageSize) =>
      ref.read(dealsRepositoryProvider).list(page: page, pageSize: pageSize, search: ref.read(dealsSearchProvider));
}

final dealsPagedProvider = AutoDisposeNotifierProvider<DealsPaged, PagedState<Deal>>(DealsPaged.new);

final dealDetailProvider = FutureProvider.autoDispose.family<Deal, String>(
    (ref, id) => ref.read(dealsRepositoryProvider).getById(id));

final dealStagesProvider = FutureProvider.autoDispose<List<DealStage>>(
    (ref) => ref.read(dealsRepositoryProvider).stages());
