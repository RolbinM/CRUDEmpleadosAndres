using CRUDEmpleados.Models;
using Microsoft.AspNetCore.Mvc;

namespace CRUDEmpleados.Controllers
{
    public class EmpleadoController : Controller
    {

        [HttpGet]
        public async Task<IActionResult> Lista()
        {
            List<Empleado> lista = await _appDBContext.Empleados.ToListAsync();

            return View(lista);
        }


        [HttpGet]
        public IActionResult Nuevo()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Nuevo(Empleado empleado)
        {
           

            return RedirectToAction(nameof(Lista));
        }

        [HttpGet]
        public async Task<IActionResult> Editar(int Id)
        {
            Empleado empleado = await _appDBContext.Empleados.FirstAsync(e => e.IdEmpleado == Id);

            return View(empleado);
        }

        [HttpPost]
        public async Task<IActionResult> Editar(Empleado empleado)
        {
            _appDBContext.Empleados.Update(empleado);
            await _appDBContext.SaveChangesAsync();

            return RedirectToAction(nameof(Lista));
        }


        [HttpGet]
        public async Task<IActionResult> Eliminar(int Id)
        {
            Empleado empleado = await _appDBContext.Empleados.FirstAsync(e => e.IdEmpleado == Id);
            _appDBContext.Empleados.Remove(empleado);
            await _appDBContext.SaveChangesAsync();

            return RedirectToAction(nameof(Lista));
        }
    }
}
