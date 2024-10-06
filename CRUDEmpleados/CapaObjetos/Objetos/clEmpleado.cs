namespace CapaObjetos.Objetos
{
    public class clEmpleado
    {
        public int Id { get; set; }
        public int IdPuesto { get; set; }
        public string NombrePuesto { get; set; }
        public decimal SalarioxHora { get; set; }
        public string ValorDocumentoIdentidad { get; set; }
        public string Nombre { get; set; }
        public DateTime FechaContratacion { get; set; }
        public decimal SaldoVacaciones { get; set; }
        public Boolean EsActivo { get; set; }

    }
}
