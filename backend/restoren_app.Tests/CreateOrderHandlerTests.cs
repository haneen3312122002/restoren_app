using Microsoft.EntityFrameworkCore;
using restoren_app.CQRS.order.Commands;
using restoren_app.CQRS.order.Handlers;
using restoren_app.Data;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;

namespace restoren_app.Tests
{
    // Tests for creating an order, using an in-memory database (no SQL Server needed)
    public class CreateOrderHandlerTests
    {
        // A new empty database for each test, with 2 products: one available and one hidden
        private static AppDbContext CreateDb()
        {
            var options = new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(Guid.NewGuid().ToString())
                .Options;

            var db = new AppDbContext(options);
            db.Categories.Add(new Category { Id = 1, Name = "Mains" });
            db.Products.Add(new Product { Id = 1, CategoryId = 1, Name = "Burger", Price = 8.50m, IsAvailable = true });
            db.Products.Add(new Product { Id = 2, CategoryId = 1, Name = "Hidden Dish", Price = 5.00m, IsAvailable = false });
            db.SaveChanges();
            return db;
        }

        // A simple valid order with the given items
        private static OrderCreateDto ValidOrder(List<OrderItemCreateDto> items)
        {
            return new OrderCreateDto
            {
                CustomerName = "Haneen",
                CustomerPhone = "0791234567",
                OrderType = OrderType.Takeaway,
                Items = items
            };
        }

        // Total comes from database prices, the order starts as Pending, and duplicates are joined
        [Fact]
        public async Task Creates_order_with_server_side_total_and_merged_items()
        {
            using var db = CreateDb();
            var handler = new CreateOrderHandler(db);

            var items = new List<OrderItemCreateDto>
            {
                new OrderItemCreateDto { ProductId = 1, Quantity = 1 },
                new OrderItemCreateDto { ProductId = 1, Quantity = 2 }
            };
            var result = await handler.Handle(new CreateOrderCommand(ValidOrder(items)), CancellationToken.None);

            Assert.Equal(OrderStatus.Pending, result.Status);
            Assert.Single(result.Items);
            Assert.Equal(3, result.Items[0].Quantity);
            Assert.Equal(25.50m, result.Total); // 8.50 x 3

            var saved = await db.Orders.Include(o => o.Items).SingleAsync();
            Assert.Equal("Burger", saved.Items[0].ProductName); // copy of the name
            Assert.Equal(8.50m, saved.Items[0].UnitPrice);      // copy of the price
        }

        // Changing the price later doesn't change an old order
        [Fact]
        public async Task Price_change_does_not_affect_existing_order()
        {
            using var db = CreateDb();
            var handler = new CreateOrderHandler(db);

            var items = new List<OrderItemCreateDto> { new OrderItemCreateDto { ProductId = 1, Quantity = 2 } };
            var created = await handler.Handle(new CreateOrderCommand(ValidOrder(items)), CancellationToken.None);

            var product = await db.Products.FindAsync(1);
            product.Price = 99m;
            await db.SaveChangesAsync();

            var order = await db.Orders.Include(o => o.Items).SingleAsync(o => o.Id == created.Id);
            Assert.Equal(17.00m, order.Total);
            Assert.Equal(8.50m, order.Items[0].UnitPrice);
        }

        // A hidden product is rejected, even if the customer opened the menu before it was hidden
        [Fact]
        public async Task Rejects_hidden_product()
        {
            using var db = CreateDb();
            var handler = new CreateOrderHandler(db);

            var items = new List<OrderItemCreateDto> { new OrderItemCreateDto { ProductId = 2, Quantity = 1 } };
            var ex = await Assert.ThrowsAsync<ArgumentException>(() =>
                handler.Handle(new CreateOrderCommand(ValidOrder(items)), CancellationToken.None));

            Assert.Contains(ErrorMessages.ProductUnavailable, ex.Message);
            Assert.Empty(db.Orders); // nothing was saved
        }

        // A product that doesn't exist is rejected
        [Fact]
        public async Task Rejects_unknown_product()
        {
            using var db = CreateDb();
            var handler = new CreateOrderHandler(db);

            var items = new List<OrderItemCreateDto> { new OrderItemCreateDto { ProductId = 999, Quantity = 1 } };
            var ex = await Assert.ThrowsAsync<ArgumentException>(() =>
                handler.Handle(new CreateOrderCommand(ValidOrder(items)), CancellationToken.None));

            Assert.Contains(ErrorMessages.ProductNotFound, ex.Message);
        }

        // 30 + 30 of the same product = 60, which is over the limit of 50
        [Fact]
        public async Task Rejects_merged_quantity_over_limit()
        {
            using var db = CreateDb();
            var handler = new CreateOrderHandler(db);

            var items = new List<OrderItemCreateDto>
            {
                new OrderItemCreateDto { ProductId = 1, Quantity = 30 },
                new OrderItemCreateDto { ProductId = 1, Quantity = 30 }
            };

            await Assert.ThrowsAsync<ArgumentException>(() =>
                handler.Handle(new CreateOrderCommand(ValidOrder(items)), CancellationToken.None));
        }
    }
}
