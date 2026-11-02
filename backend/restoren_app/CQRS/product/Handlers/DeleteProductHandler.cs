using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Commands;
using restoren_app.Data;

namespace restoren_app.CQRS.product.Handlers
{
    // Deletes a product.
    // Old order items get ProductId = NULL but keep their saved name and price.
    public class DeleteProductHandler : IRequestHandler<DeleteProductCommand, Unit>
    {
        private readonly AppDbContext _db;

        public DeleteProductHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<Unit> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
        {
            var entity = await _db.Products
                .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

            if (entity == null)
                throw new KeyNotFoundException(ErrorMessages.ProductNotFound);

            _db.Products.Remove(entity);
            await _db.SaveChangesAsync(cancellationToken);

            return Unit.Value;
        }
    }
}
