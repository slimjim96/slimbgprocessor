using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Interface for stock market data operations
/// </summary>
public interface IStockLoaderService
{
    /// <summary>
    /// Fetches stock data for a list of symbols
    /// </summary>
    /// <param name="symbols">The stock symbols to fetch data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A task representing the asynchronous operation</returns>
    Task FetchStockDataAsync(List<string> symbols, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets the latest cached data for all stocks
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>A list of stock data objects</returns>
    Task<List<StockData>> GetLatestStockDataAsync(CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets the latest cached data for a specific stock symbol
    /// </summary>
    /// <param name="symbol">The stock symbol to get data for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The stock data, or null if no data exists for the symbol</returns>
    Task<StockData?> GetStockDataAsync(string symbol, CancellationToken cancellationToken = default);
}
