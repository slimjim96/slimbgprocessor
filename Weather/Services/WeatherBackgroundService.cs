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
