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
