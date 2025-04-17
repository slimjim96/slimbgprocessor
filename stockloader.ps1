# PowerShell Script to update StockLoader project for .NET 9
# This script creates the necessary files for the StockLoader project

# Set the solution path - update this to match your environment
$solutionPath = "C:\Projects\slimbgprocessor"

# Navigate to solution directory
Set-Location $solutionPath

# 1. Create StockLoaderSettings.cs model
$stockSettingsPath = "StockLoader\Models\StockLoaderSettings.cs"
Write-Host "Creating $stockSettingsPath..." -ForegroundColor Cyan

$stockSettingsContent = @'
namespace StockLoader.Models;

/// <summary>
/// Configuration settings for the StockLoader service
/// </summary>
public class StockLoaderSettings
{
    /// <summary>
    /// API key for stock data provider
    /// </summary>
    public string ApiKey { get; set; } = string.Empty;
    
    /// <summary>
    /// Interval in minutes between automatic stock data updates
    /// </summary>
    public int UpdateIntervalMinutes { get; set; } = 5;
    
    /// <summary>
    /// List of stock symbols to track
    /// </summary>
    public List<string> Symbols { get; set; } = new List<string>();
}
'@

New-Item -Path $stockSettingsPath -ItemType File -Force | Out-Null
Set-Content -Path $stockSettingsPath -Value $stockSettingsContent -Force
Write-Host "Created StockLoaderSettings.cs" -ForegroundColor Green

# 2. Create StockData.cs model
$stockDataPath = "StockLoader\Models\StockData.cs"
Write-Host "Creating $stockDataPath..." -ForegroundColor Cyan

$stockDataContent = @'
namespace StockLoader.Models;

/// <summary>
/// Represents stock market data for a specific symbol
/// </summary>
public class StockData
{
    /// <summary>
    /// The stock symbol (e.g., AAPL, MSFT)
    /// </summary>
    public string Symbol { get; set; } = string.Empty;
    
    /// <summary>
    /// Current stock price
    /// </summary>
    public decimal Price { get; set; }
    
    /// <summary>
    /// Change in price from previous close
    /// </summary>
    public decimal Change { get; set; }
    
    /// <summary>
    /// Percentage change from previous close
    /// </summary>
    public decimal ChangePercent { get; set; }
    
    /// <summary>
    /// Trading volume
    /// </summary>
    public long Volume { get; set; }
    
