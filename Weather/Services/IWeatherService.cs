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
