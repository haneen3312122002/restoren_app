import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';

/// Color for each status (used in tracking and the admin dashboard).
Color statusColor(OrderStatus status) => switch (status) {
      OrderStatus.pending => const Color(0xFFF59F00),
      OrderStatus.preparing => const Color(0xFF1C7ED6),
      OrderStatus.ready => const Color(0xFF7048E8),
      OrderStatus.delivered => const Color(0xFF2F9E44),
    };

/// A colored badge with the status name.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.apiValue,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Progress bar: 4 connected circles, the current step is highlighted.
/// On narrow screens the labels get smaller to avoid overflow.
class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.current});

  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = OrderStatus.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final circle = compact ? 30.0 : 40.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _connector(theme, visible: i > 0, done: i <= current.index)),
                        _circle(theme, steps[i], i, circle),
                        Expanded(child: _connector(theme, visible: i < steps.length - 1, done: i < current.index)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[i].apiValue,
                      textAlign: TextAlign.center,
                      style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelLarge)?.copyWith(
                        fontWeight: i == current.index ? FontWeight.w700 : FontWeight.w400,
                        color: i <= current.index ? theme.colorScheme.onSurface : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Step circle: done ✓, current is colored, next ones are grey.
  Widget _circle(ThemeData theme, OrderStatus step, int index, double size) {
    final isDone = index < current.index || (current.isFinal && index == current.index);
    final isCurrent = index == current.index;
    final color = index <= current.index ? statusColor(current) : theme.colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index <= current.index ? color : theme.colorScheme.surface,
        border: Border.all(color: color, width: 2),
        boxShadow: isCurrent && !current.isFinal
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Icon(
        isDone ? Icons.check : _icon(step),
        size: size * 0.55,
        color: index <= current.index ? Colors.white : theme.colorScheme.outline,
      ),
    );
  }

  /// The line between the circles.
  Widget _connector(ThemeData theme, {required bool visible, required bool done}) {
    if (!visible) return const SizedBox.shrink();
    return Container(height: 3, color: done ? statusColor(current) : theme.colorScheme.outlineVariant);
  }

  /// The icon for each step.
  IconData _icon(OrderStatus step) => switch (step) {
        OrderStatus.pending => Icons.receipt_long,
        OrderStatus.preparing => Icons.soup_kitchen,
        OrderStatus.ready => Icons.room_service,
        OrderStatus.delivered => Icons.done_all,
      };
}

/// List of order items with the total.
class OrderLinesList extends StatelessWidget {
  const OrderLinesList({super.key, required this.lines, required this.total});

  final List<OrderLine> lines;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text('${line.quantity}×', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: Text(line.productName)),
                Text(Formatters.price(line.lineTotal)),
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
      ],
    );
  }
}

/// A wrapper that limits the content width and centers it (for pages with a form).
class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}
