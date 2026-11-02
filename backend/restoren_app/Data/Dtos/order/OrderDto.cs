using restoren_app.Data.Models;
using restoren_app.Rules;

namespace restoren_app.Data.Dtos.order
{
    // The order the customer sees when tracking it.
    // No name, phone.....ect
    public class OrderDto
    {
        public int Id { get; set; }
        public OrderStatus Status { get; set; }
        public OrderType OrderType { get; set; }
        public decimal Total { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<OrderItemDto> Items { get; set; } = new List<OrderItemDto>();

        // Entity -> DTO for the customer
        public static OrderDto FromEntity(Order order)
        {
            var dto = new OrderDto();
            FillCommonFields(dto, order);
            return dto;
        }

        // Fills the fields that OrderDto and AdminOrderDto share
        protected static void FillCommonFields(OrderDto dto, Order order)
        {
            dto.Id = order.Id;
            dto.Status = order.Status;
            dto.OrderType = order.OrderType;
            dto.Total = order.Total;
            dto.CreatedAt = order.CreatedAt;
            dto.UpdatedAt = order.UpdatedAt;

            foreach (var item in order.Items.OrderBy(i => i.Id))
            {
                dto.Items.Add(new OrderItemDto
                {
                    ProductName = item.ProductName,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    LineTotal = OrderCalculator.LineTotal(item.UnitPrice, item.Quantity)
                });
            }
        }
    }

    // The order the admin sees: same as OrderDto + customer info
    public class AdminOrderDto : OrderDto
    {
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerPhone { get; set; } = string.Empty;
        public string? Notes { get; set; }

        // Entity -> DTO for the admin
        public static AdminOrderDto FromAdminEntity(Order order)
        {
            var dto = new AdminOrderDto
            {
                CustomerName = order.CustomerName,
                CustomerPhone = order.CustomerPhone,
                Notes = order.Notes
            };
            FillCommonFields(dto, order);
            return dto;
        }
    }

    // One line of the order with its total
    public class OrderItemDto
    {
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal LineTotal { get; set; }
    }
}
