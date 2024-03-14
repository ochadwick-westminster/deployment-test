using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using Test.Api.App.B.Controllers;

namespace Test.Api.App.B.Tests;

public class APIBControllerTests
{
    [Fact]
    public void ApiBControllerTest()
    {
        var mockLogger = new Mock<ILogger<APIBController>>();

        var controller = new APIBController(mockLogger.Object);

        var result = controller.Subtract(3, 6);

        result.Should().Be(-3);
    }
}