using restoren_app.Data.Models;
using restoren_app.Validation;
using System.ComponentModel.DataAnnotations;

namespace restoren_app.Data.Dtos.product
{
    // A product as the admin sees it 
    public class ProductDto
    {
        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<string> Ingredients { get; set; } = new List<string>();
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public bool IsAvailable { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Entity -> DTO (the Category must be loaded first)
        public static ProductDto FromEntity(Product p)
        {
            return new ProductDto
            {
                Id = p.Id,
                CategoryId = p.CategoryId,
                CategoryName = p.Category != null ? p.Category.Name : string.Empty,
                Name = p.Name,
                Description = p.Description,
                Ingredients = p.Ingredients,
                Price = p.Price,
                ImageUrl = p.ImageUrl,
                IsAvailable = p.IsAvailable,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt
            };
        }
    }

    // What the admin sends to add or edit a product 
    public class ProductCreateUpdateDto
    {
        [Required]
        [StringLength(120, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 120 characters.")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "Description must be at most 500 characters.")]
        public string? Description { get; set; }

        [IngredientsList]
        public List<string> Ingredients { get; set; } = new List<string>();

        [Range(typeof(decimal), "0.01", "99999999.99", ErrorMessage = "Price must be greater than 0.")]
        [MaxDecimalPlaces(2)]
        public decimal Price { get; set; }

        [MaxLength(500)]
        [HttpUrl]
        public string? ImageUrl { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = ErrorMessages.CategoryNotFound)]
        public int CategoryId { get; set; }

        public bool IsAvailable { get; set; } = true;
    }

    // Body for hide/show
    public class ProductAvailabilityDto
    {
        [Required(ErrorMessage = "isAvailable is required.")]
        public bool? IsAvailable { get; set; }
    }

    // A category for the dropdown in the admin panel
    public class CategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
    }
}
