import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import 'lead_model.dart';

class LeadsRepository {
  LeadsRepository(this._api);
  final ApiClient _api;

  /// GET /v1/crm/leads — paged, optional search + stage filter.
  Future<Paged<Lead>> list({int page = 1, int pageSize = 20, String? search, LeadStage? stage}) async {
    final res = await _api.dio.get('/v1/crm/leads', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (stage != null && stage != LeadStage.unknown) 'stage': stage.raw,
    });
    if (res.statusCode == 200 && res.data is Map) {
      return Paged.fromJson(Map<String, dynamic>.from(res.data), Lead.fromJson);
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed to load leads');
  }

  /// GET /v1/crm/leads/{id}
  Future<Lead> getById(String id) async {
    final res = await _api.dio.get('/v1/crm/leads/$id');
    if (res.statusCode == 200 && res.data is Map) {
      return Lead.fromJson(Map<String, dynamic>.from(res.data));
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Lead not found');
  }

  /// PUT /v1/crm/leads/{id}/stage
  Future<void> updateStage(String id, LeadStage stage) async {
    await _api.dio.put('/v1/crm/leads/$id/stage', data: {'stage': stage.raw});
  }
}
