using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.order.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.order;

namespace restoren_app.CQRS.order.Handlers
{
    // Returns the order status for the customer (no name, phone or notes)
    public class GetOrderByIdHandler : IRequestHandler<GetOrderByIdQuery, OrderDto>
    {
        private readonly AppDbContext _db;

        public GetOrderByIdHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<OrderDto> Handle(GetOrderByIdQuery request, CancellationToken cancellationToken)
        {
            var order = await _db.Orders
                .AsNoTracking()
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == request.Id, cancellationToken);

            if (order == null)
                throw new KeyNotFoundException(ErrorMessages.OrderNotFound);

            return OrderDto.FromEntity(order);
        }
    }
}
