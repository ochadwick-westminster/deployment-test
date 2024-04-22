using Microsoft.AspNetCore.Mvc;

namespace Test.Api.AppA.Controllers;
[ApiController]
[Route("[controller]")]
public class APIAController : ControllerBase
{
    private readonly ILogger<APIAController> _logger;
    private readonly string password = "123e3refj4w";

    private string connectionString = "Server=myServerAddress;Database=myDataBase;User Id=myUsername;Password=myPassword123e;";


    public APIAController(ILogger<APIAController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "Add")]
    public int Add(int x, int y)
    {
        return Core.Math.add(x, y);
    }
}
