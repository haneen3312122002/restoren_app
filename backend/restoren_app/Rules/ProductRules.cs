namespace restoren_app.Rules
{
    // Product rules we apply before saving
    public static class ProductRules
    {
        public const int MaxIngredients = 30;
        public const int MaxIngredientLength = 60;

        // Cleans the ingredients: trims spaces, removes empty ones and duplicates
        // ("Salt" and "salt" count as the same)
        public static List<string> NormalizeIngredients(List<string>? ingredients)
        {
            var result = new List<string>();
            if (ingredients == null)
                return result;

            foreach (var ingredient in ingredients)
            {
                if (string.IsNullOrWhiteSpace(ingredient))
                    continue;

                var clean = ingredient.Trim();

                bool alreadyAdded = result.Any(r => r.Equals(clean, StringComparison.OrdinalIgnoreCase));
                if (!alreadyAdded)
                    result.Add(clean);
            }

            return result;
        }
    }
}
