using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Commands;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Handlers
{
    // Hides or shows a product.
    // A hidden product disappears from the customer menu and can't be ordered.
    public class SetProductAvailabilityHandler : IRequestHandler<SetProductAvailabilityCommand, ProductDto>
    {
        private readonly AppDbContext _db;

        public SetProductAvailabilityHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ProductDto> Handle(SetProductAvailabilityCommand request, CancellationToken cancellationToken)
        {
            var entity = await _db.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

            if (entity == null)
                throw new KeyNotFoundException(ErrorMessages.ProductNotFound);

            entity.IsAvailable = request.IsAvailable;
            entity.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(cancellationToken);

            return ProductDto.FromEntity(entity);
        }
    }
}
