using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Configuration;

public class WeatherLoaderHealthCheck : IHealthCheck
{
    private readonly IOptions<WeatherLoaderOptions> _options;

    public WeatherLoaderHealthCheck(IOptions<WeatherLoaderOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Check if configuration is valid
        if (string.IsNullOrEmpty(_options.Value.ApiKey) || string.IsNullOrEmpty(_options.Value.ApiBaseUrl))
        {
            return Task.FromResult(HealthCheckResult.Degraded("Weather Loader API configuration is incomplete"));
        }

        if (_options.Value.Locations.Length == 0)
        {
            return Task.FromResult(HealthCheckResult.Degraded("No weather locations configured"));
        }

        return Task.FromResult(HealthCheckResult.Healthy("Weather Loader is healthy"));
    }
}
