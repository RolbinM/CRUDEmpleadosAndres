using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using CapaObjetos.Objetos;
using CapaDatos.Data;

namespace CRUDEmpleados.Controllers
{
    public class LoginController : BaseController
    {
        public LoginController(IHttpContextAccessor contextAccessor, IConfiguration configuration)
       : base(contextAccessor, configuration)
        {
        }

        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(string inUsuario, string inClave)
        {

            int usuario = dbLogin.iniciarSesion(conexionString, inUsuario, inClave);

            if (usuario == 0)
            {
                // Si la autenticación es exitosa:
                HttpContext.Session.SetString("Usuario", inUsuario);

                var claims = new List<Claim>
                    {
                        new Claim(ClaimTypes.Name, inUsuario)
                    };

                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = true
                };

                HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimsIdentity), authProperties);

                return RedirectToAction("Index", "Empleado");

            }
            else if (usuario == 50001)
            {

                TempData["Error"] = "El usuario ingresado no existe.";

                return View();
            }
            else if (usuario == 50002) {

                TempData["Error"] = "La contraseña ingresada es incorrecta.";

                return View();
            }
            else if (usuario == 50003)
            {

                TempData["Error"] = "El login esta deshabilitado, debe esperar 10 min a que se habilite.";

                return View();
            }
            else
            {

                TempData["Error"] = "Error al iniciar sesión.";

                return View();
            }

            
        }

        [HttpGet]
        public IActionResult Logout()
        {
            HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }
    }
}
