using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Handlers
{
    // All products for the admin, sorted by category then name
    public class GetAllProductsHandler : IRequestHandler<GetAllProductsQuery, List<ProductDto>>
    {
        private readonly AppDbContext _db;

        public GetAllProductsHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<ProductDto>> Handle(GetAllProductsQuery request, CancellationToken cancellationToken)
        {
            var products = await _db.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .OrderBy(p => p.Category.SortOrder)
                .ThenBy(p => p.Name)
                .ToListAsync(cancellationToken);

            var result = new List<ProductDto>();
            foreach (var product in products)
                result.Add(ProductDto.FromEntity(product));

            return result;
        }
    }
}
