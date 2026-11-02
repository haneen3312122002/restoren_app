import 'package:flutter/material.dart';

// Product image from a link. If the link is empty or broken, shows a placeholder instead of an error icon.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const _Placeholder();
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const _Placeholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _Placeholder(loading: true),
    );
  }
}

// The placeholder image.
class _Placeholder extends StatelessWidget {
  const _Placeholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.restaurant, size: 36, color: scheme.outline),
      ),
    );
  }
}
