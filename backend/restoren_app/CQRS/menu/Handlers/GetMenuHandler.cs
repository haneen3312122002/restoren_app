using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.menu.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.menu;

namespace restoren_app.CQRS.menu.Handlers
{
   // every cat has products 
    public class GetMenuHandler : IRequestHandler<GetMenuQuery, List<MenuCategoryDto>>
    {
        private readonly AppDbContext _db;

        public GetMenuHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<MenuCategoryDto>> Handle(GetMenuQuery request, CancellationToken cancellationToken)
        {
            // Hidden products are skipped + a category with no available products is skipped 
            return await _db.Categories
                .AsNoTracking() // read only
                .Where(c => c.Products.Any(p => p.IsAvailable))
                .OrderBy(c => c.SortOrder)
                .ThenBy(c => c.Name)
                .Select(c => new MenuCategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Products = c.Products
                        .Where(p => p.IsAvailable)
                        .OrderBy(p => p.Name)
                        .Select(p => new MenuProductDto
                        {
                            Id = p.Id,
                            Name = p.Name,
                            Description = p.Description,
                            Ingredients = p.Ingredients,
                            Price = p.Price,
                            ImageUrl = p.ImageUrl
                        })
                        .ToList()
                })
                .ToListAsync(cancellationToken);
        }
    }
}
