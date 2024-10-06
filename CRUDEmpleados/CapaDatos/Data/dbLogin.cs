using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos.Data
{
    public class dbLogin
    {
        public int iniciarSesion(SqlConnectionStringBuilder connectionString, string inUsuario, string inClave)
        {
            int resultCode = -1;

            string command = "dbo.SP_Login";

            using (SqlConnection conn = new SqlConnection(connectionString.ConnectionString))
            {
                conn.Open();
                using (SqlCommand comando = new SqlCommand(command, conn))
                {
                    comando.CommandType = System.Data.CommandType.StoredProcedure;
                    comando.Parameters.AddWithValue("@username", inUsuario);
                    comando.Parameters.AddWithValue("@password", inClave);
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
