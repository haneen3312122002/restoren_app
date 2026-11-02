import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/widgets/order_widgets.dart';
import '../providers/admin_providers.dart';

/// "Orders" tab: one card per order, refreshes by itself every 5 seconds.
class OrdersTab extends ConsumerWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminOrdersProvider);
    final showDelivered = ref.watch(showDeliveredProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  orders.hasValue ? '${orders.value!.length} orders' : 'Orders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Text('Show delivered'),
              const SizedBox(width: 8),
              Switch(
                value: showDelivered,
                onChanged: (v) => ref.read(showDeliveredProvider.notifier).set(v),
              ),
            ],
          ),
        ),
        Expanded(
          child: orders.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              message: error is Failure ? error.message : 'Could not load orders.',
              onRetry: () => ref.invalidate(adminOrdersProvider),
            ),
            data: (list) => list.isEmpty
                ? const EmptyView(message: 'No orders right now', icon: Icons.receipt_long_outlined)
                : _OrdersGrid(orders: list),
          ),
        ),
      ],
    );
  }
}

/// Cards in a Wrap. The number of columns depends on the width from LayoutBuilder.
class _OrdersGrid extends StatelessWidget {
  const _OrdersGrid({required this.orders});

  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 16.0;
        final width = constraints.maxWidth - padding * 2;
        final columns = width < 600 ? 1 : (width < 1000 ? 2 : 3);
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(padding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final order in orders) SizedBox(width: cardWidth, child: _AdminOrderCard(order: order)),
            ],
          ),
        );
      },
    );
  }
}

/// Order card: number, colored status, type, time, customer, items, notes, total, and the next step button.
class _AdminOrderCard extends ConsumerWidget {
  const _AdminOrderCard({required this.order});

  final AdminOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUpdating = ref.watch(orderStatusUpdaterProvider).contains(order.id);
    final next = order.status.next;

    return Card(
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: statusColor(order.status), width: 5))),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('#${order.id}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                StatusChip(status: order.status),
                const Spacer(),
                Icon(order.orderType == OrderType.dineIn ? Icons.restaurant : Icons.shopping_bag, size: 18),
                const SizedBox(width: 4),
                Text(order.orderType.label),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.time(order.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(order.customerName, style: theme.textTheme.titleSmall)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18),
                const SizedBox(width: 6),
                SelectableText(order.customerPhone),
              ],
            ),
            const SizedBox(height: 12),
            OrderLinesList(lines: order.items, total: order.total),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Note: ${order.notes}'),
              ),
            ],
            // A delivered order has no button
            if (next != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: isUpdating ? null : () => _advance(context, ref),
                style: FilledButton.styleFrom(backgroundColor: statusColor(next), minimumSize: const Size.fromHeight(44)),
                icon: isUpdating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward),
                label: Text('Move to ${next.apiValue}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Moves the order to the next step. If it fails, shows the server message in a snackbar and the card stays.
  Future<void> _advance(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(orderStatusUpdaterProvider.notifier).advance(order);
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }
}
