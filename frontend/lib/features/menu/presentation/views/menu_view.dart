import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/breakpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';
import '../../../cart/presentation/widgets/cart_panel.dart';
import '../../domain/entities/menu_category.dart';
import '../providers/menu_providers.dart';
import '../widgets/category_bar.dart';
import '../widgets/product_card.dart';

/// The home page (/): menu + cart.
///
/// LayoutBuilder decides the layout:
/// - laptop (≥ 900): the cart is a fixed side panel.
/// - phone: the cart is a drawer opened from an icon with a badge.
class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: const _AppTitle(),
            actions: [
              IconButton(
                tooltip: 'Track order',
                onPressed: () => context.go('/track'),
                icon: const Icon(Icons.receipt_long_outlined),
              ),
              IconButton(
                tooltip: 'Admin',
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
              if (!isDesktop)
                Builder(
                  builder: (context) => CartIconButton(onPressed: () => Scaffold.of(context).openEndDrawer()),
                ),
              const SizedBox(width: 8),
            ],
          ),
          endDrawer: isDesktop
              ? null
              : Drawer(
                  width: math.min(constraints.maxWidth * 0.9, 400),
                  child: SafeArea(
                    child: Builder(
                      builder: (context) => CartPanel(onCheckout: () => Navigator.of(context).pop()),
                    ),
                  ),
                ),
          body: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: _MenuBody()),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 380,
                      child: Material(color: Theme.of(context).colorScheme.surface, child: const CartPanel()),
                    ),
                  ],
                )
              : const _MenuBody(),
        );
      },
    );
  }
}

/// App title in the AppBar.
class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text('Restoren', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Menu content with loading, error and empty states.
class _MenuBody extends ConsumerWidget {
  const _MenuBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);

    return menu.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: error is Failure ? error.message : 'Could not load the menu.',
        onRetry: () => ref.invalidate(menuProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const EmptyView(message: 'No available items', icon: Icons.no_food_outlined);
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(menuProvider.future),
          child: _MenuGrid(categories: categories),
        );
      },
    );
  }
}

/// The grid: one column on a phone, 2 or 3 on bigger screens.
/// "All" shows every category with titles; one category shows only its products, without a new request.
class _MenuGrid extends ConsumerWidget {
  const _MenuGrid({required this.categories});

  final List<MenuCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final visible = selected == null ? categories : categories.where((c) => c.id == selected).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 16.0;
        final columns = Breakpoints.gridColumns(constraints.maxWidth);
        final cardWidth = (constraints.maxWidth - padding * 2 - spacing * (columns - 1)) / columns;
        final imageHeight = math.min(cardWidth * 0.6, 220.0);
        final cardHeight = imageHeight + 175;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: CategoryBar(categories: categories)),
            for (final category in visible) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(padding, 12, padding, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(category.name, style: Theme.of(context).textTheme.headlineSmall),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent: cardHeight,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: category.products[index], imageHeight: imageHeight),
                    childCount: category.products.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}
