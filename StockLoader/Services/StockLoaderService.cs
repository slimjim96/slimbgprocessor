using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Service for fetching and managing stock market data
/// </summary>
public class StockLoaderService : IStockLoaderService
{
    private readonly ILogger<StockLoaderService> _logger;
    private readonly StockLoaderSettings _settings;
    private readonly Dictionary<string, StockData> _cache = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Initializes a new instance of the StockLoaderService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Stock loader settings</param>
    public StockLoaderService(
        ILogger<StockLoaderService> logger,
        IOptions<StockLoaderSettings> settings)
    {
        _logger = logger;
        _settings = settings.Value;
    }

    /// <summary>
    /// Fetches stock data for a list of symbols
    /// </summary>
    /// <param name="symbols">The stock symbols to fetch data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task FetchStockDataAsync(List<string> symbols, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching stock data for {SymbolCount} symbols", symbols.Count);
        
        try
        {
            // In a real implementation, you would call a stock market API here
            // using the _settings.ApiKey
            // This is just a simulation with random data
            await Task.Delay(300, cancellationToken); // Simulate API call
            
            var random = new Random();
            var timestamp = DateTime.UtcNow;
            
            foreach (var symbol in symbols)
            {
                // Generate consistent but semi-random base price for each symbol
                var basePrice = Math.Abs(symbol.GetHashCode() % 1000) + 10;
                
                // Add some random variation
                var price = basePrice + (decimal)(random.NextDouble() * 10 - 5);
                var change = (decimal)(random.NextDouble() * 4 - 2);
                var volume = random.Next(10000, 1000000);
                
                // Create stock data object
                var stockData = new StockData
                {
                    Symbol = symbol,
                    Price = Math.Round(price, 2),
                    Change = Math.Round(change, 2),
                    ChangePercent = Math.Round(change / price * 100, 2),
                    Volume = volume,
                    Timestamp = timestamp
                };
                
                // Update cache
                _cache[symbol] = stockData;
                
                _logger.LogDebug("Updated stock data for {Symbol}: ${Price}", symbol, stockData.Price);
            }
            
            _logger.LogInformation("Stock data updated for {SymbolCount} symbols at {Timestamp}", 
                symbols.Count, timestamp);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching stock data for {SymbolCount} symbols", symbols.Count);
            throw;
        }
    }

    /// <summary>
    /// Gets the latest cached data for all stocks
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A list of stock data objects</returns>
    public Task<List<StockData>> GetLatestStockDataAsync(CancellationToken cancellationToken = default)
    {
        var stockList = _cache.Values.ToList();
        
        if (!stockList.Any())
        {
            _logger.LogWarning("No stock data available in cache");
        }
        
        return Task.FromResult(stockList);
    }

    /// <summary>
    /// Gets the latest cached data for a specific stock symbol
    /// </summary>
    /// <param name="symbol">The stock symbol to get data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The stock data, or null if no data exists for the symbol</returns>
    public Task<StockData?> GetStockDataAsync(string symbol, CancellationToken cancellationToken = default)
    {
        _cache.TryGetValue(symbol, out var data);
        
        if (data == null)
        {
            _logger.LogWarning("No stock data available for symbol {Symbol}", symbol);
            return Task.FromResult<StockData?>(null);
        }
        
        // Check if data is stale (older than 30 minutes)
        if (data.Timestamp < DateTime.UtcNow.AddMinutes(-30))
        {
            _logger.LogInformation("Stock data for {Symbol} is stale", symbol);
        }
        
        return Task.FromResult<StockData?>(data);
    }
}
