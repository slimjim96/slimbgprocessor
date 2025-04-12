using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Configuration;

public class StockLoaderHealthCheck : IHealthCheck
{
    private readonly IOptions<StockLoaderOptions> _options;

    public StockLoaderHealthCheck(IOptions<StockLoaderOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Check if configuration is valid
        if (string.IsNullOrEmpty(_options.Value.ApiKey) || string.IsNullOrEmpty(_options.Value.ApiBaseUrl))
        {
            return Task.FromResult(HealthCheckResult.Degraded("Stock Loader API configuration is incomplete"));
        }

        if (_options.Value.Symbols.Length == 0)
        {
            return Task.FromResult(HealthCheckResult.Degraded("No stock symbols configured"));
        }

        return Task.FromResult(HealthCheckResult.Healthy("Stock Loader is healthy"));
    }
}
