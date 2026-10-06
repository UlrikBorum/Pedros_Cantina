
using Microsoft.IdentityModel.Tokens;
using Pedros_Cantina.Connection;
using Pedros_Cantina.Model;
using Pedros_Cantina.Repo;




// Assembling connection to the DB and creating an Employee Repository
PedroDBConnection db = new PedroDBConnection();
List <Employee> list = new List<Employee>();
EmployeeRepo repo = new EmployeeRepo(list, db);



// -- Showing Create part of CRUD --
Employee newEmployee = new Employee(0, "John", "Doe", "1234567890", "john.doe@example.com", true, false);
Console.WriteLine("Created new employee:");
Console.WriteLine(repo.Create(newEmployee));



// -- Showing Read All part of CRUD --
Console.WriteLine("\nRetrieving all employees:");
foreach (Employee e in repo.ReadAll())
{
    Console.WriteLine(e);
}


// -- Showing Read part of CRUD --
//Console.WriteLine("\nTrying to find Employee with ID: 10:");
//Console.WriteLine(repo.ReadById(10));



// -- Showing Delete (hard) part of CRUD -- 
try
{
    Employee eDeleted = repo.ReadById(8);
    Console.WriteLine("\nTrying to delete Employee with ID: 11:");
    Console.WriteLine($"{repo.Delete(8)} successfully deleted.");
}
catch (KeyNotFoundException ex)
{
    Console.WriteLine($"Error: The requested key was not found. {ex.Message}");
}
// Note: Only works if the employee have no assignments


// -- Showing Delete (soft) part of CRUD --
try
{
    Employee eSoftDeleted = repo.ReadById(9);
    Console.WriteLine("\ntrying to make Employee with ID: 10 not active");
    repo.SoftDelete(9);
    Console.WriteLine(repo.ReadById(9));
}
catch (KeyNotFoundException ex)
{
    Console.WriteLine($"Error; the requested key was not found: {ex.Message}");
}


// -- Showing Update part of CRUD --
Employee eUpdated = new Employee(10, "Jane", "Doe", "1234567890", "Jane.doe@example.com", true, false);

Console.WriteLine("\nTrying to update Employee with ID: 9:");
Console.WriteLine($"Before: {repo.ReadById(10)}");

// Updating the employee to eUpdated, but keeping the old employee object to be able to revert back. 
Employee eRevertBack = repo.Update(10, eUpdated);

Console.WriteLine($"After: {repo.ReadById(10)}");

repo.Update(10, eRevertBack);
Console.WriteLine($"Reverting back to original: {repo.ReadById(10)}");

