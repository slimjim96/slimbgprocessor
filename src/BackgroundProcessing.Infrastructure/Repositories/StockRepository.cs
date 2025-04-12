using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Repositories;

public class StockRepository : IStockRepository
{
    private readonly StockDbContext _dbContext;
    private readonly ILogger<StockRepository> _logger;

    public StockRepository(StockDbContext dbContext, ILogger<StockRepository> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task SaveStockDataAsync(IEnumerable<StockData> stockData, CancellationToken cancellationToken = default)
    {
        try
        {
            await _dbContext.StockData.AddRangeAsync(stockData, cancellationToken);
            await _dbContext.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("Successfully saved {Count} stock data records", stockData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving stock data");
            throw;
        }
    }

    public async Task<IEnumerable<StockData>> GetLatestStockDataAsync(string symbol, CancellationToken cancellationToken = default)
    {
        return await _dbContext.StockData
            .Where(s => s.Symbol == symbol)
            .OrderByDescending(s => s.Timestamp)
            .Take(100)
            .ToListAsync(cancellationToken);
    }
}
