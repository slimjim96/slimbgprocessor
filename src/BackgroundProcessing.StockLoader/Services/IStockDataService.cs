using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.StockLoader.Services;

public interface IStockDataService
{
    Task<IEnumerable<StockData>> FetchStockDataAsync(IEnumerable<string> symbols, CancellationToken cancellationToken = default);
}
