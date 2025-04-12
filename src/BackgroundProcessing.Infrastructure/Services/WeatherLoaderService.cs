using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Logging;
using System.Net.Http.Json;

namespace BackgroundProcessing.Infrastructure.Services;

public class WeatherLoaderService : IWeatherLoaderService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<WeatherLoaderService> _logger;

    public WeatherLoaderService(HttpClient httpClient, ILogger<WeatherLoaderService> logger)
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
            
            _logger.LogInformation("Successfully triggered weather loader job: {JobId}", result.JobId);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering weather loader process");
            throw;
        }
    }
}
