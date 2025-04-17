# PowerShell Script to add a test project with NSubstitute to the BackgroundProcessing solution
# This script creates an xUnit test project with NSubstitute for mocking

# Set the solution path - update this to match your environment
$solutionPath = "C:\Projects\slimbgprocessor"

# Navigate to solution directory
Set-Location $solutionPath

# 1. Create the test project
Write-Host "Creating test project..." -ForegroundColor Cyan
dotnet new xunit --framework net9.0 --name BackgroundProcessing.Tests --output BackgroundProcessing.Tests

# 2. Add project references to the test project
Write-Host "Adding project references to test project..." -ForegroundColor Cyan
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj reference BackgroundProcessing.API/BackgroundProcessing.API.csproj
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj reference Weather/Weather.csproj
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj reference StockLoader/StockLoader.csproj

# 3. Add the test project to the solution
Write-Host "Adding test project to solution..." -ForegroundColor Cyan
dotnet sln add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj

# 4. Add NSubstitute and other testing packages
Write-Host "Adding NSubstitute and other testing packages..." -ForegroundColor Cyan
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj package NSubstitute
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj package NSubstitute.Analyzers.CSharp
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj package FluentAssertions
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj package coverlet.collector
dotnet add BackgroundProcessing.Tests/BackgroundProcessing.Tests.csproj package Microsoft.NET.Test.Sdk

# 5. Remove default test file
Remove-Item -Path "BackgroundProcessing.Tests\UnitTest1.cs" -ErrorAction SilentlyContinue

# 6. Create directory structure for test files
Write-Host "Creating directory structure for test files..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "BackgroundProcessing.Tests\Weather" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "BackgroundProcessing.Tests\StockLoader" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "BackgroundProcessing.Tests\API" -ErrorAction SilentlyContinue | Out-Null

# 7. Create test files for WeatherService
$weatherServiceTestPath = "BackgroundProcessing.Tests\Weather\WeatherServiceTests.cs"
Write-Host "Creating $weatherServiceTestPath..." -ForegroundColor Cyan

$weatherServiceTestContent = @'
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
'@

New-Item -Path $weatherServiceTestPath -ItemType File -Force | Out-Null
Set-Content -Path $weatherServiceTestPath -Value $weatherServiceTestContent -Force
Write-Host "Created WeatherServiceTests.cs" -ForegroundColor Green

# 8. Create test files for StockLoaderService
$stockServiceTestPath = "BackgroundProcessing.Tests\StockLoader\StockLoaderServiceTests.cs"
Write-Host "Creating $stockServiceTestPath..." -ForegroundColor Cyan

$stockServiceTestContent = @'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NSubstitute;
using StockLoader.Models;
using StockLoader.Services;
using Xunit;

namespace BackgroundProcessing.Tests.StockLoader;

public class StockLoaderServiceTests
{
    private readonly ILogger<StockLoaderService> _logger;
    private readonly IOptions<StockLoaderSettings> _settings;
    private readonly StockLoaderService _service;
    private readonly List<string> _testSymbols = new() { "TEST", "MOCK" };

    public StockLoaderServiceTests()
    {
        // Setup mocks with NSubstitute
        _logger = Substitute.For<ILogger<StockLoaderService>>();
        
        // Create test settings
        var stockSettings = new StockLoaderSettings
        {
            ApiKey = "test-api-key",
            UpdateIntervalMinutes = 5,
            Symbols = new List<string> { "DEFAULT" }
        };
        
        _settings = Substitute.For<IOptions<StockLoaderSettings>>();
        _settings.Value.Returns(stockSettings);
        
        // Create the service with mocked dependencies
        _service = new StockLoaderService(_logger, _settings);
    }

