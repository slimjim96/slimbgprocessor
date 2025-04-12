namespace BackgroundProcessing.Core.Models;

public class WeatherData
{
    public string Location { get; set; } = string.Empty;
    public string Condition { get; set; } = string.Empty;
    public double Temperature { get; set; }
    public double FeelsLike { get; set; }
    public int Humidity { get; set; }
    public double WindSpeed { get; set; }
    public DateTime Timestamp { get; set; }
}
