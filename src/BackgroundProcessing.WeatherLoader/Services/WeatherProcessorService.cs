using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.WeatherLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Services;

public class WeatherProcessorService : IWeatherProcessorService
{
    private readonly IWeatherDataService _weatherDataService;
    private readonly IWeatherRepository _weatherRepository;
    private readonly IJobStatusService _jobStatusService;
    private readonly IOptions<WeatherLoaderOptions> _options;
    private readonly ILogger<WeatherProcessorService> _logger;

    public WeatherProcessorService(
        IWeatherDataService weatherDataService,
        IWeatherRepository weatherRepository,
        IJobStatusService jobStatusService,
        IOptions<WeatherLoaderOptions> options,
        ILogger<WeatherProcessorService> logger)
    {
        _weatherDataService = weatherDataService;
        _weatherRepository = weatherRepository;
        _jobStatusService = jobStatusService;
        _options = options;
        _logger = logger;
    }

    public async Task<string> ProcessWeatherAsync(CancellationToken cancellationToken = default)
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
                { "Type", "WeatherLoader" },
                { "Locations", string.Join(",", _options.Value.Locations) }
            }
        };
        
        // Update job status to running
        await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        
        _logger.LogInformation("Starting weather processing job {JobId}", jobId);
        
        try
        {
            // Fetch weather data
            var weatherData = await _weatherDataService.FetchWeatherDataAsync(_options.Value.Locations, cancellationToken);
            
            // Save to database
            await _weatherRepository.SaveWeatherDataAsync(weatherData, cancellationToken);
            
            // Update job status to completed
            jobStatus.Status = "Completed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.Metadata.Add("RecordsProcessed", weatherData.Count().ToString());
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
            
            _logger.LogInformation("Completed weather processing job {JobId}, processed {Count} records", 
                jobId, weatherData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in weather processing job {JobId}", jobId);
            
            // Update job status to failed
            jobStatus.Status = "Failed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.ErrorMessage = ex.Message;
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        }
        
        return jobId;
    }
}
