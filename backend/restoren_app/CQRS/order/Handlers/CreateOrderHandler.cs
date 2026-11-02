using MediatR;
using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.order.Commands;
using restoren_app.Data;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;
using restoren_app.Rules;

namespace restoren_app.CQRS.order.Handlers
{
    // Turns the cart into a real order.
    public class CreateOrderHandler : IRequestHandler<CreateOrderCommand, OrderDto>
    {
        private readonly AppDbContext _db;

        public CreateOrderHandler(AppDbContext db)
        {
            _db = db;
        }

        public async Task<OrderDto> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
        {
            var dto = request.Order;

            if (dto.Items == null || dto.Items.Count == 0)
                throw new ArgumentException(ErrorMessages.EmptyOrder);

            // 1) Join duplicate items (same product twice = one line)
            var sentLines = new List<OrderLine>();
            foreach (var item in dto.Items)
                sentLines.Add(new OrderLine(item.ProductId, item.Quantity));

            var lines = OrderCalculator.MergeLines(sentLines);

            foreach (var line in lines)
            {
                if (!OrderCalculator.IsValidQuantity(line.Quantity))
                    throw new ArgumentException(ErrorMessages.QuantityOutOfRange);
            }

            // 2) Get all the products in one query 
            var ids = lines.Select(l => l.ProductId).ToList();
            var products = await _db.Products
                .Where(p => ids.Contains(p.Id))
                .ToListAsync(cancellationToken);

            // 3) Check every product exists and is available,
            //    then build the items with the database price
            var items = new List<OrderItem>();
            foreach (var line in lines)
            {
                var product = products.FirstOrDefault(p => p.Id == line.ProductId);

                if (product == null)
                    throw new ArgumentException($"{ErrorMessages.ProductNotFound} (id: {line.ProductId})");

                if (!product.IsAvailable)
                    throw new ArgumentException($"{ErrorMessages.ProductUnavailable} ({product.Name})");

                items.Add(new OrderItem
                {
                    ProductId = product.Id,
                    ProductName = product.Name, // copy of the name at order time
                    UnitPrice = product.Price,  // copy of the price at order time
                    Quantity = line.Quantity
                });
            }

            var order = new Order
            {
                CustomerName = dto.CustomerName.Trim(),
                CustomerPhone = dto.CustomerPhone.Trim(),
                OrderType = dto.OrderType.Value,
                Notes = string.IsNullOrWhiteSpace(dto.Notes) ? null : dto.Notes.Trim(),
                Status = OrderStatus.Pending,
                Items = items,
                // 4) The server calculates the total
                Total = OrderCalculator.CalculateTotal(items),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            // 5) Save. One SaveChanges saves the order and its items together.
            _db.Orders.Add(order);
            await _db.SaveChangesAsync(cancellationToken);

            return OrderDto.FromEntity(order);
        }
    }
}
