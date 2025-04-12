using BackgroundProcessing.API.Configuration;
using BackgroundProcessing.API.Models;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.API.Endpoints;

// Non-static implementation class with proper DI
public class JobEndpointDefinitions
{
    private readonly ILogger<JobEndpointDefinitions> _logger;
    private readonly IStockLoaderService _stockLoaderService;
    private readonly IWeatherLoaderService _weatherLoaderService;
    private readonly IJobStatusService _jobStatusService;
    private readonly IOptions<JobKeyOptions> _jobKeyOptions;

    public JobEndpointDefinitions(
        ILogger<JobEndpointDefinitions> logger,
        IStockLoaderService stockLoaderService,
        IWeatherLoaderService weatherLoaderService,
        IJobStatusService jobStatusService,
        IOptions<JobKeyOptions> jobKeyOptions)
    {
        _logger = logger;
        _stockLoaderService = stockLoaderService;
        _weatherLoaderService = weatherLoaderService;
        _jobStatusService = jobStatusService;
        _jobKeyOptions = jobKeyOptions;
    }

    public void DefineEndpoints(RouteGroupBuilder group)
    {
        group.MapPost("/stock/trigger", TriggerStockLoader)
            .WithName("TriggerStockLoader")
            .WithOpenApi(operation =>
            {
                operation.Summary = "Triggers the stock loader process";
                operation.Description = "Requires a valid job key GUID in the request body to authorize the trigger";
                return operation;
            });

        group.MapPost("/weather/trigger", TriggerWeatherLoader)
            .WithName("TriggerWeatherLoader")
            .WithOpenApi(operation =>
            {
                operation.Summary = "Triggers the weather loader process";
                operation.Description = "Requires a valid job key GUID in the request body to authorize the trigger";
                return operation;
            });

        group.MapGet("/status/{jobId}", GetJobStatus)
            .WithName("GetJobStatus")
            .WithOpenApi(operation =>
            {
                operation.Summary = "Gets the status of a job by ID";
                return operation;
            });
    }

    private async Task<IResult> TriggerStockLoader(JobTriggerRequest request, CancellationToken cancellationToken)
    {
        // Validate the job key GUID
        if (!IsValidJobKey(request.JobKey, "StockLoader"))
        {
            _logger.LogWarning("Unauthorized attempt to trigger stock loader job with invalid key: {JobKey}", request.JobKey);
            return TypedResults.Unauthorized();
        }

        _logger.LogInformation("Triggering stock loader job with authorized key");

        try
        {
            var result = await _stockLoaderService.TriggerProcessAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = result.JobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering stock loader job");
            return TypedResults.BadRequest("Failed to trigger stock loader job");
        }
    }

    private async Task<IResult> TriggerWeatherLoader(JobTriggerRequest request, CancellationToken cancellationToken)
    {
        // Validate the job key GUID
        if (!IsValidJobKey(request.JobKey, "WeatherLoader"))
        {
            _logger.LogWarning("Unauthorized attempt to trigger weather loader job with invalid key: {JobKey}", request.JobKey);
            return TypedResults.Unauthorized();
        }

        _logger.LogInformation("Triggering weather loader job with authorized key");

        try
        {
            var result = await _weatherLoaderService.TriggerProcessAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = result.JobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering weather loader job");
            return TypedResults.BadRequest("Failed to trigger weather loader job");
        }
    }

    private async Task<IResult> GetJobStatus(string jobId, CancellationToken cancellationToken)
    {
        var status = await _jobStatusService.GetJobStatusAsync(jobId, cancellationToken);

        if (status == null)
        {
            return TypedResults.NotFound();
        }

        return TypedResults.Ok(status);
    }

    private bool IsValidJobKey(Guid jobKey, string jobType)
    {
        return jobType switch
        {
            "StockLoader" => jobKey == _jobKeyOptions.Value.StockLoaderKey,
            "WeatherLoader" => jobKey == _jobKeyOptions.Value.WeatherLoaderKey,
            _ => false
        };
    }
}

// Static extension methods for registration
public static class JobEndpointExtensions
{
    public static RouteGroupBuilder MapJobEndpoints(this RouteGroupBuilder group, WebApplication app)
    {
        var endpoints = app.Services.GetRequiredService<JobEndpointDefinitions>();
        endpoints.DefineEndpoints(group);
        return group;
    }
}