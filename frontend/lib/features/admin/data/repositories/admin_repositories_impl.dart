import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repositories.dart';
import '../datasources/admin_remote_data_source.dart';
import '../datasources/session_local_data_source.dart';

/// [AuthRepository] implementation: login from the API, session from local storage.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AdminRemoteDataSource _remote;
  final SessionLocalDataSource _local;

  @override
  Future<Result<AdminSession>> login(String username, String password) =>
      ApiErrorMapper.guard(() => _remote.login(username, password));

  @override
  AdminSession? loadSession() {
    final session = _local.read();
    return (session == null || session.isExpired) ? null : session;
  }

  @override
  Future<void> saveSession(AdminSession session) => _local.write(session);

  @override
  Future<void> clearSession() => _local.clear();
}

/// [AdminOrdersRepository] implementation using the API.
class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  const AdminOrdersRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<Result<List<AdminOrder>>> getOrders({required bool includeDelivered}) =>
      ApiErrorMapper.guard(() => _remote.getOrders(includeDelivered: includeDelivered));

  @override
  Future<Result<AdminOrder>> updateStatus(int orderId, OrderStatus status) =>
      ApiErrorMapper.guard(() => _remote.updateStatus(orderId, status));
}

/// [AdminMenuRepository] implementation using the API.
class AdminMenuRepositoryImpl implements AdminMenuRepository {
  const AdminMenuRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<Result<List<AdminProduct>>> getProducts() => ApiErrorMapper.guard(_remote.getProducts);

  @override
  Future<Result<List<Category>>> getCategories() => ApiErrorMapper.guard(_remote.getCategories);

  @override
  Future<Result<AdminProduct>> createProduct(ProductDraft draft) =>
      ApiErrorMapper.guard(() => _remote.createProduct(draft));

  @override
  Future<Result<AdminProduct>> updateProduct(int id, ProductDraft draft) =>
      ApiErrorMapper.guard(() => _remote.updateProduct(id, draft));

  @override
  Future<Result<AdminProduct>> setAvailability(int id, bool isAvailable) =>
      ApiErrorMapper.guard(() => _remote.setAvailability(id, isAvailable));

  @override
  Future<Result<void>> deleteProduct(int id) => ApiErrorMapper.guard(() => _remote.deleteProduct(id));
}
