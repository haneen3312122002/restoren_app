import 'package:dio/dio.dart';

import '../../domain/entities/new_order.dart';
import '../../domain/entities/order.dart';
import '../models/order_models.dart';

/// Calls the API for customer orders.
class OrderRemoteDataSource {
  const OrderRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /api/orders
  Future<Order> createOrder(NewOrder order) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/orders', data: OrderModels.newOrderToJson(order));
    return OrderModels.orderFromJson(response.data!);
  }

  /// GET /api/orders/{id}
  Future<Order> getOrder(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/orders/$id');
    return OrderModels.orderFromJson(response.data!);
  }
}
