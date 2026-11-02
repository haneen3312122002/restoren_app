import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/providers/auth_providers.dart';

/// Starting point: set up local storage (for the admin session), then run the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      // Turn off automatic retry: the UI has a Retry button and polling tries again by itself.
      retry: (retryCount, error) => null,
      child: const RestorenApp(),
    ),
  );
}

/// The root widget of the app.
class RestorenApp extends ConsumerWidget {
  const RestorenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Restoren',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
