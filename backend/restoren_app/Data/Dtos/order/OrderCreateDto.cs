using restoren_app.Data.Models;
using System.ComponentModel.DataAnnotations;

namespace restoren_app.Data.Dtos.order
{
    // What the customer sends when they confirm the order.
    // There is no price or total -> the server calculates them.
    public class OrderCreateDto
    {
        [Required]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters.")]
        public string CustomerName { get; set; } = string.Empty;

        [Required]
        [RegularExpression(@"^\+?[0-9][0-9\s\-]{6,18}$", ErrorMessage = "Phone number is not valid.")]
        public string CustomerPhone { get; set; } = string.Empty;

        [Required(ErrorMessage = "Order type is required (DineIn or Takeaway).")]
        public OrderType? OrderType { get; set; }

        [MaxLength(300, ErrorMessage = "Notes must be at most 300 characters.")]
        public string? Notes { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = ErrorMessages.EmptyOrder)]
        public List<OrderItemCreateDto> Items { get; set; } = new List<OrderItemCreateDto>();
    }

    // One item in the order: product id and quantity only
    public class OrderItemCreateDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Product id is not valid.")]
        public int ProductId { get; set; }

        [Range(1, 50, ErrorMessage = ErrorMessages.QuantityOutOfRange)]
        public int Quantity { get; set; }
    }
}
