/// App-wide configuration. The API base URL is provided at build time via
/// `--dart-define=API_BASE_URL=https://your-host/api` and falls back to a local
/// dev default. The backend exposes everything under `{base}/v1/...`.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api', // Android emulator → host localhost:5000
  );

  /// Secure-storage keys for the JWT pair + active tenant.
  static const String kAccessToken = 'lead360_access_token';
  static const String kRefreshToken = 'lead360_refresh_token';
  static const String kTenantId = 'lead360_tenant_id';
}
