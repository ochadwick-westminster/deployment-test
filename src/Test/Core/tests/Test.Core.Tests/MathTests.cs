using FluentAssertions;

namespace Test.Core.Tests;

public class MathTests
{
    [Fact]
    public void AddTest()
    {
        int x = 2; 
        int y = 3;

        int result = Math.add(x, y);

        result.Should().Be(x + y);
    }

    [Fact]
    public void AddTestNegatives()
    {
        int x = -2;
        int y = 3;

        int result = Math.add(x, y);

        result.Should().Be(x + y);
    }
}