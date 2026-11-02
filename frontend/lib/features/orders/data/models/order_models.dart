import '../../domain/entities/new_order.dart';
import '../../domain/entities/order.dart';

/// JSON conversions for orders.
class OrderModels {
  const OrderModels._();

  /// Customer order from JSON.
  static Order orderFromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        status: OrderStatus.fromApi(json['status'] as String),
        orderType: OrderType.fromApi(json['orderType'] as String),
        total: (json['total'] as num).toDouble(),
        createdAt: _utc(json['createdAt'] as String),
        updatedAt: _utc(json['updatedAt'] as String),
        items: _lines(json['items']),
      );

  /// Admin order from JSON (with customer info).
  static AdminOrder adminOrderFromJson(Map<String, dynamic> json) => AdminOrder(
        id: json['id'] as int,
        status: OrderStatus.fromApi(json['status'] as String),
        orderType: OrderType.fromApi(json['orderType'] as String),
        total: (json['total'] as num).toDouble(),
        createdAt: _utc(json['createdAt'] as String),
        updatedAt: _utc(json['updatedAt'] as String),
        items: _lines(json['items']),
        customerName: json['customerName'] as String? ?? '',
        customerPhone: json['customerPhone'] as String? ?? '',
        notes: json['notes'] as String?,
      );

  /// New order to JSON. Only productId and quantity.
  static Map<String, dynamic> newOrderToJson(NewOrder order) => {
        'customerName': order.customerName.trim(),
        'customerPhone': order.customerPhone.trim(),
        'orderType': order.orderType.apiValue,
        if (order.notes != null && order.notes!.trim().isNotEmpty) 'notes': order.notes!.trim(),
        'items': [
          for (final i in order.items) {'productId': i.productId, 'quantity': i.quantity},
        ],
      };

  /// The server saves times in UTC, but dates read back from SQL Server come without
  /// the "Z" at the end, so Dart would think they are local time. Add the Z if it's missing.
  static DateTime _utc(String value) => DateTime.parse(value.endsWith('Z') ? value : '${value}Z');

  /// Order lines.
  static List<OrderLine> _lines(dynamic items) => (items as List? ?? const [])
      .map((e) => e as Map<String, dynamic>)
      .map((e) => OrderLine(
            productName: e['productName'] as String? ?? '',
            quantity: e['quantity'] as int,
            unitPrice: (e['unitPrice'] as num).toDouble(),
            lineTotal: (e['lineTotal'] as num).toDouble(),
          ))
      .toList();
}
