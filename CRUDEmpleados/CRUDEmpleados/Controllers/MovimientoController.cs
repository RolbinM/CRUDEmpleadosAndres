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
        public IActionResult Insertar(string Empleado)
        {
            clEmpleado emp = dbEmpleado.obtenerEmpleado(conexionString, Empleado);

            List<clTipoMovimiento> tiposMovimientos = dbMovimiento.obtenerTiposMovimientos(conexionString);

            ViewBag.Empleado = emp;
            ViewBag.tiposMovimientos = tiposMovimientos; ;

            return View();
        }

        [HttpPost]
        public async Task<int> Insertar([FromBody] clMovimiento inMovimiento)
        {
            int resultCode = -1;

            try
            {
                string usuario = User.Identity.Name;
                string ip = HttpContext.Connection.RemoteIpAddress?.ToString();

                inMovimiento.Usuario = User.Identity.Name;
                inMovimiento.PostInIp = ip;

                resultCode = dbMovimiento.insertarMovimiento(conexionString, inMovimiento);

                return resultCode;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }
    }
}
