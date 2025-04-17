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
