import 'package:dio/dio.dart';

import '../../../orders/data/models/order_models.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_entities.dart';
import '../models/admin_models.dart';

/// Calls the admin endpoints of the API (the interceptor adds the token).
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._dio);

  final Dio _dio;

  // ==================== Auth ====================

  /// POST /api/auth/login
  Future<AdminSession> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'username': username.trim(), 'password': password},
    );
    return AdminModels.sessionFromJson(response.data!);
  }

  // ==================== Orders ====================

  /// GET /api/admin/orders?includeDelivered=
  Future<List<AdminOrder>> getOrders({required bool includeDelivered}) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/admin/orders',
      queryParameters: {'includeDelivered': includeDelivered},
    );
    return (response.data ?? const [])
        .map((o) => OrderModels.adminOrderFromJson(o as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/admin/orders/{id}/status
  Future<AdminOrder> updateStatus(int orderId, OrderStatus status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/admin/orders/$orderId/status',
      data: {'status': status.apiValue},
    );
    return OrderModels.adminOrderFromJson(response.data!);
  }

  // ==================== Menu ====================

  /// GET /api/admin/menu
  Future<List<AdminProduct>> getProducts() async {
    final response = await _dio.get<List<dynamic>>('/api/admin/menu');
    return (response.data ?? const []).map((p) => AdminModels.productFromJson(p as Map<String, dynamic>)).toList();
  }

  /// GET /api/admin/menu/categories
  Future<List<Category>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/api/admin/menu/categories');
    return (response.data ?? const []).map((c) => AdminModels.categoryFromJson(c as Map<String, dynamic>)).toList();
  }

  /// POST /api/admin/menu
  Future<AdminProduct> createProduct(ProductDraft draft) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/admin/menu', data: AdminModels.draftToJson(draft));
    return AdminModels.productFromJson(response.data!);
  }

  /// PUT /api/admin/menu/{id}
  Future<AdminProduct> updateProduct(int id, ProductDraft draft) async {
    final response = await _dio.put<Map<String, dynamic>>('/api/admin/menu/$id', data: AdminModels.draftToJson(draft));
    return AdminModels.productFromJson(response.data!);
  }

  /// PATCH /api/admin/menu/{id}/availability
  Future<AdminProduct> setAvailability(int id, bool isAvailable) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/admin/menu/$id/availability',
      data: {'isAvailable': isAvailable},
    );
    return AdminModels.productFromJson(response.data!);
  }

  /// DELETE /api/admin/menu/{id}
  Future<void> deleteProduct(int id) => _dio.delete<void>('/api/admin/menu/$id');
}
