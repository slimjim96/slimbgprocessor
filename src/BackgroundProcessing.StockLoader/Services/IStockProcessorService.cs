namespace BackgroundProcessing.StockLoader.Services;

public interface IStockProcessorService
{
    Task<string> ProcessStocksAsync(CancellationToken cancellationToken = default);
}
