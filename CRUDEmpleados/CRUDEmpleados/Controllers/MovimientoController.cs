using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRUDEmpleados.Controllers
{
    [Authorize]
    public class MovimientoController : BaseController
    {
        public MovimientoController(IHttpContextAccessor contextAccessor, IConfiguration configuration)
      : base(contextAccessor, configuration)
        {
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
