import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/admin_entities.dart';
import '../providers/admin_providers.dart';
import 'product_form_dialog.dart';

/// "Menu management" tab: product list with add, edit, delete and hide.
class MenuTab extends ConsumerWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  products.hasValue ? '${products.value!.length} products' : 'Products',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => showProductFormDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              message: error is Failure ? error.message : 'Could not load products.',
              onRetry: () => ref.invalidate(adminProductsProvider),
            ),
            data: (list) => list.isEmpty
                ? const EmptyView(message: 'No products yet', icon: Icons.fastfood_outlined)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 720;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _ProductRow(product: list[i], wide: wide),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

/// One product row: thumbnail, name, category, price, available/hidden switch, edit, delete.
/// A hidden product shows faded and crossed out.
/// [wide]: on a wide screen everything is on one line, on a phone the buttons go on a second line.
class _ProductRow extends ConsumerWidget {
  const _ProductRow({required this.product, required this.wide});

  final AdminProduct product;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final busy = ref.watch(adminMenuViewModelProvider).contains(product.id);
    final hidden = !product.isAvailable;

    final info = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: theme.textTheme.titleSmall?.copyWith(decoration: hidden ? TextDecoration.lineThrough : null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${product.categoryName} · ${Formatters.price(product.price)}${hidden ? ' · Hidden' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (busy)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        Tooltip(
          message: product.isAvailable ? 'Visible on menu' : 'Hidden from menu',
          child: Switch(
            value: product.isAvailable,
            onChanged: busy ? null : (v) => _toggle(context, ref, v),
          ),
        ),
        IconButton(
          tooltip: 'Edit',
          onPressed: busy ? null : () => showProductFormDialog(context, product: product),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: busy ? null : () => _delete(context, ref),
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        ),
      ],
    );

    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: 56, height: 56, child: ProductImage(url: product.imageUrl)),
    );

    return Opacity(
      opacity: hidden ? 0.55 : 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: wide
              ? Row(children: [thumbnail, const SizedBox(width: 12), info, actions])
              : Column(
                  children: [
                    Row(children: [thumbnail, const SizedBox(width: 12), info]),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                ),
        ),
      ),
    );
  }

  /// Hide or show the product.
  Future<void> _toggle(BuildContext context, WidgetRef ref, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(adminMenuViewModelProvider.notifier).setAvailability(product.id, value);
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  /// Delete after a confirm dialog. The dialog suggests hiding instead.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          'Delete "${product.name}" permanently?\n\n'
          'Tip: you can hide it instead, so it disappears from the menu but can be shown again later. '
          'Old orders are not affected either way.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          if (product.isAvailable)
            TextButton(onPressed: () => Navigator.pop(context, 'hide'), child: const Text('Hide instead')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    final vm = ref.read(adminMenuViewModelProvider.notifier);
    final error = switch (choice) {
      'delete' => await vm.delete(product.id),
      'hide' => await vm.setAvailability(product.id, false),
      _ => null,
    };
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }
}
