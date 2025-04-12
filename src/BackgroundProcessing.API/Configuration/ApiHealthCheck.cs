using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace BackgroundProcessing.API.Configuration;

public class ApiHealthCheck : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Add more sophisticated health checks as needed
        return Task.FromResult(HealthCheckResult.Healthy("API is healthy"));
    }
}
