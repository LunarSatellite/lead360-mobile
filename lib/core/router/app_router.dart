import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/leads/lead_detail_screen.dart';
import '../../features/contacts/contact_detail_screen.dart';
import '../../features/deals/deal_detail_screen.dart';
import '../../features/copilot/copilot_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth is AuthLoading) return null; // splash handles it
      final authed = auth is AuthAuthenticated;
      final atLogin = state.matchedLocation == '/login';
      if (!authed) return atLogin ? null : '/login';
      if (authed && (atLogin || state.matchedLocation == '/')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const _Splash()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/leads/:id', builder: (_, s) => LeadDetailScreen(leadId: s.pathParameters['id']!)),
      GoRoute(path: '/contacts/:id', builder: (_, s) => ContactDetailScreen(contactId: s.pathParameters['id']!)),
      GoRoute(path: '/deals/:id', builder: (_, s) => DealDetailScreen(dealId: s.pathParameters['id']!)),
      GoRoute(path: '/copilot', builder: (_, __) => const CopilotScreen()),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.brand)));
}

/// Bridges the Riverpod auth state into go_router's refreshListenable so the
/// redirect re-runs whenever auth changes (login/logout/session-lost).
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}
