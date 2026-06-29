import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../leads/leads_list_screen.dart';
import '../contacts/contacts_list_screen.dart';
import '../deals/deals_list_screen.dart';
import '../tasks/tasks_list_screen.dart';

/// Bottom-tab shell: Home (dashboard), Leads, Contacts, Deals, Tasks.
/// Sign-out lives in the app-bar profile menu; Search + Copilot are app-bar actions.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  static const _titles = ['Home', 'Leads', 'Contacts', 'Deals', 'Tasks'];

  /// FAB target per tab (Leads/Contacts/Deals create); null = no FAB.
  String? get _fabRoute => switch (_index) {
        1 => '/leads/new',
        2 => '/contacts/new',
        3 => '/deals/new',
        _ => null,
      };

  static const _pages = [
    DashboardScreen(),
    LeadsListScreen(),
    ContactsListScreen(),
    DealsListScreen(),
    TasksListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'Copilot',
            icon: const Icon(Icons.auto_awesome, color: AppColors.brand),
            onPressed: () => context.push('/copilot'),
          ),
          _ProfileMenu(),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: _fabRoute == null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(_fabRoute!),
              backgroundColor: AppColors.brand,
              foregroundColor: AppColors.bg,
              child: const Icon(Icons.add),
            ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Leads'),
          NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), selectedIcon: Icon(Icons.handshake), label: 'Deals'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tasks'),
        ],
      ),
    );
  }
}

class _ProfileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final name = auth is AuthAuthenticated ? auth.user.displayName : '';
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
      color: AppColors.bgCard,
      onSelected: (v) {
        if (v == 'logout') ref.read(authControllerProvider.notifier).logout();
      },
      itemBuilder: (_) => [
        if (name.isNotEmpty)
          PopupMenuItem<String>(
            enabled: false,
            child: Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout, color: AppColors.danger, size: 18),
            SizedBox(width: 10),
            Text('Sign out', style: TextStyle(color: AppColors.textPrimary)),
          ]),
        ),
      ],
    );
  }
}
