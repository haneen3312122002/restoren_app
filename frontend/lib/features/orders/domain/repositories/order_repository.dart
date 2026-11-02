import '../../../../core/utils/result.dart';
import '../entities/new_order.dart';
import '../entities/order.dart';

/// Customer orders.
abstract class OrderRepository {
  /// Sends the order and returns the saved order with its number and total from the server.
  Future<Result<Order>> createOrder(NewOrder order);

  /// Gets the order status by its number.
  Future<Result<Order>> getOrder(int id);
}
