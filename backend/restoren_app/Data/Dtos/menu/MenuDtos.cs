namespace restoren_app.Data.Dtos.menu
{
    // A category in the customer menu, with its available products only
    public class MenuCategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public List<MenuProductDto> Products { get; set; } = new List<MenuProductDto>();
    }

    // A product in the customer menu 
    public class MenuProductDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<string> Ingredients { get; set; } = new List<string>();
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
    }
}
