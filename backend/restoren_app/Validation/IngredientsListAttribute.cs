using restoren_app.Rules;
using System.ComponentModel.DataAnnotations;

namespace restoren_app.Validation
{
    // Checks the ingredients list: at most 30 items, each at most 60 characters
    public class IngredientsListAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            var list = value as List<string>;
            if (list == null)
                return ValidationResult.Success;

            var cleaned = ProductRules.NormalizeIngredients(list);

            if (cleaned.Count > ProductRules.MaxIngredients)
                return new ValidationResult($"A product can have at most {ProductRules.MaxIngredients} ingredients.");

            foreach (var ingredient in cleaned)
            {
                if (ingredient.Length > ProductRules.MaxIngredientLength)
                    return new ValidationResult($"Each ingredient must be at most {ProductRules.MaxIngredientLength} characters.");
            }

            return ValidationResult.Success;
        }
    }
}
