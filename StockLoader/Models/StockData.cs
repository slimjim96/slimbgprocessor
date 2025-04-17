namespace StockLoader.Models;

/// <summary>
/// Represents stock market data for a specific symbol
/// </summary>
public class StockData
{
    /// <summary>
    /// The stock symbol (e.g., AAPL, MSFT)
    /// </summary>
    public string Symbol { get; set; } = string.Empty;
    
    /// <summary>
    /// Current stock price
    /// </summary>
    public decimal Price { get; set; }
    
    /// <summary>
    /// Change in price from previous close
    /// </summary>
    public decimal Change { get; set; }
    
    /// <summary>
    /// Percentage change from previous close
    /// </summary>
    public decimal ChangePercent { get; set; }
    
    /// <summary>
    /// Trading volume
    /// </summary>
    public long Volume { get; set; }
    
    /// <summary>
    /// When this stock data was retrieved
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
