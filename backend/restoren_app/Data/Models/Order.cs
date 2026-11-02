using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace restoren_app.Data.Models
{
    // The Id is the "order number" the customer gets
    public class Order
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string CustomerName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string CustomerPhone { get; set; } = string.Empty;

        // Saved as text (DineIn / Takeaway), see AppDbContext
        public OrderType OrderType { get; set; }

        // Saved as text, every new order starts as Pending
        public OrderStatus Status { get; set; } = OrderStatus.Pending;

        [MaxLength(300)]
        public string? Notes { get; set; }

        // Only the server calculates the total
        [Precision(10, 2)]
        public decimal Total { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation property
        public List<OrderItem> Items { get; set; } = new List<OrderItem>();
    }
}
