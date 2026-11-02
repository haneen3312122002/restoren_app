using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using restoren_app.CQRS.product.Commands;
using restoren_app.CQRS.product.Queries;
using restoren_app.Data.Dtos.product;
using restoren_app.Data.Models;

namespace restoren_app.Controllers
{
    // Menu management (products CRUD), admins only
    [Route("api/admin/menu")]
    [ApiController]
    [Authorize(Roles = Roles.Admin)]
    public class AdminMenuController : ControllerBase
    {
        private readonly IMediator _med;

        public AdminMenuController(IMediator med)
        {
            _med = med;
        }

       
        // All products
        [HttpGet]
        public async Task<ActionResult<List<ProductDto>>> GetAll()
        {
            return Ok(await _med.Send(new GetAllProductsQuery()));
        }

        // Categories for the dropdown
        [HttpGet("categories")]
        public async Task<ActionResult<List<CategoryDto>>> GetCategories()
        {
            return Ok(await _med.Send(new GetCategoriesQuery()));
        }
        // get product by id
        [HttpGet("{id}")]
        public async Task<ActionResult<ProductDto>> GetById(int id)
        {
            try
            {
                return Ok(await _med.Send(new GetProductByIdQuery(id)));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
        // add product
        [HttpPost]
        public async Task<ActionResult<ProductDto>> Create(ProductCreateUpdateDto dto)
        {
            try
            {
                return Ok(await _med.Send(new CreateProductCommand(dto)));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
        //update product
        [HttpPut("{id}")]
        public async Task<ActionResult<ProductDto>> Update(int id, ProductCreateUpdateDto dto)
        {
            try
            {
                return Ok(await _med.Send(new UpdateProductCommand(id, dto)));
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

        // Hide or show a product without deleting it
        [HttpPatch("{id}/availability")]
        public async Task<ActionResult<ProductDto>> SetAvailability(int id, ProductAvailabilityDto dto)
        {
            try
            {
                return Ok(await _med.Send(new SetProductAvailabilityCommand(id, dto.IsAvailable == true)));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        // delete product
        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                await _med.Send(new DeleteProductCommand(id));
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
    }
}
