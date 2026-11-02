using System.ComponentModel.DataAnnotations;

namespace restoren_app.Data.Models
{
    // Menu categories (Starters, Drinks...). They come from the seed, there is no CRUD for them.
    public class Category
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(80)]
        public string Name { get; set; } = string.Empty;

        // The order the category shows in the menu
        public int SortOrder { get; set; } = 0;

        // Products in this category
        public List<Product> Products { get; set; } = new List<Product>();
    }
}
