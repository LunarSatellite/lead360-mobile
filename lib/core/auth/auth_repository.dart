import '../network/api_client.dart';
import 'auth_models.dart';
import 'auth_storage.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final AuthStorage _storage;

  Future<AuthResult> login(String email, String password) async {
    final res = await _api.dio.post('/v1/auth/login', data: {'email': email, 'password': password});
    if (res.statusCode == 200 && res.data is Map) {
      final result = AuthResult.fromJson(Map<String, dynamic>.from(res.data));
      if (result.accessToken.isEmpty) {
        throw AuthException('Login succeeded but no token was returned. Please verify your email.');
      }
      await _storage.save(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        tenantId: result.user.tenantId,
      );
      return result;
    }
    final msg = (res.data is Map ? (res.data['message'] ?? res.data['Message']) : null)?.toString();
    throw AuthException(msg ?? 'Invalid email or password.');
  }

  Future<void> logout() async {
    final rt = await _storage.refreshToken;
    try {
      if (rt != null && rt.isNotEmpty) {
        await _api.dio.post('/v1/auth/revoke-token', data: {'refreshToken': rt});
      }
    } catch (_) {
      // best-effort — clear locally regardless
    }
    await _storage.clear();
  }
}
