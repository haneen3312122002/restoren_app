import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/views/admin_view.dart';
import '../../features/menu/presentation/views/menu_view.dart';
import '../../features/orders/presentation/views/checkout_view.dart';
import '../../features/orders/presentation/views/track_view.dart';
import '../widgets/state_views.dart';

/// App routes:
/// - `/` menu and cart
/// - `/checkout` confirm the order
/// - `/track` enter the order number, `/track/:id` track the order
/// - `/admin` admin login and dashboard
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MenuView()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutView()),
      GoRoute(path: '/track', builder: (context, state) => const TrackLookupView()),
      GoRoute(
        path: '/track/:id',
        builder: (context, state) => TrackView(orderId: int.tryParse(state.pathParameters['id'] ?? '')),
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminView()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: EmptyView(
        message: 'This page does not exist.',
        icon: Icons.explore_off_outlined,
        action: FilledButton(onPressed: () => context.go('/'), child: const Text('Back to menu')),
      ),
    ),
  );
});
