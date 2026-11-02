using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Commands;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;
using restoren_app.Rules;

namespace restoren_app.CQRS.product.Handlers
{
    // Edits a product.
    // Old orders don't change because they saved their own copy of the name and price.
    public class UpdateProductHandler : IRequestHandler<UpdateProductCommand, ProductDto>
    {
        private readonly AppDbContext _db;

        public UpdateProductHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ProductDto> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
        {
            var dto = request.Product;

            var entity = await _db.Products
                .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

            if (entity == null)
                throw new KeyNotFoundException(ErrorMessages.ProductNotFound);

            var category = await _db.Categories
                .FirstOrDefaultAsync(c => c.Id == dto.CategoryId, cancellationToken);

            if (category == null)
                throw new ArgumentException(ErrorMessages.CategoryNotFound);

            entity.CategoryId = category.Id;
            entity.Name = dto.Name.Trim();
            entity.Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim();
            entity.Ingredients = ProductRules.NormalizeIngredients(dto.Ingredients);
            entity.Price = dto.Price;
            entity.ImageUrl = string.IsNullOrWhiteSpace(dto.ImageUrl) ? null : dto.ImageUrl.Trim();
            entity.IsAvailable = dto.IsAvailable;
            entity.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(cancellationToken);

            entity.Category = category; // so the DTO has the category name
            return ProductDto.FromEntity(entity);
        }
    }
}
