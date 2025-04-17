using System.Threading;
using System.Threading.Tasks;
using BackgroundProcessing.API.Controllers;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using NSubstitute;
using Weather.Models;
using Weather.Services;
using Xunit;

namespace BackgroundProcessing.Tests.API;

public class WeatherControllerTests
{
    private readonly ILogger<WeatherController> _logger;
    private readonly IWeatherService _weatherService;
    private readonly WeatherController _controller;
    private readonly string _testLocation = "TestCity";
    private readonly WeatherData _testData;

    public WeatherControllerTests()
    {
        // Setup mocks
        _logger = Substitute.For<ILogger<WeatherController>>();
        _weatherService = Substitute.For<IWeatherService>();
        
        // Create test weather data
        _testData = new WeatherData
        {
            Location = _testLocation,
            Temperature = 22.5,
            Humidity = 65,
            Condition = "Sunny"
        };
        
        // Create controller with mocked dependencies
        _controller = new WeatherController(_logger, _weatherService);
    }

    [Fact]
    public async Task GetWeather_WhenDataExists_ReturnsOkWithData()
    {
        // Arrange
        _weatherService.GetLatestWeatherAsync(_testLocation, Arg.Any<CancellationToken>())
            .Returns(_testData);

        // Act
        var result = await _controller.GetWeather(_testLocation, CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var weatherData = okResult.Value.Should().BeOfType<WeatherData>().Subject;
        weatherData.Should().Be(_testData);
        
        // Verify service was called
        await _weatherService.Received(1).GetLatestWeatherAsync(_testLocation, Arg.Any<CancellationToken>());
        await _weatherService.DidNotReceive().FetchWeatherDataAsync(Arg.Any<string>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetWeather_WhenNoDataExists_FetchesData()
    {
        // Arrange
        _weatherService.GetLatestWeatherAsync(_testLocation, Arg.Any<CancellationToken>())
            .Returns((WeatherData?)null, _testData);

        // Act
        var result = await _controller.GetWeather(_testLocation, CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var weatherData = okResult.Value.Should().BeOfType<WeatherData>().Subject;
        weatherData.Should().Be(_testData);
        
        // Verify service calls
        await _weatherService.Received(2).GetLatestWeatherAsync(_testLocation, Arg.Any<CancellationToken>());
        await _weatherService.Received(1).FetchWeatherDataAsync(_testLocation, Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RefreshWeather_CallsService_ReturnsOk()
    {
        // Act
        var result = await _controller.RefreshWeather(_testLocation, CancellationToken.None);

        // Assert
        result.Should().BeOfType<OkObjectResult>();
        
        // Verify service was called
        await _weatherService.Received(1).FetchWeatherDataAsync(_testLocation, Arg.Any<CancellationToken>());
    }
}
