using Microsoft.AspNetCore.Mvc;
using Test.Core;

namespace Test.Api.App.A.Controllers;
[ApiController]
[Route("[controller]")]
public class APIAController : ControllerBase
{
    private readonly ILogger<APIAController> _logger;

    public APIAController(ILogger<APIAController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "Add")]
    public int Get(int x, int y)
    {
        return Core.Math.add(x, y);
    }
}
