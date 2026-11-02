import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/menu_category.dart';
import '../providers/menu_providers.dart';

/// Category bar: an "All" button and one button per category, the selected one is highlighted.
class CategoryBar extends ConsumerWidget {
  const CategoryBar({super.key, required this.categories});

  final List<MenuCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final notifier = ref.read(selectedCategoryProvider.notifier);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip(context, label: 'All', isSelected: selected == null, onTap: () => notifier.select(null)),
          for (final c in categories)
            _chip(context, label: c.name, isSelected: selected == c.id, onTap: () => notifier.select(c.id)),
        ],
      ),
    );
  }

  /// One category button.
  Widget _chip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }
}
