using System.Data.SqlClient;

namespace Test.Api.AppA;

public class TestQuery
{
    public TestQuery()
    {
        
    }

    public void Query()
    {
        string userInput = "'; DROP TABLE Users; --";
        string connectionString = "your_connection_string_here";
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();
            string query = "SELECT * FROM Users WHERE Name = '" + userInput + "'";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Console.WriteLine(reader[0].ToString());
                    }
                }
            }
        }
    }
}