    /// <summary>
    /// When this stock data was retrieved
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
'@

New-Item -Path $stockDataPath -ItemType File -Force | Out-Null
Set-Content -Path $stockDataPath -Value $stockDataContent -Force
Write-Host "Created StockData.cs" -ForegroundColor Green

# 3. Create IStockLoaderService.cs interface
$stockServiceInterfacePath = "StockLoader\Services\IStockLoaderService.cs"
Write-Host "Creating $stockServiceInterfacePath..." -ForegroundColor Cyan

$stockServiceInterfaceContent = @'
using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Interface for stock market data operations
/// </summary>
public interface IStockLoaderService
{
    /// <summary>
    /// Fetches stock data for a list of symbols
    /// </summary>
    /// <param name="symbols">The stock symbols to fetch data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A task representing the asynchronous operation</returns>
    Task FetchStockDataAsync(List<string> symbols, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets the latest cached data for all stocks
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A list of stock data objects</returns>
    Task<List<StockData>> GetLatestStockDataAsync(CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets the latest cached data for a specific stock symbol
    /// </summary>
    /// <param name="symbol">The stock symbol to get data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The stock data, or null if no data exists for the symbol</returns>
    Task<StockData?> GetStockDataAsync(string symbol, CancellationToken cancellationToken = default);
}
'@

New-Item -Path $stockServiceInterfacePath -ItemType File -Force | Out-Null
Set-Content -Path $stockServiceInterfacePath -Value $stockServiceInterfaceContent -Force
Write-Host "Created IStockLoaderService.cs" -ForegroundColor Green

# 4. Create StockLoaderService.cs implementation
$stockServicePath = "StockLoader\Services\StockLoaderService.cs"
Write-Host "Creating $stockServicePath..." -ForegroundColor Cyan

$stockServiceContent = @'
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Service for fetching and managing stock market data
/// </summary>
public class StockLoaderService : IStockLoaderService
{
    private readonly ILogger<StockLoaderService> _logger;
    private readonly StockLoaderSettings _settings;
    private readonly Dictionary<string, StockData> _cache = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Initializes a new instance of the StockLoaderService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Stock loader settings</param>
    public StockLoaderService(
        ILogger<StockLoaderService> logger,
        IOptions<StockLoaderSettings> settings)
    {
        _logger = logger;
        _settings = settings.Value;
    }

    /// <summary>
    /// Fetches stock data for a list of symbols
    /// </summary>
    /// <param name="symbols">The stock symbols to fetch data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task FetchStockDataAsync(List<string> symbols, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching stock data for {SymbolCount} symbols", symbols.Count);
        
        try
        {
            // In a real implementation, you would call a stock market API here
            // using the _settings.ApiKey
            // This is just a simulation with random data
            await Task.Delay(300, cancellationToken); // Simulate API call
            
            var random = new Random();
            var timestamp = DateTime.UtcNow;
            
            foreach (var symbol in symbols)
            {
                // Generate consistent but semi-random base price for each symbol
                var basePrice = Math.Abs(symbol.GetHashCode() % 1000) + 10;
                
                // Add some random variation
                var price = basePrice + (decimal)(random.NextDouble() * 10 - 5);
                var change = (decimal)(random.NextDouble() * 4 - 2);
                var volume = random.Next(10000, 1000000);
                
                // Create stock data object
                var stockData = new StockData
                {
                    Symbol = symbol,
                    Price = Math.Round(price, 2),
                    Change = Math.Round(change, 2),
                    ChangePercent = Math.Round(change / price * 100, 2),
                    Volume = volume,
                    Timestamp = timestamp
                };
                
                // Update cache
                _cache[symbol] = stockData;
                
                _logger.LogDebug("Updated stock data for {Symbol}: ${Price}", symbol, stockData.Price);
            }
            
            _logger.LogInformation("Stock data updated for {SymbolCount} symbols at {Timestamp}", 
                symbols.Count, timestamp);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching stock data for {SymbolCount} symbols", symbols.Count);
            throw;
        }
    }

    /// <summary>
    /// Gets the latest cached data for all stocks
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A list of stock data objects</returns>
    public Task<List<StockData>> GetLatestStockDataAsync(CancellationToken cancellationToken = default)
    {
        var stockList = _cache.Values.ToList();
        
        if (!stockList.Any())
        {
            _logger.LogWarning("No stock data available in cache");
        }
        
        return Task.FromResult(stockList);
    }

    /// <summary>
    /// Gets the latest cached data for a specific stock symbol
    /// </summary>
    /// <param name="symbol">The stock symbol to get data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The stock data, or null if no data exists for the symbol</returns>
    public Task<StockData?> GetStockDataAsync(string symbol, CancellationToken cancellationToken = default)
    {
        _cache.TryGetValue(symbol, out var data);
        
        if (data == null)
        {
            _logger.LogWarning("No stock data available for symbol {Symbol}", symbol);
            return Task.FromResult<StockData?>(null);
        }
        
        // Check if data is stale (older than 30 minutes)
        if (data.Timestamp < DateTime.UtcNow.AddMinutes(-30))
        {
            _logger.LogInformation("Stock data for {Symbol} is stale", symbol);
        }
        
        return Task.FromResult<StockData?>(data);
    }
}
'@

New-Item -Path $stockServicePath -ItemType File -Force | Out-Null
Set-Content -Path $stockServicePath -Value $stockServiceContent -Force
Write-Host "Created StockLoaderService.cs" -ForegroundColor Green

# 5. Create StockLoaderBackgroundService.cs
$backgroundServicePath = "StockLoader\Services\StockLoaderBackgroundService.cs"
Write-Host "Creating $backgroundServicePath..." -ForegroundColor Cyan

$backgroundServiceContent = @'
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Background service that periodically fetches stock market data
/// </summary>
public class StockLoaderBackgroundService : BackgroundService
{
    private readonly ILogger<StockLoaderBackgroundService> _logger;
    private readonly StockLoaderSettings _settings;
    private readonly IStockLoaderService _stockService;
    private readonly PeriodicTimer _timer;

