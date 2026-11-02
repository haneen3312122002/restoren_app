using MediatR;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Queries
{
    // All products for the admin (hidden ones too)
    public record GetAllProductsQuery() : IRequest<List<ProductDto>>;

    // One product by id
    public record GetProductByIdQuery(int Id) : IRequest<ProductDto>;

    // Categories for the dropdown
    public record GetCategoriesQuery() : IRequest<List<CategoryDto>>;
}
