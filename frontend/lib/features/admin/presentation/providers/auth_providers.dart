import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/datasources/session_local_data_source.dart';
import '../../data/repositories/admin_repositories_impl.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repositories.dart';

/// SharedPreferences. Created in main and passed in as an override.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

/// Admin remote data source (shared by all admin repositories).
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(ref.watch(dioProvider));
});

/// The login repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(adminRemoteDataSourceProvider),
    SessionLocalDataSource(ref.watch(sharedPreferencesProvider)),
  );
});

/// The current admin session (null = not logged in).
final authViewModelProvider = NotifierProvider<AuthViewModel, AdminSession?>(AuthViewModel.new);

/// Login and logout logic.
class AuthViewModel extends Notifier<AdminSession?> {
  /// Starts with the saved session so a page refresh doesn't log the admin out.
  @override
  AdminSession? build() => ref.read(authRepositoryProvider).loadSession();

  /// Logs in. Returns the error message if it failed, or null if it worked.
  Future<String?> login(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    switch (await repository.login(username, password)) {
      case Success(:final value):
        await repository.saveSession(value);
        state = value;
        return null;
      case ResultFailure(:final failure):
        return failure.message;
    }
  }

  /// Clears the token and goes back to the login form.
  Future<void> logout() async {
    if (state == null) return;
    state = null;
    await ref.read(authRepositoryProvider).clearSession();
  }
}
