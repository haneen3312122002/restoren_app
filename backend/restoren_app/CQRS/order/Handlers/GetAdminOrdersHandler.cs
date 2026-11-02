using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.order.Queries;
using restoren_app.Data;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;

namespace restoren_app.CQRS.order.Handlers
{
    // Orders for the admin.
    // By default: orders that are not delivered yet, oldest first (the kitchen works in order).
    public class GetAdminOrdersHandler : IRequestHandler<GetAdminOrdersQuery, List<AdminOrderDto>>
    {
        // We only return the last 50 delivered orders, not the whole history
        public const int DeliveredLimit = 50;

        private readonly AppDbContext _db;

        public GetAdminOrdersHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<AdminOrderDto>> Handle(GetAdminOrdersQuery request, CancellationToken cancellationToken)
        {
            var orders = new List<Order>();

            if (request.Status == OrderStatus.Delivered)
            {
                // Only delivered orders
                orders = await GetLatestDelivered(cancellationToken);
            }
            else if (request.Status != null)
            {
                // Only one status (Pending, Preparing or Ready)
                orders = await _db.Orders
                    .AsNoTracking()
                    .Include(o => o.Items)
                    .Where(o => o.Status == request.Status)
                    .OrderBy(o => o.CreatedAt)
                    .ToListAsync(cancellationToken);
            }
            else
            {
                // No filter: all active orders, plus delivered ones if asked
                orders = await _db.Orders
                    .AsNoTracking()
                    .Include(o => o.Items)
                    .Where(o => o.Status != OrderStatus.Delivered)
                    .OrderBy(o => o.CreatedAt)
                    .ToListAsync(cancellationToken);

                if (request.IncludeDelivered)
                    orders.AddRange(await GetLatestDelivered(cancellationToken));
            }

            var result = new List<AdminOrderDto>();
            foreach (var order in orders)
                result.Add(AdminOrderDto.FromAdminEntity(order));

            return result;
        }

        // The latest delivered orders, newest first
        private async Task<List<Order>> GetLatestDelivered(CancellationToken cancellationToken)
        {
            return await _db.Orders
                .AsNoTracking()
                .Include(o => o.Items)
                .Where(o => o.Status == OrderStatus.Delivered)
                .OrderByDescending(o => o.UpdatedAt)
                .Take(DeliveredLimit)
                .ToListAsync(cancellationToken);
        }
    }
}
