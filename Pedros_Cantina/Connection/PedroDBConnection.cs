using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Text;
using Microsoft.Extensions.Configuration;
using System.Reflection;

namespace Pedros_Cantina.Connection
{
    public class PedroDBConnection
    {
        SqlConnection _connection;
        private string _connectionString = "";

       
        public PedroDBConnection(string connectionString)
        {
            
            _connectionString = connectionString;
        }

        public PedroDBConnection()
        {
            var config = new ConfigurationBuilder()
            .AddUserSecrets(Assembly.GetExecutingAssembly(), optional: true)
            .Build();
            string connectionString = config["ConnectionString"];

            _connectionString = connectionString;
        }

        public string ConnectionString { get { return _connectionString; } set { _connectionString = value; } }
        public SqlConnection Connection { get { return _connection; } }

        //Method to connect to Database
        public void ConnectToDatabase()
        {
         
            //Create connection

            _connection = new SqlConnection(_connectionString);

            _connection.Open();

        }

        //Method to disconnect from Database
        public void DisconnectFromDatabase()
        {
            _connection.Close();
        }



    }
}
