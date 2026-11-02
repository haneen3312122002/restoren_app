import 'package:equatable/equatable.dart';

/// Order statuses in order (same as the server).
enum OrderStatus {
  pending('Pending'),
  preparing('Preparing'),
  ready('Ready'),
  delivered('Delivered');

  const OrderStatus(this.apiValue);

  /// The value as text, the way the server sends it.
  final String apiValue;

  /// The next status, or null if Delivered (the last step).
  OrderStatus? get next => index + 1 < OrderStatus.values.length ? OrderStatus.values[index + 1] : null;

  /// Is the order finished?
  bool get isFinal => this == OrderStatus.delivered;

  /// Turns the text from the server into the enum.
  static OrderStatus fromApi(String value) =>
      OrderStatus.values.firstWhere((s) => s.apiValue == value, orElse: () => OrderStatus.pending);
}

/// Order type: eat in or take away.
enum OrderType {
  dineIn('DineIn', 'Dine-in'),
  takeaway('Takeaway', 'Takeaway');

  const OrderType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Turns the text from the server into the enum.
  static OrderType fromApi(String value) =>
      OrderType.values.firstWhere((t) => t.apiValue == value, orElse: () => OrderType.dineIn);
}

/// One order line as the server saved it (copy of name and price).
class OrderLine extends Equatable {
  const OrderLine({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  @override
  List<Object?> get props => [productName, quantity, unitPrice, lineTotal];
}

/// The order as the customer sees it (no personal data).
class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.orderType,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  final int id;
  final OrderStatus status;
  final OrderType orderType;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderLine> items;

  @override
  List<Object?> get props => [id, status, orderType, total, createdAt, updatedAt, items];
}

/// The order as the admin sees it (with customer info).
class AdminOrder extends Order {
  const AdminOrder({
    required super.id,
    required super.status,
    required super.orderType,
    required super.total,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
    required this.customerName,
    required this.customerPhone,
    this.notes,
  });

  final String customerName;
  final String customerPhone;
  final String? notes;

  @override
  List<Object?> get props => [...super.props, customerName, customerPhone, notes];
}
