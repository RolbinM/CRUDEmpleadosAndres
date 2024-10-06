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
            string usuario = User.Identity.Name;

            List<clEmpleado> lista = dbEmpleado.obtenerEmpleados(conexionString);

            return View(lista);
        }

        [HttpGet]
        public IActionResult Insertar()
        {
            // Ejemplo de una lista de puestos
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
                string usuario = User.Identity.Name;

                

                return 1;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }

        //[HttpGet]
        //public async Task<IActionResult> Editar(string inEmpleado)
        //{
        //    string usuario = User.Identity.Name;

        //    //cl cuenta = await personalHubDBContext.Cuenta.FirstAsync(e => (e.Usuario == usuario && e.Cuenta == inCuenta));

        //    return View(cuenta);
        //}

        //[HttpPost]
        //public async Task<int> Editar([FromBody] clEmpleado inEmpleado)
        //{
        //    try
        //    {
        //        string usuario = User.Identity.Name;
        //        cuenta.UpdatedDate = DateTime.Now;


        //        return 1;

        //    }
        //    catch (Exception ex)
        //    {
        //        return -1;
        //    }
        //}

        //[HttpPost]
        //public async Task<int> Eliminar([FromBody] clEmpleado inEmpleado)
        //{
        //    try
        //    {
        //        string usuario = User.Identity.Name;



        //        return 1;

        //    }
        //    catch (Exception ex)
        //    {
        //        return -1;
        //    }
        //}
    }
}
