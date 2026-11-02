import '../../../../core/utils/result.dart';
import '../../../orders/domain/entities/order.dart';
import '../entities/admin_entities.dart';

// Admin login and saving the session.
abstract class AuthRepository {
  /// Logs in and returns the session.
  Future<Result<AdminSession>> login(String username, String password);

  /// The saved session (if there is one and it hasn't expired).
  AdminSession? loadSession();

  /// Saves the session so a page refresh doesn't log the admin out.
  Future<void> saveSession(AdminSession session);

  /// Clears the session.
  Future<void> clearSession();
}

/// Order management.
abstract class AdminOrdersRepository {
  /// Orders that aren't delivered yet (plus the latest delivered ones if [includeDelivered]).
  Future<Result<List<AdminOrder>>> getOrders({required bool includeDelivered});

  /// Moves the order to [status].
  Future<Result<AdminOrder>> updateStatus(int orderId, OrderStatus status);
}

/// Menu management.
abstract class AdminMenuRepository {
  Future<Result<List<AdminProduct>>> getProducts();
  Future<Result<List<Category>>> getCategories();
  Future<Result<AdminProduct>> createProduct(ProductDraft draft);
  Future<Result<AdminProduct>> updateProduct(int id, ProductDraft draft);
  Future<Result<AdminProduct>> setAvailability(int id, bool isAvailable);
  Future<Result<void>> deleteProduct(int id);
}
