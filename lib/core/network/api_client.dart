import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../auth/auth_storage.dart';

/// Single Dio instance for the whole app. Attaches the bearer token + tenant
/// header from secure storage on every request, and transparently refreshes the
/// access token once on a 401 before retrying.
class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      // The API binds JSON case-insensitively; send/accept JSON.
      contentType: Headers.jsonContentType,
      validateStatus: (s) => s != null && s < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.accessToken;
        final tenantId = await _storage.tenantId;
        if (token != null && token.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';
        if (tenantId != null && tenantId.isNotEmpty) options.headers['X-Tenant-Id'] = tenantId;
        handler.next(options);
      },
      onError: (e, handler) async {
        // One refresh attempt on 401, then retry the original request.
        if (e.response?.statusCode == 401 && !_isRefreshing && e.requestOptions.path != '/v1/auth/refresh-token') {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final retried = await _retry(e.requestOptions);
            return handler.resolve(retried);
          }
          await _storage.clear();
          onUnauthorized?.call();
        }
        handler.next(e);
      },
    ));
  }

  late final Dio dio;
  final AuthStorage _storage;
  bool _isRefreshing = false;

  /// Called when refresh fails — the app should route back to login.
  void Function()? onUnauthorized;

  Future<bool> _tryRefresh() async {
    _isRefreshing = true;
    try {
      final rt = await _storage.refreshToken;
      if (rt == null || rt.isEmpty) return false;
      final res = await dio.post('/v1/auth/refresh-token', data: {'refreshToken': rt});
      final data = res.data;
      if (res.statusCode == 200 && data is Map) {
        final at = (data['accessToken'] ?? data['AccessToken'])?.toString() ?? '';
        final newRt = (data['refreshToken'] ?? data['RefreshToken'])?.toString() ?? rt;
        final tenantId = await _storage.tenantId ?? '';
        if (at.isNotEmpty) {
          await _storage.save(accessToken: at, refreshToken: newRt, tenantId: tenantId);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions o) {
    return dio.fetch(o);
  }
}
