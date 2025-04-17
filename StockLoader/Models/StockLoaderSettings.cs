namespace StockLoader.Models;

/// <summary>
/// Configuration settings for the StockLoader service
/// </summary>
public class StockLoaderSettings
{
    /// <summary>
    /// API key for stock data provider
    /// </summary>
    public string ApiKey { get; set; } = string.Empty;
    
    /// <summary>
    /// Interval in minutes between automatic stock data updates
    /// </summary>
    public int UpdateIntervalMinutes { get; set; } = 5;
    
    /// <summary>
    /// List of stock symbols to track
    /// </summary>
    public List<string> Symbols { get; set; } = new List<string>();
}
