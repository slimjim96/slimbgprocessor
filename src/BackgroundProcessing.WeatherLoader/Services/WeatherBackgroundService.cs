using BackgroundProcessing.WeatherLoader.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Services;

public class WeatherLoaderBackgroundService : BackgroundService
{
    private readonly IWeatherProcessorService _processorService;
    private readonly IOptions<WeatherLoaderOptions> _options;
    private readonly ILogger<WeatherLoaderBackgroundService> _logger;

    public WeatherLoaderBackgroundService(
        IWeatherProcessorService processorService,
        IOptions<WeatherLoaderOptions> options,
        ILogger<WeatherLoaderBackgroundService> logger)
    {
        _processorService = processorService;
        _options = options;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Weather Loader Background Service is starting");

        // Determine polling interval from configuration
        var pollingInterval = TimeSpan.FromSeconds(_options.Value.PollingIntervalSeconds);

        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Weather Loader running at: {Time}", DateTimeOffset.Now);

            try
            {
                var jobId = await _processorService.ProcessWeatherAsync(stoppingToken);
                _logger.LogInformation("Scheduled weather loader job completed: {JobId}", jobId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during scheduled weather loading");
            }

            // Wait for the next polling interval
            await Task.Delay(pollingInterval, stoppingToken);
        }

        _logger.LogInformation("Weather Loader Background Service is stopping");
    }
}