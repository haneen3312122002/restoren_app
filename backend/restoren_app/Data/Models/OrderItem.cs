using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace restoren_app.Data.Models
{
   
    public class OrderItem
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey("Order")]
        public int OrderId { get; set; }

        // Can be null: becomes NULL if the product is deleted
        [ForeignKey("Product")]
        public int? ProductId { get; set; }

        [Required]
        [MaxLength(120)]
        public string ProductName { get; set; } = string.Empty;

        [Precision(10, 2)]
        public decimal UnitPrice { get; set; }

        // 1 to 50
        public int Quantity { get; set; }

        // Navigation properties
        public Order Order { get; set; }
        public Product? Product { get; set; }
    }
}
