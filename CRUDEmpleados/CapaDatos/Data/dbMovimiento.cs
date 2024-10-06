using CapaObjetos.Objetos;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos.Data
{
    public class dbMovimiento
    {
        object ConvertToDBNull(string value)
        {
            return string.IsNullOrEmpty(value) ? DBNull.Value : value;
        }

        public List<clMovimiento> obtenerMovimientos(SqlConnectionStringBuilder connectionString, string inEmpleado)
        {
            List<clMovimiento> lista = new List<clMovimiento>();

            string command = "dbo.listadoMovimientos";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@inValorDocIdentidad", inEmpleado);
                    comando.Parameters.AddWithValue("@outResultCode", 0);
                    SqlDataReader reader = comando.ExecuteReader();


                    while (reader.Read())
                    {
                        clMovimiento mov = new clMovimiento();
                        mov.IdEmpleado = reader.GetInt32(0);
                        mov.Nombre = reader.GetString(1);
                        mov.ValorDocumentoIdentidad = reader.GetString(2);
                        mov.Fecha = reader.GetDateTime(3);
                        mov.Monto = reader.GetDecimal(4);
                        mov.TipoMovimiento = reader.GetString(5);
                        mov.NuevoSaldo = reader.GetDecimal(6);
                        mov.Usuario = reader.GetString(7);
                        mov.PostInIp = reader.GetString(8);
                        mov.PostTime = reader.GetDateTime(9);


                        lista.Add(mov);
                    }
                }
                conn.Close();
            }
            return lista;
        }
    }
}
