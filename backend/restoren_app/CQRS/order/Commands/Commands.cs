using MediatR;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;

namespace restoren_app.CQRS.order.Commands
{
    // Create a new order from the cart
    public record CreateOrderCommand(OrderCreateDto Order) : IRequest<OrderDto>;

    // Move an order to its next status (admin)
    public record UpdateOrderStatusCommand(int Id, OrderStatus NewStatus) : IRequest<AdminOrderDto>;
}
