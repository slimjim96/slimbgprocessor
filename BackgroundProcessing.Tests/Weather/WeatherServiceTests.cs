using System;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NSubstitute;
using Weather.Models;
using Weather.Services;
using Xunit;

namespace BackgroundProcessing.Tests.Weather;

public class WeatherServiceTests
{
    private readonly ILogger<WeatherService> _logger;
    private readonly IOptions<WeatherSettings> _settings;
    private readonly WeatherService _service;
    private readonly string _testLocation = "TestCity";

    public WeatherServiceTests()
    {
        // Setup mocks with NSubstitute
        _logger = Substitute.For<ILogger<WeatherService>>();
        
        // Create test settings
        var weatherSettings = new WeatherSettings
        {
            ApiKey = "test-api-key",
            DefaultLocation = "DefaultCity",
            UpdateIntervalMinutes = 15
        };
        
        _settings = Substitute.For<IOptions<WeatherSettings>>();
        _settings.Value.Returns(weatherSettings);
        
        // Create the service with mocked dependencies
        _service = new WeatherService(_logger, _settings);
    }

    [Fact]
    public async Task GetLatestWeatherAsync_WhenNoDataExists_ReturnsNull()
    {
        // Act
        var result = await _service.GetLatestWeatherAsync(_testLocation);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task FetchWeatherDataAsync_ShouldCreateData()
    {
        // Act
        await _service.FetchWeatherDataAsync(_testLocation);
        var result = await _service.GetLatestWeatherAsync(_testLocation);

        // Assert
        result.Should().NotBeNull();
        result!.Location.Should().Be(_testLocation);
        result.Timestamp.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(10));
    }

    [Fact]
    public async Task GetLatestWeatherAsync_AfterFetch_ReturnsCachedData()
    {
        // Arrange
        await _service.FetchWeatherDataAsync(_testLocation);

        // Act
        var result1 = await _service.GetLatestWeatherAsync(_testLocation);
        var result2 = await _service.GetLatestWeatherAsync(_testLocation);

        // Assert
        result1.Should().NotBeNull();
        result2.Should().NotBeNull();
        result1.Should().BeSameAs(result2); // Should return the same cached instance
    }

    [Fact]
    public async Task FetchWeatherDataAsync_WithCancellation_ShouldCancel()
    {
        // Arrange
        var cts = new CancellationTokenSource();
        cts.Cancel(); // Cancel immediately

        // Act & Assert
        await Assert.ThrowsAsync<OperationCanceledException>(() => 
            _service.FetchWeatherDataAsync(_testLocation, cts.Token));
    }
}
