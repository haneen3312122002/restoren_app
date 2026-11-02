import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../menu/presentation/providers/menu_providers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../data/repositories/admin_repositories_impl.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repositories.dart';
import 'auth_providers.dart';

// ==================== Repositories ====================

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>((ref) {
  return AdminOrdersRepositoryImpl(ref.watch(adminRemoteDataSourceProvider));
});

final adminMenuRepositoryProvider = Provider<AdminMenuRepository>((ref) {
  return AdminMenuRepositoryImpl(ref.watch(adminRemoteDataSourceProvider));
});

// ==================== Orders ====================

/// The "Show delivered" option.
final showDeliveredProvider = NotifierProvider<ShowDeliveredNotifier, bool>(ShowDeliveredNotifier.new);

/// Keeps the state of the "Show delivered" switch.
class ShowDeliveredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// The admin orders list. It refreshes by itself every 5 seconds.
/// If a refresh fails and we already have a list, we keep showing it and try again later.
final adminOrdersProvider = StreamProvider.autoDispose<List<AdminOrder>>((ref) async* {
  final includeDelivered = ref.watch(showDeliveredProvider);
  final repository = ref.watch(adminOrdersRepositoryProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);

  var hasData = false;
  while (!disposed) {
    switch (await repository.getOrders(includeDelivered: includeDelivered)) {
      case Success(:final value):
        hasData = true;
        yield value;
      case ResultFailure(:final failure):
        if (failure is AuthFailure || !hasData) throw failure;
    }
    await Future<void>.delayed(AppConfig.adminOrdersPollInterval);
  }
});

/// Ids of orders being updated right now (so we disable their button and show loading).
final orderStatusUpdaterProvider = NotifierProvider<OrderStatusUpdater, Set<int>>(OrderStatusUpdater.new);

/// Moves the order to the next step.
class OrderStatusUpdater extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  /// Returns the server error message if it failed, or null if it worked.
  Future<String?> advance(AdminOrder order) async {
    final next = order.status.next;
    if (next == null || state.contains(order.id)) return null;

    state = {...state, order.id};
    final result = await ref.read(adminOrdersRepositoryProvider).updateStatus(order.id, next);
    state = {...state}..remove(order.id);

    switch (result) {
      case Success():
        ref.invalidate(adminOrdersProvider);
        return null;
      case ResultFailure(:final failure):
        return failure.message;
    }
  }
}

// ==================== Menu ====================

/// All products (hidden ones too).
final adminProductsProvider = FutureProvider.autoDispose<List<AdminProduct>>((ref) async {
  return (await ref.watch(adminMenuRepositoryProvider).getProducts()).getOrThrow();
});

/// Categories for the dropdown.
final adminCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  return (await ref.watch(adminMenuRepositoryProvider).getCategories()).getOrThrow();
});

/// Ids of products with an action running right now.
final adminMenuViewModelProvider = NotifierProvider<AdminMenuViewModel, Set<int>>(AdminMenuViewModel.new);

/// Menu management actions. After each one we refresh the list and the customer menu.
class AdminMenuViewModel extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  /// Add a product. Returns the error message or null.
  Future<String?> create(ProductDraft draft) =>
      _run(null, () => ref.read(adminMenuRepositoryProvider).createProduct(draft));

  /// Edit a product.
  Future<String?> update(int id, ProductDraft draft) =>
      _run(id, () => ref.read(adminMenuRepositoryProvider).updateProduct(id, draft));

  /// Hide or show.
  Future<String?> setAvailability(int id, bool isAvailable) =>
      _run(id, () => ref.read(adminMenuRepositoryProvider).setAvailability(id, isAvailable));

  /// Delete.
  Future<String?> delete(int id) => _run(id, () => ref.read(adminMenuRepositoryProvider).deleteProduct(id));

  /// Runs the action, marks the product as "busy", and refreshes the lists if it worked.
  Future<String?> _run(int? id, Future<Result<Object?>> Function() action) async {
    if (id != null) state = {...state, id};
    final result = await action();
    if (id != null) state = {...state}..remove(id);

    switch (result) {
      case Success():
        ref.invalidate(adminProductsProvider);
        ref.invalidate(menuProvider);
        return null;
      case ResultFailure(:final failure):
        return failure.message;
    }
  }
}
