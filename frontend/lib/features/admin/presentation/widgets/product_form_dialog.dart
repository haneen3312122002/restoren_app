import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/breakpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/admin_entities.dart';
import '../providers/admin_providers.dart';

/// Opens the product form: full screen on a phone, a centered dialog on a laptop.
/// Returns true if the product was saved.
Future<bool?> showProductFormDialog(BuildContext context, {AdminProduct? product}) {
  final isDesktop = Breakpoints.isDesktop(MediaQuery.sizeOf(context).width);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => isDesktop
        ? Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
              child: ProductForm(product: product),
            ),
          )
        : Dialog.fullscreen(child: ProductForm(product: product)),
  );
}

/// The same form for add and edit. Ingredients are comma separated.
class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({super.key, this.product});

  /// null = adding a new product.
  final AdminProduct? product;

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _ingredients;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  int? _categoryId;
  late bool _isAvailable;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name);
    _description = TextEditingController(text: p?.description);
    _ingredients = TextEditingController(text: p?.ingredients.join(', '));
    _price = TextEditingController(text: p?.price.toStringAsFixed(2));
    _imageUrl = TextEditingController(text: p?.imageUrl);
    _categoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _ingredients.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  /// Checks the form and saves, and closes the dialog if it worked.
  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final draft = ProductDraft(
      name: _name.text,
      description: _description.text,
      ingredients: Validators.parseIngredients(_ingredients.text),
      price: _price.text,
      imageUrl: _imageUrl.text,
      categoryId: _categoryId!,
      isAvailable: _isAvailable,
    );

    final vm = ref.read(adminMenuViewModelProvider.notifier);
    final error = _isEdit ? await vm.update(widget.product!.id, draft) : await vm.create(draft);

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(adminCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_isEdit ? 'Edit product' : 'Add product'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
      ),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e is Failure ? e.message : 'Could not load categories.',
          onRetry: () => ref.invalidate(adminCategoriesProvider),
        ),
        data: (list) => _buildForm(list),
      ),
    );
  }

  /// The form itself.
  Widget _buildForm(List<Category> categories) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            maxLength: 120,
            validator: Validators.productName,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: categories.any((c) => c.id == _categoryId) ? _categoryId : null,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
            onChanged: (v) => setState(() => _categoryId = v),
            validator: (v) => v == null ? 'Choose a category.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _price,
            decoration: const InputDecoration(labelText: 'Price', suffixText: 'JD'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.price,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
            maxLines: 3,
            maxLength: 500,
            validator: Validators.description,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ingredients,
            decoration: const InputDecoration(
              labelText: 'Ingredients (optional)',
              helperText: 'Separate with commas, e.g. Beef, Cheese, Tomato',
            ),
            validator: Validators.ingredients,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _imageUrl,
            decoration: const InputDecoration(labelText: 'Image URL (optional)', hintText: 'https://...'),
            keyboardType: TextInputType.url,
            validator: Validators.imageUrl,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available on the menu'),
            value: _isAvailable,
            onChanged: (v) => setState(() => _isAvailable = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Text(_isEdit ? 'Save changes' : 'Add product'),
          ),
        ],
      ),
    );
  }
}
