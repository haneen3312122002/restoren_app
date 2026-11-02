import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/breakpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';
import '../widgets/order_widgets.dart';

/// Order tracking page (/track/:id). Updates by itself without a refresh.
class TrackView extends ConsumerWidget {
  const TrackView({super.key, required this.orderId});

  /// Order number from the link (null if it's not a valid number).
  final int? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orderId == null ? 'Track order' : 'Order #$orderId'),
        leading: IconButton(
          tooltip: 'Back to menu',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/track'),
            icon: const Icon(Icons.search),
            label: const Text('Another order'),
          ),
        ],
      ),
      body: orderId == null ? _notFound(context) : _TrackBody(orderId: orderId!),
    );
  }

  /// Invalid number (letters, for example).
  Widget _notFound(BuildContext context) => EmptyView(
        message: 'Order not found',
        icon: Icons.search_off,
        action: FilledButton(onPressed: () => context.go('/track'), child: const Text('Enter your order number')),
      );
}

/// Tracking content with loading and error states.
class _TrackBody extends ConsumerWidget {
  const _TrackBody({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(orderTrackingProvider(orderId));

    return tracking.when(
      skipLoadingOnRefresh: true,
      loading: () => const LoadingView(),
      error: (error, _) {
        if (error is NotFoundFailure) {
          return EmptyView(
            message: 'Order not found',
            icon: Icons.search_off,
            action: FilledButton(onPressed: () => context.go('/track'), child: const Text('Try another number')),
          );
        }
        return ErrorView(
          message: error is Failure ? error.message : 'Could not load the order.',
          onRetry: () => ref.invalidate(orderTrackingProvider(orderId)),
        );
      },
      data: (order) => _OrderDetails(order: order),
    );
  }
}

/// Order details: number and type, progress bar, items, total, and time.
class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CenteredContent(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Order #${order.id}', style: theme.textTheme.headlineSmall),
                        StatusChip(status: order.status),
                        Chip(
                          avatar: Icon(order.orderType == OrderType.dineIn ? Icons.restaurant : Icons.shopping_bag, size: 18),
                          label: Text(order.orderType.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StatusStepper(current: order.status),
                    const SizedBox(height: 20),
                    Text(
                      _statusMessage(order.status),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (!order.status.isFinal) ...[
                      const SizedBox(height: 8),
                      Text(
                        'This page updates automatically.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Items', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    OrderLinesList(lines: order.items, total: order.total),
                    const SizedBox(height: 12),
                    Text(
                      'Ordered at ${Formatters.dateTime(order.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A sentence that explains the status to the customer.
  String _statusMessage(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'We received your order.',
        OrderStatus.preparing => 'Your order is being prepared.',
        OrderStatus.ready => 'Your order is ready!',
        OrderStatus.delivered => 'Delivered. Enjoy your meal!',
      };
}

/// Page to enter the order number (/track).
class TrackLookupView extends StatefulWidget {
  const TrackLookupView({super.key});

  @override
  State<TrackLookupView> createState() => _TrackLookupViewState();
}

class _TrackLookupViewState extends State<TrackLookupView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Goes to the tracking page for the typed number.
  void _go() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go('/track/${_controller.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track order'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CenteredContent(
          maxWidth: Breakpoints.formMaxWidth,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Enter your order number', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Order number', prefixText: '#'),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) => _go(),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        return n == null || n <= 0 ? 'Enter a valid order number.' : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _go,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: const Text('Track'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