    [Fact]
    public async Task GetLatestStockDataAsync_WhenNoDataExists_ReturnsEmptyList()
    {
        // Act
        var result = await _service.GetLatestStockDataAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetStockDataAsync_WhenNoDataExists_ReturnsNull()
    {
        // Act
        var result = await _service.GetStockDataAsync("TEST");

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task FetchStockDataAsync_ShouldCreateData()
    {
        // Act
        await _service.FetchStockDataAsync(_testSymbols);
        var result = await _service.GetLatestStockDataAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().HaveCount(_testSymbols.Count);
        result.Select(s => s.Symbol).Should().BeEquivalentTo(_testSymbols);
        result.All(s => s.Timestamp.IsCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(10))).Should().BeTrue();
    }

    [Fact]
    public async Task GetStockDataAsync_AfterFetch_ReturnsCachedData()
    {
        // Arrange
        var symbol = _testSymbols.First();
        await _service.FetchStockDataAsync(_testSymbols);

        // Act
        var result = await _service.GetStockDataAsync(symbol);

        // Assert
        result.Should().NotBeNull();
        result!.Symbol.Should().Be(symbol);
    }

    [Fact]
    public async Task FetchStockDataAsync_WithCancellation_ShouldCancel()
    {
        // Arrange
        var cts = new CancellationTokenSource();
        cts.Cancel(); // Cancel immediately

        // Act & Assert
        await Assert.ThrowsAsync<OperationCanceledException>(() => 
            _service.FetchStockDataAsync(_testSymbols, cts.Token));
    }
}
'@

New-Item -Path $stockServiceTestPath -ItemType File -Force | Out-Null
Set-Content -Path $stockServiceTestPath -Value $stockServiceTestContent -Force
Write-Host "Created StockLoaderServiceTests.cs" -ForegroundColor Green

# 9. Create test file for WeatherController
$weatherControllerTestPath = "BackgroundProcessing.Tests\API\WeatherControllerTests.cs"
Write-Host "Creating $weatherControllerTestPath..." -ForegroundColor Cyan

$weatherControllerTestContent = @'
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
'@

New-Item -Path $weatherControllerTestPath -ItemType File -Force | Out-Null
Set-Content -Path $weatherControllerTestPath -Value $weatherControllerTestContent -Force
Write-Host "Created WeatherControllerTests.cs" -ForegroundColor Green

# 10. Create test file for StockController
$stockControllerTestPath = "BackgroundProcessing.Tests\API\StockControllerTests.cs"
Write-Host "Creating $stockControllerTestPath..." -ForegroundColor Cyan

$stockControllerTestContent = @'
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BackgroundProcessing.API.Controllers;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NSubstitute;
using StockLoader.Models;
using StockLoader.Services;
using Xunit;

namespace BackgroundProcessing.Tests.API;

public class StockControllerTests
{
    private readonly ILogger<StockController> _logger;
    private readonly IStockLoaderService _stockService;
    private readonly IOptions<StockLoaderSettings> _settings;
    private readonly StockController _controller;
    private readonly string _testSymbol = "TEST";
    private readonly List<StockData> _testData;

    public StockControllerTests()
    {
        // Setup mocks
        _logger = Substitute.For<ILogger<StockController>>();
        _stockService = Substitute.For<IStockLoaderService>();
        
        // Create test settings
        var stockSettings = new StockLoaderSettings
        {
            ApiKey = "test-api-key",
            UpdateIntervalMinutes = 5,
            Symbols = new List<string> { _testSymbol, "MOCK" }
        };
        
        _settings = Substitute.For<IOptions<StockLoaderSettings>>();
        _settings.Value.Returns(stockSettings);
        
        // Create test stock data
        _testData = new List<StockData>
        {
            new() { Symbol = _testSymbol, Price = 123.45m, Volume = 1000 },
            new() { Symbol = "MOCK", Price = 67.89m, Volume = 2000 }
        };
        
        // Create controller with mocked dependencies
        _controller = new StockController(_logger, _stockService, _settings);
    }

