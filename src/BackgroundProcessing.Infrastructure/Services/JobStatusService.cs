using System.Text.Json;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Services;

public class JobStatusService : IJobStatusService
{
    private readonly IDistributedCache _cache;
    private readonly ILogger<JobStatusService> _logger;
    private readonly JsonSerializerOptions _jsonOptions = new() 
    { 
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase 
    };

    public JobStatusService(IDistributedCache cache, ILogger<JobStatusService> logger)
    {
        _cache = cache;
        _logger = logger;
    }

    public async Task<JobStatusResponse?> GetJobStatusAsync(string jobId, CancellationToken cancellationToken = default)
    {
        try
        {
            var cacheKey = $"job:{jobId}";
            var cachedStatus = await _cache.GetStringAsync(cacheKey, cancellationToken);
            
            if (string.IsNullOrEmpty(cachedStatus))
            {
                return null;
            }
            
            return JsonSerializer.Deserialize<JobStatusResponse>(cachedStatus, _jsonOptions);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving job status for job {JobId}", jobId);
            return null;
        }
    }

    public async Task UpdateJobStatusAsync(JobStatusResponse status, CancellationToken cancellationToken = default)
    {
        try
        {
            var cacheKey = $"job:{status.JobId}";
            var serializedStatus = JsonSerializer.Serialize(status, _jsonOptions);
            
            // Set cache options - keep job status for 24 hours
            var cacheOptions = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            };
            
            await _cache.SetStringAsync(cacheKey, serializedStatus, cacheOptions, cancellationToken);
            
            _logger.LogInformation("Updated status for job {JobId} to {Status}", status.JobId, status.Status);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating job status for job {JobId}", status.JobId);
            throw;
        }
    }
}
