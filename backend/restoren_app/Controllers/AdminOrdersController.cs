using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using restoren_app.CQRS.order.Commands;
using restoren_app.CQRS.order.Queries;
using restoren_app.Data.Dtos.order;
using restoren_app.Data.Models;

namespace restoren_app.Controllers
{
    // Order management, admins only
    [Route("api/admin/orders")]
    [ApiController]
    [Authorize(Roles = Roles.Admin)]
    public class AdminOrdersController : ControllerBase
    {
        private readonly IMediator _med;

        public AdminOrdersController(IMediator med)
        {
            _med = med;
        }

        // Orders with customer info
        [HttpGet]
        public async Task<ActionResult<List<AdminOrderDto>>> GetAll([FromQuery] OrderStatus? status, [FromQuery] bool includeDelivered)
        {
            return Ok(await _med.Send(new GetAdminOrdersQuery(status, includeDelivered)));
        }

        // Moves the order to the next step only
        //update the status of an order (e.g. from Pending to Preparing)
        [HttpPatch("{id}/status")]
        public async Task<ActionResult<AdminOrderDto>> UpdateStatus(int id, OrderStatusUpdateDto dto)
        {
            try
            {
                return Ok(await _med.Send(new UpdateOrderStatusCommand(id, dto.Status.Value)));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
