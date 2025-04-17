# PowerShell Script to update BackgroundProcessing.API code for .NET 9
# This script updates the Program.cs file and creates controller files

# Set the solution path - update this to match your environment
$solutionPath = "C:\Projects\slimbgprocessor"

# Navigate to solution directory
Set-Location $solutionPath

# 1. Update the Program.cs file in BackgroundProcessing.API
$programPath = "BackgroundProcessing.API\Program.cs"
Write-Host "Updating $programPath..." -ForegroundColor Cyan

$programContent = @'
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Weather;
using StockLoader;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register Weather Service
builder.Services.Configure<WeatherSettings>(
    builder.Configuration.GetSection("Weather"));
builder.Services.AddHostedService<WeatherBackgroundService>();
builder.Services.AddSingleton<IWeatherService, WeatherService>();

// Register StockLoader Service
builder.Services.Configure<StockLoaderSettings>(
    builder.Configuration.GetSection("StockLoader"));
builder.Services.AddHostedService<StockLoaderBackgroundService>();
builder.Services.AddSingleton<IStockLoaderService, StockLoaderService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
'@

Set-Content -Path $programPath -Value $programContent -Force
Write-Host "Updated Program.cs" -ForegroundColor Green

# 2. Create/update appsettings.json
$appsettingsPath = "BackgroundProcessing.API\appsettings.json"
Write-Host "Updating $appsettingsPath..." -ForegroundColor Cyan

$appsettingsContent = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Weather": {
    "ApiKey": "your-weather-api-key",
    "UpdateIntervalMinutes": 15,
    "DefaultLocation": "New York"
  },
  "StockLoader": {
    "ApiKey": "your-stock-api-key",
    "UpdateIntervalMinutes": 5,
    "Symbols": ["AAPL", "MSFT", "GOOGL"]
  }
}
'@

Set-Content -Path $appsettingsPath -Value $appsettingsContent -Force
Write-Host "Updated appsettings.json" -ForegroundColor Green

# 3. Create WeatherController.cs
$weatherControllerPath = "BackgroundProcessing.API\Controllers\WeatherController.cs"
Write-Host "Creating $weatherControllerPath..." -ForegroundColor Cyan

$weatherControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;
using Weather;

namespace BackgroundProcessing.API.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherController : ControllerBase
{
    private readonly ILogger<WeatherController> _logger;
    private readonly IWeatherService _weatherService;

    public WeatherController(
        ILogger<WeatherController> logger,
        IWeatherService weatherService)
    {
        _logger = logger;
        _weatherService = weatherService;
    }

    [HttpGet("{location}")]
    public async Task<ActionResult<WeatherData>> GetWeather(string location, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Weather request received for {Location}", location);
        
        var weatherData = await _weatherService.GetLatestWeatherAsync(location, cancellationToken);
        
        if (weatherData == null || weatherData.Location != location)
        {
            // If we don't have data for this location yet, trigger a fetch and wait for it
            _logger.LogInformation("No cached data for {Location}, fetching now", location);
            await _weatherService.FetchWeatherDataAsync(location, cancellationToken);
            weatherData = await _weatherService.GetLatestWeatherAsync(location, cancellationToken);
        }
        
        return Ok(weatherData);
    }

    [HttpPost("refresh/{location}")]
    public async Task<IActionResult> RefreshWeather(string location, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Manual weather refresh triggered for {Location}", location);
        
        await _weatherService.FetchWeatherDataAsync(location, cancellationToken);
        
        return Ok(new { message = $"Weather data refresh for {location} initiated" });
    }
}
'@

New-Item -Path $weatherControllerPath -ItemType File -Force | Out-Null
Set-Content -Path $weatherControllerPath -Value $weatherControllerContent -Force
Write-Host "Created WeatherController.cs" -ForegroundColor Green

# 4. Create StockController.cs
$stockControllerPath = "BackgroundProcessing.API\Controllers\StockController.cs"
Write-Host "Creating $stockControllerPath..." -ForegroundColor Cyan

$stockControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using StockLoader;

namespace BackgroundProcessing.API.Controllers;

[ApiController]
[Route("[controller]")]
public class StockController : ControllerBase
{
    private readonly ILogger<StockController> _logger;
    private readonly IStockLoaderService _stockService;
    private readonly StockLoaderSettings _settings;

    public StockController(
        ILogger<StockController> logger,
        IStockLoaderService stockService,
        IOptions<StockLoaderSettings> settings)
    {
        _logger = logger;
        _stockService = stockService;
        _settings = settings.Value;
    }

    [HttpGet]
    public async Task<ActionResult<List<StockData>>> GetAllStocks(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Request received for all stock data");
        
        var stocksData = await _stockService.GetLatestStockDataAsync(cancellationToken);
        
        if (stocksData == null || !stocksData.Any())
        {
            // If we don't have any data yet, trigger a fetch and wait for it
            _logger.LogInformation("No cached stock data, fetching now");
            await _stockService.FetchStockDataAsync(_settings.Symbols, cancellationToken);
            stocksData = await _stockService.GetLatestStockDataAsync(cancellationToken);
        }
        
        return Ok(stocksData);
    }

    [HttpGet("{symbol}")]
    public async Task<ActionResult<StockData>> GetStock(string symbol, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Stock data request received for {Symbol}", symbol);
        
        var stockData = await _stockService.GetStockDataAsync(symbol, cancellationToken);
        
        if (stockData == null)
        {
            if (_settings.Symbols.Contains(symbol))
            {
                // Symbol is configured but we don't have data yet, trigger a fetch
                var symbolList = new List<string> { symbol };
                await _stockService.FetchStockDataAsync(symbolList, cancellationToken);
                stockData = await _stockService.GetStockDataAsync(symbol, cancellationToken);
                
                if (stockData == null)
                {
                    return NotFound($"Could not fetch data for symbol {symbol}");
                }
            }
            else
            {
                return NotFound($"Symbol {symbol} is not being tracked");
            }
        }
        
        return Ok(stockData);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> RefreshAllStocks(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Manual stock refresh triggered for all symbols");
        
        await _stockService.FetchStockDataAsync(_settings.Symbols, cancellationToken);
        
        return Ok(new { message = "Stock data refresh initiated" });
    }

    [HttpPost("refresh/{symbol}")]
    public async Task<IActionResult> RefreshStock(string symbol, CancellationToken cancellationToken)
    {
        if (!_settings.Symbols.Contains(symbol))
        {
            return NotFound($"Symbol {symbol} is not being tracked");
        }
        
        _logger.LogInformation("Manual stock refresh triggered for {Symbol}", symbol);
        
        var symbolList = new List<string> { symbol };
        await _stockService.FetchStockDataAsync(symbolList, cancellationToken);
        
        return Ok(new { message = $"Stock data refresh for {symbol} initiated" });
    }
}
'@

New-Item -Path $stockControllerPath -ItemType File -Force | Out-Null
Set-Content -Path $stockControllerPath -Value $stockControllerContent -Force
Write-Host "Created StockController.cs" -ForegroundColor Green

# All done
Write-Host "BackgroundProcessing.API updates completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. Create/update Weather models and services" -ForegroundColor White
Write-Host "2. Create/update StockLoader models and services" -ForegroundColor White
Write-Host ""
Write-Host "To build the project, run: dotnet build" -ForegroundColor Cyan.