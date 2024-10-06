using CapaObjetos.Objetos;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos.Data
{
    public class dbPuesto
    {
        public List<clPuesto> obtenerPuesto(SqlConnectionStringBuilder connectionString)
        {
            List<clPuesto> lista = new List<clPuesto>();

            string command = "dbo.SP_Listar_Puestos";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    SqlDataReader reader = comando.ExecuteReader();


                    while (reader.Read())
                    {
                        clPuesto puesto = new clPuesto();
                        puesto.Id = reader.GetInt32(0);
                        puesto.Nombre = reader.GetString(1);
                        puesto.SalarioxHora = reader.GetDecimal(2);

                        lista.Add(puesto);
                    }
                }
                conn.Close();
            }
            return lista;
        }
    }
}
