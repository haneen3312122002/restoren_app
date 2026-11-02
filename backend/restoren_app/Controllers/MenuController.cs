using MediatR;
using Microsoft.AspNetCore.Mvc;
using restoren_app.CQRS.menu.Queries;
using restoren_app.Data.Dtos.menu;

namespace restoren_app.Controllers
{
    //  customer menu, no login 
    [Route("api/menu")]
    [ApiController]
    public class MenuController : ControllerBase
    {
        private readonly IMediator _med;

        public MenuController(IMediator med)
        {
            _med = med;
        }

        // All categories with their available products, in one request
        [HttpGet]
        public async Task<ActionResult<List<MenuCategoryDto>>> GetMenu()
        {
            return Ok(await _med.Send(new GetMenuQuery()));
        }
    }
}
