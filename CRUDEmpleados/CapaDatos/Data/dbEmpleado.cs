
using CapaObjetos.Objetos;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos.Data
{
    public class dbEmpleado
    {
        public List<clEmpleado> obtenerEmpleados(SqlConnectionStringBuilder connectionString)
        {
            List<clEmpleado> lista = new List<clEmpleado>();

            string command = "dbo.listadoEmpleados";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@inValorDocIdentidad", DBNull.Value);
                    comando.Parameters.AddWithValue("@inNombre", DBNull.Value);
                    comando.Parameters.AddWithValue("@outResultCode", 0);
                    SqlDataReader reader = comando.ExecuteReader();


                    while (reader.Read())
                    {
                        clEmpleado emp = new clEmpleado();
                        emp.Id = reader.GetInt32(0);
                        emp.IdPuesto = reader.GetInt32(1);
                        emp.NombrePuesto = reader.GetString(2);
                        emp.SalarioxHora = reader.GetDecimal(3);
                        emp.ValorDocumentoIdentidad = reader.GetString(4);
                        emp.Nombre = reader.GetString(5);
                        emp.FechaContratacion = reader.GetDateTime(6);
                        emp.SaldoVacaciones = reader.GetDecimal(7);
                        emp.EsActivo = reader.GetBoolean(8);


                        lista.Add(emp);
                    }
                }
                conn.Close();
            }
            return lista;
        }


        public int insertarEmpleado(SqlConnectionStringBuilder connectionString, string cedula, string nombre, string nombrePuesto, DateTime fechaContratacion)
        {
            int resultCode = -1;

            string command = "dbo.SP_Insert_Employee";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@cedula", cedula);
                    comando.Parameters.AddWithValue("@name", nombre);
                    comando.Parameters.AddWithValue("@nombrePuesto", nombrePuesto);
                    comando.Parameters.AddWithValue("@fechaContratacion", fechaContratacion);
                    comando.Parameters.AddWithValue("@outResultCode", 0);
                    SqlDataReader reader = comando.ExecuteReader();


                    while (reader.Read())
                    {
                        resultCode = reader.GetInt32(0);
                    }
                }
                conn.Close();
            }
            return resultCode;
        }
    }
}
