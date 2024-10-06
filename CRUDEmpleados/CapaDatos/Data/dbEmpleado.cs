
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
        object ConvertToDBNull(string value)
        {
            return string.IsNullOrEmpty(value) ? DBNull.Value : value;
        }

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

        public clEmpleado obtenerEmpleado(SqlConnectionStringBuilder connectionString, string inEmpleado)
        {
            clEmpleado emp = new clEmpleado();

            string command = "dbo.SP_Get_Employee";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@cedula", inEmpleado);
                    comando.Parameters.AddWithValue("@outResultCode", 0);
                    SqlDataReader reader = comando.ExecuteReader();


                    while (reader.Read())
                    {
                        emp.ValorDocumentoIdentidad = reader.GetString(0);
                        emp.Nombre = reader.GetString(1);
                        emp.NombrePuesto = reader.GetString(2);
                        emp.SaldoVacaciones = reader.GetDecimal(3);

                    }
                }
                conn.Close();
            }
            return emp;
        }


        public int insertarEmpleado(SqlConnectionStringBuilder connectionString, clEmpleado inEmpleado)
        {
            int resultCode = -1;

            string command = "dbo.SP_Insert_Employee";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@cedula", inEmpleado.ValorDocumentoIdentidad);
                    comando.Parameters.AddWithValue("@name", inEmpleado.Nombre);
                    comando.Parameters.AddWithValue("@nombrePuesto", inEmpleado.NombrePuesto);
                    comando.Parameters.AddWithValue("@fechaContratacion", inEmpleado.FechaContratacion);
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


        public int editarEmpleado(SqlConnectionStringBuilder connectionString, clEmpleado inEmpleado)
        {
            int resultCode = -1;

            string command = "dbo.SP_Update_Employee";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@cedula", inEmpleado.ValorDocumentoIdentidadOriginal);
                    comando.Parameters.AddWithValue("@cedula_updated", ConvertToDBNull(inEmpleado.ValorDocumentoIdentidad));
                    comando.Parameters.AddWithValue("@name_updated", ConvertToDBNull(inEmpleado.Nombre));
                    comando.Parameters.AddWithValue("@nombrePuesto_updated", ConvertToDBNull(inEmpleado.NombrePuesto));
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


        public int eliminarEmpleado(SqlConnectionStringBuilder connectionString, clEmpleado inEmpleado)
        {
            int resultCode = -1;

            string command = "dbo.SP_Delete_Employee";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@cedulaDeleted", inEmpleado.ValorDocumentoIdentidad);
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