    [Fact]
    public async Task GetAllStocks_WhenDataExists_ReturnsOkWithData()
    {
        // Arrange
        _stockService.GetLatestStockDataAsync(Arg.Any<CancellationToken>())
            .Returns(_testData);

        // Act
        var result = await _controller.GetAllStocks(CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var stockData = okResult.Value.Should().BeOfType<List<StockData>>().Subject;
        stockData.Should().BeEquivalentTo(_testData);
        
        // Verify service was called
        await _stockService.Received(1).GetLatestStockDataAsync(Arg.Any<CancellationToken>());
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetAllStocks_WhenNoDataExists_FetchesData()
    {
        // Arrange
        _stockService.GetLatestStockDataAsync(Arg.Any<CancellationToken>())
            .Returns(new List<StockData>(), _testData);

        // Act
        var result = await _controller.GetAllStocks(CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var stockData = okResult.Value.Should().BeOfType<List<StockData>>().Subject;
        stockData.Should().BeEquivalentTo(_testData);
        
        // Verify service calls
        await _stockService.Received(2).GetLatestStockDataAsync(Arg.Any<CancellationToken>());
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.SequenceEqual(_settings.Value.Symbols)), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetStock_WhenDataExists_ReturnsOkWithData()
    {
        // Arrange
        var stockData = _testData.First(s => s.Symbol == _testSymbol);
        _stockService.GetStockDataAsync(_testSymbol, Arg.Any<CancellationToken>())
            .Returns(stockData);

        // Act
        var result = await _controller.GetStock(_testSymbol, CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var returnedData = okResult.Value.Should().BeOfType<StockData>().Subject;
        returnedData.Should().Be(stockData);
        
        // Verify service was called
        await _stockService.Received(1).GetStockDataAsync(_testSymbol, Arg.Any<CancellationToken>());
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetStock_WhenSymbolNotTracked_ReturnsNotFound()
    {
        // Arrange
        var unknownSymbol = "UNKNOWN";
        
        // Act
        var result = await _controller.GetStock(unknownSymbol, CancellationToken.None);

        // Assert
        result.Result.Should().BeOfType<NotFoundObjectResult>();
    }

    [Fact]
    public async Task RefreshAllStocks_CallsService_ReturnsOk()
    {
        // Act
        var result = await _controller.RefreshAllStocks(CancellationToken.None);

        // Assert
        result.Should().BeOfType<OkObjectResult>();
        
        // Verify service was called with all configured symbols
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.SequenceEqual(_settings.Value.Symbols)), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RefreshStock_WithValidSymbol_CallsService_ReturnsOk()
    {
        // Act
        var result = await _controller.RefreshStock(_testSymbol, CancellationToken.None);

        // Assert
        result.Should().BeOfType<OkObjectResult>();
        
        // Verify service was called with just the one symbol
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.Count == 1 && list[0] == _testSymbol), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RefreshStock_WithInvalidSymbol_ReturnsNotFound()
    {
        // Arrange
        var unknownSymbol = "UNKNOWN";
        
        // Act
        var result = await _controller.RefreshStock(unknownSymbol, CancellationToken.None);

        // Assert
        result.Should().BeOfType<NotFoundObjectResult>();
        
        // Verify service was not called
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }
}
'@

New-Item -Path $stockControllerTestPath -ItemType File -Force | Out-Null
Set-Content -Path $stockControllerTestPath -Value $stockControllerTestContent -Force
Write-Host "Created StockControllerTests.cs" -ForegroundColor Green

# 11. Create test extension helper for time comparisons
$testExtensionsPath = "BackgroundProcessing.Tests\TestExtensions.cs"
Write-Host "Creating $testExtensionsPath..." -ForegroundColor Cyan

$testExtensionsContent = @'
using System;

namespace BackgroundProcessing.Tests;

/// <summary>
/// Extension methods for testing
/// </summary>
public static class TestExtensions
{
    /// <summary>
    /// Checks if a DateTime is close to another DateTime within a specified tolerance
    /// </summary>
    public static bool IsCloseTo(this DateTime source, DateTime target, TimeSpan tolerance)
    {
        return Math.Abs((source - target).TotalMilliseconds) <= tolerance.TotalMilliseconds;
    }
}
'@

New-Item -Path $testExtensionsPath -ItemType File -Force | Out-Null
Set-Content -Path $testExtensionsPath -Value $testExtensionsContent -Force
Write-Host "Created TestExtensions.cs" -ForegroundColor Green

# 12. Create/update global usings file
$globalUsingsPath = "BackgroundProcessing.Tests\GlobalUsings.cs"
Write-Host "Creating $globalUsingsPath..." -ForegroundColor Cyan

$globalUsingsContent = @'
global using System;
global using System.Threading;
global using System.Threading.Tasks;
global using System.Collections.Generic;
global using System.Linq;
global using Xunit;
global using NSubstitute;
global using FluentAssertions;
'@

New-Item -Path $globalUsingsPath -ItemType File -Force | Out-Null
Set-Content -Path $globalUsingsPath -Value $globalUsingsContent -Force
Write-Host "Created GlobalUsings.cs" -ForegroundColor Green

# All done
Write-Host "Test project setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To run tests, use:" -ForegroundColor Magenta
Write-Host "dotnet test" -ForegroundColor White
Write-Host ""
Write-Host "To run tests with coverage:" -ForegroundColor Magenta
Write-Host "dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura" -ForegroundColor White
Write-Host ""
Write-Host "Test structure overview:" -ForegroundColor Yellow
Write-Host "  - Service tests:" -ForegroundColor White
Write-Host "    - WeatherServiceTests" -ForegroundColor White
Write-Host "    - StockLoaderServiceTests" -ForegroundColor White
Write-Host "  - Controller tests:" -ForegroundColor White
Write-Host "    - WeatherControllerTests" -ForegroundColor White
Write-Host "    - StockControllerTests" -ForegroundColor White