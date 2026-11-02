using MediatR;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Commands
{
    // Add a new product
    public record CreateProductCommand(ProductCreateUpdateDto Product) : IRequest<ProductDto>;

    // Edit a product (all fields)
    public record UpdateProductCommand(int Id, ProductCreateUpdateDto Product) : IRequest<ProductDto>;

    // Hide or show a product without deleting it
    public record SetProductAvailabilityCommand(int Id, bool IsAvailable) : IRequest<ProductDto>;

    // Delete a product
    public record DeleteProductCommand(int Id) : IRequest<Unit>;
}
