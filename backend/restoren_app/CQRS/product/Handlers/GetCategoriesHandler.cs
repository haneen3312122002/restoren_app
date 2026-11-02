using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.product.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.product;

namespace restoren_app.CQRS.product.Handlers
{
    // Returns the categories sorted by their menu order
    public class GetCategoriesHandler : IRequestHandler<GetCategoriesQuery, List<CategoryDto>>
    {
        private readonly AppDbContext _db;

        public GetCategoriesHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<CategoryDto>> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
        {
            return await _db.Categories
                .AsNoTracking()
                .OrderBy(c => c.SortOrder)
                .Select(c => new CategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    SortOrder = c.SortOrder
                })
                .ToListAsync(cancellationToken);
        }
    }
}
