namespace BackgroundProcessing.StockLoader.Configuration;

public class StockLoaderOptions
{
    public string[] Symbols { get; set; } = Array.Empty<string>();
    public string ApiKey { get; set; } = string.Empty;
    public string ApiBaseUrl { get; set; } = string.Empty;
    public int PollingIntervalSeconds { get; set; } = 60;
}
