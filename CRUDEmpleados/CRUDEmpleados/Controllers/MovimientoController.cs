using CapaObjetos.Objetos;
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

        public IActionResult Index(string empleado)
        {
            List<clMovimiento> lista = dbMovimiento.obtenerMovimientos(conexionString, empleado);

            ViewBag.empleado = empleado;

            return View(lista);
        }


        [HttpGet]
        public IActionResult Insertar()
        {
            List<clPuesto> puestos = dbPuesto.obtenerPuesto(conexionString);

            ViewBag.Puestos = puestos;

            return View();
        }
    }
}
