import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/auth_models.dart';
import 'auth/auth_repository.dart';
import 'auth/auth_storage.dart';
import 'network/api_client.dart';

/// ── Infrastructure singletons ──
final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(ref.read(authStorageProvider));
  client.onUnauthorized = () => ref.read(authControllerProvider.notifier).onSessionLost();
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiClientProvider), ref.read(authStorageProvider)),
);

/// ── Auth state ──
sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  final String? error;
  const AuthUnauthenticated([this.error]);
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthLoading();
  }

  Future<void> _bootstrap() async {
    final hasSession = await ref.read(authStorageProvider).hasSession;
    // We keep the token but have no cached user; treat presence of a token as
    // authenticated with a minimal user (profile can be fetched lazily later).
    if (hasSession) {
      final tenantId = await ref.read(authStorageProvider).tenantId ?? '';
      state = AuthAuthenticated(AppUser(id: '', tenantId: tenantId));
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final res = await ref.read(authRepositoryProvider).login(email, password);
      state = AuthAuthenticated(res.user);
    } on AuthException catch (e) {
      state = AuthUnauthenticated(e.message);
    } catch (_) {
      state = const AuthUnauthenticated('Could not reach the server. Check your connection.');
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthUnauthenticated();
  }

  void onSessionLost() {
    state = const AuthUnauthenticated('Your session expired. Please sign in again.');
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
