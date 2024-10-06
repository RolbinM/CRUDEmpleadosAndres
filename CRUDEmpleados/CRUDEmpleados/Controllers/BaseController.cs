using CapaDatos;
using CapaDatos.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace CRUDEmpleados.Controllers
{
    public class BaseController : Controller
    {
        /* Manejo de Session y appsettings */
        protected readonly IHttpContextAccessor contextAccessor;
        protected IConfiguration configuration;

        /* Objeto de Conexión */
        public SqlConnectionStringBuilder conexionString = new SqlConnectionStringBuilder();

        /* Instancias de la CapaDatos */
        public dbConexion dbConexion = new dbConexion();

        public dbLogin dbLogin = new dbLogin();
        public dbEmpleado dbEmpleado = new dbEmpleado();
        public dbPuesto dbPuesto = new dbPuesto();
        

        public BaseController(IHttpContextAccessor _contextAccessor, IConfiguration _configuration)
        {
            this.contextAccessor = _contextAccessor;
            this.configuration = _configuration;

            // Configuración conexión
            string servidor = configuration.GetValue<string>("Servidor");
            string baseDatos = configuration.GetValue<string>("BaseDatos");
            string usuario = configuration.GetValue<string>("Usuario");
            string clave = configuration.GetValue<string>("Clave");
            
            this.conexionString = dbConexion.obtenerConexion(servidor, baseDatos, usuario, clave);
        }
    }
}
