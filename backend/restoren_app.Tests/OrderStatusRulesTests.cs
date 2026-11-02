using restoren_app.Data.Models;
using restoren_app.Rules;

namespace restoren_app.Tests
{
    // Tests for the order status rule
    public class OrderStatusRulesTests
    {
        // Allowed: one step forward
        [Theory]
        [InlineData(OrderStatus.Pending, OrderStatus.Preparing)]
        [InlineData(OrderStatus.Preparing, OrderStatus.Ready)]
        [InlineData(OrderStatus.Ready, OrderStatus.Delivered)]
        public void Allows_one_step_forward(OrderStatus from, OrderStatus to)
        {
            Assert.True(OrderStatusRules.CanMoveTo(from, to));
            OrderStatusRules.EnsureCanMoveTo(from, to); // should not throw
        }

        // Same status, skipping a step, or going back are all rejected
        [Theory]
        [InlineData(OrderStatus.Pending, OrderStatus.Pending)]
        [InlineData(OrderStatus.Pending, OrderStatus.Ready)]
        [InlineData(OrderStatus.Pending, OrderStatus.Delivered)]
        [InlineData(OrderStatus.Ready, OrderStatus.Preparing)]
        [InlineData(OrderStatus.Preparing, OrderStatus.Pending)]
        public void Rejects_same_skip_or_backward(OrderStatus from, OrderStatus to)
        {
            Assert.False(OrderStatusRules.CanMoveTo(from, to));
            var ex = Assert.Throws<ArgumentException>(() => OrderStatusRules.EnsureCanMoveTo(from, to));
            Assert.Contains(from.ToString(), ex.Message);
        }

        // Delivered is the last step, nothing can come after it
        [Theory]
        [InlineData(OrderStatus.Pending)]
        [InlineData(OrderStatus.Ready)]
        [InlineData(OrderStatus.Delivered)]
        public void Delivered_is_final(OrderStatus to)
        {
            Assert.Null(OrderStatusRules.GetNextStatus(OrderStatus.Delivered));
            Assert.Throws<ArgumentException>(() => OrderStatusRules.EnsureCanMoveTo(OrderStatus.Delivered, to));
        }
    }
}
