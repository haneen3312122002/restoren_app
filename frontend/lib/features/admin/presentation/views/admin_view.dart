import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../widgets/login_form.dart';
import '../widgets/menu_tab.dart';
import '../widgets/orders_tab.dart';

/// The admin page (/admin): the login form if there's no token, otherwise the dashboard with two tabs.
class AdminView extends ConsumerWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authViewModelProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        ),
        body: const LoginForm(),
      );
    }

    void logout() => ref.read(authViewModelProvider.notifier).logout();

    // On a narrow screen we hide the username and keep only the logout icon
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(wide ? 'Admin dashboard' : 'Admin'),
              leading: IconButton(
                tooltip: 'Back to menu',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              actions: [
                if (wide)
                  TextButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                    label: Text('Log out (${session.username})'),
                  )
                else
                  IconButton(tooltip: 'Log out', onPressed: logout, icon: const Icon(Icons.logout)),
                const SizedBox(width: 8),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
                  Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu management'),
                ],
              ),
            ),
            body: const TabBarView(children: [OrdersTab(), MenuTab()]),
          ),
        );
      },
    );
  }
}
