using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaObjetos.Objetos
{
    public class clMovimiento
    {
        public int IdEmpleado {  get; set; }
        public string Nombre {  get; set; }
        public string ValorDocumentoIdentidad {  get; set; }
        public DateTime Fecha {  get; set; }
        public decimal Monto {  get; set; }
        public string TipoMovimiento {  get; set; }
        public decimal NuevoSaldo {  get; set; }
        public string Usuario {  get; set; }
        public string PostInIp {  get; set; }
        public DateTime PostTime {  get; set; }
    }
}
