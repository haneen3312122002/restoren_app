import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../domain/entities/new_order.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';

/// Checkout page state.
class CheckoutState {
  const CheckoutState({this.isSubmitting = false, this.errorMessage, this.fieldErrors = const {}});

  /// true while sending. We disable the confirm button so the order isn't sent twice.
  final bool isSubmitting;

  /// The server message if the order failed.
  final String? errorMessage;

  /// Field errors from the server.
  final Map<String, List<String>> fieldErrors;
}

final checkoutViewModelProvider =
    NotifierProvider.autoDispose<CheckoutViewModel, CheckoutState>(CheckoutViewModel.new);

/// Checkout logic.
class CheckoutViewModel extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  /// Sends the order. If it works, empties the cart and returns the order number; if not, the cart stays as it is.
  Future<int?> submit({
    required String customerName,
    required String customerPhone,
    required OrderType orderType,
    String? notes,
  }) async {
    if (state.isSubmitting) return null; // stops a double click

    final cartItems = ref.read(cartViewModelProvider);
    if (cartItems.isEmpty) return null;

    state = const CheckoutState(isSubmitting: true);

    final order = NewOrder(
      customerName: customerName,
      customerPhone: customerPhone,
      orderType: orderType,
      notes: notes,
      items: [for (final i in cartItems) NewOrderItem(productId: i.productId, quantity: i.quantity)],
    );

    final result = await ref.read(orderRepositoryProvider).createOrder(order);
    if (!ref.mounted) return null;

    switch (result) {
      case Success(:final value):
        ref.read(cartViewModelProvider.notifier).clear();
        state = const CheckoutState();
        return value.id;
      case ResultFailure(:final failure):
        state = CheckoutState(
          errorMessage: failure.message,
          fieldErrors: failure is ValidationFailure ? failure.fieldErrors : const {},
        );
        return null;
    }
  }
}
