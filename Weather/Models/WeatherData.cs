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
