using MediatR;
using restoren_app.Data.Dtos.menu;

namespace restoren_app.CQRS.menu.Queries
{
    // The full customer menu: categories with their available products
    public record GetMenuQuery() : IRequest<List<MenuCategoryDto>>;
}
