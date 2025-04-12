using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Repositories;

public interface IStockRepository
{
    Task SaveStockDataAsync(IEnumerable<StockData> stockData, CancellationToken cancellationToken = default);
    Task<IEnumerable<StockData>> GetLatestStockDataAsync(string symbol, CancellationToken cancellationToken = default);
}
