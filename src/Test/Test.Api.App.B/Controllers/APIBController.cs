using Microsoft.AspNetCore.Mvc;
using Test.Core;

namespace Test.Api.App.B.Controllers;
[ApiController]
[Route("[controller]")]
public class APIBController : ControllerBase
{
    private readonly ILogger<APIBController> _logger;

    public APIBController(ILogger<APIBController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "Subtract")]
    public int Get(int x, int y)
    {
        return Core.Math.subtract(x, y);
    }
}
