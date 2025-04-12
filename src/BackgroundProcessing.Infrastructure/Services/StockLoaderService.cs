using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Logging;
using System.Net.Http.Json;

namespace BackgroundProcessing.Infrastructure.Services;

public class StockLoaderService : IStockLoaderService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<StockLoaderService> _logger;

    public StockLoaderService(HttpClient httpClient, ILogger<StockLoaderService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _httpClient.PostAsync("/api/process", null, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            var result = await response.Content.ReadFromJsonAsync<JobResponse>(cancellationToken: cancellationToken);
            
            if (result == null)
            {
                throw new InvalidOperationException("Failed to deserialize job response");
            }
            
            _logger.LogInformation("Successfully triggered stock loader job: {JobId}", result.JobId);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering stock loader process");
            throw;
        }
    }
}
