# PowerShell Script to update Weather project for .NET 9
# This script creates the necessary files for the Weather project

# Set the solution path - update this to match your environment
$solutionPath = "C:\Projects\slimbgprocessor"

# Navigate to solution directory
Set-Location $solutionPath

# 1. Create WeatherSettings.cs model
$weatherSettingsPath = "Weather\Models\WeatherSettings.cs"
Write-Host "Creating $weatherSettingsPath..." -ForegroundColor Cyan

$weatherSettingsContent = @'
namespace Weather.Models;

/// <summary>
/// Configuration settings for the Weather service
/// </summary>
public class WeatherSettings
{
    /// <summary>
    /// API key for weather data provider
    /// </summary>
    public string ApiKey { get; set; } = string.Empty;
    
    /// <summary>
    /// Interval in minutes between automatic weather data updates
    /// </summary>
    public int UpdateIntervalMinutes { get; set; } = 15;
    
    /// <summary>
    /// Default location to fetch weather data for
    /// </summary>
    public string DefaultLocation { get; set; } = string.Empty;
}
'@

New-Item -Path $weatherSettingsPath -ItemType File -Force | Out-Null
Set-Content -Path $weatherSettingsPath -Value $weatherSettingsContent -Force
Write-Host "Created WeatherSettings.cs" -ForegroundColor Green

# 2. Create WeatherData.cs model
$weatherDataPath = "Weather\Models\WeatherData.cs"
Write-Host "Creating $weatherDataPath..." -ForegroundColor Cyan

$weatherDataContent = @'
namespace Weather.Models;

/// <summary>
/// Represents weather data for a specific location
/// </summary>
public class WeatherData
{
    /// <summary>
    /// The location (city, region, etc.) this weather data is for
    /// </summary>
    public string Location { get; set; } = string.Empty;
    
    /// <summary>
    /// Temperature in Celsius
    /// </summary>
    public double Temperature { get; set; }
    
    /// <summary>
    /// Humidity percentage (0-100)
    /// </summary>
    public double Humidity { get; set; }
    
    /// <summary>
    /// Weather condition description (e.g., "Partly Cloudy", "Rain", etc.)
    /// </summary>
    public string Condition { get; set; } = string.Empty;
    
    /// <summary>
    /// When this weather data was retrieved or measured
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
'@

New-Item -Path $weatherDataPath -ItemType File -Force | Out-Null
Set-Content -Path $weatherDataPath -Value $weatherDataContent -Force
Write-Host "Created WeatherData.cs" -ForegroundColor Green

# 3. Create IWeatherService.cs interface
$weatherServiceInterfacePath = "Weather\Services\IWeatherService.cs"
Write-Host "Creating $weatherServiceInterfacePath..." -ForegroundColor Cyan

$weatherServiceInterfaceContent = @'
using Weather.Models;

namespace Weather.Services;

/// <summary>
/// Interface for weather data operations
/// </summary>
public interface IWeatherService
{
    /// <summary>
    /// Fetches weather data for a specific location
    /// </summary>
    /// <param name="location">The location to fetch weather for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A task representing the asynchronous operation</returns>
    Task FetchWeatherDataAsync(string location, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets the latest cached weather data for a location
    /// </summary>
    /// <param name="location">The location to get weather for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The weather data, or null if no data exists for the location</returns>
    Task<WeatherData?> GetLatestWeatherAsync(string location, CancellationToken cancellationToken = default);
}
'@

New-Item -Path $weatherServiceInterfacePath -ItemType File -Force | Out-Null
Set-Content -Path $weatherServiceInterfacePath -Value $weatherServiceInterfaceContent -Force
Write-Host "Created IWeatherService.cs" -ForegroundColor Green

# 4. Create WeatherService.cs implementation
$weatherServicePath = "Weather\Services\WeatherService.cs"
Write-Host "Creating $weatherServicePath..." -ForegroundColor Cyan

$weatherServiceContent = @'
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Weather.Models;

namespace Weather.Services;

/// <summary>
/// Service for fetching and managing weather data
/// </summary>
public class WeatherService : IWeatherService
{
    private readonly ILogger<WeatherService> _logger;
    private readonly WeatherSettings _settings;
    private readonly Dictionary<string, WeatherData> _cache = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Initializes a new instance of the WeatherService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Weather settings</param>
    public WeatherService(
        ILogger<WeatherService> logger,
        IOptions<WeatherSettings> settings)
    {
        _logger = logger;
        _settings = settings.Value;
    }

    /// <summary>
    /// Fetches weather data for a specific location
    /// </summary>
    /// <param name="location">The location to fetch weather for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task FetchWeatherDataAsync(string location, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching weather data for {Location}", location);
        
