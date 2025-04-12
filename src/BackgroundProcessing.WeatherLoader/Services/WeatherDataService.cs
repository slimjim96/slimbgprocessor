using System.Net.Http.Json;
using BackgroundProcessing.Core.Exceptions;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.WeatherLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Services;

public class WeatherDataService : IWeatherDataService
{
    private readonly HttpClient _httpClient;
    private readonly IOptions<WeatherLoaderOptions> _options;
    private readonly ILogger<WeatherDataService> _logger;

    public WeatherDataService(
        HttpClient httpClient,
        IOptions<WeatherLoaderOptions> options,
        ILogger<WeatherDataService> logger)
    {
        _httpClient = httpClient;
        _options = options;
        _logger = logger;
        
        // Configure the base URL from options
        _httpClient.BaseAddress = new Uri(_options.Value.ApiBaseUrl);
    }

    public async Task<IEnumerable<WeatherData>> FetchWeatherDataAsync(IEnumerable<string> locations, CancellationToken cancellationToken = default)
    {
        try
        {
            var result = new List<WeatherData>();
            
            foreach (var location in locations)
            {
                // Construct API request URL with API key
                var requestUrl = $"/api/v1/weather?location={Uri.EscapeDataString(location)}&apiKey={_options.Value.ApiKey}";
                
                _logger.LogInformation("Fetching weather data for location: {Location}", location);
                
                // Make the API request
                var response = await _httpClient.GetAsync(requestUrl, cancellationToken);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                    _logger.LogError("Weather API returned error status code {StatusCode} for location {Location}: {ErrorContent}", 
                        response.StatusCode, location, errorContent);
                    
                    continue; // Skip this location but continue with others
                }
                
                // Parse the response
                var weatherData = await response.Content.ReadFromJsonAsync<WeatherData>(cancellationToken: cancellationToken);
                
                if (weatherData != null)
                {
                    result.Add(weatherData);
                }
                else
                {
                    _logger.LogWarning("Received null weather data for location {Location}", location);
                }
            }
            
            if (!result.Any())
            {
                throw new ProcessingException("Failed to retrieve weather data for any location");
            }
            
            return result;
        }
        catch (Exception ex) when (ex is not ProcessingException)
        {
            _logger.LogError(ex, "Error fetching weather data");
            throw new ProcessingException("Failed to fetch weather data", ex);
        }
    }
}
