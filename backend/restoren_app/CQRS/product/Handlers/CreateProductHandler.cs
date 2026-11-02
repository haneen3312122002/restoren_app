using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Commands;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;
using restoren_app.Data.Models;
using restoren_app.Rules;

namespace restoren_app.CQRS.product.Handlers
{
    // Adds a new product after checking its category exists
    public class CreateProductHandler : IRequestHandler<CreateProductCommand, ProductDto>
    {
        private readonly AppDbContext _db;

        public CreateProductHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ProductDto> Handle(CreateProductCommand request, CancellationToken cancellationToken)
        {
            var dto = request.Product;

            var category = await _db.Categories
                .FirstOrDefaultAsync(c => c.Id == dto.CategoryId, cancellationToken);

            if (category == null)
                throw new ArgumentException(ErrorMessages.CategoryNotFound);

            var entity = new Product
            {
                CategoryId = category.Id,
                Name = dto.Name.Trim(),
                Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim(),
                Ingredients = ProductRules.NormalizeIngredients(dto.Ingredients),
                Price = dto.Price,
                ImageUrl = string.IsNullOrWhiteSpace(dto.ImageUrl) ? null : dto.ImageUrl.Trim(),
                IsAvailable = dto.IsAvailable,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _db.Products.Add(entity);
            await _db.SaveChangesAsync(cancellationToken);

            entity.Category = category; // so the DTO has the category name
            return ProductDto.FromEntity(entity);
        }
    }
}
