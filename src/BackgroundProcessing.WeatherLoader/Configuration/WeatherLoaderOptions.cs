namespace BackgroundProcessing.WeatherLoader.Configuration;

public class WeatherLoaderOptions
{
    public string[] Locations { get; set; } = Array.Empty<string>();
    public string ApiKey { get; set; } = string.Empty;
    public string ApiBaseUrl { get; set; } = string.Empty;
    public int PollingIntervalSeconds { get; set; } = 900; // 15 minutes
}
