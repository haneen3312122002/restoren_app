using System.ComponentModel.DataAnnotations;

namespace restoren_app.Validation
{
    // Checks the image link (if there is one) is a real http or https link
    public class HttpUrlAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            var url = value as string;

            // The link is optional
            if (string.IsNullOrWhiteSpace(url))
                return ValidationResult.Success;

            bool isValid = Uri.TryCreate(url, UriKind.Absolute, out var uri)
                           && (uri.Scheme == "http" || uri.Scheme == "https");

            if (!isValid)
                return new ValidationResult("Image URL must be a valid http or https URL.");

            return ValidationResult.Success;
        }
    }
}
