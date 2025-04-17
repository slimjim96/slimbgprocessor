using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;
using Weather;
using Weather.Models;
using Weather.Services;

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
