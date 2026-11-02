using System.ComponentModel.DataAnnotations;

namespace restoren_app.Validation
{
    // Checks a number doesn't have too many digits after the point (for prices: 2, like 4.50)
    public class MaxDecimalPlacesAttribute : ValidationAttribute
    {
        private readonly int _places;

        public MaxDecimalPlacesAttribute(int places)
        {
            _places = places;
        }

        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value == null)
                return ValidationResult.Success;

            var number = (decimal)value;

            // If rounding changes the number, it had too many digits (4.505 -> 4.51)
            if (decimal.Round(number, _places) != number)
                return new ValidationResult($"Price can have at most {_places} decimal places.");

            return ValidationResult.Success;
        }
    }
}
