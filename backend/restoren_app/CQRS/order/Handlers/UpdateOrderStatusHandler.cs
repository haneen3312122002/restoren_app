using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.order.Commands;
using restoren_app.Data;
using restoren_app.Data.Dtos.order;
using restoren_app.Rules;

namespace restoren_app.CQRS.order.Handlers
{
    // Moves an order one step forward.
    // The check is done here on the server, not in the controller or the frontend.
    public class UpdateOrderStatusHandler : IRequestHandler<UpdateOrderStatusCommand, AdminOrderDto>
    {
        private readonly AppDbContext _db;

        public UpdateOrderStatusHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<AdminOrderDto> Handle(UpdateOrderStatusCommand request, CancellationToken cancellationToken)
        {
            var order = await _db.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == request.Id, cancellationToken);

            if (order == null)
                throw new KeyNotFoundException(ErrorMessages.OrderNotFound);

            // Throws ArgumentException with a clear message if the move is not allowed
            OrderStatusRules.EnsureCanMoveTo(order.Status, request.NewStatus);

            order.Status = request.NewStatus;
            order.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(cancellationToken);

            return AdminOrderDto.FromAdminEntity(order);
        }
    }
}
