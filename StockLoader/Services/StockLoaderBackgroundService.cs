using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StockLoader.Models;

namespace StockLoader.Services;

/// <summary>
/// Background service that periodically fetches stock market data
/// </summary>
public class StockLoaderBackgroundService : BackgroundService
{
    private readonly ILogger<StockLoaderBackgroundService> _logger;
    private readonly StockLoaderSettings _settings;
    private readonly IStockLoaderService _stockService;
    private readonly PeriodicTimer _timer;

    /// <summary>
    /// Initializes a new instance of the StockLoaderBackgroundService
    /// </summary>
    /// <param name="logger">Logger</param>
    /// <param name="settings">Stock loader settings</param>
    /// <param name="stockService">Stock loader service</param>
    public StockLoaderBackgroundService(
        ILogger<StockLoaderBackgroundService> logger,
        IOptions<StockLoaderSettings> settings,
        IStockLoaderService stockService)
    {
        _logger = logger;
        _settings = settings.Value;
        _stockService = stockService;
        
        // Create timer based on configured interval
        _timer = new PeriodicTimer(TimeSpan.FromMinutes(_settings.UpdateIntervalMinutes));
    }

    /// <summary>
    /// Executes the background service
    /// </summary>
    /// <param name="stoppingToken">Cancellation token used to stop the service</param>
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(
            "StockLoader Background Service starting. Update interval: {UpdateInterval} minutes. Tracking {SymbolCount} symbols",
            _settings.UpdateIntervalMinutes,
            _settings.Symbols.Count);

        if (_settings.Symbols.Count == 0)
        {
            _logger.LogWarning("No stock symbols configured. Background service will not fetch any data");
        }

        try
        {
            // Perform initial fetch immediately if we have symbols to track
            if (_settings.Symbols.Count > 0)
            {
                await _stockService.FetchStockDataAsync(_settings.Symbols, stoppingToken);
            }
            
            // Then fetch on the timer
            while (await _timer.WaitForNextTickAsync(stoppingToken) && !stoppingToken.IsCancellationRequested)
            {
                try
                {
                    if (_settings.Symbols.Count > 0)
                    {
                        await _stockService.FetchStockDataAsync(_settings.Symbols, stoppingToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while fetching stock data");
                    // Continue running service even after errors
                }
            }
        }
        catch (OperationCanceledException)
        {
            // Normal cancellation, don't treat as error
            _logger.LogInformation("StockLoader Background Service stopping due to cancellation");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "StockLoader Background Service stopped due to exception");
            throw;
        }
        finally
        {
            _logger.LogInformation("StockLoader Background Service stopped");
        }
    }
}
