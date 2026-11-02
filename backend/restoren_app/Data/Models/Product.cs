using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace restoren_app.Data.Models
{
    // A menu item
    public class Product
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey("Category")]
        public int CategoryId { get; set; }

        [Required]
        [MaxLength(120)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        // EF Core saves this list as JSON in one column
        public List<string> Ingredients { get; set; } = new List<string>();

        // decimal, not double, so money stays exact
        [Precision(10, 2)]
        public decimal Price { get; set; }

        // Just a link to an image (no file upload)
        [MaxLength(500)]
        public string? ImageUrl { get; set; }

        // false = hidden from the customer menu (instead of deleting it)
        public bool IsAvailable { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation property
        public Category Category { get; set; }
    }
}
