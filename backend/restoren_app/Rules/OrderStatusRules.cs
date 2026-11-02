using restoren_app.Data;
using restoren_app.Data.Models;

namespace restoren_app.Rules
{
    // The rule for changing an order's status, written once and used everywhere.
    // Allowed: Pending -> Preparing -> Ready -> Delivered (one step forward only)
    public static class OrderStatusRules
    {
        // Returns the next status, or null if the order is already Delivered
        public static OrderStatus? GetNextStatus(OrderStatus current)
        {
            if (current == OrderStatus.Pending)
                return OrderStatus.Preparing;

            if (current == OrderStatus.Preparing)
                return OrderStatus.Ready;

            if (current == OrderStatus.Ready)
                return OrderStatus.Delivered;

            return null; // Delivered is the last step
        }

        // true if we can move from current to next
        public static bool CanMoveTo(OrderStatus current, OrderStatus next)
        {
            return GetNextStatus(current) == next;
        }

        // Throws ArgumentException (the controller turns it into 400) if the move is not allowed
        public static void EnsureCanMoveTo(OrderStatus current, OrderStatus next)
        {
            var allowed = GetNextStatus(current);

            if (allowed == null)
                throw new ArgumentException(ErrorMessages.OrderAlreadyDelivered);

            if (allowed != next)
                throw new ArgumentException(
                    $"Cannot change order status from '{current}' to '{next}'. The only allowed next status is '{allowed}'.");
        }
    }
}
