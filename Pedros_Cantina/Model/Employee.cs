using Microsoft.IdentityModel.Logging;
using System;
using System.Collections.Generic;
using System.Text;

namespace Pedros_Cantina.Model
{
    public class Employee
    {

        private int _employeeID;
        private string _firstName;
        private string _lastName;
        private string _phone;
        private string? _email;
        private bool _isActive;
        private bool _isLeader;


        public Employee()
        {
            _employeeID = 1;
            _firstName = "First Name";
            _lastName = "Last Name";
            _phone = "+00 00000000";
            _email = "placeholder@mail.com";
            _isActive = true;
            _isLeader = false;
        }

        public Employee(int iD, string firstName, string lastName, string phone, string? email, bool isActive, bool isLeader)
        {
            _employeeID = iD;
            _firstName = firstName;
            _lastName = lastName;
            _phone = phone;
            _email = email;
            _isActive = isActive;
            _isLeader = isLeader;
        }

        public int EmployeeId { get { return _employeeID; } set { _employeeID = value; } }
        public string FirstName { get { return _firstName; } set { _firstName = value; } }
        public string LastName { get { return _lastName; } set { _lastName = value; } }
        public string Phone { get { return _phone; } set { _phone = value; } }
        public string? Email { get { return _email; } set { _email = value; } }
        public bool IsActive { get { return _isActive; } set { _isActive = value; } }
        public bool IsLeader { get { return _isLeader; } set { _isLeader = value; } }



        public override string ToString()
        {

            string leader = "";
            if (IsLeader)
            {
                leader = "Leader";
            }
            else
            {
                leader = "Worker";
            }


            return $"Name: {FirstName}, Last Name: {LastName}, Active: {IsActive}, Role: {leader}";
        }
    }
}
