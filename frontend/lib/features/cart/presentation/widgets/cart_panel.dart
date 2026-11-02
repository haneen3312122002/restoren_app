import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';

/// Cart content. The same widget shows as a side panel on a laptop and as a drawer on a phone.
class CartPanel extends ConsumerWidget {
  const CartPanel({super.key, this.onCheckout});

  /// Called before going to checkout (for example to close the drawer).
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartViewModelProvider);
    final total = ref.watch(cartTotalProvider);
    final cart = ref.read(cartViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
          child: Row(
            children: [
              Expanded(child: Text('Your cart', style: theme.textTheme.titleLarge)),
              if (items.isNotEmpty)
                TextButton.icon(
                  onPressed: cart.clear,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? const EmptyView(message: 'Your cart is empty', icon: Icons.shopping_cart_outlined)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) => _CartLine(item: items[index]),
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Total', style: theme.textTheme.titleMedium)),
                  Text(Formatters.price(total), style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                // Disabled when the cart is empty
                onPressed: items.isEmpty
                    ? null
                    : () {
                        onCheckout?.call();
                        context.go('/checkout');
                      },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Checkout'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One cart line: name, quantity with + and − buttons, line total, and a remove button.
class _CartLine extends ConsumerWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(Formatters.price(item.lineTotal), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease',
            onPressed: () => cart.decrement(item.productId),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 28,
            child: Text('${item.quantity}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ),
          IconButton(
            tooltip: 'Increase',
            onPressed: item.quantity >= CartItem.maxQuantity ? null : () => cart.increment(item.productId),
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => cart.remove(item.productId),
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }
}
