import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/breakpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../domain/entities/order.dart';
import '../viewmodels/checkout_viewmodel.dart';
import '../widgets/order_widgets.dart';

/// Checkout page (/checkout).
///
/// LayoutBuilder: on a laptop the form and summary are side by side, on a phone the summary is on top.
class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  OrderType _orderType = OrderType.dineIn;

  /// After the first submit, the errors update while typing.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Checks the form and sends the order. If it works, goes to the tracking page.
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    final orderId = await ref.read(checkoutViewModelProvider.notifier).submit(
          customerName: _name.text,
          customerPhone: _phone.text,
          orderType: _orderType,
          notes: _notes.text,
        );

    if (!mounted) return;
    if (orderId != null) {
      context.go('/track/$orderId');
    } else {
      final message = ref.read(checkoutViewModelProvider).errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartViewModelProvider);
    final state = ref.watch(checkoutViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          tooltip: 'Back to menu',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: items.isEmpty && !state.isSubmitting
          ? EmptyView(
              message: 'Your cart is empty',
              icon: Icons.shopping_cart_outlined,
              action: FilledButton(onPressed: () => context.go('/'), child: const Text('Back to menu')),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
                final summary = _OrderSummary();
                final form = _buildForm(state);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: CenteredContent(
                    maxWidth: isDesktop ? 1000 : Breakpoints.formMaxWidth,
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: form),
                              const SizedBox(width: 24),
                              SizedBox(width: 360, child: summary),
                            ],
                          )
                        : Column(children: [summary, const SizedBox(height: 16), form]),
                  ),
                );
              },
            ),
    );
  }

  /// Customer details form.
  Widget _buildForm(CheckoutState state) {
    final theme = Theme.of(context);
    String? serverError(String field) => state.fieldErrors[field]?.join('\n');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: 'Name', errorText: serverError('CustomerName')),
                textInputAction: TextInputAction.next,
                maxLength: 100,
                validator: Validators.customerName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: '+962 79 123 4567',
                  errorText: serverError('CustomerPhone'),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              Text('Order type', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<OrderType>(
                segments: const [
                  ButtonSegment(value: OrderType.dineIn, label: Text('Dine-in'), icon: Icon(Icons.restaurant)),
                  ButtonSegment(value: OrderType.takeaway, label: Text('Takeaway'), icon: Icon(Icons.shopping_bag)),
                ],
                selected: {_orderType},
                onSelectionChanged: (s) => setState(() => _orderType = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: 'Notes (optional)', errorText: serverError('Notes')),
                maxLines: 3,
                maxLength: 300,
                validator: Validators.notes,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(state.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                // Disabled while sending so the order isn't sent twice
                onPressed: state.isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: state.isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Confirm order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Order summary (display only, the server calculates the real total).
class _OrderSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartViewModelProvider);
    final total = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}×', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name)),
                    Text(Formatters.price(item.lineTotal)),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                Expanded(child: Text('Total', style: theme.textTheme.titleMedium)),
                Text(Formatters.price(total), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'The final total is confirmed by the restaurant.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
