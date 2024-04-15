using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using Test.Api.AppA.Controllers;

namespace Test.Api.AppA.Tests;

public class APIAControllerTests
{
    [Fact]
    public void ApiAControllerTest()
    {
        var mockLogger = new Mock<ILogger<APIAController>>();

        var controller = new APIAController(mockLogger.Object);

        var result = controller.Add(3, 6);

        result.Should().Be(9);
    }
}