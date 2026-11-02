using restoren_app.Data.Models;
using System.ComponentModel.DataAnnotations;

namespace restoren_app.Data.Dtos.order
{
    // Body for changing the status
    public class OrderStatusUpdateDto
    {
        [Required(ErrorMessage = "Status is required.")]
        public OrderStatus? Status { get; set; }
    }
}
