import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Thin wrapper over flutter_secure_storage for the JWT pair + active tenant.
class AuthStorage {
  AuthStorage([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  Future<void> save({required String accessToken, required String refreshToken, required String tenantId}) async {
    await _s.write(key: AppConfig.kAccessToken, value: accessToken);
    await _s.write(key: AppConfig.kRefreshToken, value: refreshToken);
    await _s.write(key: AppConfig.kTenantId, value: tenantId);
  }

  Future<String?> get accessToken => _s.read(key: AppConfig.kAccessToken);
  Future<String?> get refreshToken => _s.read(key: AppConfig.kRefreshToken);
  Future<String?> get tenantId => _s.read(key: AppConfig.kTenantId);

  Future<bool> get hasSession async => (await accessToken)?.isNotEmpty ?? false;

  Future<void> clear() async {
    await _s.delete(key: AppConfig.kAccessToken);
    await _s.delete(key: AppConfig.kRefreshToken);
    await _s.delete(key: AppConfig.kTenantId);
  }
}
