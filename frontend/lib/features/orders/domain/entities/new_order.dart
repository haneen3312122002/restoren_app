import 'order.dart';

/// A new order before sending it. Only product id and quantity, no price or total.
class NewOrder {
  const NewOrder({
    required this.customerName,
    required this.customerPhone,
    required this.orderType,
    required this.items,
    this.notes,
  });

  final String customerName;
  final String customerPhone;
  final OrderType orderType;
  final String? notes;
  final List<NewOrderItem> items;
}

/// One item in the new order.
class NewOrderItem {
  const NewOrderItem({required this.productId, required this.quantity});

  final int productId;
  final int quantity;
}
