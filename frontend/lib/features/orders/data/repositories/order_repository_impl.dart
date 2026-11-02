import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/new_order.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

/// [OrderRepository] implementation using the API.
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<Result<Order>> createOrder(NewOrder order) => ApiErrorMapper.guard(() => _remote.createOrder(order));

  @override
  Future<Result<Order>> getOrder(int id) => ApiErrorMapper.guard(() => _remote.getOrder(id));
}
