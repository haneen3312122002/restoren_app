using MediatR;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;

namespace restoren_app.CQRS.order.Queries
{
    // Track an order by its number (public, no personal data)
    public record GetOrderByIdQuery(int Id) : IRequest<OrderDto>;

    // Orders list for the admin, with an optional status filter
    public record GetAdminOrdersQuery(OrderStatus? Status, bool IncludeDelivered) : IRequest<List<AdminOrderDto>>;
}
