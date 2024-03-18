using Microsoft.AspNetCore.Mvc;

namespace Test.Api.App.A.Controllers;
[ApiController]
[Route("[controller]")]
public class APIAController : ControllerBase
{
    private readonly ILogger<APIAController> _logger;
    private readonly string password = "123";

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