        try
        {
            // In a real implementation, you would call a weather API here
            // using the _settings.ApiKey
            // This is just a simulation with random data
            await Task.Delay(500, cancellationToken); // Simulate API call
            
            // Create simulated weather data
            var random = new Random();
            var temperature = Math.Round(random.NextDouble() * 30, 1); // 0-30°C
            var humidity = Math.Round(random.NextDouble() * 100, 1); // 0-100%
            
            string[] conditions = { "Sunny", "Partly Cloudy", "Cloudy", "Rain", "Thunderstorm", "Snow" };
            var condition = conditions[random.Next(conditions.Length)];
            
            // Update the cached data
            var weatherData = new WeatherData
            {
                Location = location,
                Temperature = temperature,
                Humidity = humidity,
                Condition = condition,
                Timestamp = DateTime.UtcNow
            };
            
            _cache[location] = weatherData;
            
            _logger.LogInformation("Weather data updated for {Location} at {Timestamp}: {Condition}, {Temperature}°C", 
                location, weatherData.Timestamp, weatherData.Condition, weatherData.Temperature);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching weather data for {Location}", location);
            throw;
        }
    }

    /// <summary>
    /// Gets the latest cached weather data for a location
    /// </summary>
    /// <param name="location">The location to get weather for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The weather data, or null if no data exists for the location</returns>
    public Task<WeatherData?> GetLatestWeatherAsync(string location, CancellationToken cancellationToken = default)
    {
        _cache.TryGetValue(location, out var data);
        
        if (data == null)
        {
            _logger.LogWarning("No weather data available for {Location}", location);
            return Task.FromResult<WeatherData?>(null);
        }
        
        // Check if data is stale (older than 1 hour)
        if (data.Timestamp < DateTime.UtcNow.AddHours(-1))
        {
            _logger.LogInformation("Weather data for {Location} is stale", location);
        }
        
        return Task.FromResult<WeatherData?>(data);
    }
}
'@

New-Item -Path $weatherServicePath -ItemType File -Force | Out-Null
Set-Content -Path $weatherServicePath -Value $weatherServiceContent -Force
Write-Host "Created WeatherService.cs" -ForegroundColor Green

# 5. Create WeatherBackgroundService.cs
$backgroundServicePath = "Weather\Services\WeatherBackgroundService.cs"
Write-Host "Creating $backgroundServicePath..." -ForegroundColor Cyan

$backgroundServiceContent = @'
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Weather.Models;

namespace Weather.Services;

/// <summary>
/// Background service that periodically fetches weather data
/// </summary>
public class WeatherBackgroundService : BackgroundService
{
    private readonly ILogger<WeatherBackgroundService> _logger;
    private readonly WeatherSettings _settings;
    private readonly IWeatherService _weatherService;
    private readonly PeriodicTimer _timer;

    /// <summary>
    /// Initializes a new instance of the WeatherBackgroundService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Weather settings</param>
    /// <param name="weatherService">Weather service</param>
    public WeatherBackgroundService(
        ILogger<WeatherBackgroundService> logger,
        IOptions<WeatherSettings> settings,
        IWeatherService weatherService)
    {
        _logger = logger;
        _settings = settings.Value;
        _weatherService = weatherService;
        
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
            "Weather Background Service starting. Update interval: {UpdateInterval} minutes. Default location: {Location}",
            _settings.UpdateIntervalMinutes, 
            _settings.DefaultLocation);

        try
        {
            // Perform initial fetch immediately
            if (!string.IsNullOrEmpty(_settings.DefaultLocation))
            {
                await _weatherService.FetchWeatherDataAsync(_settings.DefaultLocation, stoppingToken);
            }
            
            // Then fetch on the timer
            while (await _timer.WaitForNextTickAsync(stoppingToken) && !stoppingToken.IsCancellationRequested)
            {
                try
                {
                    if (!string.IsNullOrEmpty(_settings.DefaultLocation))
                    {
                        await _weatherService.FetchWeatherDataAsync(_settings.DefaultLocation, stoppingToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while fetching weather data");
                    // Continue running service even after errors
                }
            }
        }
        catch (OperationCanceledException)
        {
            // Normal cancellation, don't treat as error
            _logger.LogInformation("Weather Background Service stopping due to cancellation");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Weather Background Service stopped due to exception");
            throw;
        }
        finally
        {
            _logger.LogInformation("Weather Background Service stopped");
        }
    }
}
'@

New-Item -Path $backgroundServicePath -ItemType File -Force | Out-Null
Set-Content -Path $backgroundServicePath -Value $backgroundServiceContent -Force
Write-Host "Created WeatherBackgroundService.cs" -ForegroundColor Green

# 6. Create global usings file to simplify imports
$globalUsingsPath = "Weather\GlobalUsings.cs"
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

# 7. Update the Weather.csproj file
$csprojPath = "Weather\Weather.csproj"
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
Write-Host "Updated Weather.csproj" -ForegroundColor Green

# Create src folders if they don't exist
New-Item -ItemType Directory -Path "Weather\Models" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "Weather\Services" -ErrorAction SilentlyContinue | Out-Null

# All done
Write-Host "Weather project updates completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. Update StockLoader project" -ForegroundColor White
Write-Host "2. Build and test the solution" -ForegroundColor White
Write-Host ""
Write-Host "To build the project, run: dotnet build" -ForegroundColor Cyan