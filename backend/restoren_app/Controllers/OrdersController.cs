using MediatR;
using Microsoft.AspNetCore.Mvc;
using restoren_app.CQRS.order.Commands;
using restoren_app.CQRS.order.Queries;
using restoren_app.Data.Dtos.order;

namespace restoren_app.Controllers
{
    // Customer orders: place an order and track it 
    [Route("api/orders")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly IMediator _med;

        public OrdersController(IMediator med)
        {
            _med = med;
        }

        // Creates the order and returns it with its order number
        [HttpPost]
        public async Task<ActionResult<OrderDto>> Create(OrderCreateDto dto)
        {
            try
            {
                return Ok(await _med.Send(new CreateOrderCommand(dto)));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // Order tracking
        [HttpGet("{id}")]
        public async Task<ActionResult<OrderDto>> GetById(int id)
        {
            try
            {
                return Ok(await _med.Send(new GetOrderByIdQuery(id)));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
    }
}
