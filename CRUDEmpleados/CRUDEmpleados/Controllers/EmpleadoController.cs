using CapaDatos.Data;
using CapaObjetos.Objetos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRUDEmpleados.Controllers
{
    [Authorize]
    public class EmpleadoController : BaseController
    {
        public EmpleadoController(IHttpContextAccessor contextAccessor, IConfiguration configuration)
       : base(contextAccessor, configuration)
        {
        }

        public async Task<IActionResult> Index()
        {
            List<clEmpleado> lista = dbEmpleado.obtenerEmpleados(conexionString);

            return View(lista);
        }

        [HttpGet]
        public IActionResult Insertar()
        {
            List<clPuesto> puestos = dbPuesto.obtenerPuesto(conexionString);

            ViewBag.Puestos = puestos;

            return View();
        }

        [HttpPost]
        public async Task<int> Insertar([FromBody] clEmpleado inEmpleado)
        {
            int resultCode = -1;

            try
            {
                resultCode = dbEmpleado.insertarEmpleado(conexionString, inEmpleado);

                return resultCode;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }

        [HttpGet]
        public async Task<IActionResult> Editar(string Empleado)
        {
            try
            {
                List<clPuesto> puestos = dbPuesto.obtenerPuesto(conexionString);

                ViewBag.Puestos = puestos;

                clEmpleado empleado = dbEmpleado.obtenerEmpleado(conexionString, Empleado);
                return View(empleado);
            }
            catch (Exception ex)
            {
                return NotFound();
            }
        }

        [HttpPost]
        public async Task<int> Editar([FromBody] clEmpleado inEmpleado)
        {
            int resultCode = -1;

            try
            {
                clEmpleado empleado = dbEmpleado.obtenerEmpleado(conexionString, inEmpleado.ValorDocumentoIdentidadOriginal);

                if (empleado.ValorDocumentoIdentidad == inEmpleado.ValorDocumentoIdentidad)
                {
                    inEmpleado.ValorDocumentoIdentidad = null;
                }

                if (empleado.Nombre == inEmpleado.Nombre)
                {
                    inEmpleado.Nombre = null;
                }

                if (empleado.NombrePuesto == inEmpleado.NombrePuesto)
                {
                    inEmpleado.NombrePuesto = null;
                }

                resultCode = dbEmpleado.editarEmpleado(conexionString, inEmpleado);

                return resultCode;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }

        [HttpPost]
        public async Task<int> Eliminar([FromBody] clEmpleado inEmpleado)
        {
            int resultCode = -1;

            try
            {
                resultCode = dbEmpleado.eliminarEmpleado(conexionString, inEmpleado);

                return resultCode;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }
    }
}
