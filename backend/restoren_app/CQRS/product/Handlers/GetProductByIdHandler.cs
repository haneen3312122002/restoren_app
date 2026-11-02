using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Handlers
{
    // Returns one product, or throws KeyNotFoundException (404) if it doesn't exist
    public class GetProductByIdHandler : IRequestHandler<GetProductByIdQuery, ProductDto>
    {
        private readonly AppDbContext _db;

        public GetProductByIdHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ProductDto> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
        {
            var product = await _db.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

            if (product == null)
                throw new KeyNotFoundException(ErrorMessages.ProductNotFound);

            return ProductDto.FromEntity(product);
        }
    }
}