    /// <summary>
    /// Initializes a new instance of the StockLoaderBackgroundService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Stock loader settings</param>
    /// <param name="stockService">Stock loader service</param>
    public StockLoaderBackgroundService(
        ILogger<StockLoaderBackgroundService> logger,
        IOptions<StockLoaderSettings> settings,
        IStockLoaderService stockService)
    {
        _logger = logger;
        _settings = settings.Value;
        _stockService = stockService;
        
        // Create timer based on configured interval
        _timer = new PeriodicTimer(TimeSpan.FromMinutes(_settings.UpdateIntervalMinutes));
    }

    /// <summary>
    /// Executes the background service
    /// </summary>
    /// <param name="stoppingToken">Cancellation token used to stop the service</param>
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(
            "StockLoader Background Service starting. Update interval: {UpdateInterval} minutes. Tracking {SymbolCount} symbols",
            _settings.UpdateIntervalMinutes,
            _settings.Symbols.Count);

        if (_settings.Symbols.Count == 0)
        {
            _logger.LogWarning("No stock symbols configured. Background service will not fetch any data");
        }

        try
        {
            // Perform initial fetch immediately if we have symbols to track
            if (_settings.Symbols.Count > 0)
            {
                await _stockService.FetchStockDataAsync(_settings.Symbols, stoppingToken);
            }
            
            // Then fetch on the timer
            while (await _timer.WaitForNextTickAsync(stoppingToken) && !stoppingToken.IsCancellationRequested)
            {
                try
                {
                    if (_settings.Symbols.Count > 0)
                    {
                        await _stockService.FetchStockDataAsync(_settings.Symbols, stoppingToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while fetching stock data");
                    // Continue running service even after errors
                }
            }
        }
        catch (OperationCanceledException)
        {
            // Normal cancellation, don't treat as error
            _logger.LogInformation("StockLoader Background Service stopping due to cancellation");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "StockLoader Background Service stopped due to exception");
            throw;
        }
        finally
        {
            _logger.LogInformation("StockLoader Background Service stopped");
        }
    }
}
'@

New-Item -Path $backgroundServicePath -ItemType File -Force | Out-Null
Set-Content -Path $backgroundServicePath -Value $backgroundServiceContent -Force
Write-Host "Created StockLoaderBackgroundService.cs" -ForegroundColor Green

# 6. Create global usings file to simplify imports
$globalUsingsPath = "StockLoader\GlobalUsings.cs"
Write-Host "Creating $globalUsingsPath..." -ForegroundColor Cyan

$globalUsingsContent = @'
global using System;
global using System.Collections.Generic;
global using System.Linq;
global using System.Threading;
global using System.Threading.Tasks;
'@

New-Item -Path $globalUsingsPath -ItemType File -Force | Out-Null
Set-Content -Path $globalUsingsPath -Value $globalUsingsContent -Force
Write-Host "Created GlobalUsings.cs" -ForegroundColor Green

# 7. Update the StockLoader.csproj file
$csprojPath = "StockLoader\StockLoader.csproj"
Write-Host "Updating $csprojPath..." -ForegroundColor Cyan

$csprojContent = @'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
  </PropertyGroup>

  <ItemGroup>
    <FrameworkReference Include="Microsoft.AspNetCore.App" />
  </ItemGroup>

</Project>
'@

Set-Content -Path $csprojPath -Value $csprojContent -Force
Write-Host "Updated StockLoader.csproj" -ForegroundColor Green

# Create src folders if they don't exist
New-Item -ItemType Directory -Path "StockLoader\Models" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "StockLoader\Services" -ErrorAction SilentlyContinue | Out-Null

# All done
Write-Host "StockLoader project updates completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. Build and test the solution" -ForegroundColor White
Write-Host "2. Add any additional functionality as needed" -ForegroundColor White
Write-Host ""
Write-Host "To build the solution, run: dotnet build" -ForegroundColor Cyan