using Pedros_Cantina.Model;
using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Text;
using Pedros_Cantina.Connection;

namespace Pedros_Cantina.Repo
{
    public class EmployeeRepo
    {

        private List<Employee> _employees = new List<Employee>();
        public PedroDBConnection DB { get; set; }


        public EmployeeRepo()
        {
            _employees = new List<Employee>();
            DB = new PedroDBConnection();
        }

        public EmployeeRepo(List<Employee> employees, PedroDBConnection dB)
        {
            _employees = employees;
            DB = dB;
        }

        public List<Employee> Employees { get { return _employees; } set { _employees = value; } }


        public List<Employee> ReadAll()
        {
            List<Employee> emp = new List<Employee>();
            DB.ConnectToDatabase();
            string sql = "SELECT * FROM Employee";
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);
           

            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                int ID = (int)reader["EmployeeID"];
                string firstName = (string)reader["FirstName"];
                string lastName = (string)reader["LastName"];
                string phone = (string)reader["Phone"];
                string email = (string)reader["Email"];
                bool isActive = (bool)reader["IsActive"];
                bool isLeader = (bool)reader["IsLeader"];

                Employee e = new Employee(ID, firstName, lastName, phone, email, isActive, isLeader);
                emp.Add(e);
            }


            DB.DisconnectFromDatabase();
            return emp;
        }

        public Employee Create(Employee e)
        {
          
            DB.ConnectToDatabase();
            string sql = $"INSERT INTO Employee (FirstName, LastName, Phone, Email, IsLeader, IsActive) " +
                         $"Values (@FirstName, @LastName, @Phone, @Email, @IsLeader, @IsActive);";
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);

            cmd.Parameters.AddWithValue("@FirstName", e.FirstName);
            cmd.Parameters.AddWithValue("@LastName", e.LastName);
            cmd.Parameters.AddWithValue("@Phone", e.Phone);
            cmd.Parameters.AddWithValue("@Email", e.Email);
            cmd.Parameters.AddWithValue("@IsActive", e.IsActive);
            cmd.Parameters.AddWithValue("@IsLeader", e.IsLeader);
            
            int row = cmd.ExecuteNonQuery();

            DB.DisconnectFromDatabase();

            if (row == 0)
            {
                throw new KeyNotFoundException($"Could not make a new employee.");
            }

          
            return e;
        }

        public Employee Delete(int id)
        {
            Employee e = ReadById(id);
            DB.ConnectToDatabase();
            string sql = $"DELETE FROM Employee WHERE EmployeeID = @EmployeeID";
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);

            cmd.Parameters.AddWithValue("@EmployeeID", id);
           

            int row = cmd.ExecuteNonQuery();

            DB.DisconnectFromDatabase();

            if (row == 0)
            {
                throw new KeyNotFoundException($"Could not delete employee.");
            }

          
            return e;
        }

        public Employee SoftDelete(int id)
        {
            Employee e = ReadById(id);
            DB.ConnectToDatabase();
            string sql = $"UPDATE Employee SET IsActive = 0 WHERE EmployeeID = {id}";
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);

            cmd.Parameters.AddWithValue("@EmployeeID", id);


            int row = cmd.ExecuteNonQuery();

            DB.DisconnectFromDatabase();

            if (row == 0)
            {
                throw new KeyNotFoundException($"Could not soft delete (set activity to 0) employee.");
            }


            return e;
        }

        public Employee Update(int id,Employee newE)
        {

            Employee e = ReadById(id);

            DB.ConnectToDatabase();
            string sql = $"UPDATE Employee SET FirstName = @FirstName, LastName = @LastName, Phone = @Phone, " +
                         $"Email = @Email, IsActive = @IsActive, IsLeader = @IsLeader WHERE EmployeeID = {id}" ;
                        
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);

            cmd.Parameters.AddWithValue("@FirstName", newE.FirstName);
            cmd.Parameters.AddWithValue("@LastName", newE.LastName);
            cmd.Parameters.AddWithValue("@Phone", newE.Phone);
            cmd.Parameters.AddWithValue("@Email", newE.Email);
            cmd.Parameters.AddWithValue("@IsActive", newE.IsActive);
            cmd.Parameters.AddWithValue("@IsLeader", newE.IsLeader);


            int row = cmd.ExecuteNonQuery();

            DB.DisconnectFromDatabase();

            if (row == 0)
            {
                throw new KeyNotFoundException($"Could not update employee.");
            }

            return e;
        }

        public Employee ReadById(int id)
        {

            Employee? e = null;
            DB.ConnectToDatabase();
            string sql = $"SELECT * FROM Employee WHERE EmployeeID = {id}";
            SqlCommand cmd = new SqlCommand(sql, DB.Connection);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                int ID = (int)reader["EmployeeID"];
                string firstName = (string)reader["FirstName"];
                string lastName = (string)reader["LastName"];
                string phone = (string)reader["Phone"];
                string email = (string)reader["Email"];
                bool isActive = (bool)reader["IsActive"];
                bool isLeader = (bool)reader["IsLeader"];

                e = new Employee(ID, firstName, lastName, phone, email, isActive, isLeader);

            }
            else
            {
                DB.DisconnectFromDatabase();
                throw new KeyNotFoundException("Employee not found");
            }

            DB.DisconnectFromDatabase();

            return e;

        }





        public override string ToString()
        {
            string s = "";
            foreach (Employee e in Employees)
            {
                s = $"{e}\n";
            }

            return s;
        }

    }
}
