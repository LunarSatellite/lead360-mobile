import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../leads/leads_list_screen.dart';
import '../contacts/contacts_list_screen.dart';
import '../deals/deals_list_screen.dart';
import '../tasks/tasks_list_screen.dart';

/// Bottom-tab shell: Leads (live), Contacts/Deals/Tasks (stubs), More.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = ['Leads', 'Contacts', 'Deals', 'Tasks', 'More'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LeadsListScreen(),
      const ContactsListScreen(),
      const DealsListScreen(),
      const TasksListScreen(),
      _MoreTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Copilot',
            icon: const Icon(Icons.auto_awesome, color: AppColors.brand),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CRM Copilot — wiring the /agent-runtime stream next.')),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Leads'),
          NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), selectedIcon: Icon(Icons.handshake), label: 'Deals'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class _MoreTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final name = auth is AuthAuthenticated ? auth.user.displayName : '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Signed in as $name', style: const TextStyle(color: AppColors.textMuted)),
          ),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.danger),
          title: const Text('Sign out', style: TextStyle(color: AppColors.textPrimary)),
          onTap: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ],
    );
  }
}
