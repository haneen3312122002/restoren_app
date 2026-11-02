// form checks. Same rules as the backend (here for a quick message, the backend is the real protection).
class Validators {
  const Validators._();

  static final RegExp _phone = RegExp(r'^\+?[0-9][0-9\s\-]{6,18}$');

  // name: required, 2 to 100 characters.
  static String? customerName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required.';
    if (v.length < 2 || v.length > 100) return 'Name must be between 2 and 100 characters.';
    return null;
  }

  // phone: digits, can start with + and have spaces or dashes.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required.';
    if (!_phone.hasMatch(v)) return 'Phone number is not valid.';
    return null;
  }

  // notes: optional, 300 characters max.
  static String? notes(String? value) {
    if ((value?.length ?? 0) > 300) return 'Notes must be at most 300 characters.';
    return null;
  }

  // product name: required, 2 to 120 characters.
  static String? productName(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2 || v.length > 120) return 'Name must be between 2 and 120 characters.';
    return null;
  }

  // description: 500 characters max.
  static String? description(String? value) {
    if ((value?.trim().length ?? 0) > 500) return 'Description must be at most 500 characters.';
    return null;
  }

  // ingredients (comma separated): 30 items max, each one 60 characters max.
  static String? ingredients(String? value) {
    final list = parseIngredients(value);
    if (list.length > 30) return 'A product can have at most 30 ingredients.';
    if (list.any((i) => i.length > 60)) return 'Each ingredient must be at most 60 characters.';
    return null;
  }

  // price: more than zero, two decimals max.
  static String? price(String? value) {
    final v = value?.trim() ?? '';
    final number = double.tryParse(v);
    if (number == null) return 'Enter a valid price.';
    if (number <= 0) return 'Price must be greater than 0.';
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v)) return 'Price can have at most two decimal places.';
    return null;
  }

  // image link: optional, but must be http or https.
  static String? imageUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final uri = Uri.tryParse(v);
    final ok = uri != null && uri.hasAuthority && (uri.scheme == 'http' || uri.scheme == 'https');
    return ok ? null : 'Image URL must be a valid http or https URL.';
  }

  // turns the ingredients text into a list: trims spaces, removes empty ones and duplicates.
  static List<String> parseIngredients(String? value) {
    final seen = <String>{};
    final result = <String>[];
    for (final part in (value ?? '').split(',')) {
      final item = part.trim();
      if (item.isEmpty || !seen.add(item.toLowerCase())) continue;
      result.add(item);
    }
    return result;
  }
}
