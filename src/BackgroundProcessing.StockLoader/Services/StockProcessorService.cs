using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.StockLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Services;

public class StockProcessorService : IStockProcessorService
{
    private readonly IStockDataService _stockDataService;
    private readonly IStockRepository _stockRepository;
    private readonly IJobStatusService _jobStatusService;
    private readonly IOptions<StockLoaderOptions> _options;
    private readonly ILogger<StockProcessorService> _logger;

    public StockProcessorService(
        IStockDataService stockDataService,
        IStockRepository stockRepository,
        IJobStatusService jobStatusService,
        IOptions<StockLoaderOptions> options,
        ILogger<StockProcessorService> logger)
    {
        _stockDataService = stockDataService;
        _stockRepository = stockRepository;
        _jobStatusService = jobStatusService;
        _options = options;
        _logger = logger;
    }

    public async Task<string> ProcessStocksAsync(CancellationToken cancellationToken = default)
    {
        // Generate a unique job ID
        var jobId = Guid.NewGuid().ToString();
        
        // Create initial job status
        var jobStatus = new JobStatusResponse
        {
            JobId = jobId,
            Status = "Running",
            StartTime = DateTime.UtcNow,
            Metadata = new Dictionary<string, string>
            {
                { "Type", "StockLoader" },
                { "Symbols", string.Join(",", _options.Value.Symbols) }
            }
        };
        
        // Update job status to running
        await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        
        _logger.LogInformation("Starting stock processing job {JobId}", jobId);
        
        try
        {
            // Fetch stock data
            var stockData = await _stockDataService.FetchStockDataAsync(_options.Value.Symbols, cancellationToken);
            
            // Save to database
            await _stockRepository.SaveStockDataAsync(stockData, cancellationToken);
            
            // Update job status to completed
            jobStatus.Status = "Completed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.Metadata.Add("RecordsProcessed", stockData.Count().ToString());
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
            
            _logger.LogInformation("Completed stock processing job {JobId}, processed {Count} records", 
                jobId, stockData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in stock processing job {JobId}", jobId);
            
            // Update job status to failed
            jobStatus.Status = "Failed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.ErrorMessage = ex.Message;
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        }
        
        return jobId;
    }
}
