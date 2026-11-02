using restoren_app.Data.Models;
using restoren_app.Rules;

namespace restoren_app.Tests
{
    // Tests for the order total and for joining duplicate items
    public class OrderCalculatorTests
    {
        // The same product twice becomes one line with the quantities added
        [Fact]
        public void MergeLines_combines_duplicate_products()
        {
            var lines = new List<OrderLine>
            {
                new OrderLine(1, 2),
                new OrderLine(2, 1),
                new OrderLine(1, 3)
            };

            var merged = OrderCalculator.MergeLines(lines);

            Assert.Equal(2, merged.Count);
            Assert.Equal(5, merged.Single(l => l.ProductId == 1).Quantity);
            Assert.Equal(1, merged.Single(l => l.ProductId == 2).Quantity);
        }

        // Total = sum of (price x quantity), exact with decimal
        [Fact]
        public void CalculateTotal_sums_unit_price_times_quantity()
        {
            var items = new List<OrderItem>
            {
                new OrderItem { UnitPrice = 4.50m, Quantity = 2 },  // 9.00
                new OrderItem { UnitPrice = 0.10m, Quantity = 3 },  // 0.30
                new OrderItem { UnitPrice = 8.75m, Quantity = 1 }   // 8.75
            };

            Assert.Equal(18.05m, OrderCalculator.CalculateTotal(items));
        }

        // No items = total of zero
        [Fact]
        public void CalculateTotal_of_no_items_is_zero()
        {
            Assert.Equal(0m, OrderCalculator.CalculateTotal(new List<OrderItem>()));
        }

        // Quantity must be from 1 to 50
        [Theory]
        [InlineData(0, false)]
        [InlineData(1, true)]
        [InlineData(50, true)]
        [InlineData(51, false)]
        public void IsValidQuantity_enforces_1_to_50(int quantity, bool expected)
        {
            Assert.Equal(expected, OrderCalculator.IsValidQuantity(quantity));
        }
    }
}
