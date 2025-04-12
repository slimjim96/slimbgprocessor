using BackgroundProcessing.StockLoader.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Services;

public class StockLoaderBackgroundService : BackgroundService
{
    private readonly IStockProcessorService _processorService;
    private readonly IOptions<StockLoaderOptions> _options;
    private readonly ILogger<StockLoaderBackgroundService> _logger;

    public StockLoaderBackgroundService(
        IStockProcessorService processorService,
        IOptions<StockLoaderOptions> options,
        ILogger<StockLoaderBackgroundService> logger)
    {
        _processorService = processorService;
        _options = options;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Stock Loader Background Service is starting");
        
        // Determine polling interval from configuration
        var pollingInterval = TimeSpan.FromSeconds(_options.Value.PollingIntervalSeconds);
        
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Stock Loader running at: {Time}", DateTimeOffset.Now);
            
            try
            {
                var jobId = await _processorService.ProcessStocksAsync(stoppingToken);
                _logger.LogInformation("Scheduled stock loader job completed: {JobId}", jobId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during scheduled stock loading");
            }
            
            // Wait for the next polling interval
            await Task.Delay(pollingInterval, stoppingToken);
        }
        
        _logger.LogInformation("Stock Loader Background Service is stopping");
    }
}
