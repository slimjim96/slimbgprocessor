namespace BackgroundProcessing.Core.Models;

public class StockData
{
    public string Symbol { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public decimal Change { get; set; }
    public decimal PercentChange { get; set; }
    public long Volume { get; set; }
    public DateTime Timestamp { get; set; }
}
