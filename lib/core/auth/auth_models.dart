import '../network/json.dart';

/// Authenticated user profile (subset of the API's UserProfileDto).
class AppUser {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final int role; // 1 Owner · 2 Admin · 3 Agent
  final String tenantId;
  final String? tenantName;

  const AppUser({
    required this.id,
    required this.tenantId,
    this.email,
    this.firstName,
    this.lastName,
    this.role = 3,
    this.tenantName,
  });

  String get displayName {
    final n = [firstName, lastName].where((s) => (s ?? '').isNotEmpty).join(' ');
    return n.isNotEmpty ? n : (email ?? 'User');
  }

  bool get isManager => role == 1 || role == 2;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: str(j, 'id') ?? '',
        email: str(j, 'email'),
        firstName: str(j, 'firstName'),
        lastName: str(j, 'lastName'),
        role: intOr(j, 'role', 3),
        tenantId: str(j, 'tenantId') ?? '',
        tenantName: str(j, 'tenantName'),
      );
}

/// Result of a successful login / refresh.
class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthResult({required this.accessToken, required this.refreshToken, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> j) {
    final userJson = (_pickMap(j, 'user')) ?? const {};
    return AuthResult(
      accessToken: str(j, 'accessToken') ?? '',
      refreshToken: str(j, 'refreshToken') ?? '',
      user: AppUser.fromJson(userJson),
    );
  }

  static Map<String, dynamic>? _pickMap(Map<String, dynamic> j, String key) {
    final v = j[key] ?? j[key[0].toUpperCase() + key.substring(1)];
    return v is Map<String, dynamic> ? v : null;
  }
}
